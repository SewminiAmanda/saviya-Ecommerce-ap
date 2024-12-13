const express = require('express')
const sequelize = require('sequelize')
const dotenv = require('dotenv').config()
const cookieParser = require('cookie-parser')


 const db = require('./Model')

 const userRoutes = require ('./Routes/userRoutes')
 

//setting up your port
const PORT = process.env.PORT || 8080

//assigning the variable app to express
const app = express()

app.use('/api/users', userRoutes);
//middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }))
app.use(cookieParser())

//synchronizing the database and forcing it to false so we dont lose data
db.sequelize.sync({ force: true }).then(() => {
    console.log("db has been re sync")
})



//listening to server connection
app.listen(PORT, () => console.log(`Server is connected on ${PORT}`))