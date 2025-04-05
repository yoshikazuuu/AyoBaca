#!/bin/bash

# --- Safety Check ---
echo "🛑 IMPORTANT: Make sure you have backed up your project (e.g., git commit)!"
echo "This script will create directories and move files."
read -p "Are you sure you want to continue? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi

echo "🚀 Starting project organization..."

# --- 1. Create New Directory Structure ---
echo "📁 Creating new directories..."
mkdir -p Application
mkdir -p Features/Onboarding/Views
mkdir -p Features/Onboarding/State
mkdir -p Features/MainApp/Views
mkdir -p UIComponents/Backgrounds
mkdir -p UIComponents/Indicators
mkdir -p UIComponents/Effects
mkdir -p Core/Data
mkdir -p Core/Extensions
mkdir -p Core/Modifiers
mkdir -p Core/Typography
mkdir -p Resources # Create Resources first

echo "✅ Directories created."

# --- 2. Move Swift Files ---
echo "🚚 Moving Swift files..."

# Application
mv AyoBacaApp.swift Application/AyoBacaApp.swift || echo "⚠️  Warning: Could not move AyoBacaApp.swift"
mv ContentView.swift Application/ContentView.swift || echo "⚠️  Warning: Could not move ContentView.swift"
# NOTE: AppScreen enum needs manual extraction from ContentView.swift later

# Features/Onboarding
mv Observable/OnboardingState.swift Features/Onboarding/State/OnboardingState.swift || echo "⚠️  Warning: Could not move OnboardingState.swift"
mv View/SplashView.swift Features/Onboarding/Views/SplashView.swift || echo "⚠️  Warning: Could not move SplashView.swift"
mv View/LoginView.swift Features/Onboarding/Views/LoginView.swift || echo "⚠️  Warning: Could not move LoginView.swift"
mv View/WelcomeView.swift Features/Onboarding/Views/WelcomeView.swift || echo "⚠️  Warning: Could not move WelcomeView.swift"
mv View/NameSetupView.swift Features/Onboarding/Views/NameSetupView.swift || echo "⚠️  Warning: Could not move NameSetupView.swift"
mv View/AgeSetupView.swift Features/Onboarding/Views/AgeSetupView.swift || echo "⚠️  Warning: Could not move AgeSetupView.swift"
# NOTE: ConfettiView needs manual extraction later
mv View/CelebrationView.swift Features/Onboarding/Views/CelebrationView.swift || echo "⚠️  Warning: Could not move CelebrationView.swift"
# NOTE: LottieView needs manual extraction later

# Features/MainApp
mv View/MainAppView.swift Features/MainApp/Views/MainAppView.swift || echo "⚠️  Warning: Could not move MainAppView.swift"

# UIComponents
mv View/FloatingAlphabetBackground.swift UIComponents/Backgrounds/FloatingAlphabetBackground.swift || echo "⚠️  Warning: Could not move FloatingAlphabetBackground.swift"
mv View/OnboardingProgressView.swift UIComponents/Indicators/OnboardingProgressView.swift || echo "⚠️  Warning: Could not move OnboardingProgressView.swift"

# Core
# NOTE: SwiftData container needs manual extraction from AyoBacaApp.swift later
mv Extension/Image.swift Core/Extensions/Image+Size.swift || echo "⚠️  Warning: Could not move Image.swift extension"
# NOTE: Font.swift needs manual splitting later
mv Helper/Font.swift Core/Typography/FontHelper_TEMP.swift || echo "⚠️  Warning: Could not move Font.swift helper (will need splitting)"
# NOTE: PageTransition.swift needs manual splitting later
mv View/Modifiers/PageTransition.swift Core/Modifiers/PageTransition_TEMP.swift || echo "⚠️  Warning: Could not move PageTransition.swift (will need splitting)"

echo "✅ Swift files moved (check warnings!)."

# --- 3. Move Resources ---
echo "🖼️  Moving resources..."
mv Assets.xcassets Resources/Assets.xcassets || echo "⚠️  Warning: Could not move Assets.xcassets"
mv Fonts Resources/Fonts || echo "⚠️  Warning: Could not move Fonts folder"
# Info.plist typically stays in root
# Preview Content typically stays in root

echo "✅ Resources moved."

# --- 4. Cleanup Old Folders (Optional - Use with caution) ---
echo "🧹 Cleaning up old directories (attempting)..."
# Use rmdir which only removes empty directories for safety
rmdir Extension 2>/dev/null || echo "ℹ️  Info: Old 'Extension' directory not removed (might not be empty or exist)."
rmdir Helper 2>/dev/null || echo "ℹ️  Info: Old 'Helper' directory not removed."
rmdir Observable 2>/dev/null || echo "ℹ️  Info: Old 'Observable' directory not removed."
rmdir View/Modifiers 2>/dev/null || echo "ℹ️  Info: Old 'View/Modifiers' directory not removed."
rmdir View 2>/dev/null || echo "ℹ️  Info: Old 'View' directory not removed."

echo "✅ Cleanup attempted."

# --- 5. Reminders ---
echo "🔔 REMINDER: Manual steps needed!"
echo "   - Extract ConfettiView & LottieView to UIComponents/Effects/"
echo "   - Split FontHelper_TEMP.swift into Core/Typography/FontType.swift & Core/Extensions/Font+AppFont.swift"
echo "   - Split PageTransition_TEMP.swift into Core/Modifiers/PageTransition.swift & Core/Extensions/View+PageTransition.swift"
echo "   - Create Application/AppScreen.swift and move enum"
echo "   - Create Core/Data/AppModelContainer.swift and move container setup"
echo "   - Update Xcode project navigator (remove old refs, add new folders)"
echo "   - Update Info.plist with font files"
echo "   - Clean build folder (Shift+Cmd+K) and build project"

echo "🎉 Organization script finished!"

