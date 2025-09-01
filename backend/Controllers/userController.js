const User = require('../models/userModel');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const SECRET_KEY = '78a07bdfe276a6c00a94cfda343629dbb5d338bac19dae41b1929ee63b969';

const UserController = {
  // Register a new user
  register: async (req, res) => {
    const { first_name, last_name, email, password, address, phone_number, role, is_active, profile_picture } = req.body;
    console.log('Request body:', req.body); // Log the request body
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
        is_active: is_active !== undefined ? is_active : true,
        profile_picture: profile_picture || null
      };

      console.log('User data before creation:', userData); // Log the user data

      const newUser = await User.create(userData); // Pass the entire userData object

      // Respond with the created user data (without password)
      res.status(201).json({
        success: true,
        message: 'User registered successfully',
        user: {
          userid: newUser.userid,
          first_name: newUser.first_name,
          last_name: newUser.last_name,
          email: newUser.email
        }
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
        const token = jwt.sign({ userid: user.userid, email: user.email }, SECRET_KEY, { expiresIn: '12h' });

        res.status(200).json({
          success: true,
          message: 'Login successful',
          user: {
            userid: user.userid,
            first_name: user.first_name,
            last_name: user.last_name,
            email: user.email,
            is_rejected: user.is_rejected,
            is_verified: user.is_verified,
          },
          token
        });
      } else {
        res.status(400).json({ success: false, message: 'Invalid credentials' });
      }
    } catch (err) {
      res.status(500).json({ success: false, message: 'Error logging in', error: err.message });
    }
  },

  getCurrentUser: async (req, res) => {
    try {
      const user = await User.findByEmail(req.user.email);
      console.log('Request body:', user);
      if (!user) return res.status(404).json({ success: false, message: 'User not found' });

      res.status(200).json({
        success: true,
        user: {
          userid: user.userid,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          role: user.role,
          profile_picture: user.profile_picture,
          address: user.address,
          contact_number: user.contact_number,
          is_active: user.is_active

        }
      });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Error fetching user', error: err.message });
    }
  },
  logout: async (req, res) => {
    try {
      // On client, token should be removed manually 
      // localStorage.removeItem('token');
      res.status(200).json({
        success: true,
        message: 'Logout successful. Please remove the token on client side.'
      });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Logout failed', error: err.message });
    }
  },
  getAllUsers: async (req, res) => {
    try {
      const users = await User.findAll(); // Fetch all users
      res.status(200).json({ success: true, users });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Failed to fetch users', error: err.message });
    }
  },
  // Get all verified users
  getVerifiedUsers: async (req, res) => {
    try {
      const users = await User.findAll({ where: { is_verified: true } });
      res.status(200).json({ success: true, users });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Failed to fetch verified users', error: err.message });
    }
  },
  // Get all rejected users
  getRejectedUsers: async (req, res) => {
    try {
      const users = await User.findAll({ where: { is_rejected: true } });
      res.status(200).json({ success: true, users });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Failed to fetch verified users', error: err.message });
    }
  },

  // Get all unverified users
  getUnverifiedUsers: async (req, res) => {
    try {
      const users = await User.findAll({ where: { is_verified: false, is_rejected: false } });
      res.status(200).json({ success: true, users });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Failed to fetch unverified users', error: err.message });
    }
  },
  // Verify a user by ID
  verifyUser: async (req, res) => {
    const { id } = req.params;

    try {
      const user = await User.findByPk(id);
      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }

      user.is_verified = true;
      await user.save();

      res.status(200).json({ success: true, message: 'User verified successfully' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, message: 'Error verifying user', error: error.message });
    }
  },
  // Reject a user by ID
  rejectUser: async (req, res) => {
    const { id } = req.params;
    const { reason } = req.body;

    try {
      const user = await User.findByPk(id);
      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }

      user.is_rejected = true;
      user.is_verified = false;
      await user.save();

      res.status(200).json({
        success: true,
        message: 'User rejected successfully',
        user: {
          email: user.email,
          firstName: user.user_name,
          type: "user",
          is_rejected: user.is_rejected,
          is_verified: user.is_verified,
          reason
        }
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, message: 'Error rejecting user', error: error.message });
    }
  },
  updateVerificationDocs: async (req, res) => {
    const { id } = req.params;
    const { verification_docs } = req.body; // URL of uploaded file

    try {
      const user = await User.findByPk(id);
      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }

      user.verification_docs = verification_docs;
      await user.save();

      res.status(200).json({
        success: true,
        message: 'Verification document updated successfully',
        verification_docs: user.verification_docs
      });
    } catch (err) {
      res.status(500).json({
        success: false,
        message: 'Failed to update verification document',
        error: err.message
      });
    }
  },

  //admin panel user stats
  getUserStats: async (req, res) => {
    try {
      const totalUsers = await User.count();
      const verifiedUsers = await User.count({ where: { is_verified: true } });
      const rejectedUsers = await User.count({ where: { is_rejected: true } });
      const pendingUsers = await User.count({ where: { is_verified: false, is_rejected: false } });

      res.status(200).json({
        success: true,
        stats: {
          totalUsers,
          verifiedUsers,
          rejectedUsers,
          pendingUsers,
        },
      });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Error fetching user stats', error: err.message });
    }
  },
  getUserById: async (req, res) => {
    try {
      const userId = req.params.id; // Extract the ID from the URL
      const user = await User.findById(userId);

      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }

      res.status(200).json({
        success: true,
        user: {
          userid: user._id,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          role: user.role,
          profile_picture: user.profile_picture,
          address: user.address,
          contact_number: user.contact_number,
          is_active: user.is_active
        }
      });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Error fetching user', error: err.message });
    }
  },
  // Add/update shipping address
  updateShippingAddress: async (req, res) => {
    try {
      console.log("Incoming request body:", req.body);
      const userId = req.user.userid;
      console.log("user id in address: ", userId);

      const { address } = req.body;
      if (!address) {
        console.log("No address provided!");
        return res.status(400).json({
          success: false,
          message: 'Shipping address is required'
        });
      }

      const user = await User.findById(userId);
      if (!user) {
        console.log("User not found for ID:", userId);
        return res.status(404).json({ success: false, message: 'User not found' });
      }

      // Update the shipping address
      user.address = address;
      await user.save();
      console.log("Updated address:", user.address);

      res.status(200).json({
        success: true,
        message: 'Shipping address updated successfully',
        address: user.address
      });
    } catch (err) {
      console.error("Failed to update shipping address:", err);
      res.status(500).json({
        success: false,
        message: 'Failed to update shipping address',
        error: err.message
      });
    }
  }

  

};

module.exports = UserController;