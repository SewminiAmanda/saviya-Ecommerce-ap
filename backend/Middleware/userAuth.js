const db = require('../Model');
const User = db.users;

// Middleware to check if first_name, last_name, or email already exist
const saveUser = async (req, res, next) => {
  console.log('Request Body:', req.body);

  try {
    // Check if first_name, last_name, or email are missing
    if (!req.body.first_name || !req.body.last_name || !req.body.email) {
      return res.status(400).send('First name, last name, and email are required');
    }

    // Check if email already exists
    const emailCheck = await User.findOne({ where: { email: req.body.email } });
    if (emailCheck) {
      return res.status(409).send('Email already in use');
    }

    // Check if first_name or last_name already exists (optional, depending on your logic)
    const firstNameCheck = await User.findOne({ where: { first_name: req.body.first_name } });
    if (firstNameCheck) {
      return res.status(409).send('First name already taken');
    }

    const lastNameCheck = await User.findOne({ where: { last_name: req.body.last_name } });
    if (lastNameCheck) {
      return res.status(409).send('Last name already taken');
    }

    // If everything is fine, proceed to the next middleware (signup)
    next();
  } catch (error) {
    console.error(error);
    return res.status(500).send('An error occurred while checking first_name/last_name/email');
  }
};

module.exports = {
  saveUser,
};
