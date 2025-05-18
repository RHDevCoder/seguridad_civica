const express = require('express');
const db = require('./config/db'); // Importa la conexión a la base de datos
const app = express();
const port = 3000;

app.use(express.json());

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

module.exports = app;