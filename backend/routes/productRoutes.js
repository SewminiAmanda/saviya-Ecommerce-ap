const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');

router.post('/create', productController.create);
router.get('/', productController.getAll);
router.get('/:id', productController.getById);
router.put('/:id', productController.update);
router.delete('/:id', productController.delete);
router.get('/category/:categoryid', productController.getByCategoryId);

module.exports = router;