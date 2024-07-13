import fs from 'fs'
import keccak256 from 'keccak256'

const rnCount = process.argv[2] || 100
const seed = process.argv[3] || 'default seed here'
const filename = 'seeds.txt'

var hash = keccak256(seed).toString('hex')
console.log(hash)
var list = [hash]
while (list.length < rnCount) {
    if (list.length%1000 === 0)
        console.log(list.length)
    hash = keccak256(list[list.length-1]).toString('hex')
    list.push(hash)
}

fs.writeFile(filename, list.join('\n'), function(err) {
    if(err) return console.log(err)
    console.log(rnCount+ " hashes saved to "+filename)
})