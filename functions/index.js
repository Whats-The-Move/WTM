// index.js

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const updateIsGoingField = async () => {
  try {
    const databaseRef = admin.database().ref("Parties");
    const snapshot = await databaseRef.once("value");

    // Update the isGoing field for each child in the Parties node
    snapshot.forEach((childSnapshot) => {
      const childRef = childSnapshot.ref;
      const isGoingArray = [];

      // Here, we add the UID twice to the isGoingArray
      isGoingArray.push("vSAYcrlFT1faX9Z4KrX8waB4vdA2");
      isGoingArray.push("vSAYcrlFT1faX9Z4KrX8waB4vdA2");

      childRef.update({isGoing: isGoingArray});
    });

    console.log("isGoing field updated successfully.");
  } catch (error) {
    console.error("Error updating isGoing field:", error);
  }
};


exports.dailyUpdateIsGoing = functions.pubsub
    .schedule("0 6 * * *") // Cron schedule for 6 am Central Time
    .timeZone("America/Chicago") // Timezone is set to America/Chicago
    .onRun(async (context) => {
      console.log("Running daily updateIsGoing function");
      await updateIsGoingField();
      return null;
    });
