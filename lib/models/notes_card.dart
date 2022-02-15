import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'notes_model.dart';
class NoteCard extends StatefulWidget {
  final Note note;
  final bool isLightMode;
  final int index;
  final bool longPressEnabled;
  final VoidCallback callback;

  const NoteCard({required this.note, required this.isLightMode,  required this.index, required this.longPressEnabled, required this.callback});

  @override
  _NoteCardState createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GestureDetector(
          onLongPress: () {
            setState(() {
              selected = !selected;
            });
            widget.callback();
          },
          onTap: () {
            if (widget.longPressEnabled) {
              setState(() {
                selected = !selected;
              });
              widget.callback();
            }
          },
          child:  Card(
            color: selected
                ? widget.isLightMode
                ? Colors.black38
                : Colors.white
                : widget.isLightMode ? Colors.white : Colors.grey,
            // clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 10,
            child: ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    tapBodyToCollapse: !selected, /// To disable collapsing & expanding when the note is selected
                    tapBodyToExpand: !selected,
                    tapHeaderToExpand: selected
                ),
                header: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.only(right: 13.0),
                            child: Text(
                              widget.note.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24
                              ),
                            ),
                          ),
                        ),
                        FittedBox(
                          child: Icon(
                              CupertinoIcons.exclamationmark_octagon_fill,
                              color: widget.note.importanceLevel == 'CGreen' ? CupertinoColors.systemGreen
                                  : widget.note.importanceLevel == 'BYellow' ? CupertinoColors.systemYellow
                                  : CupertinoColors.systemRed,
                              size: 28
                          ),
                        )
                      ],
                    )),
                collapsed: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.note.note,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16
                        ),
                      ),
                    ),
                    _popUp(),
                  ],
                ),
                expanded: Padding(
                    padding: const EdgeInsets.only(bottom: 10, right: 10),
                    child: Text(
                      widget.note.note,
                      softWrap: true,
                      overflow: TextOverflow.fade,
                    )),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _popUp(){
    return PopupMenuButton(
      padding: const EdgeInsets.only(left: 15, right: 10),
        icon: const Icon(
          Icons.more_vert_sharp,
          size: 28,
          color: Colors.black54,
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text(widget.note.lastEditedTime.toString().substring(0, 16)),

          ),
          PopupMenuItem(
            value: 2,
            child: const Text("edit").tr(),
          ),
        ],
        onSelected: (value) {
          switch (value) {
            case 1:
              break;
            case 2:
              break;
          }
        },
      );
  }

}
