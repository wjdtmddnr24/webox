import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/log.dart';
import 'package:sprintf/sprintf.dart';
import 'package:webox/models/block.dart';
import 'package:webox/models/record.dart';
import 'package:webox/utils/camera.dart';

// FlutterFFmpeg flutterFFmpeg = new FlutterFFmpeg();

// Future<int> createVideo(
//     {required String sourcePath,
//     required String outputPath,
//     required frameCount}) async {
//   final resultCode = await flutterFFmpeg.execute(
//       '-hide_banner -f image2 -y -r $frameCount -pattern_type sequence -i \"$sourcePath\" \"$outputPath\"');
//   return resultCode;
// }

Future<int> createVideoFromBlock(Record record, Block block) async {
  // if (block.status == BlockStatus.VideoCreating ||
  //     block.status == BlockStatus.VideoCreated) return -1;
  // block.status = BlockStatus.VideoCreating;
  final outputPath = '${await getRecordPath(record)}/block_${sprintf('%04d', [
        block.offset ~/ 1000
      ])}.mp4';
  final sourcePath = '${await getRecordPath(record)}/frame_${sprintf('%04d', [
        block.offset ~/ 1000
      ])}_%04d.jpg';

  final frameCount = block.frames.length + 1;
  print('------------------ creating video of block ${block.offset}');
  final completer = Completer<int>();
  await FFmpegKit.executeAsync(
      '-hide_banner -loglevel error -y -f image2 -framerate $frameCount -i \"$sourcePath\" -preset veryfast -vf \"transpose=1\" \"$outputPath\"',
      (session) async {
    final returnCode = (await session.getReturnCode())!.getValue();
    print('block ${block.offset} ffmpeg returned code: $returnCode');
    completer.complete(returnCode);
  }, (Log log) {
    print('log block ${block.offset} ${log.getMessage()}');
  });

  final resultCode = await completer.future;

  print('------------------ created video of block ${block.offset}');
  block.status = BlockStatus.VideoCreated;
  block.path = outputPath;
  return resultCode;
}

// Future<int> concatVideos(Record record) async {
//   final outputPath = '${await getRecordPath(record)}/result.mp4';
//   final String files = record.blocks
//       .where((element) => element.path != null)
//       .fold(
//           '',
//           (previousValue, element) =>
//               previousValue + 'file \'${element.path}\'\n');
//   print(files);
//   final filePath = '${await getRecordPath(record)}/files.txt';
//
//   await File(filePath).writeAsString(files);
//   print('------------------ concat start!');
//   final resultCode = await flutterFFmpeg.execute(
//       '-hide_banner -loglevel error -y -f concat -safe 0 -i \"$filePath\" \"$outputPath\"');
//   print('------------------ concat done!');
//   return resultCode;
// }
