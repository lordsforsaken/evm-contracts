// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/finance/VestingWallet.sol";

contract TeamVesting is VestingWallet, Ownable {
    constructor(address beneficiary, uint64 startTimestamp) VestingWallet(beneficiary, startTimestamp, 31536000) {
        
    }
}