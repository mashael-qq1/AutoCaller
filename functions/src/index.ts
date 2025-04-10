import * as functions from "firebase-functions/v2";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = getFirestore();

// Function to extract the document ID from a Firestore reference
function extractGuardianID(referencePath: string): string {
  const parts = referencePath.split("/");
  return parts[parts.length - 1]; // Get the last part of the reference (actual document ID)
}

// Generic function to handle guardian arrival updates
async function handleGuardianArrival(guardianId: string, guardianType: string) {
  console.log(`${guardianType} Guardian ${guardianId} has arrived. Updating student records...`);

  // Fetch students where the guardian reference matches the updated guardian ID
  const studentsSnapshot = await db.collection("Student")
    .where(`${guardianType === "Primary" ? "primaryGuardianID" : "secondaryGuardianID"}`, "==", db.doc(`${guardianType} Guardian/${guardianId}`))
    .get();

  if (studentsSnapshot.empty) {
    console.log(`No students found for ${guardianType} Guardian ${guardianId}.`);
    return;
  }

  // Batch update students' "readyForPickup" field
  const batch = db.batch();
  studentsSnapshot.forEach((studentDoc) => {
    batch.update(studentDoc.ref, { readyForPickup: true, lastDismissalTime: FieldValue.serverTimestamp() });
  });

  await batch.commit();
  console.log(`Updated students linked to ${guardianType} Guardian ${guardianId}.`);
}

// Firestore trigger for Primary Guardian
export const onPrimaryGuardianArrival = functions.firestore.onDocumentUpdated(
  "Primary Guardian/{guardianId}",
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();

    if (beforeData?.arrived === false && afterData?.arrived === true) {
      await handleGuardianArrival(event.params.guardianId, "Primary");
    }
  }
);

// Firestore trigger for Secondary Guardian
export const onSecondaryGuardianArrival = functions.firestore.onDocumentUpdated(
  "Secondary Guardian/{guardianId}",
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();

    if (beforeData?.arrived === false && afterData?.arrived === true) {
      await handleGuardianArrival(event.params.guardianId, "Secondary");
    }
  }
);
