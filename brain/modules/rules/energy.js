export default (data) => {
  if (data.metric !== "power") return;

  const threshold = Number(process.env.POWER_THRESHOLD || 2000);

  if (data.value > threshold) {
    return {
      alert: {
        message: `⚡ Power High\nZone: ${data.tags?.zone}\nDevice: ${data.tags?.device}\nValue: ${data.value}W`
      },
      action: {
        type: "reduce_load",
        device: data.tags?.device
      }
    };
  }
};