// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CardPack is ERC20, Ownable {
    bool public isMintable = true;
    uint256 public maxSupply;

    constructor(string memory name, string memory symbol, uint256 initialSupply, uint256 _maxSupply) ERC20(name, symbol) Ownable(msg.sender) {
      maxSupply = _maxSupply;
      _mint(msg.sender, initialSupply);
    }

    // MINT FUNCTIONS
    function mint(uint256 amount, address recipient) external onlyOwner {
        require(isMintable, "mint renounced");
        require(totalSupply() + amount <= maxSupply, "Cannot exceed max supply");
        _mint(recipient, amount);
    }

    function mintBatch(uint256[] calldata amounts, address[] calldata recipients) external onlyOwner {
        require(isMintable, "mint renounced");
        require(amounts.length == recipients.length, "???");
        for (uint256 i = 0; i < amounts.length; i++)
            _mint(recipients[i], amounts[i]);
    }

    function mintRenounce() external onlyOwner {
        // WARNING: this is non-revertable
        isMintable = false;
    }
}