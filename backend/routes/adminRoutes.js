const express = require('express');
const AdminController = require('../controllers/adminController');  
const authenticate = require('../middlewears/auth');  
const router = express.Router();

// Admin routes
router.post('/register', AdminController.signup);  
router.post('/login', AdminController.login);   
router.get('/adminuser', authenticate, AdminController.getCurrentAdmin);     
router.put('/admin/update/:id', authenticate, AdminController.updateAdmin);
router.delete('/admin/delete/:id', authenticate, AdminController.deleteAdmin);

module.exports = router;