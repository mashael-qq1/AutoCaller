import * as functions from "firebase-functions/v2";
import { getFirestore } from "firebase-admin/firestore";
import { admin } from "./firebase";

const db = getFirestore(admin.app());

export const notifyPrimaryGuardian = functions.firestore.onDocumentCreated(
  "Secondary Guardian/{secondaryGuardianId}",
  async (event) => {
    const newData = event.data?.data();
    const primaryGuardianID = newData?.primaryGuardianID;

    if (!primaryGuardianID) {
      console.log("❌ No Primary Guardian ID found.");
      return;
    }

    const primaryGuardianDoc = await db.collection("Primary Guardian").doc(primaryGuardianID).get();

    const fcmToken = primaryGuardianDoc.get("fcmToken");

    if (!fcmToken) {
      console.log("❌ No FCM token found.");
      return;
    }

    console.log("🚀 Sending Notification to Primary Guardian...");

    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: "New Secondary Guardian Registered!",
        body: `${newData.FullName} accepted your invitation.`,
      },
    });

    console.log("✅ Notification sent successfully.");
  }
);