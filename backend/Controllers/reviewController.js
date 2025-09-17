const Review = require("../models/reviewModel");
const Product = require("../models/productModel");
const User = require('../models/userModel');

// Add a review
exports.addReview = async (req, res) => {
    try {
        const { productId, rating, comment } = req.body;
        const userId = req.user.userid;

        // Check if product exists
        const product = await Product.findByPk(productId);
        if (!product) return res.status(404).json({ message: "Product not found" });

        // Prevent duplicate reviews (optional)
        const existing = await Review.findOne({ where: { productId, userId } });
        if (existing) {
            return res.status(400).json({ message: "You already reviewed this product" });
        }

        // Create review
        const review = await Review.create({ productId, userId, rating, comment });

        // Fetch with user info
        const fullReview = await Review.findOne({
            where: { id: review.id },
            include: [{
                model: User,
                as: 'user',
                attributes: ['userid', 'first_name', 'last_name']
            }],
            attributes: [
                'id',
                'rating',
                'comment',
                ['product_id', 'productId'],
                ['user_id', 'userId'],
                ['created_at', 'createdAt'],
                ['updated_at', 'updatedAt']
            ]
        });

        res.status(201).json(fullReview);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
};

// Get reviews for a product
exports.getProductReviews = async (req, res) => {
    try {
        const { productId } = req.params;

        const reviews = await Review.findAll({
            where: { productId },
            include: [{
                model: User,
                as: 'user',
                attributes: ['userid', 'first_name', 'last_name']
            }],
            attributes: [
                'id',
                'rating',
                'comment',
                ['product_id', 'productId'],
                ['user_id', 'userId'],
                ['created_at', 'createdAt'],
                ['updated_at', 'updatedAt']
            ],
            order: [['created_at', 'DESC']]
        });

      
        const formatted = reviews.map(r => ({
            id: r.id,
            productId: r.productId,
            userId: r.userId,
            userFirstName: r.user.first_name,
            userLastName: r.user.last_name,
            rating: r.rating,
            comment: r.comment,
            createdAt: r.createdAt,
        }));
        console.log("review",formatted);
        res.json(formatted);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
};
