const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const authMiddleware = require('../middlewears/auth');

router.post('/', authMiddleware, orderController.createOrder);
router.get('/', authMiddleware, orderController.getUserOrders);
router.get('/:orderId', authMiddleware, orderController.getOrderById);
router.put('/:orderId', authMiddleware, orderController.updateOrderStatus);

module.exports = router;
