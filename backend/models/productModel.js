const client = require('../connection');

const Product = {
    // Create a new product
    create: async (productName, categoryId, price, image, quantity) => {
      const query = `
        INSERT INTO product (productName, categoryId, price, image, quantity) 
        VALUES ($1, $2, $3, $4, $5) 
        RETURNING productId, productName, categoryId, price, image, quantity, createdAt, updatedAt
      `;
      const values = [productName, categoryId, price, image, quantity];
      try {
        const res = await client.query(query, values);
        return res.rows[0];
      } catch (err) {
        throw err;
      }
    },
     // Get all products
  getAll: async () => {
    const query = 'SELECT * FROM product ORDER BY productId';
    try {
      const res = await client.query(query);
      return res.rows;
    } catch (err) {
      throw err;
    }
  },
    // Get a product by its ID
    getById: async (productId) => {
      const query = 'SELECT * FROM product WHERE productId = $1';
      try {
        const res = await client.query(query, [productId]);
        return res.rows[0];
      } catch (err) {
        throw err;
      }
    },

     // Update a product
  update: async (productId, productName, categoryId, price, image, quantity) => {
    const query = `
      UPDATE product
      SET productName = $1, categoryId = $2, price = $3, image = $4, quantity = $5, updatedAt = CURRENT_TIMESTAMP
      WHERE productId = $6
      RETURNING productId, productName, categoryId, price, image, quantity, updatedAt
    `;
    const values = [productName, categoryId, price, image, quantity, productId];
    try {
      const res = await client.query(query, values);
      return res.rows[0];
    } catch (err) {
      throw err;
    }
  },

   // Delete a product
   delete: async (productId) => {
    const query = 'DELETE FROM product WHERE productId = $1 RETURNING productId';
    try {
      const res = await client.query(query, [productId]);
      return res.rows[0];
    } catch (err) {
      throw err;
    }
  }

};

module.exports = Product;