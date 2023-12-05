import 'dart:math';

import 'package:advent_of_code/puzzle_input.dart';
import 'package:advent_of_code/puzzle_solver.dart';
import 'package:dartx/dartx.dart';

class Day04 implements PuzzleSolver {
  @override
  void solvePart1() {
    final lines = PuzzleInput.forDay(day: 4).asLines;

    final cards = lines.map(ScratchCard.fromLine);

    final totalScore = cards.sumBy((card) => card.pointValue);
    print(totalScore);
  }

  @override
  void solvePart2() {
    final lines = PuzzleInput.forDay(day: 4).asLines;

    final originalCards = lines.map(ScratchCard.fromLine).toList();
    final wonCardsById = <int, int>{};

    for (final card in originalCards) {
      final current = (wonCardsById[card.cardNumber] ?? 0) + 1;
      for (final wonCardId in card.wonCardCopies) {
        wonCardsById.update(
          wonCardId,
          (value) => value + current,
          ifAbsent: () => current,
        );
      }
    }

    print(originalCards.length + wonCardsById.values.sum());
  }
}

class ScratchCard {
  ScratchCard(this.cardNumber, this.winningNumbers, this.revealedNumbers);

  factory ScratchCard.fromLine(String line) {
    final split = line.split(':');
    final cardNumber = int.parse(split.first.removePrefix('Card '));
    final numbers = split.last.split('|');
    final winners = _parseNumbers(numbers.first);
    final revealed = _parseNumbers(numbers.last);

    return ScratchCard(cardNumber, winners, revealed);
  }

  int cardNumber;
  Set<int> winningNumbers;
  Set<int> revealedNumbers;

  Set<int> get winningMatches =>
      winningNumbers.intersection(revealedNumbers).toSet();
  int get winningMatchCount => winningMatches.length;
  int get pointValue =>
      winningMatchCount == 0 ? 0 : pow(2, winningMatchCount - 1).toInt();
  Set<int> get wonCardCopies => winningMatchCount == 0
      ? <int>{}
      : (cardNumber + 1).rangeTo(cardNumber + winningMatchCount).toSet();

  static Set<int> _parseNumbers(String numbers) => numbers
      .split(' ')
      .whereNot((e) => e.isBlank)
      .map((e) => e.toInt())
      .toSet();
}
