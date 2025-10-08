import fs from 'fs';
import axios from 'axios';

export default async function handler(req, res) {
  try {
    const { query } = req.body || {};
    if (!query) return res.status(400).json({ error: 'query required' });

    const HUGGINGFACE_KEY = process.env.HUGGINGFACE_API_KEY || '';
    const QDRANT_URL = process.env.QDRANT_URL || '';
    const QDRANT_KEY = process.env.QDRANT_API_KEY || '';

    let vector;
    if (HUGGINGFACE_KEY) {
      const embRes = await axios.post(
        "https://api-inference.huggingface.co/pipeline/feature-extraction/sentence-transformers/all-MiniLM-L6-v2",
        query,
        { headers: { Authorization: `Bearer ${HUGGINGFACE_KEY}` } }
      );
      vector = Array.isArray(embRes.data[0]) ? embRes.data[0] : embRes.data;
      if (Array.isArray(vector[0])) vector = vector[0];
    } else {
      vector = Array.from({length:384}, (_,i)=> ((query.charCodeAt(i % query.length) || 1) % 100)/100);
    }

    if (QDRANT_URL && !QDRANT_URL.includes('your-qdrant')) {
      const qRes = await axios.post(`${QDRANT_URL}/collections/foods/points/search`, { vector, limit: 6 }, { headers: { 'api-key': QDRANT_KEY }});
      return res.status(200).json(qRes.data.result);
    } else {
      const sample = JSON.parse(fs.readFileSync('./sample_foods.json','utf8'));
      const qLower = query.toLowerCase();
      const scored = sample.map(s => {
        let score = 0;
        if ((s.name||'').toLowerCase().includes(qLower)) score += 3;
        if ((s.description||'').toLowerCase().includes(qLower)) score += 2;
        (s.tags||[]).forEach(t => { if (t.includes(qLower)) score += 2; });
        return {...s, score};
      }).sort((a,b)=>b.score - a.score);
      const top = scored.slice(0,6).map(s => ({ id: s.id, score: s.score, payload: s }));
      return res.status(200).json(top);
    }
  } catch (err) {
    console.error(err?.response?.data || err.message || err);
    return res.status(500).json({ error: 'server error' });
  }
}
