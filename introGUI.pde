/*
 * Methods for drawing to the intro window
 * Creator: Michael Jamieson
 * Date: July 4, 2020
 */

// All GWindow element declarations for intro window
GWindow introWindow;
GButton joinSession, createSession, takeATour, clipboard, play, back;
GTextField roomCodeField, nameField;
GLabel squiggle, roomCodeLabel, nameLabel;

int introButLargeW, introButLargeH, introButSmallW, introButSmallH, introFieldW, introFieldH, 
  introLineLength;

//This method initializes all elements of the intro screen
public void introGUI() {
  // Bring in required fonts for intro window
  Baskerville64 = getFont("fonts/BASKVILL.TTF", Font.PLAIN, 64);
  Baskerville24 = getFont("fonts/BASKVILL.TTF", Font.PLAIN, 24);
  Baskerville22 = getFont("fonts/BASKVILL.TTF", Font.PLAIN, 22);
  Baskerville16 = getFont("fonts/BASKVILL.TTF", Font.PLAIN, 16);

  //Setup for the intro window
  introWindow = GWindow.getWindow(this, "Intro Screen", ((width - windowWidth) / 2), 0, windowWidth, windowHeight, JAVA2D); //((height - windowHeight) / 2)
  introWindow.setActionOnClose(G4P.CLOSE_WINDOW);
  introWindow.setAlwaysOnTop(true);
  introWindow.addDrawHandler(this, "introWindowDraw");
  introWindow.addMouseHandler(this, "introWindowMouse");
  introWindow.addKeyHandler(this, "introWindowKey");
  introWindow.addData(new introWinData());
  ((introWinData)introWindow.data).bGUILoaded = false;
  ((introWinData)introWindow.data).bJoin = false;
  ((introWinData)introWindow.data).bCreate = false;
  ((introWinData)introWindow.data).bTour = false;
  ((introWinData)introWindow.data).sessionPassword = null;

  // Button declarations and handlers
  joinSession = new GButton(introWindow, centerGControlX(introWindow, introButLargeW), 315, introButLargeW, introButLargeH, "Join Session");
  joinSession.addEventHandler(this, "handleBtnJoinSession");
  joinSession.setFont(Baskerville24);
  createSession = new GButton(introWindow, centerGControlX(introWindow, introButLargeW), 411, introButLargeW, introButLargeH, "Create Session");
  createSession.addEventHandler(this, "handleBtnCreateSession");
  createSession.setFont(Baskerville24);
  takeATour = new GButton(introWindow, centerGControlX(introWindow, introButLargeW), 507, introButLargeW, introButLargeH, "Take a Tour");
  takeATour.addEventHandler(this, "handleBtnTakeATour");
  takeATour.setFont(Baskerville24);
  clipboard = new GButton(introWindow, 842, 354, 189, 27, "Copy to Clipboard");
  clipboard.addEventHandler(this, "handleBtnClipboard");
  clipboard.setFont(Baskerville16);
  clipboard.setVisible(false);
  play = new GButton(introWindow, centerGControlX(introWindow, introButSmallW), 499, introButSmallW, introButSmallH, "PLAY");
  play.addEventHandler(this, "handleBtnPlay");
  play.setFont(Baskerville16);
  play.setVisible(false);
  back = new GButton(introWindow, 10, 10, introButSmallW, introButSmallH, "BACK");
  back.addEventHandler(this, "handleBtnBack");
  back.setFont(Baskerville16);
  back.setVisible(false);

  // Text field declarations
  roomCodeField = new GTextField(introWindow, centerGControlX(introWindow, introFieldW), 348, introFieldW, introFieldH);
  roomCodeField.addEventHandler(this, "handleRoomCodeTextField");
  roomCodeField.setFont(Baskerville24);
  roomCodeField.setPromptText("Input Room Code");
  roomCodeField.setVisible(false);
  nameField = new GTextField(introWindow, centerGControlX(introWindow, introFieldW), 443, introFieldW, introFieldH);
  nameField.addEventHandler(this, "handleNameTextField");
  nameField.setFont(Baskerville24);
  nameField.setPromptText("Input Your Name");
  nameField.setVisible(false);

  // Label declarations
  squiggle = new GLabel(introWindow, 512, 184, 414, 88);
  squiggle.setTextAlign(GAlign.LEFT, null);
  squiggle.setFont(Baskerville64);
  squiggle.setText("SQUIGGLE.io");
  roomCodeLabel = new GLabel(introWindow, 502, 302, 141, 34);
  roomCodeLabel.setTextAlign(GAlign.LEFT, null);
  roomCodeLabel.setFont(Baskerville22);
  roomCodeLabel.setText("Room Code");
  roomCodeLabel.setVisible(false);
  nameLabel = new GLabel(introWindow, 502, 401, 70, 34);
  nameLabel.setTextAlign(GAlign.LEFT, null);
  nameLabel.setFont(Baskerville22);
  nameLabel.setText("Name");
  nameLabel.setVisible(false);  

  ((introWinData)introWindow.data).bGUILoaded = true;
}

