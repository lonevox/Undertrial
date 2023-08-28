import java.io.*;
import java.lang.*;

// Class for loading a sequence of images that can be played as an animation

class Animation {
  private PImage[] images;                                                                       // Array containing all images in the animation.
  private int imageCount;                                                                        // The number of images in the animation.
  private ArrayList<AnimationInstance> animationInstances = new ArrayList<AnimationInstance>();  // Contains instances of this animation. Not to be confused with an instance of the Animation class.
  
  // Images should be named like 0000.png... 0012.png
  // There should not be any other files in the pathToImages folder.
  // The image files can be of different types but must all be the
  // same size.
  // Scale can be nagative 
  Animation(String pathToImages, int scale) {
    // Get the number of images in the pathToImages folder
    // and make the same number of PImages.
    File file = new File(dataPath(pathToImages));
    String[] imagePaths = file.list();
    imageCount = imagePaths.length;
    images = new PImage[imageCount];
    
    // Load all the images in the animation
    for (int i = 0; i < imageCount; i++) {
      String fileExtension = imagePaths[0].substring(imagePaths[0].lastIndexOf("."));
      String filename = pathToImages + "/" + nf(i+1,4) + fileExtension;
      images[i] = loadImage(filename);
      // Scale the image
      if (scale != 1) {
        images[i] = nearestNeighbourScale(images[i], scale);
      }
    }
  }
  Animation(String pathToImages) {
    this(pathToImages, 1);
  }
  
  AnimationInstance createAnimationInstance() {
    AnimationInstance animationInstance = new AnimationInstance(this);
    animationInstances.add(animationInstance);
    return animationInstance;
  }
  
  void destroyAnimationInstance(AnimationInstance animationInstance) {
    animationInstances.remove(animationInstance);
  }
  
  AnimationInstance getAnimationInstance(int index) {
    return animationInstances.get(index);
  }
  
  ArrayList<AnimationInstance> getAllAnimationInstances() {
    return animationInstances;
  }
  
  PImage getImage(int index) {
    return images[index];
  }
  
  int getImageCount() {
    return imageCount;
  }
  
  int getWidth() {
    return images[0].width;
  }
  
  int getHeight() {
    return images[0].height;
  }
}

class AnimationInstance {
  Animation animation;
  private int frame;                 // The index of the currently displayed frame in the animation.
  private boolean hasStarted = false;// True if the animation has started.
  private boolean playing = false;   // True if the animation is playing.
  private int loops;                 // The number of times the animation will loop for.
  private int loop = 0;              // The current loop that the animation is on.
  private boolean visible = false;   // Whether or not the image is visible.
  private boolean paused = false;    // Whether or not the animation is paused.
  private int totalTimePaused;       // Total time paused since the start of the animation.
  private int timeWhenPaused;        // The time in milliseconds since the animation was last paused.
  private int timeAtLastFrame;       // The time in milliseconds when the last frame was displayed.
  private int timeSinceLastFrame;    // The time in milliseconds since the last frame in the animation.
  
  AnimationInstance(Animation animation) {
    this.animation = animation;
  }
  
  void draw(PGraphics dest, float xpos, float ypos, int framesPerSecond) {
    // Detects if the animation has moved onto a new frame if enough time has passed
    // Also recalculates timeSinceLastFrame and timeAtLastFrame
    boolean isNewFrame = false;
    if (playing) {
      timeSinceLastFrame = millis()-totalTimePaused-(timeAtLastFrame-totalTimePaused);
      int frameTimeLength = (int)(1.0/framesPerSecond*1000);
      if (timeSinceLastFrame > frameTimeLength) {
        isNewFrame = true;
        timeAtLastFrame = millis() + (frameTimeLength - timeSinceLastFrame);
        timeSinceLastFrame = 0;
      }
    }
    
    // Stop playing if at the end of a looped animation
    int imageCount = animation.getImageCount();
    if (!paused && isNewFrame && frame % imageCount == imageCount-1) {
      loop++;
      if (loop == loops) stop();
    }
    
    // Increment frame
    if (isNewFrame) frame = (frame+1) % imageCount;
    
    // Draw frame if currently visible
    if (visible) {
      dest.beginDraw();
      dest.image(animation.getImage(frame), xpos, ypos);
      dest.endDraw();
    }
  }
  
  // Make the animation play forever (until stop() is called)
  void play() {
    hasStarted = true;
    playing = true;
    visible = true;
    timeAtLastFrame = millis();
  }
  
  // Make the animation play a given number of times
  void playNumberOfTimes(int numberOfLoops) {
    playing = true;
    loops = numberOfLoops;
  }
  
  // Stops the animation and destroys it
  void stop() {
    animation.destroyAnimationInstance(this);
  }
  
  // Pauses the animation. Can be resumed with unpause().
  void pause() {
    if (hasStarted) {
      paused = true;
      playing = false;
      timeWhenPaused = millis();
    }
  }
  
  // Unpauses the animation
  void unpause() {
    if (hasStarted) {
      paused = false;
      totalTimePaused += timeWhenPaused - millis();
      play();
    }
  }
  
  void setFrame(int frame) {
    this.frame = frame;
  }
  
  boolean isPlaying() {
    return playing;
  }
  
  boolean hasStarted() {
    return hasStarted;
  }
}
