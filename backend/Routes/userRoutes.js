const express = require("express");
const { signup, login, profile } = require("../Controllers/userController");
const { verifyToken } = require('../Middleware/verifyToken');
const router = express.Router();

router.post("/signup", signup);

router.post('/login', login);

router.get('/profile', verifyToken, profile);

module.exports = router;
