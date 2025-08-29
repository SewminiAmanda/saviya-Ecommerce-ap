const { DataTypes } = require("sequelize");
const sequelize = require("../connection");
const Order = require("./orderModel");

const OrderItem = sequelize.define(
    "OrderItem",
    {
        orderItemId: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
            field: "orderitemid",
        },
        orderId: {   // ✅ must match your Order association
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: Order,
                key: "orderid",
            },
            field: "orderid",
        },
        productId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            field: "productid",
        },
        quantity: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        price: {
            type: DataTypes.FLOAT,
            allowNull: false,
        },
    },
    {
        tableName: "order_items",
        timestamps: false,
    }
);

Order.hasMany(OrderItem, { foreignKey: "orderId", as: "OrderItems" });
OrderItem.belongsTo(Order, { foreignKey: "orderId", as: "order" });


module.exports = OrderItem;
