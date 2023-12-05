import 'dart:io';

const _year = 2023;
const _inputFolder = 'inputs';
const _inputFilePrefix = 'day';
const _inputFileExtension = '.txt';

class PuzzleInput {
  PuzzleInput.forDay({required int day, int year = _year})
      : this.fromFilePath(
          inputFilePath: _createInputPath(
            day: day,
            year: year,
          ),
        );

  PuzzleInput.fromFilePath({required String inputFilePath})
      : _input = _loadInputFileAsString(inputFilePath),
        _inputAsLines = _loadInputFileAsLines(inputFilePath);

  PuzzleInput.fromMultilineString({required String input})
      : _input = input,
        _inputAsLines = input.split('\n');

  final String _input;
  final List<String> _inputAsLines;

  String get asString => _input;
  List<String> get asLines => _inputAsLines;

  static String _loadInputFileAsString(String inputFilePath) {
    return File(inputFilePath).readAsStringSync();
  }

  static List<String> _loadInputFileAsLines(String inputFilePath) {
    return File(inputFilePath).readAsLinesSync();
  }

  static String _createInputPath({required int day, int year = _year}) {
    final dayString = day.toString().padLeft(2, '0');
    return '$_inputFolder/$year/$_inputFilePrefix$dayString$_inputFileExtension';
  }
}
