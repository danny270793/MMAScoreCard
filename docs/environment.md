# Environment variables (`.env.json`)

Flutter bakes `String.fromEnvironment` values into the binary at **build** time. There are no runtime env vars for these keys. Pass them with `--dart-define-from-file=.env.json`.

## Fill the file

1. Copy the template (already gitignored destination):

   ```sh
   cp .env.example.json .env.json
   ```

2. Replace the placeholders with the same Supabase project values used by Wallet (Dashboard → Project Settings → API):

   ```json
   {
     "SUPABASE_URL": "https://<project-ref>.supabase.co",
     "SUPABASE_ANON_KEY": "<anon-or-publishable-key>"
   }
   ```

3. Never commit `.env.json`. Commit `.env.example.json` only.

## Use it

```sh
asdf exec flutter run --dart-define-from-file=.env.json
asdf exec flutter build apk --dart-define-from-file=.env.json
asdf exec flutter build ipa --dart-define-from-file=.env.json
```

## CI

Store `SUPABASE_URL` and `SUPABASE_ANON_KEY` as pipeline secrets, then:

```yaml
flutter build apk \
  --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
  --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
```

## Keys

The **anon / publishable** key is meant for clients. Data protection is **Row Level Security**, not secrecy of this key. Keep it out of git anyway.

Never put the **service role** key in the app or in `.env.json`.
