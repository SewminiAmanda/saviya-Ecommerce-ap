const { Sequelize, DataTypes } = require('sequelize');

// Create the Sequelize instance with database credentials
const sequelize = new Sequelize({
  username: "postgres",
  password: "Sewmini/01831",  // Ensure this is correct for your environment
  database: "saviya",
  host: "localhost",
  port: 5432,
  dialect: "postgres",
});

// Initialize db object to store models
const db = {};
db.Sequelize = Sequelize;
db.sequelize = sequelize;

// Import the User model
db.users = require('./userModel')(sequelize, DataTypes);

// Test database connection
sequelize.authenticate()
  .then(() => {
    console.log('Database connected to saviya');
  })
  .catch((err) => {
    console.log('Database connection error:', err);
  });



// Export the db object for use in other files
module.exports = db;
