/*  //<>//
 * Class made for creating, saving and handling radials
 * Creator: Michael Jamieson
 * Date: July 7, 2020
 */

public final int timeToClick = 100;

// file type declarations
public final int WAV = 0;
public final int MP3 = 1;

// color declarations for displaying Radial
public final int NO_COLOR = 0;
public final int COLOR = 1;
public final int DEUTERANOMLAY = 2;
public final int PROTANOMLAY = 3;
public final int PROTANOPIA = 4;
public final int TRITANOMALY = 5;
public final int TRITANOPIA = 6;

class Radial {

  // constant value of the number of points to reduce a sound file to
  final int maxArraySize = 720;

  PApplet app;
  FilePlayer sound;
  TickRate rateControl;
  String name, fileName, filePath;
  int orgPosX, orgPosY, curPosX, curPosY, fileType, soundLength, BPM;
  float curRC;
  float[] sampleArray;
  int[] frequencyArray;

  boolean bOverHandle = false;
  boolean bPressHandle = false;
  boolean bActiveHandle = false;
  boolean bFirstTimeValue = false;
  float lastHandlePressTime = 0;
  int handleRadius = maxRadialRadius;

  /* Contructor for a Radial object
   * 
   * @param app_:       PApplet (or window) the Radial exists on
   * @param name_:      name of radial file to eb displayed
   * @param fileName_:  file name of sound file
   * @param fileType_:  file type of sound file
   * @param curPosX_:      x position of center of radial
   * @param curPosY_:      y position of center of radial
   */
  Radial(PApplet app_, String name_, String fileName_, int fileType_, String filePath_, int curPosX_, int curPosY_) {
    app = app_;
    name = name_;
    fileName = fileName_;
    fileType = fileType_;
    curPosX = orgPosX = curPosX_;
    curPosY = orgPosY = curPosY_;
    filePath = filePath_;

    sampleArray = new float[maxArraySize];
    frequencyArray = new int[maxArraySize];
    rateControl = new TickRate(1f);

    // check for data array files
    if (!checkForDataFile()) {
      createDataFile(createSampleArray(), createFrequencyArray());
    } else {   
      loadDataFromFile();
    }

    if (BPM != 0) {
      curRC = (120f / BPM);
      rateControl.value.setLastValue(curRC);
      if (curRC < 1)  rateControl.setInterpolation(true); 
      else            rateControl.setInterpolation(false);
    } else {
      curRC = 1f;
      rateControl.value.setLastValue(1f);
    }

    // load the correct file type into the player
    if (fileType == MP3) { 
      try {
        sound = new FilePlayer(radialsMinim.loadFileStream(filePath + fileName + ".mp3"));
        sound.patch(rateControl).patch(audioOut);
      } 
      catch (Exception e) {
        println("Exception: " + e + " when attempting to load " + fileName + ".mp3");
      }
    } else {
      try {
        sound = new FilePlayer(radialsMinim.loadFileStream(filePath + fileName + ".wav"));
        sound.patch(rateControl).patch(audioOut);
      } 
      catch (Exception e) {
        println("Exception: " + e + " when attempting to load " + fileName + ".wav");
      }
    }

    // AudioSample.length() does not equal AudioSample.position() at the end of the sound,
    // so we work around it
    sound.cue(sound.length());
    soundLength = sound.position();
  }

  /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   *
   *  METHODS FOR RADIAL FILES
   *
   * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   */

  /* method for checking whether an array data file exists
   *
   * @param fileSuffix:  suffix of the file being written to
   */
  boolean checkForDataFile() {
    File f = new File(sketchPath() + "/data/soundData/" + fileName + ".csv");
    if (f.exists()) {
      println(fileName + ".csv found");
      return true;
    } else {
      println(fileName+ ".csv not found");
      return false;
    }
  }

  /* method for creating a file containing float values of the radial
   *
   * @param array[]:   float array to be written to the file
   * @param fileSuffix:  suffix of the file being written to
   */
  void createDataFile(float[] arrayS, int[] arrayF) {
    println("Creating data file at:\t" + sketchPath() + "\\data\\soundData\\" + fileName + ".csv");
    Table dataTable = new Table();
    TableRow newRow;

    dataTable.addColumn("samples");
    dataTable.addColumn("frequencies");
    dataTable.addColumn("BPM");

    for (int i = 0; i < maxArraySize; i++) {
      newRow = dataTable.addRow();
      newRow.setFloat("samples", arrayS[i]);
      newRow.setInt("frequencies", arrayF[i]);
      sampleArray[i] = arrayS[i];
      frequencyArray[i] = arrayF[i];
    }

    saveTable(dataTable, "data/soundData/" + fileName + ".csv");
  }

