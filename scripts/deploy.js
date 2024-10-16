async function main() {

  console.log(
    "\n\n" +
    "************************** WARNING **************************\n" +
    "Reminder: make sure to run \"database/createTables/addCardsToFree2PlayDeck\" script\n" +
    "to populate the bot account with all the cards for the free-to-play deck.\n" +
    "**************************************************************\n\n"
  );

  const [deployer] = await ethers.getSigners();
  console.log("deployer address", deployer.address)
  console.log(
  "Deploying contracts with the account:",
  deployer.address
  );

  const CardPack = await ethers.getContractFactory("CardPack");
  const cp = await CardPack.deploy(
    "Lords Forsaken Card Pack Alpha",
    "LORDα",
    0,
    "100000000000000000000000" // 100k 
  );
  console.log("Card Pack deploying at:", cp.target);
  await cp.deploymentTransaction().wait(1)
  console.log("Card Pack deployed");

  const CardEdition = await ethers.getContractFactory("CardEdition");
  const nft = await CardEdition.deploy(
    "Lords Forsaken Alpha Cards",
    "LORDα",
    cp.target
  );
  await nft.deploymentTransaction().wait(1)
  console.log("Card NFT deployed at:", nft.target);

//   let numberOfPacks = 50

//   let tx = await cp.mint(""+numberOfPacks+"000000000000000000", deployer.address)
//   await tx.wait(1)
//   console.log('Minted '+numberOfPacks+' Packs to '+deployer.address)

//   tx = await cp.approve(nft.target, "115792089237316195423570985008687907853269984665640564039457584007913129639935")
//   await tx.wait(1)
//   console.log('Approved NFT contract')

//   tx = await nft.openCardPack(numberOfPacks, "123")
//   await tx.wait(1)
//   console.log('Opening '+numberOfPacks+' card pack')

//   tx = await nft.finishOpen(0, "456")
//   let receipt = await tx.wait(1)
//   console.log('Done!')
//   console.log('Gas Used: '+receipt.gasUsed)
//   console.log('Gas/Pack: '+receipt.gasUsed / BigInt(numberOfPacks))

//   let nextTokenId = await nft.nextTokenId();

//   for (let i = 0; i < nextTokenId; i++) {
//     let cardDetail = await nft.cardDetails(i);
//     // console.log(cardDetail)
//     // check no stupid promo cards
//     if (cardDetail[1] == 0 || cardDetail[1] == 43 || cardDetail[1] == 44 || cardDetail[1] == 45) {
//       console.log('ERR ' + cardDetail[1])
//     }
//   }
}

main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error);
  process.exit(1);
});