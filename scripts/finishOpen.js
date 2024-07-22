

import fs from 'fs'
const [deployer] = await ethers.getSigners();

console.log("Using account: "+deployer.address)
const CardEdition = await ethers.getContractFactory("CardEdition");
const nft = CardEdition.attach(
  "0x2663227f2497Aa9955c6b58C4658503726Ba801F" // The deployed contract address
);

let openPackRequestId = 0
getRequest(openPackRequestId)

async function getRequest(i) {
  console.log(i)
  let req = await nft.openPackRequests(i)

  if (req[1] == '0x0000000000000000000000000000000000000000') {
    // empty request
    setTimeout(() => {
      getRequest(openPackRequestId)
    }, 3500)
    return
  }

  if (req[4] == false) { // check if open pack request has been processed
    // not opened
    let seeds = fs.readFileSync('/home/dr/Coding/whitefish/seeds.txt').toString().split('\n')
    console.log(seeds.length + ' seeds left in the file')
    let seed = seeds.splice(seeds.length-1-i,1)[0]
    console.log(seed+' is the seed')
    let tx = await nft.finishOpen(BigInt(i), BigInt('0x'+seed))
    await tx.wait(1)
    setTimeout(() => {
      openPackRequestId++
      getRequest(openPackRequestId)
    }, 3500)
  } else {
    setTimeout(() => {
      openPackRequestId++
      getRequest(openPackRequestId)
    }, 1)
  }
}