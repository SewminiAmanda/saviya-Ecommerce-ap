const express = require('express');
const categoryController = require('../controllers/categoryController');

const router = express.Router();


router.post('/create', categoryController.create);
router.get('/', categoryController.getAll);
router.put('/:id', categoryController.update);
router.delete('/:id', categoryController.delete);

module.exports = router;