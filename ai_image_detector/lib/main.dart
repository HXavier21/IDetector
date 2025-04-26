import 'package:ai_image_detector/components/display_image.dart';
import 'package:ai_image_detector/components/display_words.dart';
import 'package:ai_image_detector/components/drop_zone.dart';
import 'package:ai_image_detector/components/side_bar.dart';
import 'package:ai_image_detector/data/history_item.dart';
import 'package:ai_image_detector/utils/network_util.dart';
import 'package:ai_image_detector/utils/pick_image_util.dart';
import 'package:ai_image_detector/utils/process_control_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI iDetector',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          primary: Colors.white,
          secondary: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late DropzoneViewController controller;
  late AnimationController animationController;
  late Animation<double> animation;
  bool isImageUploaded = false;
  Uint8List imageFileData = Uint8List(0);
  String imageFileName = '';
  bool isImageProcessing = false;
  bool isSidebarOpen = false;
  double? probability;
  List<HistoryItem> historyItems = [];
  int currentIndex = -1;

  void onError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
    setState(() {
      isImageUploaded = false;
      isImageProcessing = false;
    });
  }

  void switchSideBarState() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
      isSidebarOpen
          ? animationController.forward()
          : animationController.reverse();
    });
  }

  void switchSideDrawerState(BuildContext context) {
    isSidebarOpen = !isSidebarOpen;
    if (isSidebarOpen) {
      Scaffold.of(context).openDrawer();
    } else {
      Navigator.pop(context);
    }
  }

  void onHistoryItemTap(int index) {
    setState(() {
      isImageUploaded = true;
      isImageProcessing = false;
      imageFileData = historyItems[index].image;
      imageFileName = historyItems[index].fileName;
      probability = historyItems[index].probability;
      currentIndex = index;
    });
  }

  void onClickUploadImage() {
    PickImageUtil().pickImage(
      onFilePicked: (file) {
        if (file.bytes == null) {
          onError('File bytes is null');
          return;
        }
        startProcess(file.bytes!, file.name);
        ProcessControlUtil().onFileUpload(
          imageFile: MultipartFile.fromBytes(
            imageFileData,
            filename: imageFileName,
          ),
          onPostResponse: onPostResponse,
        );
      },
      onError: (error) => onError(error),
    );
  }

  void startProcess(Uint8List data, String name) {
    NetworkUtil().cancelPreviousRequest();
    setState(() {
      imageFileData = data;
      imageFileName = name;
      isImageUploaded = true;
      isImageProcessing = true;
      currentIndex = -1;
    });
  }

  void onPostResponse(Response response) {
    setState(() {
      isImageProcessing = false;
      probability = response.data['probability'];
      currentIndex = historyItems.length;
      historyItems.add(
        HistoryItem(
          DateTime.now(),
          fileName: imageFileName,
          image: imageFileData,
          probability: probability ?? 0.0,
        ),
      );
    });
  }

  void clearAllStateAndUpload() {
    NetworkUtil().cancelPreviousRequest();
    setState(() {
      isImageUploaded = false;
      isImageProcessing = false;
      imageFileData = Uint8List(0);
      probability = null;
      currentIndex = -1;
    });
    onClickUploadImage();
  }

  bool isMobile() {
    return MediaQuery.of(context).size.width < 800;
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    animation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: isMobile()
          ? SideBar(
              onLeadIconPressed: () => switchSideDrawerState(context),
              historyList: historyItems,
              onHistoryItemTap: onHistoryItemTap,
              selectedIndex: currentIndex,
              isMobile: true,
            )
          : null,
      onDrawerChanged: (isOpened) => setState(() {
        isSidebarOpen = isOpened;
      }),
      body: Stack(
        children: [
          if (!isMobile())
            SideBar(
              onLeadIconPressed: switchSideBarState,
              historyList: historyItems,
              onHistoryItemTap: onHistoryItemTap,
              selectedIndex: currentIndex,
              isMobile: false,
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return SizedBox(
                    width: screenWidth * (isMobile() ? 1.0 : animation.value),
                    child: Scaffold(
                      appBar: AppBar(
                        backgroundColor: Colors.white,
                        leading: !isSidebarOpen || isMobile()
                            ? IconButton(
                                icon: Icon(Icons.notes, color: Colors.black),
                                onPressed: () {
                                  if (isMobile()) {
                                    switchSideDrawerState(context);
                                  } else {
                                    switchSideBarState();
                                  }
                                },
                              )
                            : null,
                        title: const Text('AI iDetector'),
                        centerTitle: false,
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: Icon(Icons.add_box_outlined),
                              onPressed: clearAllStateAndUpload,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: Icon(Icons.person_outline),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      body: Container(
                        color: Colors.white,
                        child: Stack(
                          children: [
                            DropZone(
                              onCreated: (ctrl) => controller = ctrl,
                              getFile: (file) async {
                                startProcess(
                                  await controller.getFileData(file),
                                  file.name,
                                );
                                return MultipartFile.fromBytes(
                                  imageFileData,
                                  filename: imageFileName,
                                );
                              },
                              onPostResponse: onPostResponse,
                              onError: (error) => onError(error),
                            ),
                            Positioned.fill(
                              child: Column(
                                children: [
                                  Spacer(),
                                  if (!isImageUploaded)
                                    DisplayWords(onClick: onClickUploadImage)
                                  else
                                    DisplayImage(
                                      imageFile: imageFileData,
                                      isImageProcessing: isImageProcessing,
                                      probability: probability,
                                    ),
                                  Spacer(),
                                  Text(
                                    isMobile()
                                        ? "iDetector is not always accurate,\nplease use it with caution."
                                        : "iDetector is not always accurate,please use it with caution.",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
