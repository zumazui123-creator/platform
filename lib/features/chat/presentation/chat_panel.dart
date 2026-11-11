import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/health_area.dart';
import '../../../core/domain/metric_series.dart';
import '../../data/providers.dart';

/// Ein Chat-Nachricht (lokal, ohne Persistenz in dieser Version).
class _ChatMsg {
  _ChatMsg(this.text, this.fromUser, this.time);

  final String text;
  final bool fromUser;
  final DateTime time;
}

/// Coach-Chat als eigener Tab in der Bottom-Bar (Mobile-First-Layout).
///
/// Antwortet lokal mit kontextbezogenen Hinweisen auf Basis der
/// aktuell verfügbaren Messreihen des aktiven Bereichs. Klar als
/// lokale Demo-Antwort gekennzeichnet — ein echter LLM-/Supabase-
/// Edge-Function-Anschluss ist der nächste Ausbauschritt.
class ChatPanel extends ConsumerStatefulWidget {
  const ChatPanel({required this.area, super.key});

  final HealthArea area;

  @override
  ConsumerState<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends ConsumerState<ChatPanel> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_ChatMsg> _messages = [];
  bool _busy = false;

  static const List<String> _greetings = [
    'Hallo! Ich bin dein Coach für den Bereich „Gesundheit“. Frag mich z. B. nach deinen letzten Werten.',
    'Hallo! Ich blicke auf deine Fitness-Daten. Wie lief dein Training?',
    'Hallo! Schön, dass du da bist. Wie war dein Schlaf in letzter Zeit?',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _seed());
  }

  void _seed() {
    final i = widget.area.index % _greetings.length;
    _messages.add(_ChatMsg(_greetings[i], false, DateTime.now()));
  }

  @override
  void didUpdateWidget(covariant ChatPanel old) {
    super.didUpdateWidget(old);
    if (old.area != widget.area) {
      _messages
        ..clear()
        ..add(
          _ChatMsg(
            _greetings[widget.area.index % _greetings.length],
            false,
            DateTime.now(),
          ),
        );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _busy) return;
    _ctrl.clear();
    _messages.add(_ChatMsg(text, true, DateTime.now()));
    _scrollToBottom();
    setState(() => _busy = true);

    // Sicherstellen, dass die Messreihen des Bereichs geladen sind —
    // die erste Frage darf nicht vor dem Repository-Antwort eintreffen
    // (FutureProvider liefert beim ersten Read sonst AsyncLoading).
    List<MetricSeries>? series;
    try {
      series = await ref.read(seriesByAreaProvider(widget.area).future);
    } catch (_) {
      series = null;
    }
    if (!mounted) return;

    // Antwort bauen (mit echten, verfügbaren Daten, falls vorhanden).
    final reply = _coachReply(text, series);

    // Kleine Verzögerung für ein natürliches Gefühl.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMsg(reply, false, DateTime.now()));
      _busy = false;
    });
    _scrollToBottom();
  }

  String _coachReply(String question, List<MetricSeries>? series) {
    if (series == null || series.isEmpty) {
      return 'Ich habe gerade keine Messwerte für „${widget.area.label}“ '
          'vor mir. Trage erst Werte ein, dann kann ich Trends sehen.';
    }
    final lq = question.toLowerCase();
    bool q(List<String> keywords) => keywords.any((k) => lq.contains(k));

    // 1) Frage nach einem konkreten Wert/Trend
    for (final s in series) {
      if (q([s.name.toLowerCase().split(' ').first, _shortName(s)])) {
        final last = s.last;
        final (lastV, delta) = _lastAndDelta(s);
        if (last == null) continue;
        final trend = delta == null
            ? ''
            : (delta >= 0
                  ? ' (im Vergleich zur Vorwoche: +'
                        '${_fmt(delta.abs())} ${s.unit})'
                  : ' (im Vergleich zur Vorwoche: −'
                        '${_fmt(delta.abs())} ${s.unit})');
        return 'Dein letzter Wert für ${s.name}: '
            '${_fmt(lastV)} ${s.unit}$trend. '
            'Willst du einen Verlauf als Diagramm im Dashboard sehen?';
      }
    }

    // 2) Stimmung/Stress-Fragen
    if (widget.area == HealthArea.psychologie &&
        q(['müde', 'schlaf', 'stress', 'stimmung', 'kaputt', 'energie'])) {
      final mood = series.firstWhere(
        (s) => s.id == 'psych-mood',
        orElse: () => series.first,
      );
      final last = mood.last;
      return last == null
          ? 'Erzähl mir mehr — wie beschreibst du deine aktuelle Verfassung in 1–10?'
          : 'Deine letzte Stimmungsbewertung: ${_fmt(last)} von 10. '
                'Was könnte heute helfen: kurzer Spaziergang, früh zu Bett gehen oder eine Pause?';
    }

    // 3) Fitness-Fragen
    if (widget.area == HealthArea.fitness &&
        q(['train', 'lauf', 'workout', 'sport', 'schritte'])) {
      final steps = series.firstWhere(
        (s) => s.id == 'fitness-steps',
        orElse: () => series.first,
      );
      final last = steps.last;
      return last == null
          ? 'Noch keine Trainingsdaten zu sehen. Wie sah dein letztes Training aus?'
          : 'Letzte Aktivität: ${_fmt(last)} ${steps.unit}. '
                'Kleiner Tipp: Regelmäßigkeit schlägt Intensität — wie wäre es mit 20 Minuten heute?';
    }

    // 4) Gesundheit-Fragen
    if (widget.area == HealthArea.gesundheit &&
        q(['gewicht', 'blutdruck', 'zucker', 'puls'])) {
      final w = series.firstWhere(
        (s) => s.id == 'health-weight',
        orElse: () => series.first,
      );
      final last = w.last;
      return last == null
          ? 'Ich habe noch keine Werte zu sehen. Wogst du dich diese Woche?'
          : 'Letzter Wert: ${_fmt(last)} ${w.unit}. '
                'Mein Rat: gleiche Bedingungen beim Messen (morgens, nach dem Toilettengang) — dann bleiben die Werte vergleichbar.';
    }

    // Fallback
    return 'Gute Frage! Am besten funktioniert es, wenn du mich nach einem '
        'konkreten Wert fragst (z. B. „Gewicht“ oder „Schlaf“) — dann antworte ich '
        'mit deinen aktuellen Daten.';
  }

  String _shortName(MetricSeries s) {
    // Kurzform für Keyword-Matches: „Körpergewicht“ → „gewicht“ etc.
    final n = s.name.toLowerCase();
    if (n.contains('gewicht')) return 'gewicht';
    if (n.contains('schlaf')) return 'schlaf';
    if (n.contains('schritt')) return 'schritte';
    if (n.contains('stimmung')) return 'stimmung';
    if (n.contains('stress')) return 'stress';
    if (n.contains('kalori')) return 'kalorien';
    if (n.contains('puls')) return 'puls';
    if (n.contains('blutdruck')) return 'blutdruck';
    return n.split(' ').first;
  }

  (double last, double? delta) _lastAndDelta(MetricSeries s) {
    if (s.points.isEmpty) return (0, null);
    final last = s.points.last.value;
    final idx = s.points.length - 1 - 7;
    if (idx < 0) return (last, null);
    return (last, last - s.points[idx].value);
  }

  String _fmt(double v) => v.abs() >= 100
      ? v.toStringAsFixed(0)
      : v.toStringAsFixed(1).replaceAll('.', ',');

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? const SizedBox.shrink()
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length + (_busy ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == _messages.length) {
                      return const _TypingIndicator();
                    }
                    final m = _messages[i];
                    return _Bubble(msg: m);
                  },
                ),
        ),
        // Hinweiszeile
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'Lokaler Coach-Demo-Assistent — kein medizinischer Rat.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.outline,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Frag deinen Coach …',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Senden',
                onPressed: _send,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});

  final _ChatMsg msg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mine = msg.fromUser;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: mine
              ? scheme.primary
              : scheme.surfaceContainerHighest.withValues(alpha: 0.7),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(mine ? 14 : 4),
            bottomRight: Radius.circular(mine ? 4 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: mine ? scheme.onPrimary : scheme.onSurface,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 9,
                color: (mine ? scheme.onPrimary : scheme.onSurfaceVariant)
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: scheme.outline,
          ),
        ),
      ),
    );
  }
}
