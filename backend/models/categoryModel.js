const client = require('../connection'); 

const Category = {
    create: async (categoryName, description) => {
        const query = ` 
        INSERT INTO category (categoryName, description) 
        VALUES ($1, $2) 
        RETURNING categoryId, categoryName, description`; 
    
        const values = [categoryName, description];

        try {
            const res = await client.query(query, values);
            return res.rows[0];
        } catch (err) {
            console.error("Error creating category:", err);
            throw err;
        }
    },

    findByName: async (categoryName) => {
        const query = `SELECT * FROM category WHERE categoryName = $1`;
        const values = [categoryName];

        try {
            const res = await client.query(query, values);
            return res.rows[0] || null;
        } catch (err) {
            console.error("Error finding category:", err);
            throw err;
        }
    },

     // READ: Get all categories
     getAll: async () => {
        const query = `SELECT * FROM category ORDER BY categoryId`;

        try {
            const res = await client.query(query);
            return res.rows;
        } catch (err) {
            console.error("Error fetching categories:", err);
            throw err;
        }
    },
    update: async (categoryId, categoryName, description) => {
        const query = `
        UPDATE category 
        SET categoryName = $1, description = $2
        WHERE categoryId = $3
        RETURNING categoryId, categoryName, description`;

        const values = [categoryName, description, categoryId];

        try {
            const res = await client.query(query, values);
            return res.rows[0] || null;
        } catch (err) {
            console.error("Error updating category:", err);
            throw err;
        }
    },

    delete: async (categoryId) => {
        const query = `DELETE FROM category WHERE categoryId = $1 RETURNING categoryId`;

        const values = [categoryId];

        try {
            const res = await client.query(query, values);
            
            return res.rows[0] ? true : false;
        } catch (err) {
            console.error("Error deleting category:", err);
            throw err;
        }
    },

    getByName: async (categoryName) => {
        const query = 'SELECT categoryId FROM category WHERE categoryName = $1';
        try {
          const res = await client.query(query, [categoryName]);
          categoryId = res.rows[0];
          return categoryId ; // Return the category with its category_id
         
        } catch (err) {
          throw err;
        }
      },

};

module.exports = Category;
