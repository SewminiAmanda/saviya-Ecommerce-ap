const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const client = require('./connection.js');
const userRoutes = require('./routes/userRoutes');
const categoryRoutes = require('./routes/categoryRoutes.js');
const productRoutes = require('./routes/productRoutes.js');

const app = express(); 

app.use(cors()); 



client.connect()
    .then(() => {
        console.log("Connected to the database successfully!");
    })
    .catch((err) => {
        console.error("Database connection error:", err.stack);
    });

    
app.use(bodyParser.json()); 
app.use('/api/users', userRoutes);
app.use('/api/category', categoryRoutes);
app.use('/api/product', productRoutes);

const PORT = 8080;
app.listen(PORT, () => {
    console.log(`Server is now listening on port ${PORT}`);
});
