import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

// https://blog.logrocket.com/flutter-camera-plugin-deep-dive-with-examples/
class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final ResolutionPreset _currentResolutionPreset = ResolutionPreset.medium;

  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isRearCameraSelected = false;
  FlashMode? _currentFlashMode;
  List<CameraDescription> _cameras = [];

  Future<XFile?> _takePicture() async {
    if (_controller!.value.isTakingPicture) {
      return null;
    }

    try {
      XFile file = await _controller!.takePicture();

      if (!_isRearCameraSelected) {
        List<int> imageBytes = await file.readAsBytes();

        img.Image? originalImage = img.decodeImage(imageBytes);
        img.Image flippedImage = img.flipHorizontal(originalImage!);

        File newFile = File(file.path);
        File flippedFile = await newFile.writeAsBytes(
          img.encodeJpg(flippedImage),
          flush: true,
        );

        file = XFile(flippedFile.path);
      }

      return file;
    } on CameraException catch (_) {
      // print('Error occured while taking picture: $e');
      return null;
    }
  }

  void _onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = _controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      _currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    if (mounted) {
      setState(() => _controller = cameraController);
    }

    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();

      _currentFlashMode = FlashMode.off;
      await cameraController.setFlashMode(_currentFlashMode!);
    } on CameraException catch (_) {
      Navigator.pop(context);
      // print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() => _isCameraInitialized = _controller!.value.isInitialized);
    }
  }

  void _onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (_controller == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _controller!.setExposurePoint(offset);
    _controller!.setFocusPoint(offset);
  }

  @override
  void initState() {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      availableCameras().then(
        (value) {
          _cameras = value;
          _onNewCameraSelected(_cameras[1]);
        },
      );
    } on CameraException catch (_) {
      Navigator.pop(context);
      // print('Error in fetching the cameras: $e');
    }

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();

    super.dispose();
  }

  Widget _buildFlashIcon(FlashMode flashMode, IconData icon) {
    return InkWell(
      onTap: () async {
        setState(
          () => _currentFlashMode = flashMode,
        );
        await _controller!.setFlashMode(
          flashMode,
        );
      },
      child: Icon(
        icon,
        color: _currentFlashMode == flashMode ? Colors.amber : Colors.white,
      ),
    );
  }

  void _onTakePicture() async {
    XFile? rawImage = await _takePicture();

    if (!mounted) return;
    Navigator.pop(context, rawImage);
  }

  void _onFlipCamera() {
    setState(
      () => _isCameraInitialized = false,
    );
    _onNewCameraSelected(_cameras[_isRearCameraSelected ? 1 : 0]);
    setState(
      () => _isRearCameraSelected = !_isRearCameraSelected,
    );
  }

  final List<Map<String, dynamic>> _flashIcons = const [
    {
      'flashMode': FlashMode.off,
      'icon': Icons.flash_off,
    },
    {
      'flashMode': FlashMode.auto,
      'icon': Icons.flash_auto,
    },
    {
      'flashMode': FlashMode.always,
      'icon': Icons.flash_on,
    },
    {
      'flashMode': FlashMode.torch,
      'icon': Icons.highlight,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _flashIcons
                        .map((item) =>
                            _buildFlashIcon(item['flashMode'], item['icon']))
                        .toList(),
                  ),
                ),
                AspectRatio(
                  aspectRatio: 1 / _controller!.value.aspectRatio,
                  child: Stack(
                    children: [
                      CameraPreview(
                        _controller!,
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (details) =>
                                  _onViewFinderTap(details, constraints),
                            );
                          },
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 2,
                          child: Image.asset(
                            'assets/images/camera_aim.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const SizedBox(
                            width: 80,
                            height: 80,
                          ),
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: (_controller!.value.isTakingPicture)
                                ? const Padding(
                                    padding: EdgeInsets.all(22.0),
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                    ),
                                  )
                                : InkWell(
                                    borderRadius: BorderRadius.circular(50),
                                    onTap: _onTakePicture,
                                    child: const Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: Colors.white38,
                                          size: 80,
                                        ),
                                        Icon(
                                          Icons.circle,
                                          color: Colors.white,
                                          size: 65,
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: _onFlipCamera,
                              child: const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.black38,
                                    size: 60,
                                  ),
                                  Icon(
                                    Icons.autorenew,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ),
    );
  }
}
