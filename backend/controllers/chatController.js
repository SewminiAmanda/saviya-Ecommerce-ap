const Message = require('../models/messageModel');
const { Op } = require('sequelize');

exports.getChatHistory = async (req, res) => {
    const { user1, user2 } = req.query;
    if (!user1 || !user2) {
        return res.status(400).json({ error: 'user1 and user2 are required' });
    }

    try {
        const messages = await Message.findAll({
            where: {
                [Op.or]: [
                    { sender_id: user1, receiver_id: user2 },
                    { sender_id: user2, receiver_id: user1 },
                ],
            },
            order: [['timestamp', 'ASC']],
        });
        res.json({ success: true, messages });
    } catch (error) {
        console.error('Error fetching chat history:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.saveMessage = async (req, res) => {
    const { sender_id, receiver_id, message } = req.body;
    if (!sender_id || !receiver_id || !message) {
        return res.status(400).json({ error: 'sender_id, receiver_id, and message are required' });
    }

    try {
        const newMessage = await Message.create({ sender_id, receiver_id, message });
        res.json({ success: true, message: newMessage });
    } catch (error) {
        console.error('Error saving message:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
};
