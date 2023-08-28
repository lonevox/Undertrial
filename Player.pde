class Player extends PhysicsObject {
  private PImage sprite;
  private boolean alive = true;
  private ArrayList<PlayerGib> playerGibs = new ArrayList<PlayerGib>();
  final ScheduledExecutorService returnToMenuExecutorService = Executors.newSingleThreadScheduledExecutor();
  
  Player() {
    sprite = loadImage("player.png");
    position = new PVector(width/2, height/2);
    speedMultiplier = 7;
    
    // Create collision shape
    Point2D.Double[] pointsInShape = new Point2D.Double[6];
    pointsInShape[0] = new Point2D.Double(0,0);
    pointsInShape[1] = new Point2D.Double(28,0);
    pointsInShape[2] = new Point2D.Double(28,12);
    pointsInShape[3] = new Point2D.Double(16,24);
    pointsInShape[4] = new Point2D.Double(12,24);
    pointsInShape[5] = new Point2D.Double(0,12);
    collisionShape = new PolygonCollisionShape(pointsInShape);
  }
  
  @Override void update() {
    if (alive) {
      // Input
      handleInput();
      // Update collision shape world translation
      collisionShape.setWorldTranslation(new Point2D.Double(position.x, position.y));
      // Kill player if colliding with a CombatObject
      ArrayList<PhysicsObject> allCollisions = getAllCollisions();
      for (PhysicsObject physicsObject : allCollisions) {
        if (physicsObject instanceof CombatObject) {
          // Dont kill player if the CombatObject is a vulnerable point, instead damage enemy
          if (((CombatObject)physicsObject).getName().equals("vulnerablePoint")) {
            currentEnemy.hit();
            physicsObject.removeFromWorld();
          } else {
            die();
          }
        }
      }
    }
  }
  
  void draw(PGraphics src) {
    if (alive) {
      src.beginDraw();
      src.image(sprite, position.x, position.y);
      src.endDraw();
      collisionShape.drawOverlay(new Point2D.Double(position.x, position.y));
    } else {
      // Draw gibs
      for (PlayerGib playerGib : playerGibs) {
        playerGib.update();
        playerGib.draw(src);
      }
    }
  }
  
  void handleInput() {
    velocity.x = 0;
    velocity.y = 0;
    boolean doMove = false;
    if (pressedKeys.contains('w')) {
      velocity.y -= 1;
      doMove = true;
    }
    if (pressedKeys.contains('a')) {
      velocity.x -= 1;
      doMove = true;
    }
    if (pressedKeys.contains('s')) {
      velocity.y += 1;
      doMove = true;
    }
    if (pressedKeys.contains('d')) {
      velocity.x += 1;
      doMove = true;
    }
    velocity.normalize();
    if (doMove) moveByVelocity();
  }
  
  void die() {
    alive = false;
    
    // Create giblets
    for (int i=0; i<5; i++) {
      playerGibs.add(new PlayerGib(this));
    }
    
    // Go back to the main menu after 1 second
    returnToMenuExecutorService.schedule(new Runnable() {public void run() {
      currentEnemy.endFight();
      switchScene(mainMenuScene);
    }}, 1, TimeUnit.SECONDS);
  }
}


class PlayerGib extends PhysicsObject {
  private PImage sprite = loadImage("playerGiblet.png");
  private Player playerRef;
  private float angleOfMotion;
  
  PlayerGib(Player player) {
    playerRef = player;
    position = playerRef.position;
    angleOfMotion = random(2 * (float)Math.PI);
    velocity = PVector.fromAngle(angleOfMotion);
    speedMultiplier = 5;
    
    // Create collision shape
    collisionShape = new RectangleCollisionShape(new Rectangle((int)position.x, (int)position.y, sprite.width, sprite.height));
  }
  
  @Override void update() {
    // Move towards angle of motion
    moveByVelocity();
    // Update collision translation
    collisionShape.setWorldTranslation(new Point2D.Double(position.x, position.y));
  }
  
  void draw(PGraphics src) {
    src.beginDraw();
    src.image(sprite, position.x, position.y);
    src.endDraw();
  }
}
