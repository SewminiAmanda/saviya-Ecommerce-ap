const { Op } = require("sequelize");
const ChatRoom = require("../models/chatRoomModel");
const Message = require("../models/messageModel");

// Helper: find or create private chat room
async function getOrCreatePrivateRoom(user1Id, user2Id) {
    const [first, second] = user1Id < user2Id ? [user1Id, user2Id] : [user2Id, user1Id];

    let room = await ChatRoom.findOne({ where: { user1_id: first, user2_id: second } });
    if (!room) {
        room = await ChatRoom.create({ user1_id: first, user2_id: second });
    }
    return room;
}

// Get chat history
async function getChatHistory(req, res) {
    const { user1, user2 } = req.query;
    if (!user1 || !user2) return res.status(400).json({ error: "user1 and user2 are required" });

    try {
        const room = await getOrCreatePrivateRoom(parseInt(user1), parseInt(user2));
        const messages = await Message.findAll({
            where: { chat_room_id: room.id },
            order: [["timestamp", "ASC"]],
        });

        const formatted = messages.map((msg) => ({
            id: msg.id,
            senderId: msg.sender_id,
            receiverId: msg.sender_id === parseInt(user1) ? parseInt(user2) : parseInt(user1),
            message: msg.message,
            timestamp: msg.timestamp,
        }));

        res.json({ success: true, messages: formatted });
    } catch (err) {
        console.error("❌ getChatHistory failed:", err);
        res.status(500).json({ error: "Internal server error" });
    }
}

// Send message via REST API
async function sendMessage(req, res) {
    const { sender_id, receiver_id, message } = req.body;
    if (!sender_id || !receiver_id || !message)
        return res.status(400).json({ error: "sender_id, receiver_id, and message are required" });

    try {
        const room = await getOrCreatePrivateRoom(parseInt(sender_id), parseInt(receiver_id));
        const newMessage = await Message.create({
            chat_room_id: room.id,
            sender_id,
            message,
        });

        res.json({
            success: true,
            message: {
                id: newMessage.id,
                senderId: newMessage.sender_id,
                message: newMessage.message,
                timestamp: newMessage.createdAt,
            },
        });
    } catch (err) {
        console.error("❌ sendMessage failed:", err);
        res.status(500).json({ error: "Internal server error" });
    }
}

// Get user chat list
async function getUserChats(req, res) {
    const { userId } = req.query;
    if (!userId) return res.status(400).json({ error: "userId is required" });

    try {
        const rooms = await ChatRoom.findAll({
            where: { [Op.or]: [{ user1_id: userId }, { user2_id: userId }] },
            order: [["createdAt", "DESC"]],
        });

        const chatList = await Promise.all(
            rooms.map(async (room) => {
                const lastMessage = await Message.findOne({
                    where: { chat_room_id: room.id },
                    order: [["timestamp", "DESC"]],
                });

                const otherUserId = room.user1_id == userId ? room.user2_id : room.user1_id;
                return {
                    chatRoomId: room.id,
                    otherUserId,
                    lastMessage: lastMessage ? lastMessage.message : null,
                    lastMessageTimestamp: lastMessage ? lastMessage.createdAt : null,
                };
            })
        );

        res.json({ success: true, chats: chatList });
    } catch (err) {
        console.error("❌ getUserChats failed:", err);
        res.status(500).json({ error: "Internal server error" });
    }
}

module.exports = { getChatHistory, sendMessage, getUserChats };
