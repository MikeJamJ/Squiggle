import g4p_controls.*;
import processing.video.*;

// for FFT
import ddf.minim.*; 
import ddf.minim.spi.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;

// for saving to clipboard
import java.awt.*;
import java.awt.datatransfer.StringSelection;
import java.awt.datatransfer.Clipboard;

// for MP3 and WAV file saving
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;
import java.io.BufferedWriter;

// objects for getting audio from mic and speakers
AudioInput audioIn;
AudioRecorder recorder;
AudioOutput audioOut;
AudioPlayer recording;
Minim radialsMinim;
Minim mainMinim;

PImage logo;
Capture cam;
Font Baskerville64, Baskerville24, Baskerville22, Baskerville16;
Radial[] radials;
Track track1;

int windowWidth, windowHeight;
int maxRadialRadius = 60;
int minRadialRadius = 10;

String defaultSoundFolder;

void setup() {
  // set the defualt window insisible
  fullScreen();
  surface.setVisible(false); 
  
  // anti-aliasing to [input number]x
  // onlny used for P3D or P2D renderers
  //smooth(2);
  
  // set maximum fram rate to 120
  // I need to do this to display the framerate
  frameRate(120);
  windowWidth = 1280;
  windowHeight = height - int(height * 0.025f);
  defaultSoundFolder = sketchPath() + "/data/sounds/Piano/PiNotes/";

  //Load in logo png from data folder  
  logo = loadImage("data/Squiggle_Logo.png");
  
  G4P.messagesEnabled(false);   // don't allow messages
  G4P.setGlobalColorScheme(9);  // Custom scheme
  G4P.setCtrlMode(GControlMode.CORNER);  //Set dimensioning to x1, y1, w, h
  setIntroGUIValues();
  introGUI();
}


void draw() {  
}


class introWinData extends GWinData {
  boolean bGUILoaded, bJoin, bCreate, bTour;
  int butWidth;
  String sessionPassword;
  String username;
}

class mainWinData extends GWinData {
  boolean bGUILoaded, bCameraOn, bRadialsLoaded, bRadialHandleActive;
  int lastRadialPosX, BPM, lastTrackPosX;
  String username;
}
