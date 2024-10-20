const { Pool } = require("pg");
require('dotenv').config();

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_DATABASE,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT
});

// Function to get users
const getUsers = async () => {
    const client = await pool.connect(); // Get a connection from the pool
    try {
        const res = await client.query('SELECT * FROM users'); // Example query
        return res.rows; // Return the results
    } catch (err) {
        console.error('Database query error', err.stack);
        throw err; // Rethrow error for handling in the route
    } finally {
        client.release(); // Release the connection back to the pool
    }
};



// Export the getUsers function
module.exports = { getUsers };
