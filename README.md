AI Food App - package (lib + backend)

Folders:
- lib/: Flutter frontend source
- backend/: Node.js serverless APIs to be deployed on Vercel (put under backend/api)

How to use:
1. Create a Flutter project and replace its lib/ folder with this lib/ folder.
2. Add dependencies from pubspec.yaml (firebase_core, firebase_auth, cloud_firestore, google_sign_in, http).
3. Build web: flutter build web --dart-define=API_BASE_URL=https://<your-vercel-url> --dart-define=FIREBASE_API_KEY=<...> --dart-define=...
4. In backend, run `npm install` and deploy backend/api/*.js to Vercel (or push entire repo and configure vercel.json).
5. Set environment variables on Vercel: HUGGINGFACE_API_KEY, QDRANT_URL, QDRANT_API_KEY, GEMINI_API_KEY, FIREBASE_*

Notes:
- Do not commit API keys. Use Vercel environment variables.
- The backend has demo fallbacks so you can test without keys.
