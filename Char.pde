import java.util.*;
// A Char object is an ascii character that can move, be displayed and has other properties important for animating it
class Char {
  // Most important Char properties
  private char charac; //character it holds
  private float b; //brightness score
  private PVector pos; //position
  private float speed = 15; //speed
  private float betaSpeedOffset; //give a randomized offset to pixar speed
  private float alphaSpeedOffset;
  private int _textSize; //Displayed size

  private color realCol; //color in original image
  private float realB; //brightness of realCol
  private color textCol = 255; // color to display text
  private color col = textCol; //initially we always start with a text so col is textCol

  //Positioningy
  private PVector target; //target destination as pixel on screeen
  private boolean isHome = false; //Is target - pos < epsilon? If so, snap to target destination
  private float epsilon = speed*0.8;
  private float distToCover; // target-pos
  private int betaIdx=-1; //index in beta position

  //state booleans
  private boolean inBeta = false;
  private boolean toBeta = false;
  private boolean hidden = false;
  private boolean mustFade = false;
  private boolean alphaOrdered = false;

  //Constructors
  Char(char _c, float _b) {
    charac = _c;
    b = _b;
    initOffsets();
  }
  Char(char _c, PVector _pos) {
    charac = _c;
    pos = _pos;
    _textSize = (int)textSizeMax;
    initOffsets();
  }

  void initOffsets() {
    int aMag = 4;
    int bMag = 2;
    alphaSpeedOffset = random(-aMag, aMag);
    betaSpeedOffset = random(-bMag, bMag);
  }

  //Setter Methods ##########################################
  public void hide(boolean val) {
    hidden = val;
  }

  public void realCol(boolean _real) {
    col = _real ? realCol : textCol;
  }

  public void setRealCol(color _realCol) {
    realCol = _realCol;
    realB = brightness(_realCol);
  }

  public void toBeta(boolean val) {
    toBeta = val;
  }

  public void setBetaIndex(int val) {
    betaIdx = val;
  }

  public void setAlphaOrdered(boolean val) {
    alphaOrdered = val;
  }

  public void setPos(PVector _pos) {
    pos = _pos;
  }

  public void setTarget(PVector _target) {
    target = _target;
  }

  public void setDistToCover(float _d) {
    distToCover = _d;
  }


  public void setInBeta(boolean val) {
    inBeta = val;
  }

  //Getter Methods ##########################################

  public boolean isAlphaOrdered() {
    return alphaOrdered;
  }

  public boolean inBeta() {
    return inBeta;
  }

  public void calcDistToCover() {
    distToCover = (target.copy()).sub(pos.copy()).mag();
  }

  //Move and display
  public void move() {
    if (!isHome) {
      hidden = false;
      //Manual movement calcs in hope of speed up
      float dirX = target.x-pos.x;
      float dirY = target.y-pos.y;
      float distLeft = sqrt(dirX*dirX+dirY*dirY);
      dirX /= distLeft;
      dirY /= distLeft;
      pos.x+=dirX*speed;
      pos.y+=dirY*speed;

      if (dist(pos.x, pos.y, target.x, target.y)<epsilon) {
        isHome=true;
        pos = target;
        _textSize = toBeta ? (int)betaTextSizeMax : (int)textSizeMin;
        col = toBeta ? 255 : (int)realB;
        if (toBeta) {
          if (betaPresent[betaIdx]) hidden = true;
          betaPresent[betaIdx] = true;
        }
      } else {
        if (toBeta) {
          _textSize = (int)map(distLeft, distToCover, 0, textSizeMin, textSizeMax);
          col = (int)map(distLeft, distToCover, 0, realB, 255);
          speed =max(alphaSpeedOffset+(int)map(distLeft, distToCover, 0, charSpeedMax, charSpeedMin), 2);
        } else {
          _textSize = (int)map(distLeft, distToCover, 0, textSizeMax, textSizeMin);
          col = (int)map(distLeft, distToCover, 0, 255, realB);
          speed = max(betaSpeedOffset +quadraticMap(distLeft, distToCover, 0, charSpeedMin, charSpeedMax), 0); //Looks a bit better than linear map
        }
      }
    }
  }

  //Map "in" from [A,B] quadratically to [a,b]
  float quadraticMap(float in, float A, float B, float a, float b) {
    float mid = (B-A)/2;
    float x = in - mid;
    float s = 0.5;
    return min(s*x*x+a, b);
  }

  public void display() {
    if (!(mustFade && isHome) && !hidden) {
      fill(col);
      if (_textSize > 0) {
        textSize(_textSize);
      } else {
      }
      text(charac, pos.x, pos.y);
    }
  }
}

//Comparator implementation
class CharComp implements Comparator<Char> {
  // override the compare() method
  public int compare(Char c1, Char c2)
  {
    if (c1.b == c2.b)
      return 0;
    else if (c1.b > c2.b)
      return 1;
    else
      return -1;
  }
}
