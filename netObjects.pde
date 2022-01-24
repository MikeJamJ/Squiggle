import processing.net.*;

public class squiggleClient {
  
  WebcamEncoder jpg;
  PApplet app;
  Client client;
  Capture cam;
  PImage img;
  
  squiggleClient(PApplet app_, Capture cam_, String portPassword){
    jpg = new WebcamEncoder();
    
    app = app_;
    cam = cam_;
    client = new Client(app, "127.0.0.1", Integer.parseInt(portPassword));
    
    img = createImage(100, 100, RGB);
  }
  
  void readCameraInfo(){
    if (cam.available()) {
      println("Cam available. Going to read");
      cam.read();
      try {
          println("Getting image to memory");
          PImage img = cam.get();
          img.resize(500, 0);
 
          println("Encoding");
          byte[] encoded = jpg.encode(img);
 
          println("Writing to server");
          client.write(encoded);
      } catch (IOException e) {
          // Ignore failure to encode
          println("IOException");
      }
    }
  }
  
  void checkForIncomingWebcamImage() {
    if (client.available() > 0) {
 
        byte[] byteBuffer = client.readBytes();
 
        if (byteBuffer.length > 0) {
            println("Received data. Trying to decode.");
            try {
                img = jpg.decode(byteBuffer);
            } catch (IOException e) {
                println("IOException");
            } catch (NullPointerException e) {
                println("Probs incomplete image");
            } catch (ArrayIndexOutOfBoundsException e) {
                println("Probs also incomplete image (Out of Bounds)");
            }
        } else {
            println("Byte amount not above 0");
          }
      }
  }
  
}

public class squiggleServer{
  
  WebcamEncoder jpg;
  PImage img;
  PApplet app;
  int numClients;
  Server server;
  Capture cam;
  
  squiggleServer(PApplet app_, Capture cam_, String portPassword){
    jpg = new WebcamEncoder();
    
    numClients += 1;
    app = app_;
    cam = cam_;
    server = new Server(app, Integer.parseInt(portPassword));
    
    img = createImage(100, 100, RGB);
  }

  void readCameraInfo(){
    if (cam.available()) {
      println("Cam available. Going to read");
      cam.read();
      try {
          println("Getting image to memory");
          PImage img = cam.get();
          img.resize(500, 0);
 
          println("Encoding");
          byte[] encoded = jpg.encode(img);
 
          println("Writing to server");
          server.write(encoded);
      } catch (IOException e) {
          // Ignore failure to encode
          println("IOException");
      }
 
 
    }
  }
  
  void checkForIncomingWebcamImage() {
    Client nextClient = server.available();
    if (nextClient != null) {
 
        byte[] byteBuffer = nextClient.readBytes();
 
        if (byteBuffer.length > 0) {
            println("Received data. Trying to decode.");
            try {
                img = jpg.decode(byteBuffer);
            } catch (IOException e) {
                println("IOException");
            } catch (NullPointerException e) {
                println("Probs incomplete image");
            } catch (ArrayIndexOutOfBoundsException e) {
                println("Probs also incomplete image (Out of Bounds)");
            }
        } else {
            println("Byte amount not above 0");
          }
      }
  }
  
  void serverEvent(Server someServer, Client someClient) {
    numClients += 1;
  }
  
}
