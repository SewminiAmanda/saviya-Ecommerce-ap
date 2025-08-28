const { DataTypes } = require("sequelize");
const sequelize = require("../connection");
const Order = require("./Order");

const Payment = sequelize.define(
    "Payment",
    {
        paymentId: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
        },
        orderId: {
            type: DataTypes.INTEGER,
            references: {
                model: Order,
                key: "orderId",
            },
        },
        amount: {
            type: DataTypes.FLOAT,
            allowNull: false,
        },
        method: {
            type: DataTypes.ENUM("card", "paypal", "stripe", "cod"),
            allowNull: false,
        },
        status: {
            type: DataTypes.ENUM("pending", "success", "failed"),
            defaultValue: "pending",
        },
        transactionId: {
            type: DataTypes.STRING,
        },
    },
    {
        tableName: "payments",
        timestamps: false,
    }
);

Order.hasOne(Payment, { foreignKey: "orderId" });
Payment.belongsTo(Order, { foreignKey: "orderId" });

module.exports = Payment;
