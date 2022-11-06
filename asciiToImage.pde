/*
 What
 -----
 This piece of code creates the animation from one (or multiple) strings (called "alpha") into a picture and further into a new string "beta".
 First, alpha is displayed, then the individual characters of which alpha is composed of are used to approximate the input image.
 By approximate I mean that the picture is drawn with a certain resolution (N*N) to the screen with letters/numbers instead of square pixels.
 
 How
 ---
 The terminology in the code is that alpha can be mono (one line) or !mono (multiple strings, i.e a text file).
 The only other thing you really need to specify is the image into which alpha should be converted.
 What you might want to change are the "Char global parameters", which specify speed and size bounds for the moving chars.
 
 Important variables list:
 ------------------------
 alpha <- input string, to be first displayed
 beta  <- string which is to be displayed after the image
 Chars <- list of all ascii characters in alpha turnend into a custom Char object
 Pixars <- subset of Chars containing the elements of Chars which are used as pixels for image
 
 USAGE
 ------
 i) Provide all necessary data (alpha,beta,img) and run sketch
 ii) Press space to transition to the image
 iii) Press 'b' or 'B' to transition to beta 
 
 
 Details on implementation
 -------------------------
 We start off with a predefined alpha and beta. Depending on "mono" these are loaded differently.
 Then the following steps are executed:
 
 i) The characters "?!;:+=-,._" are added to alpha. This is done so that we can use them when creating the picture later for finer resolution.
 
 ii) In the function analyze_chars the following happens:
 1. Each ascii character in alpha is turned into a custom Char object which carries its relative (to other Chars) brightness as member variable.
 The result ist stored in "Chars".
 2. The elements of Chars are sorted by descending brightness.
 3. The duplicates of Chars are removed
 
 iii) In CreatePixars the following happens:
 1. For all points on N by N grid find best fitting Char from Chars (called "bestChar") and add all of these chars to ArrayList<Char> Pixars
 2. If bestChar appears in beta, then this specific Char object remembers that with a boolean attribute
 3. Since each Pixar is created in an instant of a grid iteration, it receives its position in the image as target position attribute
 
 iv) In createSentences the following happens:
 1. The locations for the alpha and beta sentence on screen are determined/set
 2. OrderToSentence: Place all present pixars where they are supposed to be in the alpha sentence,set their targets to the targeted image location
 and then make them invisible so that they dont overoccupy letters in alpha.
 3. CompleteSentence: For each Char in alpha spawn a new Char at start and tell it where to vanish to.
 
 Now alpha is properly displayed on screen.
 
 v) spawnBeta: Spawn all Chars present in the beta sentence at a specific spawnpoint
 
 vi) Once space is pressed, the individual Chars which make up alpha move to their target location in the image.
 
 Now the image is displayed using the Pixars.
 
 vii) Once b is pressed, all Pixars move to their beta location thereby forming beta.
 
 Beta is now displayed.
 The program is done.
 
 Advice: The more common characters alpha and beta have the better it will look
 */

import java.util.Scanner;
import java.io.*;
import java.io.FileInputStream;

/*
Chinese example:
 String alpha = "您好，这是您的字母文本";
 String beta = "您好，这是您的测试版文本";
*/
 

// USER DEFINED PARAMETERS (necessary) ##################################################################################
String alpha = "Hello this is your alpha text!";
String beta = "This is your beta text!";
int N = 100;
String imageName = "celeb.jpg";

boolean mono = false; //mono: alpha is a single line. !mono: alpha is all the lines from the text file specified below
String textFilePath = "/home/user/path"; // has to be full path from home dir
boolean chinese = false;

// USER DEFINED PARAMETERS (can be left on default) ######################################################################
float textSizeMin = 9;
float textSizeMax = 21;
float betaTextSizeMax = chinese ? 50 : 30;
float charSpeedMin = 4;
float charSpeedMax = 8;
PVector alphaSentenceLoc; // what is the upper left corner of alpha
PVector betaSentenceLoc; // what is the left corner stone of beta
// #######################################################################################################################
//Text global parameters
float letterSpacing = chinese ? textSizeMax*1: textSizeMax*0.7; //non-chinese:0.7, chinese: >=1
float betaLetterSpacing = chinese ? betaTextSizeMax*1: betaTextSizeMax*0.7;
String fontName = chinese ?  "simsun.ttf" : "consolaz.ttf";
int fontSize = 48;

//Text inputs mono-line
String alphabet = "";

//Important global data structures
ArrayList<Char> chars;
ArrayList<Char> betaChars;
ArrayList<Char> pixars;
ArrayList<Char> sentence;
ArrayList<String> text;
PImage img;

//Sketch params
PFont font;

//Sequence parameters -------
boolean move = false;
boolean charsReady = false;
boolean[] betaPresent;

