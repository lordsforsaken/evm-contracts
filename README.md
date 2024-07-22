# Lords Forsaken Contracts

## 1- Install deps
```shell
npm install
```
Then modify hardhat.config.cjs to add your network and private keys.

## 2- Generate Seeds
```shell
node generateSeeds.js 100000
```

## 3- Deploy contracts
```shell
npx hardhat run scripts/deploy.js --network xxxxx
```

## 4- Launch scanner to process card pack openings
```shell
npx hardhat run scripts/finishOpen.js --network xxxxx
```

## 5- Flatten contracts individually for block explorer contract verification (optional)
```shell
npx hardhat flatten scripts/CardEdition.sol > flat.sol
```
