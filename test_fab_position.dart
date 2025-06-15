import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAB Position Test',
      theme: ThemeData(
        primaryColor: const Color(0xFF1F2937),
        colorScheme: ColorScheme.light(primary: const Color(0xFF1F2937)),
      ),
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAB Position Test')),
      body: ListView.separated(
        // Add bottom padding to prevent FAB from covering content
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 80.0, // Extra padding at bottom for FAB
        ),
        itemCount: 20, // Create many items to test scrolling
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
            subtitle: const Text('This is a test item'),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
            ),
          );
        },
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 24.0, right: 8.0),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('FAB Clicked!')));
            },
            child: const Center(
              child: Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
      // Use custom FAB location to position it higher
      floatingActionButtonLocation: _CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        24.0,
      ),
    );
  }
}

/// Custom FloatingActionButtonLocation that positions the FAB higher up from the bottom
class _CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final FloatingActionButtonLocation _location;
  final double _offsetY;

  const _CustomFloatingActionButtonLocation(this._location, this._offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset offset = _location.getOffset(scaffoldGeometry);
    return Offset(offset.dx, offset.dy - _offsetY);
  }
}
