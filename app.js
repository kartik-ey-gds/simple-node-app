const express = require('express');
const app = express();

app.use(express.json());

// Simple endpoints
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to Simple Node App',
    status: 'running',
    version: '1.0.0',
    timestamp: new Date()
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptime: Math.floor(process.uptime()),
    memory: process.memoryUsage()
  });
});

app.get('/api/info', (req, res) => {
  res.json({
    app: 'Simple Node App',
    environment: process.env.NODE_ENV || 'development',
    version: '1.0.0'
  });
});

app.post('/api/echo', (req, res) => {
  res.json({
    received: req.body,
    echoed: true,
    timestamp: new Date()
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: err.message });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
  console.log(`📍 Try: http://localhost:${PORT}/`);
  console.log(`🏥 Health: http://localhost:${PORT}/health`);
});
