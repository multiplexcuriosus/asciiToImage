//For char pixel density analysis, create ArrayList<Char> with all Chars from string
ArrayList<Char> createChars(String input) {
  fill(0);
  textSize(500);
  ArrayList<Char> res = new ArrayList<Char>();
  for (int i = 0; i<input.length(); i++) {
    char c = input.charAt(i);
    text(c, width*0.1, height*0.8);
    float b = getB();
    res.add(new Char(c, b));
    background(255);
  }
  return res;
}

float getB() { //calculate average brightness of all pixels inside canvas
  float res = 0;
  for (int x = 0; x<width; x++) {
    for (int y = 0; y<height; y++) {
      color col = get(x, y);
      res += brightness(col);
    }
  }
  return res/width/height;
}

// SMALL FUNCTIONS --------------------------------------------------------------------------------

void printArr(boolean[] arr) {
  for (int i = 0; i<arr.length; i++) {
    print(arr[i] + " ");
  }
  println();
}

// STRING OPERATIONS --------------------------------------------------------------------------------
String getIntersection(String A, String B) {
  String res = "";

  for (int i = 0; i<A.length(); i++) {
    for (int j = 0; j<B.length(); j++) {
      if (A.charAt(i) == B.charAt(j)) {
        char c = A.charAt(i);
        if (!contains(res, c)) res+=c;
      }
    }
  }
  return res;
}

//return true if list of chars contains chars, false if not
boolean contains(ArrayList<Char> list, Char _c) {
  for (Char c : list) {
    if (c.charac == _c.charac) return true;
  }
  return false;
}

//return true if String contains chars, false if not
boolean contains(String str, char _c) {
  for (int i = 0; i<str.length(); i++) {
    if (str.charAt(i) == _c) return true;
  }
  return false;
}
String getBWithoutA(String inter, String B) {
  String res = "";
  for (int i = 0; i<B.length(); i++) {
    char c = B.charAt(i);
    if (!contains(inter, c)) {
      if (!contains(res, c)) res+=c;
    }
  }
  return res;
}


boolean isSpecial(char c) {
  String special = "?!;:+=-,._ ";
  for (int i = 0; i<special.length(); i++) {
    if (special.charAt(i) == c) return true;
  }
  return false;
}

int getSentenceIndex(char c, String sentence) {
  for (int i = 0; i<sentence.length(); i++) {
    if (sentence.charAt(i) == c) {
      return i;
    }
  }
  return -17;
}

//Load content from text file into an ArrayList<String> and return it
ArrayList<String> readFile() {
  ArrayList<String> res = new ArrayList<String>();
  try
  {
    //the file to be opened for reading
    FileInputStream fis=new FileInputStream(textFilePath);
    Scanner sc=new Scanner(fis);    //file to be scanned
    //returns true if there is another line to read
    while (sc.hasNextLine())
    {
      res.add(sc.nextLine());
    }
    sc.close();     //closes the scanner
  }
  catch(IOException e)
  {
    e.printStackTrace();
  }
  return res;
}

int getMaxLength(ArrayList<String> strings) {
  int len = -1;
  for (int i = 0; i<strings.size(); i++) {
    if (strings.get(i).length() > len) len = strings.get(i).length();
  }
  return len;
}

String concatStrings(ArrayList<String> strings) {
  String res = "";
  for (int i = 0; i<strings.size(); i++)res+=strings.get(i);
  return res;
}

//CHAR UTILS ------------------------------------------------------------------------------------------------------------
ArrayList<Char> getSentence(PVector start) {
  ArrayList<Char> res = new ArrayList<Char>();
  for (int i = 0; i<alpha.length(); i++) {
    char c = alpha.charAt(i);
    float x = start.x + i*15;
    res.add(new Char(c, new PVector(x, start.y)));
  }
  return res;
}

//Pixel density analysis -------------------------------------------------------------------------------------------------
void analyze_chars() {
  //Turn each character in alpha into a custom Char object which carries its relative brightness as member function
  chars = createChars(alphabet);
  //Sort elements of chars by descending brightness
  Collections.sort(chars, new CharComp());
  //Remove all duplicates
  chars = removeDuplicates(chars);
}

// Function to remove duplicates from an ArrayList
ArrayList<Char> removeDuplicates(ArrayList<Char> list) {
  ArrayList<Char> newList = new ArrayList<Char>();
  for (Char element : list) {
    if (!contains(newList, element)) {
      newList.add(element);
    }
  }
  return newList;
}

//Create pixars -------------------------------------------------------------------------------------------------------------
void createPixars(int num) {

  //Draw image
  img.resize(0, height);
  background(0);
  imageMode(CENTER);
  image(img, width/2, height/2);
  filter(GRAY);

  //Prepare betachars
  String AinterB = "";
  if (mono) {
    AinterB = getIntersection(alpha, beta); //<-- MONO VS NON-MONO!!!
  } else {
    for (int i = 0; i<text.size(); i++) {
      AinterB += getIntersection(text.get(i), beta);
    }
  }

  //For all points on N by N grid find best fitting Char and add all of these chars to ArrayList<Char> pixars
  float step = width/num;
  for (int x = 0; x<width; x+=step) {
    for (int y = 0; y<height; y+=step) {
      color col = get(x, y);
      float b = brightness(col);
      if (b > 0) {
        int r = (int)map(b, 0, 254, chars.size()-1, 0);
        char bestChar = chars.get(r).charac;
        Char newChar = new Char(bestChar, new PVector(x, y));
        newChar.setTarget(new PVector(x, y));
        newChar.setRealCol(col);
        if (contains(AinterB, bestChar)) {
          newChar.setInBeta(true);
        }
        pixars.add(newChar);
      }
    }
  }
  background(0);
}
