// Clean & Correct index.ts

// Export triggers from other files
export * from "./primaryArrival";
export * from "./notifySecondary";

/*
async function handleGuardianArrival(guardianId: string, guardianType: string) {
  console.log(`${guardianType} Guardian ${guardianId} has arrived. Updating student records...`);

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
  console.log(`Updated students linked to ${guardianType} Guardian ${guardianId}.`);
}
*/