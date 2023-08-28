static final class PhysicsObjectHandler {
  static private ArrayList<PhysicsObject> physicsObjects = new ArrayList<PhysicsObject>();
  
  private PhysicsObjectHandler() {}
  
  static void addPhysicsObject(PhysicsObject physicsObject) {
    physicsObjects.add(physicsObject);
  }
  
  static void removePhysicsObject(PhysicsObject physicsObject) {
    physicsObjects.remove(physicsObject);
  }
  
  static ArrayList<PhysicsObject> getAllPhysicsObjects() {
    return physicsObjects;
  }
  
  // Returns an PhysicsObject at a given point. If there is no PhysicsObject at the point, it returns null.
  static PhysicsObject getObjectAtPosition(Point2D point) {
    ArrayList<PhysicsObject> physicsObjectsCopy = new ArrayList<PhysicsObject>(physicsObjects);    // Copy physics object list to fix ConcurrentModificationException
    for (PhysicsObject physicsObject : physicsObjectsCopy) {
      if (physicsObject.getCollisionShape() == null) continue;
      if (physicsObject.getCollisionShape().contains(point)) {
        return physicsObject;
      }
    }
    return null;
  }
  
  // Returns all PhysicsObjects that overlap with the given PhysicsObject
  static ArrayList<PhysicsObject> getCollidingObjects(PhysicsObject physicsObject) {
    ArrayList<PhysicsObject> collidingObjects = new ArrayList<PhysicsObject>();
    ArrayList<PhysicsObject> physicsObjectsCopy = new ArrayList<PhysicsObject>(physicsObjects);    // Copy physics object list to fix ConcurrentModificationException
    for (PhysicsObject object : physicsObjectsCopy) {
      if (physicsObject.getCollisionShape() == null) continue;
      if (object.getCollisionShape() == null) continue;
      CollisionShape objectCollisionShape = object.getCollisionShape();
      if (objectCollisionShape.overlaps(physicsObject.getCollisionShape().getArea())) {
        collidingObjects.add(object);
      }
    }
    return collidingObjects;
  }
}


abstract class PhysicsObject {
  
  protected CollisionShape collisionShape;
  protected boolean ignoreCollisions = false;
  protected PVector position = new PVector();
  protected PVector velocity = new PVector(0,0);
  protected double speedMultiplier = 1;
  protected float rotation = 0;
  
  PhysicsObject() {
    PhysicsObjectHandler.addPhysicsObject(this);
  }
  PhysicsObject(CollisionShape collisionShape) {
    this.collisionShape = collisionShape;
    PhysicsObjectHandler.addPhysicsObject(this);
  }
  
  // Called to recalculate position
  // Override this
  void update() {
    collisionShape.setWorldTranslation(new Point2D.Double(position.x, position.y));
  }
  
  // Moves the object by its current velocity
  void moveByVelocity() {
    Point2D.Double targetTranslation = new Point2D.Double(position.x + velocity.x * speedMultiplier, position.y + velocity.y * speedMultiplier);
    // Move along X axis
    if (canMoveX(targetTranslation)) {
      position.x += velocity.x * speedMultiplier;
    } else {
      // Move as far on the X axis as possible
      if (velocity.x > 0) {
        while(canMoveX(new Point2D.Double(position.x + 0.1, position.y))) {
          position.x += 0.1;
        }
      } else {
        while(canMoveX(new Point2D.Double(position.x - 0.1, position.y))) {
          position.x -= 0.1;
        }
      }
    }
    // Move along Y axis
    if (canMoveY(targetTranslation)) {
      position.y += velocity.y * speedMultiplier;
    } else {
      // Move as far on the X axis as possible
      if (velocity.y > 0) {
        while(canMoveY(new Point2D.Double(position.x, position.y + 0.1))) {
          position.y += 0.1;
        }
      } else {
        while(canMoveY(new Point2D.Double(position.x, position.y - 0.1))) {
          position.y -= 0.1;
        }
      }
    }
  }
  
  // Returns the position of the object as a PVector
  PVector getPosition() {
    return position;
  }
  
  // Returns the velocity of the object as a PVector
  PVector getVelocity() {
    return velocity;
  }
  
  CollisionShape getCollisionShape() {
    return collisionShape;
  }
  
  void removeFromWorld() {
    PhysicsObjectHandler.removePhysicsObject(this);
  }
  
  // Sets the position of the object as a PVector
  void setPosition(PVector position) {
    this.position = position;
  }
  
  // Sets the velocity of the object as a PVector
  void setVelocity(PVector velocity) {
    this.velocity = velocity;
  }
  
  void setRotation(float radians) {
    rotation = radians;
    if (collisionShape instanceof Rotatable) ((Rotatable)collisionShape).setRotation(radians);
  }
  
  // Returns true if there isn't an object at the given point
  boolean canMove(Point2D targetTranslation) {
    if (ignoreCollisions) return true;
    for (Point2D vertex : collisionShape.getVertices()) {
      PhysicsObject physicsObject = PhysicsObjectHandler.getObjectAtPosition(new Point2D.Double(vertex.getX() + targetTranslation.getX(), vertex.getY() + targetTranslation.getY()));
      if (physicsObject != this && physicsObject != null) {
        return false;
      }
    }
    return true;
  }
  
  // Returns true if there isn't an object at the given point on the X axis
  boolean canMoveX(Point2D targetTranslation) {
    if (ignoreCollisions) return true;
    for (Point2D vertex : collisionShape.getVertices()) {
      PhysicsObject physicsObject = PhysicsObjectHandler.getObjectAtPosition(new Point2D.Double(vertex.getX() + targetTranslation.getX(), vertex.getY() + position.y));
      if (physicsObject != this && physicsObject != null) {
        return false;
      }
    }
    return true;
  }
  
  // Returns true if there isn't an object at the given point on the Y axis
  boolean canMoveY(Point2D targetTranslation) {
    if (ignoreCollisions) return true;
    for (Point2D vertex : collisionShape.getVertices()) {
      PhysicsObject physicsObject = PhysicsObjectHandler.getObjectAtPosition(new Point2D.Double(vertex.getX() + position.x, vertex.getY() + targetTranslation.getY()));
      if (physicsObject != this && physicsObject != null) {
        return false;
      }
    }
    return true;
  }
  
  ArrayList<PhysicsObject> getAllCollisions() {
    return PhysicsObjectHandler.getCollidingObjects(this);
  }
}
