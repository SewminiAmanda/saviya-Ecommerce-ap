const {Client} = require('pg')

const client = new Client({
    host: "localhost",
    user: "postgres",
    port: 5432,
    password: "Sewmini/01831",
    database: "saviya"
})

module.exports = client