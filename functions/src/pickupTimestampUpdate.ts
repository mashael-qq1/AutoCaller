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

    const studentId = event.params.studentId;
    const pickedUpById = afterData.pickedUpBy;
    let pickedUpByName = "Unknown";

    console.log(`🔍 Looking up pickedUpBy ID: ${pickedUpById}`);

    // Try Primary Guardian by doc ID
    let doc = await db.collection("Primary Guardian").doc(pickedUpById).get();
    if (doc.exists && doc.data()?.fullName) {
      pickedUpByName = doc.data()!.fullName;
      console.log(`👤 Found Primary Guardian by doc ID: ${pickedUpByName}`);
    } else {
      // Try Primary Guardian by 'userid' field
      const primaryQuery = await db
        .collection("Primary Guardian")
        .where("userid", "==", pickedUpById)
        .limit(1)
        .get();

      if (!primaryQuery.empty) {
        pickedUpByName = primaryQuery.docs[0].data().fullName ?? "Unknown";
        console.log(`👤 Found Primary Guardian by userid: ${pickedUpByName}`);
      } else {
        // Try Secondary Guardian by 'uid' field
        const secondaryQuery = await db
          .collection("Secondary Guardian")
          .where("uid", "==", pickedUpById)
          .limit(1)
          .get();

        if (!secondaryQuery.empty) {
          pickedUpByName = secondaryQuery.docs[0].data().FullName ?? "Unknown";
          console.log(`👤 Found Secondary Guardian: ${pickedUpByName}`);
        } else {
          console.log("⚠️ Guardian not found in any method.");
        }
      }
    }

    const studentRef = db.collection("Student").doc(studentId);
    await studentRef.update({
      dismissalHistory: FieldValue.arrayUnion({
        status: "Picked Up",
        timestamp: pickupAfter,
        pickedUpBy: pickedUpByName,
      }),
    });

    console.log(
      `✅ Dismissal updated by ${pickedUpByName} for student ${studentId}`
    );
  }
);