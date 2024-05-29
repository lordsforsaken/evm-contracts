// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ALL THE COINS ARE MINTED ON CONTRACT DEPLOYMENT
// NO MINT FUNCTION

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FaithToken is ERC20 {
    constructor(address vestManager, address p2eManager, address treasury) ERC20("Faith LordsForsaken.com", "FAITH") {
        uint256 supply = 100000000000000000000000000; // 100 million
        uint256 vestingShare = supply * 2 / 10;
        uint256 p2eShare = supply * 3 / 10;
        uint256 treasuryShare = supply * 5 / 10;
        _mint(vestManager, vestingShare); 
        _mint(p2eManager, p2eShare);
        _mint(treasury, treasuryShare);
    }
}