import fs from 'fs';
import axios from 'axios';

export default async function handler(req, res) {
  try {
    const { lastDishEmbedding } = req.body || {};
    const QDRANT_URL = process.env.QDRANT_URL || '';
    const QDRANT_KEY = process.env.QDRANT_API_KEY || '';

    if (QDRANT_URL && !QDRANT_URL.includes('your-qdrant')) {
      const qRes = await axios.post(`${QDRANT_URL}/collections/foods/points/search`, { vector: lastDishEmbedding, limit: 6 }, { headers: { 'api-key': QDRANT_KEY }});
      return res.status(200).json(qRes.data.result);
    } else {
      const sample = JSON.parse(fs.readFileSync('./sample_foods.json','utf8'));
      return res.status(200).json(sample.slice(0,5));
    }
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'server error' });
  }
}