/* default method for drawing to G4P intro window
 *
 * @param app:   name of G4P window (automatically applied)
 * @param data:  G4P window data (automatically applied)
 */
public void introWindowDraw(PApplet app, GWinData data) {
  introWinData introData = (introWinData)data;
  
  if (introData.bGUILoaded) {
    introHeaderGUI(app, data); 

    if (introData.bJoin) {
      introJoinSessionGUI(app, data);
    } else if (introData.bCreate) {
      introCreateSessionGUI(app, data);
    } else if (introData.bTour) {
    } else {
      introMainGUI(app, data);
    }
  }
}

/* method for drawing the header of the intro window
 * this includes: logo, name, and underline
 *
 * @param app:   name of G4P window
 * @param data:  G4P window data
 */
void introHeaderGUI(PApplet app, GWinData data) {
  introWinData introData = (introWinData)data;
  //background color
  app.background(#E8F4F8);
  // Logo
  app.image(logo, 405, 178, 100, 100);
  // Line under logo
  app.strokeWeight(2);
  app.stroke(#69D2E7);
  app.line((windowWidth / 2) - (introLineLength / 2), 286, (windowWidth / 2) + (introLineLength / 2), 286);

  // decided to display frame rate
  app.fill(0);
  app.textSize(12);
  app.textAlign(RIGHT, TOP);
  app.text(frameRate, windowWidth - 10, 10);
}

/* method for drawing the main intro window
 *
 * @param app:   name of G4P window
 * @param data:  G4P window data
 */
void introMainGUI(PApplet app, GWinData data) {
  introWinData introData = (introWinData)data;

  // Make buttons from main screen visible
  joinSession.setVisible(true);
  createSession.setVisible(true);
  takeATour.setVisible(true);  

  roomCodeLabel.setVisible(false);
  roomCodeField.setVisible(false);
  nameLabel.setVisible(false);
  nameField.setVisible(false);
  play.setVisible(false);
  back.setVisible(false);
  clipboard.setVisible(false);
}

/* method for drawing the join session screen of the intro window
 *
 * @param app:   name of G4P window
 * @param data:  G4P window data
 */
void introJoinSessionGUI(PApplet app, GWinData data) {
  introWinData introData = (introWinData)data;

  // Hide buttons from main screen
  joinSession.setVisible(false);
  createSession.setVisible(false);
  takeATour.setVisible(false);

  // Make text fields, labels and buttons visible
  roomCodeLabel.setVisible(true);
  roomCodeField.setVisible(true);
  nameLabel.setVisible(true);
  nameField.setVisible(true);
  play.setVisible(true);
  back.setVisible(true);
}

/* method for drawing the create session screen of the intro window
 *
 * @param app:   name of G4P window
 * @param data:  G4P window data
 */
void introCreateSessionGUI(PApplet app, GWinData data) {
  introWinData introData = (introWinData)data;

  // Hide buttons from main screen
  joinSession.setVisible(false);
  createSession.setVisible(false);
  takeATour.setVisible(false);

  // Make text fields, labels and buttons visible
  roomCodeLabel.setVisible(true);
  roomCodeField.setVisible(true);
  nameLabel.setVisible(true);
  nameField.setVisible(true);
  play.setVisible(true);
  back.setVisible(true);
  clipboard.setVisible(true);

  // If a room code has not been made, make one and save it to the window data
  if (((introWinData)introWindow.data).sessionPassword == null)  ((introWinData)introWindow.data).sessionPassword = makeSessionPasswordPort();

  // Add room code into text field
  roomCodeField.setText(((introWinData)introWindow.data).sessionPassword);
}

// method for later so we can do auto formatting
void setIntroGUIValues() { 
  introButLargeW = 411; 
  introButLargeH = 68;
  introFieldW = 304;
  introFieldH = 40;
  introButSmallW = 101;
  introButSmallH = 41;
  introLineLength = 711;
}
