import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

exports.createGame = functions.firestore
    .document("games/{gameId}")
    .onCreate(async (snap, _) => {
      const game = snap.data();
      if (game) {
        const gameId = game.uid;
        let code;

        const configRef = db.collection("config").doc("games");
        try {
          await db.runTransaction(async (t) => {
            const configDoc = await t.get(configRef);
            const configData = configDoc.data();
            if (configData) {
              code = configData.nextValidCode;
              t.update(configRef, {nextValidCode: code + 1});
            }
          });
          console.log("Game code transaction success!");
        } catch (e) {
          console.log("Game code transaction failure:", e);
          return null;
        }

        const data = {code};

        snap.ref.set(data, {merge: true}).then((res) => {
          return null;
        }).catch((err: Error) => {
          console.log(`Error on gameId ${gameId}: ${err}`);
          return null;
        });
      }
      console.log("Error getting data from document");
      return null;
    });
