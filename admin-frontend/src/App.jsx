// src/App.jsx
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import LoginPage from './pages/Login';
import Dashboard from './pages/Dashboard';
import PrivateRoute from './components/protectedRoute';

import Requests from "./pages/pages/requests.jsx";
import Approved from "./pages/pages/approved.jsx";
import Categories from "./pages/pages/categories.jsx";
import Register from "./pages/pages/register.jsx";
import Profile from "./pages/pages/profile.jsx";
import DashboardHome from "./pages/pages/dashboardHome.jsx";
import EditAdmin from "./pages/pages/editAdmin.jsx";

const App = () => {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="/login" element={<LoginPage />} />

        {/* Protect all /dashboard routes */}
        <Route
          path="/dashboard/*"
          element={
            <PrivateRoute>
              <Dashboard />
            </PrivateRoute>
          }
        >
          {/* Nested routes rendered inside Dashboard's <Outlet> */}
          <Route index element={<DashboardHome />} />
          <Route path="requests" element={<Requests />} />
          <Route path="approved" element={<Approved />} />
          <Route path="categories" element={<Categories />} />
          <Route path="register" element={<Register />} />
          <Route path="profile" element={<Profile />} />
          <Route path="editAdmin" element={<EditAdmin />} />
        </Route>
      </Routes>
    </Router>
  );
};

export default App;
