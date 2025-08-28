const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const authMiddleware = require('../middlewears/auth.js');

router.post('/create', authMiddleware, productController.create);
router.get('/', productController.getAll);
router.get('/user', authMiddleware, productController.getByUserId);
router.get('/category/:categoryid', productController.getByCategoryId);
router.get('/:id', authMiddleware, productController.getById);
router.put('/:id', authMiddleware, productController.update);
router.delete('/:id', authMiddleware, productController.delete);
router.get('/user', authMiddleware, productController.getByUserId);

module.exports = router;