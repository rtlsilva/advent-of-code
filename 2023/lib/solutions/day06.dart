import 'dart:math';

import 'package:advent_of_code/puzzle_input.dart';
import 'package:advent_of_code/puzzle_solver.dart';
import 'package:dartx/dartx.dart';

class Day06 implements PuzzleSolver {
  @override
  void solvePart1() {
    final input = PuzzleInput.forDay(day: 6).asLines;
    final numberMatcher = RegExp(r'\d+');

    final raceDurations =
        numberMatcher.allMatches(input.first).map((e) => int.parse(e[0]!));
    final raceRecords =
        numberMatcher.allMatches(input.last).map((e) => int.parse(e[0]!));
    final races = raceDurations.zip(
      raceRecords,
      Race.new,
    );

    var total = 1;

    for (final race in races) {
      final runDistances = <int>[];
      for (var speed = 1; speed < race.duration; speed++) {
        runDistances.add(race.run(speed));
      }
      runDistances.removeWhere((runDistance) => runDistance <= race.record);
      total *= runDistances.length;
    }

    print(total);
  }

  @override
  void solvePart2() {
    final input = PuzzleInput.forDay(day: 6).asLines;
    final numberMatcher = RegExp(r'\d+');

    final raceDuration =
        numberMatcher.allMatches(input.first).map((e) => e[0]!).join().toInt();
    final raceRecord =
        numberMatcher.allMatches(input.last).map((e) => e[0]!).join().toInt();
    final bigRace = Race(raceDuration, raceRecord);

    final runDistances = <int>[];
    for (var speed = 1; speed < bigRace.duration; speed++) {
      runDistances.add(bigRace.run(speed));
    }
    runDistances.removeWhere((runDistance) => runDistance <= bigRace.record);

    print(runDistances.length);
  }
}

class Race {
  Race(this.duration, this.record);

  int duration;
  int record;

  static int runRace(int raceDuration, int heldDuration) =>
      heldDuration * (raceDuration - heldDuration);

  int run(int heldDuration) => heldDuration * (duration - heldDuration);
}
