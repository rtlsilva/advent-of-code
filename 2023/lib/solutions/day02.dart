import 'dart:math';

import 'package:advent_of_code/puzzle_input.dart';
import 'package:advent_of_code/puzzle_solver.dart';

class Day02 implements PuzzleSolver {
  @override
  void solvePart1() {
    final lines = PuzzleInput.forDay(day: 2).asLines;
    final games = <Game>[];

    for (final line in lines) {
      final game = Game.fromLine(line);
      games.add(game);
    }

    final sum = games.fold(
      0,
      (previousValue, game) =>
          game.isPossible ? previousValue + game.id : previousValue,
    );

    print(sum);
  }

  @override
  void solvePart2() {
    final lines = PuzzleInput.forDay(day: 2).asLines;
    final games = <Game>[];

    for (final line in lines) {
      final game = Game.fromLine(line);
      games.add(game);
    }

    final sum = games.fold(
      0,
      (previousValue, game) => previousValue + game.power,
    );

    print(sum);
  }
}

enum Color { red, green, blue }

class Game {
  Game(this.id, this.amounts, this.minimumSet, {required this.isPossible});

  factory Game.fromLine(String line) {
    final splits = line.split(':').map((e) => e.trim());
    final gameId = int.parse(splits.first.replaceFirst('Game ', ''));
    final gameRounds = splits.skip(1).single.split(';').map((e) => e.trim());
    final amounts = <Color, int>{};
    final minimumSet = <Color, int>{};
    var isPossible = true;

    for (final round in gameRounds) {
      final subsets = round.split(',').map((e) => e.trim());
      for (final subset in subsets) {
        final color =
            Color.values.firstWhere((v) => v.name == subset.split(' ').last);
        final amount = int.parse(subset.split(' ').first);
        amounts.update(
          color,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
        minimumSet.update(
          color,
          (value) => max(value, amount),
          ifAbsent: () => amount,
        );
        if (isPossible) isPossible = bag[color]! >= amount;
      }
    }

    print('$gameId -> $minimumSet');

    return Game(gameId, amounts, minimumSet, isPossible: isPossible);
  }

  static const bag = {
    Color.red: 12,
    Color.green: 13,
    Color.blue: 14,
  };

  int id;
  Map<Color, int> amounts;
  Map<Color, int> minimumSet;
  bool isPossible;

  int get power =>
      minimumSet.values.reduce((value, element) => value * element);
}
