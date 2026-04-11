import mqtt from "mqtt";
import { processMessage } from "./core/processor.js";

// ==============================
// CONFIG
// ==============================
const MQTT_OPTIONS = {
  host: process.env.MQTT_HOST,
  port: Number(process.env.MQTT_PORT),
  username: process.env.MQTT_USER,
  password: process.env.MQTT_PASSWORD,

  reconnectPeriod: 5000,      // reconnect ทุก 5s
  connectTimeout: 30 * 1000,  // 30s timeout
  clean: true
};

// ==============================
// START MQTT
// ==============================
export const startMQTT = () => {
  const client = mqtt.connect(MQTT_OPTIONS);

  // ==========================
  // CONNECT
  // ==========================
  client.on("connect", () => {
    console.log("✅ MQTT connected");

    const topics = process.env.MQTT_TOPICS || "mini-dc/+/+/+";

    client.subscribe(topics, (err) => {
      if (err) {
        console.error("❌ Subscribe error:", err.message);
      } else {
        console.log(`📡 Subscribed to: ${topics}`);
      }
    });
  });

  // ==========================
  // RECONNECT
  // ==========================
  client.on("reconnect", () => {
    console.warn("🔄 MQTT reconnecting...");
  });

  // ==========================
  // OFFLINE
  // ==========================
  client.on("offline", () => {
    console.warn("⚠️ MQTT offline");
  });

  // ==========================
  // ERROR
  // ==========================
  client.on("error", (err) => {
    console.error("❌ MQTT error:", err.message);
  });

  // ==========================
  // MESSAGE
  // ==========================
  client.on("message", async (topic, payload) => {
    try {
      const raw = payload.toString();

      let data;
      try {
        data = JSON.parse(raw);
      } catch {
        console.warn("⚠️ Invalid JSON:", raw);
        return;
      }

      // attach topic (useful later for routing)
      data._topic = topic;

      await processMessage(data);

    } catch (err) {
      console.error("❌ Message handling error:", err.message);
    }
  });

  return client;
};