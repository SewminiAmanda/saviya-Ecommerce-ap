const express = require('express');
const router = express.Router();
const CartController = require('../controllers/cartController');
const authMiddleware = require('../middlewears/auth.js'); 

router.get('/', authMiddleware, CartController.getCart);
router.post('/items', authMiddleware, CartController.addToCart);
router.put('/items/:itemId', authMiddleware, CartController. updateCartItem);
router.delete('/items/:itemId', authMiddleware, CartController.removeFromCart);
router.delete('/clear', authMiddleware, CartController.clearCart);

module.exports = router;
