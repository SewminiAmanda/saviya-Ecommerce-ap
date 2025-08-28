const { DataTypes } = require('sequelize');
const sequelize = require('../connection');

const Cart = sequelize.define('Cart', {
    cartid: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
    },
    userid: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    productid: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    quantity: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 1,
    },
    created_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
    updated_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    }
}, {
    tableName: 'cart',
    timestamps: false,
});

// Optional: Helper method to get all cart items for a user
Cart.getUserCart = async function (userid) {
    return await this.findAll({ where: { userid } });
};

module.exports = Cart;