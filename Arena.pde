import java.awt.Dimension;

final class Arena {
  private Rectangle dimensions = new Rectangle();
  private Wall[] walls = new Wall[4];
  private int wallThickness = 8;
  
  private Arena() {}
  
  void setPosition(int x, int y) {
    dimensions.setLocation(x, y);
  }
  
  void setSize(int x, int y) {
    dimensions.setSize(x, y);
  }
  
  Dimension getSize() {
    return dimensions.getSize();
  }
  
  Wall[] getWalls() {
    return walls;
  }
  
  void createWalls() {
    // Top wall
    walls[0] = new Wall(new RectangleCollisionShape(new Rectangle(dimensions.x - wallThickness/2, dimensions.y - wallThickness/2, dimensions.width + wallThickness, wallThickness)));
    // Right wall
    walls[1] = new Wall(new RectangleCollisionShape(new Rectangle(dimensions.x + dimensions.width - wallThickness/2, dimensions.y - wallThickness/2, wallThickness, dimensions.height + wallThickness)));
    // Bottom wall
    walls[2] = new Wall(new RectangleCollisionShape(new Rectangle(dimensions.x - wallThickness/2, dimensions.y + dimensions.height - wallThickness/2, dimensions.width + wallThickness, wallThickness)));
    // Left wall
    walls[3] = new Wall(new RectangleCollisionShape(new Rectangle(dimensions.x - wallThickness/2, dimensions.y - wallThickness/2, wallThickness, dimensions.height + wallThickness)));
  }
  
  void draw(PGraphics src) {
    // Arena walls
    src.stroke(255);
    src.strokeWeight(wallThickness);
    src.strokeCap(PROJECT);
    src.beginDraw();
    src.line(dimensions.x, dimensions.y, dimensions.x + dimensions.width, dimensions.y);
    src.line(dimensions.x + dimensions.width, dimensions.y, dimensions.x + dimensions.width, dimensions.y + dimensions.height);
    src.line(dimensions.x + dimensions.width, dimensions.y + dimensions.height, dimensions.x, dimensions.y + dimensions.height);
    src.line(dimensions.x, dimensions.y + dimensions.height, dimensions.x, dimensions.y);
    src.strokeWeight(1);
    src.endDraw();
    // Collision overlay
    for (int i=0; i<arena.getWalls().length; i++) {
      Wall wall = arena.getWalls()[i];
      Point2D.Double drawTranslation = new Point2D.Double(wall.getPosition().x, wall.getPosition().y);
      ((RectangleCollisionShape)wall.getCollisionShape()).drawOverlay(drawTranslation);
    }
  }
}

class Wall extends PhysicsObject {
  Wall(RectangleCollisionShape collisionShape) {
    this.collisionShape = collisionShape;
  }
  
  PVector getPosition() {
    return new PVector(collisionShape.getBounds().x, collisionShape.getBounds().y);
  }
}
