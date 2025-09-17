// models/Category.js
const { DataTypes } = require('sequelize');
const sequelize = require('../connection');

const Category = sequelize.define('Category', {
    categoryid: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
    },
    categoryname: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    imageurl: {
    type: DataTypes.STRING,
    allowNull: true,
  },
}, {
    tableName: 'category',
    timestamps: false, 
}



);
Category.getByName = async function (name) {
  return await Category.findOne({ where: { categoryname: name } });
};

module.exports = Category;
