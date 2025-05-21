# AutoCaller – Smart Student Dismissal System

**AutoCaller** is an IoT-based platform designed to enhance the student dismissal process in schools. It integrates GPS tracking, text-to-speech, and mobile app functionality to ensure a safer, faster, and more organized dismissal experience.

---

## Features

- **Guardian Mobile App** – Allows primary and secondary guardians to sign in, select students, and send pickup requests.
- **Geofence Detection** – Automatically detects when a guardian arrives near the school.
- **Smart Display System** – Displays and announces students’ names via IoT screens when their guardian arrives.
- **Text-to-Speech** – Reads student names out loud to reduce confusion.
- **Authorization Control** – Only authorized guardians can pick up students.
- **Real-time Attendance Handling** – Absent students are excluded from the pickup list.

---

## Demo

Watch a short video demo here: [AutoCaller Demo](https://youtu.be/jxDsLSj3528?feature=shared)

---

## Technologies Used

- **Flutter** 
- **Firebase** (Authentication, Firestore, Cloud Messaging)
- **Raspberry Pi** (IoT Display)
- **Geolocator** & **TTS plugins**

---

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-repo/autocaller.git
   cd autocaller
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Add your `google-services.json` (Android) 
   - Configure Firebase authentication and Firestore collections as described in the documentation.

4. **Run the app**
   ```bash
   flutter run
   ```

---

## Firestore Structure

- `Primary Guardian` (with subcollections: `studentsID`, `secondaryGuardiansID`)
- `Secondary Guardian` (with field: `isAuthorized`, and subcollection: `studentsID`)
- `Students`
- `Dismissal Logs`

---

## How It Works

1. Guardians sign in and select the students they're picking up.
2. When they enter the geofence, the app notifies the system.
3. The IoT display shows the student name.
4. TTS announces the name audibly.
5. Pickup is logged and verified.

---

## Team Members

- Mashael Alqabbani
- Noura Alhumaid  
- Batool Alfouzan  
- Rama Alayed  
- Sara Alaiban  

**Supervised by:** Mashael Maashi

---



## License

[MIT License](LICENSE)
