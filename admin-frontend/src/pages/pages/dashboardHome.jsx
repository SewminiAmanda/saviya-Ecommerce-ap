import React, { useEffect, useState } from "react";
import axios from "axios";

const DashboardHome = () => {
    const [stats, setStats] = useState([
        { label: "Total Users", value: 0, bg: "bg-blue-500" },
        { label: "Pending Requests", value: 0, bg: "bg-yellow-500" },
        { label: "Approved Users", value: 0, bg: "bg-green-500" },
        { label: "Rejected Users", value: 0, bg: "bg-red-500" },
    ]);

    const [activities, setActivities] = useState([]);

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const response = await axios.get("http://localhost:8080/api/users/user-stats");
                const data = response.data.stats;

                setStats([
                    { label: "Total Users", value: data.totalUsers, bg: "bg-blue-500" },
                    { label: "Pending Requests", value: data.pendingUsers, bg: "bg-yellow-500" },
                    { label: "Approved Users", value: data.verifiedUsers, bg: "bg-green-500" },
                    { label: "Rejected Users", value: data.rejectedUsers, bg: "bg-red-500" },
                ]);
            } catch (error) {
                console.error("Failed to fetch stats:", error);
            }
        };

        const fetchActivities = async () => {
            try {
                // For admin dashboard, fetch all activities
                const response = await axios.get("http://localhost:8080/api/activities/");
                setActivities(response.data);
            } catch (error) {
                console.error("Failed to fetch activities:", error);
            }
        };

        fetchStats();
        fetchActivities();
    }, []);

    return (
        <div>
            <h1 className="text-3xl font-bold mb-6">Admin Dashboard</h1>

            {/* Stat cards */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                {stats.map((stat) => (
                    <div
                        key={stat.label}
                        className={`rounded-xl p-6 shadow-md text-white ${stat.bg}`}
                    >
                        <div className="text-sm uppercase">{stat.label}</div>
                        <div className="text-2xl font-bold">{stat.value}</div>
                    </div>
                ))}
            </div>

            {/* Recent activity */}
            <div className="mt-10">
                <h2 className="text-xl font-semibold mb-4">Recent Activity</h2>
                <div className="bg-white rounded-xl shadow p-4 text-gray-600">
                    {activities.length === 0 ? (
                        <p>No recent activity yet.</p>
                    ) : (
                        <ul className="divide-y divide-gray-200">
                            {activities.map((act) => (
                                <li key={act.id} className="py-2">
                                    <div className="flex justify-between items-center">
                                        <div>
                                            <p className="font-medium">{act.activityType}</p>
                                            <p className="text-sm text-gray-500">
                                                {act.activityDescription}
                                            </p>
                                            {act.metadata && act.metadata.reason && (
                                                <p className="text-sm text-gray-400">
                                                    Reason: {act.metadata.reason}
                                                </p>
                                            )}
                                        </div>
                                        <span className="text-xs text-gray-400">
                                            {new Date(act.createdAt).toLocaleString()}
                                        </span>
                                    </div>
                                </li>
                            ))}
                        </ul>
                    )}
                </div>
            </div>
        </div>
    );
};

export default DashboardHome;