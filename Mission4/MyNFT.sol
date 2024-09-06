// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {

    uint256 public nextTokenId;
    string public baseTokenURI;

    // Constructor that sets the name, symbol, base URI, and owner for the NFT collection
    constructor(
        string memory name, 
        string memory symbol, 
        string memory baseURI
    ) ERC721(name, symbol) Ownable(msg.sender) {
        baseTokenURI = baseURI;
    }

    // Mint function to create new NFTs. Only the contract owner can mint new tokens.
    function mint(address to) public onlyOwner {
        uint256 tokenId = nextTokenId;
        _safeMint(to, tokenId);  // Mint the token to the 'to' address
        nextTokenId++;  // Increment the token ID for the next minting
    }

    // Override the baseURI function to return the base URI for token metadata
    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    // Allow the owner to set a new base URI
    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }
}
