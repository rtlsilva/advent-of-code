import 'package:advent_of_code/puzzle_input.dart';
import 'package:advent_of_code/puzzle_solver.dart';
import 'package:dartx/dartx.dart';

class Day07 implements PuzzleSolver {
  @override
  void solvePart1() {
    final lines = PuzzleInput.forDay(day: 7).asLines;
    final hands = parseHands(lines);
    final totalWinnings = calculateTotalWinnings(hands);
    print(totalWinnings);
  }

  @override
  void solvePart2() {
    final lines = PuzzleInput.forDay(day: 7).asLines;
    final hands = parseHands(lines, enableJokers: true);
    final totalWinnings = calculateTotalWinnings(hands);
    print(totalWinnings);
  }
}

Iterable<Hand> parseHands(Iterable<String> lines, {bool enableJokers = false}) {
  return lines.map((line) {
    final [hand, bid] = line.split(' ');
    final cards = hand
        .split('')
        .map((l) => CamelCardRank.fromLabel(l, enableJokers: enableJokers))
        .toList();
    return (hand: cards, type: HandType.fromCards(cards), bid: bid.toInt());
  });
}

int calculateTotalWinnings(Iterable<Hand> hands) {
  final sorted = hands.sortedWith(handComparator);

  final sum = sorted.indexed
      .map((e) => (handRank: e.$1, hand: e.$2))
      .sumBy((e) => (e.handRank + 1) * e.hand.bid);

  return sum;
}

int handComparator(Hand a, Hand b) {
  final handTypeComparison = a.type.value.compareTo(b.type.value);
  if (handTypeComparison != 0) return handTypeComparison;

  for (final cardPair in a.hand.zip(b.hand, (a, b) => (a: a, b: b))) {
    final cardPowerComparison = cardPair.a.power.compareTo(cardPair.b.power);
    if (cardPowerComparison != 0) return cardPowerComparison;
  }

  return 0;
}

typedef Hand = ({List<CamelCardRank> hand, HandType type, int bid});

enum HandType {
  highCard,
  onePair,
  twoPair,
  trips,
  fullHouse,
  quads,
  quints;

  factory HandType.fromCards(List<CamelCardRank> cards) {
    final cardCounts = <CamelCardRank, int>{};
    for (final card in cards) {
      cardCounts.update(
        card,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    final sorted =
        cardCounts.entries.sortedByDescending((entry) => entry.value);
    final mostCommonCard = sorted.first.key;
    final mostOccurrences = sorted.first.value;
    final second = sorted.elementAtOrNull(1);
    final secondMostOccurences = second?.value;
    final secondMostCommonCard = second?.key;

    final jokerCount = cardCounts[CamelCardRank.joker] ?? 0;

    late final HandType? jokerHandType;
    switch (jokerCount) {
      case 5:
      case 4:
      case 3 when secondMostOccurences == 2:
      case 2 when mostOccurrences == 3:
      case 1 when mostOccurrences == 4:
        jokerHandType = HandType.quints;
      case 3 when secondMostOccurences == 1:
      case 2 when mostOccurrences == 2 && mostCommonCard != CamelCardRank.joker:
      case 2
          when secondMostOccurences == 2 &&
              secondMostCommonCard != CamelCardRank.joker:
      case 1 when mostOccurrences == 3:
        jokerHandType = HandType.quads;
      case 1
          when mostOccurrences == 3 &&
              secondMostOccurences == 1 &&
              secondMostCommonCard != CamelCardRank.joker:
      case 1 when mostOccurrences == 2 && secondMostOccurences == 2:
        jokerHandType = HandType.fullHouse;
      case 1 when mostOccurrences == 2:
      case 2 when secondMostOccurences == 1:
        jokerHandType = HandType.trips;
      case 1 when mostOccurrences == 1 && mostCommonCard != CamelCardRank.joker:
      case 1
          when secondMostOccurences == 1 &&
              secondMostCommonCard != CamelCardRank.joker:
        jokerHandType = HandType.onePair;
      default:
        jokerHandType = null;
    }

    if (jokerHandType != null) return jokerHandType;

    return switch (mostOccurrences) {
      5 => HandType.quints,
      4 => HandType.quads,
      3 when secondMostOccurences == 2 => HandType.fullHouse,
      3 => HandType.trips,
      2 when secondMostOccurences == 2 => HandType.twoPair,
      2 => HandType.onePair,
      _ => HandType.highCard,
    };
  }

  int get value => index;
}

enum CamelCardRank {
  ace(14, 'A'),
  deuce(2, '2'),
  trey(3, '3'),
  four(4, '4'),
  five(5, '5'),
  six(6, '6'),
  seven(7, '7'),
  eight(8, '8'),
  nine(9, '9'),
  ten(10, 'T'),
  jack(11, 'J'),
  queen(12, 'Q'),
  king(13, 'K'),
  joker(1, 'J');

  const CamelCardRank(this.power, this.label);

  factory CamelCardRank.fromPower(int power) {
    assert(
      power.between(
        CamelCardRank.values.firstIndex,
        CamelCardRank.values.lastIndex,
      ),
      'No rank corresponds to given power',
    );

    return CamelCardRank.values.singleWhere((rank) => rank.power == power);
  }

  factory CamelCardRank.fromLabel(String label, {bool enableJokers = false}) {
    if (label == 'J') {
      return enableJokers ? CamelCardRank.joker : CamelCardRank.jack;
    }

    return CamelCardRank.values.singleWhere((rank) => rank.label == label);
  }

  final int power;
  final String label;
}
