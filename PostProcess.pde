import java.util.Arrays;
import java.lang.Exception;
import java.util.function.Supplier;

////////// POST-PROCESSING PIPELINE CLASS //////////

class PostProcessPipeline {
  private ArrayList<PostProcessingStep> steps = new ArrayList<PostProcessingStep>();
  PGraphics currentPass;
  PVector initialGraphicsSize;
  PVector currentGraphicsSize;    // The current size of the graphics. Changes during post-processing.
  PVector nextGraphicsSize;       // The next size of the graphics. Changes during post-processing.
  ShaderStep lastShaderStep;      // Used for drawing to the screen after post-processing.
  
  PostProcessPipeline(int initialOutputWidth, int initialOutputHeight) {
    initialGraphicsSize = new PVector(initialOutputWidth, initialOutputHeight);
    currentGraphicsSize = new PVector(initialOutputWidth, initialOutputHeight);
    nextGraphicsSize = new PVector(initialOutputWidth, initialOutputHeight);
    currentPass = createGraphics(initialOutputWidth, initialOutputHeight, P2D);
    currentPass.beginDraw();
    currentPass.blendMode(REPLACE);
    currentPass.noSmooth();
    currentPass.endDraw();
  }
  
  PGraphics process(PGraphics src, int blendMode) {
    // Set current graphics to src
    currentPass = src;
    // Execute steps in pipeline
    for (PostProcessingStep step : steps) {
      step.execute();
    }
    // Draw resulting graphics to the input
    blendMode(blendMode);
    image(currentPass, 0, 0);
    blendMode(BLEND);
    return currentPass;
  }
  
  // , blendModeFinds the graphics size of a step by searching the steps before it
  PVector findTargetGraphicsSize(int index)  {
    // Throw out of bounds exception if index is out of bounds
    if (index >= steps.size()) throw new IndexOutOfBoundsException("Index " + index + " is out of bounds.");
    // Loop through steps list in reverse to find the latest GraphicsSizeStep
    for (int i = index; i >= 0; i--) {
      PostProcessingStep step = steps.get(i);
      if (step instanceof GraphicsSizeStep) return ((GraphicsSizeStep)step).getSize();
    }
    // If no GraphicsSizeSteps are found, return the default graphics size
    return initialGraphicsSize;
  }
  
  // Corrects any future shader steps by setting their graphics size to the size given by the GraphicsSizeStep
  void correctShaderStepGraphicsSizes(GraphicsSizeStep graphicsSizeStep) {
    boolean correctSteps = true;
    int index = steps.indexOf(graphicsSizeStep);
    while (correctSteps) {
      PostProcessingStep step = steps.get(index);
      if (step instanceof ShaderStep) ((ShaderStep)step).setGraphicsSize(graphicsSizeStep.getSize());
      index++;    // Increment loop
      if (index >= steps.size() || steps.get(index) instanceof GraphicsSizeStep) correctSteps = false;  // Exit loop if true
    }
  }
  
  // This is called when a GraphicsSizeStep is disabled
  void disableGraphicsSizeStep(GraphicsSizeStep graphicsSizeStep) {
    // Find previous graphics size
    int fromIndex = steps.indexOf(graphicsSizeStep);
    for (int i = fromIndex; i >= 0; i--) {
      PostProcessingStep step = steps.get(i);
      if (step instanceof GraphicsSizeStep) {
        correctShaderStepGraphicsSizes((GraphicsSizeStep)step);
      }
    }
  }
  
  void setShaderStep(PShader shader) {
    steps.add(new ShaderStep(this, shader, findTargetGraphicsSize(steps.size()-1)));
  }
  
  private Supplier constant(final Object value) {
    return new Supplier() {
      public Object get() {return value;}
    };
  }
  
  private void setUniformStepInternal(PShader shader, String name, Object value, boolean setOnce) {
    // If setOnce, set the uniform now instead of adding it to the steps list
    if (setOnce) {
      if (value instanceof Integer) {
        int valueInt = (int)value;
        shader.set(name, valueInt);
      } else if (value instanceof Float) {
        float valueFloat = (float)value;
        shader.set(name, valueFloat);
      } else if (value instanceof PImage) {
        PImage valuePImage = (PImage)value;
        shader.set(name, valuePImage);
      }
    } else {
      steps.add(new UniformStep(this, shader, new Uniform(name, constant(value))));
    }
  }
  void setUniformStep(PShader shader, String name, int value, boolean setOnce) {
    setUniformStepInternal(shader, name, value, setOnce);
  }
  void setUniformStep(PShader shader, String name, float value, boolean setOnce) {
    setUniformStepInternal(shader, name, value, setOnce);
  }
  void setUniformStep(PShader shader, String name, PImage value, boolean setOnce) {
    setUniformStepInternal(shader, name, value, setOnce);
  }
  <T> void setUniformStep(PShader shader, String name, Supplier<T> value, boolean setOnce) {
    T valueValue = value.get();
    if (valueValue instanceof Integer || valueValue instanceof Float || valueValue instanceof PImage) {
      setUniformStepInternal(shader, name, value, setOnce);
    }
  }
  
