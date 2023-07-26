import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as myimg;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {

 static  SharedPreferences? prefs;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List mybool = [];
  bool win =false;
  int level=0;
  bool temp = false;
  List  myimages = [];
  List <Image> myimages1 = [];
  List <Image> myimages2 = [];
  List image = ["img_1.png","img_2.png","img_3.png","img_4.png","img_5.png","img_6.png","img_7.png","img_8.png","img_9.png","img_10.png"];

  // this is cut image pieces(1)
  List<myimg.Image> splitImage(myimg.Image inputImage, int horizontalPieceCount, int verticalPieceCount) {
    myimg.Image image = inputImage;  // myimg : is a name to different to image

    final pieceWidth = (image.width / horizontalPieceCount).round();
    final pieceHeight = (image.height / verticalPieceCount).round();
    final pieceList = List<myimg.Image>.empty(growable: true);
    int x=0,y=0;
    for (int i=0; i<horizontalPieceCount; i++) {
      for (int j=0; j<verticalPieceCount; j++) {
        pieceList.add(myimg.copyCrop(image, x: x, y: y, width: pieceWidth, height: pieceHeight));
        x = x+pieceWidth;
      }
      x=0;
      y = y+pieceHeight;
    }
    return pieceList;
  }

  // this is convert image asset to file (2,4_path)
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('images/$path');  // images : my foldername, path : image name
    var myDir_path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS)+"/jigazo";
    Directory dir = Directory(myDir_path);
    if(!await dir.exists())
      {
        await dir.create();
      }
    final file = File('${dir.path}/$path');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  // get permission(3)
  get_permission()
  async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.storage,
      ].request();
    }
  }

  shared_pref() async {
    Home.prefs = await SharedPreferences.getInstance();
    level=Home.prefs!.getInt("level") ?? 0 ;
  }

  win_puzzle(){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text("Solved"),
            content: Text("You are Win.."),
            actions: [
              ElevatedButton(onPressed: () {
                level++;
                Home.prefs!.setInt("level", level);
                setState(() {});
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Home();
                },));
              }, child: Text("Submit"))
            ],
          );
        },);
      });
  }

  @override
  void initState() {
    super.initState();
    get_permission();
    shared_pref();
        level=Home.prefs!.getInt("level") ?? 0 ;
        getImageFileFromAssets("${image[level]}").then((value) {
          temp=true;
          myimg.Image? img = myimg.decodePng(value.readAsBytesSync());
          myimages =splitImage(img!, 3, 3);
          for(int i=0;i<myimages.length;i++)
          {
            myimages1.add(Image.memory(myimg.encodePng(myimages[i]),fit: BoxFit.fill,height: 100,width: 100,));
          }
          mybool = List.filled(myimages.length, true);
          myimages2.addAll(myimages1);
          myimages1.shuffle();
          setState(() {});
        });
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${level+1} Jigazo Puzzle"),
      ),
      body: (temp==true) ?
      Column(
        children: [
          IconButton(onPressed: () {
            showDialog(context: context, builder: (context) {
              return AlertDialog(
                title: Text("Hint"),
                content: Image(image: AssetImage("images/${image[level]}")),
              );
            },);
          }, icon: Icon(Icons.extension)),
          Expanded(flex: 2,
            child: GridView.builder(padding: EdgeInsets.only(top: 50,left: 7,right: 7),
              itemCount: myimages.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 1, crossAxisSpacing: 1),
              itemBuilder: (context, index) {
                return (mybool[index]) ? Draggable(
                    data: index,
                    onDragStarted: () {
                      mybool=List.filled(myimages.length, false);
                      mybool[index]=true;
                      setState(() {});
                    },
                    onDragEnd: (details) {
                      mybool=List.filled(myimages.length, true);
                      setState(() {});
                    },
                    child: myimages1[index],   //Container(alignment: Alignment.center, decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.fill,image: MemoryImage(myimages[index]))),),

                    feedback: myimages1[index])
                    : DragTarget(
                  onAccept: (data) {
                    // Uint8List t=myimages[data as int];
                    // myimages[data as int] = myimages[index];
                    // myimages[index]=t;
                    Image tmp_img = myimages1[data as int];
                    myimages1[data as int] = myimages1[index];
                    myimages1[index] = tmp_img;
                    if (listEquals(myimages1, myimages2)) // for compare two list
                      {
                        win_puzzle();
                      }
                    setState(() {});
                    },
                    builder: (context, candidateData, rejectedData) {
                    return myimages1[index];
                  },
                );
              },
            ),
          ),
        ],
      )
      : CircularProgressIndicator(),
    );
  }
}
