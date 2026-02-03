const admin = require("firebase-admin");

const serviceAccountPath =
  process.env.GOOGLE_APPLICATION_CREDENTIALS ||
  process.env.SERVICE_ACCOUNT_PATH ||
  "../keys/tech-knowl-edge-connect-40c99169d4a2.json";
const uid = process.argv[2];

if (!serviceAccountPath) {
  console.error(
    "Missing service account credentials. Set GOOGLE_APPLICATION_CREDENTIALS or SERVICE_ACCOUNT_PATH.",
  );
  process.exit(1);
}

if (!uid) {
  console.error("Usage: node set_admin_claim.js <uid>");
  process.exit(1);
}

const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

admin
  .auth()
  .setCustomUserClaims(uid, { admin: true })
  .then(() => {
    console.log(`Admin claim set for ${uid}`);
    process.exit(0);
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
