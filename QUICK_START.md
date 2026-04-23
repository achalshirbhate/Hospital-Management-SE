# Quick Start: Deploy TelePatient to Render

## 🚀 Follow These Steps

### 1️⃣ Push Code to GitHub (2 minutes)

Open Git Bash or PowerShell in your project folder:

```bash
git add .
git commit -m "Prepare for Render deployment"
git push origin main
```

### 2️⃣ Deploy to Render (10 minutes)

1. **Go to Render**: https://dashboard.render.com
2. **Sign up/Login** (use your GitHub account for easy setup)
3. **Click "New +"** → Select **"Web Service"**
4. **Connect GitHub** and select repository: `achalshirbhate/Hospital-Management-SE`
5. **Render will auto-detect** your `render.yaml` file
6. **Click "Create Web Service"**

### 3️⃣ Add Environment Variables in Render

In the Render dashboard, go to **Environment** tab and add these:

| Key | Value |
|-----|-------|
| `DB_URL` | `jdbc:postgresql://aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres?sslmode=require&prepareThreshold=0` |
| `DB_USERNAME` | `postgres.dkksbddtojuhhbdkyvad` |
| `DB_PASSWORD` | `Ach@l789Achal` |
| `MAIL_USERNAME` | `aachalshirbhate4@gmail.com` |
| `MAIL_PASSWORD` | `jmjwhcgnzadujvph` |
| `JWT_SECRET` | `TelePatient$SuperSecret$Key$LocalDev$Only$NotForProd` |

Click **"Save Changes"** - Render will automatically redeploy.

### 4️⃣ Wait for Deployment (5-10 minutes)

Watch the logs in Render dashboard. When you see:
```
Started AuthServiceApplication in X seconds
```
Your backend is live! 🎉

### 5️⃣ Copy Your Backend URL

In Render dashboard, you'll see a URL like:
```
https://telepatient-api.onrender.com
```
**Copy this URL** - you need it for the next step.

### 6️⃣ Update Flutter App

I'll help you update the Flutter app with your Render URL.

**What's your Render backend URL?** (You'll get this after step 5)

Example: `https://telepatient-api.onrender.com`

---

## ⚠️ Important Notes

- **First request is slow**: Render free tier sleeps after 15 minutes. First request takes 30-60 seconds to wake up.
- **Test backend**: Visit `https://your-url.onrender.com/actuator/health` - should show `{"status":"UP"}`
- **Rebuild APK**: After updating the URL, you must rebuild the APK for changes to take effect.

---

## 🆘 Troubleshooting

**Deployment failed?**
- Check Render logs for errors
- Verify all environment variables are set

**App still can't connect?**
- Make sure you updated the URL in `constants.dart`
- Rebuild the APK: `flutter build apk --release`
- Backend might be sleeping - visit the health endpoint to wake it

**Database errors?**
- Check Supabase is active
- Verify database credentials in Render environment variables

---

## 📱 After Deployment

Once your backend is deployed and you have the URL, tell me and I'll:
1. Update your Flutter app configuration
2. Help you rebuild the APK
3. Guide you through testing

**Ready? Let's deploy! 🚀**
