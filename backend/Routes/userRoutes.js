const express = require('express');
const UserController = require('../controllers/userController');  // Import user controller
const authenticate = require('../middlewears/auth');  
const EmailController = require('../controllers/emailController');
const router = express.Router();

// User routes
router.post('/register', UserController.register);
router.post('/login', UserController.login);

// Admin & verified user routes (specific first)
router.get('/verified', UserController.getVerifiedUsers);
router.get('/rejected', UserController.getRejectedUsers);
router.get('/unverified', UserController.getUnverifiedUsers);
router.get('/user-stats', UserController.getUserStats);
router.get('/', UserController.getAllUsers);

router.put('/verify/:id', authenticate, UserController.verifyUser);
router.put('/reject/:id', UserController.rejectUser);
router.post('/emails/reject', EmailController.sendRejectionEmail);
router.put('/update-verification-doc/:id', UserController.updateVerificationDocs);

// Should always be last
router.get('/:id', UserController.getUserById);






module.exports = router;
