import 'dart:isolate';

import 'package:advent_of_code/puzzle_input.dart';
import 'package:advent_of_code/puzzle_solver.dart';
import 'package:dartx/dartx.dart';

class Day08 implements PuzzleSolver {
  @override
  void solvePart1() {
    final document = readDocument(PuzzleInput.forDay(day: 8).asLines);

    final steps = followPath(
      document,
      'AAA',
      followInstruction,
      (currentNodeKey) => currentNodeKey == 'ZZZ',
    );

    print(steps);
  }

  @override
  void solvePart2() {
    final document = readDocument(PuzzleInput.forDay(day: 8).asLines);
    final startingNodeKeys =
        document.network.filterKeys((key) => key.endsWith('A')).keys;

    startingNodeKeys
        .asStream()
        .asyncMap(
          (key) => Isolate.run(
            () => followPath(
              document,
              key,
              followInstruction,
              (currentNodeKey) => currentNodeKey.endsWith('Z'),
            ),
          ),
        )
        .reduce((sum, stepCount) => sum *= stepCount ~/ sum.gcd(stepCount))
        .then(print);
  }

  int followPath(
    Document document,
    String startingNodeKey,
    String Function(Document document, int currentStep, String currentNodeKey)
        nextInstruction,
    bool Function(String currentNodeKey) stopCondition,
  ) {
    var currentStep = 0;
    var currentNodeKey = startingNodeKey;

    do {
      currentNodeKey = nextInstruction(document, currentStep++, currentNodeKey);
    } while (!stopCondition(currentNodeKey));

    return currentStep;
  }

  String followInstruction(
    Document document,
    int currentInstructionIndex,
    String currentNodeKey,
  ) {
    final instruction = document
        .instructions[currentInstructionIndex % document.instructions.length];
    return document.network[currentNodeKey]!.traverseInDirection(instruction);
  }

  Document readDocument(List<String> lines) {
    final instructions =
        lines.first.characters.map(Direction.fromCharacter).toList();

    ({String key, NetworkNode node}) parseNodeLine(String line) {
      final parts = line.split(' = ');
      final key = parts.first;
      final networkNodeMatcher = RegExp(r'\((\w+), (\w+)\)');
      final matches = networkNodeMatcher.allMatches(parts.last);
      final left = matches.first.group(1)!;
      final right = matches.first.group(2)!;

      return (key: key, node: NetworkNode(left: left, right: right));
    }

    final network = lines
        .skip(2)
        .map(parseNodeLine)
        .associate((e) => MapEntry(e.key, e.node));

    return (instructions: instructions, network: network);
  }
}

typedef Document = ({List<Direction> instructions, Network network});

typedef Network = Map<String, NetworkNode>;

class NetworkNode {
  const NetworkNode({
    required this.left,
    required this.right,
  });

  final String left;
  final String right;

  String traverseInDirection(Direction direction) =>
      direction == Direction.left ? left : right;
}

enum Direction {
  left('L'),
  right('R');

  const Direction(this.value);

  factory Direction.fromCharacter(String character) =>
      Direction.values.singleWhere((e) => e.value == character);

  final String value;
}
