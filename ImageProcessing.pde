// WARNING: Use other resize function for now, this one has a bug
PImage nearestNeighbourResize(PImage image, float scale) {
  int scaledWidth = (int)(scale*image.width);
  int scaledHeight = (int)(scale*image.height);
  PImage out = createImage(scaledWidth, scaledHeight, image.format);
  image.loadPixels();
  out.loadPixels();
  for (int i=0; i<scaledHeight; i++) {
    int y = Math.min(round(i / scale), image.height - 1) * image.width;
    for (int j=0; j<scaledWidth; j++) {
      int x = Math.min(round(j / scale), image.width - 1);
      out.pixels[(scaledWidth * i) + j] = image.pixels[(y + x)];
    }
  }
  out.updatePixels();
  return out;
}

// Used to resize images if scale is used when creating an Animation, and in other parts of code. Can only scale by whole numbers.
PImage nearestNeighbourScale(PImage image, int scale) {
  int scaledWidth = image.width * scale;
  int scaledHeight = image.height * scale;
  PImage out = createImage(scaledWidth, scaledHeight, image.format);
  int xRatio = (int)((image.width<<16)/scaledWidth) + 1;
  int yRatio = (int)((image.height<<16)/scaledHeight) + 1;
  int x2, y2;
  image.loadPixels();
  out.loadPixels();
  for (int i=0;i<scaledHeight;i++) {
    for (int j=0;j<scaledWidth;j++) {
      x2 = ((j*xRatio)>>16);
      y2 = ((i*yRatio)>>16);
      out.pixels[(i*scaledWidth)+j] = image.pixels[(y2*image.width)+x2];
    }
  }
  out.updatePixels();
  return out;
}
