import * as functions from "firebase-functions/v2";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { admin } from "./firebase";

const db = getFirestore(admin.app());

export const onPickupTimestampUpdate = functions.firestore.onDocumentUpdated(
  "Student/{studentId}",
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();

    if (!beforeData || !afterData) {
      console.log("❌ Missing before/after data.");
      return;
    }

    const pickupBefore = beforeData.pickupTimestamp;
    const pickupAfter = afterData.pickupTimestamp;

    if (pickupBefore === pickupAfter) {
      console.log("ℹ️ Pickup Timestamp didn't change.");
      return;
    }

    console.log(`🚀 Appending new dismissal history for student ${event.params.studentId}`);

    const studentRef = db.collection("Student").doc(event.params.studentId);

    await studentRef.update({
      dismissalHistory: FieldValue.arrayUnion({
        status: "Picked Up",
        timestamp: pickupAfter,
      }),
    });

    console.log("✅ Dismissal history updated successfully.");
  }
);