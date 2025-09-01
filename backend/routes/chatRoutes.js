const express = require('express');
const router = express.Router();
const chatController = require('../Controllers/chatController');

router.get('/history', chatController.getChatHistory);
router.post('/message', chatController.saveMessage);

module.exports = router;
