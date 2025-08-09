import React, { useState, useEffect } from 'react';
import axios from 'axios';
import {
  Button,
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
  Select, MenuItem,
  Dialog, DialogTitle, DialogContent, DialogActions
} from "@mui/material";
import Pagination from '@mui/material/Pagination';
import PaginationItem from '@mui/material/PaginationItem';

const Requests = () => {
  const [users, setUsers] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;
  const [dialogOpen, setDialogOpen] = useState(false);
  const [rejectionReason, setRejectionReason] = useState('');
  const [selectedUserIndex, setSelectedUserIndex] = useState(null);

  useEffect(() => {
    const fetchUnverifiedUsers = async () => {
      try {
        const { data } = await axios.get("http://localhost:8080/api/users/unverified");
        if (Array.isArray(data.users)) {
          setUsers(data.users);
        } else {
          setUsers(data);
        }
      } catch (error) {
        console.error("Error fetching unverified users:", error);
        setUsers([]);
      }
    };

    fetchUnverifiedUsers();
  }, []);

  const handleStatusChange = async (event, index) => {
    const newStatus = event.target.value;
    const updatedUsers = [...users];
    const user = updatedUsers[index];

    if (newStatus === "Verified") {
      try {
        await axios.put(
          `http://localhost:8080/api/users/verify/${user.userid}`,
          {},
          {
            headers: {
              Authorization: `Bearer ${localStorage.getItem("adminToken")}`,
            },
          }
        );
        updatedUsers.splice(index, 1);
        setUsers(updatedUsers);
        alert(`${user.first_name} ${user.last_name} has been verified.`);
      } catch (error) {
        console.error("Verification failed:", error);
        alert("Failed to verify user.");
      }
    } else if (newStatus === "Rejected") {
      setSelectedUserIndex(index);
      setDialogOpen(true);
    }
  };

  const handleRejectSubmit = async () => {
    if (selectedUserIndex === null) return;

    const updatedUsers = [...users];
    const user = updatedUsers[selectedUserIndex];

    try {
      // 1. Mark user as rejected in DB
      await axios.put(`http://localhost:8080/api/users/reject/${user.userid}`, {
        reason: rejectionReason
      });

      // 2. Send rejection email
      await axios.post(`http://localhost:8080/api/users/emails/reject`, {
        email: user.email,
        fullName: `${user.user_name}`,
        reason: rejectionReason,
        id: user.userid
      });

      // 3. Remove user from current list
      updatedUsers.splice(selectedUserIndex, 1);
      setUsers(updatedUsers);

      // 4. Reset dialog state
      setDialogOpen(false);
      setRejectionReason('');
      setSelectedUserIndex(null);

      alert(`${user.first_name} ${user.last_name} has been rejected and notified.`);
    } catch (error) {
      console.error("Rejection failed:", error);
      alert("Failed to reject user.");
    }
  };

  const paginatedUsers = users.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  return (
    <div className="flex justify-center items-center">
      <div className="w-full flex flex-col justify-center items-center pt-3">
        <h1 className="text-2xl font-bold mb-4">Saviya B2B E-Commerce Application</h1>
        <div className="bg-[#565449] h-1 w-full mb-6"></div>
        <p className="text-lg text-gray-500 mb-6">User Verification Requests</p>

        <TableContainer className="w-full px-4 mb-6">
          <Table>
            <TableHead>
              <TableRow>
                <TableCell className="bg-gray-400">Name</TableCell>
                <TableCell className="bg-gray-400">Email</TableCell>
                <TableCell className="bg-gray-400">Contact Number</TableCell>
                <TableCell className="bg-gray-400">Verification Document</TableCell>
                <TableCell className="bg-gray-400">Status</TableCell>
              </TableRow>
            </TableHead>

            <TableBody>
              {paginatedUsers.map((user, index) => (
                <TableRow key={user.userid}>
                  <TableCell>{user.first_name} {user.last_name}</TableCell>
                  <TableCell>{user.email}</TableCell>
                  <TableCell>{user.phone_number || "N/A"}</TableCell>
                  <TableCell>
                    {user.verificationDocuments ? (
                      <a href={user.verificationDocuments} target="_blank" rel="noopener noreferrer" className="text-blue-600 underline">
                        View PDF
                      </a>
                    ) : "Pending"}
                  </TableCell>
                  <TableCell>
                    <Select
                      value={user.status || "To Do"}
                      onChange={(e) => handleStatusChange(e, index)}
                      displayEmpty
                      fullWidth
                    >
                      <MenuItem value="To Do">To Do</MenuItem>
                      <MenuItem value="Verified">Verified</MenuItem>
                      <MenuItem value="Rejected">Rejected</MenuItem>
                    </Select>
                  </TableCell>
                </TableRow>
              ))}
              {paginatedUsers.length === 0 && (
                <TableRow>
                  <TableCell colSpan={5} className="text-center text-gray-500">No unverified users found.</TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </TableContainer>

        <Pagination
          count={Math.ceil(users.length / itemsPerPage)}
          page={currentPage}
          onChange={(e, value) => setCurrentPage(value)}
          renderItem={(item) => (
            <PaginationItem {...item} className="bg-gray-800 text-white hover:bg-gray-600" />
          )}
          className="mb-6"
        />
      </div>

      {/* Rejection Dialog */}
      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} fullWidth>
        <DialogTitle>Rejection Reason</DialogTitle>
        <DialogContent>
          <textarea
            value={rejectionReason}
            onChange={(e) => setRejectionReason(e.target.value)}
            placeholder="Enter reason for rejection"
            className="w-full h-24 p-2 border border-gray-300 rounded mt-2"
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialogOpen(false)}>Cancel</Button>
          <Button
            onClick={handleRejectSubmit}
            variant="contained"
            color="error"
            disabled={!rejectionReason.trim()}
          >
            Submit
          </Button>
        </DialogActions>
      </Dialog>
    </div>
  );
};

export default Requests;
