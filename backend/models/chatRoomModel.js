// models/chatRoomModel.js
const { DataTypes } = require('sequelize');
const sequelize = require('../connection');

const ChatRoom = sequelize.define('ChatRoom', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    user1_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    user2_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
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
    }
}, {
    tableName: 'chat_rooms',
    timestamps: true  // map to actual DB column
});

module.exports = ChatRoom;
