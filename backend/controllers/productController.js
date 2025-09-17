const Product = require('../models/productModel');
const Category = require('../models/categoryModel');

const productController = {
  // Create product
  create: async (req, res) => {
    const { productName, categoryName, price, image, quantity, minQuantity, description, userId } = req.body;

    try {
      // Validate required fields
      if (!productName || !categoryName || !price || !quantity || !userId || !minQuantity) {
        return res.status(400).json({
          success: false,
          message: 'Missing required fields: productName, categoryName,minQuantity, price, quantity, or userId'
        });
      }
      console.log(req);
      // Check if the category exists based on categoryName
      const category = await Category.getByName(categoryName);
      if (!category) {
        return res.status(404).json({
          success: false,
          message: 'Category not found'
        });
      }

      const categoryId = category.categoryid;

      // Create product with an object
      const newProduct = await Product.create({
        productName,
        categoryId,
        price,
        image,
        quantity,
        minQuantity,
        description,
        userId
      });

      res.status(201).json({
        success: true,
        message: 'Product created successfully',
        product: newProduct
      });
    } catch (err) {
      res.status(500).json({
        success: false,
        message: 'Error creating product',
        error: err.message
      });
    }
  },

  // Get all products
  getAll: async (req, res) => {
    try {
      const products = await Product.findAll();
      res.status(200).json({ success: true, products });
    } catch (err) {
      res.status(500).json({
        success: false,
        message: 'Error fetching products',
        error: err.message
      });
    }
  },

  // Get product by ID
  getById: async (req, res) => {
    const { id } = req.params;
    try {
      const product = await Product.findByPk(id);
      if (!product) {
        return res.status(404).json({
          success: false,
          message: 'Product not found'
        });
      }
      res.status(200).json({ success: true, product });
    } catch (err) {
      res.status(500).json({
        success: false,
        message: 'Error fetching product',
        error: err.message
      });
    }
  },

  // Update product
  update: async (req, res) => {
    const { id } = req.params;
    const { productName, categoryName, price, image, quantity, description } = req.body;

    try {
      // Check if category exists
      const category = await Category.getByName(categoryName);
      if (!category) {
        return res.status(404).json({
          success: false,
          message: 'Category not found'
        });
      }

      const categoryId = category.categoryid;

      // Find and update the product
      const [updated] = await Product.update(
        {
          productName,
          categoryId,
          price,
          image,
          quantity,
          description
        },
        { where: { productId: id } }
      );

      if (updated === 0) {
        return res.status(404).json({ success: false, message: 'Product not found or no change detected' });
      }

      const updatedProduct = await Product.findByPk(id);
      res.status(200).json({
        success: true,
        message: 'Product updated successfully',
        product: updatedProduct
      });
    } catch (err) {
      res.status(500).json({
        success: false,
        message: 'Error updating product',
        error: err.message
      });
    }
  },

  // Delete product
  delete: async (req, res) => {
    const { id } = req.params;
    try {
      const deleted = await Product.destroy({ where: { productId: id } });

      if (!deleted) {
        return res.status(404).json({
          success: false,
          message: 'Product not found'
        });
      }

      res.status(200).json({
        success: true,
        message: 'Product deleted successfully',
        productId: id
      });
    } catch (err) {
      res.status(500).json({
        success: false,
        message: 'Error deleting product',
        error: err.message
      });
    }
  },
  // Get all products by category ID
  getByCategoryId: async (req, res) => {
    const { categoryid } = req.params;
    try {
      const products = await Product.findAll({ where: { categoryId: categoryid } });

      if (!products || products.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'No products found for this category'
        });
      }

      res.status(200).json({
        success: true,
        products
      });
    } catch (err) {
      res.status(500).json({
        success: false,
        message: 'Error fetching products by category',
        error: err.message
      });
    }
  },
  getByUserId: async (req, res) => {
    console.log("Backend hits /user endpoint");

    // Use the key from your token payload
    const userId = req.user.userid;
    console.log('Decoded userId from token:', userId);

    try {
      // Ensure the DB column matches 'userId'
      const products = await Product.findAll({ where: { userId } });
      console.log('Found products:', products.length);

      return res.status(200).json({ success: true, products });
    } catch (err) {
      console.error('Error fetching products:', err);
      return res.status(500).json({
        success: false,
        message: 'Error fetching user products',
        error: err.message,
      });
    }
  }
};

module.exports = productController;
