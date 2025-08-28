const Category = require('../models/categoryModel');

const categoryController = {
  // Create a new category
  create: async (req, res) => {
    const { categoryname, description, imageurl } = req.body; // <-- include imageurl
    console.log("Request body:", req.body);

    try {
      const existingCategory = await Category.findOne({ where: { categoryname } });
      if (existingCategory) {
        return res.status(400).json({
          success: false,
          message: 'Category already exists with that name'
        });
      }

      const newCategory = await Category.create({ categoryname, description, imageurl }); // <-- store imageurl

      res.status(201).json({
        success: true,
        message: 'Category created successfully',
        category: newCategory
      });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Error creating category', error: err.message });
    }
  },

  // Get all categories
  getAll: async (req, res) => {
    try {
      const categories = await Category.findAll();
      res.status(200).json({ success: true, categories });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Error fetching categories', error: err.message });
    }
  },

  // Update a category
  update: async (req, res) => {
    const { id } = req.params;
    const { categoryname, description, imageurl } = req.body; // <-- include imageurl

    try {
      const [updated, [updatedCategory]] = await Category.update(
        { categoryname, description, imageurl }, // <-- update imageurl too
        { where: { categoryid: id }, returning: true }
      );

      if (!updated) {
        return res.status(404).json({ success: false, message: 'Category not found' });
      }

      res.status(200).json({
        success: true,
        message: 'Category updated successfully',
        category: updatedCategory
      });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Error updating category', error: err.message });
    }
  },

  // Delete a category
  delete: async (req, res) => {
    const { id } = req.params;

    try {
      const deleted = await Category.destroy({ where: { categoryid: id } });

      if (!deleted) {
        return res.status(404).json({ success: false, message: 'Category not found' });
      }

      res.status(200).json({ success: true, message: 'Category deleted successfully' });
    } catch (err) {
      res.status(500).json({ success: false, message: 'Error deleting category', error: err.message });
    }
  }
};

module.exports = categoryController;
