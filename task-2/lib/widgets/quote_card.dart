import 'package:flutter/material.dart';
import '../models/quote.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isExport;

  const QuoteCard({
    Key? key,
    required this.quote,
    this.isExport = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.format_quote_rounded,
          color: Colors.white.withOpacity(0.5),
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          quote.text,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: isExport ? 40 : 32,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Text(
          "— ${quote.author}",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontStyle: FontStyle.italic,
            fontSize: isExport ? 20 : 16,
          ),
          textAlign: TextAlign.right,
        ),
        if (isExport) ...[
          const SizedBox(height: 64),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.7), size: 16),
              const SizedBox(width: 8),
              Text(
                "Quotiva",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          )
        ]
      ],
    );
  }
}
