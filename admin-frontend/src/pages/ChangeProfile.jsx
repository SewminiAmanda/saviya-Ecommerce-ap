import React, { useState, useEffect } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';

const API_URL = 'http://localhost:8080';

const ProfileChangePage = () => {
    const location = useLocation();
    const navigate = useNavigate();
    const userId = location.state?.userId;

    const [userName, setUserName] = useState('');
    const [email, setEmail] = useState('');
    const [profilePicture, setProfilePicture] = useState('');
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');

    useEffect(() => {
        // Fetch current admin details
        const fetchAdmin = async () => {
            try {
                const token = localStorage.getItem('adminToken');
                const res = await fetch(`${API_URL}/api/admin/adminuser`, {
                    headers: { 'Authorization': `Bearer ${token}` }
                });

                if (!res.ok) throw new Error('Failed to fetch admin');

                const data = await res.json();
                setUserName(data.user_name || '');
                setEmail(data.email || '');
                setProfilePicture(data.profile_picture || '');
            } catch (err) {
                console.error(err);
                setError('Failed to load profile.');
            }
        };
        fetchAdmin();
    }, []);

    const handleProfileUpdate = async (e) => {
        e.preventDefault();
        setError('');
        setSuccess('');

        try {
            const token = localStorage.getItem('adminToken');
            const res = await fetch(`${API_URL}/api/admin/admin/update/${userId}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({
                    user_name: userName,
                    email,
                    profile_picture: profilePicture
                }),
            });

            if (!res.ok) throw new Error('Profile update failed');

            setSuccess('Profile updated successfully!');
            setTimeout(() => navigate('/dashboard'), 1500); // redirect to dashboard
        } catch (err) {
            console.error(err);
            setError('Failed to update profile. Try again.');
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-100 px-4">
            <div className="max-w-md w-full bg-white p-8 rounded shadow-md">
                <h2 className="text-2xl font-bold text-center mb-6">Update Profile</h2>
                <form onSubmit={handleProfileUpdate} className="space-y-4">
                    <div>
                        <label className="block text-sm font-medium text-gray-700">Username</label>
                        <input
                            type="text"
                            value={userName}
                            onChange={(e) => setUserName(e.target.value)}
                            className="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-md shadow-sm focus:ring focus:ring-blue-200"
                            placeholder="Enter username"
                            required
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700">Email</label>
                        <input
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            className="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-md shadow-sm focus:ring focus:ring-blue-200"
                            placeholder="Enter email"
                            required
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700">Profile Picture URL</label>
                        <input
                            type="text"
                            value={profilePicture}
                            onChange={(e) => setProfilePicture(e.target.value)}
                            className="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-md shadow-sm focus:ring focus:ring-blue-200"
                            placeholder="Enter image URL"
                        />
                    </div>
                    {error && <p className="text-red-500 text-sm">{error}</p>}
                    {success && <p className="text-green-500 text-sm">{success}</p>}
                    <button
                        type="submit"
                        className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded"
                    >
                        Update Profile
                    </button>
                </form>
            </div>
        </div>
    );
};

export default ProfileChangePage;
