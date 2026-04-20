# TelePatient Backend Deployment Guide

## Prerequisites
- GitHub account (you already have this)
- Render account (free): https://render.com
- Supabase database (you already have this configured)

## Step 1: Push Your Code to GitHub

```bash
git add .
git commit -m "Prepare for Render deployment"
git push origin main
```

## Step 2: Deploy to Render

1. **Go to Render Dashboard**
   - Visit: https://dashboard.render.com
   - Sign up or log in (you can use your GitHub account)

2. **Create New Web Service**
   - Click "New +" button → "Web Service"
   - Connect your GitHub account if not already connected
   - Select repository: `achalshirbhate/Hospital-Management-SE`
   - Click "Connect"

3. **Configure the Service**
   Render will auto-detect the `render.yaml` file, but verify these settings:
   
   - **Name**: `telepatient-api` (or your preferred name)
   - **Runtime**: Java
   - **Build Command**: `mvn clean package -DskipTests`
   - **Start Command**: `java -Xmx400m -Xms200m -jar target/auth-service-0.0.1-SNAPSHOT.jar`
   - **Plan**: Free

4. **Set Environment Variables**
   In the Render dashboard, go to "Environment" tab and add these variables:

   ```
   SPRING_PROFILES_ACTIVE=prod
   
   # Database (from your Supabase)
   DB_URL=jdbc:postgresql://aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres?sslmode=require&prepareThreshold=0
   DB_USERNAME=postgres.dkksbddtojuhhbdkyvad
   DB_PASSWORD=Ach@l789Achal
   DB_POOL_SIZE=3
   
   # Email (Gmail SMTP)
   MAIL_USERNAME=aachalshirbhate4@gmail.com
   MAIL_PASSWORD=jmjwhcgnzadujvph
   
   # JWT Secret (generate a new one for production)
   JWT_SECRET=TelePatient$SuperSecret$Key$LocalDev$Only$NotForProd
   JWT_EXPIRATION=86400000
   
   # CORS
   CORS_ALLOWED_ORIGINS=*
   
   # Database schema
   DDL_AUTO=update
   ```

   **IMPORTANT**: For production, generate a new JWT secret:
   ```bash
   openssl rand -base64 64
   ```

5. **Deploy**
   - Click "Create Web Service"
   - Render will start building and deploying your app
   - Wait 5-10 minutes for the first deployment

6. **Get Your Backend URL**
   - Once deployed, you'll see a URL like: `https://telepatient-api.onrender.com`
   - Copy this URL - you'll need it for the Flutter app

## Step 3: Update Flutter App

1. **Update the API URL**
   Edit `telepatient_app/lib/utils/constants.dart`:

   ```dart
   static String get baseUrl {
     if (kIsWeb) {
       return 'http://localhost:8081'; // Running in browser (Chrome)
     }
     // Use your Render URL here
     return 'https://telepatient-api.onrender.com'; // Production backend
   }

   static String get wsVideoUrl {
     if (kIsWeb) {
       return 'ws://localhost:8081/ws/video';
     }
     // Use wss:// for secure WebSocket
     return 'wss://telepatient-api.onrender.com/ws/video';
   }
   ```

2. **Rebuild the APK**
   ```bash
   cd telepatient_app
   flutter clean
   flutter build apk --release
   ```

3. **Install the New APK**
   - The new APK will be at: `telepatient_app/build/app/outputs/flutter-apk/app-release.apk`
   - Transfer to your phone and install

## Step 4: Test the Deployment

1. **Check Backend Health**
   Visit: `https://your-app-url.onrender.com/actuator/health`
   You should see: `{"status":"UP"}`

2. **Test Login**
   Open the app on your phone and try logging in with:
   - Email: `admin@123`
   - Password: `admin`

## Important Notes

### Free Tier Limitations
- **Sleep after 15 minutes**: Render free tier puts your service to sleep after 15 minutes of inactivity
- **Cold start**: First request after sleep takes 30-60 seconds to wake up
- **Solution**: Upgrade to Starter plan ($7/month) for always-on service, or use a service like UptimeRobot to ping your API every 10 minutes

### Security Recommendations
1. **Change default credentials** in production
2. **Generate new JWT secret** (don't use the default one)
3. **Update CORS_ALLOWED_ORIGINS** to specific domains if you have a web frontend
4. **Never commit sensitive data** to GitHub (use environment variables)

### Troubleshooting

**If deployment fails:**
1. Check Render logs in the dashboard
2. Verify all environment variables are set correctly
3. Make sure your Supabase database is accessible

**If app can't connect:**
1. Verify the backend URL in `constants.dart` is correct
2. Check if backend is sleeping (visit the health endpoint to wake it)
3. Make sure you rebuilt the APK after changing the URL

**Database connection issues:**
1. Check Supabase connection limits (free tier has 15 connections max)
2. Verify DB_POOL_SIZE is set to 3 or less
3. Check if your Supabase project is active

## Next Steps

After successful deployment:
1. Set up a custom domain (optional)
2. Configure automatic deployments on git push
3. Set up monitoring and alerts
4. Consider upgrading to paid tier for production use

## Support

If you encounter issues:
- Check Render logs: Dashboard → Your Service → Logs
- Check application logs in Render dashboard
- Verify environment variables are set correctly
