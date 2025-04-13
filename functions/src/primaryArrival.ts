import * as functions from "firebase-functions/v2";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { admin } from "./firebase";

const db = getFirestore(admin.app());


async function handleGuardianArrival(guardianId: string, guardianType: string) {
  console.log(`${guardianType} Guardian ${guardianId} has arrived.`);

  const studentsSnapshot = await db.collection("Student")
    .where(
      `${guardianType === "Primary" ? "primaryGuardianID" : "secondaryGuardianID"}`,
      "==",
      db.doc(`${guardianType} Guardian/${guardianId}`)
    )
    .get();

  if (studentsSnapshot.empty) {
    console.log(`No students found for ${guardianType} Guardian ${guardianId}.`);
    return;
  }

  const batch = db.batch();
  studentsSnapshot.forEach((studentDoc) => {
    batch.update(studentDoc.ref, {
      readyForPickup: true,
      lastDismissalTime: FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
  console.log(`Updated students for ${guardianType} Guardian ${guardianId}`);
}

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