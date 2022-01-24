

// All GWindow element declarations for main window
GWindow mainWindow;
GButton webcamToggle1, webcamToggle2, webcamToggle3, webcamToggle4; 
GButton playButton, recordButton, saveRecordingButton; 
GCustomSlider radialAreaSlider, trackSlider; 
GTextField bpmField;
GDropList folderSelectList;

int radialSpacing, radialAreaBorder;
int trackWindowX, trackWindowY, trackWindowW, trackWindowH;
int webcamW, webcamH;
boolean NoCam = false;

// This method initializes all elements of the main screen
public void mainGUI() {

  // setup for main window
  mainWindow = GWindow.getWindow(this, "Main Screen", ((width - windowWidth) / 2), 0, windowWidth, windowHeight, JAVA2D);
  mainWindow.setActionOnClose(G4P.EXIT_APP);
  mainWindow.setAlwaysOnTop(true);
  mainWindow.addDrawHandler(this, "mainWindowDraw");
  mainWindow.addMouseHandler(this, "mainWindowMouse");
  mainWindow.addKeyHandler(this, "mainWindowKey");
  mainWindow.addData(new mainWinData());

  // start camera
  try {
    cam = new Capture(mainWindow, getCamera());
    cam.start();
  } catch (Exception e) {
    println("Exception: " + e + " when trying to start cam");
    NoCam = true;
  }

  //Load in a sound files wihin a given folder
  radialsMinim = new Minim(mainWindow);
  mainMinim = new Minim(mainWindow);

  // get a stereo line-in: sample buffer length of 2048
  // default sample rate is 44100, default bit depth is 16
  audioIn = mainMinim.getLineIn(Minim.STEREO, 2048);
  // get an output we can playback the recording on
  audioOut = radialsMinim.getLineOut(Minim.STEREO);
  
  // make temp recording file for when recording occurs
  makeTempRecordingFile();

  // set main window data
  ((mainWinData)mainWindow.data).username = ((introWinData)introWindow.data).username;
  ((mainWinData)mainWindow.data).bGUILoaded = false;
  ((mainWinData)mainWindow.data).bCameraOn = true;
  ((mainWinData)mainWindow.data).bRadialsLoaded = false;
  ((mainWinData)mainWindow.data).bRadialHandleActive = false;
  ((mainWinData)mainWindow.data).BPM = 120;

  // make Radial array from the default folder
  makeRadialArray(mainWindow, findSoundFilesInDirectory(defaultSoundFolder), defaultSoundFolder);
  ((mainWinData)mainWindow.data).bRadialsLoaded = true;
  ((mainWinData)mainWindow.data).lastRadialPosX = radials[radials.length - 1].curPosX;
  
  // make a track
  track1 = new Track(mainWindow, trackWindowX, trackWindowY, trackWindowW, trackWindowH, ((mainWinData)mainWindow.data).BPM);
  ((mainWinData)mainWindow.data).lastTrackPosX = track1.timeStampXValues[track1.timeStampXValues.length - 1];

  // Button declarations and handlers
  webcamToggle1 = new GButton(mainWindow, 45, 270, 80, 30, "Toggle Webcam");
  webcamToggle1.addEventHandler(this, "handleWebcamToggle1");
  webcamToggle1.setFont(Baskerville16);
  webcamToggle2 = new GButton(mainWindow, 215, 270, 80, 30, "Toggle Webcam");
  webcamToggle2.addEventHandler(this, "handleWebcamToggle2");
  webcamToggle2.setFont(Baskerville16);
  webcamToggle3 = new GButton(mainWindow, 45, 433, 80, 30, "Toggle Webcam");
  webcamToggle3.addEventHandler(this, "handleWebcamToggle3");
  webcamToggle3.setFont(Baskerville16);
  webcamToggle4 = new GButton(mainWindow, 215, 433, 80, 30, "Toggle Webcam");
  webcamToggle4.addEventHandler(this, "handleWebcamToggle4");
  webcamToggle4.setFont(Baskerville16);

  playButton = new GButton(mainWindow, windowWidth - 510, 55, 120, 42, "PLAY");
  playButton.addEventHandler(this, "handlePlay");
  playButton.setFont(Baskerville16);
  recordButton = new GButton(mainWindow, windowWidth - 340, 55, 120, 42, "RECORD");
  recordButton.addEventHandler(this, "handleRecord");
  recordButton.setFont(Baskerville16);
  saveRecordingButton = new GButton(mainWindow, windowWidth - 170, 55, 120, 42, "SAVE RECORDING");
  saveRecordingButton.addEventHandler(this, "handleBtnSaveRecording");
  saveRecordingButton.setFont(Baskerville16);

  // Slider declarations and handlers
  radialAreaSlider = new GCustomSlider(mainWindow, centerGControlX(mainWindow, 220), (mainWindow.height - 50), 220, 40, null);
  radialAreaSlider.setLimits(0.0f, 0.0f, 1.0f);
  radialAreaSlider.setNumberFormat(G4P.DECIMAL, 2);
  radialAreaSlider.setShowDecor(false, false, false, false); //show: opaque, ticks, value, limits
  radialAreaSlider.addEventHandler(this, "handleRadialAreaSlider");
  trackSlider = new GCustomSlider(mainWindow, (trackWindowX + (trackWindowW / 2) - (400 / 2)), (trackWindowY + trackWindowH + 10), 400, 40, null);
  trackSlider.addEventHandler(this, "handleTrackSlider");
  trackSlider.setLimits(0.0f, 0.0f, 1.0f);
  trackSlider.setNumberFormat(G4P.DECIMAL, 2);
  trackSlider.setShowDecor(false, false, false, false); //show: opaque, ticks, value, limits

  // Text field declarations and handlers
  bpmField = new GTextField(mainWindow, windowWidth - 150, 750, 100, 36);
  bpmField.addEventHandler(this, "handleBPMTextField");
  bpmField.setNumeric(1, 250, -1);
  bpmField.tag = "bpm";
  bpmField.setFont(Baskerville24);
  bpmField.setText(str(((mainWinData)mainWindow.data).BPM));
  
  folderSelectList = new GDropList(mainWindow, 20, windowHeight - 300, 200, 100);
  folderSelectList.addEventHandler(this, "handleFolderSelectList");
  folderSelectList.setFont(Baskerville22);
  folderSelectList.setLocalColorScheme(10); // seperate color scheme for this
  initializeFolderSelectValues(sketchPath() + "/data/sounds/", 0);

  // reused label from intro window resized and moved
  squiggle = new GLabel(mainWindow, 138, 32, 414, 88);
  squiggle.setTextAlign(GAlign.LEFT, null);
  squiggle.setFont(Baskerville64);
  squiggle.setText("SQUIGGLE.io");
  squiggle.setVisible(true); 

  ((mainWinData)mainWindow.data).bGUILoaded = true;
  
  //printRadialsData();
}


