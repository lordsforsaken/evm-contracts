import fs from 'fs'
import hashjs from 'hash.js'

let sha512 = hashjs.sha512

const rnCount = process.argv[2] || 100
const seed = process.argv[3] || 'default seed here'
const filename = 'seeds.txt'

var hash = sha512().update(seed).digest('hex')
var list = [hash]
while (list.length < rnCount) {
    if (list.length%1000 === 0)
        console.log(list.length)
    hash = sha512().update(list[list.length-1]).digest('hex')
    list.push(hash)
}

fs.writeFile(filename, list.join('\n'), function(err) {
    if(err) return console.log(err)
    console.log(rnCount+ " hashes saved to "+filename)
})