  void setOutputSizeStep(int w, int h) {
    steps.add(new GraphicsSizeStep(this, w, h));
  }
  
  void enableShader(PShader shader) {
    for (PostProcessingStep step : steps) { 
      if (step instanceof ShaderStep && ((ShaderStep)step).getShader() == shader) {
        step.enable();
      }
    }
  }
  void enableShader(PShader shader, int position) {
    PostProcessingStep step = steps.get(position);
    
  }
  
  void disableShader(PShader shader) {
    for (PostProcessingStep step : steps) { 
      if (step instanceof ShaderStep && ((ShaderStep)step).getShader() == shader) {
        step.disable();
      }
    }
  }
  
  PVector getCurrentGraphicsSize() {
    return currentGraphicsSize;
  }
  
  PVector getNextGraphicsSize() {
    return nextGraphicsSize;
  }
}


////////// POST-PROCESSING STEP CLASSES //////////

private abstract class PostProcessingStep {
  protected PostProcessPipeline postProcessPipeline;
  protected boolean enabled = true;
  
  void enable() {
    enabled = true;
  }
  
  void disable() {
    enabled = false;
  }
  
  void execute() {}    // Override this to make something happen when the step is executed
}

private class ShaderStep extends PostProcessingStep {
  private PShader shader;
  private PVector outputSize;
  PGraphics graphics;
  
  ShaderStep(PostProcessPipeline pipeline, PShader shader, PVector outputSize) {
    this.postProcessPipeline = pipeline;
    this.shader = shader;
    setGraphicsSize(outputSize);
    graphics.beginDraw();
    graphics.blendMode(REPLACE);
    graphics.endDraw();
  }
  
  PShader getShader() {
    return shader;
  }
  
  PGraphics getGraphics() {
    return graphics;
  }
  
  void setGraphics(PGraphics graphics) {
    this.graphics = graphics;
  }
  
  void setGraphicsSize(int w, int h) {
    graphics = createGraphics(w, h, P2D);
  }
  void setGraphicsSize(PVector size) {
    setGraphicsSize((int)size.x, (int)size.y);
  }
  
  void execute() {
    // Return early if shader step is disabled
    if (!enabled) return;
    // If the next graphics size is different, draw the image at that size
    if (postProcessPipeline.currentGraphicsSize == postProcessPipeline.nextGraphicsSize) {
      graphics.beginDraw();
      graphics.shader(shader);
      graphics.image(postProcessPipeline.currentPass, 0, 0);
      graphics.endDraw();
    } else {
      graphics.beginDraw();
      graphics.shader(shader);
      graphics.image(postProcessPipeline.currentPass, 0, 0, postProcessPipeline.nextGraphicsSize.x, postProcessPipeline.nextGraphicsSize.y);
      graphics.endDraw();
      postProcessPipeline.currentGraphicsSize = postProcessPipeline.nextGraphicsSize;
    }
    // Set current graphics to the output of this shader pass
    postProcessPipeline.currentPass = graphics;
  }
}

private class UniformStep extends PostProcessingStep {
  private Uniform uniform;
  private PShader shader;
  
  UniformStep(PostProcessPipeline pipeline, PShader shader, Uniform uniform) {
    this.postProcessPipeline = pipeline;
    this.uniform = uniform;
    this.shader = shader;
  }
  
  void execute() {
    // Return early if uniform step is disabled
    if (!enabled) return;
    // Set the shaders uniform
    Object value = ((Supplier)uniform.getValue()).get();
    if (value instanceof Integer) {
      int valueInt = (int)value;
      shader.set(uniform.getName(), valueInt);
    } else if (value instanceof Float) {
      float valueFloat = (float)value;
      shader.set(uniform.getName(), valueFloat);
    } else if (value instanceof PImage) {
      PImage valuePImage = (PImage)value;
      shader.set(uniform.getName(), valuePImage);
    }
  }
}

private class GraphicsSizeStep extends PostProcessingStep {
  private int w;
  private int h;
  
  GraphicsSizeStep(PostProcessPipeline pipeline, int w, int h) {
    this.postProcessPipeline = pipeline;
    this.w = w;
    this.h = h;
  }
  
  void execute() {
    postProcessPipeline.nextGraphicsSize = new PVector(w, h);
  }
  
  PVector getSize() {
    return new PVector(w, h);
  }
  
  int getWidth() {
    return w;
  }
  
  int getHeight() {
    return h;
  }
  
  void enable() {
    enabled = true;
    postProcessPipeline.correctShaderStepGraphicsSizes(this);
  }
  
  void disable() {
    enabled = false;
    postProcessPipeline.disableGraphicsSizeStep(this);
  }
}


////////// UNIFORM //////////

private class Uniform {
  private String name;
  private Supplier value;
  
  Uniform(String name, Supplier value) {
    this.name = name;
    this.value = value;
  }
  
  Object getValue() {
    return value.get();
  }
  
  String getName() {
    return name;
  }
}

private class InvalidUniformException extends Exception {
  InvalidUniformException(String str) {
    super(str);
  }
}
