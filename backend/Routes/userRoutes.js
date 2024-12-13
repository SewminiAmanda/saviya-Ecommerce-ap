const express = require('express');
const userController = require('../Controllers/userController');
const { signup, login } = userController;
const userAuth = require('../Middleware/userAuth');

const router = express.Router();

// Signup route with middleware for validation
router.post('/signup', userAuth.saveUser, signup);

// Login route
router.post('/login', login);

module.exports = router;
