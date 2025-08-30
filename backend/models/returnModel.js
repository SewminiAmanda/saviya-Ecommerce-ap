const { DataTypes } = require("sequelize");
const sequelize = require("../connection");
const Order = require("./Order");

const Return = sequelize.define(
    "Return",
    {
        returnId: {
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
        reason: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        status: {
            type: DataTypes.ENUM("requested", "approved", "rejected", "refunded"),
            defaultValue: "requested",
        },
    },
    {
        tableName: "returns",
        timestamps: false,
    }
);

Order.hasMany(Return, { foreignKey: "orderId" });
Return.belongsTo(Order, { foreignKey: "orderId" });

module.exports = Return;
