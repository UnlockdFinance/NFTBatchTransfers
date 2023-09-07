// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract MockERC721 is ERC721, Ownable {

    string private _mockBaseURI;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function setBaseURI(string calldata baseURI_)
        external
        onlyOwner
    {
        _mockBaseURI = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return _mockBaseURI;
    }
}
