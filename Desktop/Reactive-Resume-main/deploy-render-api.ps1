# PowerShell script for Render deployment via API
# Run this script after getting your Render API key

param(
    [Parameter(Mandatory=$true)]
    [string]$ApiKey,
    
    [Parameter(Mandatory=$false)]
    [string]$OwnerEmail
)

# Colors for output
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

Write-Info "🚀 Starting Render deployment via API..."

# Check if API key is provided
if (-not $ApiKey) {
    Write-Error "API key is required. Get it from: https://dashboard.render.com/account/api-keys"
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $ApiKey"
    "Content-Type" = "application/json"
}

$baseUrl = "https://api.render.com/v1"

# Step 1: Create PostgreSQL Database
Write-Info "📊 Creating PostgreSQL database..."

$dbPayload = @{
    "type" = "postgresql"
    "name" = "freeresumebuilder-db"
    "plan" = "free"
    "region" = "oregon"
    "databaseName" = "freeresumebuilder"
    "databaseUser" = "freeresumebuilder"
} | ConvertTo-Json

try {
    $dbResponse = Invoke-RestMethod -Uri "$baseUrl/services" -Method POST -Headers $headers -Body $dbPayload
    Write-Success "Database created successfully: $($dbResponse.service.name)"
    $databaseUrl = $dbResponse.service.databaseUrl
    Write-Info "Database URL: $databaseUrl"
} catch {
    Write-Error "Failed to create database: $($_.Exception.Message)"
    exit 1
}

# Step 2: Create Backend Web Service
Write-Info "🖥️  Creating backend web service..."

$backendPayload = @{
    "type" = "web_service"
    "name" = "freeresumebuilder-backend"
    "plan" = "free"
    "region" = "oregon"
    "runtime" = "node"
    "buildCommand" = "npm install -g pnpm && pnpm install && pnpm prisma:generate && pnpm build:server"
    "startCommand" = "pnpm prisma:migrate && pnpm start:server"
    "envVars" = @(
        @{ "key" = "NODE_ENV"; "value" = "production" }
        @{ "key" = "PORT"; "value" = "3000" }
        @{ "key" = "DATABASE_URL"; "value" = $databaseUrl }
        @{ "key" = "PUBLIC_URL"; "value" = "https://freeresumebuilder.onrender.com" }
        @{ "key" = "ACCESS_TOKEN_SECRET"; "generateValue" = $true }
        @{ "key" = "REFRESH_TOKEN_SECRET"; "generateValue" = $true }
        @{ "key" = "MAIL_FROM"; "value" = "noreply@freeresumebuilder.co" }
        @{ "key" = "DISABLE_SIGNUPS"; "value" = "true" }
        @{ "key" = "DISABLE_EMAIL_AUTH"; "value" = "true" }
        @{ "key" = "STORAGE_ENDPOINT"; "value" = "localhost" }
        @{ "key" = "STORAGE_PORT"; "value" = "9000" }
        @{ "key" = "STORAGE_REGION"; "value" = "us-east-1" }
        @{ "key" = "STORAGE_BUCKET"; "value" = "default" }
        @{ "key" = "STORAGE_ACCESS_KEY"; "value" = "minioadmin" }
        @{ "key" = "STORAGE_SECRET_KEY"; "value" = "minioadmin" }
        @{ "key" = "STORAGE_USE_SSL"; "value" = "false" }
        @{ "key" = "STORAGE_SKIP_BUCKET_CHECK"; "value" = "true" }
        @{ "key" = "CHROME_TOKEN"; "value" = "chrome_token" }
        @{ "key" = "CHROME_URL"; "value" = "ws://localhost:3000" }
    )
    "repo" = @{
        "url" = "https://github.com/your-username/your-repo"
        "branch" = "main"
        "buildFilter" = @{
            "paths" = @("apps/server/**", "libs/**", "tools/**", "package.json", "pnpm-lock.yaml")
        }
    }
} | ConvertTo-Json -Depth 10

try {
    $backendResponse = Invoke-RestMethod -Uri "$baseUrl/services" -Method POST -Headers $headers -Body $backendPayload
    Write-Success "Backend service created successfully: $($backendResponse.service.name)"
    $backendUrl = "https://$($backendResponse.service.name).onrender.com"
    Write-Info "Backend URL: $backendUrl"
} catch {
    Write-Error "Failed to create backend service: $($_.Exception.Message)"
    exit 1
}

# Step 3: Create Frontend Static Site
Write-Info "🌐 Creating frontend static site..."

$frontendPayload = @{
    "type" = "static_site"
    "name" = "freeresumebuilder-frontend"
    "plan" = "free"
    "region" = "oregon"
    "buildCommand" = "npm install -g pnpm && pnpm install && pnpm build:client"
    "publishPath" = "dist/apps/client"
    "envVars" = @(
        @{ "key" = "NODE_ENV"; "value" = "production" }
        @{ "key" = "VITE_SERVER_URL"; "value" = $backendUrl }
    )
    "headers" = @(
        @{ "path" = "/*"; "name" = "X-Frame-Options"; "value" = "DENY" }
        @{ "path" = "/*"; "name" = "X-Content-Type-Options"; "value" = "nosniff" }
    )
    "routes" = @(
        @{ "type" = "rewrite"; "source" = "/*"; "destination" = "/index.html" }
    )
    "repo" = @{
        "url" = "https://github.com/your-username/your-repo"
        "branch" = "main"
        "buildFilter" = @{
            "paths" = @("apps/client/**", "libs/**", "package.json", "pnpm-lock.yaml")
        }
    }
} | ConvertTo-Json -Depth 10

try {
    $frontendResponse = Invoke-RestMethod -Uri "$baseUrl/services" -Method POST -Headers $headers -Body $frontendPayload
    Write-Success "Frontend service created successfully: $($frontendResponse.service.name)"
    $frontendUrl = "https://$($frontendResponse.service.name).onrender.com"
    Write-Info "Frontend URL: $frontendUrl"
} catch {
    Write-Error "Failed to create frontend service: $($_.Exception.Message)"
    exit 1
}

Write-Success "🎉 Deployment completed successfully!"
Write-Info "📋 Summary:"
Write-Info "   Database: $($dbResponse.service.name)"
Write-Info "   Backend:  $backendUrl"
Write-Info "   Frontend: $frontendUrl"
Write-Info ""
Write-Warning "⚠️  Remember to:"
Write-Info "   1. Update PUBLIC_URL in backend env vars to: $frontendUrl"
Write-Info "   2. Wait for builds to complete (5-10 minutes)"
Write-Info "   3. Check service logs for any issues"
Write-Info ""
Write-Info "🔗 Visit your app at: $frontendUrl"