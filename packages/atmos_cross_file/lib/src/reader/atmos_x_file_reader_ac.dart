import '../x_files/atmos_x_file_ac.dart';
import 'atmos_x_file_reader.dart';

class AtmosXFileReaderAC extends AtmosXFileReader<AtmosXFileAC> {
  const AtmosXFileReaderAC({
    required super.file,
    super.start = 0,
    super.end,
  });

  @override
  int get platformId => 0;
}
