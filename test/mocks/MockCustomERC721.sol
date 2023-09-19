// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC721} from "../../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "../../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**
 * @title MintableERC721
 * @dev ERC721 minting logic
 */
contract MockCustomERC721 is ERC721Enumerable {
  error ZeroAddress();
  error MaxSupplyReached();
  error MaxNFTsPerWalletReached();

  uint16 public _currTokenId = 1;
  string public baseURI;
  address private owner;
  uint256 public constant MAX_SUPPLY = 10_000;

  constructor(string memory name, string memory symbol) ERC721(name, symbol) {
    baseURI = "";
    owner = _msgSender();
  }

  /**
   * @dev Function to mint tokens
   * @param to The address receiving the NFT
   * @param amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address to, uint256 amount) public returns (bool) {
    if ((balanceOf(msg.sender) + amount) >= 3) revert MaxNFTsPerWalletReached();
    if (to == address(0)) revert ZeroAddress();
    if (_currTokenId + amount >= MAX_SUPPLY) revert MaxSupplyReached();

    for (uint256 i; i < amount; ) {
      _mint(to, _currTokenId);
      unchecked {
        ++i;
        _currTokenId = _currTokenId + 1;
      }
    }
    return true;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function setBaseURI(string memory baseURI_) public {
    baseURI = baseURI_;
  }
}
