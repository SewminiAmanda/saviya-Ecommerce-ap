const User = require('../models/adminModel');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const SECRET_KEY = '78a07bdfe276a6c00a94cfda343629dbb5d338bac19dae41b1929ee63b969';

const AdminController = {
    signup: async (req, res) => {
        try {
            const { user_name, email, password, profile_picture } = req.body;

            // Check if email already exists
            const existingUser = await User.findByEmail(email);
            if (existingUser) {
                return res.status(400).json({ message: 'Email already in use.' });
            }

            // Create new admin
            const newUser = await User.create({
                user_name,
                email,
                password, // will be hashed in hook
                profile_picture
            });

            res.status(201).json({ message: 'Admin registered successfully.' });
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Server error during signup.' });
        }
    },

    // LOGIN
    login: async (req, res) => {
        try {
            const { email, password } = req.body;

            const user = await User.findByEmail(email);
            if (!user) {
                return res.status(404).json({ message: 'Admin not found.' });
            }

            const isMatch = await bcrypt.compare(password, user.password);
            if (!isMatch) {
                return res.status(401).json({ message: 'Invalid password.' });
            }

            // Generate JWT
            const token = jwt.sign(
                { id: user.userid, email: user.email ,isAdmin: true,},
                SECRET_KEY,
                { expiresIn: '2h' }
            );

            res.status(200).json({
                message: 'Login successful.',
                token,
                admin: {
                    id: user.userid,
                    user_name: user.user_name,
                    email: user.email,
                    profile_picture: user.profile_picture,
                }
            });
        } catch (error) {
            console.error(error);
            res.status(500).json({ message: 'Server error during login.' });
        }
    },

    getCurrentAdmin: async (req, res) => {
    try {
        const userId = req.user.id; // This comes from the decoded token via middleware
        const admin = await User.findByPk(userId); // Assuming you're using Sequelize

        if (!admin) {
            return res.status(404).json({ message: 'Admin not found' });
        }

        res.status(200).json({
            id: admin.userid,
            user_name: admin.user_name,
            email: admin.email,
            profile_picture: admin.profile_picture
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error fetching admin profile' });
    }
},
updateAdmin: async (req, res) => {
    try {
      const userId = req.user.id; // From middleware
      const { firstName, lastName, email, contactNumber } = req.body;

      if (parseInt(req.params.id) !== userId) {
        return res.status(403).json({ message: 'Forbidden: cannot update other admin.' });
      }

      const admin = await User.findByPk(userId);
      if (!admin) {
        return res.status(404).json({ message: 'Admin not found' });
      }

      // Update fields - adjust these if your model uses different attribute names
      admin.firstName = firstName || admin.firstName;
      admin.lastName = lastName || admin.lastName;
      admin.email = email || admin.email;
      admin.contactNumber = contactNumber || admin.contactNumber;

      await admin.save();

      res.status(200).json({ message: 'Admin profile updated successfully.' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Error updating admin profile.' });
    }
  },

  deleteAdmin: async (req, res) => {
    try {
      const userId = req.user.id; // From middleware

      if (parseInt(req.params.id) !== userId) {
        return res.status(403).json({ message: 'Forbidden: cannot delete other admin.' });
      }

      const admin = await User.findByPk(userId);
      if (!admin) {
        return res.status(404).json({ message: 'Admin not found' });
      }

      await admin.destroy();

      res.status(200).json({ message: 'Admin profile deleted successfully.' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Error deleting admin profile.' });
    }
  }

};

module.exports = AdminController;
