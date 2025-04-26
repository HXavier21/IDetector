import 'package:ai_image_detector/data/history_item.dart';
import 'package:flutter/material.dart';

class HistoryItemView extends StatefulWidget {
  const HistoryItemView({
    super.key,
    required this.historyItem,
    required this.isSelect,
    this.onTap,
  });
  final HistoryItem historyItem;
  final bool isSelect;
  final void Function()? onTap;

  @override
  State<HistoryItemView> createState() => _HistoryItemViewState();
}

class _HistoryItemViewState extends State<HistoryItemView> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: widget.isSelect
                ? Color.fromARGB(255, 227, 227, 227)
                : isHovering
                    ? Color.fromARGB(255, 236, 236, 236)
                    : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.historyItem.fileName,
            style: Theme.of(context).typography.englishLike.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