  /* method for creating a float array from a txt file data
   *
   * @param fileSuffix:  suffix of the file being written to
   */
  void loadDataFromFile() {
    println("loading data from file at:\t" + sketchPath() + "\\data\\soundData\\" + fileName + ".csv");

    // load csv to table
    Table dataTable = loadTable("soundData/" + fileName + ".csv", "header");
    TableRow row;

    // read the data from the specified file and set to Radial arrays
    for (int i = 0; i < maxArraySize; i++) {
      row = dataTable.getRow(i);
      sampleArray[i] = row.getFloat("samples");
      frequencyArray[i] = row.getInt("frequencies");
      if (i == 0) BPM = row.getInt("BPM");
    }
  }

  // method for reducing the samples in an mp3 or wav file to 720 values
  float[] createSampleArray() {
    float[] reducedSamples = new float[maxArraySize];

    // load in the audio file as a sample
    AudioSample tempSample;
    if (fileType == MP3) {     
      tempSample = radialsMinim.loadSample(filePath + fileName + ".mp3");
    } else {
      tempSample = radialsMinim.loadSample(filePath + fileName + ".wav");
    }

    // If the file only has a mono track, then you only need one array of values
    // If the file has stereo audio, take both channels and average the values from both
    float[] leftSamples = tempSample.getChannel(AudioSample.LEFT);
    float[] summedSamples = new float[leftSamples.length];
    if (tempSample.type() == 1) {
      for (int i = 0; i < leftSamples.length; i++) {
        summedSamples[i] = leftSamples[i];
      }
    } else {
      float[] rightSamples = tempSample.getChannel(AudioSample.RIGHT);
      for (int i = 0; i < leftSamples.length; i++) {
        summedSamples[i] = leftSamples[i] + rightSamples[i];
      }
    }

    // Reduce the summedSamples to arraySize by taking the average of the samples over the reducing factor
    float totalSamples = leftSamples.length;
    float reducingFactor = totalSamples / float(maxArraySize);
    float average = 0;
    int curArraySpot = 0;

    for (int i = 0; i < summedSamples.length; i++) {
      average += summedSamples[i];
      if ( i % int(reducingFactor) == 0 && i!=0) {  //Must cast reducing factor to int to make math work
        reducedSamples[curArraySpot] = average / reducingFactor;
        curArraySpot++;
        average = 0;
        if (curArraySpot == maxArraySize - 1) break;
      }
    }
    tempSample.close();
    return reducedSamples;
  }

  // method for reducing the samples in an mp3 or wav file to 720 values
  int[] createFrequencyArray () {
    int[] frequencyArray = new int[maxArraySize];
    int maxBand = 0;

    // load in the audio file as a sample
    AudioSample tempSample;
    if (fileType == MP3) {     
      tempSample = radialsMinim.loadSample(filePath + fileName + ".mp3");
    } else {
      tempSample = radialsMinim.loadSample(filePath + fileName + ".wav");
    }

    // If the file only has a mono track, then you only need one array of values
    // If the file has stereo audio, take both channels and average the values from both
    float[] leftSamples = tempSample.getChannel(AudioSample.LEFT);
    float[] summedSamples = new float[leftSamples.length];
    if (tempSample.type() == 1) {
      for (int i = 0; i < leftSamples.length; i++) {
        summedSamples[i] = leftSamples[i];
      }
    } else {
      float[] rightSamples = tempSample.getChannel(AudioSample.RIGHT);
      for (int i = 0; i < leftSamples.length; i++) {
        summedSamples[i] = leftSamples[i] + rightSamples[i];
      }
    }

    // choose the number of samples to analyze per chunk
    // !!MUST BE A POWER OF 2!!
    int fftSize = 1024;
    float[] fftSamples = new float[fftSize];

    // the number of analysis' that will be done
    int totalChunks = (summedSamples.length / fftSize) + 1;
    int[] fftValues = new int[totalChunks];

    FFT fft = new FFT(fftSize, tempSample.sampleRate());

    for (int i = 0; i < totalChunks; i++) {
      int curChunkIndex = i * fftSize;

      // if we are at the end of the samples we might not have enough 
      // sample values to fill an analysis array
      int chunkSize = min((summedSamples.length - curChunkIndex), fftSize);

      // copy chunk into our analysis array
      // copy fftSize samples from summedSamples from curChunkIndex to fftSamples starting at position 0 
      System.arraycopy( summedSamples, curChunkIndex, fftSamples, 0, chunkSize);

      // if the chunk was smaller than the fftSize, we need to pad the analysis buffer with zeroes        
      if ( chunkSize < fftSize ) {
        java.util.Arrays.fill( fftSamples, chunkSize, fftSamples.length - 1, 0.0 );
      }

      // analyze the array
      fft.forward(fftSamples);

      // find the max value of the fft
      for (int j = 0; j < (fftSize / 2); j++) {
        if (fft.getBand(j) > fft.getBand(maxBand)) {
          maxBand = j;
        }
      }
      fftValues[i] = maxBand;
      maxBand = 0;
    }

    // find the ratio between the number of chunks analyzed and 720
    float scalingFactor = float(totalChunks) / float(maxArraySize);

    // fill the final array
    for (int i = 0; i < maxArraySize; i++) {
      frequencyArray[i] = fftValues[int(i * scalingFactor)];
    }
    tempSample.close();
    return frequencyArray;
  }

