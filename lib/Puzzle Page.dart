// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as myimg;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class PuzzlePage extends StatefulWidget {
//   List myimages;
//   int level;
//   PuzzlePage(this.myimages,this.level);
//
//   @override
//   State<PuzzlePage> createState() => _PuzzlePageState();
// }
//
// class _PuzzlePageState extends State<PuzzlePage> {
//   List image = ["img_1.png","img_2.png","img_3.png","img_4.png","img_5.png","img_6.png","img_7.png","img_8.png","img_9.png","img_10.png"];
//   List mybool = [];
//   List myimages = [];
//   int level=0; bool win =false;
//
//   SharedPreferences? prefs;
//   shared_pref() async {
//     prefs = await SharedPreferences.getInstance();
//   }
//
//   win_puzzle(){
//     if (win) {
//       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//         showDialog(context: context, builder: (context) {
//           return AlertDialog(
//             title: Text("Hoohu"),
//             content: Text("You are Win.."),
//             actions: [
//               ElevatedButton(onPressed: () {
//                 level++;
//                 prefs!.setInt("level", level);
//                 setState(() {});
//                 Navigator.pop(context);
//               }, child: Text("Submit"))
//             ],
//           );
//         },);
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     shared_pref();
//     level=widget.level;
//     mybool = List.filled(widget.myimages.length, true);
//     for(int i=0;i<widget.myimages.length;i++)
//       {
//         myimages.add(myimg.encodePng(widget.myimages[i]));
//       }
//     print("hhps :$myimages");
//     win_puzzle();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("${level+1} Jigazo Puzzle"),
//       ),
//       body: Column(
//         children: [
//           IconButton(onPressed: () {
//             showDialog(context: context, builder: (context) {
//               return AlertDialog(
//                 title: Text("Hint"),
//                 content: Image(image: AssetImage("images/${image[level]}")),
//               );
//             },);
//           }, icon: Icon(Icons.extension)),
//           Expanded(flex: 2,
//             child: GridView.builder(padding: EdgeInsets.only(top: 50,left: 7,right: 7),
//               itemCount: myimages.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3, mainAxisSpacing: 1, crossAxisSpacing: 1),
//               itemBuilder: (context, index) {
//                 return (mybool[index]) ? Draggable(
//                     data: index,
//                     onDragStarted: () {
//                       mybool=List.filled(myimages.length, false);
//                       mybool[index]=true;
//                       setState(() {});
//                     },
//                     onDragEnd: (details) {
//                       mybool=List.filled(myimages.length, true);
//                       setState(() {});
//                     },
//                     child: Container(alignment: Alignment.center,
//                       decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.fill,image: MemoryImage(myimages[index]))),
//                     ),
//                     feedback: Container(alignment: Alignment.center,
//                       height: 100, width: 100,
//                       decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.fill,image: MemoryImage(myimages[index]))),
//                     )) : DragTarget(
//                   onAccept: (data) {
//                     Uint8List t=myimages[data as int];
//                     myimages[data as int] = myimages[index];
//                     myimages[index]=t;
//                   },
//                   builder: (context, candidateData, rejectedData) {
//                     return Container(alignment: Alignment.center,
//                       decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.fill,image:MemoryImage(myimages[index]))),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
