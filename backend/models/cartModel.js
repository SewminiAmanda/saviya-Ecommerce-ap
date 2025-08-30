const { DataTypes } = require('sequelize');
const sequelize = require('../connection');

const Cart = sequelize.define('Cart', {
    cartid: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
    },
    userId: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    createdAt: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
    updatedAt: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    }
}, {
    tableName: 'cart',
    timestamps: false,
});

module.exports = Cart;
