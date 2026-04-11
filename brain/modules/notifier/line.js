import axios from "axios";

export const sendLine = async (message) => {
  if (!process.env.LINE_TOKEN) {
    console.warn("⚠️ LINE_TOKEN not set");
    return;
  }

  await axios.post(
    "https://notify-api.line.me/api/notify",
    new URLSearchParams({ message }),
    {
      headers: {
        Authorization: `Bearer ${process.env.LINE_TOKEN}`
      }
    }
  );
};