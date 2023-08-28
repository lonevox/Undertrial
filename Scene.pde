// A scene is something like the game scene or the main menu
class Scene {
  private Consumer draw;
  private ArrayList<GUIElement> GUIElements = new ArrayList<GUIElement>();
  
  // onSwitchedTo is called when this scene is switched to, and draw is called when drawing
  Scene(Consumer<PGraphics> draw) {
    this.draw = draw;
  }
  
  ArrayList<GUIElement> getGUIElements() {
    return GUIElements;
  }
  
  void addGUIElement(GUIElement element) {
    GUIElements.add(element);
  }
  
  void draw(PGraphics src) {
    src.beginDraw();
    draw.accept(src);
    // Draw GUI elements
    for (GUIElement element : GUIElements) {
      element.draw(src);
    }
    src.endDraw();
  }
}
