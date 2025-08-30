const jwt = require('jsonwebtoken');
const SECRET_KEY = '78a07bdfe276a6c00a94cfda343629dbb5d338bac19dae41b1929ee63b969';

module.exports = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ message: 'Authorization header missing' });
  }

  const token = authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ message: 'Token missing' });
  }

  try {
    const decoded = jwt.verify(token, SECRET_KEY);

    // Attach the decoded payload to the request
    req.user = decoded;
    

    // decoded should contain userId if it was included in the token
    // e.g., req.user.userId
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Invalid token', error: err.message });
  }
};
