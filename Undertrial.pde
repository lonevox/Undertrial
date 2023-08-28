import java.util.HashSet;

Animation explosionAnimation;

PShader brightFilterShader;
PShader kawaseBlurDownsampleShader, kawaseBlurUpsampleShader;
PShader heatDistortionShader;

PGraphics src;

PostProcessPipeline heatDistortionPipeline, bloomPipeline;

boolean showFramerate = false;
boolean showCollisionOverlay = false;
boolean showSource = false;
boolean bloom = false;
boolean heatDistortion = false;
boolean useShaders = true;

// JSON files
JSONObject enemiesJSON, combatObjectJSON;

Player player;

Enemy[] enemies = new Enemy[3];
int currentEnemyID = 0;
Enemy currentEnemy;

Arena arena = new Arena();

// GUI
PFont debugFont, mainFont, titleFont;

// Scenes
Scene mainMenuScene, gameScene, winScene;
Scene currentScene;

int startTimeOfGame;

// HashSet for holding the keys that are currently pressed
HashSet<Character> pressedKeys = new HashSet<Character>();

void setup() {
  // Setup graphics
  size(1280, 720, P2D);
  noSmooth();
  src = createGraphics(width, height, P2D);
  collisionOverlay = createGraphics(width, height, P2D);
  collisionOverlay.beginDraw();
  collisionOverlay.fill(color(100,250,70,127));
  collisionOverlay.noStroke();
  collisionOverlay.endDraw();
  
  // Load fonts
  debugFont = createFont("ut-hp-font.ttf", 8);
  mainFont = createFont("ut-hp-font.ttf", 12);
  titleFont = createFont("monster-friend-fore-pro.ttf", 32);
  
  // Load JSON
  enemiesJSON = loadJSONObject("enemies.json");
  combatObjectJSON = loadJSONObject("combatObjects.json");
  
  // Create scenes
  mainMenuScene = new Scene(
    new Consumer<PGraphics>() {
      public void accept(PGraphics src) {
        src.background(0);
        // Draw debug keys
        src.textFont(debugFont);
        src.textAlign(LEFT, TOP);
        src.text("Press F to toggle framerate", width-325, 20);
        src.text("Press O to toggle collision overlay", width-325, 40);
        src.text("Press P to toggle shaders", width-325, 60);
        // Draw title
        src.textFont(titleFont);
        src.textAlign(CENTER, CENTER);
        src.text("Undertrial", width/2, height/3);
        //// Draw help section
        // Telegraph explanation
        src.textFont(mainFont);
        PImage telegraphImage = loadImage("telegraph.png");
        telegraphImage = nearestNeighbourScale(telegraphImage, 4);
        src.image(telegraphImage, width/3 - 50, height/3*2);
        src.text("=  Warnings for incoming attacks", width/2 + 50, height/3*2 + telegraphImage.height/2);
        // Vulnerable point explanation
        PImage vulnerablePointImage = loadImage("vulnerablePoint.png");
        vulnerablePointImage = nearestNeighbourScale(vulnerablePointImage, 4);
        src.image(vulnerablePointImage, width/3 - 50, height/3*2 + 75);
        src.text("=  Bump into these to damage enemies", width/2 + 72, height/3*2 + 75 + vulnerablePointImage.height/2);
        // Combat object explanation
        src.text("Avoid everything else. Easy.", width/2, height/3*2 + 180);
      }
    }
  );
  gameScene = new Scene(new Consumer<PGraphics>() {
    public void accept(PGraphics src) {
      src.background(0);
      // Draw arena
      arena.draw(src);
      
      // Draw player
      player.update();
      player.draw(src);
      
      // Draw enemy
      currentEnemy.draw(src);
    }
  });
  winScene = new Scene(new Consumer<PGraphics>() {
    public void accept(PGraphics src) {
      src.background(0);
      // Draw win text
      src.textFont(mainFont);
      src.text("You win", width/2, height/2);
      
      // Draw player
      player.update();
      player.draw(src);
    }
  });
  switchScene(mainMenuScene);
  
  // Create GUI
  Button fightVorpalButton = new Button("Fight Vorpal", mainFont, new Rectangle(width/2 - 100 - width/4, height/2 - 40, 200, 80), color(100), color(200), new Consumer() {
    public void accept(Object object) {
      currentEnemyID = 0;
      switchScene(gameScene);
    }
  });
  mainMenuScene.addGUIElement(fightVorpalButton);
  Button fightFreaButton = new Button("Fight Frea", mainFont, new Rectangle(width/2 - 100, height/2 - 40, 200, 80), color(100), color(200), new Consumer() {
    public void accept(Object object) {
      currentEnemyID = 1;
      switchScene(gameScene);
    }
  });
  mainMenuScene.addGUIElement(fightFreaButton);
  Button fightIgnusButton = new Button("Fight Ignus", mainFont, new Rectangle(width/2 - 100 + width/4, height/2 - 40, 200, 80), color(100), color(200), new Consumer() {
    public void accept(Object object) {
      currentEnemyID = 2;
      switchScene(gameScene);
      heatDistortion = true;
    }
  });
  mainMenuScene.addGUIElement(fightIgnusButton);

  // Create explosion animation
  explosionAnimation = new Animation("pixel_explosion_small", 6);
  // Create an instance of the explosion animation
  AnimationInstance animInst = explosionAnimation.createAnimationInstance();
  //animInst.play();

  // Load shaders
  heatDistortionShader = loadShader("heatDistortion.frag");
  brightFilterShader = loadShader("brightFilter.frag");
  kawaseBlurDownsampleShader = loadShader("kawaseBlurDownsample.frag");
  kawaseBlurUpsampleShader = loadShader("kawaseBlurUpsample.frag");
  
  // Create heat distortion post-processing pipeline
  heatDistortionPipeline = new PostProcessPipeline(width, height);
  heatDistortionPipeline.setUniformStep(heatDistortionShader, "distortTexture", loadImage("seamlessNoise.png"), true);
  heatDistortionPipeline.setUniformStep(heatDistortionShader, "time", new Supplier<Integer>() {
    public Integer get() {return millis();}
  }, false);
  heatDistortionPipeline.setShaderStep(heatDistortionShader);
  
  // Create bloom post-processing pipeline
  bloomPipeline = new PostProcessPipeline(width, height);
  bloomPipeline.setShaderStep(brightFilterShader);
  bloomPipeline.setOutputSizeStep(width/4, height/4);
  bloomPipeline.setShaderStep(kawaseBlurDownsampleShader);
  bloomPipeline.setOutputSizeStep(width/2, height/2);
  bloomPipeline.setShaderStep(kawaseBlurDownsampleShader);
  bloomPipeline.setShaderStep(kawaseBlurUpsampleShader);
  bloomPipeline.setOutputSizeStep(width, height);
  bloomPipeline.setShaderStep(kawaseBlurUpsampleShader);
}

