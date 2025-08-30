const { DataTypes } = require('sequelize');
const bcrypt = require('bcrypt');
const sequelize = require('../connection');

const Admin = sequelize.define('Admin', {
    userid: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
    },
    user_name: {
        type: DataTypes.STRING,
        allowNull: true, // Changed to allow null for invited admins
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
    is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
    },
    profile_picture: {
        type: DataTypes.STRING,
        allowNull: true,
    },
    isFirstLogin: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
        field: 'is_first_login'
    }
}, {
    tableName: 'admin',
    timestamps: false,
    hooks: {
        beforeCreate: async (user) => {
            if (user.password) {
                const saltRounds = 10;
                user.password = await bcrypt.hash(user.password, saltRounds);
            }
        },
    }
});

Admin.findByEmail = async function (email) {
    return await this.findOne({ where: { email } });
};

module.exports = Admin;