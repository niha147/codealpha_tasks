import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/quote_provider.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/quote_card.dart';
import '../../widgets/action_button_bar.dart';
import '../../widgets/mood_selector_bottom_sheet.dart';
import '../favorites/favorites_screen.dart';
import '../../core/services/share_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey _globalKey = GlobalKey();
  final ShareService _shareService = ShareService();
  bool _isFocusMode = false;
  bool _showFocusHint = false;

  void _shareQuoteImage() async {
    try {
      await _shareService.shareQuoteImage(_globalKey);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share. Did you fully restart the app? Error: $e')),
        );
      }
    }
  }

  void _showMoodSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const MoodSelectorBottomSheet(),
    );
  }

  void _toggleFocusMode() {
    setState(() {
      _isFocusMode = !_isFocusMode;
      if (_isFocusMode) {
        _showFocusHint = true;
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showFocusHint = false);
        });
      }
    });
  }

  void _exitFocusMode() {
    if (_isFocusMode) {
      setState(() {
        _isFocusMode = false;
        _showFocusHint = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedOpacity(
          opacity: _isFocusMode ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Quotiva', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: _isFocusMode ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.nights_stay_rounded),
                tooltip: "Focus Mode",
                onPressed: _toggleFocusMode,
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onDoubleTap: _exitFocusMode,
        onLongPress: _exitFocusMode, // Added long press to exit for better UX
        onTap: () {
          if (_isFocusMode) {
            ref.read(quoteProvider.notifier).generateNewQuote();
          }
        },
        child: AnimatedGradientBackground(
          child: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  // Use Consumer to isolate rebuilds ONLY to the quote and action bar
                  child: Consumer(
                    builder: (context, ref, child) {
                      final quoteState = ref.watch(quoteProvider);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          if (quoteState.isLoading)
                            const Center(child: CircularProgressIndicator(color: Colors.white))
                          else if (quoteState.currentQuote != null)
                            RepaintBoundary(
                              key: _globalKey,
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.transparent),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 600),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.0, 0.1),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: GlassCard(
                                    key: ValueKey(quoteState.currentQuote!.text),
                                    child: QuoteCard(quote: quoteState.currentQuote!),
                                  ),
                                ),
                              ),
                            )
                          else
                            const Center(child: Text('No quotes available')),
                          const Spacer(),
                          if (quoteState.currentQuote != null)
                            AnimatedOpacity(
                              opacity: _isFocusMode ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: IgnorePointer(
                                ignoring: _isFocusMode,
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  borderRadius: 30.0,
                                  child: ActionButtonBar(
                                    currentQuote: quoteState.currentQuote!,
                                    onSharePressed: _shareQuoteImage,
                                    onMoodPressed: _showMoodSelector,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
              ),
              // Focus Mode Hint Toast
              if (_isFocusMode)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  top: _showFocusHint ? MediaQuery.of(context).padding.top + kToolbarHeight : -100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _showFocusHint ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Double tap or long press to exit",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
