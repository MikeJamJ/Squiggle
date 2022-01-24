/* 
 * Class made for creating, saving and handling tracks
 * Creator: Michael Jamieson
 * Date: July 14, 2020
 */

class Track {

  PApplet app;
  ArrayList<TrackRadial> trackRadials;  // list of radials in a track
  int posX, posY, w, h, trackLengthB, BPM, trackSpacing;
  float trackLengthMS;

  int startOfPlay = 0;
  float trackPos = 0;
  boolean bPlaying = false;
  int[] timeStampXValues;


  /* Contructor for a Track object
   * 
   * @param app_:  PApplet (or window) the Track exists on
   * @param x:     x position of top left of track
   * @param y:     y position of top left of track
   * @param w_:    width of track
   * @param h_:    height of track
   * @param bpm:   BPM of the track
   */
  Track(PApplet app_, int x, int y, int w_, int h_, int bpm) {
    app = app_;
    posX = x;
    posY = y;
    w = w_;
    h = h_;
    BPM = bpm;

    trackRadials = new ArrayList<TrackRadial>();
    trackLengthB = 120; // number of beats the track length is
    trackLengthMS = (trackLengthB * (1000f / (BPM / 60f)));
    trackSpacing = maxRadialRadius * 2;

    timeStampXValues = new int[trackLengthB];
    for (int i = 0; i < trackLengthB; i++) {
      timeStampXValues[i] = posX + (trackSpacing * (i + 1));
    }
  }

  /* method for adding a Radial to a track
   *
   * @param r:  Radial to be added
   */
  void addTrackRadial(Radial r) {
    int beat = findClosestBeat(r.curPosX);
    TrackRadial newTrackRadial = new TrackRadial(r.app, r.name, r.fileName, r.fileType, r.filePath, timeStampXValues[beat - 1], r.curPosY, r.sampleArray, r.frequencyArray, r.BPM, r.curRC, beat);
    trackRadials.add(newTrackRadial);
  }

  /* method for removing a Radial from a track
   *
   * @param r:  TrackRadial to be removed
   */
  void removeTrackRadial(TrackRadial r) {
    r.sound.close();
    trackRadials.remove(r);
  }

  /* method for finding closest beat based on x position of TrackRadial
   *
   * @param x:  x position of TrackRadial
   */
  int findClosestBeat(int x) {
    // check beginning and end cases
    if (x <= timeStampXValues[0]) {
      return 1;
    }
    if (x >= timeStampXValues[trackLengthB - 1]) {
      return trackLengthB;
    }

    // Do a binary search  
    int i = 0;
    int j = trackLengthB;
    int mid = 0; 
    while (i < j) { 
      // get middle value
      mid = (i + j) / 2; 

      if (timeStampXValues[mid] == x) 
        return timeStampXValues[mid]; 

      // If target is less than array element, then search in left
      if (x < timeStampXValues[mid]) { 

        // If target is greater than previous to mid, return closest of two 
        if (mid > 0 && x > timeStampXValues[mid - 1]) {
          if (x - timeStampXValues[mid - 1] >= timeStampXValues[mid] - x) {
            return mid + 1;
          } else { 
            return mid;
          }
        }

        // Repeat for left half
        j = mid;
      } 

      // If target is greater than mid 
      else { 
        if (mid < (trackLengthB - 1) && x < timeStampXValues[mid + 1]) {
          if (x - timeStampXValues[mid] >= timeStampXValues[mid + 1] - x) {
            return mid + 2;
          } else { 
            return mid + 1;
          }
        }
        i = mid + 1; // update i
      }
    } 

    // Only single element left after search 
    return mid + 1;
  }

