# AsciiToImage
<img src="https://github.com/user-attachments/assets/cfac52ed-3a00-4357-91eb-d1dd72840c3e" width=50% height=50%>

Animate letters into an image! And let the letters collapse again into a text.

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
