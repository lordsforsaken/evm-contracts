

async function main() {

  const [deployer] = await ethers.getSigners();

  console.log(
  "Deploying contracts with the account:",
  deployer.address
  );

  const CardEdition = await ethers.getContractFactory("CardEdition");
  const nft = CardEdition.attach(
    "0x4dc8dd959ba2a7e04af34c7561ea369ceaaa7df7" // The deployed contract address
  );

  // let tx = await nft.merge([9,25,46], 6)
  // await tx.wait(1)
  // console.log('merged')

  

  let nextTokenId = await nft.nextTokenId();
  let byCardId = []
  console.log(nextTokenId)
  for (let i = 0; i < nextTokenId; i++) {
    let cardDetail = await nft.cardDetails(i);
    console.log(cardDetail)
    if (byCardId[cardDetail[1].toString()])
      byCardId[cardDetail[1].toString()].push(i)
    else
      byCardId[cardDetail[1].toString()] = [i]
    // check no stupid promo cards
    if (cardDetail[1] == 43 || cardDetail[1] == 44 || cardDetail[1] == 45) {
      console.log('ERR ' + cardDetail[1])
    }
  }

  

  for (let i = 0; i < byCardId.length; i++) {
    console.log(i, byCardId[i])
  }
}

main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error);
  process.exit(1);
});