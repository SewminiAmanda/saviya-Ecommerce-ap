const Cart = require('./cartModel');
const CartItem = require('./cartItemModel');
const Product = require('./productModel');


Cart.hasMany(CartItem, {
    foreignKey: 'cartId',
    as: 'items'
});

CartItem.belongsTo(Cart, {
    foreignKey: 'cartId',
    as: 'cart'
});


CartItem.belongsTo(Product, {
    foreignKey: 'productId',
    as: 'product'
});

Product.hasMany(CartItem, {
    foreignKey: 'productId',
    as: 'cartItems'
});

module.exports = { Cart, CartItem, Product };