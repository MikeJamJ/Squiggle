/* 
 * Class made for creating, saving and handling Track Radials
 * Creator: Michael Jamieson
 * Date: July 7, 2020
 */

class TrackRadial {

  // constant value of the number of points to reduce a sound file to
  final int maxArraySize = 720;

  PApplet app;
  FilePlayer sound;
  TickRate rateControl;
  String name, fileName, filePath;
  int orgPosX, orgPosY, curPosX, curPosY, fileType, soundLength, BPM, beatPos;
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
   * @param others_:    array of other radials in a window to check from drag and drop activity
   */
  TrackRadial(PApplet app_, String name_, String fileName_, int fileType_, String filePath_, int curPosX_, int curPosY_, float[] samples, int[] frequencies, int bpm, float curRC_, int beat) {
    app = app_;
    name = name_;
    fileName = fileName_;
    fileType = fileType_;
    curPosX = orgPosX = curPosX_;
    curPosY = orgPosY = curPosY_;
    filePath = filePath_;
    BPM = bpm;
    curRC = curRC_;
    beatPos = beat;

    sampleArray = new float[maxArraySize];
    frequencyArray = new int[maxArraySize];

    // copy over array values
    for (int i = 0; i < maxArraySize; i++) {
      sampleArray[i] = samples[i];
      frequencyArray[i] = frequencies[i];
    }

    // apply rate control
    rateControl = new TickRate(curRC);
    if (curRC < 1)  rateControl.setInterpolation(true); 
    else            rateControl.setInterpolation(false);

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
      // center name at bottom of TrackRadial
      app.fill(0);
      app.textSize(12);
      app.textAlign(CENTER, TOP);
      app.text(fileName, curPosX, curPosY + maxRadialRadius);
    }

    if (sound.isPlaying()) {
      drawRadialPosition();
    }
  }

  /* method for updating Radial data
   * update x position if tarck slider has moved
   * check for whether the handle has been hovered or clicked
   * update the x and y of the Radial while the handle is pressed
   */
  boolean update(boolean otherActiveHandle) {   

    // update x positon if track x positons have been changed
    if (track1.timeStampXValues[beatPos - 1] != curPosX) {
      curPosX = track1.timeStampXValues[beatPos - 1];
    }

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

    // return whether this Radial became active
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
    // check if Radial is on the trackWindow
    if ((curPosX + maxRadialRadius) > trackWindowX && (curPosX - maxRadialRadius) < (trackWindowX + trackWindowW)) {
      boolean firstPointDrawn = false;
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

        if (x < trackWindowX || x > (trackWindowX + trackWindowW)) {
          // if we have already drawn a point and the current point is out of bounds, we know we will not be drawing another one
          if (firstPointDrawn && pPos <= (displayPoints / 2)) {
            break;
          }
        } else {
          // if this is the first point, add an extra vertex handle
          firstPointDrawn = true;
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
      }
      app.endShape();
    }
  }

  // method for drawing the position of the player on the Radial
  void drawRadialPosition() { 
    float pos = map(sound.position(), 0, soundLength, 0, maxArraySize);
    float x2 = curPosX + (handleRadius * cos(radians(((360.0 / maxArraySize) * pos) - 90)));
    float y2 = curPosY + (handleRadius * sin(radians(((360.0 / maxArraySize) * pos) - 90)));
    if (x2 >= trackWindowX && x2 <= (trackWindowX + trackWindowW)) {
      app.stroke(0, 200, 0);
      app.strokeWeight(1);
      app.line(curPosX, curPosY, x2, y2);
    }
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
      if (app.mouseButton == LEFT) {
        bPressHandle = true;
        bActiveHandle = true;
        if (!bFirstTimeValue) {   
          lastHandlePressTime = millis();
          bFirstTimeValue = true;
        }
      } else if (app.mouseButton == RIGHT) {
        track1.removeTrackRadial(this);
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
          // update beat position
          beatPos = track1.findClosestBeat(curPosX);
          curPosX = track1.timeStampXValues[beatPos - 1];
          orgPosX = curPosX;
          orgPosY = curPosY;
        } else {
          curPosX = orgPosX;
          curPosY = orgPosY;
        }
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
