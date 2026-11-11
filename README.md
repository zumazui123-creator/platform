# health_platform

Gesundheits-Dashboard-App (Flutter, Web-first) mit drei Bereichen:
**Gesundheit**, **Fitness**, **Psychologie**. Jeder Bereich hat eigene
Messreihen, ein konfigurierbares Dashboard (UI-Baukasten) und einen
Coach-Chat.

## Architektur

Feature-first mit klaren Schichten (Domain framework-frei → unit-testbar):

```
lib/
├── core/                 # Domain-Modelle (HealthArea, MetricSeries), Errors,
│                         #   Env, Provider-Infra, Theme
├── app.dart              # MaterialApp.router + Material-3 Light/Dark-Theme
├── main.dart             # Bootstrap: Supabase (optional) + SharedPreferences
└── features/
    ├── auth/             # AuthStatus (sealed), Supabase-Auth / Demo-Auth
    ├── data/             # MetricSeriesRepository (Demo / Supabase), Serien-Katalog
    ├── charts/           # ChartEngine: MetricSeries → fl_chart-Daten (unit-testbar)
    ├── dashboard/        # UI-Baukasten: freezed-Schema, Validator, JSON-Gateway,
    │                     #   Riverpod-Store, Editor, Widget-Registry (7 Bausteine)
    ├── chat/             # Coach-Chat (Spalte / Bottom-Sheet)
    ├── main/             # MainShell: 80/20-Layout (Rail | Dashboard | Chat)
    └── navigation/       # go_router mit Auth-Guard, Bereichs-Icons
```

### UI-Baukasten

Dashboards sind **reine Datenkonfiguration** (versioniertes JSON-Schema,
`schemaVersion: 1`). Es wird niemals Code aus Konfiguration geladen:

- **7 Baustein-Typen:** Zahlenkarte, Statistik-Karte (Trend), Liniendiagramm,
  Balkendiagramm, Kreisdiagramm, Fortschrittsanzeige, Tabelle
- **4-Spalten-Raster**, Größen in Raster-Einheiten (plattformunabhängig)
- **Fail-closed-Validierung** an jeder Grenze: `DashboardValidator` +
  `parseLayoutString` (JSON-Gateway) + Store (jede Mutation)
- **Editor:** Bausteine hinzufügen/entfernen/verschieben/resize,
  Serie + Ziele pro Baustein, mehrere Layouts pro Bereich

### Daten & Persistenz

| Modus | Auth | Messwerte | Layouts |
|---|---|---|---|
| **Demo** (Default) | Demo-Nutzer (klar im UI gekennzeichnet) | Deterministische Demo-Daten | `shared_preferences` (geseedet) |
| **Supabase** (konfiguriert) | Supabase Auth | `metric_points` (RLS `user_id = auth.uid()`) | `dashboard_layouts` (RLS) |

Ohne Konfiguration läuft alles im Demo-Modus — die App startet sofort mit
sinnvollem Inhalt (Standard-Layouts pro Bereich).

## Supabase einrichten (optional)

1. Tabellen `metric_points` + `dashboard_layouts` anlegen (Schemas in den
   Repository-Docs unter `features/data/supabase/` und
   `features/dashboard/data/`)
2. Row Level Security: alle Operationen auf `user_id = auth.uid()`
3. Build-Konfiguration über `lib/core/env.dart` (z. B. `--dart-define`)

## Entwicklung

```bash
flutter pub get
flutter analyze        # 0 Probleme
flutter test           # 46 Tests
dart format lib test
flutter run -d chrome
```

## Qualitätsgate

- `flutter analyze` — 0 Issues (auch info-Level)
- `flutter test` — 46 Tests: Schema-JSON (Roundtrip + Rejection), Validator,
  ChartEngine, Repositories (Seed/Save/Delete/fail-closed), Demo-Daten,
  HealthArea
- `dart format` — formatiert
