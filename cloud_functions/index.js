const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

admin.initializeApp();
const db = admin.firestore();

// Weekly summaries with optional LLM provider (configure env var: LLM_API_KEY, LLM_ENDPOINT)
exports.weeklyParentReport = functions.pubsub.schedule('every 168 hours').onRun(async () => {
  const users = await db.collection('users').where('role','==','child').get();
  for (const doc of users.docs) {
    const child = doc.data();
    const parentId = child.parent_id;
    if (!parentId) continue;
    const minutes = child.remaining_minutes || 0;
    const prompt = `Summarize child weekly usage: minutes=${minutes}. Provide 2 recommendations.`;
    let summary = `Weekly usage: ${minutes} minutes. Recommendation: Set clear schedules.`;
    try {
      const key = process.env.LLM_API_KEY;
      const endpoint = process.env.LLM_ENDPOINT;
      if (key && endpoint) {
        const resp = await fetch(endpoint, { method:'POST', headers:{'Authorization':`Bearer ${key}`,'Content-Type':'application/json'}, body: JSON.stringify({prompt}) });
        if (resp.ok) {
          const data = await resp.json();
          summary = data.summary || data.output || summary;
        }
      }
    } catch(e) {}
    await db.collection('reports').add({ parent_id: parentId, child_id: doc.id, summary, ts: admin.firestore.FieldValue.serverTimestamp() });
  }
  return null;
});
