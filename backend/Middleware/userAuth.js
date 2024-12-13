const express = require("express");
const app = express();

app.use(express.json()); // Middleware to parse JSON
app.use(express.urlencoded({ extended: true })); // Middleware to parse URL-encoded data

// Routes must be added after middleware
app.use('/api/users', userRoutes);
