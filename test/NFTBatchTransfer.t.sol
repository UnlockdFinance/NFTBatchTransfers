// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "ds-test/test.sol";
import "../src/NFTBatchTransfer.sol";
import "./MockERC721.sol";
import "./MockPunkMarket.sol";

contract TestNFTBatchTransfer is DSTest {
    NFTBatchTransfer public nftBatchTransfer;
    MockERC721 public mockERC721_1;
    MockERC721 public mockERC721_2;
    MockPunkMarket public mockPunkMarket;

    function setUp() public {
        mockERC721_1 = new MockERC721("Mock Token 1", "MT1");
        mockERC721_2 = new MockERC721("Mock Token 2", "MT2");
        mockPunkMarket = new MockPunkMarket();
        mockPunkMarket.allInitialOwnersAssigned();
        nftBatchTransfer = new NFTBatchTransfer(address(mockPunkMarket));
    }

    function testSingleNFTTransfer() public {
        // Mint an NFT
        mockERC721_1.mint(address(this), 1);
    
        // Approve the NFTBatchTransfer contract to move the NFT
        mockERC721_1.approve(address(nftBatchTransfer), 1);
    
        // Set up the NFT for transfer
        NFTBatchTransfer.NftTransfer[] memory nftTransfers = new NFTBatchTransfer.NftTransfer[](1);
        nftTransfers[0] = NFTBatchTransfer.NftTransfer(address(mockERC721_1), 1);
    
        // Transfer the NFT
        nftBatchTransfer.batchTransferFrom(nftTransfers, address(0x123));
    
        // Check the new owner
        assertEq(mockERC721_1.ownerOf(1), address(0x123));
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

    function testBatchPunkTransferFrom() public {
        // Mint some NFTs
        mockERC721_1.mint(address(this), 1);
        mockERC721_2.mint(address(this), 2);
        mockPunkMarket.getPunk(1);
        mockPunkMarket.transferPunk(address(nftBatchTransfer), 1);

        // Approve the NFTBatchTransfer contract to move the NFTs
        mockERC721_1.approve(address(nftBatchTransfer), 1);
        mockERC721_2.approve(address(nftBatchTransfer), 2);

        // Set up the NFTs for transfer
        NFTBatchTransfer.NftTransfer[] memory nftTransfers = new NFTBatchTransfer.NftTransfer[](3);
        nftTransfers[0] = NFTBatchTransfer.NftTransfer(address(mockERC721_1), 1);
        nftTransfers[1] = NFTBatchTransfer.NftTransfer(address(mockERC721_2), 2);
        nftTransfers[2] = NFTBatchTransfer.NftTransfer(address(mockPunkMarket), 1);

        // Transfer the NFTs
        nftBatchTransfer.batchPunkTransferFrom(nftTransfers, address(0x123));

        // Check the new owners
        assertEq(mockERC721_1.ownerOf(1), address(0x123));
        assertEq(mockERC721_2.ownerOf(2), address(0x123));
        assertEq(mockPunkMarket.punkIndexToAddress(1), address(0x123));
    }
}
