import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

public class WebcamEncoder {

  // method for encoding webcam capture data into a byte array
  byte[] encode(PImage img) throws IOException {
    ByteArrayOutputStream imgBAOS = new ByteArrayOutputStream();
    ImageIO.write((BufferedImage) img.getNative(), "jpg", imgBAOS);

    return imgBAOS.toByteArray();
  }

  // method for decoding webcam capture data into an image to be displayed
  PImage decode(byte[] imgbytes) throws IOException {
    BufferedImage imgBuffer = ImageIO.read(new ByteArrayInputStream(imgbytes));
    PImage img = new PImage(imgBuffer.getWidth(), imgBuffer.getHeight(), RGB);
    imgBuffer.getRGB(0, 0, img.width, img.height, img.pixels, 0, img.width);
    img.updatePixels();

    return img; 
  }

} 
