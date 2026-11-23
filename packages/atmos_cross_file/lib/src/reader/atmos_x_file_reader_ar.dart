import '../x_files/atmos_x_file_ar.dart';
import 'atmos_x_file_reader.dart';

class AtmosXFileReaderAR extends AtmosXFileReader<AtmosXFileAR> {
  const AtmosXFileReaderAR({
    required super.file,
    super.start = 0,
    super.end,
  });

  @override
  int get platformId => 0;
}
