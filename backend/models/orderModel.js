const { DataTypes } = require("sequelize");
const sequelize = require("../connection");
const User = require("./userModel");

const Order = sequelize.define(
    "Order",
    {
        orderId: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
            field: "orderid"
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            field: "userid"
        },
        status: {
            type: DataTypes.ENUM("pending", "paid", "shipped", "delivered", "cancelled"),
            defaultValue: "pending",
        },
        totalAmount: {
            type: DataTypes.FLOAT,
            allowNull: false,
            field: "totalamount"
        },
        paymentStatus: {
            type: DataTypes.ENUM("pending", "paid", "failed"),
            defaultValue: "pending",
            field:"paymentstatus"
        },
        sellerId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: { model: 'users', key: 'id' },
        },
        createdAt: {
            type: DataTypes.DATE,
            defaultValue: DataTypes.NOW,
            field: "created_at"
        },
        updatedAt: {
            type: DataTypes.DATE,
            defaultValue: DataTypes.NOW,
            field: "updated_at"
        },
    },
    {
        tableName: "orders",
        timestamps: false,
    }
);
Order.belongsTo(User, { as: 'buyer', foreignKey: 'userId' });
Order.belongsTo(User, { as: 'seller', foreignKey: 'sellerId' });

module.exports = Order;