# Manual Render Deployment Steps

## 🚀 Step-by-Step Command Line Deployment Guide

**Important**: Render doesn't have an official CLI for service creation. We'll use manual steps through their web interface, but I'll give you the exact commands to run locally for preparation.

### Step 1: Prepare Local Project ✅

```bash
# 1. Navigate to project directory
cd "C:\Users\Middha Global\Desktop\Reactive-Resume-main"

# 2. Verify all files are ready
dir
```

**Verification**: Ensure these files exist:
- `render.yaml`
- `.env.production`
- `DEPLOYMENT.md`
- `package.json` (with updated scripts)

### Step 2: Initialize Git Repository (if not done)

```bash
# 1. Initialize git (if not already done)
git init

# 2. Add all files
git add .

# 3. Commit changes
git commit -m "Prepare for Render deployment - auth removed, domain updated"

# 4. Create GitHub repository and push (you'll need to do this manually)
# Go to github.com, create new repository, then:
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git branch -M main
git push -u origin main
```

### Step 3: Create Render Account and Services

**🌐 Web Interface Steps:**

1. **Create Account**: Go to https://render.com and sign up

2. **Create Database**:
   - Dashboard → New → PostgreSQL
   - Name: `freeresumebuilder-db`
   - Plan: Free
   - Region: Oregon (US-West)
   - Database Name: `freeresumebuilder`
   - User: `freeresumebuilder`

3. **Create Backend Service**:
   - Dashboard → New → Web Service
   - Connect GitHub repository
   - Name: `freeresumebuilder-backend`
   - Runtime: Node.js
   - Build Command: `npm install -g pnpm && pnpm install && pnpm prisma:generate && pnpm build:server`
   - Start Command: `pnpm prisma:migrate && pnpm start:server`
   - Plan: Free

4. **Create Frontend Service**:
   - Dashboard → New → Static Site
   - Connect same GitHub repository
   - Name: `freeresumebuilder-frontend`
   - Build Command: `npm install -g pnpm && pnpm install && pnpm build:client`
   - Publish Directory: `dist/apps/client`
   - Plan: Free

### Step 4: Configure Environment Variables

**Backend Environment Variables** (add in Render dashboard):
```
NODE_ENV=production
PORT=3000
DATABASE_URL=[AUTO-GENERATED FROM DATABASE SERVICE]
PUBLIC_URL=https://freeresumebuilder-frontend.onrender.com
ACCESS_TOKEN_SECRET=[GENERATE 32-CHAR RANDOM STRING]
REFRESH_TOKEN_SECRET=[GENERATE 32-CHAR RANDOM STRING]
MAIL_FROM=noreply@freeresumebuilder.co
DISABLE_SIGNUPS=true
DISABLE_EMAIL_AUTH=true
STORAGE_ENDPOINT=localhost
STORAGE_PORT=9000
STORAGE_REGION=us-east-1
STORAGE_BUCKET=default
STORAGE_ACCESS_KEY=minioadmin
STORAGE_SECRET_KEY=minioadmin
STORAGE_USE_SSL=false
STORAGE_SKIP_BUCKET_CHECK=true
CHROME_TOKEN=chrome_token
CHROME_URL=ws://localhost:3000
```

**Frontend Environment Variables**:
```
NODE_ENV=production
VITE_SERVER_URL=https://freeresumebuilder-backend.onrender.com
```

### Step 5: Deploy and Verify

**Commands to generate secrets locally**:
```powershell
# Generate random secrets (run these in PowerShell)
[System.Web.Security.Membership]::GeneratePassword(32, 8)
[System.Web.Security.Membership]::GeneratePassword(32, 8)
```

### Step 6: Monitor Deployment

**Check logs via command line** (using curl):
```bash
# This requires your Render API key - get from dashboard
curl -H "Authorization: Bearer YOUR_API_KEY" https://api.render.com/v1/services
```

## 🎯 Alternative: Blueprint Deployment

**Easiest Method** - Upload your `render.yaml`:

1. Go to Render Dashboard
2. Click "New" → "Blueprint"
3. Connect your GitHub repository
4. Render will auto-detect `render.yaml`
5. Click "Apply" to deploy all services

## ✅ Verification Steps

After deployment, run these commands to test:

```bash
# Test backend health
curl https://freeresumebuilder-backend.onrender.com/api/health

# Test frontend
curl -I https://freeresumebuilder-frontend.onrender.com
```

Expected responses:
- Backend: JSON health status
- Frontend: 200 OK with HTML

## 🔧 Troubleshooting Commands

```bash
# Check build logs (in project directory)
pnpm install
pnpm build

# Test locally before deployment
pnpm dev
```

## 📝 Notes

- **Free Tier Limits**: 750 hours/month per service
- **Build Time**: ~5-10 minutes for initial deployment
- **Cold Starts**: ~30 seconds on free tier
- **Storage**: Local filesystem (not persistent)

Use this guide step-by-step and let me know when you complete each step!