import 'dart:math';

import 'package:advent_of_code/puzzle_input.dart';
import 'package:advent_of_code/puzzle_solver.dart';
import 'package:dartx/dartx.dart';

class Day05 implements PuzzleSolver {
  @override
  void solvePart1() {
    final input = PuzzleInput.forDay(day: 5);
    final almanac = Almanac.fromPuzzleInput(input);
    final lowestLocationNumber =
        almanac.seeds.map(almanac.seedToLocation).min();

    print(lowestLocationNumber);
  }

  @override
  void solvePart2() {
    final input = PuzzleInput.forDay(day: 5);
    final almanac = Almanac.fromPuzzleInput(input);
    final seedRanges = almanac.seeds
        .windowed(2, step: 2)
        .map((e) => IntRange(e[0], e[0] + e[1] - 1));
    final lowestLocationNumber = almanac.findLocationFromSeedRanges(seedRanges);

    print(lowestLocationNumber);
  }
}

class Almanac {
  const Almanac({
    required this.seeds,
    required this.seedToSoil,
    required this.soilToFertilizer,
    required this.fertilizerToWater,
    required this.waterToLight,
    required this.lightToTemperature,
    required this.temperatureToHumidity,
    required this.humidityToLocation,
  });

  factory Almanac.fromPuzzleInput(PuzzleInput input) {
    final lines = input.asLines;

    final seeds =
        lines.first.split(':').last.trim().split(' ').map(int.parse).toSet();

    final seedToSoil = <AlmanacMapping>[];
    final soilToFertilizer = <AlmanacMapping>[];
    final fertilizerToWater = <AlmanacMapping>[];
    final waterToLight = <AlmanacMapping>[];
    final lightToTemperature = <AlmanacMapping>[];
    final temperatureToHumidity = <AlmanacMapping>[];
    final humidityToLocation = <AlmanacMapping>[];

    void createMapping(
      List<AlmanacMapping> destination,
      int index,
      List<String> input,
    ) {
      for (var nextIndex = index + 1;
          nextIndex < lines.length && lines[nextIndex].isNotEmpty;
          nextIndex++) {
        destination.add(AlmanacMapping.fromLine(lines[nextIndex]));
      }
    }

    for (final (index, line) in lines.indexed) {
      if (line.startsWith('seed-to-soil map:')) {
        createMapping(seedToSoil, index, lines);
      } else if (line.startsWith('soil-to-fertilizer map:')) {
        createMapping(soilToFertilizer, index, lines);
      } else if (line.startsWith('fertilizer-to-water map:')) {
        createMapping(fertilizerToWater, index, lines);
      } else if (line.startsWith('water-to-light map:')) {
        createMapping(waterToLight, index, lines);
      } else if (line.startsWith('light-to-temperature map:')) {
        createMapping(lightToTemperature, index, lines);
      } else if (line.startsWith('temperature-to-humidity map:')) {
        createMapping(temperatureToHumidity, index, lines);
      } else if (line.startsWith('humidity-to-location map:')) {
        createMapping(humidityToLocation, index, lines);
      }
    }

    return Almanac(
      seeds: seeds,
      seedToSoil: seedToSoil,
      soilToFertilizer: soilToFertilizer,
      fertilizerToWater: fertilizerToWater,
      waterToLight: waterToLight,
      lightToTemperature: lightToTemperature,
      temperatureToHumidity: temperatureToHumidity,
      humidityToLocation: humidityToLocation,
    );
  }

  final Set<int> seeds;
  final List<AlmanacMapping> seedToSoil;
  final List<AlmanacMapping> soilToFertilizer;
  final List<AlmanacMapping> fertilizerToWater;
  final List<AlmanacMapping> waterToLight;
  final List<AlmanacMapping> lightToTemperature;
  final List<AlmanacMapping> temperatureToHumidity;
  final List<AlmanacMapping> humidityToLocation;

  List<List<AlmanacMapping>> get allMaps => [
        seedToSoil,
        soilToFertilizer,
        fertilizerToWater,
        waterToLight,
        lightToTemperature,
        temperatureToHumidity,
        humidityToLocation,
      ];

  int sourceToDestination(int source, List<AlmanacMapping> destinationMap) =>
      destinationMap
          .firstOrNullWhere(
            (mapping) => mapping.containsSource(source),
          )
          ?.sourceToDestination(source) ??
      source;

  int destinationToSource(int destination, List<AlmanacMapping> sourceMap) =>
      sourceMap
          .firstOrNullWhere(
            (mapping) => mapping.containsDestination(destination),
          )
          ?.destinationToSource(destination) ??
      destination;

  int seedToLocation(int seed) {
    final soil = sourceToDestination(seed, seedToSoil);
    final fertilizer = sourceToDestination(soil, soilToFertilizer);
    final water = sourceToDestination(fertilizer, fertilizerToWater);
    final light = sourceToDestination(water, waterToLight);
    final temperature = sourceToDestination(light, lightToTemperature);
    final humidity = sourceToDestination(temperature, temperatureToHumidity);
    final location = sourceToDestination(humidity, humidityToLocation);

    return location;
  }

  int locationToSeed(int location) {
    final humidity = destinationToSource(location, humidityToLocation);
    final temperature = destinationToSource(humidity, temperatureToHumidity);
    final light = destinationToSource(temperature, lightToTemperature);
    final water = destinationToSource(light, waterToLight);
    final fertilizer = destinationToSource(water, fertilizerToWater);
    final soil = destinationToSource(fertilizer, soilToFertilizer);
    final seed = destinationToSource(soil, seedToSoil);

    return seed;
  }

  int findLocationFromSeedRanges(Iterable<IntRange> seedRanges) {
    var minValue = 0x7fffffffffffffff;

    for (final seed in seedRanges) {
      final start = seed.start;
      final end = seed.endInclusive;

      for (var seedValue = start; seedValue <= end; seedValue++) {
        var value = seedValue;
        var skipCount = 0x7fffffffffffffff;

        for (final ranges in allMaps) {
          for (final range in ranges) {
            if (range.sourceRange.contains(value)) {
              skipCount = min(
                range.sourceRange.endInclusive - value,
                skipCount,
              );
              value += range.destinationRangeStart - range.sourceRangeStart;
              break;
            }
          }
        }
        if (value > minValue &&
            skipCount != 0x7fffffffffffffff &&
            skipCount > 0) {
          seedValue += skipCount;
        }
        minValue = min(minValue, value);
      }
    }

    return minValue;
  }
}

class AlmanacMapping {
  const AlmanacMapping({
    required this.sourceRangeStart,
    required this.destinationRangeStart,
    required this.rangeLength,
  });

  factory AlmanacMapping.fromLine(String line) {
    final numbers = line.split(' ');

    return AlmanacMapping(
      destinationRangeStart: int.parse(numbers[0]),
      sourceRangeStart: int.parse(numbers[1]),
      rangeLength: int.parse(numbers[2]),
    );
  }

  final int destinationRangeStart;
  final int sourceRangeStart;
  final int rangeLength;

  IntRange get destinationRange =>
      IntRange(destinationRangeStart, destinationRangeStart + rangeLength - 1);

  IntRange get sourceRange =>
      IntRange(sourceRangeStart, sourceRangeStart + rangeLength - 1);

  bool containsSource(int source) => sourceRange.contains(source);

  bool containsDestination(int destination) =>
      destinationRange.contains(destination);

  int sourceToDestination(int source) =>
      source - sourceRangeStart + destinationRangeStart;

  int destinationToSource(int destination) =>
      destination - destinationRangeStart + sourceRangeStart;
}
