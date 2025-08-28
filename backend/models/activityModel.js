const { DataTypes } = require("sequelize");
const sequelize = require("../connection");

const UserActivityLog = sequelize.define(
    "UserActivityLog",
    {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            field: "user_id",
        },
        activityType: {
            type: DataTypes.STRING,
            allowNull: false,
            field: "activity_type",
        },
        activityDescription: {
            type: DataTypes.TEXT,
            allowNull: true,
            field: "activity_description",
        },
        metadata: {
            type: DataTypes.JSONB,
            allowNull: true,
        },
        createdAt: {
            type: DataTypes.DATE,
            defaultValue: DataTypes.NOW,
            field: "created_at",
        },
    },
    {
        tableName: "user_activity_log",
        timestamps: false,
    }
);

module.exports = UserActivityLog;