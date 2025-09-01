
const sequelize = require("../connection");
const Order = require('../models/orderModel');
const Cart = require('../models/cartModel');
const CartItem = require('../models/cartItemModel');
const OrderItem = require("../models/orderItemModel");
const Product = require('../models/productModel');
const User = require("../models/userModel");

// Create order from cart
exports.createOrder = async (req, res) => {
    try {
        const userId = req.user.userid;
        console.log("user id in order: ", userId);

        // Fetch cart with items and their products
        const cart = await Cart.findOne({
            where: { userId },
            include: [
                {
                    model: CartItem,
                    as: 'items',
                    include: [
                        {
                            model: Product,
                            as: 'product',
                            attributes: ['productId', 'userId', 'productName', 'price'],
                        }
                    ]
                }
            ]
        });

        if (!cart || cart.items.length === 0) {
            return res.status(400).json({ message: "Cart is empty" });
        }

        // Ensure all products have the same seller
        const sellerIds = new Set(cart.items.map(item => item.product.userId));
        if (sellerIds.size > 1) {
            return res.status(400).json({ message: "All products must belong to the same seller" });
        }
        const sellerId = cart.items[0].product.userId;

        // Calculate total
        const totalAmount = cart.items.reduce(
            (sum, item) => sum + (item.price * item.quantity),
            0
        );

        // Create order
        const order = await Order.create({
            userId,
            totalAmount,
            sellerId,
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

        // Fetch created order with OrderItems + Product + buyer/seller
        const createdOrder = await Order.findOne({
            where: { orderId: order.orderId },
            include: [
                {
                    model: User,
                    as: 'buyer',
                    attributes: ['userid','first_name', 'last_name', 'address', 'email'], // fixed column names
                },
                {
                    model: User,
                    as: 'seller',
                    attributes: ['userid', 'first_name', 'last_name', 'address', 'email'], // fixed column names
                },
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

        const orderJson = createdOrder.toJSON();
        orderJson.items = orderJson.OrderItems.map(oi => ({
            id: oi.orderItemId,
            productId: oi.productId,
            quantity: oi.quantity,
            price: oi.price,
            name: oi.product?.productName ?? `Product #${oi.productId}`,
        }));

        console.log("created order", orderJson);

        res.status(201).json({ message: "Order placed successfully", order: orderJson });

    } catch (error) {
        console.error("Place order error:", error);
        res.status(500).json({ message: "Error creating order", error: error.message });
    }
};

// Orders where the logged-in user is the buyer
exports.getUserOrders = async (req, res) => {
    try {
        const userId = req.user.userid;
        const orders = await Order.findAll({
            where: { userId }, // buyer
            include: [
                {
                    model: User,
                    as: 'buyer',
                    attributes: ['userid', 'first_name', 'last_name', 'address', 'email'],
                },
                {
                    model: User,
                    as: 'seller',
                    attributes: ['userid', 'first_name', 'last_name', 'address', 'email'],
                },
                {
                    model: OrderItem,
                    as: 'OrderItems',
                    include: [{ model: Product, as: 'product', attributes: ['productName'] }],
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
        res.status(500).json({ message: "Error fetching buyer orders", error: error.message });
    }
};

// Orders where the logged-in user is the seller (received orders)
exports.getSellerOrders = async (req, res) => {
    try {
        const sellerId = req.user.userid;

        const orders = await Order.findAll({
            where: { sellerId },
            include: [
                {
                    model: User,
                    as: 'buyer',
                    attributes: ['userid', 'first_name', 'last_name', 'address', 'email'],
                },
                {
                    model: User,
                    as: 'seller',
                    attributes: ['userid', 'first_name', 'last_name', 'address', 'email'],
                },
                {
                    model: OrderItem,
                    as: 'OrderItems',
                    include: [
                        { model: Product, as: 'product', attributes: ['productName'] }
                    ],
                },
            ],
        });

        // Map to same structure as buyer orders
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
        console.error("Error fetching seller orders", error);
        res.status(500).json({ message: "Error fetching seller orders", error: error.message });
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

exports.updateOrderStatus = async (req, res) => {
    try {
        const { orderId } = req.params;
        const { status, paymentStatus } = req.body;

        console.log("Received update request:", { orderId, status, paymentStatus });

        const order = await Order.findByPk(orderId);
        if (!order) {
            console.log("Order not found:", orderId);
            return res.status(404).json({ message: "Order not found" });
        }

        if (status) {
            console.log(`Updating status from ${order.status} to ${status}`);
            order.status = status;
        }
        if (paymentStatus) {
            console.log(`Updating paymentStatus from ${order.paymentStatus} to ${paymentStatus}`);
            order.paymentStatus = paymentStatus;
        }

        await order.save();
        console.log("Order updated successfully:", order.toJSON());

        res.json({ message: "Order updated successfully", order });
    } catch (error) {
        console.error("Error updating order:", error);
        res.status(500).json({ message: "Error updating order", error: error.message });
    }
};