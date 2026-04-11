import "dotenv/config";
import { startMQTT } from "./mqtt.js";

// ==============================
// BOOTSTRAP
// ==============================
const start = async () => {
  try {
    console.log("🚀 Starting Mini-DC Brain...");

    // ==========================
    // START MQTT
    // ==========================
    startMQTT();

    console.log("✅ Brain started");

  } catch (err) {
    console.error("❌ Failed to start:", err.message);
    process.exit(1);
  }
};

// ==============================
// GLOBAL ERROR HANDLER
// ==============================
process.on("uncaughtException", (err) => {
  console.error("🔥 Uncaught Exception:", err);
});

process.on("unhandledRejection", (err) => {
  console.error("🔥 Unhandled Rejection:", err);
});

// ==============================
// START APP
// ==============================
start();