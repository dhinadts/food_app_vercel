import fs from 'fs';
import axios from 'axios';

const HUGGINGFACE_KEY = process.env.HUGGINGFACE_API_KEY || '';
const QDRANT_URL = process.env.QDRANT_URL || '';
const QDRANT_KEY = process.env.QDRANT_API_KEY || '';

async function getEmbedding(text) {
  if (HUGGINGFACE_KEY) {
    const r = await axios.post("https://api-inference.huggingface.co/pipeline/feature-extraction/sentence-transformers/all-MiniLM-L6-v2", text, { headers: { Authorization: `Bearer ${HUGGINGFACE_KEY}` }});
    let vector = r.data;
    if (Array.isArray(vector[0])) vector = vector[0];
    return vector;
  } else {
    return Array.from({length:384}, (_,i)=> ((text.charCodeAt(i % text.length) || 1)%100)/100);
  }
}

async function main(){
  const sample = JSON.parse(fs.readFileSync('./sample_foods.json','utf8'));
  const points = [];
  for (const f of sample) {
    const emb = await getEmbedding(f.description || f.name);
    points.push({ id: f.id, vector: emb, payload: f });
  }
  if (!QDRANT_URL || QDRANT_URL.includes('your-qdrant')) {
    console.log('Demo mode: prepared', points.length, 'points. Not sending to Qdrant.');
    return;
  }
  const resp = await axios.put(`${QDRANT_URL}/collections/foods/points`, { points }, { headers: { 'api-key': QDRANT_KEY }});
  console.log('Inserted to Qdrant:', resp.data);
}

main().catch(e => { console.error(e); process.exit(1); });
