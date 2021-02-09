void generateLpsArray(String pattern, int patternLength, List<int> lpsList) {
  var longestPrefixSuffixLength = 0;
  lpsList[0] = 0;
  var i = 1;
  while (i < patternLength) {
    if (pattern[i] == pattern[longestPrefixSuffixLength]) {
      longestPrefixSuffixLength++;
      lpsList[i] = longestPrefixSuffixLength;
      i++;
    } else {
      if (longestPrefixSuffixLength != 0) {
        longestPrefixSuffixLength = lpsList[longestPrefixSuffixLength - 1];
      } else {
        lpsList[i] = longestPrefixSuffixLength;
        i++;
      }
    }
  }
}

bool kmpSearch(String pattern, String textToCheck) {
  var patternWasFound = false;
  var patternLength = pattern.length;
  var textLength = textToCheck.length;
  var lps = <int>[]..length = patternLength;
  generateLpsArray(pattern, patternLength, lps);
  var patternIndex = 0;
  var textIndex = 0;
  while (textIndex < textLength) {
    if (pattern[patternIndex] == textToCheck[textIndex]) {
      patternIndex++;
      textIndex++;
    }
    if (patternIndex == patternLength) {
      patternWasFound = true;
      patternIndex = lps[patternIndex - 1];
    } else if (textIndex < textLength &&
        pattern[patternIndex] != textToCheck[textIndex]) {
      if (patternIndex != 0) {
        patternIndex = lps[patternIndex - 1];
      } else {
        textIndex++;
      }
    }
  }
  return patternWasFound;
}

List<int> kmpSearchList(String pattern, String textToCheck) {
  List<int> foundIndexes = [];
  // var patternWasFound = false;
  var patternLength = pattern.length;
  var textLength = textToCheck.length;
  var lps = <int>[]..length = patternLength;
  generateLpsArray(pattern, patternLength, lps);
  var patternIndex = 0;
  var textIndex = 0;
  while (textIndex < textLength) {
    if (pattern[patternIndex] == textToCheck[textIndex]) {
      patternIndex++;
      textIndex++;
    }
    if (patternIndex == patternLength) {
      // patternWasFound = true;
      foundIndexes.add(textIndex - patternIndex);
      patternIndex = lps[patternIndex - 1];
    } else if (textIndex < textLength &&
        pattern[patternIndex] != textToCheck[textIndex]) {
      if (patternIndex != 0) {
        patternIndex = lps[patternIndex - 1];
      } else {
        textIndex++;
      }
    }
  }
  return foundIndexes;
}
