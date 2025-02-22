const Category = require('../models/categoryModel');

const categoryController = {
    create: async (req, res) => {
        const { categoryName, description } = req.body;

        try {
            // Check if the category already exists
            const existingCategory = await Category.findByName(categoryName);
            if (existingCategory) {
                return res.status(400).json({ 
                    success: false, 
                    message: 'Category already exists with that name' 
                });
            }

            // Create the category
            const newCategory = await Category.create(categoryName, description);

            // Respond with the created category data
            res.status(201).json({
                success: true,
                message: 'Category created successfully',
                category: { 
                    categoryId: newCategory.categoryId, 
                    categoryName: newCategory.categoryName, 
                    description: newCategory.description 
                }
            });
        } catch (err) {
            res.status(500).json({ 
                success: false, 
                message: 'Error creating category', 
                error: err.message 
            });
        }
    },

    //get all categories
    getAll: async ( req,res) => {
        try {
            const category = await Category.getAll();
            res.status(200).json({ success: true, category });
        } catch (err) {
            res.status(500).json({ success: false, message: 'Error fetching categories', error: err.message });
        }
    },

    update: async (req, res) => {
        const { id } = req.params;
        const { categoryName, description } = req.body;

        try {
            const updatedCategory = await Category.update(id, categoryName, description);
            if (!updatedCategory) {
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
    // DELETE Category
    delete: async (req, res) => {
        const { id } = req.params;

        try {
            const isDeleted = await Category.delete(id);
            if (!isDeleted) {
                return res.status(404).json({ success: false, message: 'Category not found' });
            }
            res.status(200).json({ success: true, message: 'Category deleted successfully' });
        } catch (err) {
            res.status(500).json({ success: false, message: 'Error deleting category', error: err.message });
        }
    }

};

module.exports = categoryController;
