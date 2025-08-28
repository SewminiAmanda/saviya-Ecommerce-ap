// src/services/authService.js
const API_URL = 'http://localhost:'; // Adjust to your backend

export const login = async (email, password) => {
  const response = await fetch(`${API_URL}/admin/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });
  if (!response.ok) throw new Error('Login failed');
  const data = await response.json();
  localStorage.setItem('adminToken', data.token);
  localStorage.setItem('userId', data.token.user.userId);
  return data;
};

export const logout = () => {
  localStorage.removeItem('adminToken');
};

export const isAuthenticated = () => {
  return !!localStorage.getItem('adminToken');
};
