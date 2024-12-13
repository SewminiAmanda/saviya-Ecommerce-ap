const axios = require("axios");

const signupUser = async (first_name, last_name, email, password) => {
  try {
    const response = await axios.post(
      "http://localhost:8080/api/users/signup",
      { first_name, last_name, email, password },
      {
        headers: {
          "Content-Type": "application/json",
        }
      }
    );

    console.log("Response from server:", response.data);
  } catch (error) {
    console.error(
      "Error signing up:",
      error.response ? error.response.data : error.message
    );
  }
};

// Call the function with dynamic input
signupUser("Jane", "Smith", "jane.smith@example.com", "securepassword456");
