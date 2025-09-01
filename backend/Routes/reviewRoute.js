// routes/reviewRoutes.js
const express = require("express");
const router = express.Router();
const reviewController = require("../Controllers/reviewController");
const authMiddleware = require('../middlewears/auth'); 

// Add review
router.post("/", authMiddleware, reviewController.addReview);

// Get reviews for a product
router.get("/:productId", reviewController.getProductReviews);

module.exports = router;