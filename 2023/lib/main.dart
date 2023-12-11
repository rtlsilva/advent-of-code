import 'package:advent_of_code/solutions/solution_index.dart';

final days = [
  Day01(),
  Day02(),
  Day03(),
  Day04(),
  Day05(),
  Day06(),
  Day07(),
  Day08(),
];

void main() {
  days.last.solvePart1();
  days.last.solvePart2();
}
