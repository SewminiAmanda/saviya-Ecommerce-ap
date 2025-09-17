const { DataTypes } = require('sequelize');
const sequelize = require('../connection');
const ChatRoom = require('./chatRoomModel');

const Message = sequelize.define('Message', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    chat_room_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: ChatRoom,
            key: 'id',
        }
    },
    sender_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    message: {
        type: DataTypes.TEXT,
        allowNull: false,
    },
    timestamp: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
}, {
    tableName: 'messages',
    timestamps: false,
});

ChatRoom.hasMany(Message, { foreignKey: 'chat_room_id' });
Message.belongsTo(ChatRoom, { foreignKey: 'chat_room_id' });


module.exports = Message;
