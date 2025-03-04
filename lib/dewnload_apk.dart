import 'dart:io';
import 'package:apk_installer/apk_installer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  ValueNotifier downloadProgressNotifier = ValueNotifier(0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //requestManageExternalStoragePermission();
  }

  Future<void> requestManageExternalStoragePermission() async {

    // permission from user to manage external storage
    if (await Permission.manageExternalStorage.request().isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission granted!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied!')),
      );
    }
  }

  downloadFileFromServer(BuildContext cont) async {
    try {
      downloadProgressNotifier.value = 0;
      Directory directory = await getApplicationDocumentsDirectory();
      await getDownloadDirectory();

      Response rep = await Dio().download(
          "",
        //weblink to download apk
        //https://mobile.Suraj.co.in:5086/Download_File.aspx?DownloadLink
        
          '${directory.path}/sample.apk',
          onReceiveProgress: (actualBytes, int totalBytes) {
        downloadProgressNotifier.value =
            (actualBytes / totalBytes * 100).floor();
      });
      print('File downloaded at ${directory.path}/Pravin.apk');

      if (rep.statusCode == 200) {
        //file download
        Navigator.of(context).pop();
        installAppDialog('${directory.path}/Pravin.apk', cont);
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Try After Some Time")));
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _installApk(String filePth) async {
    try {
      // Replace with the actual path to your APK file
      // String apkPath = "/storage/emulated/0/Download/your_app.apk";
      await ApkInstaller.installApk(filePath: filePth);
      print("APK installed successfully!");
    } catch (e) {
      print("Failed to install APK: $e");
    }
  }

  void installAppDialog(String apkPath, BuildContext context) {
    showDialog(
        context: context,
        
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.amberAccent,
            contentPadding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 0.0),
            
            content: 
              SizedBox(
                height: 35,
                width: 0,
                child: Center(
                  child: TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 30)),
                    onPressed: () {
                    _installApk(apkPath);
                    Navigator.of(context).pop();
                  }, child: Text("INSTALL", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),)),
                ),
              )
     
          );
        });
  }

  Future<Directory> getDownloadDirectory() async {
    Directory? downloadDirectory;

    if (Platform.isAndroid) {
      // On Android, retrieve the external storage directory
      downloadDirectory = Directory('/storage/emulated/0/Download');
    }
    return downloadDirectory!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Flutter File Download')),
        body: Center(
          child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  useSafeArea: true,
                  builder: (context) {
                    return AlertDialog(
                      actions: [
                        //if(downloadProgressNotifier.value != 100.00)
                        ElevatedButton(
                            onPressed: () {
                              downloadFileFromServer(context);
                            },
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size(250, 35),
                                backgroundColor: Colors.amberAccent),
                            child: Text("Download")),
                        // if(downloadProgressNotifier.value == 100.00)
                        // ElevatedButton(onPressed: () {}, child: Text('INSTALL'))
                      ],
                      title: Text("New Update Available!"),
                      content: SizedBox(
                        // height: 200,
                        width: 300,
                        child: ValueListenableBuilder(
                          valueListenable: downloadProgressNotifier,
                          builder: (context, value, child) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LinearPercentIndicator(
                                  lineHeight: 45.0,
                                  barRadius: Radius.circular(10),
                                  percent: downloadProgressNotifier.value / 100,
                                  backgroundColor: Colors.grey,
                                  progressColor: Colors.blue,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  '${downloadProgressNotifier.value}%',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  padding: EdgeInsets.symmetric(horizontal: 40)),
              child:
                  Text("Download APK", style: TextStyle(color: Colors.black))),
        )

        // Center(
        //   child: ValueListenableBuilder(
        //       valueListenable: downloadProgressNotifier,
        //       builder: (context, value, snapshot) {
        //         return Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           crossAxisAlignment: CrossAxisAlignment.center,
        //           children: [
        //             const Text(
        //               'Circular Progress Indicator',
        //               style: TextStyle(fontSize: 20),
        //             ),
        //             const SizedBox(
        //               height: 32,
        //             ),
        //             CircularPercentIndicator(
        //               radius: 50.0,
        //               lineWidth: 10.0,
        //               // animation: true,
        //               percent: downloadProgressNotifier.value / 100,
        //               center: Text(
        //                 "${downloadProgressNotifier.value}%",
        //                 style: const TextStyle(
        //                     fontSize: 20.0,
        //                     fontWeight: FontWeight.w600,
        //                     color: Colors.black),
        //               ),
        //               backgroundColor: Colors.grey.shade300,
        //               circularStrokeCap: CircularStrokeCap.round,
        //               progressColor: Colors.blueAccent,
        //             ),
        //             const SizedBox(
        //               height: 32,
        //             ),
        //             const Text(
        //               'Linear Progress Indicator',
        //               style: TextStyle(fontSize: 20),
        //             ),
        //             const SizedBox(
        //               height: 32,
        //             ),
        //             LinearPercentIndicator(
        //               // animation: true,
        //               barRadius: const Radius.circular(10),
        //               // animationDuration: 400,
        //               lineHeight: 30.0,
        //               percent: downloadProgressNotifier.value / 100,
        //               backgroundColor: Colors.grey.shade300,
        //               progressColor: Colors.blue,
        //             ),
        //             const SizedBox(
        //               height: 15,
        //             ),
        //             Text(
        //               "${downloadProgressNotifier.value}%",
        //               style: const TextStyle(
        //                   fontSize: 20.0,
        //                   fontWeight: FontWeight.w600,
        //                   color: Colors.black),
        //             ),
        //           ],
        //         );
        //       }),
        // ),
        // floatingActionButton: FittedBox(
        //   child: FloatingActionButton(
        //       onPressed: () => downloadFileFromServer(context),
        //       child: const Icon(Icons.cloud_download_sharp)),
        // ),
        );
  }
}
