# Firebase Setup Guide for Noctis To Do

This guide will walk you through setting up Firebase for your Noctis To Do application.

## 🚀 Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project" (or "Add project")
3. Enter a project name (e.g., "noctis-todo")
4. Follow the setup wizard (you can disable Google Analytics if you want)

## 🔐 Step 2: Enable Authentication

1. In your Firebase project, go to "Authentication" in the left sidebar
2. Click "Get started"
3. Go to the "Sign-in method" tab
4. Enable "Google" as a sign-in provider
5. Configure the OAuth consent screen:
   - Add your project name
   - Add your support email
   - Click "Save"

## 💾 Step 3: Set up Firestore Database

1. Go to "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in production mode" (we'll set up rules later)
4. Select your preferred location (choose one close to your users)
5. Click "Enable"

### Database Rules

Once created, go to the "Rules" tab and replace the rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own todos
    match /todos/{todoId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
  }
}
```

Click "Publish" to save the rules.

## 🔑 Step 4: Get Your Configuration

1. Go to Project Settings (gear icon in the sidebar)
2. Scroll down to "Your apps" section
3. Click on the web icon (</>)
4. Register your app with a nickname (e.g., "noctis-todo-web")
5. Copy the Firebase configuration object

## 📝 Step 5: Set Up Environment Variables

1. In your project root, create a file named `.env.local`
2. Add your Firebase configuration:

```env
REACT_APP_FIREBASE_API_KEY=your_api_key_here
REACT_APP_FIREBASE_AUTH_DOMAIN=your_auth_domain_here
REACT_APP_FIREBASE_PROJECT_ID=your_project_id_here
REACT_APP_FIREBASE_STORAGE_BUCKET=your_storage_bucket_here
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id_here
REACT_APP_FIREBASE_APP_ID=your_app_id_here
```

⚠️ **Important**: Never commit `.env.local` to Git!

## 🌐 Step 6: Configure OAuth Redirect URIs

1. Go to the [Google Cloud Console](https://console.cloud.google.com)
2. Select your Firebase project
3. Go to "APIs & Services" → "Credentials"
4. Find your OAuth 2.0 Client ID (created by Firebase)
5. Add authorized redirect URIs:
   - `http://localhost:3000` (for development)
   - `http://localhost:3001` (alternative port)
   - Your production domain (when you deploy)

## 🚀 Step 7: Deploy to Firebase Hosting

### Install Firebase CLI

```bash
npm install -g firebase-tools
```

### Initialize Firebase in your project

```bash
firebase login
firebase init
```

Select:
- **Hosting**: Configure files for Firebase Hosting
- Use an existing project → Select your Firebase project
- Public directory: `build`
- Configure as single-page app: `Yes`
- Set up automatic builds with GitHub: `No` (optional)

### Build and Deploy

```bash
npm run build
firebase deploy
```

Your app will be available at:
- `https://your-project-id.web.app`
- `https://your-project-id.firebaseapp.com`

## 📱 Step 8: Update OAuth Settings for Production

Once deployed, go back to Google Cloud Console and add your production URLs to the authorized redirect URIs.

## 🔄 Continuous Deployment (Optional)

You can set up GitHub Actions for automatic deployment:

Create `.github/workflows/firebase-hosting.yml`:

```yaml
name: Deploy to Firebase Hosting

on:
  push:
    branches: [ main ]

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run build
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: your-project-id
```

## 🎉 Done!

Your Noctis To Do app is now:
- ✅ Connected to Firebase
- ✅ Using Google Authentication
- ✅ Storing data in Firestore
- ✅ Ready to deploy

## 🐛 Troubleshooting

### "Permission denied" errors
- Check your Firestore rules
- Ensure you're logged in
- Verify the userId matches in the database

### Google Sign-in not working
- Check OAuth redirect URIs
- Ensure Google auth is enabled in Firebase
- Check browser console for errors

### Data not showing up
- Check Firestore database in Firebase Console
- Verify the collection name is "todos"
- Check browser console for errors

## 📚 Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Hosting](https://firebase.google.com/docs/hosting) 