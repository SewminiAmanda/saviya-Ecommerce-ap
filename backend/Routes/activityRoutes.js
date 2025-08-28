const express = require("express");
const router = express.Router();
const activityController = require("../controllers/activityController");

// Log activity
router.post("/log", activityController.logActivity);

// Get all activities (for admin dashboard)
router.get("/", activityController.getAllActivities);

// Get activities for a specific user
router.get("/:userId", activityController.getUserActivities);

module.exports = router;