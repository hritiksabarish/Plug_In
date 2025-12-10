import 'dart:async';
import 'package:flutter/material.dart';

class RemoteCursor {
  final String id;
  final String name;
  final Color color;
  Offset position;

  RemoteCursor({
    required this.id,
    required this.name,
    required this.color,
    required this.position,
  });
}

class LiveCursors extends StatefulWidget {
  final Widget child;
  final Stream<Map<String, dynamic>>? cursorStream;
  final String? myUserId;

  const LiveCursors({
    super.key,
    required this.child,
    this.cursorStream,
    this.myUserId,
  });

  @override
  State<LiveCursors> createState() => _LiveCursorsState();
}

class _LiveCursorsState extends State<LiveCursors> {
  final Map<String, RemoteCursor> _cursors = {};
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    if (widget.cursorStream != null) {
      _sub = widget.cursorStream!.listen(_onCursorUpdate);
    }
  }

  @override
  void didUpdateWidget(LiveCursors oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cursorStream != oldWidget.cursorStream) {
      _sub?.cancel();
      if (widget.cursorStream != null) {
        _sub = widget.cursorStream!.listen(_onCursorUpdate);
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onCursorUpdate(Map<String, dynamic> data) {
    final userId = data['userId'] as String;
    if (userId == widget.myUserId) return;

    final x = (data['x'] as num).toDouble();
    final y = (data['y'] as num).toDouble();
    final colorHex = data['color'] as String? ?? '#FF0000';
    
    setState(() {
      if (_cursors.containsKey(userId)) {
        _cursors[userId]!.position = Offset(x, y);
      } else {
        _cursors[userId] = RemoteCursor(
          id: userId,
          name: userId.substring(0, 4), // Placeholder name
          color: _parseColor(colorHex),
          position: Offset(x, y),
        );
      }
    });
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          child: Stack(
            children: _cursors.values.map((c) {
              return Positioned(
                left: c.position.dx,
                top: c.position.dy,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.near_me, color: c.color, size: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        c.name,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
