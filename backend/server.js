const express = require("express");
const cookieParser = require("cookie-parser");
const cors = require("cors");
const db = require("./Model"); // Sequelize instance and models
const userRoutes = require("./Routes/userRoutes");
require('dotenv').config();


const PORT = 8080;
const app = express();

// Middleware
app.use(cors()); // Allows cross-origin requests
app.use(express.json()); // Parses incoming JSON payloads
app.use(express.urlencoded({ extended: true })); // Parses URL-encoded payloads
app.use(cookieParser());

// Routes
app.use("/api/users", userRoutes);

// Sync database
db.sequelize.sync({ force: true }).then(() => {
  console.log("Database synced successfully");
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
