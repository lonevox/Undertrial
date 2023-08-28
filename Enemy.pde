import java.util.concurrent.*;

class Enemy {
  private JSONObject data;
  private int stage;
  private int attack;
  private int stageStartTime;
  private PImage sprite;
  private int health = 3;
  private boolean drawExplosion = false;
  private ArrayList<CombatObject> combatObjects = new ArrayList<CombatObject>();
  private final ScheduledExecutorService attackExecutorService = Executors.newSingleThreadScheduledExecutor();
  private ScheduledFuture futureAttack;
  private final ScheduledExecutorService explosionExecutorService = Executors.newSingleThreadScheduledExecutor();
  
  Enemy(JSONObject enemyData) {
    this.data = enemyData;
  }
  
  void startFight() {
    setStage(0);
  }
  
  void endFight() {
    for (CombatObject combatObject : combatObjects) {
      combatObject.removeFromWorld();
    }
  }
  
  int getStage() {
    return stage;
  }
  
  void setStage(int stageIndex) {
    stage = stageIndex;
    stageStartTime = millis();
    JSONObject stageData = data.getJSONArray("stages").getJSONObject(stage);
    sprite = loadImage(stageData.getString("sprite"));
    sprite = nearestNeighbourResize(sprite, 8);
    setAttack(0);
  }
  
  int getAttack() {
    return attack;
  }
  
  void setAttack(int attackIndex) {
    attack = attackIndex;
    // Get attack
    JSONArray attacks = data.getJSONArray("stages").getJSONObject(stage).getJSONArray("attacks");
    JSONObject attackObject = attacks.getJSONObject(attackIndex);
    
    // Create all objects in the attack
    if (!attackObject.isNull("objects")) createAttackObjects(attackObject.getJSONArray("objects"));
    // Create all objects in attacks that are a part of this attack
    if (!attackObject.isNull("includeAttacks")) {
      // Find attacks
      JSONArray includedAttackNames = attackObject.getJSONArray("includeAttacks");
      for (int i=0; i<includedAttackNames.size(); i++) {
        for (int j=0; j<attacks.size(); j++) {
          JSONObject otherAttackObject = attacks.getJSONObject(j);
          if (otherAttackObject.getString("name").equals(includedAttackNames.getString(i))) {
            createAttackObjects(otherAttackObject.getJSONArray("objects"));
            break;
          }
        }
      }
    }
    
    // After this attacks duration is complete, do the next attack
    if (futureAttack != null) futureAttack.cancel(true);
    futureAttack = attackExecutorService.schedule(new Runnable() {public void run() {nextAttack();}}, (long)(attackObject.getFloat("duration") * 1000), TimeUnit.MILLISECONDS);
  }
  
  void nextAttack() {
    int numberOfAttacks = data.getJSONArray("stages").getJSONObject(stage).getJSONArray("attacks").size();
    if (attack + 1 < numberOfAttacks) {
      setAttack(attack + 1);
    } else {
      setAttack(0);
    }
  }
  
  void createAttackObjects(JSONArray attackObjects) {
    for (int i=0; i<attackObjects.size(); i++) {
      JSONObject combatObjectData = attackObjects.getJSONObject(i);
      combatObjects.add(new CombatObject(combatObjectData));
    }
  }
  
  void hit() {
    health -= 1;
    if (health == 0) {
      endFight();
      switchScene(winScene);
      // Move to the main menu after 2 seconds
      player.returnToMenuExecutorService.schedule(new Runnable() {public void run() {
        switchScene(mainMenuScene);
      }}, 4, TimeUnit.SECONDS);
    } else {
      setStage(stage + 1);
    }
    
    // Draw an explosion on the enely and stop the explosion after it has looped once
    drawExplosion = true;
    AnimationInstance explosionAnimationInstance = explosionAnimation.getAnimationInstance(0);
    explosionAnimationInstance.setFrame(0);
    explosionAnimationInstance.play();
    attackExecutorService.schedule(new Runnable() {public void run() {drawExplosion = false;}}, 10 / 6, TimeUnit.SECONDS);
  }
  
  void draw(PGraphics src) {
    src.beginDraw();
    
    // Draw big sprite
    src.image(sprite, width/2 - sprite.width/2, 27);
    
    // Draw health bar
    src.fill(255);
    src.rect(width/3, 20, width/3, 20);
    src.fill(253, 78, 81);
    switch (health) {
      case 3:
        src.rect(width/3 + width/3/3*2, 20, width/3/3, 20);
      case 2:
        src.rect(width/3 + width/3/3, 20, width/3/3, 20);
      case 1:
        src.rect(width/3, 20, width/3/3, 20);
    }
    src.fill(255);
    
    // Draw an explosion on the enemy if damage has been taken
    if (drawExplosion) {
      AnimationInstance explosionAnimationInstance = explosionAnimation.getAnimationInstance(0);
      explosionAnimationInstance.draw(src, width/2 - explosionAnimation.getWidth()/2, height/10 - explosionAnimation.getHeight()/2, 10);
    }
    
    src.endDraw();
    
    // Update and draw combat objects
    ArrayList<CombatObject> combatObjectsToDestroy = new ArrayList<CombatObject>();
    ArrayList<CombatObject> combatObjectsClone = new ArrayList<CombatObject>(combatObjects);    // Clone so that attackExecutorService doesn't modify the list during the loop
    for (CombatObject combatObject : combatObjectsClone) {
      combatObject.update();
      combatObject.draw(src);
      // Destroy the combat object if it has reached the end of its duration
      if (combatObject.getTimeAlive() >= combatObject.getLifetime()) combatObjectsToDestroy.add(combatObject);
    }
    // Destroy combat objects
    for (CombatObject combatObject : combatObjectsToDestroy) {
      combatObject.removeFromWorld();
      combatObjects.remove(combatObject);
    }
  }
}
