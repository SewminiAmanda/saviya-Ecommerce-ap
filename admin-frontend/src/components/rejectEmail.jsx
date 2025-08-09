import * as React from 'react';

const RejectionEmail = ({ user_name,  reason }) => (
    <div style={{ fontFamily: 'Arial, sans-serif', lineHeight: '1.6', color: '#333' }}>
        <h2 style={{ color: '#d32f2f' }}>Application Rejected</h2>

        <p>Dear {user_name},</p>

        <p>
            We regret to inform you that your application to join our platform as a
            Seller has been reviewed and unfortunately did not meet our current requirements.
        </p>

        {reason && (
            <p>
                <strong>Reason:</strong> {reason}
            </p>
        )}

        <p>
            We appreciate the time and effort you put into your application. If you believe this decision was made in error or
            would like to provide additional information, you’re welcome to contact our support team.
        </p>

        <p>
            You may also reapply in the future if your qualifications or circumstances change.
        </p>

        <p>
            Best regards,<br />
            Saviya Verification Team
        </p>
    </div>
);
export default RejectionEmail;