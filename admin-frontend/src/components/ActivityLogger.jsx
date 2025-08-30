import axios from "axios";

export const logActivity = async (userId, activityType, activityDescription, metadata = {}) => {
    try {
        await axios.post("http://localhost:8080/api/activities/log", {
            userId,
            activityType,
            activityDescription,
            metadata,
        }, {
            headers: {
                'Content-Type': 'application/json'
            }
        });
    } catch (err) {
        console.error("Failed to log activity:", err);
    }
};