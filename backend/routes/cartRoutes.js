const express = require('express');
const router = express.Router();
const CartController = require('../controllers/cartController');
const authMiddleware = require('../middleware/auth'); 

router.post('/add', authMiddleware, CartController.addToCart);
router.get('/', authMiddleware, CartController.getCart);
router.put('/:id', authMiddleware, CartController.updateCartItem);
router.delete('/:id', authMiddleware, CartController.removeFromCart);

module.exports = router;
