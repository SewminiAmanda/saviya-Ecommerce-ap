const nodemailer = require('nodemailer');

// ================== HTML TEMPLATES ==================
const getRejectionEmailHtml = ({ user_name, reason }) => `
  <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333">
    <h2 style="color: #d32f2f;">Application Rejected</h2>
    <p>Dear ${user_name},</p>
    <p>
      We regret to inform you that your application to join as a seller on our platform 
      has been reviewed and unfortunately did not meet our current requirements.
    </p>
    ${reason ? `<p><strong>Reason:</strong> ${reason}</p>` : ""}
    <p>We appreciate your effort. You may reapply in the future.</p>
    <p>Best regards,<br />Saviya Verification Team</p>
  </div>
`;

const getAdminInviteEmailHtml = ({ email, tempPassword }) => `
  <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333">
    <h2>Welcome to Saviya Admin Portal</h2>
    <p>You have been added as an <strong>Admin</strong> to the platform.</p>
    <p>Here are your temporary login credentials:</p>
    <p><strong>Email:</strong> ${email}<br />
    <strong>Temporary Password:</strong> ${tempPassword}</p>
    <p>Please log in using this password and update your details immediately.</p>
    <p>
      <a href="http://localhost:5173/login" 
         style="background: #1976d2; color: white; padding: 10px 15px; text-decoration: none; border-radius: 4px;">
         Login Here
      </a>
    </p>
    <p>Best regards,<br />Saviya Admin Team</p>
  </div>
`;

// ================== EMAIL CONTROLLER ==================
const EmailController = {
  sendRejectionEmail: async (req, res) => {
    const { email, user_name, reason } = req.body;

    try {
      const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS,
        },
      });

      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: email,
        subject: "Your Application Has Been Rejected",
        html: getRejectionEmailHtml({ user_name, reason }),
      });

      res.status(200).json({ success: true, message: "Rejection email sent successfully" });
    } catch (error) {
      console.error("Failed to send rejection email:", error);
      res.status(500).json({ success: false, message: "Failed to send rejection email", error: error.message });
    }
  },

  sendAdminInvite: async (email, tempPassword) => {
    try {
      const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS,
        },
      });

      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: email,
        subject: "You Have Been Added as an Admin",
        html: getAdminInviteEmailHtml({ email, tempPassword }),
      });

      console.log("✅ Admin invite sent successfully to " + email);
    } catch (error) {
      console.error("❌ Failed to send admin invite:", error);
      throw new Error("Failed to send admin invite");
    }
  },
};

module.exports = EmailController;
