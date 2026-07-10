import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../models/quote.dart';
import '../providers/favorites_provider.dart';
import '../providers/quote_provider.dart';
import 'bouncing_button.dart';

class ActionButtonBar extends ConsumerWidget {
  final Quote currentQuote;
  final VoidCallback onSharePressed;
  final VoidCallback onMoodPressed;

  const ActionButtonBar({
    super.key,
    required this.currentQuote,
    required this.onSharePressed,
    required this.onMoodPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider.notifier).isFavorite(currentQuote);
    ref.watch(favoritesProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(
          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.redAccent : Colors.white,
          onPressed: () {
            ref.read(favoritesProvider.notifier).toggleFavorite(currentQuote);
          },
        ),
        _buildIconButton(
          icon: Icons.copy_rounded,
          onPressed: () async {
            await Clipboard.setData(ClipboardData(
                text: '"${currentQuote.text}" - ${currentQuote.author}'));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quote copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        _buildMainCTA(context, ref),
        _buildIconButton(
          icon: Icons.mood,
          onPressed: onMoodPressed,
        ),
        _buildIconButton(
          icon: Icons.ios_share_rounded,
          onPressed: onSharePressed,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white,
  }) {
    return BouncingButton(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _buildMainCTA(BuildContext context, WidgetRef ref) {
    return BouncingButton(
      onTap: () {
        ref.read(quoteProvider.notifier).generateNewQuote();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              "New",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
