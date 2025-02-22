const Product = require('../models/productModel');
const Category = require('../models/categoryModel');

const productController = {
  // Create product
  create: async (req, res) => {
    const { productName, categoryName, price, image, quantity } = req.body;

    try {
      // Check if the category exists based on categoryName
      const category = await Category.getByName(categoryName);
      if (!category) {
        return res.status(404).json({
          success: false,
          message: 'Category not found'
        });
      }

      // Get categoryId from retrieved category
      const categoryId = category.category_id;

      // Create the product with the categoryId
      const newProduct = await Product.create(productName, categoryId, price, image, quantity);

      res.status(201).json({
        success: true,
        message: 'Product created successfully',
        product: newProduct
      });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Error creating product', error: err.message });
    }
  },

  // Get all products
  getAll: async (req, res) => {
    try {
      const products = await Product.getAll();
      res.status(200).json({ success: true, products });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Error fetching products', error: err.message });
    }
  },

  // Get product by ID
  getById: async (req, res) => {
    const { id } = req.params;
    try {
      const product = await Product.getById(id);
      if (!product) {
        return res.status(404).json({ success: false, message: 'Product not found' });
      }
      res.status(200).json({ success: true, product });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Error fetching product', error: err.message });
    }
  },

  // Update product
  update: async (req, res) => {
    const { id } = req.params;
    const { productName, categoryName, price, image, quantity } = req.body;

    try {
      // Check if the category exists based on categoryName
      const category = await Category.getByName(categoryName);
      if (!category) {
        return res.status(404).json({
          success: false,
          message: 'Category not found'
        });
      }
      
      // Get categoryId from retrieved category
      const categoryId = category.categoryid;

      // Update the product with the new categoryId
      const updatedProduct = await Product.update(id, productName, categoryId, price, image, quantity);
      if (!updatedProduct) {
        return res.status(404).json({ success: false, message: 'Product not found' });
      }
      res.status(200).json({
        success: true,
        message: 'Product updated successfully',
        product: updatedProduct
      });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Error updating product', error: err.message });
    }
  },

  // Delete product
  delete: async (req, res) => {
    const { id } = req.params;
    try {
      const deletedProduct = await Product.delete(id);
      if (!deletedProduct) {
        return res.status(404).json({ success: false, message: 'Product not found' });
      }
      res.status(200).json({
        success: true,
        message: 'Product deleted successfully',
        productId: deletedProduct.product_id
      });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Error deleting product', error: err.message });
    }
  }

};

module.exports = productController;
