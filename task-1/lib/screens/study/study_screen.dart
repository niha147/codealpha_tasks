import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/study_session_provider.dart';
import '../../providers/stats_provider.dart';
import '../../widgets/flip_card.dart';

class StudyScreen extends StatefulWidget {
  final String? categoryId;
  const StudyScreen({super.key, this.categoryId});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fp = Provider.of<FlashcardProvider>(context, listen: false);
      final sp = Provider.of<StudySessionProvider>(context, listen: false);
      
      final cards = widget.categoryId != null 
          ? fp.getFlashcardsByCategory(widget.categoryId!)
          : fp.flashcards;
          
      sp.startSession(cards);
    });
  }

  @override
  void dispose() {
    final sp = Provider.of<StudySessionProvider>(context, listen: false);
    final stats = Provider.of<StatsProvider>(context, listen: false);
    if (sp.cardsReviewed > 0) {
      stats.recordStudySession(sp.secondsElapsed, sp.cardsReviewed);
    }
    sp.stopSession();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudySessionProvider>(
      builder: (context, studyProv, _) {
        final cards = studyProv.studyCards;
        if (cards.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Study Session')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No Flashcards to study.', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          );
        }

        final currentCard = cards[studyProv.currentIndex];
        final progress = (studyProv.currentIndex + 1) / cards.length;

        return Scaffold(
          appBar: AppBar(
            title: Text(_formatDuration(studyProv.secondsElapsed)),
            actions: [
              IconButton(
                icon: Icon(studyProv.isShuffle ? Icons.shuffle_on : Icons.shuffle),
                onPressed: studyProv.toggleShuffle,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 16),
                Text(
                  'Card ${studyProv.currentIndex + 1} of ${cards.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GestureDetector(
                    onTap: studyProv.flipCard,
                    child: FlipCardWidget(
                      isFlipped: studyProv.isFlipped,
                      front: _buildCardSide(context, currentCard.question, 'Question'),
                      back: _buildCardSide(context, currentCard.answer, 'Answer', isAnswer: true),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: studyProv.flipCard,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(studyProv.isFlipped ? 'Hide Answer' : 'Show Answer'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: studyProv.currentIndex > 0 ? studyProv.previousCard : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                    Consumer<FlashcardProvider>(
                      builder: (context, fp, _) => IconButton(
                        icon: Icon(
                          currentCard.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: currentCard.isFavorite ? Colors.pink : null,
                          size: 32,
                        ),
                        onPressed: () => fp.toggleFavorite(currentCard.id),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: studyProv.currentIndex < cards.length - 1 ? studyProv.nextCard : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardSide(BuildContext context, String text, String label, {bool isAnswer = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: isAnswer ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isAnswer ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.6) : Colors.grey,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isAnswer ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
