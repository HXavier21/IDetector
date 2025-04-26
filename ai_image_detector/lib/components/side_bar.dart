import 'package:ai_image_detector/components/history_item_view.dart';
import 'package:ai_image_detector/data/history_item.dart';
import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  const SideBar(
      {super.key,
      required this.onLeadIconPressed,
      this.historyList,
      this.onHistoryItemTap,
      required this.selectedIndex,
      required this.isMobile});
  final void Function()? onLeadIconPressed;
  final List<HistoryItem>? historyList;
  final void Function(int)? onHistoryItemTap;
  final int selectedIndex;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * (isMobile ? 0.45 : 0.2),
      color: Color.fromARGB(255, 249, 249, 249),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.notes, color: Colors.black),
                  onPressed: onLeadIconPressed,
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.black),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.edit_note_outlined, color: Colors.black),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          if (historyList == null || historyList!.isEmpty) ...[
            Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history_outlined,
                  size: 28,
                ),
                Text(
                  "No history,\nplease upload an image.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .typography
                      .englishLike
                      .bodyLarge!
                      .copyWith(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                ),
              ],
            ),
            Spacer(),
          ] else ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    "History",
                    style: Theme.of(context)
                        .typography
                        .englishLike
                        .bodyLarge!
                        .copyWith(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.left,
                  ),
                ),
                for (int i = historyList!.length - 1; i >= 0; i--)
                  HistoryItemView(
                    historyItem: historyList![i],
                    isSelect: i == selectedIndex,
                    onTap: () {
                      onHistoryItemTap?.call(i);
                    },
                  ),
              ],
            ),
            Spacer(),
          ],
        ],
      ),
    );
  }
}
