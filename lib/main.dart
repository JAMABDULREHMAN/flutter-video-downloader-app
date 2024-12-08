import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const VideoDownloaderApp());
}

class VideoDownloaderApp extends StatelessWidget {
  const VideoDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoDownloaderScreen(),
    );
  }
}

class VideoDownloaderScreen extends StatefulWidget {
  const VideoDownloaderScreen({super.key});

  @override
  _VideoDownloaderScreenState createState() => _VideoDownloaderScreenState();
}

class _VideoDownloaderScreenState extends State<VideoDownloaderScreen> {
  final TextEditingController _urlController = TextEditingController();
  VideoPlayerController? _controller;
  bool _isDownloading = false;
  bool _isPlaying = false;
  String _downloadPath = '';

  @override
  void initState() {
    super.initState();
    FlutterDownloader.initialize(debug: true);
  }

  Future<void> _downloadVideo(String url) async {
    setState(() {
      _isDownloading = true;
    });

    final downloadUrl = await _getDownloadUrl(url);
    if (downloadUrl == null) {
      Fluttertoast.showToast(msg: "Failed to get download URL");
      setState(() {
        _isDownloading = false;
      });
      return;
    }

    final directory = await getExternalStorageDirectory();
    final savePath = '${directory!.path}/downloaded_video.mp4';

    _downloadPath = savePath;

    FlutterDownloader.enqueue(
      url: downloadUrl,
      savedDir: directory.path,
      fileName: 'downloaded_video.mp4',
      showNotification: true,
      openFileFromNotification: true,
    ).then((value) {
      setState(() {
        _isDownloading = false;
      });
      Fluttertoast.showToast(msg: "Download started...");
    }).catchError((e) {
      setState(() {
        _isDownloading = false;
      });
      Fluttertoast.showToast(msg: "Error during download: $e");
    });
  }

  Future<String?> _getDownloadUrl(String url) async {
    // Placeholder method to simulate fetching a download URL.
    // Replace this with actual logic to get the video URL, such as calling an API or using a third-party library.
    await Future.delayed(
        const Duration(seconds: 2)); // Simulating a network delay
    return 'https://path-to-your-video-file.mp4'; // Return a valid URL to download the video
  }

  void _playVideo() async {
    final directory = await getExternalStorageDirectory();
    final videoPath = '${directory?.path}/downloaded_video.mp4';
    _controller = VideoPlayerController.file(File(videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller?.play();
        setState(() {
          _isPlaying = true;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VidMate-like Downloader"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: "Enter video URL",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isDownloading
                  ? null
                  : () => _downloadVideo(_urlController.text),
              child: _isDownloading
                  ? const CircularProgressIndicator()
                  : const Text("Download Video"),
            ),
            const SizedBox(height: 20),
            _controller == null
                ? Container()
                : _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isPlaying ? null : _playVideo,
              child: const Text("Play Downloaded Video"),
            ),
            if (_isDownloading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
