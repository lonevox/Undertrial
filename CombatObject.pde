class CombatObject extends PhysicsObject {
  private boolean active = false;
  private String name;
  private int timeWhenCreated = millis();
  private double startTime;
  private int timeWhenStarted;
  private double lifetime;
  private ArrayList<String> flippedOutputs = new ArrayList<String>();
  private PShape texture = createShape();
  private PShape textureFlipX = createShape();
  private boolean useFlippedTextures = false;
  private PVector centreOfTexture = new PVector();
  private int scale = 1;
  private ArrayList<JSONObject> animations = new ArrayList<JSONObject>();
  private ArrayList<Point2D> pointsInShape = new ArrayList<Point2D>();
  
  CombatObject(JSONObject data) {
    // Parse data
    name = data.getString("type");
    position.x = data.getFloat("positionX");
    position.y = data.getFloat("positionY");
    startTime = data.getFloat("startTime");
    if (startTime == 0) {
      active = true;
      timeWhenStarted = millis();
    }
    lifetime = data.getFloat("duration");
    // Put all flipped outputs into flippedOutputs (if there are any)
    if (!data.isNull("flipOutput")) {
      JSONArray flipOutput = data.getJSONArray("flipOutput");
      for (int i=0; i<flipOutput.size(); i++) {
        flippedOutputs.add(flipOutput.getString(i));
      }
    }
    
    // Get sprite and animations from combat object type
    JSONObject combatObjectTypeData = combatObjectJSON.getJSONObject(data.getString("type"));
    if (!combatObjectTypeData.isNull("flipTexture")) useFlippedTextures = combatObjectTypeData.getBoolean("flipTexture");
    PImage sprite = loadImage(combatObjectTypeData.getString("sprite"));
    scale = combatObjectTypeData.getInt("scale");
    sprite = nearestNeighbourScale(sprite, scale);
    centreOfTexture.x = sprite.width/2;
    centreOfTexture.y = sprite.height/2;
    JSONArray animationsJSONArray = combatObjectTypeData.getJSONArray("animations");
    for (int i=0; i<animationsJSONArray.size(); i++) {
      animations.add(animationsJSONArray.getJSONObject(i));
    }
    
    // Create textures from sprite
    texture.beginShape();
    texture.textureMode(NORMAL);
    texture.texture(sprite);
    texture.vertex(-sprite.width/2, -sprite.height/2, 0, 0);                              // Top left corner
    texture.vertex(sprite.width/2, -sprite.height/2, 1, 0);                   // Top right corner
    texture.vertex(sprite.width/2, sprite.height/2, 1, 1);       // Bottom right corner
    texture.vertex(-sprite.width/2, sprite.height/2, 0, 1);                  // Bottom left corner
    texture.textureMode(IMAGE);
    texture.endShape();
    
    textureFlipX.beginShape();
    textureFlipX.textureMode(NORMAL);
    textureFlipX.texture(sprite);
    textureFlipX.vertex(-sprite.width/2, -sprite.height/2, 1, 0);                         // Top left corner
    textureFlipX.vertex(sprite.width/2, -sprite.height/2, 0, 0);              // Top right corner
    textureFlipX.vertex(sprite.width/2, sprite.height/2, 0, 1);  // Bottom right corner
    textureFlipX.vertex(-sprite.width/2, sprite.height/2, 1, 1);             // Bottom left corner
    textureFlipX.textureMode(IMAGE);
    textureFlipX.endShape();
    
    // Create collision shape
    if (!combatObjectTypeData.isNull("pointsInShape")) {
      JSONArray pointsInShapeData = combatObjectTypeData.getJSONArray("pointsInShape");
      for (int i=0; i<pointsInShapeData.size(); i++) {
        JSONObject pointData = pointsInShapeData.getJSONObject(i);
        pointsInShape.add(new Point2D.Double(pointData.getInt("x") * scale, pointData.getInt("y") * scale));
      }
      collisionShape = new PolygonCollisionShape(pointsInShape.toArray(new Point2D[0]));
    }
    ignoreCollisions = true;
  }
  
  @Override void update() {
    // Start if it has been startTime seconds since the object was created
    if (active == false) {
      if ((millis() - timeWhenCreated) / 1000.0 > startTime) {
        active = true;
        timeWhenStarted = millis();
      }
    } else {
      // Apply animations
      for (JSONObject animation : animations) {
        // Continue if animation hasn't started yet
        if (!animation.isNull("delay") && animation.getFloat("delay") > getTimeAlive()) continue; 
        float magnitude = animation.getFloat("magnitude");
        switch (animation.getString("modifies")) {
          case "positionY":
            boolean flipped = flippedOutputs.contains("positionY");
            switch (animation.getString("type")) {
              case "linear":
                if (!flipped) {
                  position.y += magnitude;
                } else {
                  position.y -= magnitude;
                }
                break;
              case "sine":
                float frequency = animation.getFloat("frequency");
                if (!flipped) {
                  position.y += sin(((millis() - timeWhenStarted) * frequency % 1000) / 1000 * 2 * (float)Math.PI) * magnitude;
                } else {
                  position.y -= sin(((millis() - timeWhenStarted) * frequency % 1000) / 1000 * 2 * (float)Math.PI) * magnitude;
                }
                break;
            }
            break;
            
          case "positionX":
            flipped = flippedOutputs.contains("positionX");
            switch (animation.getString("type")) {
              case "linear":
                if (!flipped) {
                  position.x += magnitude;
                } else {
                  position.x -= magnitude;
                }
                break;
              case "sine":
                float frequency = animation.getFloat("frequency");
                if (!flipped) {
                  position.x += sin(((millis() - timeWhenStarted) * frequency % 1000) / 1000 * 2 * (float)Math.PI) * magnitude;
                } else {
                  position.x -= sin(((millis() - timeWhenStarted) * frequency % 1000) / 1000 * 2 * (float)Math.PI) * magnitude;
                }
                break;
            }
            break;
            
          case "rotation":
            flipped = flippedOutputs.contains("rotation");
            switch (animation.getString("type")) {
              case "linear":
                if (!flipped) {
                  setRotation(rotation + magnitude);
                } else {
                  setRotation(rotation - magnitude);
                }
                break;
              case "sine":
                float frequency = animation.getFloat("frequency");
                if (!flipped) {
                  setRotation(sin(((millis() - timeWhenStarted) * frequency % 1000) / 1000 * 2 * (float)Math.PI) * magnitude);
                } else {
                  setRotation(sin(((millis() - timeWhenStarted) * frequency % 1000) / 1000 * 2 * (float)Math.PI + (float)Math.PI) * magnitude + 90);
                }
                break;
            }
            break;
        }
      }
    }
    // Update collision shape if flipped
    if (collisionShape != null && useFlippedTextures && flippedOutputs.contains("positionX")) {
      ((PolygonCollisionShape)collisionShape).setXFlipped(true);
    }
    // Translate collision shape to position
    if (collisionShape != null) {
      collisionShape.setWorldTranslation(new Point2D.Double(position.x, position.y));
    }
  }
  
  void draw(PGraphics src) {
    if (active) {
      // Draw to src
      src.beginDraw();
      src.pushMatrix();
      src.translate(position.x + centreOfTexture.x, position.y + centreOfTexture.y);
      src.rotate(rotation);
      if (useFlippedTextures && flippedOutputs.contains("positionX")) {
        src.shape(textureFlipX);
      } else {
        src.shape(texture);
      }
      src.popMatrix();
      src.endDraw();
      
      // Draw collision overlay
      if (collisionShape != null) collisionShape.drawOverlay(new Point2D.Double(position.x, position.y));
    }
  }
  
  // Returns the length of time in seconds that the object has existed for
  double getTimeAlive() {
    if (active) {
      return (millis() - timeWhenStarted) / 1000.0;
    }
    return 0;
  }
  
  // Returns the lifetime of the object, which is set in the JSON file
  double getLifetime() {
    return lifetime;
  }
  
  String getName() {
    return name;
  }
}
