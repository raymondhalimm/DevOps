// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin's implementation of the ERC20 standard
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Your ERC20 Token Contract
contract MyToken is ERC20 {
    
    // Constructor that gives the deployer all of the initial supply
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        // Mint initial supply to the address that deploys the contract
        _mint(msg.sender, initialSupply);
    }
}
