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
  final pct = (lhTotal / lfTotal * 100).toStringAsFixed(2);
  print('Coverage total: $lhTotal/$lfTotal ($pct%)');
}
