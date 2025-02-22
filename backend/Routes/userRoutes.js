const express = require('express');
const UserController = require('../controllers/userController');  // Import user controller

const router = express.Router();

// User routes
router.post('/register', UserController.register);  // Register user
router.post('/login', UserController.login);        // Login user

module.exports = router;
