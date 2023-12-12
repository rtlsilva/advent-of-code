import 'package:advent_of_code/puzzle_input.dart';
import 'package:advent_of_code/puzzle_solver.dart';
import 'package:dartx/dartx.dart';

class Day09 implements PuzzleSolver {
  @override
  void solvePart1() {
    final lines = PuzzleInput.forDay(day: 9).asLines;
    final histories =
        lines.map((line) => line.split(' ').map(int.parse).toList()).toList();

    var sum = 0;

    for (final history in histories) {
      final extrapolations = extrapolate(history);
      extrapolations.last.add(0);

      for (final extrapolationPair in extrapolations.reversed.windowed(2)) {
        final currentLine = extrapolationPair.last;
        final previousLine = extrapolationPair.first;
        currentLine.add(currentLine.last + previousLine.last);
      }

      sum += extrapolations.first.last;
    }

    print(sum);
  }

  @override
  void solvePart2() {
    final lines = PuzzleInput.forDay(day: 9).asLines;
    final histories =
        lines.map((line) => line.split(' ').map(int.parse).toList()).toList();

    var sum = 0;

    for (final history in histories) {
      final extrapolations = extrapolate(history);
      extrapolations.last.insert(0, 0);

      for (final extrapolationPair in extrapolations.reversed.windowed(2)) {
        final currentLine = extrapolationPair.last;
        final previousLine = extrapolationPair.first;
        currentLine.insert(0, currentLine.first - previousLine.first);
      }

      sum += extrapolations.first.first;
    }

    print(sum);
  }

  List<List<int>> extrapolate(List<int> history) {
    final extrapolations = [history];
    var sequence = extrapolations[0];

    do {
      sequence = sequence.windowed(2).map((e) => e.last - e.first).toList();
      extrapolations.add(sequence);
    } while (sequence.any((element) => element != 0));

    return extrapolations;
  }
}
