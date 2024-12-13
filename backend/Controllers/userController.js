const bcrypt = require('bcrypt');
const db = require('../Model');
const jwt = require('jsonwebtoken');

const User = db.users;

// Sign up logic
const signup = async (req, res) => {
  try {
    const { first_name, last_name, email, password } = req.body;
    
    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Construct user data
    const data = {
      first_name,
      last_name,
      email,
      password: hashedPassword,
    };

    // Save the user
    const user = await User.create(data);

    // Generate JWT token
    const token = jwt.sign({ id: user.id }, process.env.secretKey, {
      expiresIn: '1d',  // Token expires in 1 day
    });

    // Set JWT token in cookies
    res.cookie('jwt', token, { maxAge: 1 * 24 * 60 * 60 * 1000, httpOnly: true });

    // Send user data back with status 201 (created)
    return res.status(201).send(user);
  } catch (error) {
    console.error(error);
    return res.status(500).send('Server error');
  }
};

// Login logic
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user by email
    const user = await User.findOne({ where: { email } });

    if (!user) {
      return res.status(401).send('Authentication failed');
    }

    // Compare the password
    const isMatch = await bcrypt.compare(password, user.password);
    
    if (!isMatch) {
      return res.status(401).send('Authentication failed');
    }

    // Generate JWT token
    const token = jwt.sign({ id: user.id }, process.env.secretKey, {
      expiresIn: '1d',
    });

    // Set JWT token in cookies
    res.cookie('jwt', token, { maxAge: 1 * 24 * 60 * 60 * 1000, httpOnly: true });

    // Send user data back with status 200 (OK)
    return res.status(200).send(user);
  } catch (error) {
    console.error(error);
    return res.status(500).send('Server error');
  }
};

module.exports = {
  signup,
  login,
};
