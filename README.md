# Custom Couple Dashboard - Offline UI Showroom ❤️

A private, highly personalized mobile application originally built with Flutter & Dart. This project was custom-designed as a dedicated, real-time shared space for two connected users ("User 1" and "User 2"). In its production build, both profiles are linked via a centralized Firebase cloud database, allowing their text messages, shared calendar logs, and virtual pet metrics to seamlessly merge into a single, synchronized ecosystem.

> 🌐 **Note on Language:** The application interface and all feature labels are entirely in **Polish**, as it was meticulously tailored for personal use.

---

## 🛠️ Showcase Build Alterations (Demo Mode)

To ensure **100% privacy and data protection**, this repository features an **isolated, anonymized, and serverless showroom architecture**.

### Changes implemented in this Demo:

1. **Full Anonymization:** All personal identifiers and names have been fully replaced with generic **User 1** and **User 2** roles across the profile picking mechanism, headers, and modules.
2. **Firebase Completely Decoupled:** All dependencies (`firebase_core`, `cloud_firestore`) and production initialization steps have been completely commented out or removed. The architecture no longer communicates with the live cloud where both users' actions merge into one.
3. **Local Memory Caching:** Data channelling streams (`StreamBuilder`) have been rewritten into reactive local state managers (`setState`). All core structures (adding calendar items, modifying virtual asset counts, claiming tokens, and chat updates) run locally in physical RAM.
4. **Data Persistence via SharedPreferences:** Virtual currency values, Bąbel's current hunger percentage, daily time-drains, and logged calendar milestones persist seamlessly on the local storage partition of the host machine.
5. **Mocked Real-Time Containers:** "Nasz Snap" (the private chat feature) uses a localized runtime list to distribute textual components and camera snapshots (encoded into Base64 frames), strictly maintaining the original 2-second viewing expiration timeline.

---

## 🚀 Key Features

- **Dynamic Relationship Counter:** Displays the exact duration of a relationship in years, months, and days, accompanied by an interactive fluid-fill heart and floating bubble animations.
- **Intimate Shared Calendar:** An offline calendar dashboard created for managing local daily highlights, text logging, and cycle tracking indicators. In the production app, inputs from both users merge into one shared timeline.
- **Nasz Snap (Our Snap):** A mocked sandbox simulation of our ephemeral messaging container. Supports full text-routing and real-time device camera activation.
- **Nasz Bąbel (Our Bubble):** An interactive Tamagotchi pet companion simulator with integrated time-based hunger updates, activity reward tracking panels, and a standalone coin economy shared between both users.