void switchScene(Scene scene) {
  currentScene = scene;
  if (currentScene == gameScene) {
    startGameScene();
  } else if (currentScene == mainMenuScene) {
    startMenuScene();
  }
}

void startMenuScene() {
  bloom = false;
  heatDistortion = false;
}

void startGameScene() {
  bloom = true;
  
  startTimeOfGame = millis();
  
  // Setup arena
  arena.setSize(500, 400);
  arena.setPosition((int)(width/2 - arena.getSize().width/2), (int)(height - height*0.6));
  arena.createWalls();
  
  // Create player
  player = new Player();
  
  // Create enemies
  enemies[0] = new Enemy(enemiesJSON.getJSONObject("vorpal"));
  enemies[1] = new Enemy(enemiesJSON.getJSONObject("frea"));
  enemies[2] = new Enemy(enemiesJSON.getJSONObject("ignus"));
  currentEnemy = enemies[currentEnemyID];
  currentEnemy.startFight();
}

void draw() {
  currentScene.draw(src);
  
  ////////// COMPOSE SCENE //////////
  if (useShaders) {
    if (heatDistortion && bloom) {
      bloomPipeline.process(heatDistortionPipeline.process(src, BLEND), LIGHTEST);
    } else if (heatDistortion) {
      heatDistortionPipeline.process(src, BLEND);
    } else if (bloom) {
      image(src, 0, 0);
      bloomPipeline.process(src, LIGHTEST);
    } else {
      image(src, 0, 0);
    }
  } else {
    image(src, 0, 0);
  }
  // Collision overlay for debugging collisions
  if (showCollisionOverlay) {
    blendMode(SUBTRACT);
    image(collisionOverlay, 0, 0);
    blendMode(BLEND);
    collisionOverlay.beginDraw();
    collisionOverlay.background(0);
    collisionOverlay.endDraw();
  }
  
  if (showFramerate) text(int(frameRate), 20, 20);
}

void mouseClicked() {
  // Run clicked() on a GUIElement if it is under the mouse
  for (GUIElement element : currentScene.getGUIElements()) {
    if (element instanceof Clickable && ((Clickable)element).contains(new Point2D.Double(mouseX, mouseY))) {
      ((Clickable)element).clicked();
    }
  }
  
  //showSource = !showSource;
  //bloom = !bloom;
  /*for (AnimationInstance animationInstance : explosionAnimation.getAllAnimationInstances()) {
    if (animationInstance.isPlaying()) {
      animationInstance.pause();
    } else {
      animationInstance.unpause();
    }
    if (!animationInstance.hasStarted()) {
      animationInstance.play();
    }
  }*/
  //currentEnemy.nextAttack();
}

void keyPressed() {
  pressedKeys.add(key);
  if (key == 'o') showCollisionOverlay = !showCollisionOverlay;
  if (key == 'f') showFramerate = !showFramerate;
  if (key == 'p') useShaders = !useShaders;
}

void keyReleased() {
  pressedKeys.remove(key);
}
