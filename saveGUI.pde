
// All GWindow element declarations for save window
GWindow saveWindow;
GTextField fileNameField;
GLabel promptLabel;
GButton save;

int saveWindowWidth = 300;
int saveWindowHeight = 130;

// This method initializes all elements of the save window
public void saveGUI() {
  // setup for save window
  saveWindow = GWindow.getWindow(this, "Save Song", ((width - saveWindowWidth) / 2), (height - saveWindowHeight) / 2, saveWindowWidth, saveWindowHeight, JAVA2D);
  saveWindow.setActionOnClose(G4P.CLOSE_WINDOW);
  saveWindow.setAlwaysOnTop(true);
  saveWindow.addDrawHandler(this, "saveWindowDraw");
  saveWindow.addMouseHandler(this, "saveWindowMouse");
  saveWindow.addKeyHandler(this, "saveWindowKey");
  
  // label declaration
  promptLabel = new GLabel(saveWindow, (saveWindowWidth / 2) - (300 / 2), 5, 300, 36);
  promptLabel.setTextAlign(GAlign.CENTER, null);
  promptLabel.setFont(Baskerville24);
  promptLabel.setText("Please enter the file name");
  
  // text field declarations
  fileNameField = new GTextField(saveWindow, (saveWindowWidth / 2) - (250 / 2), 46, 250, 36);
  fileNameField.addEventHandler(this, "handleFileNameField");
  fileNameField.tag = "fileName";
  fileNameField.setFont(Baskerville24);
  int l = activeRecordingFileName.length();
  fileNameField.setText(activeRecordingFileName.substring(0, l - 4));
  
  // button declaration
  save = new GButton(saveWindow, (saveWindowWidth / 2) - (80 / 2), 87, 80, 30, "SAVE");
  save.addEventHandler(this, "handleBtnSave");
  save.setFont(Baskerville16);
}

public void saveWindowDraw(PApplet app, GWinData data) {
  app.background(#E8F4F8);
}

public void saveWindowMouse(PApplet app, GWinData data, MouseEvent event) {
}

public void saveWindowKey(PApplet app, GWinData data, KeyEvent event) {
}

public void handleFileNameField(GTextField field, GEvent event) { 
}

public void handleBtnSave(GButton button, GEvent event) { 
  if (event == GEvent.CLICKED) {
    if (fileNameField.getText().equals("") || fileNameField.getText().equals(" ") || fileNameField.getText().equals(null)) {
      promptLabel.setLocalColor(2, #FF0000); // set text color to red
      promptLabel.setText("Please enter a valid file name");
    } else {
      saveRecording(fileNameField.getText());
      makeTempRecordingFile();
      recorded = false;
      recordButton.setText("RECORD");
      saveWindow.close();
    }
  }
}
