const {Sequelize, DataTypes} = require('sequelize')

const sequelize = new Sequelize({
    username: "postgres",
    password: "Sewmini/01831",
    database: "saviya",
    host: "localhost",
    port: 5432,
    dialect: "postgres",
  });
  

sequelize.authenticate().then(() => {
    console.log(`Database connected to saviya`)
}).catch((err) => {
    console.log(err)
})

const db = {}
db.Sequelize = Sequelize
db.sequelize = sequelize

db.users = require('./userModel') (sequelize, DataTypes)

//exporting the module
module.exports = db