import axios from 'axios';

export default async function handler(req, res) {
  try {
    const { userPrompt } = req.body || {};
    if (!userPrompt) return res.status(400).json({ error: 'userPrompt required' });

    const GEMINI_KEY = process.env.GEMINI_API_KEY || '';

    if (!GEMINI_KEY) {
      return res.status(200).json({ reply: 'Demo: Set GEMINI_API_KEY to enable real chatbot. Try "Suggest me breakfast with high protein".' });
    }

    // NOTE: adapt to your Gemini REST/SDK call. This is a placeholder.
    const endpoint = 'https://api.generativelanguage.googleapis.com/v1beta2/models/gemini-lite:generateText';
    const prompt = `You are a helpful food assistant. ${userPrompt}`;
    const r = await axios.post(endpoint, { prompt: { text: prompt } }, { headers: { Authorization: `Bearer ${GEMINI_KEY}` }});
    const reply = r.data?.candidates?.[0]?.content || r.data?.output?.[0]?.content || JSON.stringify(r.data);
    return res.status(200).json({ reply });
  } catch (err) {
    console.error(err?.response?.data || err.message || err);
    return res.status(500).json({ error: 'server error' });
  }
}
