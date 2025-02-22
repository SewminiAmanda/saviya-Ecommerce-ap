const User = require('../models/userModel');  // Import the user model
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const SECRET_KEY = '78a07bdfe276a6c00a94cfda343629dbb5d338bac19dae41b1929ee63b969'; // Replace with a strong secret key

const UserController = {
    // Register a new user
    register: async (req, res) => {
        const { first_name, last_name, email, password, address, phone_number, role, is_active, profile_picture } = req.body;

        try {
            const existingUser = await User.findByEmail(email);
            if (existingUser) {
                return res.status(400).json({ success: false, message: 'User already exists with that email' });
            }

            // Set default values for optional fields if they are not provided
            const userData = {
                first_name,
                last_name,
                email,
                password,
                address: address || null,
                phone_number: phone_number || null,
                role: role || 'user', // Default role is 'user'
                is_active: is_active !== undefined ? is_active : true, // Default is_active is true
                profile_picture: profile_picture || null
            };

            const newUser = await User.create(
                userData.first_name,
                userData.last_name,
                userData.email,
                userData.password,
                userData.address,
                userData.phone_number,
                userData.role,
                userData.is_active,
                userData.profile_picture
            );

            // Respond with the created user data (without token)
            res.status(201).json({
                success: true,
                message: 'User registered successfully',
                user: { userId: newUser.userId, first_name: newUser.first_name, last_name: newUser.last_name, email: newUser.email }
            });
        } catch (err) {
            res.status(500).json({ success: false, message: 'Error registering user', error: err.message });
        }
    },

    // Login user
login: async (req, res) => {
    const { email, password } = req.body;

    try {
        const user = await User.findByEmail(email);
        if (user && await bcrypt.compare(password, user.password)) {
            // Generate token with 30 minutes expiration
            const token = jwt.sign({ userId: user.userId, email: user.email }, SECRET_KEY, { expiresIn: '30m' });

            res.status(200).json({
                success: true,
                message: 'Login successful',
                user: { userId: user.userId, first_name: user.first_name, last_name: user.last_name, email: user.email },
                token // Send the token in the response
            });
        } else {
            res.status(400).json({ success: false, message: 'Invalid credentials' });
        }
    } catch (err) {
        res.status(500).json({ success: false, message: 'Error logging in', error: err.message });
    }
},

};

module.exports = UserController;