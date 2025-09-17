const Admin = require('../models/adminModel');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const EmailController = require('./emailController');
const { generateTempPassword } = require('../middlewears/passwordGenerator');

const SECRET_KEY = process.env.JWT_SECRET || '78a07bdfe276a6c00a94cfda343629dbb5d338bac19dae41b1929ee63b969';

const AdminController = {
  //  Invite Admin via Email (temp password)
  inviteAdmin: async (req, res) => {
    try {
      const { email } = req.body;

      // Check if already exists
      const existing = await Admin.findOne({ where: { email } });
      if (existing) {
        return res.status(400).json({ message: 'User already exists with this email' });
      }

      const tempPassword = generateTempPassword();
      console.log("tempory password is",tempPassword);

      // Create admin with minimal data
      const newAdmin = await Admin.create({
        email,
        password: tempPassword,
        role: 'ADMIN',
        isFirstLogin: true,
        user_name: email.split('@')[0], 
      });

      // Send email
      await EmailController.sendAdminInvite(email, tempPassword);

      res.status(201).json({
        success: true,
        message: 'Admin added & invite sent',
        data: {
          id: newAdmin.userid,
          email: newAdmin.email
        }
      });
    } catch (error) {
      console.error("Error inviting admin:", error);
      res.status(500).json({
        success: false,
        message: 'Failed to invite admin',
        error: error.message
      });
    }
  },

  ///  Login - Add debug logging
  login: async (req, res) => {
    try {
      const { email, password } = req.body;

      console.log('Login attempt for:', email);
      console.log('Password received:', password);

      const user = await Admin.findByEmail(email);
      if (!user) {
        console.log('Admin not found:', email);
        return res.status(404).json({ message: 'Admin not found.' });
      }

      console.log('Admin found. Stored hash:', user.password);

      const isMatch = await bcrypt.compare(password, user.password);
      console.log('Password match result:', isMatch);

      if (!isMatch) {
        console.log('Invalid password for:', email);
        return res.status(401).json({ message: 'Invalid password.' });
      }

      const token = jwt.sign(
        { id: user.userid, email: user.email, isAdmin: true },
        SECRET_KEY,
        { expiresIn: '2h' }
      );

      console.log('Login successful for:', email);

      res.status(200).json({
        message: 'Login successful.',
        token,
        admin: {
          id: user.userid,
          user_name: user.user_name,
          email: user.email,
          profile_picture: user.profile_picture,
          isFirstLogin: user.isFirstLogin
        }
      });
    } catch (error) {
      console.error('Server error during login:', error);
      res.status(500).json({ message: 'Server error during login.', error: error.message });
    }
  },

  // Get logged in admin
  getCurrentAdmin: async (req, res) => {
    try {
      const userId = req.user.id;
      const admin = await Admin.findByPk(userId);

      if (!admin) return res.status(404).json({ message: 'Admin not found' });

      res.status(200).json({
        id: admin.userid,
        user_name: admin.user_name,
        email: admin.email,
        profile_picture: admin.profile_picture,
        isFirstLogin: admin.isFirstLogin
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Error fetching admin profile' });
    }
  },

  // Update Admin
  updateAdmin: async (req, res) => {
    try {
      const userId = req.user.id;
      if (parseInt(req.params.id) !== userId) {
        return res.status(403).json({ message: 'Forbidden: cannot update other admin.' });
      }

      const admin = await Admin.findByPk(userId);
      if (!admin) return res.status(404).json({ message: 'Admin not found' });

      const { user_name, email, profile_picture } = req.body;
      admin.user_name = user_name || admin.user_name;
      admin.email = email || admin.email;
      admin.profile_picture = profile_picture || admin.profile_picture;

      await admin.save();
      res.status(200).json({ message: 'Admin updated successfully.' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Error updating admin profile.' });
    }
  },

  // Delete Admin
  deleteAdmin: async (req, res) => {
    try {
      const userId = req.user.id;
      if (parseInt(req.params.id) !== userId) {
        return res.status(403).json({ message: 'Forbidden: cannot delete other admin.' });
      }

      const admin = await Admin.findByPk(userId);
      if (!admin) return res.status(404).json({ message: 'Admin not found' });

      await admin.destroy();
      res.status(200).json({ message: 'Admin deleted successfully.' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Error deleting admin profile.' });
    }
  },

  // First Login → update password
  updatePassword: async (req, res) => {
    try {
      const userId = req.user.id;
      const { newPassword, user_name } = req.body;

      const hashedPassword = await bcrypt.hash(newPassword, 10);

      await Admin.update(
        {
          password: hashedPassword,
          isFirstLogin: false,
          user_name: user_name
        },
        { where: { userid: userId } }
      );

      res.json({ success: true, message: 'Password updated successfully' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, message: 'Failed to update password' });
    }
  }
};

module.exports = AdminController;