const Cart = require('../models/cartModel');
const Product = require('../models/productModel'); // Ensure this exists for stock checking

const CartController = {
    // ADD TO CART
    addToCart: async (req, res) => {
        try {
            const { productid, quantity } = req.body;
            const userid = req.user.id; // From JWT middleware

            // Check product exists
            const product = await Product.findByPk(productid);
            if (!product) {
                return res.status(404).json({ message: 'Product not found' });
            }

            // Check stock
            if (quantity > product.stock) {
                return res.status(400).json({ message: 'Not enough stock available' });
            }

            // Check if item already in cart
            const existingItem = await Cart.findOne({ where: { userid, productid } });
            if (existingItem) {
                existingItem.quantity += quantity;
                await existingItem.save();
            } else {
                await Cart.create({ userid, productid, quantity });
            }

            res.status(201).json({ message: 'Item added to cart successfully' });
        } catch (error) {
            console.error('Add to cart error:', error);
            res.status(500).json({ message: 'Server error while adding to cart' });
        }
    },

    // GET CART ITEMS
    getCart: async (req, res) => {
        try {
            const userid = req.user.id;

            const cartItems = await Cart.findAll({
                where: { userid },
                include: [{ model: Product }]
            });

            res.status(200).json(cartItems);
        } catch (error) {
            console.error('Get cart error:', error);
            res.status(500).json({ message: 'Server error while fetching cart' });
        }
    },

    // UPDATE CART ITEM
    updateCartItem: async (req, res) => {
        try {
            const { quantity } = req.body;
            const cartid = req.params.id;
            const userid = req.user.id;

            const cartItem = await Cart.findOne({ where: { cartid, userid } });
            if (!cartItem) {
                return res.status(404).json({ message: 'Cart item not found' });
            }

            // Check stock
            const product = await Product.findByPk(cartItem.productid);
            if (quantity > product.stock) {
                return res.status(400).json({ message: 'Not enough stock available' });
            }

            cartItem.quantity = quantity;
            await cartItem.save();

            res.status(200).json({ message: 'Cart item updated successfully' });
        } catch (error) {
            console.error('Update cart error:', error);
            res.status(500).json({ message: 'Server error while updating cart' });
        }
    },

    // REMOVE CART ITEM
    removeFromCart: async (req, res) => {
        try {
            const cartid = req.params.id;
            const userid = req.user.id;

            const cartItem = await Cart.findOne({ where: { cartid, userid } });
            if (!cartItem) {
                return res.status(404).json({ message: 'Cart item not found' });
            }

            await cartItem.destroy();
            res.status(200).json({ message: 'Item removed from cart successfully' });
        } catch (error) {
            console.error('Remove cart error:', error);
            res.status(500).json({ message: 'Server error while removing cart item' });
        }
    }
};

module.exports = CartController;
