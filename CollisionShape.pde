import java.awt.Rectangle;
import java.awt.Shape;
import java.awt.Polygon;
import java.awt.geom.Point2D;
import java.awt.geom.Area;
import java.awt.geom.AffineTransform;
import java.awt.geom.FlatteningPathIterator;

PGraphics collisionOverlay;

interface CollisionShape {
  Area getArea();                                 // Gets the area which defines the CollisionShape
  Rectangle getBounds();                          // Returns the bounding box of the CollisionShape
  boolean contains(Point2D point);                // Returns true if the point lies within the CollisionShape
  boolean overlaps(Area area);                    // Returns true if the CollisionShape overlaps an area
  Point2D[] getVertices();                        // Returns an array of the vertices that make up the CollisionShape
  void setWorldTranslation(Point2D translation);  // Sets the translation of the collision shape in the world
  void drawOverlay(Point2D translate);            // Draws a transparent overlay of the CollisionShape with a translation
}


interface Rotatable {
  void setRotation(float radians);
}


class RectangleCollisionShape implements CollisionShape {
  private Rectangle rectangle;
  private Point2D[] vertices = new Point2D[4];
  
  RectangleCollisionShape(Rectangle rectangle) {
    this.rectangle = rectangle;
    vertices[0] = rectangle.getLocation();
    vertices[1] = new Point2D.Double(rectangle.x + rectangle.width, rectangle.y);
    vertices[2] = new Point2D.Double(rectangle.x + rectangle.width, rectangle.y + rectangle.height);
    vertices[3] = new Point2D.Double(rectangle.x, rectangle.y + rectangle.height);
  }
  
  Area getArea() {
    return new Area(rectangle);
  }
  
  Rectangle getBounds() {
    return rectangle.getBounds();
  }
  
  boolean contains(Point2D point) {
    return rectangle.contains(point);
  }
  
  boolean overlaps(Area area) {
    area.intersect(getArea());
    return area.isEmpty();
  }
  
  Point2D[] getVertices() {
    return vertices;
  }
  
  void setWorldTranslation(Point2D translation) {
    rectangle.setLocation((int)translation.getX(), (int)translation.getY());
  }
  
  void drawOverlay(Point2D translate) {
    collisionOverlay.beginDraw();
    collisionOverlay.pushMatrix();
    collisionOverlay.translate((float)translate.getX(), (float)translate.getY());
    collisionOverlay.rect(0, 0, rectangle.width, rectangle.height);
    collisionOverlay.popMatrix();
    collisionOverlay.endDraw();
  }
}


class PolygonCollisionShape implements CollisionShape, Rotatable {
  private Polygon polygon;
  private Point2D[] vertices;
  Point2D.Double centrePoint;
  private Point2D worldTranslation;
  private boolean xFlipped = false;
  float angle = 0;
  
  PolygonCollisionShape(Point2D[] vertices) {
    this.vertices = vertices;
    // Set points of polygon
    constructPolygon(vertices);
    // Find the centre point
    Rectangle bounds = polygon.getBounds();
    centrePoint = new Point2D.Double((bounds.width - bounds.getX()) / 2, (bounds.height - bounds.getY()) / 2);
  }
  
  void constructPolygon(Point2D[] vertices) {
    polygon = new Polygon();
    for (Point2D vertex : vertices) {
      polygon.addPoint((int)vertex.getX(), (int)vertex.getY());
    }
  }
  
  Area getArea() {
    // Translate area of polygon to world coordinates
    Area polygonArea = new Area(polygon);
    if (worldTranslation != null) {
      AffineTransform at = new AffineTransform();
      at.translate(worldTranslation.getX(), worldTranslation.getY());
      polygonArea.transform(at);
    }
    return polygonArea;
  }
  
  Rectangle getBounds() {
    return polygon.getBounds();
  }
  
  boolean contains(Point2D point) {
    return polygon.contains(point);
  }
  
  boolean overlaps(Area area) {
    area.intersect(getArea());
    return !area.isEmpty();
  }
  
  Point2D[] getVertices() {
    return vertices;
  }
  
  void setRotation(float radians) {
    float rotationDifference = radians - angle;
    angle = radians;
    
    // Change position of all points in the polygon due to the rotation
    for (Point2D vertex : vertices) {
      // Translate to origin
      double x1 = vertex.getX() - centrePoint.getX();
      double y1 = vertex.getY() - centrePoint.getY();
      // Rotate
      double temp_x1 = x1 * Math.cos(rotationDifference) - y1 * Math.sin(rotationDifference);
      double temp_y1 = x1 * Math.sin(rotationDifference) + y1 * Math.cos(rotationDifference);
      // Translate back
      vertex.setLocation(temp_x1 + centrePoint.getX(), temp_y1 + centrePoint.getY());
    }
  }
  
  void setXFlipped(boolean bool) {
    // Call flipX() when the current flipped state changes
    if (xFlipped != bool) {
      flipX();
    }
    xFlipped = bool;
  }
  
  void setWorldTranslation(Point2D translation) {
    worldTranslation = translation;
  }
  
  private void flipX() {
    for (Point2D vertex : vertices) {
      vertex.setLocation(-vertex.getX(), vertex.getY());
    }
  }
  
  // Draws an overlay of the polygon at a given position. Used for testing.
  void drawOverlay(Point2D translate) {
    collisionOverlay.beginDraw();
    collisionOverlay.beginShape();
    // Translate polygon by it's width if flipped on x axis
    if (xFlipped) {
      translate.setLocation(translate.getX() + getBounds().width, translate.getY());
    }
    for (Point2D vertex : vertices) {
      collisionOverlay.vertex((float)(vertex.getX() + translate.getX()), (float)(vertex.getY() + translate.getY()));
    }
    collisionOverlay.endShape(CLOSE);
    collisionOverlay.endDraw();
  }
}
