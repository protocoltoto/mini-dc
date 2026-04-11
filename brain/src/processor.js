import energyRule from "../modules/rules/energy.js";
import networkRule from "../modules/rules/network.js";

import { sendLine } from "../modules/notifier/line.js";
import { handleAction } from "../modules/actuator/ha.js";

// ==============================
// REGISTER RULES (plug-in style)
// ==============================
const rules = [
  energyRule,
  networkRule
];

// ==============================
// MAIN PROCESSOR
// ==============================
export const processMessage = async (data) => {
  try {
    // basic validation
    if (!data || !data.metric || data.value === undefined) {
      console.warn("⚠️ Invalid message:", data);
      return;
    }

    // loop ทุก rule
    for (const rule of rules) {
      const result = rule(data);

      if (!result) continue;

      // ==========================
      // ALERT
      // ==========================
      if (result.alert) {
        await handleAlert(result.alert, data);
      }

      // ==========================
      // ACTION
      // ==========================
      if (result.action) {
        await handleActionWrapper(result.action, data);
      }
    }

  } catch (err) {
    console.error("❌ Processor error:", err.message);
  }
};

// ==============================
// ALERT HANDLER
// ==============================
const handleAlert = async (alert, data) => {
  try {
    // basic message fallback
    const message =
      alert.message ||
      `⚠️ Alert: ${data.metric} = ${data.value}`;

    await sendLine(message);

  } catch (err) {
    console.error("❌ Alert error:", err.message);
  }
};

// ==============================
// ACTION HANDLER
// ==============================
const handleActionWrapper = async (action, data) => {
  try {
    await handleAction(action, data);

  } catch (err) {
    console.error("❌ Action error:", err.message);
  }
};