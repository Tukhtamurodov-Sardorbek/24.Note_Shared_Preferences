import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:expandable_bottom_bar/expandable_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/notes_card.dart';
import '../models/notes_model.dart';
import '../services/preferences_service.dart';

class Notes extends StatefulWidget {
  static const String id = '/notes';
  const Notes({Key? key}) : super(key: key);

  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  /// All Notes
  List<Note> notes = [];
  /// For responsiveness
  bool isNotMobile = false;
  /// Text field => Title
  final TextEditingController _titleController = TextEditingController();
  /// Text field => Note
  final TextEditingController _noteController = TextEditingController(text: '');
  /// Object
  Note? note;
  /// PopUp value (language)
  int _value = 3;
  /// Theme
  bool isLightMode = true;
  /// Mic button color
  Color buttonColor = Colors.white54;
  /// To select
  bool longPressFlag = false;
  /// Selected notes' indices
  List<int> indexList = [];

  String importanceLevel = 'CGreen';
  bool redIsPressed = false;
  bool yellowIsPressed = false;
  bool greenIsPressed = false;

  // void _storeNote() async {
  //   String text = _controller.text.trim().toString();
  //   Note note = Note(id: text.hashCode, createdTime: DateTime.now(), lastEditedTime: DateTime.now(), note: text);
  //   var result = await Preferences.storeNote(note);
  //   /// Check if the note is stored
  //   if(result) {
  //     if (kDebugMode) {
  //       print("Note successfully saved!!!");
  //     }
  //   }
  // }
  void _storeNotes() async {
    setState(() {
      notes.add(Note(
        id: _noteController.text.trim().toString().hashCode,
        lastEditedTime: DateTime.now(),
        title: _titleController.text.trim().toString(),
        note: _noteController.text.trim().toString(),
        importanceLevel: importanceLevel,
      ));

      notes.sort();
    });
    bool isStored = await Preferences.storeNoteList(notes);

    /// Check if the note is stored
    if (isStored) {
      if (kDebugMode) {
        print("Note successfully saved!!!");
      }
    } else {
      if (kDebugMode) {
        print("Note is not saved...\nSomething went wrong!");
      }
    }
  }

  // void _loadNote() async {
  //   await Preferences.loadNote().then((value) {
  //     setState(() {
  //       note = value;
  //     });
  //   });
  //   if (kDebugMode) {
  //     print(note!.toJson());
  //   }
  //   // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(note!.toJson().toString()), duration: const Duration(seconds: 5)));
  // }
  Future<void> _loadNotes() async {
    await Preferences.loadNoteList().then((value) {
      setState(() {
        value == null ? null : notes = value;
      });
    });
    if (kDebugMode) {
      print(notes.map((note) => jsonEncode(note.toJson())).toList());
    }
  }

  void _changeMode() async {
    setState(() {
      isLightMode = !isLightMode;
    });
    await Preferences.storeMode(isLightMode);
  }

  Future<void> _loadState() async {
    await Preferences.loadMode().then((value) {
      setState(() {
        isLightMode = value ?? true;
      });
    });

    await Preferences.loadLang().then((value) {
      setState(() {
        _value = value == null ? 3 : int.parse(value);
      });
    });
    if (kDebugMode) {
      print('Theme: ${isLightMode ? 'light' : 'dark'}');
      print(
          'Language: ${_value == 1 ? 'English' : _value == 2 ? 'Russian' : _value == 3 ? 'Uzbek' : 'Unhandled Exception'}');
    }
  }

