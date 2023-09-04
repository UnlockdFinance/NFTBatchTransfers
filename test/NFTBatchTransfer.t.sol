// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "ds-test/test.sol";
import "../src/NFTBatchTransfer.sol";
import "./MockERC721.sol";

contract TestNFTBatchTransfer is DSTest {
    NFTBatchTransfer public nftBatchTransfer;
    MockERC721 public mockERC721_1;
    MockERC721 public mockERC721_2;

    function setUp() public {
        nftBatchTransfer = new NFTBatchTransfer();
        mockERC721_1 = new MockERC721("Mock Token 1", "MT1");
        mockERC721_2 = new MockERC721("Mock Token 2", "MT2");
    }

    function testBatchTransferFrom() public {
        // Mint some NFTs
        mockERC721_1.mint(address(this), 1);
        mockERC721_1.mint(address(this), 2);
        mockERC721_2.mint(address(this), 3);
        
        // Approve the NFTBatchTransfer contract to move the NFTs
        mockERC721_1.approve(address(nftBatchTransfer), 1);
        mockERC721_1.approve(address(nftBatchTransfer), 2);
        mockERC721_2.approve(address(nftBatchTransfer), 3);

        // Set up the NFTs for transfer
        NFTBatchTransfer.NftTransfer[] memory nftTransfers = new NFTBatchTransfer.NftTransfer[](3);
        nftTransfers[0] = NFTBatchTransfer.NftTransfer(address(mockERC721_1), 1);
        nftTransfers[1] = NFTBatchTransfer.NftTransfer(address(mockERC721_1), 2);
        nftTransfers[2] = NFTBatchTransfer.NftTransfer(address(mockERC721_2), 3);

        // Transfer the NFTs
        nftBatchTransfer.batchTransferFrom(nftTransfers, address(0x123));

        // Check the new owners
        assertEq(mockERC721_1.ownerOf(1), address(0x123));
        assertEq(mockERC721_1.ownerOf(2), address(0x123));
        assertEq(mockERC721_2.ownerOf(3), address(0x123));
    }
}
