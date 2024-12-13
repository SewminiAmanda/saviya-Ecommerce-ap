const bcrypt = require('bcryptjs'); // To hash the password
const db = require("../Model/index.js"); // Path to your index.js file
const Joi = require('joi'); // For input validation

// Validation schema using Joi
const userValidationSchema = Joi.object({
  first_name: Joi.string().min(2).max(50).required(),
  last_name: Joi.string().min(2).max(50).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(4).required(), // Password should be at least 4 characters
});

// Signup function
const signup = async (req, res) => {
  console.log("Request Body:", req.body);
  try {
    const { first_name, last_name, email, password } = req.body;

    // Validate input using Joi schema
    const { error } = userValidationSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ message: error.details[0].message });
    }

    // Check if the user already exists with the same email
    const existingUser = await db.users.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ message: "Email is already in use." });
    }

    // Hash the password before storing it
    const hashedPassword = await bcrypt.hash(password, 10); // Salt rounds set to 10

    // Create a new user
    const newUser = await db.users.create({
      first_name,
      last_name,
      email,
      password: hashedPassword,
    });

    res.status(201).json({
      message: "User registered successfully.",
      user: {
        id: newUser.id,
        first_name: newUser.first_name,
        last_name: newUser.last_name,
        email: newUser.email,
      },
    });
  } catch (error) {
    console.error("Error creating user:", error);
    res.status(500).json({ message: "Error creating user.", error: error.message });
  }
};

module.exports = { signup };