  void longPress() {
    setState(() {
      if (indexList.isEmpty) {
        longPressFlag = false;
      } else {
        longPressFlag = true;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _noteController.clear();
    _loadNotes();
    _loadState();
    // _loadNotes().then((value) => context.setLocale(const Locale('uz', 'UZB')));
    // Timer(
    //   const Duration(seconds: 1),
    //     (){
    //       context.setLocale(const Locale('en', 'US'));
    //     }
    // );
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.shortestSide > 600) {
      isNotMobile = true;
    }
    return Scaffold(
      backgroundColor: isLightMode ? Colors.white : Colors.black,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            // margin: const EdgeInsets.only(top: 15),
            child: notes.isEmpty
                ? Center(child: Text("empty", style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isLightMode ? Colors.black : Colors.grey
            ),).tr())
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: notes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return NoteCard(
                        note: notes[index],
                        isLightMode: isLightMode,
                        index: index,
                        longPressEnabled: longPressFlag,
                        callback: () {
                          if (indexList.contains(index)) {
                            indexList.remove(index);
                          } else {
                            indexList.add(index);
                          }
                          longPress();
                        },
                      );
                    },
                  )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onVerticalDragUpdate: DefaultBottomBarController.of(context).onDrag,
        onVerticalDragEnd: DefaultBottomBarController.of(context).onDragEnd,
        child: FloatingActionButton.extended(
          label: FittedBox(
            child: const Text("new_note", style: TextStyle(fontSize: 16)).tr(),
          ),
          elevation: 2,
          backgroundColor: const Color(0xff20B2AA),
          foregroundColor: Colors.white,
          onPressed: () {
            DefaultBottomBarController.of(context).swap();
          },
        ),
      ),
      bottomNavigationBar: BottomExpandableAppBar(
          expandedHeight: MediaQuery.of(context).size.height * 0.59,
          bottomOffset: 0,
          horizontalMargin: 10,
          shape: const AutomaticNotchedShape(
              RoundedRectangleBorder(), StadiumBorder(side: BorderSide())),
          expandedBackColor: Colors.grey.shade400,
          bottomAppBarColor: isLightMode ? Colors.white : Colors.black,
          expandedBody: Padding(
            padding: const EdgeInsets.only(bottom: kToolbarHeight + 5),
            child: Column(
              children: [
                const SizedBox(height: 5),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: Container(
                          // width: greenIsPressed ? 40 : 32,
                          // height: greenIsPressed ? 35 : 30,
                          width: 32,
                          height: 30,
                          alignment: Alignment.bottomCenter,
                          child: Icon(
                              CupertinoIcons.exclamationmark_octagon_fill,
                              color: greenIsPressed
                                  ? Colors.green.shade900
                                  : CupertinoColors.systemGreen,
                              size: 28),
                        ),
                        onTap: () {
                          setState(() {
                            importanceLevel = 'CGreen';
                            greenIsPressed = true;
                            Timer(
                                const Duration(milliseconds: 500),
                                () => setState(() {
                                      greenIsPressed = false;
                                    }));
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          // width: yellowIsPressed ? 40 : 32,
                          // height: yellowIsPressed ? 35 : 30,
                          width: 32,
                          height: 30,
                          alignment: Alignment.bottomCenter,
                          child: Icon(
                              CupertinoIcons.exclamationmark_octagon_fill,
                              color: yellowIsPressed
                                  ? Colors.yellow.shade900
                                  : CupertinoColors.systemYellow,
                              size: 28),
                        ),
                        onTap: () {
                          setState(() {
                            importanceLevel = 'BYellow';
                            yellowIsPressed = true;
                            Timer(
                                const Duration(milliseconds: 500),
                                () => setState(() {
                                      yellowIsPressed = false;
                                    }));
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          // width: redIsPressed ? 40 : 32,
                          // height: redIsPressed ? 35 : 30,
                          width: 32,
                          height: 30,
                          alignment: Alignment.bottomCenter,
                          child: Icon(
                              CupertinoIcons.exclamationmark_octagon_fill,
                              color: redIsPressed
                                  ? Colors.red.shade900
                                  : CupertinoColors.systemRed,
                              size: 28),
                        ),
                        onTap: () {
                          setState(() {
                            importanceLevel = 'ARed';
                            redIsPressed = true;
                            Timer(
                                const Duration(milliseconds: 500),
                                () => setState(() {
                                      redIsPressed = false;
                                    }));
                          });
                        },
                      ),
                      const SizedBox(width: 10)
                    ],
                  ),
                ),

                /// Text Field => Title
                // Expanded(
                //   child: Padding(
                //     /// Raise text field over keyboard
                //     padding: EdgeInsets.only(
                //         bottom: isNotMobile
                //             ? MediaQuery.of(context).viewInsets.bottom * 0.58
                //             : MediaQuery.of(context).viewInsets.bottom * 0.54),
                //     child: TextField(
                //       controller: _titleController,
                //       keyboardType: TextInputType.multiline,
                //       style: const TextStyle(
                //           fontSize: 16,
                //           color: Colors.black,
                //           fontWeight: FontWeight.bold,
                //           letterSpacing: 1.5
                //       ),
                //       textAlign: TextAlign.center,
                //       maxLines: 1,
                //
                //       /// If the maxLines property is null, there is no limit to the number of lines, and the wrap is enabled.
                //       decoration: InputDecoration(
                //           contentPadding: EdgeInsets.only(left: (isNotMobile ? 25 : 15), right: (isNotMobile ? 25 : 15)),
                //           hintText: "title".tr(),
                //           hintStyle: const TextStyle(
                //               color: Colors.white, fontSize: 18),
                //           border: const OutlineInputBorder(
                //               borderSide: BorderSide.none)),
                //     ),
                //   ),
                // ),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5
                    ),
                    maxLines: 1,

                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                            left: (isNotMobile ? 25 : 15),
                            right: (isNotMobile ? 25 : 15),),
                        hintText: "title".tr(),
                        hintStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 18),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none)),
                  ),
                ),

                /// Text Field => Note
                Expanded(
                  flex: 6,
                  child: Padding(
                    /// Raise text field over keyboard
                    padding: EdgeInsets.only(
                        bottom: isNotMobile
                            ? MediaQuery.of(context).viewInsets.bottom * 0.58
                            : MediaQuery.of(context).viewInsets.bottom * 0.54),

                    child: TextField(
                      controller: _noteController,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.normal),
                      maxLines: null,

                      /// If the maxLines property is null, there is no limit to the number of lines, and the wrap is enabled.
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(
                              left: (isNotMobile ? 25 : 15),
                              right: (isNotMobile ? 25 : 15),
                              top: 5,
                              bottom: 35),
                          hintText: "note".tr(),
                          hintStyle: const TextStyle(
                              color: Colors.white, fontSize: 18),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none)),
                    ),
                  ),
                ),

                /// Buttons
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Cancel
                        Expanded(
                          child: MaterialButton(
                            minWidth: MediaQuery.of(context).size.width * 0.21,
                            height: 45,
                            shape: const StadiumBorder(),
                            color: const Color(0xff8B0000),
                            child: FittedBox(
                              child: const Text("cancel",
                                      style: TextStyle(
                                          color: Colors.white,
                                          letterSpacing: 1.7,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))
                                  .tr(),
                            ),
                            onPressed: () {
                              DefaultBottomBarController.of(context).swap();
                              _titleController.clear();
                              _noteController.clear();
                              importanceLevel = 'CGreen';
                              setState(() {});
                            },
                          ),
                        ),
                        const Spacer(),

                        /// OK
                        Expanded(
                          child: MaterialButton(
                            minWidth: MediaQuery.of(context).size.width * 0.21,
                            height: 45,
                            shape: const StadiumBorder(),
                            color: const Color(0xff008000),
                            child: FittedBox(
                              child: const Text("ok",
                                      style: TextStyle(
                                          color: Colors.white,
                                          letterSpacing: 1.7,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))
                                  .tr(),
                            ),
                            onPressed: () {
                              DefaultBottomBarController.of(context).swap();
                              _storeNotes();
                              _titleController.clear();
                              _noteController.clear();
                              importanceLevel = 'CGreen';
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomAppBarBody: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton(
                  icon: const Icon(
                    Icons.language_sharp,
                    size: 28,
                    color: CupertinoColors.systemGrey,
                  ),
                  tooltip: "tooltip_lang".tr(),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: const Text("eng").tr(),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: const Text("ru").tr(),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: const Text("uz").tr(),
                    ),
                  ],
                  initialValue: _value,
                  onCanceled: () {},
                  onSelected: (value) {
                    switch (value) {
                      case 1:
                        setState(() {
                          _value = 1;
                        });
                        context.setLocale(const Locale('en', 'US'));
                        break;
                      case 2:
                        setState(() {
                          _value = 2;
                        });
                        context.setLocale(const Locale('ru', 'RU'));
                        break;
                      case 3:
                        setState(() {
                          _value = 3;
                        });
                        context.setLocale(const Locale('uz', 'UZB'));
                        break;
                    }
                    Preferences.storeLang(value.toString());
                  },
                ),
                // IconButton(
                //   icon: const Icon(Icons.account_circle, color: CupertinoColors.systemGrey, size: 28),
                //   onPressed: (){},
                // ),
                const Spacer(),
                indexList.isNotEmpty
                    ? MaterialButton(
                        minWidth: 10,
                        shape: const CircleBorder(),
                        child: SizedBox(
                          height: 45,
                          width: 40,
                          child: Stack(
                            children: [
                              const Align(
                                  alignment: Alignment.center,
                                  child: Icon(CupertinoIcons.trash_fill,
                                      color: CupertinoColors.systemGrey)),
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle),
                                  child: Center(
                                      child: Text('${indexList.length}')),
                                ),
                              )
                            ],
                          ),
                        ),
                        onPressed: () {
                          if (kDebugMode) {
                            print(indexList);
                          }
                          for (int i = 0; i < indexList.length; i++) {
                            notes.removeAt(indexList[i]);
                          }
                          Preferences.storeNoteList(notes);
                          _loadNotes();
                          setState(() {
                            indexList = [];
                          });
                        },
                      )
                    : const SizedBox(),

                IconButton(
                    splashRadius: 10,
                    color: CupertinoColors.systemGrey,
                    icon:
                        Icon(isLightMode ? Icons.dark_mode : Icons.light_mode),
                    tooltip: "tooltip_theme".tr(),
                    onPressed: () {
                      _changeMode();
                    })
              ],
            ),
          )),
    );
  }
}
