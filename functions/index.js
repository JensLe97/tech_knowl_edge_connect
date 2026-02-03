const functions = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

exports.setAdmin = functions.onCall(
  {
    enforceAppCheck: true, // Rejects requests without a valid App Check token
    maxInstances: 10, // Limits maximum concurrent instances to prevent billing spikes
  },
  async (request) => {
    try {
      console.log("setAdmin request", {
        hasAuth: !!request.auth,
        hasAppCheck: !!request.app,
        authUid: request.auth?.uid,
        isAdmin: request.auth?.token?.admin === true,
      });

      if (!request.auth || request.auth.token.admin !== true) {
        throw new functions.HttpsError(
          "permission-denied",
          "Admin privileges required.",
        );
      }

      const uid = request.data && request.data.uid;
      if (!uid || typeof uid !== "string") {
        throw new functions.HttpsError(
          "invalid-argument",
          "Missing or invalid uid.",
        );
      }

      await admin.auth().setCustomUserClaims(uid, { admin: true });
      return { ok: true };
    } catch (err) {
      console.error("setAdmin error", err);
      if (err instanceof functions.HttpsError) {
        throw err;
      }
      throw new functions.HttpsError(
        "internal",
        "Unexpected error in setAdmin.",
      );
    }
  },
);

exports.revokeAdmin = functions.onCall(
  {
    enforceAppCheck: true, // Rejects requests without a valid App Check token
    maxInstances: 10, // Limits maximum concurrent instances to prevent billing spikes
  },
  async (request) => {
    try {
      console.log("revokeAdmin request", {
        hasAuth: !!request.auth,
        hasAppCheck: !!request.app,
        authUid: request.auth?.uid,
        isAdmin: request.auth?.token?.admin === true,
      });

      if (!request.auth || request.auth.token.admin !== true) {
        throw new functions.HttpsError(
          "permission-denied",
          "Admin privileges required.",
        );
      }

      const uid = request.data && request.data.uid;
      if (!uid || typeof uid !== "string") {
        throw new functions.HttpsError(
          "invalid-argument",
          "Missing or invalid uid.",
        );
      }

      const user = await admin.auth().getUser(uid);
      const existingClaims = user.customClaims || {};
      if (!existingClaims.admin) {
        return { ok: true };
      }

      const { admin: _admin, ...rest } = existingClaims;
      await admin.auth().setCustomUserClaims(uid, rest);
      return { ok: true };
    } catch (err) {
      console.error("revokeAdmin error", err);
      if (err instanceof functions.HttpsError) {
        throw err;
      }
      throw new functions.HttpsError(
        "internal",
        "Unexpected error in revokeAdmin.",
      );
    }
  },
);
