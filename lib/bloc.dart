import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeDownloaderBloc {
  final _ytExplode = YoutubeExplode();
  // final _downloadSubject =

  Future<List<VideoStreamInfo>> getVideoManifest(
      {required String videoUrl}) async {
    final manifest =
        await _ytExplode.videos.streamsClient.getManifest(videoUrl);
    return manifest.muxed.sortByVideoQuality();
  }

  Future<Video> getVideoInformation({required String videoUrl}) async {
    final video = await _ytExplode.videos.get(videoUrl);

    return video;
  }

  Future<void> saveFile(Video video, StreamInfo streamInfo) async {
    final stream = _ytExplode.videos.streamsClient.get(streamInfo);

    final directory = await getApplicationDocumentsDirectory();

    final filePath =
        "${directory.path}/${video.title}.${streamInfo.codec.subtype}";

    final file = File(filePath);
    final fileStream = file.openWrite();
    await stream.pipe(fileStream);
    fileStream.flush();
    fileStream.close();
    await GallerySaver.saveVideo(file.path);
    file.deleteSync();
  }

  void dispose() {}
}
