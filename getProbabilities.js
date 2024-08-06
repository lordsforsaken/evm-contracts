import units from './units.js'

// STUPID HACKY SHIT BECAUSE OF ""PROMO CARDS""
for (let u = 0; u < units.length; u++) {
  if (units[u].id == 43 || units[u].id == 44 || units[u].id == 45) {
    units.splice(u,1)
    u--
  }
}

let probaPerRarity = {
  1: 0.7,
  2: 0.25,
  3: 0.04,
  4: 0.01
}
let numberPerRarity = {
  1: 0,
  2: 0,
  3: 0,
  4: 0
}


for (let i = 0; i < units.length; i++) {
  let r = units[i].rarity
  if (!numberPerRarity[r])
    numberPerRarity[r] = 1
  else
    numberPerRarity[r]++
}

let probaPerCard = {}
let cumulativeProbabilities = {}

for (let i = 0; i < units.length; i++) {
  let r = units[i].rarity
  let c = units[i].id
  probaPerCard[c] = numberPerRarity[r] / probaPerRarity[r]
  if (!cumulativeProbabilities[c-1]) {
    // STUPID HACKY SHIT BECAUSE OF ""PROMO CARDS""
    if (c == 46) {
      cumulativeProbabilities[c] = probaPerCard[c] + cumulativeProbabilities[42]
    } else
      cumulativeProbabilities[c] = probaPerCard[c]
  }
    
  else
    cumulativeProbabilities[c] = probaPerCard[c] + cumulativeProbabilities[c-1]
}

console.log('Probabilities per card ID:')
for (const i in probaPerCard) {
  console.log(i, 1/probaPerCard[i])
}

let thresholdCard = []
for (const cardId in cumulativeProbabilities) {
  let c = cumulativeProbabilities[cardId];
  c = Math.round(c * 10000);
  thresholdCard[cardId] = c
}
thresholdCard.splice(0,1)
thresholdCard.splice(thresholdCard.length-1,1)

console.log('Thresholds: ')
console.log(thresholdCard)
