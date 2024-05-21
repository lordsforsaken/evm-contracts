import units from './units.js'

let probaPerRarity = {
  1: 0.6,
  2: 0.3,
  3: 0.08,
  4: 0.02
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
  probaPerCard[c] = probaPerRarity[r] / numberPerRarity[r]
  if (!cumulativeProbabilities[c-1])
    cumulativeProbabilities[c] = probaPerCard[c]
  else
    cumulativeProbabilities[c] = probaPerCard[c] + cumulativeProbabilities[c-1]
}

// console.log(cumulativeProbabilities)

let thresholdCard = []
for (const cardId in cumulativeProbabilities) {
  let c = cumulativeProbabilities[cardId];
  c = Math.round(c * 10000000000);
  thresholdCard[cardId] = c
}
thresholdCard.splice(0,1)
thresholdCard.splice(thresholdCard.length-1,1)

console.log(thresholdCard)
