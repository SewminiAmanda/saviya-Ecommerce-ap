const { DataTypes } = require("sequelize");
const sequelize = require("../connection");
const User = require("./userModel");
const Product = require("./productModel");

const Review = sequelize.define(
    "Review",
    {
        rating: {
            type: DataTypes.INTEGER,
            allowNull: false,
            validate: { min: 1, max: 5 },
        },
        comment: {
            type: DataTypes.TEXT,
            allowNull: true,
        },
        productId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: { model: Product, key: "id" },
            onDelete: "CASCADE",
            field: "product_id",
        },
        userId: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: { model: User, key: "id" },
            onDelete: "CASCADE",
            field: "user_id",
        },

        createdAt: {
            type: DataTypes.DATE,
            defaultValue: DataTypes.NOW,
            field: "created_at"
        },
        updatedAt: {
            type: DataTypes.DATE,
            defaultValue: DataTypes.NOW,
            field: "updated_at"
        }
    },
    {
        tableName: "reviews",
        timestamps: true,
    }
);

Review.belongsTo(User, { foreignKey: "userId", as: "user" });
User.hasMany(Review, { foreignKey: "userId" });

Review.belongsTo(Product, { foreignKey: "productId" });
Product.hasMany(Review, { foreignKey: "productId" });

module.exports = Review;
