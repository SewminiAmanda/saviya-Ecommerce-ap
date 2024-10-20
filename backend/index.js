const express = require("express");
const bodyParser = require("body-parser");

const app = express();
const port = 3000;

// Middleware to parse JSON and URL-encoded data
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Route for the root path
app.get('/', (req, res) => {
    res.send('Server is running on port 3000!');
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
