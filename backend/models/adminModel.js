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
    is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
    },
    profile_picture: {
        type: DataTypes.STRING,
    },
}, {
    tableName: 'admin',
    timestamps: false,
    hooks: {
        beforeCreate: async (user) => {
            const saltRounds = 10;
            user.password = await bcrypt.hash(user.password, saltRounds);
        },
    }
});

Admin.findByEmail = async function (email) {
    return await this.findOne({ where: { email } });
};

module.exports = Admin;