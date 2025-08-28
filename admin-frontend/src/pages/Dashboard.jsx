import React from 'react';
import { Outlet, Link, useNavigate } from 'react-router-dom';
import { Avatar, Typography } from '@mui/material';
import NavBar from './navbar';

const Dashboard = () => {
  const navigate = useNavigate();

  const user = JSON.parse(localStorage.getItem('user')) || { username: 'Admin' };

  const handleLogout = () => {
    localStorage.removeItem('adminToken');
    localStorage.removeItem('user');
    navigate('/login', { replace: true });
  };

  return (
    <div className="flex h-screen overflow-hidden">
      {/* Sidebar */}
      <aside className="w-64 bg-black text-white flex flex-col items-center shadow-lg h-full fixed left-0 top-0 bottom-0">
        <div className="flex flex-col items-center space-y-2 mt-10 mb-6">
          <Avatar
            alt={user.username}
            src={user.picture || ''}
            sx={{ width: 80, height: 80 }}
            onError={(e) => {
              e.target.onerror = null;
              e.target.src = 'https://www.gravatar.com/avatar/?d=mp';
            }}
          />
          <Typography variant="body2" className="text-white text-center">
            {user.firstName || user.username || user.email}
          </Typography>
        </div>

        <div className="mt-10 w-full space-y-2 px-4">
          <Link to="/dashboard" className="block hover:bg-gray-700 w-full p-2 rounded text-center">
            Dashboard
          </Link>
          <Link to="/dashboard/requests" className="block hover:bg-gray-700 w-full p-2 rounded text-center">
            User Requests
          </Link>
          <Link to="/dashboard/approved" className="block hover:bg-gray-700 w-full p-2 rounded text-center">
            Approved Users
          </Link>
          <Link to="/dashboard/categories" className="block hover:bg-gray-700 w-full p-2 rounded text-center">
            Categories
          </Link>
          <Link to="/dashboard/register" className="block hover:bg-gray-700 w-full p-2 rounded text-center">
            Add Admin
          </Link>
          <Link to="/dashboard/profile" className="block hover:bg-gray-700 w-full p-2 rounded text-center">
            Profile
          </Link>
          
        </div>
      </aside>

      {/* Main Content */}
      <div className="flex flex-col flex-1 ml-64 h-screen">
        <NavBar />
        <main className="flex-1 overflow-auto p-4 bg-gray-100">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default Dashboard;
