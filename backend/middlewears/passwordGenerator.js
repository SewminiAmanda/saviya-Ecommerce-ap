const crypto = require('crypto');

function generateTempPassword() {
    return crypto.randomBytes(4).toString('hex'); 
}

module.exports = { generateTempPassword };