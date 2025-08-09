import React, { useState } from "react";
import {
  TextField,
  Paper,
  Typography,
  Box,
  Stack,
  Alert,
} from "@mui/material";
import { useLocation, useNavigate } from "react-router-dom";
import axios from "axios";

const EditAdmin = () => {
  const location = useLocation();
  const navigate = useNavigate();

  const initialData = location.state?.admin;

  const [formData, setFormData] = useState({
    user_name: initialData?.user_name || "",
    email: initialData?.email || "",
  });

  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const handleChange = (e) => {
    setFormData((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const adminId = localStorage.getItem("adminId");
    if (!adminId) {
      setError("Admin ID not found. Please login again.");
      return;
    }

    try {
      await axios.put(
        `http://localhost:8081/api/auth/admin/update/${adminId}`,
        formData
      );

      setSuccess("Profile updated successfully.");
      setTimeout(() => navigate("/dashboard/profile"), 1500);
    } catch (err) {
      setError("Failed to update profile.");
    }
  };

  return (
    <Box display="flex" justifyContent="center" mt={5}>
      <Paper elevation={3} sx={{ p: 4, width: "100%", maxWidth: 500 }}>
        <Typography variant="h5" mb={3}>
          Edit Profile
        </Typography>
        <form onSubmit={handleSubmit}>
          <Stack spacing={2}>
            <TextField
              label="Username"
              name="username"
              value={formData.user_name}
              onChange={handleChange}
              required
            />
            <TextField
              label="Email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              required
            />
            <button
              type="submit"
              className="w-full py-2 bg-black text-white rounded hover:bg-gray-800 transition"
            >
              Save Changes
            </button>
            {error && <Alert severity="error">{error}</Alert>}
            {success && <Alert severity="success">{success}</Alert>}
          </Stack>
        </form>
      </Paper>
    </Box>
  );
};

export default EditAdmin;
