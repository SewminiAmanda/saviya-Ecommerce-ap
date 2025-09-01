const express = require('express');
const router = express.Router();
const ChatController = require('../controllers/chatController');

router.post('/send', ChatController.sendMessage);
router.get('/history', ChatController.getChatHistory);
router.get('/list', ChatController.getUserChats);

module.exports = router;
