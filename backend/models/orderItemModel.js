const { DataTypes } = require("sequelize");
const sequelize = require("../connection");
const Order = require("./orderModel");
const Product = require("./productModel");


const OrderItem = sequelize.define(
    "OrderItem",
    {
        orderItemId: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
            field: "orderitemid",
        },
        orderId: {
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

OrderItem.belongsTo(Product, { foreignKey: "productId", as: "product" });
Product.hasMany(OrderItem, { foreignKey: "productId", as: "orderItems" });




module.exports = OrderItem;
