const nodemailer = require('nodemailer');
const getRejectionEmailHtml = ({ user_name, reason }) => `
  <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333">
    <h2 style="color: #d32f2f;">Application Rejected</h2>
    <p>Dear ${user_name},</p>
    <p>
      We regret to inform you that your application to join as a seller to our platform has been reviewed and unfortunately did not meet our current requirements.
    </p>
    ${reason ? `<p><strong>Reason:</strong> ${reason}</p>` : ''}
    <p>We appreciate your effort. You may reapply in the future.</p>
    <p>Best regards,<br />Saviya Verification Team</p>
  </div>
`;



const EmailController = {
  sendRejectionEmail: async (req, res) => {
    const { email, user_name, reason } = req.body;

    try {
      const transporter = nodemailer.createTransport({
        service: 'gmail', // or another SMTP provider
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS
        }
      });

      const username = user_name;

      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: email,
        subject: "Your Application Has Been Rejected",
        html: getRejectionEmailHtml({ firstName: user_name, reason })
      });

      res.status(200).json({ success: true, message: 'Rejection email sent successfully' });
    } catch (error) {
      console.error("Failed to send email:", error);
      res.status(500).json({ success: false, message: 'Failed to send rejection email', error: error.message });
    }
  }
};

module.exports = EmailController;
