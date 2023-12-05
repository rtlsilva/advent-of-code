import 'package:advent_of_code/puzzle_input.dart';
import 'package:advent_of_code/puzzle_solver.dart';
import 'package:dartx/dartx.dart';

class Day01 implements PuzzleSolver {
  @override
  void solvePart1() {
    final lines = PuzzleInput.forDay(day: 1).asLines;
    final calibrationValues = <int>[];

    for (final line in lines) {
      final firstDigit = line.iterable().firstWhere((c) => c.isInt);
      final lastDigit = line.iterable().lastWhere((c) => c.isInt);
      final calibrationValue = int.parse('$firstDigit$lastDigit');
      calibrationValues.add(calibrationValue);
    }

    final result =
        calibrationValues.reduce((value, element) => value + element);

    print(result);
  }

  @override
  void solvePart2() {
    final lines = PuzzleInput.forDay(day: 1).asLines;
    final calibrationValues = <int>[];

    const candidates = {
      'one': '1',
      'two': '2',
      'three': '3',
      'four': '4',
      'five': '5',
      'six': '6',
      'seven': '7',
      'eight': '8',
      'nine': '9',
    };

    const overlaps = {
      'oneight': 'oneeight',
      'twone': 'twoone',
      'threeight': 'threeeight',
      'fiveight': 'fiveeight',
      'sevenine': 'sevennine',
      'eightwo': 'eighttwo',
      'eighthree': 'eightthree',
      'nineight': 'nineeight',
    };

    String remapDigits(String line) {
      var result = line;
      var minIndex = line.length;
      var maxIndex = -1;
      var minCardinal = '';
      var maxCardinal = '';

      // remove overlaps
      for (final overlap in overlaps.entries) {
        result = result.replaceAll(overlap.key, overlap.value);
      }

      for (final MapEntry(key: cardinal, value: _) in candidates.entries) {
        final firstIndex = result.indexOf(cardinal);
        final lastIndex = result.lastIndexOf(cardinal);
        if (firstIndex != -1 && firstIndex < minIndex) {
          minIndex = firstIndex;
          minCardinal = cardinal;
        }
        if (lastIndex != -1 && lastIndex > maxIndex) {
          maxIndex = lastIndex;
          maxCardinal = cardinal;
        }
      }

      if (candidates[minCardinal] != null) {
        result = result.replaceAll(minCardinal, candidates[minCardinal]!);
      }

      if (candidates[maxCardinal] != null) {
        result = result.replaceAll(maxCardinal, candidates[maxCardinal]!);
      }

      return result;
    }

    for (final line in lines) {
      final remappedLine = remapDigits(line);
      final firstDigit = remappedLine.iterable().firstWhere((c) => c.isInt);
      final lastDigit = remappedLine.iterable().lastWhere((c) => c.isInt);
      final calibrationValue = int.parse('$firstDigit$lastDigit');
      calibrationValues.add(calibrationValue);
      print('$line -> $remappedLine -> $calibrationValue');
    }

    final result =
        calibrationValues.reduce((value, element) => value + element);

    print(result);
  }
}

extension on String {
  Iterable<String> iterable() sync* {
    for (var i = 0; i < length; i++) {
      yield this[i];
    }
  }
}
