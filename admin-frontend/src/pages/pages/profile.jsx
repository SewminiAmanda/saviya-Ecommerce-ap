import React, { useEffect, useState } from "react";
import {
  Avatar,
  Typography,
  Paper,
  Box,
  Divider,
  Stack,
  CircularProgress,
  Button,
} from "@mui/material";
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';
import axios from "axios";
import { useNavigate } from "react-router-dom";

const Profile = () => {
  const [admin, setAdmin] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const navigate = useNavigate();
  const [open, setOpen] = React.useState(false);

  const token = localStorage.getItem("adminToken");

  const handleClickOpen = () => setOpen(true);
  const handleClose = () => setOpen(false);

  useEffect(() => {
    const fetchAdminDetails = async () => {
      if (!token) {
        setError("Authentication token not found. Please log in.");
        setLoading(false);
        return;
      }
      try {
        const response = await axios.get(
          `http://localhost:8080/api/admin/adminuser`, // Your backend endpoint for current admin
          {
            headers: {
              Authorization: `Bearer ${token}`,
            },
          }
        );
        setAdmin(response.data);
      } catch (err) {
        setError("Failed to load admin profile.");
      } finally {
        setLoading(false);
      }
    };

    fetchAdminDetails();
  }, [token]);

  const handleEdit = () => {
    navigate("/dashboard/editAdmin", { state: { admin } });
  };

  const handleDelete = async () => {
    if (!token) {
      setError("Authentication token not found.");
      return;
    }
    try {
      await axios.delete(`http://localhost:8080/api/auth/admin/delete/me`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      // After delete, clear storage and redirect
      localStorage.removeItem("adminToken");
      navigate("/login");
    } catch (err) {
      console.error("Error deleting admin:", err);
      setError("Failed to delete admin profile.");
    } finally {
      setOpen(false);
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" mt={10}>
        <CircularProgress />
      </Box>
    );
  }

  if (error) {
    return (
      <Typography align="center" mt={10} color="error">
        {error}
      </Typography>
    );
  }

  if (!admin) {
    return (
      <Typography align="center" mt={10} color="textSecondary">
        No admin data found.
      </Typography>
    );
  }

  return (
    <Box display="flex" flexDirection="column" alignItems="center" py={5} px={4}>
      <Paper elevation={3} sx={{ padding: 4, width: '100%', maxWidth: 500 }}>
        <Box display="flex" flexDirection="column" alignItems="center">
          <Avatar
            alt={admin.user_name || "Admin Avatar"}
            src={admin.profile_picture || "https://www.gravatar.com/avatar/?d=mp"}
            sx={{ width: 100, height: 100 }}
          />
          <Typography variant="h5" mt={2} fontWeight={600}>
            {admin.user_name}
          </Typography>
        </Box>

        <Divider sx={{ my: 3 }} />

        <Stack spacing={2}>
          <Box>
            <Typography variant="subtitle2" color="textSecondary">
              Username
            </Typography>
            <Typography variant="body1">{admin.user_name}</Typography>
          </Box>
          <Box>
            <Typography variant="subtitle2" color="textSecondary">
              Email
            </Typography>
            <Typography variant="body1">{admin.email}</Typography>
          </Box>
        </Stack>
      </Paper>

      <Box mt={3} gap={2} display="flex" flexDirection="row">
        <Button variant="outlined" color="primary" onClick={handleEdit}>
          Edit Profile
        </Button>
        <Button variant="outlined" color="error" onClick={handleClickOpen}>
          Delete Profile
        </Button>

        <Dialog
          open={open}
          onClose={handleClose}
          aria-labelledby="alert-dialog-title"
          aria-describedby="alert-dialog-description"
        >
          <DialogTitle id="alert-dialog-title">
            {"Are you sure you want to delete your Admin profile?"}
          </DialogTitle>
          <DialogContent>
            <DialogContentText id="alert-dialog-description">
              This action cannot be undone. All your data will be permanently deleted.
            </DialogContentText>
          </DialogContent>
          <DialogActions>
            <Button onClick={handleClose}>Cancel</Button>
            <Button onClick={handleDelete} autoFocus color="error">
              Delete
            </Button>
          </DialogActions>
        </Dialog>
      </Box>
    </Box>
  );
};

export default Profile;
