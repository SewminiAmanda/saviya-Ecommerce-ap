const client = require('../connection');  // Import the database connection
const bcrypt = require('bcrypt');
const saltRounds = 10;

// User model object
const User = {
    // Create a new user
    create: async (firstName, lastName, email, password, address, phoneNumber, role, isActive, profilePicture) => {
        const hashedPassword = await bcrypt.hash(password, saltRounds); // Hash the password
        const query = `
            INSERT INTO users (first_name, last_name, email, password, address, phone_number, role, is_active, profile_picture)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            RETURNING userId, first_name, last_name, email, address, phone_number, role, is_active, profile_picture
        `;
        const values = [firstName, lastName, email, hashedPassword, address, phoneNumber, role, isActive, profilePicture];

        try {
            const res = await client.query(query, values);
            return res.rows[0];  // Return the inserted user
        } catch (err) {
            console.error("Error creating user:", err);
            throw err;
        }
    },

    // Find a user by email
    findByEmail: async (email) => {
        const query = `SELECT * FROM users WHERE email = $1`;
        try {
            const res = await client.query(query, [email]);
            return res.rows[0];  // Return the user data if found
        } catch (err) {
            console.error("Error finding user by email:", err);
            throw err;
        }
    },

    // Update user details (modify as needed)
    update: async (userId, firstName, lastName, address, phoneNumber) => {
        const query = `
            UPDATE users SET first_name = $1, last_name = $2, address = $3, phone_number = $4, updated_at = CURRENT_TIMESTAMP
            WHERE userId = $5
            RETURNING userId, first_name, last_name, email, address, phone_number
        `;
        const values = [firstName, lastName, address, phoneNumber, userId];

        try {
            const res = await client.query(query, values);
            return res.rows[0];  // Return the updated user
        } catch (err) {
            console.error("Error updating user:", err);
            throw err;
        }
    },

    // Delete a user by ID
    delete: async (userId) => {
        const query = `DELETE FROM users WHERE userId = $1 RETURNING userId`;
        try {
            const res = await client.query(query, [userId]);
            return res.rows[0];  // Return the deleted user ID
        } catch (err) {
            console.error("Error deleting user:", err);
            throw err;
        }
    }
};

module.exports = User;
