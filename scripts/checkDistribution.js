async function main() {

  const [deployer] = await ethers.getSigners();

  console.log(
  "Deploying contracts with the account:",
  deployer.address
  );

  const CardPack = await ethers.getContractFactory("CardPack");
  const cp = await CardPack.deploy(
    "Lords Forsaken Card Pack #1",
    "LF1",
    0,
    "25000000000000000000000"
  );
  console.log("Card Pack deploying at:", cp.target);
  await cp.deploymentTransaction().wait(1)
  console.log("Card Pack deployed");

  const CardEdition = await ethers.getContractFactory("CardEdition");
  const nft = await CardEdition.deploy(
    "Lords Forsaken NFT Edition #1",
    "LFNFT1",
    cp.target
  );
  await nft.deploymentTransaction().wait(1)
  console.log("Card NFT deployed at:", nft.target);

  let numberOfPacks = 50
  let numberOfOpenings = 40
  const totalPacks = numberOfPacks * numberOfOpenings
  const totalCards = 5 * totalPacks

  let tx = await cp.mint(""+totalPacks+"000000000000000000", deployer.address)
  await tx.wait(1)
  console.log('Minted '+totalPacks+' Packs to '+deployer.address)

  tx = await cp.approve(nft.target, "115792089237316195423570985008687907853269984665640564039457584007913129639935")
  await tx.wait(1)
  console.log('Approved NFT contract')

  let openRequestId = 0
  while (numberOfOpenings > 0) {
    tx = await nft.openCardPack(numberOfPacks, Math.floor(Math.random()*1000000))
    await tx.wait(0)
    console.log('Opening '+numberOfPacks+' card pack')

    tx = await nft.finishOpen(openRequestId, Math.floor(Math.random()*1000000))
    let receipt = await tx.wait(0)
    console.log('Done!')
    console.log('Gas Used: '+receipt.gasUsed)
    console.log('Gas/Pack: '+receipt.gasUsed / BigInt(numberOfPacks))
    
    openRequestId++
    numberOfOpenings--

    console.log('Openings left: '+numberOfOpenings)
  }
  

  let nextTokenId = await nft.nextTokenId();

  let cardIds = {}
  let foils = {}
  for (let i = 0; i < nextTokenId; i++) {
    let cardDetail = await nft.cardDetails(i);
    // console.log(cardDetail)

    // check no stupid promo cards
    if (cardDetail[1] == 0 || cardDetail[1] == 43 || cardDetail[1] == 44 || cardDetail[1] == 45) {
      throw('ERR PROMO CARD: ' + cardDetail[1])
    }

    // count card ids
    if (!cardIds[cardDetail[0]])
      cardIds[cardDetail[0]] = 1
    else
      cardIds[cardDetail[0]]++

    // count foils
    if (!foils[cardDetail[1]])
      foils[cardDetail[1]] = 1
    else
      foils[cardDetail[1]]++
  }

  for (const i in cardIds)
    console.log('Card ID #'+i+': '+(cardIds[i] / totalCards))
  console.log('Silver Foil: '+foils[1] / totalCards)
  console.log('Gold Foil: '+foils[2] / totalCards)
  console.log('Total Cards: '+totalCards)
}

main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error);
  process.exit(1);
});