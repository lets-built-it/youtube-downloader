import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_downloader/bloc.dart';

class App extends StatefulWidget {
  const App({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _controller = TextEditingController();
  final _bloc = YoutubeDownloaderBloc();
  Video? video;
  StreamInfo? selectedStream;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (video != null)
                Text(
                  video!.title,
                  style: Theme.of(context).textTheme.headline6,
                ),
              const SizedBox(height: 20),
              if (video != null)
                Image.network(
                  video!.thumbnails.mediumResUrl,
                ),
              const SizedBox(height: 20),
              if (selectedStream != null)
                Text(
                  'Selected stream Quality : $selectedStream',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  isDense: true,
                  label: Text("Video URL"),
                ),
              ),
              TextButton(
                child: const Text("Get Video Info"),
                onPressed: () async {
                  video = await _bloc.getVideoInformation(
                    videoUrl: _controller.text,
                  );
                  setState(() {});
                },
              ),
              if (video != null)
                TextButton(
                  child: const Text("Download Video"),
                  onPressed: () async {
                    final manifest = await _bloc.getVideoManifest(
                      videoUrl: _controller.text,
                    );
                    await showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return ListView.builder(
                            itemCount: manifest.length,
                            itemBuilder: (context, index) {
                              final videoStreaminfo = manifest[index];
                              return RadioListTile<StreamInfo>(
                                value: videoStreaminfo,
                                groupValue: selectedStream,
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "Quality: ${videoStreaminfo.qualityLabel} "),
                                    Text("Size: ${videoStreaminfo.size}")
                                  ],
                                ),
                                subtitle: Text(
                                    "Resolution: ${videoStreaminfo.videoResolution}"),
                                onChanged: (StreamInfo? value) {
                                  setState(() {
                                    selectedStream = value;
                                  });
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          );
                        });
                    _bloc.saveFile(video!, selectedStream!);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
