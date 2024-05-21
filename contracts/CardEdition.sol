// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBase.sol";

contract CardEdition is ERC721 {
    // thresholds for randomization
    uint256[] public thresholdFoil = [200000000]; // 2% for golden
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

    // storage for VRF requests
    mapping(bytes32 => uint256) requestIdToAmount;
    mapping(bytes32 => address) requestIdToAddress;
    uint256 vrfFee;

    // storage for all cards properties
    struct CardProperties {
      uint256 id;
      uint256 foil;
      uint256 rarity;
      uint256 exp;
      uint256 nonce;
    }
    mapping(uint256 => CardProperties) public cardDetails;

    constructor(string memory name, string memory symbol, address _cardPackToken, address vrfCoordinator, address linkToken, uint256 _vrfFee)
    ERC721(name, symbol)
    VRFConsumerBase(vrfCoordinator, linkToken) {
      cardPackToken = _cardPackToken;
      vrfFee = _vrfFee;
    }

    function openCardPack(uint256 amount) public returns (bytes32 requestId) {
      require(LINK.balanceOf(address(this)) >= fee,"Not enough LINK");
      
      
      // retrieve card pack token from user balance
      ERC20(cardPackToken).transferFrom(msg.sender, address(this), amount);

      // save calldata for later
      requestIdToAmount[requestId] = amount;
      requestIdToAddress[requestId] = msg.sender;

      // call VRF
      return requestRandomness(keyHash, fee);
    }

    // Called by the VRF
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
      uint256 numberOfPacks = requestIdToAmount[requestId] * 10**18;
      uint256[] rngs = expand(seed, 2*numberOfPacks);

      // mint 5 cards per pack
      uint256 i = 0;
      while (i < 5*numberOfPacks) {
        uint256 rngFoil = rngs[i*2];
        uint256 rngCardId = rngs[i*2+1];
        uint256 newItemId = _tokenIds.current();



        _mint(requestIdToAddress[requestId], newItemId);
        _tokenIds.increment();
        i++;
      }
    }

    // merge input cardIds into the target NFT
    function merge(uint256[] cardIds, uint256 targetId) {

    }

    function expand(uint256 randomValue, uint256 n) public pure returns (uint256[] memory expandedValues) {
      expandedValues = new uint256[](n);
      for (uint256 i = 0; i < n; i++) {
          expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i)));
      }
      return expandedValues;
  }
}