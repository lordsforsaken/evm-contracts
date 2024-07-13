// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBase.sol";

contract CardEdition is ERC721 {
    // thresholds for randomization
    uint256[] public thresholdFoil = [200000000]; // 2% chance of golden
    uint256[] public thresholdCard = [
      333333333,  666666667, 1000000000, 1333333333,
      1666666667, 2000000000, 2333333333, 2666666667,
      3000000000, 3333333333, 3666666667, 4000000000,
      4333333333, 4666666667, 5000000000, 5333333333,
      5666666667, 6000000000, 6142857143, 6285714286,
      6428571429, 6571428571, 6714285714, 6857142857,
      7000000000, 7142857143, 7285714286, 7428571429,
      7571428571, 7714285714, 7857142857, 8000000000,
      8142857143, 8285714286, 8428571429, 8571428571,
      8714285714, 8857142857, 9000000000, 9133333333,
      9266666667, 9400000000, 9533333333, 9666666667,
      9800000000, 9866666667, 9933333333
    ];

    // the associated ERC20 card pack fungible token
    address public cardPackToken;

    // open card requests
    struct OpenPackRequest {
      uint256 amount;
      address recipient;
      uint256 clientSeed;
    }
    mapping(uint256 => OpenPackRequest) openPackRequests;

    // storage for all cards properties
    struct CardProperties {
      uint256 tokenId;
      uint256 cardId;
      uint256 foil;
      uint256 power;
      uint256 nonce;
    }
    mapping(uint256 => CardProperties) public cardDetails;
    mapping(uint256 => uint256) public nextNonce;

    uint256 nextTokenId;

    constructor(string memory name, string memory symbol, address _cardPackToken)
    ERC721(name, symbol)
    {
      cardPackToken = _cardPackToken;
    }

    function openCardPack(uint256 amount, uint256 clientSeed) public {
      // retrieve card pack token from user balance
      ERC20(cardPackToken).transferFrom(msg.sender, address(this), amount);

      // save calldata for later
      openPackRequests[nextTokenId] = OpenPackRequest(amount, msg.sender, clientSeed);
      nextTokenId++;
    }

    // Called by the VRF
    function finishOpen(uint256 tokenId, uint256 serverSeed) external {
      OpenPackRequest storage req = openPackRequests[tokenId];
      uint256 numberOfPacks = req.amount * 10**18;
      uint256 seed = uint(keccak256(abi.encodePacked(block.timestamp , req.clientSeed, serverSeed)));
      uint256[] memory rngs = expand(seed, 2*numberOfPacks);

      // mint 5 cards per pack
      uint256 i = 0;
      while (i < 5*numberOfPacks) {
        uint256 rngFoil = rngs[i*2] % 10000000000;
        uint256 rngCardId = rngs[i*2+1] % 10000000000;

        // generate card properties
        CardProperties memory cp;
        cp.tokenId = tokenId;
        cp.cardId = rngToCardId(rngCardId);
        cp.foil = rngToFoil(rngFoil);
        cp.power = 1;
        cp.nonce = nextNonce[cp.cardId];
        nextNonce[cp.cardId]++;
        // save card properties
        cardDetails[tokenId] = cp;
        // mint the nft
        _mint(req.recipient, tokenId);
        i++;
      }
    }

    function rngToCardId(uint256 rng) internal view returns(uint256) {
      for (uint256 i = 0; i < thresholdCard.length; i++)
        if (rng < thresholdCard[i])
          return i;
      return thresholdCard.length;
    }

    function rngToFoil(uint256 rng) internal view returns(uint256) {
      for (uint256 i = 0; i < thresholdFoil.length; i++)
        if (rng < thresholdFoil[i])
          return i;
      return thresholdFoil.length;
    }

    // // useless
    // function cardIdToRarity(uint256 cardId) {
    // }

    function merge(uint256[] calldata tokenIds, uint256 targetToken) external {
      uint256 cardId = cardDetails[targetToken].cardId;
      uint256 foil = cardDetails[targetToken].foil;
      for (uint256 i = 0; i < tokenIds.length; i++) {
        uint256 tokenId = tokenIds[i];
        require(cardDetails[tokenId].cardId == cardId, "Cannot merge different card id");
        require(cardDetails[tokenId].foil == foil, "Cannot merge different foil");
        _burn(tokenId);
      }
      cardDetails[targetToken].power += tokenIds.length;
    }

    function expand(uint256 randomValue, uint256 n) public pure returns (uint256[] memory expandedValues) {
      expandedValues = new uint256[](n);
      for (uint256 i = 0; i < n; i++) {
          expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i)));
      }
      return expandedValues;
  }
}