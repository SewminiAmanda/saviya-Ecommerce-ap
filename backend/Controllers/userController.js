const db = require("../Model/index.js"); // Path to your index.js file

// Signup function
const signup = async (req, res) => {
  console.log("Request Body:", req.body);
  try {
    const { first_name, last_name, email, password } = req.body;

    // Check if all required fields are provided
    if (!first_name || !last_name || !email || !password) {
      return res.status(400).json({ message: "All fields are required." });
    }

    // Check if the user already exists with the same email
    const existingUser = await db.users.findOne({ where: { email } });

    if (existingUser) {
      return res.status(400).json({ message: "Email is already in use." });
    }

    // Create a new user
    const newUser = await db.users.create({ first_name, last_name, email, password });

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
