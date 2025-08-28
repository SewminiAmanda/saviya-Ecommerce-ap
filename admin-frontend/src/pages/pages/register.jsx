import React, { useState } from 'react';
import { TextField, Typography, Container, Box, Button } from '@mui/material';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const Register = () => {
  const [formData, setFormData] = useState({
    email: '',
  });
  const [errors, setErrors] = useState({});
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    // Clear error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  const validateForm = () => {
    const newErrors = {};
    if (!formData.email) newErrors.email = 'Email is required';
    else if (!/\S+@\S+\.\S+/.test(formData.email)) newErrors.email = 'Invalid email format';

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;

    try {
      const token = localStorage.getItem('adminToken');
      if (!token) {
        setError('Authentication required. Please login first.');
        return;
      }

      // Call backend to create admin and send invite email
      const response = await axios.post(
        'http://localhost:8080/api/admin/invite', 
        {
          email: formData.email,
        },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      if (response.data.success) {
        setSuccess(true);
        setError('');
        setFormData({ email: '' });
        alert(`Admin added successfully! An invite email has been sent to ${formData.email}.`);
      } else {
        setError(response.data.message || 'Failed to add admin.');
      }
    } catch (err) {
      console.error('Failed to add admin:', err);
      setError(err.response?.data?.message || 'Failed to add admin. Try again.');
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
              label="Email"
              name="email"
              type="email"
              value={formData.email}
              onChange={handleChange}
              fullWidth
              margin="normal"
              error={!!errors.email}
              helperText={errors.email}
              required
            />

            <Button
              type="submit"
              variant="contained"
              color="primary"
              fullWidth
              className="mt-5"
            >
              Add Admin
            </Button>

            {error && <p className="text-red-500 mt-2">{error}</p>}
            {success && (
              <p className="text-green-600 mt-2">
                Admin added successfully! Invite email sent.
              </p>
            )}
          </form>
        </Box>
      </Container>
    </>
  );
};

export default Register;