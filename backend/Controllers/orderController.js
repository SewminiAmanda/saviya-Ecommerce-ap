// controllers/orderController.js

const Order = require('../models/orderModel');
const Cart = require('../models/cartModel');
const CartItem = require('../models/cartItemModel'); // Correct import
const OrderItem = require("../models/orderItemModel"); 
const Product = require('../models/productModel');


exports.createOrder = async (req, res) => {
    try {
        const userId = req.user.userid; // from auth middleware
        console.log("user id in order: ", userId);

        const cart = await Cart.findOne({
            where: { userId },
            include: [{ model: CartItem, as: 'items' }]
        });

        if (!cart || cart.items.length === 0) {
            return res.status(400).json({ message: "Cart is empty" });
        }

        // ✅ Calculate total
        const totalAmount = cart.items.reduce(
            (sum, item) => sum + (item.price * item.quantity),
            0
        );


        // ✅ Create order
        const order = await Order.create({
            userId,
            totalAmount,
            status: "pending",
            paymentStatus: "pending",
        });

        const orderItems = cart.items.map(item => ({
            orderId: order.orderId,   // ✅ matches model association
            productId: item.productId,
            quantity: item.quantity,
            price: item.price,
        }));

        await OrderItem.bulkCreate(orderItems);

        // ✅ Clear cart
        await CartItem.destroy({ where: { cartId: cart.cartid } });

        res.status(201).json({ message: "Order placed successfully", order });
    } catch (error) {
        console.error("Place order error:", error);
        res.status(500).json({ message: "Error creating order", error: error.message });
    }
};


// Get all orders for user
exports.getUserOrders = async (req, res) => {
    try {
        const userId = req.user.id;
        const orders = await Order.findAll({
            where: { userId },
            include: [{ model: OrderItem }]
        });
        res.json(orders);
    } catch (error) {
        res.status(500).json({ message: "Error fetching orders", error: error.message });
    }
};

// Get single order details
exports.getOrderById = async (req, res) => {
    try {
        const { orderId } = req.params;
        const order = await Order.findByPk(orderId, {
            include: [{ model: OrderItem }]
        });
        if (!order) return res.status(404).json({ message: "Order not found" });
        res.json(order);
    } catch (error) {
        res.status(500).json({ message: "Error fetching order", error: error.message });
    }
};

// Update order status (for admin / payment callback)
exports.updateOrderStatus = async (req, res) => {
    try {
        const { orderId } = req.params;
        const { status, paymentStatus } = req.body;

        const order = await Order.findByPk(orderId);
        if (!order) return res.status(404).json({ message: "Order not found" });

        if (status) order.status = status;
        if (paymentStatus) order.paymentStatus = paymentStatus;
        await order.save();

        res.json({ message: "Order updated successfully", order });
    } catch (error) {
        res.status(500).json({ message: "Error updating order", error: error.message });
    }
};
