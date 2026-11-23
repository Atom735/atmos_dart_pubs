import '../x_files/atmos_x_file_ram.dart';
import 'atmos_x_file_reader.dart';


class AtmosXFileReaderRam extends AtmosXFileReader<AtmosXFileRam> {
  const AtmosXFileReaderRam({
    required super.file,
    super.start = 0,
    super.end,
  });

  @override
  int get platformId => 0;
}
