import React, { useEffect, useState } from "react";
import axios from "axios";

const DashboardHome = () => {
    const [stats, setStats] = useState([
        { label: "Total Users", value: 0, bg: "bg-blue-500" },
        { label: "Pending Requests", value: 0, bg: "bg-yellow-500" },
        { label: "Approved Users", value: 0, bg: "bg-green-500" },
        { label: "Rejected Users", value: 0, bg: "bg-red-500" },
    ]);

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

        fetchStats();
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

            {/* Placeholder for charts or recent activity */}
            <div className="mt-10">
                <h2 className="text-xl font-semibold mb-4">Recent Activity</h2>
                <div className="bg-white rounded-xl shadow p-4 text-gray-600">
                    <p>No recent activity yet.</p>
                </div>
            </div>
        </div>
    );
};

export default DashboardHome;
