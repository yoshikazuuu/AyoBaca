# AyoBaca 🇮🇩

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<p align="center">
  <img
    src="https://github.com/user-attachments/assets/f371e61c-6e1e-44b5-8e96-df3d8733dd51"
    alt="AyoBaca Logo"
    width="200"
  />
</p>
<p align="center">
  <a href="https://testflight.apple.com/join/Q4kTSYYF"><strong>Join the AyoBaca Beta on TestFlight</strong></a>
</p>


**An engaging iOS application designed to empower children with dyslexia in Indonesia, transforming reading challenges into fun, inclusive, and hopeful learning adventures through smart digital technology and innovative methods.**

---

## 🎯 Problem Background

Reading is a fundamental skill, yet a significant portion of children face challenges. In Indonesia:

*   Approximately **10%** of school-aged children experience dyslexia.
*   Over **60%** of teachers may lack a full understanding of dyslexia.
*   Less than **30%** of affected children receive appropriate support.
*   High therapy costs and limited access, especially in remote areas, leave much potential untapped.

Furthermore, the International Dyslexia Association estimates that **15-20%** of the world's population exhibits symptoms of dyslexia to varying degrees. These children don't need labels; they need understanding and effective tools.

## ✨ Our Vision: The AyoBaca Solution

**Ayo Baca** hadir untuk memberdayakan anak-anak dengan disleksia, mengubah setiap tantangan membaca menjadi petualangan belajar yang menyenangkan, inklusif, dan penuh harapan melalui teknologi digital yang cerdas dan metode terapi inovatif.

We aim to provide an accessible, engaging, and effective learning companion for children aged 6-12 navigating the challenges of dyslexia.

## 🚀 Key Features

*   **Interactive Onboarding:** Welcoming setup for parents and children (Name, Age).
*   **Personalized Learning Path:** Structured progression through letters, syllables, and words.
*   **Engaging Activities:**
    *   **Spelling Practice:** Uses Speech-to-Text (Indonesian locale) for pronunciation feedback.
    *   **Writing Practice:** Interactive canvas for tracing/drawing letters with basic validation.
    *   **Syllable Building:** Drag-and-drop interface to combine letters into syllables.
    *   **Word Formation:** Combine syllables to construct complete words.
*   **Progress Tracking:** Visual level map showing completed and current learning stages.
*   **Gamification:** Streak counter to encourage daily practice.
*   **Mascot Guide:** Friendly character ("Ado") to accompany the child's learning journey.
*   **Parent/Profile Section:** Allows parents to monitor progress and manage settings.
*   **In-App Guidance:** Uses TipKit for contextual help and feature discovery.
*   **Dyslexia-Friendly Design:** Incorporates OpenDyslexic font options.
*   **Data Persistence:** Uses SwiftData to save user profiles and progress.

## 👥 Target Audience

*   Children aged 6-12 years diagnosed with or showing signs of dyslexia.
*   Parents seeking accessible and engaging tools to support their child's reading development.
*   (Potentially) Teachers and therapists looking for supplementary digital resources.

## 🛠️ Technology Stack

*   **UI:** SwiftUI
*   **Data Persistence:** SwiftData
*   **In-App Tips:** TipKit
*   **Speech Recognition:** Speech Framework (AVFoundation)
*   **Drawing:** Core Graphics / SwiftUI Canvas
*   **State Management:** SwiftUI's `@StateObject`, `@EnvironmentObject`, `@Published`
*   **Language:** Swift
*   **Platform:** iOS
*   **Custom Fonts:** Rethink Sans, OpenDyslexic

## 📸 Screenshots & Flow

*(Referencing the provided composite image)*

The application flow includes:

1.  **Onboarding:** Splash, Login (Parent), Welcome, Name Setup, Age Setup, Introductory Screens.
2.  **Main Hub:** Profile Card, Mascot & Streak, Start Practice Button, Map & Profile Navigation.
3.  **Learning Loop:**
    *   Level Map Selection
    *   Character Selection (within a level)
    *   Spelling Activity (Pronounce the letter)
    *   Writing Activity (Draw the letter)
    *   (Future Modules) Syllable & Word Building Activities
4.  **Profile View:** Parent-facing section for settings and progress overview.

![ui1](https://github.com/user-attachments/assets/14dc2e96-074c-4a05-a60d-11f0311f880b)
![ui](https://github.com/user-attachments/assets/7426c274-bc1a-4b44-adac-40503e777b4e)


## 🧑‍💻 Getting Started

1.  **Prerequisites:**
    *   Xcode 16.0 or later
    *   Swift 5.10 or later
    *   iOS 17.0 or later
    *   Ensure you have the necessary custom fonts installed or included in the project.
2.  **Clone the repository:**
    ```bash
    git clone https://github.com/yoshikazuuu/AyoBaca.git
    cd AyoBaca
    ```
3.  **Open the project:**
    *   Open `AyoBaca.xcodeproj` in Xcode.
4.  **Build & Run:**
    *   Select a target simulator or connect a physical device.
    *   Press `Cmd + R` or click the Run button in Xcode.
5.  **Beta Testing (TestFlight):**
    *   Join our public beta test group via TestFlight:
    *   [**Join the AyoBaca Beta on TestFlight**](https://testflight.apple.com/join/Q4kTSYYF)

## 👨‍👩‍👧‍👦 Our Team

AyoBaca is brought to you by:

*   **Rafael Marvin** - Hustler
*   **Jerry Febriano** - Hacker
*   **Natasya Felicia** - Hipster

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