  /* method for updating Track data
   * check for whether the track is playing
   * check if Radials within a track should be playing
   */
  boolean update(boolean otherActiveHandle) {
    // check if track is playing
    if (bPlaying) {
      //print("Start time: " + millis()); 
      // check if end of track has been reached
      if ((millis() - startOfPlay) >= trackLengthMS) {
        bPlaying = false;
        println("stopped playing");
      } else {
        // check if any Radial should be playing
        for (int i = trackRadials.size() - 1; i >= 0; i--) {
          if (trackPos == trackRadials.get(i).curPosX) {
            // only play if the sound is not already playing
            if (!trackRadials.get(i).sound.isPlaying()) {
              trackRadials.get(i).play();
            }
          }
        }
      }
      //println("End time: " + millis());
    }
    
    // update all the Radials in the track
    boolean temp = otherActiveHandle;
    try {
      for (int i = trackRadials.size() - 1; i >= 0; i--) {
        // if it was found a handle was active, just update without checking the return 
        if (temp) {
          trackRadials.get(i).update(temp);
        }
        else if (trackRadials.get(i).update(temp)) {
          temp = true;
        }
      }
    } 
    catch (Exception e) {
      println("Exception: " + e + " when trying to display track radials");
    }
    
    return temp;
  }

  /* method for displaying all Track info
   *
   * @param displayPoints:  number of data points used in drawing each Radial
   * @param colorScheme:    colorscheme for Each Radial
   */
  void display(int displayPoints, int colorScheme) {
    // draw outline of the track area
    app.stroke(1);
    app.noFill();
    app.rect(posX, posY, w, h);

    // draw beat nubers and lines
    drawTrackTimeStamps();

    try {
      for (int i = trackRadials.size() - 1; i >= 0; i--) {
        trackRadials.get(i).display(displayPoints, colorScheme);
      }
    } 
    catch (Exception e) {
      println("Exception: " + e + " when trying to display track radials");
    }

    if (bPlaying) {
      drawTrackPosition();
    }
  }

  // method for drawing time stamps for the track
  void drawTrackTimeStamps() {
    for (int i = 0; i < trackLengthB; i++) {
      // break if the lines are out of the track area to the right
      if (timeStampXValues[i] > posX + w) {
        break;
      }
      // check if beat line is within the track area
      if (timeStampXValues[i] > posX) {
        // draw thicker lines and beat number every 4 bars
        if ((i + 1) % 4 == 0) {
          app.textSize(10);
          app.textAlign(CENTER);
          app.fill(0);
          app.text((i + 1), timeStampXValues[i], posY + h + 13);

          app.stroke(50);
        } else {
          app.stroke(200);
        }
        app.strokeWeight(2);
        app.line(timeStampXValues[i], posY, timeStampXValues[i], posY + h);
      }
    }
  }

  // method for drawing the position within a track
  void drawTrackPosition() {
    int trackBeatPos = floor((millis() - startOfPlay) / (trackLengthMS / trackLengthB));

    try {
      trackPos = timeStampXValues[trackBeatPos];
    } 
    catch (Exception e) {
      println("Exception: " + e + " when drawing track position");
    }

    // check if track positon line is past the halfway of the window width
    if (trackPos > posX + (w / 2)) {
      // find the amount needed to place the current value exactly at halfway the window width
      float scalar = timeStampXValues[trackBeatPos] - (posX + (w / 2));
      for (int i = 0; i < track1.timeStampXValues.length; i++) {
        timeStampXValues[i] -= scalar;
      }
      trackPos = timeStampXValues[trackBeatPos];
    }

    // check if track position is located within track area
    if (trackPos >= posX && trackPos <= (posX + w)) {
      app.stroke(0, 200, 0);
      app.strokeWeight(2);
      app.line(trackPos, posY, trackPos, posY + h);
    }
  }

  /* method for checking if mouse is over the track
   *
   * @param x:  x position of mouse
   * @param y:    y position of mouse
   */
  boolean overTrack(int x, int y) {
    if (x >= posX && x <= (posX + w) && y >= posY && y <= (posY + h)) {
      return true;
    } else {
      return false;
    }
  }
  
  void updateBPM(int bpm) {
    BPM = bpm;
    trackLengthMS = (trackLengthB * (1000f / (BPM / 60f)));
  }
}
