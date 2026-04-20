# 🎯 Render Setup - Visual Step-by-Step Guide

## What You'll Do
1. Sign up on Render (2 minutes)
2. Connect your GitHub repo (1 minute)
3. Add environment variables (5 minutes)
4. Wait for deployment (5-10 minutes)
5. Get your backend URL (1 minute)

**Total Time: ~15-20 minutes**

---

## Step 1: Go to Render

Open your browser and go to:
```
https://dashboard.render.com
```

Click **"Get Started"** or **"Sign Up"**

---

## Step 2: Sign Up with GitHub

Click the **"Sign up with GitHub"** button

This is the easiest way - no need to create a new account!

Authorize Render when GitHub asks for permission.

---

## Step 3: Create New Web Service

Once you're in the Render Dashboard:

1. Look for the **"New +"** button (usually top right corner)
2. Click it
3. Select **"Web Service"** from the dropdown

---

## Step 4: Connect Repository

You'll see a list of your GitHub repositories.

Find: **`achalshirbhate/Hospital-Management-SE`**

Click the **"Connect"** button next to it.

> **Don't see your repo?** Click "Configure account" to give Render access to your repositories.

---

## Step 5: Configure Service Settings

Render will show a configuration form. Fill it out:

### Basic Settings
```
Name: telepatient-api
(or any name you prefer - this will be part of your URL)

Region: Oregon (US West)
(or choose the closest region to you)

Branch: main
(should be auto-selected)

Root Directory: (leave blank)
```

### Build & Deploy
```
Runtime: Java
(Render should auto-detect this)

Build Command: mvn clean package -DskipTests
(should be auto-filled from render.yaml)

Start Command: java -Xmx400m -Xms200m -jar target/auth-service-0.0.1-SNAPSHOT.jar
(should be auto-filled from render.yaml)
```

### Plan
```
Instance Type: Free
(perfect for testing and development)
```

**Click "Create Web Service"** at the bottom

---

## Step 6: Add Environment Variables

After creating the service, you'll be on the service dashboard.

Look for the **"Environment"** tab in the left sidebar and click it.

Now add these variables **one by one**:

### How to Add Each Variable
1. Click **"Add Environment Variable"** button
2. Enter the **Key** (variable name)
3. Enter the **Value**
4. Click **"Add"**
5. Repeat for all variables below

### Variables to Add

#### Database Configuration
```
Key: DB_URL
Value: jdbc:postgresql://aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres?sslmode=require&prepareThreshold=0
```

```
Key: DB_USERNAME
Value: postgres.dkksbddtojuhhbdkyvad
```

```
Key: DB_PASSWORD
Value: Ach@l789Achal
```

```
Key: DB_POOL_SIZE
Value: 3
```

#### Email Configuration
```
Key: MAIL_USERNAME
Value: aachalshirbhate4@gmail.com
```

```
Key: MAIL_PASSWORD
Value: jmjwhcgnzadujvph
```

#### JWT Configuration
```
Key: JWT_SECRET
Value: TelePatient$SuperSecret$Key$LocalDev$Only$NotForProd
```

```
Key: JWT_EXPIRATION
Value: 86400000
```

#### Other Settings
```
Key: CORS_ALLOWED_ORIGINS
Value: *
```

```
Key: DDL_AUTO
Value: update
```

```
Key: SPRING_PROFILES_ACTIVE
Value: prod
```

### Save Changes
After adding all 11 variables, click **"Save Changes"** at the bottom.

Render will automatically trigger a new deployment.

---

## Step 7: Monitor Deployment

Click on the **"Logs"** tab in the left sidebar.

You'll see the build and deployment process in real-time.

### What to Look For

**Building:**
```
==> Building...
==> Running 'mvn clean package -DskipTests'
[INFO] BUILD SUCCESS
```

**Starting:**
```
==> Starting service...
Started AuthServiceApplication in 45.123 seconds
```

**Success:**
```
==> Your service is live 🎉
```

This takes **5-10 minutes** for the first deployment.

---

## Step 8: Get Your Backend URL

Once deployment is complete, look at the **top of the page**.

You'll see your service URL, something like:
```
https://telepatient-api.onrender.com
```

Or:
```
https://telepatient-api-xyz.onrender.com
```

**COPY THIS URL!** You need it for the Flutter app.

---

## Step 9: Test Your Backend

Open a new browser tab and visit:
```
https://YOUR-URL-HERE.onrender.com/actuator/health
```

Replace `YOUR-URL-HERE` with your actual Render URL.

You should see:
```json
{
  "status": "UP"
}
```

If you see this, **your backend is working!** 🎉

---

## Step 10: Come Back Here

Once you have your backend URL, come back to this chat and tell me:

> "My Render URL is https://telepatient-api-xyz.onrender.com"

I will then:
1. Update your Flutter app to use this URL
2. Help you rebuild the APK
3. Guide you through testing on your phone

---

## 🆘 Troubleshooting

### "Build Failed"
- Check the logs for specific errors
- Most common: Maven build errors
- Solution: Make sure all environment variables are set correctly

### "Service Unavailable"
- Your service might be starting up (takes 30-60 seconds)
- Refresh the page and wait a bit
- Check logs for errors

### "Can't Find Repository"
- Click "Configure account" in the repository selection screen
- Give Render access to your GitHub repositories
- Try again

### "Database Connection Failed"
- Double-check the DB_URL, DB_USERNAME, and DB_PASSWORD
- Make sure there are no extra spaces in the values
- Verify your Supabase database is active

### "Environment Variables Not Showing"
- Make sure you clicked "Save Changes" after adding them
- Try refreshing the page
- Check the "Environment" tab in the left sidebar

---

## 💡 Tips

1. **Keep the Render dashboard open** - you'll need to check logs
2. **Don't close the browser** during deployment
3. **Copy your URL immediately** - you'll need it multiple times
4. **Bookmark your Render dashboard** - you'll use it often

---

## ✅ Checklist

Use this to track your progress:

- [ ] Signed up on Render
- [ ] Connected GitHub repository
- [ ] Created web service
- [ ] Added all 11 environment variables
- [ ] Saved changes
- [ ] Waited for deployment to complete
- [ ] Tested /actuator/health endpoint
- [ ] Copied backend URL
- [ ] Told Kiro my backend URL

---

## 🎯 Ready?

**Start now:** https://dashboard.render.com

Good luck! I'll be here waiting for your backend URL! 🚀
