const express = require("express");
const bodyParser = require("body-parser");
const { getUsers } = require('./queries'); // Import getUsers from queries.js

const app = express();
const port = 3000;

// Middleware to parse JSON and URL-encoded data
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Route for the root path
app.get('/', (req, res) => {
    res.send('Server is running on port 3000!');
});

// Route to get users
app.get('/users', async (req, res) => {
    try {
        const users = await getUsers(); // Call the getUsers function
        res.json(users); // Return the users as JSON
    } catch (err) {
        res.status(500).send('Error fetching users');
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Server is listening on port ${port}`);
});

// Error handling for server errors
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('Something went wrong!');
});
