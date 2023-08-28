import java.util.function.Consumer;

class GUIElement {
  protected Rectangle rect;
  void draw(PGraphics src) {}  // Override this to draw the element
}

interface Clickable {
  void clicked();
  boolean contains(Point2D point);
}

class Button extends GUIElement implements Clickable {
  private String text;
  private PFont font;
  private color mainColor;
  private color hoverColor;
  private Consumer executeOnClick;
  
  Button(String text, PFont font, Rectangle rect, color mainColor, color hoverColor, Consumer executeOnClick) {
    this.text = text;
    this.font = font;
    this.rect = rect;
    this.mainColor = mainColor;
    this.hoverColor = hoverColor;
    this.executeOnClick = executeOnClick;
  }
  
  void clicked() {
    executeOnClick.accept(new Object());
  }
  
  boolean contains(Point2D point) {
    return rect.contains(point);
  }
  
  @Override void draw(PGraphics src) {
    color currentColor = mainColor;
    // Set color to hoverColor if the mouse is over the button
    if (rect.contains(new Point2D.Double(mouseX, mouseY))) currentColor = hoverColor;
    // Draw button
    src.beginDraw();
    src.fill(currentColor);
    src.rect(rect.x, rect.y, rect.width, rect.height);
    src.fill(255);
    src.textFont(font);
    src.textAlign(CENTER, CENTER);
    src.text(text, rect.x + rect.width/2, rect.y + rect.height/2);
    src.endDraw();
  }
}
