import React from 'react';
import { useNavigate } from 'react-router-dom';

const NavBar = () => {
  const navigate = useNavigate();

  // Get user info from localStorage or default
  const user = JSON.parse(localStorage.getItem('user')) || { username: 'Admin' };

  const handleLogout = () => {
    localStorage.removeItem('adminToken');
    localStorage.removeItem('user');
    navigate('/login', { replace: true });
  };

  return (
    <nav className="bg-gray-800 text-white px-6 py-3 flex justify-between items-center shadow">
      <div className="text-lg font-semibold">
        Welcome, {user.username || user.firstName || 'Admin'}
      </div>
      <button
        onClick={handleLogout}
        className="bg-red-600 hover:bg-red-700 px-3 py-1 rounded"
      >
        Logout
      </button>
    </nav>
  );
};

export default NavBar;