  /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   *
   *  METHODS FOR DRAWING AND 
   *  INTERACTING WITH RADIAL
   *
   * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   */

  /* method for creating a float array from a txt file data
   *
   * @param n:  number of points used to display the Radial
   * @param c:  color scheme used to display the Radial
   */
  void display(int n, int c) {
    // ensure no more display points than data points in the arrays 
    if (n > 720) {
      n = 720;
    }
    drawRadial(n, c);

    if (bOverHandle || bPressHandle) {   
      // used for drawing handle area aroudn the Radial
      app.noFill();
      app.stroke(0);
      app.circle(curPosX, curPosY, handleRadius*2);
    }

    if (sound.isPlaying()) {
      drawRadialPosition();
    }
  }

  /* method for updating Radial data
   * check for whether the handle has been hovered or clicked
   * update the x and y of the Radial while the handle is pressed
   */
  boolean update(boolean otherActiveHandle) {  
    // if there are no other active handles, run updates 
    if (!otherActiveHandle) {
      overHandleEvent();
      pressHandleEvent();
    }

    if (bPressHandle) {
      // dont't update the postition until we are sure they arent trying to play the Radial sound      
      if ((millis() - lastHandlePressTime) > timeToClick) {
        // update the center draw position to a position on the screen
        curPosX = keepOnScreen(app.mouseX, handleRadius, (windowWidth - handleRadius));
        curPosY = keepOnScreen(app.mouseY, handleRadius, (windowHeight - handleRadius));
      }
    }

    // if this handle became active, return true so other radials can be updated
    if (bActiveHandle) {
      return true;
    } else {
      return false;
    }
  }

