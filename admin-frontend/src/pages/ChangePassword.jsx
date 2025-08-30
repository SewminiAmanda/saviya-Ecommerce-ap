import React, { useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';

const API_URL = 'http://localhost:8080';

const ChangePasswordPage = () => {
    const location = useLocation();
    const navigate = useNavigate();
    const userId = location.state?.userId; // from login redirect

    const [newPassword, setNewPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');

    const validatePassword = (password) => {
        if (!password) return 'Password is required';
        if (password.length < 6) return 'Password must be at least 6 characters';
        return '';
    };

    const handleChangePassword = async (e) => {
        e.preventDefault();
        setError('');
        setSuccess('');

        const validationError = validatePassword(newPassword);
        if (validationError) {
            setError(validationError);
            return;
        }

        if (newPassword !== confirmPassword) {
            setError('Passwords do not match');
            return;
        }

        try {
            const token = localStorage.getItem('adminToken'); // get JWT token
            const response = await fetch(`${API_URL}/api/admin/change-password`, {
                method: 'PUT', // change to POST
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}` // add JWT auth
                },
                body: JSON.stringify({
                    newPassword,
                    user_name: '', // optional
                    profile_picture: '' // optional
                }),
            });

            if (!response.ok) {
                throw new Error('Password update failed');
            }

            setSuccess('Password updated successfully. Redirecting to profile change...');
            setTimeout(() => {
                navigate('/profile-change', { state: { userId } }); // redirect without removing token
            }, 1500);

        } catch (err) {
            console.error('Change Password Error:', err);
            setError('Failed to update password. Try again.');
        }
    };


    return (
        <div className="min-h-screen flex items-center justify-center bg-gray-100 px-4">
            <div className="max-w-md w-full bg-white p-8 rounded shadow-md">
                <h2 className="text-2xl font-bold text-center mb-6">Change Password</h2>
                <form onSubmit={handleChangePassword} className="space-y-4">
                    <div>
                        <label className="block text-sm font-medium text-gray-700">New Password</label>
                        <input
                            type="password"
                            value={newPassword}
                            onChange={(e) => setNewPassword(e.target.value)}
                            className="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-md shadow-sm focus:ring focus:ring-blue-200"
                            placeholder="Enter new password"
                            required
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700">Confirm Password</label>
                        <input
                            type="password"
                            value={confirmPassword}
                            onChange={(e) => setConfirmPassword(e.target.value)}
                            className="mt-1 block w-full px-4 py-2 border border-gray-300 rounded-md shadow-sm focus:ring focus:ring-blue-200"
                            placeholder="Confirm new password"
                            required
                        />
                    </div>
                    {error && <p className="text-red-500 text-sm">{error}</p>}
                    {success && <p className="text-green-500 text-sm">{success}</p>}
                    <button
                        type="submit"
                        className="w-full bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 rounded"
                    >
                        Update Password
                    </button>
                </form>
            </div>
        </div>
    );
};

export default ChangePasswordPage;