void setup() {

  //Sketch settings
  size(1000, 1000);
  background(255);
  colorMode(RGB);
  font = createFont(fontName, fontSize);
  textFont(font);

  //Init important global datastructures
  img = loadImage(imageName);
  chars = new ArrayList<Char>();
  betaChars = new ArrayList<Char>();
  pixars = new ArrayList<Char>();
  betaPresent = new boolean[beta.length()];
  for (int i = 0; i<betaPresent.length; i++) {
    betaPresent[i] = false;
  }

  //Create arraylist text containing all lines of alpha sentences
  if (!mono) text = readFile();

  //Configure
  configure(false); //configure(boolean includeSpecial)

  //Analyze all input characters
  analyze_chars();

  //Create all pixars which later build image
  createPixars(N);

  //Create alpha and beta on screen
  createSentences();

  //Continue preparation of beta chars
  spawnBetaChars();
  frameRate(60);
}

void draw() {
  background(0);
  for (Char c : pixars) {
    c.display();
    if (move) {
      c.move();
    }
  }
}

//Create the alpha sentece such that it is ready to be displayed on screen
void createSentences() {

  alphaSentenceLoc = new PVector(width/10, height/4.5);
  //calc pos for betasentence
  float horOffset = width/15;
  float xbetastart = width/2-beta.length()/2*letterSpacing;
  betaSentenceLoc = new PVector(xbetastart-horOffset, height*0.5);
  float vertSpacing = chinese ? 2*letterSpacing : 3*letterSpacing;

  if (mono) {
    //Make all the pixars in pixars build the alpha sentence
    orderToSentence(alphaSentenceLoc, alpha);
    //Add chars to sentence which are not used for picture
    completeSentence(alphaSentenceLoc, alpha);
  } else {
    for (int i = 0; i<text.size(); i++) {
      orderToSentence(alphaSentenceLoc, text.get(i));
      alphaSentenceLoc.y+=vertSpacing;
    }
    alphaSentenceLoc.y-=text.size()*vertSpacing;
    for (int i = 0; i<text.size(); i++) {
      completeSentence(alphaSentenceLoc, text.get(i));
      alphaSentenceLoc.y+=vertSpacing;
    }
  }
}

//add special characters to alphabet such that they are used to build image
void configure(boolean includeSpecial) {
  if (mono) {
    if (includeSpecial)alpha+="?!;:+=-,._";
    alphabet = alpha;
  } else {
    if (includeSpecial)text.add("?!;:+=-,._");
    alphabet = concatStrings(text);
  }
}

//Spawn all Chars present in the beta sentence at the spawnpoint
void spawnBetaChars() {
  for (int i = 0; i<beta.length(); i++) {
    PVector spawnPoint = new PVector(width/2, height*0.3);
    char c = beta.charAt(i);
    Char newChar = new Char(c, spawnPoint);
    newChar.hide(true);
    newChar.setBetaIndex(i);
    PVector target = new PVector(betaSentenceLoc.x + i*betaLetterSpacing, betaSentenceLoc.y);
    newChar.speed = 3;
    newChar.setTarget(target);
    newChar.calcDistToCover();
    betaChars.add(newChar);
  }
}

//For each char in sentence spawn a new Char at start and tell it where to vanish to
void completeSentence(PVector start, String sentence) {
  for (int i = 0; i<sentence.length(); i++) {
    char c = sentence.charAt(i);
    if (contains(sentence, c)) {
      float spread = width/10;
      PVector vanishingPos = new PVector(width/2+random(-spread, spread), height/2+random(-spread, spread));
      PVector textPos = new PVector(start.x + i*letterSpacing, start.y);
      Char newPixar = new Char(c, textPos);
      newPixar.setTarget(vanishingPos);
      newPixar.calcDistToCover();
      newPixar.mustFade = true;
      pixars.add(newPixar);
    }
  }
}

//Place all present pixars where they are supposed to be in the alpha sentence and set their targets to the targeted image location
void orderToSentence(PVector start, String sentence) {
  for (int i = 0; i<pixars.size(); i++) {
    Char pixar = pixars.get(i);
    if (!pixar.isAlphaOrdered()) {
      char c = pixars.get(i).charac;
      int sentenceIndex = getSentenceIndex(c, sentence);
      if (sentenceIndex != -17) {
        PVector targetPos = pixars.get(i).pos.copy();
        PVector textPos = new PVector(start.x + sentenceIndex*letterSpacing, start.y);
        pixar.setPos(textPos);
        pixar.setTarget(targetPos);
        pixar.calcDistToCover();
        pixar.setAlphaOrdered(true);
        pixar.hide(true);
      }
    }
  }
}

void transToBeta() {
  for (Char alphaChar : pixars) {
    if (!alphaChar.inBeta()) {
      alphaChar.mustFade = true;
    } else {
      int sentIdx = getSentenceIndex(alphaChar.charac, beta);
      PVector textPos = new PVector(betaSentenceLoc.x + sentIdx*betaLetterSpacing, betaSentenceLoc.y);
      alphaChar.setTarget(textPos);
      alphaChar.isHome = false;
      alphaChar.toBeta(true);
      alphaChar.calcDistToCover();
      alphaChar.setBetaIndex(sentIdx);
    }
  }

  for (Char betaChar : betaChars) {
    betaChar.hide(false);
    betaChar.isHome = false;
    betaChar.toBeta(true);
    ;
    betaChar.calcDistToCover();
    pixars.add(betaChar);
  }
}


void keyPressed() {
  if (key == ' ') {
    move = !move;
  } else if (key == 'b' || key == 'B') {
    transToBeta();
    background(0);
  }
}
