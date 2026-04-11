export default (data) => {
  if (data.metric !== "latency") return;

  const threshold = Number(process.env.LATENCY_THRESHOLD || 100);

  if (data.value > threshold) {
    return {
      alert: {
        message: `🌐 High Latency\nZone: ${data.tags?.zone}\nDevice: ${data.tags?.device}\nValue: ${data.value} ms`
      }
    };
  }
};