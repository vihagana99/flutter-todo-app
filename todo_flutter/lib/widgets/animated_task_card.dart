import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class AnimatedTaskCard extends StatefulWidget {
  final Task task;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final String dueDateLabel;
  final bool isOverdue;

  const AnimatedTaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.onTap,
    required this.onToggle,
    required this.dueDateLabel,
    required this.isOverdue,
  });

  @override
  State<AnimatedTaskCard> createState() => _AnimatedTaskCardState();
}

class _AnimatedTaskCardState extends State<AnimatedTaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));

    // Small stagger per item so a freshly loaded list cascades in gently.
    final delay = Duration(milliseconds: (widget.index * 40).clamp(0, 300));
    Future.delayed(delay, () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final priorityColor = AppColors.priorityColor(task.priority);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Material(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: widget.onTap,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Priority accent bar - the visual signature of the card
                    Container(
                      width: 5,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(18),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            _AnimatedCheck(
                              checked: task.completed,
                              color: priorityColor,
                              onTap: widget.onToggle,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 220),
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                          decoration: task.completed
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          color: task.completed
                                              ? Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color
                                                  ?.withOpacity(0.45)
                                              : Theme.of(context).textTheme.bodyLarge?.color,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    child: Text(task.title),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      _tag(context, task.category, Icons.label_outline),
                                      if (task.dueDate != null)
                                        _tag(
                                          context,
                                          widget.dueDateLabel,
                                          Icons.event_outlined,
                                          highlight: widget.isOverdue && !task.completed,
                                        ),
                                      if (task.notes != null && task.notes!.isNotEmpty)
                                        Icon(
                                          Icons.notes_outlined,
                                          size: 15,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withOpacity(0.6),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(BuildContext context, String label, IconData icon, {bool highlight = false}) {
    final color = highlight ? AppColors.priorityHigh : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.priorityHigh.withOpacity(0.12)
            : Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? Theme.of(context).textTheme.bodyMedium?.color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Small circular checkbox with a scale + fade animation on toggle.
class _AnimatedCheck extends StatelessWidget {
  final bool checked;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedCheck({required this.checked, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: checked ? color : Colors.transparent,
          border: Border.all(color: checked ? color : Colors.grey.shade400, width: 2),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: checked
              ? const Icon(Icons.check, size: 16, color: Colors.white, key: ValueKey('checked'))
              : const SizedBox.shrink(key: ValueKey('unchecked')),
        ),
      ),
    );
  }
}
