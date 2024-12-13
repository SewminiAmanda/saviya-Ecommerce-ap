const express = require("express");
const { signup } = require("../Controllers/userController");
const router = express.Router();

router.post("/signup", signup);

module.exports = router;
