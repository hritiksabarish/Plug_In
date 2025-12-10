import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreativeToolbar extends StatelessWidget {
  final String title;
  final String iconPath;
  final bool canEdit;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onResetView;
  final VoidCallback? onSave;
  final bool showGrid;
  final ValueChanged<bool>? onGridChanged;
  final bool showSnap;
  final ValueChanged<bool>? onSnapChanged;
  final List<String>? activeUsers;
  final List<Widget>? extraActions;

  const CreativeToolbar({
    super.key,
    required this.title,
    required this.iconPath,
    this.canEdit = false,
    this.onZoomIn,
    this.onZoomOut,
    this.onResetView,
    this.onSave,
    this.showGrid = false,
    this.onGridChanged,
    this.showSnap = false,
    this.onSnapChanged,
    this.extraActions,
    this.activeUsers,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          
          if (isSmallScreen) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Title, Edit Status, Save
                Row(
                  children: [
                    SvgPicture.asset(
                      iconPath,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(Colors.blue.shade600, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title, 
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (canEdit && onSave != null)
                      IconButton(
                        onPressed: onSave,
                        icon: const Icon(Icons.save, size: 20),
                        color: colorScheme.secondary,
                        tooltip: 'Save',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Bottom Row: Controls
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Chip(
                        label: Text(canEdit ? 'Editable' : 'Read-only'),
                        backgroundColor: canEdit ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                        labelStyle: TextStyle(color: canEdit ? Colors.green : Colors.grey, fontSize: 10),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      // View Controls
                      if (onZoomOut != null) IconButton(icon: const Icon(Icons.zoom_out), onPressed: onZoomOut, iconSize: 20, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      if (onResetView != null) IconButton(icon: const Icon(Icons.center_focus_strong), onPressed: onResetView, iconSize: 20, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      if (onZoomIn != null) IconButton(icon: const Icon(Icons.zoom_in), onPressed: onZoomIn, iconSize: 20, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      
                      const SizedBox(width: 8),
                      if (extraActions != null) ...extraActions!,
                    ],
                  ),
                ),
              ],
            );
          }

          // Desktop / Tablet Layout
          return Row(
            children: [
              // Title Section
              SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(Colors.blue.shade600, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Chip(
                label: Text(canEdit ? 'Editable' : 'Read-only'),
                backgroundColor: canEdit ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                labelStyle: TextStyle(color: canEdit ? Colors.green : Colors.grey, fontSize: 12),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              
              const Spacer(),
              
              // Active Users
              if (activeUsers != null && activeUsers!.isNotEmpty) ...[
                SizedBox(
                  height: 32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: activeUsers!.length,
                    itemBuilder: (context, index) {
                      return Align(
                        widthFactor: 0.6,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.primaries[index % Colors.primaries.length],
                          child: Text(
                            activeUsers![index][0],
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // View Controls
              if (onZoomOut != null)
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  tooltip: 'Zoom Out',
                  onPressed: onZoomOut,
                  iconSize: 20,
                ),
              if (onResetView != null)
                IconButton(
                  icon: const Icon(Icons.center_focus_strong),
                  tooltip: 'Reset View',
                  onPressed: onResetView,
                  iconSize: 20,
                ),
              if (onZoomIn != null)
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  tooltip: 'Zoom In',
                  onPressed: onZoomIn,
                  iconSize: 20,
                ),
                
              const SizedBox(width: 16),
              
              // Toggles
              if (onGridChanged != null) ...[
                Row(
                  children: [
                    const Text('Grid', style: TextStyle(fontSize: 12)),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: showGrid,
                        activeColor: colorScheme.secondary,
                        onChanged: onGridChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
              if (onSnapChanged != null) ...[
                Row(
                  children: [
                    const Text('Snap', style: TextStyle(fontSize: 12)),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: showSnap,
                        activeColor: colorScheme.secondary,
                        onChanged: onSnapChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],

              // Extra Actions
              if (extraActions != null) ...extraActions!,

              // Save
              if (canEdit && onSave != null) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ]
            ],
          );
        }
      ),
    );
  }
}
