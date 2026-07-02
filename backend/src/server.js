const app = require('./app');

const PORT = 8080;

app.listen(PORT, () => {
  console.log(`Backend API listening on port ${PORT}`);
});
