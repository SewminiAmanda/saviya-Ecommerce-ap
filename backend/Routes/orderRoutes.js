const express = require('express');
const router = express.Router();
const orderController = require('../Controllers/orderController');
const authMiddleware = require('../middlewears/auth');

router.post('/', authMiddleware, orderController.createOrder);
router.get('/', authMiddleware, orderController.getUserOrders);
router.get("/buyer", authMiddleware, orderController.getUserOrders);   
router.get("/seller", authMiddleware, orderController.getSellerOrders);
router.get('/:orderId', authMiddleware, orderController.getOrderById);
router.put('/:orderId/status', authMiddleware, orderController.updateOrderStatus);

module.exports = router;
