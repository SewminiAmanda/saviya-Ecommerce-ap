const { Cart, CartItem, Product } = require('../models/cartAssociations');
require("../middlewears/auth");

// Get user's cart
const getCart = async (req, res) => {
    try {
        const userId = req.user.userid;
        console.log("this is the fetch cart user Id: ",userId);

        let cart = await Cart.findOne({
            where: { userId },
            include: [{
                model: CartItem,
                as: 'items',
                include: [{
                    model: Product,
                    as: 'product'
                }]
            }]
        });

        if (!cart) {
            // Create a new cart if one doesn't exist
            cart = await Cart.create({ userId });
        }

        res.json(cart);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Add item to cart
const addToCart = async (req, res) => {
    try {
        const { userId, productId, quantity } = req.body;
        console.log("userId:", userId);

        // Get or create user's cart
        let cart = await Cart.findOne({ where: { userId } });
        if (!cart) {
            cart = await Cart.create({ userId });
        }

        // Check if product exists
        const product = await Product.findByPk(productId);
        console.log("productId: ", productId);
        if (!product) {
            return res.status(404).json({ error: 'Product not found' });
        }

        // Check if item already exists in cart
        let cartItem = await CartItem.findOne({
            where: { cartId: cart.cartid, productId }
        });

        if (cartItem) {
            // Update quantity if item exists
            cartItem.quantity += quantity;
            await cartItem.save();
        } else {
            // Add new item to cart
            console.log("inner loop", cart.cartid);
            cartItem = await CartItem.create({
                cartId: cart.cartid,
                productId,
                quantity,
                price: product.price
            });
        }

        // Return updated cart
        const updatedCart = await Cart.findOne({
            where: { cartid: cart.cartid },
            include: [{
                model: CartItem,
                as: 'items',
                include: [{
                    model: Product,
                    as: 'product'
                }]
            }]
        });

        res.json(updatedCart);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Update cart item quantity
const updateCartItem = async (req, res) => {
    try {
        const { itemId } = req.params;
        const { quantity } = req.body;

        const cartItem = await CartItem.findByPk(itemId);
        if (!cartItem) {
            return res.status(404).json({ error: 'Cart item not found' });
        }

        if (quantity <= 0) {
            // Remove item if quantity is 0 or less
            await cartItem.destroy();
        } else {
            // Update quantity
            cartItem.quantity = quantity;
            await cartItem.save();
        }

        // Return updated cart
        const cart = await Cart.findOne({
            where: { cartid: cartItem.cartId },
            include: [{
                model: CartItem,
                as: 'items',
                include: [{
                    model: Product,
                    as: 'product'
                }]
            }]
        });

        res.json(cart);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Remove item from cart
const removeFromCart = async (req, res) => {
    try {
        const { itemId } = req.params;

        const cartItem = await CartItem.findByPk(itemId);
        if (!cartItem) {
            return res.status(404).json({ error: 'Cart item not found' });
        }

        await cartItem.destroy();

        // Return updated cart
        const cart = await Cart.findOne({
            where: { cartid: cartItem.cartId },
            include: [{
                model: CartItem,
                as: 'items',
                include: [{
                    model: Product,
                    as: 'product'
                }]
            }]
        });

        res.json(cart);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Clear cart
const clearCart = async (req, res) => {
    try {
        const userId = req.user.id;

        const cart = await Cart.findOne({ where: { userId } });
        if (!cart) {
            return res.status(404).json({ error: 'Cart not found' });
        }

        await CartItem.destroy({ where: { cartId: cart.cartid } });

        // Return empty cart
        const emptyCart = await Cart.findOne({
            where: { cartid: cart.cartid },
            include: [{
                model: CartItem,
                as: 'items',
                include: [{
                    model: Product,
                    as: 'product'
                }]
            }]
        });

        res.json(emptyCart);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

module.exports = {
    getCart,
    addToCart,
    updateCartItem,
    removeFromCart,
    clearCart
};
