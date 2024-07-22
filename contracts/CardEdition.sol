// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CardEdition is ERC721, Ownable {
    // storage for card pack open requests
    struct OpenPackRequest {
      uint256 amount;
      address recipient;
      uint256 clientSeed;
      uint256 serverSeed;
      bool isProcessed;
    }

    // storage for all cards properties
    struct CardProperties {
      uint256 tokenId;
      uint256 cardId;
      uint256 foil;
      uint256 power;
      uint256 nonce;
    }

    // randomization constants
    uint256[] public thresholdFoil = [1]; // 1 chance in 50
    uint256[] public thresholdCard = [
      389,             778,  1167,
      1556,            1944, 2333,
      2722,            3111, 3500,
      3889,            4278, 4667,
      5056,            5444, 5833,
      6222,            6611, 7000,
      7119,            7238, 7357,
      7476,            7595, 7714,
      7833,            7952, 8071,
      8190,            8310, 8429,
      8548,            8667, 8786,
      8905,            9024, 9143,
      9262,            9381, 9500,
      9633,            9767, 9900,
      9900, 9900, 9900, 9933, 9967
    ];
    // randomized seeds
    uint256 originalSeed = 0;
    uint256 seed = 0;

    
    address public cardPackToken; // the ERC20 card pack fungible token
    mapping(uint256 => OpenPackRequest) public openPackRequests; // card pack opening storage
    mapping(uint256 => CardProperties) public cardDetails; // card attributes storage
    mapping(uint256 => uint256) public nextNonce; // individual card id nonces
    uint256 public nextOpenId = 0;
    uint256 public nextTokenId = 0;
    uint256 startCardId = 1; // the first card id that will be used for this collection

    // custom events
    event Powerup(uint256 targetId, uint256 value);
    event MetadataUpdate(uint256 _tokenId);
    event OpenPack(uint256 openPackId);

    constructor(string memory name, string memory symbol, address _cardPackToken)
    ERC721(name, symbol) Ownable(msg.sender)
    {
      cardPackToken = _cardPackToken;
    }

    // clientSeed is generated randomly by client
    function openCardPack(uint256 amount, uint256 clientSeed) public {
      require(amount>0, "Need to open at least 1 card pack");
      // retrieve card pack token from user balance
      ERC20(cardPackToken).transferFrom(msg.sender, address(this), amount * 10**18);

      // save calldata for later
      openPackRequests[nextOpenId] = OpenPackRequest(amount, msg.sender, clientSeed, 0, false);
      emit OpenPack(nextOpenId);
      nextOpenId++;
    }

    // serverSeed is provably fair and sent by server
    // https://en.wikipedia-on-ipfs.org/wiki/Provably_fair_algorithm
    // verifiable by checking that:
    // keccak256(openPackRequests[requestId]) = openPackRequests[requestId-1]
    // for every processed requestId (except the last)
    function finishOpen(uint256 requestId, uint256 serverSeed) external onlyOwner {
      OpenPackRequest storage req = openPackRequests[requestId];
      uint256 numberOfPacks = req.amount;
      require(numberOfPacks > 0, "Could not find open request");
      require(req.isProcessed == false, "This request has already been processed");
      
      // start of the card generation
      req.isProcessed = true;
      req.serverSeed = serverSeed;
      openPackRequests[requestId] = req;
      seed = uint256(keccak256(abi.encodePacked(req.clientSeed, serverSeed)));
      originalSeed = seed;

      // mint 5 cards per pack
      uint256 i = 0;
      while (i < 5*numberOfPacks) {
        uint256 rngFoil = rngp(50);
        uint256 rngCardId = rngp(10000);

        // generate card properties
        uint256 tokenId = nextTokenId;
        nextTokenId++;

        CardProperties memory cp;
        cp.tokenId = tokenId;
        cp.cardId = rngToCardId(rngCardId);
        cp.foil = rngToFoil(rngFoil);
        // golden cards
        if (cp.foil == 0)
          cp.foil = 2;
        cp.power = 1;
        cp.nonce = nextNonce[cp.cardId];
        nextNonce[cp.cardId]++;
        // save card properties
        cardDetails[tokenId] = cp;
        // mint the nft
        _safeMint(req.recipient, tokenId);
        i++;
      }
    }

    function rngToCardId(uint256 rng) internal view returns(uint256) {
      for (uint256 i = 0; i < thresholdCard.length; i++)
        if (rng < thresholdCard[i])
          return i + startCardId;
      return thresholdCard.length + startCardId;
    }

    function rngToFoil(uint256 rng) internal view returns(uint256) {
      for (uint256 i = 0; i < thresholdFoil.length; i++)
        if (rng < thresholdFoil[i])
          return i;
      return thresholdFoil.length;
    }

    function merge(uint256[] calldata tokenIds, uint256 targetToken) external {
      uint256 cardId = cardDetails[targetToken].cardId;
      uint256 foil = cardDetails[targetToken].foil;
      for (uint256 i = 0; i < tokenIds.length; i++) {
        require(ownerOf(tokenIds[i]) == msg.sender, "Need to own the burnt cards");
        require(cardDetails[tokenIds[i]].cardId == cardId, "Cannot merge different card id");
        require(cardDetails[tokenIds[i]].foil == foil, "Cannot merge different foil");
        _burn(tokenIds[i]);
      }
      require(ownerOf(targetToken) == msg.sender, "Need to own the target");
      cardDetails[targetToken].power += tokenIds.length;
      emit Powerup(targetToken, tokenIds.length);
      emit MetadataUpdate(targetToken);
    }

    function rngp(uint256 divisor) internal returns(uint256) {
      if (seed < 100000000000000) {
        // if tape is running out
        seed = uint256(keccak256(abi.encode(originalSeed, seed % 100000)));
        originalSeed = seed;
      }
      uint256 roll = seed % divisor;
      seed = seed / divisor;
      return roll;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
      require(cardDetails[tokenId].power > 0, "ERC721Metadata: URI query for nonexistent token");
      return string.concat("https://api.lordsforsaken.com/metadata/", Strings.toString(tokenId));
    }
}