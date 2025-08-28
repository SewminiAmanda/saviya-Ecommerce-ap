const UserActivityLog = require("../models/activityModel");

// Log new activity
exports.logActivity = async (req, res) => {
    try {
        const { userId, activityType, activityDescription, metadata } = req.body;

        const activity = await UserActivityLog.create({
            userId,
            activityType,
            activityDescription,
            metadata,
        });

        res.status(201).json(activity);
    } catch (err) {
        console.error("Error logging activity:", err);
        res.status(500).json({ error: "Failed to log activity" });
    }
};

// Get all activities (for admin dashboard)
exports.getAllActivities = async (req, res) => {
    try {
        const limit = parseInt(req.query.limit) || 10;
        const activities = await UserActivityLog.findAll({
            order: [["createdAt", "DESC"]],
            limit,
        });
        res.json(activities);
    } catch (err) {
        console.error("Error fetching activities:", err);
        res.status(500).json({ error: "Failed to fetch activities" });
    }
};

// Get recent activities for a specific user
exports.getUserActivities = async (req, res) => {
    try {
        const { userId } = req.params;
        const limit = parseInt(req.query.limit) || 10;

        const activities = await UserActivityLog.findAll({
            where: { userId },
            order: [["createdAt", "DESC"]],
            limit,
        });

        res.json(activities);
    } catch (err) {
        console.error("Error fetching user activities:", err);
        res.status(500).json({ error: "Failed to fetch user activities" });
    }
};