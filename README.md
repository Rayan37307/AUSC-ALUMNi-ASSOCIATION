# AUSC Alumni Management App

A Flutter application for managing alumni data of **Aftab Uddin School & College (AUSC)**.

## Features

- ✅ **Alumni List** - View all alumni in a scrollable list with cards
- ✅ **Search** - Search alumni by name, position, or current activity
- ✅ **Add Alumni** - Add new alumni with comprehensive information
- ✅ **Alumni Details** - View full alumni information
- ✅ **Edit/Delete** - Manage alumni records
- ✅ **Pull-to-Refresh** - Refresh data on all list screens
- ✅ **Dark Mode** - Full dark mode support
- ✅ **Offline Cache** - 5-minute cache for offline access
- ✅ **Modern UI** - Clean, Material Design 3 interface

## Tech Stack

- **Framework**: Flutter 3.x
- **Backend**: Supabase (PostgreSQL with auto-generated API)
- **State Management**: Provider
- **Navigation**: Go Router
- **Local Caching**: SharedPreferences

## Quick Start

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Set Up Supabase (5 minutes)

**Your Supabase Project:** https://app.supabase.com/project/mefthrvjlcwsoflvwuvj

#### Step A: Run SQL Setup

1. Go to **SQL Editor**: https://app.supabase.com/project/mefthrvjlcwsoflvwuvj/sql/new
2. Copy and paste the content from `supabase_setup.sql` file
3. Click **Run**

Or run this SQL directly:

```sql
CREATE TABLE alumni (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  village TEXT DEFAULT '',
  post_office TEXT DEFAULT '',
  upazila TEXT DEFAULT '',
  district TEXT DEFAULT '',
  currently_doing TEXT DEFAULT '',
  achievements TEXT DEFAULT '',
  batch_year TEXT NOT NULL,
  position TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE alumni ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all access" ON alumni FOR ALL USING (true) WITH CHECK (true);
CREATE INDEX idx_alumni_created_at ON alumni(created_at DESC);
```

#### Step B: Verify Credentials

Your `.env` file already has the credentials:
- **URL**: https://mefthrvjlcwsoflvwuvj.supabase.co
- **Key**: sb_publishable_1Gfqa6YbiD0PotDQbxMe7g_oXBL83v4

### 3. Run the App

```bash
flutter run
```

## Build APK

### Debug APK
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants
│   ├── theme/           # Theme and colors
│   ├── widgets/         # Reusable widgets
│   └── router.dart      # Navigation
├── data/
│   ├── models/          # Alumni model
│   ├── repositories/    # Repository pattern
│   └── sources/
│       ├── local/       # Cache (SharedPreferences)
│       └── remote/      # Supabase
├── presentation/
│   ├── providers/       # State management
│   └── screens/         # UI screens
└── main.dart
```

## Supabase vs Firestore

| Operation | Supabase | Firestore |
|-----------|----------|-----------|
| Initialize | `Supabase.initialize()` | `Firebase.initializeApp()` |
| Get all | `.from('table').select()` | `.collection('col').get()` |
| Insert | `.insert(data)` | `.add(data)` |
| Update | `.update(data).eq('id', id)` | `.doc(id).update(data)` |
| Delete | `.delete().eq('id', id)` | `.doc(id).delete()` |
| Query | `.select().eq('field', value)` | `.where('field', isEqualTo: value)` |

## Supabase Free Tier (2026)

- ✅ **500MB** database storage
- ✅ **50,000** monthly active users
- ✅ **Unlimited** API requests
- ✅ **5GB** bandwidth/month
- ✅ **Never expires**

## Database Schema

```sql
alumni (
  id: UUID (primary key)
  name: TEXT (not null)
  phone: TEXT (not null)
  village: TEXT
  post_office: TEXT
  upazila: TEXT
  district: TEXT
  currently_doing: TEXT
  achievements: TEXT
  batch_year: TEXT (not null)
  position: TEXT
  created_at: TIMESTAMPTZ
  updated_at: TIMESTAMPTZ
)
```

## Dependencies

```yaml
supabase_flutter: ^2.12.0
provider: ^6.1.1
go_router: ^12.1.1
shared_preferences: ^2.2.2
flutter_dotenv: ^5.1.0
intl: ^0.18.1
```

## Development

### Run Analyzer
```bash
flutter analyze
```

### Format Code
```bash
dart format .
```

### Clean Build
```bash
flutter clean && flutter pub get
```

## Production Checklist

- [ ] Restrict RLS policies (don't allow all access)
- [ ] Add authentication if needed
- [ ] Set up database backups
- [ ] Configure custom domain (optional)
- [ ] Monitor usage in Supabase dashboard

## Troubleshooting

### "Failed to fetch alumni"
- Check Supabase URL and anon key in `.env`
- Verify `alumni` table exists in Supabase
- Check RLS policies allow read access

### Build fails
```bash
flutter clean
flutter pub get
flutter run
```

### No data showing
- Run the SQL create table script in Supabase SQL Editor
- Add some test data manually in Supabase dashboard

## License

Educational use.

## Support

Create an issue for bugs or questions.

---

**Built with Flutter + Supabase**
