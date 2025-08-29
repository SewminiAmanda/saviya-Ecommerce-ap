// controllers/orderController.js

const Order = require('../models/orderModel');
const Cart = require('../models/cartModel');
const CartItem = require('../models/cartItemModel');
const OrderItem = require("../models/orderItemModel");
const Product = require('../models/productModel');

// Create order from cart
exports.createOrder = async (req, res) => {
    try {
        const userId = req.user.userid; // Make sure your auth middleware sets req.user.userid
        console.log("user id in order: ", userId);

        // Fetch cart with items
        const cart = await Cart.findOne({
            where: { userId },
            include: [{ model: CartItem, as: 'items' }]
        });

        if (!cart || cart.items.length === 0) {
            return res.status(400).json({ message: "Cart is empty" });
        }

        // Calculate total
        const totalAmount = cart.items.reduce(
            (sum, item) => sum + (item.price * item.quantity),
            0
        );

        // Create order
        const order = await Order.create({
            userId,
            totalAmount,
            status: "pending",
            paymentStatus: "pending",
        });

        // Map cart items to order items
        const orderItems = cart.items.map(item => ({
            orderId: order.orderId,
            productId: item.productId,
            quantity: item.quantity,
            price: item.price,
        }));

        await OrderItem.bulkCreate(orderItems);

        // Clear cart
        await CartItem.destroy({ where: { cartId: cart.cartid } });

        // Fetch created order with OrderItems + Product
        const createdOrder = await Order.findOne({
            where: { orderId: order.orderId },
            include: [
                {
                    model: OrderItem,
                    as: 'OrderItems',
                    include: [
                        {
                            model: Product,
                            as: 'product', // must match association alias
                            attributes: ['productName'], // only get productName
                        },
                    ],
                },
            ],
        });

        const orderJson = createdOrder.toJSON();

        // Map OrderItems to Flutter-friendly items including product name
        orderJson.items = orderJson.OrderItems.map(oi => ({
            id: oi.orderItemId,
            productId: oi.productId,
            quantity: oi.quantity,
            price: oi.price,
            name: oi.product?.productName ?? `Product #${oi.productId}`,
        }));

        console.log(orderJson);
        res.status(201).json({ message: "Order placed successfully", order: orderJson });

    } catch (error) {
        console.error("Place order error:", error);
        res.status(500).json({ message: "Error creating order", error: error.message });
    }
};

// Get all orders for user with product names
exports.getUserOrders = async (req, res) => {
    try {
        const userId = req.user.userid;
        const orders = await Order.findAll({
            where: { userId },
            include: [
                {
                    model: OrderItem,
                    as: 'OrderItems',
                    include: [
                        {
                            model: Product,
                            as: 'product',
                            attributes: ['productName'],
                        },
                    ],
                },
            ],
        });

        const ordersJson = orders.map(order => {
            const obj = order.toJSON();
            obj.items = obj.OrderItems.map(oi => ({
                id: oi.orderItemId,
                productId: oi.productId,
                quantity: oi.quantity,
                price: oi.price,
                name: oi.product?.productName ?? `Product #${oi.productId}`,
            }));
            return obj;
        });

        res.json(ordersJson);
    } catch (error) {
        res.status(500).json({ message: "Error fetching orders", error: error.message });
    }
};

// Get single order details
exports.getOrderById = async (req, res) => {
    try {
        const { orderId } = req.params;
        const order = await Order.findByPk(orderId, {
            include: [
                {
                    model: OrderItem,
                    as: 'OrderItems',
                    include: [
                        {
                            model: Product,
                            as: 'product',
                            attributes: ['productName'],
                        },
                    ],
                },
            ],
        });
        if (!order) return res.status(404).json({ message: "Order not found" });

        const orderJson = order.toJSON();
        orderJson.items = orderJson.OrderItems.map(oi => ({
            id: oi.orderItemId,
            productId: oi.productId,
            quantity: oi.quantity,
            price: oi.price,
            name: oi.product?.productName ?? `Product #${oi.productId}`,
        }));

        res.json(orderJson);
    } catch (error) {
        res.status(500).json({ message: "Error fetching order", error: error.message });
    }
};

// Update order status
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
