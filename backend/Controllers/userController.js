// controllers/authController.js
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Joi = require('joi');
const db = require('../Model/index'); // Import db object
const User = db.users; // Access the User model from db

// Validation schema using Joi
const userValidationSchema = Joi.object({
  first_name: Joi.string().min(2).max(50).required(),
  last_name: Joi.string().min(2).max(50).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(4).required(),
});

// Signup function
const signup = async (req, res) => {
  const { first_name, last_name, email, password } = req.body;

  // Validate incoming request body
  const { error } = userValidationSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ message: error.details[0].message });
  }

  try {
    // Check if the user already exists
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ message: 'Email is already in use' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create new user
    const newUser = await User.create({
      first_name,
      last_name,
      email,
      password: hashedPassword,
    });

    res.status(201).json({ message: 'User registered successfully', user: newUser });
  } catch (error) {
    console.log(error); // Log the error for debugging
    res.status(500).json({ message: 'Error registering user', error: error.message });
  }
};

// Login function
const login = async (req, res) => {
  const { email, password } = req.body;

  // Find user by email
  const user = await User.findOne({ where: { email } });
  if (!user) {
    return res.status(400).json({ message: 'Invalid credentials.' });
  }

  // Compare password with hashed password
  const validPassword = await bcrypt.compare(password, user.password);
  if (!validPassword) {
    return res.status(400).json({ message: 'Invalid credentials.' });
  }

  // Generate JWT token
  const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, { expiresIn: '1h' });

  res.status(200).json({
    message: 'Login successful.',
    token,
  });
};

// Profile function
const profile = (req, res) => {
  res.status(200).json({
    message: 'Access to profile',
    user: req.user, // The user data comes from the JWT token
  });
};

module.exports = { signup, login, profile };
