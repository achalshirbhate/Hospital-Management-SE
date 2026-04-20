# 🚀 TelePatient Deployment Checklist

## ✅ Step 1: Code Pushed to GitHub
**Status: COMPLETE** ✓

Your code is now on GitHub at:
`https://github.com/achalshirbhate/Hospital-Management-SE`

---

## 📋 Step 2: Deploy to Render (Do This Now)

### 2.1 Create Render Account
1. Go to: **https://dashboard.render.com**
2. Click **"Get Started"** or **"Sign Up"**
3. Choose **"Sign up with GitHub"** (easiest option)
4. Authorize Render to access your GitHub account

### 2.2 Create Web Service
1. In Render Dashboard, click **"New +"** button (top right)
2. Select **"Web Service"**
3. You'll see your repositories - find and click **"Connect"** next to:
   ```
   achalshirbhate/Hospital-Management-SE
   ```

### 2.3 Configure Service
Render will auto-detect your `render.yaml` file. Verify these settings:

| Setting | Value |
|---------|-------|
| **Name** | `telepatient-api` (or your choice) |
| **Runtime** | Java |
| **Build Command** | `mvn clean package -DskipTests` |
| **Start Command** | `java -Xmx400m -Xms200m -jar target/auth-service-0.0.1-SNAPSHOT.jar` |
| **Plan** | Free |

Click **"Create Web Service"** (don't worry about env vars yet)

### 2.4 Add Environment Variables
After service is created, go to **"Environment"** tab on the left.

Click **"Add Environment Variable"** and add these **one by one**:

```
DB_URL
jdbc:postgresql://aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres?sslmode=require&prepareThreshold=0

DB_USERNAME
postgres.dkksbddtojuhhbdkyvad

DB_PASSWORD
Ach@l789Achal

DB_POOL_SIZE
3

MAIL_USERNAME
aachalshirbhate4@gmail.com

MAIL_PASSWORD
jmjwhcgnzadujvph

JWT_SECRET
TelePatient$SuperSecret$Key$LocalDev$Only$NotForProd

JWT_EXPIRATION
86400000

CORS_ALLOWED_ORIGINS
*

DDL_AUTO
update

SPRING_PROFILES_ACTIVE
prod
```

After adding all variables, click **"Save Changes"**

### 2.5 Wait for Deployment
- Render will automatically redeploy (5-10 minutes)
- Watch the **"Logs"** tab to see progress
- Look for this message:
  ```
  Started AuthServiceApplication in X.XXX seconds
  ```
- When you see **"Your service is live 🎉"** - you're done!

### 2.6 Copy Your Backend URL
At the top of the Render dashboard, you'll see your service URL:
```
https://telepatient-api.onrender.com
```
**COPY THIS URL** - you need it for the next step!

---

## 📱 Step 3: Update Flutter App (Tell Me Your URL)

Once you have your Render URL, **tell me** and I will:

1. ✏️ Update `telepatient_app/lib/utils/constants.dart` with your URL
2. 🔧 Update WebSocket URL for video calls
3. 📦 Help you rebuild the APK
4. ✅ Guide you through testing

**Example:** "My Render URL is https://telepatient-api-xyz.onrender.com"

---

## 🧪 Step 4: Test Your Deployment

### Test Backend Health
Open this URL in your browser (replace with your URL):
```
https://your-render-url.onrender.com/actuator/health
```

You should see:
```json
{"status":"UP"}
```

### Test Login API
Use Postman or browser to test:
```
POST https://your-render-url.onrender.com/api/auth/login
Content-Type: application/json

{
  "email": "admin@123",
  "password": "admin"
}
```

Should return a JWT token.

---

## ⚠️ Important Notes

### Free Tier Behavior
- **Sleeps after 15 minutes** of inactivity
- **First request takes 30-60 seconds** to wake up
- This is normal for Render free tier

### If App Shows Connection Error
1. Visit the health endpoint to wake up the backend
2. Wait 30-60 seconds
3. Try logging in again

### Upgrade Options
- **Starter Plan ($7/month)**: Always-on, no sleep
- **Professional Plan ($25/month)**: More resources, faster

---

## 🎯 Current Status

- [x] Code pushed to GitHub
- [ ] Render account created
- [ ] Web service deployed
- [ ] Environment variables configured
- [ ] Backend URL obtained
- [ ] Flutter app updated
- [ ] New APK built
- [ ] App tested on phone

---

## 🆘 Need Help?

**Deployment fails?**
- Check Render logs for errors
- Verify all environment variables are correct
- Make sure you're using Java runtime

**Can't find environment variables?**
- Look for "Environment" tab in left sidebar
- Click "Add Environment Variable" button
- Add them one at a time

**Backend won't start?**
- Check logs for database connection errors
- Verify Supabase credentials are correct
- Make sure DB_POOL_SIZE is set to 3

---

## 📞 Next Step

**Go to Render now and start deployment!**

When you have your backend URL, come back and tell me:
> "My Render URL is https://..."

I'll update your Flutter app and help you build the final APK! 🚀
