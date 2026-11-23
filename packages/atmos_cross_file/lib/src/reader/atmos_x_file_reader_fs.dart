import '../x_files/atmos_x_file_fs.dart';
import 'atmos_x_file_reader.dart';

class AtmosXFileReaderFS extends AtmosXFileReader<AtmosXFileFS> {
  const AtmosXFileReaderFS({
    required super.file,
    super.start = 0,
    super.end,
  });

  @override
  int get platformId => 0;
}
