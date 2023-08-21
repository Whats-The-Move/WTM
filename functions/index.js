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

    const databaseRef1 = admin.database().ref("BerkeleyParties");
    const snapshot1 = await databaseRef1.once("value");

    // Update the isGoing field for each child in the Parties node
    snapshot1.forEach((childSnapshot) => {
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

const sendFriendRequestNotification = async (recipientFcmToken, senderName) => {
  const message = {
    notification: {
      title: "New Friend Request",
      body: `${senderName} has sent you a friend request!`,
    },
    token: recipientFcmToken,
  };

  try {
    await admin.messaging().send(message);
    console.log("Friend request notification sent successfully.");
  } catch (error) {
    console.error("Error sending friend request notification:", error);
  }
};

exports.sendFriendRequestNotification = functions.firestore
    .document("users/{userId}")
    .onUpdate(async (change, context) => {
      const {before, after} = change;
      const beforeRequests = before.data().pendingFriendRequests || [];
      const afterRequests = after.data().pendingFriendRequests || [];

      // Check if there's a new friend request
      if (afterRequests.length > beforeRequests.length) {
        // Get the recipient's FCM token
        const recipientUid = context.params.userId;
        const recipientSnap = await admin
            .firestore()
            .collection("users")
            .doc(recipientUid)
            .get();
        const recipientFcmToken = recipientSnap.data().fcmToken;

        // Get the sender's name
        const newRequestUid = afterRequests.find((uid) =>
          !beforeRequests.includes(uid));
        const senderSnap = await admin
            .firestore()
            .collection("users")
            .doc(newRequestUid)
            .get();
        const senderName = senderSnap.data().name;

        // Send the push notification with sender's name
        await sendFriendRequestNotification(recipientFcmToken, senderName);
      }

      return null;
    });

// const sendPartyNotification = async (recipientFcmToken, partyName) => {
//   const message = {
//     notification: {
//       title: "Alert",
//       body: `Many of your friends are going to ${partyName} tonight!`,
//     },
//     token: recipientFcmToken,
//   };

//   try {
//     await admin.messaging().send(message);
//     console.log("Party notification sent successfully.");
//   } catch (error) {
//     console.error("Error sending party notification:", error);
//   }
// };

// exports.sendPartyNotification = functions.database
//     .ref("Parties/{partyName}/isGoing")
//     .onUpdate(async (change, context) => {
//       const afterIsGoing = change.after.val() || [];
//       const partyIsGoingUids = new Set(afterIsGoing);

//       // Define the required number of friends for the notification
//       const requiredFriends = 5;

//       // Get the current party name from the context
//       const partyName = context.params.partyName;

//       // Get a reference to the "users" collection in Firestore
//       const usersCollection = admin.firestore().collection("users");

//       // Query all users to check for common friends attending the party
//       const usersSnapshot = await usersCollection.get();

//       // Iterate through each user
//       for (const userDoc of usersSnapshot.docs) {
//         const userData = userDoc.data();
//         const friendsList = userData.friends || [];

//         // Find the common friends who are going to the party
//         const commonFriends =
//           friendsList.filter((friendUid) =>
//             partyIsGoingUids.has(friendUid));

//         // Check if exactly 5 common friends are going
//         if (commonFriends.length === requiredFriends) {
//           // Get the recipient's FCM token
//           const recipientFcmToken = userData.fcmToken;

//           // Send the party notification with party name
//           await sendPartyNotification(recipientFcmToken, partyName);
//         }
//       }

//       return null;
//     });

const sendIndPartyNotification =
  async (recipientFcmToken, notificationMessage) => {
    const message = {
      notification: {
        title: notificationMessage,
        body: "Join them!",
      },
      token: recipientFcmToken,
    };

    try {
      await admin.messaging().send(message);
      console.log("Party notification sent successfully.");
    } catch (error) {
      console.error("Error sending party notification:", error);
    }
  };

exports.indSendPartyNotification = functions.database
    .ref("Parties/{partyName}/isGoing")
    .onUpdate(async (change, context) => {
      const beforeIsGoing = change.before.val() || [];
      const afterIsGoing = change.after.val() || [];

      // Find the added UID in the isGoing list
      const addedUid = afterIsGoing.find((uid) => !beforeIsGoing.includes(uid));

      if (!addedUid) {
        // No new UID added to isGoing
        return null;
      }

      // Get the current party name from the context
      const partyName = context.params.partyName;

      // Get a reference to the "users" collection in Firestore
      const usersCollection = admin.firestore().collection("users");

      // Query all users to find those who have the added UID as a friend
      const usersSnapshot = await usersCollection.get();

      // Iterate through each user
      for (const userDoc of usersSnapshot.docs) {
        const userData = userDoc.data();
        const friendsList = userData.friends || [];

        // Check if the added UID is a friend of the user
        if (friendsList.includes(addedUid)) {
          // Get the recipient's FCM token
          const recipientFcmToken = userData.fcmToken;

          // Get the name of the friend who is attending the party
          const friendSnap = await admin
              .firestore()
              .collection("users")
              .doc(addedUid)
              .get();
          const friendName = friendSnap.data().name;

          // Send the party notification with party name
          const notificationMessage =
           `${friendName} is going to ${partyName} tonight! Join them!`;
          await
          sendIndPartyNotification(recipientFcmToken, notificationMessage);

          console.log(`Party notification sent to ${userData.name}`);
        }
      }
      return null;
    });
