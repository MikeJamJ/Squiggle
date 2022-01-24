 //<>//
public void mainWindowMouse(PApplet app, GWinData data, MouseEvent event) {
  mainWinData mainData = (mainWinData)data;

  // once the mouse is released, make all Radial handles inactive
  if (event.getAction() == MouseEvent.RELEASE) {
    for (int i = 0; i < radials.length; i++) {
      radials[i].releaseHandleEvent();
    }
    try {
      for (int i = track1.trackRadials.size() - 1; i >= 0; i--) {
        track1.trackRadials.get(i).releaseHandleEvent();
      }
    } 
    catch (Exception e) {
      println("Exception: " + e + " when tring to release track radial handles");
    }
    mainData.bRadialHandleActive = false;
  }
}

public void mainWindowKey(PApplet app, GWinData data, KeyEvent event) {
  mainWinData mainData = (mainWinData)data;
}


public void handleWebcamToggle1(GButton button, GEvent event) {
  if (event == GEvent.CLICKED) {
    if (((mainWinData)mainWindow.data).bCameraOn) {
      cam.stop();
      ((mainWinData)mainWindow.data).bCameraOn = false;
    } else {
      cam.start();
      ((mainWinData)mainWindow.data).bCameraOn = true;
    }
  }
} 

public void handleWebcamToggle2(GButton button, GEvent event) { 
  println("webcamToggle2 - GButton >> GEvent." + event + " @ " + millis());
} 

public void handleWebcamToggle3(GButton button, GEvent event) { 
  println("webcamToggle3 - GButton >> GEvent." + event + " @ " + millis());
} 

public void handleWebcamToggle4(GButton button, GEvent event) { 
  println("webcamToggle4 - GButton >> GEvent." + event + " @ " + millis());
} 

public void handlePlay(GButton button, GEvent event) {
  if (event == GEvent.CLICKED) {
    // if the track isnt playing, play it
    if (!track1.bPlaying) {
      track1.bPlaying = true;
      track1.startOfPlay = millis();
      button.setText("PAUSE");
      // set slider to the beginning
      trackSlider.setValue(0.0f);
      setTrackTimeStampValues();
      println("playing");
    }
    // if the track is currently playing, pause all the sounds
    else if (track1.bPlaying) {
      track1.bPlaying = false;
      for (int i = track1.trackRadials.size() - 1; i >= 0; i--) {
        if (track1.trackRadials.get(i).sound.isPlaying()) {
          track1.trackRadials.get(i).pause();
        }
      }
      button.setText("PLAY");
    }
  }
}

public void handleRecord(GButton button, GEvent event) { 
  if (event == GEvent.CLICKED) {
    // check if a recording has been made
    if (!recorded) {
      // check if the recording is currently active
      if (recorder.isRecording() ) {
        recorder.endRecord();
        recorded = true;
        recorder.save();
        recording = mainMinim.loadFile(tempRecordingFilePath + activeRecordingFileName);
        button.setText("PLAY RECORDING");
      } else {
        recorder.beginRecord();
        button.setText("RECORDING");
      }
    } else {
      if (!recording.isPlaying()) {
        recording.play(0);
        button.setText("PAUSE RECORDING");
      } else {
        recording.pause();
        button.setText("PLAY RECORDING");
      }
    }
  }
} 

public void handleBtnSaveRecording(GButton button, GEvent event) { 
  if (event == GEvent.CLICKED) {
    if (recorded) {
      saveGUI();
    }
  }
} 

public void handleRadialAreaSlider(GCustomSlider slider, GEvent event) { 
  float scalar = ((mainWinData)mainWindow.data).lastRadialPosX - (windowWidth - radialAreaBorder - maxRadialRadius);
  for (int i = 0; i < radials.length; i++) {
    radials[i].orgPosX = radials[i].curPosX = (maxRadialRadius * ((2 * i) + 1)) + (radialSpacing * i) + radialAreaBorder - (int(slider.getValueF() * scalar));
  }
} 

public void handleTrackSlider(GCustomSlider slider, GEvent event) {
  setTrackTimeStampValues();
}

public void handleBPMTextField(GTextField field, GEvent event) {
  if (event == GEvent.LOST_FOCUS) {
    int bpm = field.getValueI();

    // if the value input is not valid, set to 120
    if (bpm == -1) {
      field.setText("120");
    } else {
      ((mainWinData)mainWindow.data).BPM = bpm;

      for (int i = 0; i < radials.length; i++) {
        radials[i].updateRadialTickRate(bpm);
      }
      try {
        for (int i = track1.trackRadials.size() - 1; i >= 0; i--) {
          track1.trackRadials.get(i).updateRadialTickRate(bpm);
        }
      } 
      catch (Exception e) {
        println("Exception: " + e + " when trying to update track radial tick rates");
      }
      track1.updateBPM(bpm);
      println(track1.trackLengthMS);
    }
    field.setLocalColorScheme(9);
  }
}


public void handleFolderSelectList(GDropList droplist, GEvent event) {
  if (event == GEvent.SELECTED) {
    int temp = droplist.getSelectedText().lastIndexOf(" ");
    String folder = droplist.getSelectedText().substring(temp + 1);
    String path = findSelectedFolder(sketchPath() + "/data/sounds/", folder);
    makeRadialArray(mainWindow, findSoundFilesInDirectory(path), path);
  }
}

// method for setting the time stamp x values of a track based on the trackSlider position
void setTrackTimeStampValues() {
  float scalar = ((mainWinData)mainWindow.data).lastTrackPosX - ((trackWindowX + trackWindowW) - track1.trackSpacing);
  for (int i = 0; i < track1.timeStampXValues.length; i++) {
    track1.timeStampXValues[i] = (track1.posX + (track1.trackSpacing * (i + 1))) - (int(trackSlider.getValueF() * scalar));
  }
}