/* default method for drawing to G4P main window
 *
 * @param app:   name of G4P window (automatically applied)
 * @param data:  G4P window data (automatically applied)
 */
public void mainWindowDraw(PApplet app, GWinData data) {
  mainWinData mainData = (mainWinData)data;  

  if (mainData.bGUILoaded) {
    mainHeaderGUI(app, data);

    // check if cam is avaiable for data
    try {
      updateMainCams(app, data);
    } 
    catch (Exception e) {
      println("Exception: " + e + " when trying to update cams");
    }

    // draw radials
    if (mainData.bRadialsLoaded) {
      for (int i = 0; i < radials.length; i++) {
        // if it was found a handle was active, just update without checking the return 
        if (mainData.bRadialHandleActive) {
          radials[i].update(mainData.bRadialHandleActive);
        }
        else if (radials[i].update(mainData.bRadialHandleActive)) {
          mainData.bRadialHandleActive = true;
        }
        radials[i].display(180, NO_COLOR);
      }
      // update track radials
      if (track1.update(mainData.bRadialHandleActive)) {
        mainData.bRadialHandleActive = true;
      }
      track1.display(180, NO_COLOR);  //<>//
    }
    
    if (recorder.isRecording()) {
      app.fill(255, 0, 0);
      app.noStroke();
      app.circle(windowWidth - 200, (55 + (42 / 2)), 20);
    } else if (recorded) {
      if (recording.length() == recording.position()) {
        recordButton.setText("PLAY RECORDING");
      }
    }
    
  } else {
    mainLoadingGUI(app, data);
  }
}

/* method for drawing the header for mainWindow
 *
 * @param app:   name of G4P window
 * @param data:  G4P window data
 */
void mainHeaderGUI(PApplet app, GWinData data) {
  // main background
  app.background(#E8F4F8);
  //load logo
  app.image(logo, 31, 26, 100, 100);
  // decided to display frame rate
  app.fill(0);
  app.textSize(12);
  app.textAlign(RIGHT, TOP);
  app.text(frameRate, windowWidth - 10, 10); 
  // Radial area background
  app.noStroke();
  app.fill(150);
  app.rect(0, (windowHeight - 228), windowWidth, 3);
  app.fill(255);
  app.rect(0, (windowHeight - 225), windowWidth, windowHeight);
}


/* method for drawing loading screen while mainGUI is loading
 *
 * @param app:   name of G4P window
 * @param data:  G4P window data
 */
void mainLoadingGUI(PApplet app, GWinData data) {
  app.background(#E8F4F8);
  app.textSize(48);
  app.fill(#000050);
  app.textAlign(CENTER);
  app.text("Loading...", windowWidth / 2, windowHeight / 2);
}

/* method for updating webcam data to the G4P window
 *
 * @param app:   name of G4P window 
 * @param data:  G4P window data
 */
void updateMainCams(PApplet app, GWinData data) {
  mainWinData mainData = (mainWinData)data; 

  if (mainData.bCameraOn && NoCam == false) {
    // if the webcam data is available to read, get read
    if (cam.available()) {
      cam.read();
    }
    app.image(cam, 45, 147, webcamW, webcamH);
  } else {
    // if the webcam is toggled off, turn space black and display the username
    app.fill(50);
    app.rect(45, 147, webcamW, webcamH);
    app.fill(255);
    app.textSize(32);
    app.textAlign(CENTER, CENTER);
    // if the username is larger than 9 characters, display the first 6 and "..."
    if (mainData.username.length() > 9) {
      app.text(mainData.username.substring(0, 6) + "...", 45 + (webcamW / 2), 147 + (webcamH / 2));
    } else {
      app.text(mainData.username, 45 + (webcamW / 2), 147 + (webcamH / 2));
    }
  }
}

// method for later so we can do auto formatting
void setMainGUIValues() {
  radialSpacing = 20;
  radialAreaBorder = 20;
  trackWindowX = 490;
  trackWindowY = 147;
  trackWindowW = windowWidth - trackWindowX;
  trackWindowH = 560;
  webcamW = 160;
  webcamH = 120;
}