  /* method for displaying a radial
   *
   * @param displayPoints:  number of data points used in drawing the radial
   * @param colorScheme:    colorscheme for frequency data
   */
  void drawRadial(int displayPoints, int colorScheme) {
    color c1, c2, cf;
    float r, x, y;
    float arrayMin = floor(min(sampleArray));
    float arrayMax = ceil(max(sampleArray));
    app.noFill();
    app.strokeWeight(2);
    app.beginShape(); 

    // used for making pulling the values from the arrays evenly if
    // less display points are used than the size of the arrays
    int ratio = maxArraySize / displayPoints;

    for (int pPos = 0; pPos < displayPoints; pPos++) {

      // get color values for stroke
      // currently broken
      if (colorScheme == NO_COLOR) {
        cf = color(0, 0, 0);
      } else if (colorScheme == COLOR) {
        float scalar = map(frequencyArray[pPos * ratio], 0, 400, 0, 100); 
        if (scalar >= 75) {
          c1 = color(255, 236, 0);  //#ffec00 yellow
          c2 = color(179, 0, 0);    //#b30000 red
          cf = lerpColor(c1, c2, ((scalar - 75.0) / 25.0));
        } else if (scalar >= 50) {
          c1 = color(40, 255, 0);  //#28ff00 green
          c2 = color(255, 236, 0); //#ffec00 yellow
          cf = lerpColor(c1, c2, ((scalar - 50.0) / 25.0));
        } else if (scalar >= 25) {
          c1 = color(5, 0, 255);   //#0500ff blue
          c2 = color(40, 255, 0);  //#28ff00 green
          cf = lerpColor(c1, c2, ((scalar - 75.0) / 100.0));
        } else {
          c1 = color(87, 0, 158);   //#57009e purple
          c2 = color(5, 0, 255);   //#0500ff blue
          cf = lerpColor(c1, c2, ((scalar - 75.0) / 100.0));
        }
      } else {
        cf = color(0, 0, 0);
      }

      //println("r:\t" + rc + "\tg:\t" + gc + "\tb:\t" + bc);
      app.stroke(cf);  

      // map the radius of the point between the max and min values of the file, 
      // and the max and min display range
      r = map(sampleArray[pPos * ratio], arrayMin, arrayMax, minRadialRadius, maxRadialRadius);
      x = curPosX + (r * cos(radians(((360.0 / displayPoints) * pPos) - 90.0)));
      y = curPosY + (r * sin(radians(((360.0 / displayPoints) * pPos) - 90.0)));

      // if this is the first point, add an extra vertex handle
      if (pPos == 0) {
        app.curveVertex(x, y);
      }
      // if we are at the end, make the final point the same as the first point
      if (pPos == (displayPoints - 1)) {
        r = map(sampleArray[0], arrayMin, arrayMax, minRadialRadius, maxRadialRadius);
        x = curPosX + (r * cos(radians(-90)));
        y = curPosY + (r * sin(radians(-90)));
        app.curveVertex(x, y);
      }
      app.curveVertex(x, y);
    }
    app.endShape();

    // center Radial name at bottom of Radial
    app.fill(0);
    app.textSize(12);
    app.textAlign(CENTER, TOP);
    app.text(fileName, curPosX, curPosY + maxRadialRadius);
  }

  // method for drawing the position of the player on the Radial
  void drawRadialPosition() { 
    float pos = map(sound.position(), 0, soundLength, 0, maxArraySize);
    float x2 = curPosX + (handleRadius * cos(radians(((360.0 / maxArraySize) * pos) - 90)));
    float y2 = curPosY + (handleRadius * sin(radians(((360.0 / maxArraySize) * pos) - 90)));
    app.stroke(0, 200, 0);
    app.strokeWeight(1);
    app.line(curPosX, curPosY, x2, y2);
  }

  // event method for handling if the mouse is over the handle
  void overHandleEvent() {
    if (overHandle()) {
      bOverHandle = true;
    } else {
      bOverHandle = false;
    }
  }

  // event method for handling if the handle is pressed
  void pressHandleEvent() {
    if (bOverHandle && app.mousePressed || bActiveHandle) {
      bPressHandle = true;
      bActiveHandle = true;
      if (!bFirstTimeValue) {   
        lastHandlePressTime = millis();
        bFirstTimeValue = true;
      }
    } else {
      bPressHandle = false;
    }
  }

  // method for handling if the handle has been released
  void releaseHandleEvent() {
    // if the Radial was clicked instead of held play the sound
    if ((millis() - lastHandlePressTime) < timeToClick) {
      if (sound.isPlaying()) {
        pause();
      } else {
        play();
      }
    } else {
      // check if this radial was the active one
      if (bActiveHandle) {
        // check if the Radial has been released in the track window
        if (track1.overTrack(curPosX, curPosY)) {
          println("new Radial being added: " + fileName);
          track1.addTrackRadial(this);
        }
        curPosX = orgPosX;
        curPosY = orgPosY;
      }
    }
    bActiveHandle = false;
    bFirstTimeValue = false;
  }

  // method for checking if mouse position is over the handle
  boolean overHandle() {
    if (sqrt(sq(app.mouseX - curPosX) + sq(app.mouseY - curPosY)) <= handleRadius) {
      return true;
    } else {
      return false;
    }
  }

  // method for keeping the handle on screen as its being dragged
  int keepOnScreen(int mousePos, int minPos, int maxPos) { 
    return  min(max(mousePos, minPos), maxPos);
  }


  /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   *
   *  METHODS FOR PLAYING RADIAL SOUND
   *
   * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   */

  void play() {
    //play from time 0
    sound.play(0);
  }

  void pause() {
    sound.pause();
  }

  void updateRadialTickRate(int bpm) {
    if (BPM != 0) {
      curRC = (float(bpm) / BPM);
      rateControl.value.setLastValue(curRC);
      if (curRC < 1) rateControl.setInterpolation(true);
      else rateControl.setInterpolation(false);
    }
  }
} 
