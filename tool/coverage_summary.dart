import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('No coverage report found.');
    exitCode = 1;
    return;
  }
  var lfTotal = 0;
  var lhTotal = 0;
  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('LF:')) {
      lfTotal += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      lhTotal += int.parse(line.substring(3));
    }
  }
  if (lfTotal == 0) {
    print('No executable lines found.');
    return;
  }

  final coverage = lhTotal / lfTotal * 100;
  final pct = coverage.toStringAsFixed(2);
  print('Coverage total: $lhTotal/$lfTotal ($pct%)');

  final minEnv = Platform.environment['MIN_COVERAGE'];
  if (minEnv != null && minEnv.trim().isNotEmpty) {
    final minValue = double.tryParse(minEnv.trim());
    if (minValue == null) {
      stderr.writeln('Invalid MIN_COVERAGE value: "$minEnv".');
      exitCode = 1;
      return;
    }
    if (coverage + 1e-6 < minValue) {
      stderr.writeln(
        'Coverage $pct% is below required minimum of ${minValue.toStringAsFixed(2)}%.',
      );
      exitCode = 1;
    }
  }
}
