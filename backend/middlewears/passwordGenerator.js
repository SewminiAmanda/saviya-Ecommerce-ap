const crypto = require('crypto');

function generateTempPassword() {
    return crypto.randomBytes(4).toString('hex'); // 8-char temp password
}

module.exports = { generateTempPassword };