// sequelize.js
const { Sequelize } = require('sequelize');

const sequelize = new Sequelize('saviya', 'postgres', 'root123', {
    host: 'localhost',
    dialect: 'postgres',
    port: 5432,
    logging: console.log, 
});

module.exports = sequelize;
