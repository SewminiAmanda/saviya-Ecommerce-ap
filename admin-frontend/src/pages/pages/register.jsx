import React, { useState } from 'react';
import { TextField, Typography, Container, Box } from '@mui/material';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const Register = () => {
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    confirmPassword: '',
  });

  const [errors, setErrors] = useState({});
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const validateForm = () => {
    const newErrors = {};
    if (!formData.username) newErrors.username = 'Username is required';
    if (!formData.email) newErrors.email = 'Email is required';
    else if (!/\S+@\S+\.\S+/.test(formData.email)) newErrors.email = 'Invalid email format';
    if (!formData.password) newErrors.password = 'Password is required';
    if (formData.password !== formData.confirmPassword)
      newErrors.confirmPassword = 'Passwords do not match';

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;

    const payload = {
      user_name: formData.username,
      email: formData.email,
      password: formData.password,
    };

    try {
      await axios.post('http://localhost:8080/api/admin/register', payload);
      setSuccess(true);
      setError('');
      setFormData({
        username: '',
        email: '',
        password: '',
        confirmPassword: '',
      });
    } catch (err) {
      console.error('Registration failed:', err);
      setError('Failed to register. Try again.');
      setSuccess(false);
    }
  };

  return (
    <>
      <div className="w-full flex flex-col justify-center items-center pt-3">
        <h1 className="text-2xl font-bold mb-4">Saviya B2B E-Commerce Application</h1>
        <div className="bg-[#565449] h-1 w-full mb-6"></div>
      </div>

      <Container maxWidth="sm">
        <Box mt={4}>
          <Typography variant="h6" gutterBottom>
            Add New Admin
          </Typography>
          <form onSubmit={handleSubmit}>
            <TextField
              label="Username"
              name="username"
              value={formData.username}
              onChange={handleChange}
              fullWidth
              margin="normal"
              error={!!errors.username}
              helperText={errors.username}
            />
            <TextField
              label="Email"
              name="email"
              type="email"
              value={formData.email}
              onChange={handleChange}
              fullWidth
              margin="normal"
              error={!!errors.email}
              helperText={errors.email}
            />
            <TextField
              label="Password"
              name="password"
              type="password"
              value={formData.password}
              onChange={handleChange}
              fullWidth
              margin="normal"
              error={!!errors.password}
              helperText={errors.password}
            />
            <TextField
              label="Confirm Password"
              name="confirmPassword"
              type="password"
              value={formData.confirmPassword}
              onChange={handleChange}
              fullWidth
              margin="normal"
              error={!!errors.confirmPassword}
              helperText={errors.confirmPassword}
            />

            <button
              type="submit"
              className="w-full py-2 mt-5 bg-black text-white rounded hover:bg-gray-800 transition"
            >
              Add Admin
            </button>

            {error && <p className="text-red-500 mt-2">{error}</p>}
            {success && <p className="text-green-600 mt-2">Registration successful!</p>}
          </form>
        </Box>
      </Container>
    </>
  );
};

export default Register;
