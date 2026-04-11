import axios from "axios";

export const handleAction = async (action) => {
  if (!action) return;

  if (!process.env.HA_URL || !process.env.HA_TOKEN) {
    console.warn("⚠️ HA config missing");
    return;
  }

  switch (action.type) {
    case "reduce_load":
      console.log("⚡ Reducing load...");

      await axios.post(
        `${process.env.HA_URL}/api/services/switch/turn_off`,
        {
          entity_id: "switch.inverter"
        },
        {
          headers: {
            Authorization: `Bearer ${process.env.HA_TOKEN}`
          }
        }
      );
      break;

    default:
      console.warn("⚠️ Unknown action:", action.type);
  }
};