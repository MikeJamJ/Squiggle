/*
 * Methods for recording and saving audio
 * Creator: Michael Jamieson
 * Date: July 4, 2020
 */

boolean recorded = false;
String tempRecordingFilePath = "/data/tempRecordings/"; 
String activeRecordingFileName = null;

/* method for saving a recording
 * this copies the temporary recording file to the "recordings" folder under a new name
 * the temporary file is then deleted
 *
 * @param filename: desured filename of the recording for saving
 */
void saveRecording(String filename) {
  // close the recording player so that you can save file
  recording.close();

  // get paths of temp file and new file location
  Path oldPath = Paths.get(sketchPath() + tempRecordingFilePath + activeRecordingFileName);
  Path newPath = Paths.get(sketchPath() + "/data/recordings/" + filename + ".wav");
  try {
    Files.copy(oldPath, newPath);
  } 
  catch (IOException e) {
    println("IOException: " + e + "when trying to save the recording");
  }

  //delete temp file after copying
  deleteTempRecordingFile();
  println("Successfully saved!");
}

// method for deleting the temporary recording file
void deleteTempRecordingFile() {
  // close the player so that you can delete the file
  recording.close();

  // select the most recent temporary recording file
  File f = new File(sketchPath() + tempRecordingFilePath + activeRecordingFileName);

  // check if file exists, then attempt to delete it
  if (f.exists()) {
    if (f.delete()) {
      println("Successfully deleted!");
    } else {
      println("File not deleted");
    }
  }
}

/* method for making a temporary file to save a recording to
 * in order to listen to the recording it must be saved, so I make a temporary file
 * before its decided whether to save the recording
 */
void makeTempRecordingFile() {
  // make a temporary filename for the recording
  int tempRecordingNum = 1;
  String fileName = "tempRecording" + tempRecordingNum + ".wav";

  // make file 
  File f = new File(sketchPath() + tempRecordingFilePath + fileName);

  // if the filename exists, repeat and increase the number by 1 until a new filename is found
  while (f.isFile()) {
    tempRecordingNum++;
    fileName = "tempRecording" + tempRecordingNum + ".wav";
    f = new File(sketchPath() + tempRecordingFilePath + fileName);
  }

  // initialze a recorder to save to the filename
  recorder = mainMinim.createRecorder(audioIn, tempRecordingFilePath + fileName, true);
  activeRecordingFileName = fileName;
  println("Recording Filename: " + fileName);
}
