class WordCounter {
  static final RegExp _latinWord = RegExp(r"[A-Za-z0-9]+(?:['’-][A-Za-z0-9]+)*");
  static final RegExp _hanCharacter = RegExp(r'[\u3400-\u9fff]');

  static int count(String text) =>
      _latinWord.allMatches(text).length + _hanCharacter.allMatches(text).length;
}
