const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const http = require('http');
const socketIo = require('socket.io');
const sequelize = require('./connection');
const userRoutes = require('./routes/userRoutes');
const categoryRoutes = require('./routes/categoryRoutes.js');
const productRoutes = require('./routes/productRoutes.js');
const adminRoutes = require('./routes/adminRoutes.js');
const chatRoutes = require('./routes/chatRoutes');
const cartRoutes = require('./routes/cartRoutes.js')
const activityRoutes = require("./routes/activityRoutes");
const orderRoutes = require('./routes/orderRoutes');
require('dotenv').config();

const app = express();
const server = http.createServer(app); // Create HTTP server
const socketHandler = require('./socket');

//  Connect to PostgreSQL
async function testConnection() {
    try {
        await sequelize.authenticate();
        console.log(' DB Connection established');
    } catch (error) {
        console.error(' DB Connection failed:', error);
    }
}
testConnection();

const io = socketIo(server, {
    cors: {
        origin: '*',
        methods: ['GET', 'POST']
    }
});

// Call the function to setup socket events
socketHandler(io);

//middlewares
app.use(cors());
app.use(bodyParser.json());

//  Routes
app.use('/api/users', userRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/product', productRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/cart', cartRoutes)
app.use("/api/activities", activityRoutes);
app.use("/api/orders",orderRoutes)


// Start server
const PORT = process.env.PORT || 8080;
server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running at http://0.0.0.0:${PORT}`);
});
