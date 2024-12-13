const { Sequelize, DataTypes } = require('sequelize');
const sequelize = new Sequelize({
  username: "postgres",
  password: "Sewmini/01831",
  database: "saviya",
  host: "localhost",
  port: 5432,
  dialect: "postgres",
});

// Testing the connection
sequelize.authenticate().then(() => {
  console.log(`Database connected to saviya`);
}).catch((err) => {
  console.log(err);
});

// Sync the models but don't drop the tables (don't use force: true)
sequelize.sync({ alter: true }).then(() => {
  console.log("Models synchronized with the database.");
}).catch((err) => {
  console.log("Error syncing models:", err);
});

const db = {};
db.Sequelize = Sequelize;
db.sequelize = sequelize;

db.users = require('./userModel')(sequelize, DataTypes);

// Export the db object
module.exports = db;
