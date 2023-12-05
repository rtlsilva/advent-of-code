import 'package:advent_of_code/puzzle_input.dart';
import 'package:advent_of_code/puzzle_solver.dart';
import 'package:dartx/dartx.dart';

const directions = [
  [-1, -1],
  [-1, 0],
  [-1, 1],
  [0, -1],
  [0, 1],
  [1, -1],
  [1, 0],
  [1, 1],
];

final engineSchematic = PuzzleInput.forDay(day: 3).asLines;
final schematicNumbers = <SchematicNumber>{};
final partNumbers = <SchematicNumber>{};
final gears = <Gear>{};
final numberMatcher = RegExp(r'\d+');
final gearMatcher = RegExp(r'\*');

class Day03 implements PuzzleSolver {
  @override
  void solvePart1() {
    reset();
    extractSchematicNumbers();
    extractPartNumbers();
    print(partNumbers.sumBy((number) => number.number));
  }

  @override
  void solvePart2() {
    reset();
    extractSchematicNumbers();
    extractPartNumbers();
    extractGears();
    print(gears.sumBy((gear) => gear.gearRatio));
  }
}

Set<SchematicNumber> extractSchematicNumbers() {
  for (final (row, line) in engineSchematic.indexed) {
    final matches = numberMatcher.allMatches(line);
    for (final match in matches) {
      final number = SchematicNumber(
        row,
        match.start,
        match.end - 1,
        int.parse(match[0]!),
      );
      schematicNumbers.add(number);
    }
  }

  return schematicNumbers;
}

Set<SchematicNumber> extractPartNumbers() {
  for (final number in schematicNumbers) {
    for (final numberColumn in number.columns) {
      checkNeighbors(
        number.row,
        numberColumn,
        (element) => !element.isInt && element != '.',
        (_, __) => partNumbers.add(number),
      );
    }
  }

  return partNumbers;
}

void extractGears() {
  for (final (row, line) in engineSchematic.indexed) {
    final matches = gearMatcher.allMatches(line);
    for (final match in matches) {
      final adjacentPartNumbers = <SchematicNumber>{};
      checkNeighbors(
        row,
        match.start,
        (element) => element.isInt,
        (matchRow, matchColumn) {
          final matchPartNumber = partNumbers.singleWhere(
            (number) =>
                number.row == matchRow && number.columns.contains(matchColumn),
          );
          adjacentPartNumbers.add(matchPartNumber);
        },
      );

      if (adjacentPartNumbers.length == 2) {
        gears.add(Gear(row, match.start, adjacentPartNumbers));
      }
    }
  }
}

void checkNeighbors(
  int row,
  int column,
  bool Function(String neighbor) test,
  void Function(int matchRow, int matchColumn) onMatch,
) {
  for (final direction in directions) {
    final testRow = row + direction[1];
    final testColumn = column + direction[0];

    if (testRow.between(0, engineSchematic.length - 1) &&
        testColumn.between(0, engineSchematic[testRow].length - 1)) {
      final testElement = engineSchematic[testRow][testColumn];

      if (test(testElement)) {
        onMatch(testRow, testColumn);
      }
    }
  }
}

void reset() {
  schematicNumbers.clear();
  partNumbers.clear();
  gears.clear();
}

class SchematicNumber {
  SchematicNumber(this.row, this.startColumn, this.endColumn, this.number);

  int row;
  int startColumn;
  int endColumn;
  int number;

  IntRange get columns => startColumn.rangeTo(endColumn);

  @override
  String toString() {
    return '$row:[$startColumn - $endColumn] = $number';
  }
}

class Gear {
  Gear(this.row, this.column, this.adjacentPartNumbers);

  int row;
  int column;

  Set<SchematicNumber> adjacentPartNumbers;

  int get gearRatio => adjacentPartNumbers
      .map((partNumber) => partNumber.number)
      .reduce((previousValue, element) => previousValue * element);
}
