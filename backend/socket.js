const Message = require("./models/messageModel");
const ChatRoom = require("./models/chatRoomModel");

module.exports = (io) => {
    io.on("connection", (socket) => {
        console.log(`✅ User connected: ${socket.id}`);

        // Join chat room (based on user pair)
        socket.on("joinRoom", async ({ userId1, userId2 }) => {
            const roomName = [userId1, userId2].sort().join("-");

            const [first, second] = userId1 < userId2 ? [userId1, userId2] : [userId2, userId1];
            let room = await ChatRoom.findOne({ where: { user1_id: first, user2_id: second } });
            if (!room) {
                room = await ChatRoom.create({ user1_id: first, user2_id: second });
            }

            socket.join(roomName);
            console.log(`📌 Socket ${socket.id} joined room ${roomName}`);
        });

        // Send a message
        socket.on("sendMessage", async ({ senderId, receiverId, message }) => {
            const roomName = [senderId, receiverId].sort().join("-");

            try {
                const [first, second] = senderId < receiverId ? [senderId, receiverId] : [receiverId, senderId];
                let room = await ChatRoom.findOne({ where: { user1_id: first, user2_id: second } });
                if (!room) {
                    room = await ChatRoom.create({ user1_id: first, user2_id: second });
                }

                const savedMessage = await Message.create({
                    chat_room_id: room.id,
                    sender_id: senderId,
                    message,
                });

                // Use createdAt instead of timestamp
                io.to(roomName).emit("receiveMessage", {
                    id: savedMessage.id,
                    senderId,
                    message,
                    timestamp: savedMessage.createdAt,
                });
            } catch (err) {
                console.error("❌ Error saving message:", err);
            }
        });

        // Typing indicator
        socket.on("typing", ({ senderId, receiverId }) => {
            const roomName = [senderId, receiverId].sort().join("-");
            socket.to(roomName).emit("userTyping", { senderId });
        });

        socket.on("disconnect", () => console.log(`❌ User disconnected: ${socket.id}`));
    });
};
