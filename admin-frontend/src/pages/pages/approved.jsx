import React, { useState, useEffect } from "react";
import axios from "axios";
import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Pagination,
  PaginationItem,
} from "@mui/material";

const Approved = () => {
  const [providerData, setProviderData] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  useEffect(() => {
    const fetchProviders = async () => {
      try {
        const response = await axios.get("http://localhost:8080/api/users/verified");
        setProviderData(response.data.users); 
      } catch (error) {
        console.error("Error fetching provider data:", error);
      }
    };

    fetchProviders();
  }, []);

  const pageCount = Math.ceil(providerData.length / itemsPerPage);
  const paginatedProviders = providerData.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const handlePageChange = (event, value) => {
    setCurrentPage(value);
  };

  return (
    <div className="flex justify-center items-center p-6">
      <div className="w-full max-w-7xl flex flex-col items-center">
        <h1 className="text-2xl font-bold mb-4">
          Saviya B2B E-Commerce Application
        </h1>
        <div className="bg-[#565449] h-1 w-full mb-6" />

        <p className="text-lg text-gray-500 mb-6">Approved Users</p>

        <TableContainer className="w-full mb-6">
          <Table>
            <TableHead>
              <TableRow className="bg-gray-400">
                <TableCell>Name</TableCell>
                <TableCell>Email</TableCell>
                <TableCell>Phone Number</TableCell>
                <TableCell>Profile Picture</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {paginatedProviders.length > 0 ? (
                paginatedProviders.map((provider, index) => (
                  <TableRow key={provider.userid || index}>
                    <TableCell>{`${provider.first_name} ${provider.last_name}`}</TableCell>
                    <TableCell>{provider.email}</TableCell>
                    <TableCell>{provider.phone_number}</TableCell>
                    <TableCell>
                      {provider.profile_picture ? (
                        <img
                          src={provider.profile_picture}
                          alt="Profile"
                          className="h-10 w-10 rounded-full"
                        />
                      ) : (
                        "No picture"
                      )}
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={4} className="text-center text-gray-500">
                    No approved users found.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </TableContainer>

        <Pagination
          count={pageCount}
          page={currentPage}
          onChange={handlePageChange}
          renderItem={(item) => (
            <PaginationItem
              {...item}
              className="bg-gray-800 text-white hover:bg-gray-600"
            />
          )}
          className="mb-6"
          showFirstButton
          showLastButton
        />
      </div>
    </div>
  );
};

export default Approved;
