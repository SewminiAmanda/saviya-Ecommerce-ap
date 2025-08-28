const { DataTypes } = require('sequelize');
const bcrypt = require('bcrypt');
const sequelize = require('../connection');

const User = sequelize.define('User', {
    userid: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
    },
    first_name: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    last_name: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    email: {
        type: DataTypes.STRING,
        unique: true,
        allowNull: false,
        validate: {
            isEmail: true,
        },
    },
    password: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    address: {
        type: DataTypes.TEXT,
    },
    phone_number: {
        type: DataTypes.STRING,
    },
    is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
    },
    is_verified: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
    is_rejected: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
    profile_picture: {
        type: DataTypes.STRING,
    },
    verification_docs: {
        type: DataTypes.STRING,
        allowNull: true
    },
}, {
    tableName: 'users',
    timestamps: false,
    hooks: {
        beforeCreate: async (user) => {
            const saltRounds = 10;
            user.password = await bcrypt.hash(user.password, saltRounds);
        },
    }
});

User.findByEmail = async function (email) {
    return await this.findOne({ where: { email } });
};

User.findById = async function (userid) {
    return await this.findOne({ where: { userid } });
}

module.exports = User;