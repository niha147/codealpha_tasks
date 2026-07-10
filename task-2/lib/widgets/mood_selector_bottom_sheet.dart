import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quote_provider.dart';
import '../core/constants/colors.dart';

class MoodSelectorBottomSheet extends ConsumerWidget {
  const MoodSelectorBottomSheet({Key? key}) : super(key: key);

  static const List<String> moods = [
    'All',
    'Motivational',
    'Calm',
    'Success',
    'Focus',
    'Love'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMood = ref.watch(quoteProvider).activeMood;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.glassBackground.withOpacity(0.3),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Mood",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: moods.map((mood) {
                  final isSelected = activeMood.toLowerCase() == mood.toLowerCase();
                  return ChoiceChip(
                    label: Text(
                      mood,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(quoteProvider.notifier).setMood(mood);
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
