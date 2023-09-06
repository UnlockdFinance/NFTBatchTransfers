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

    function mintNFTs() public {
        // User 1
        mockERC721_1.mint(address(this), 1);
        mockERC721_1.mint(address(this), 2);

        // User 2
        mockERC721_2.mint(address(this), 1);
        mockERC721_2.mint(address(this), 2);

        // Punk
        mockPunkMarket.getPunk(1);
        mockPunkMarket.transferPunk(address(this), 1);
    }

    function approveNFTs() public {
        // Approve ERC721 tokens
        mockERC721_1.approve(address(nftBatchTransfer), 1);
        mockERC721_1.approve(address(nftBatchTransfer), 2);
        mockERC721_2.approve(address(nftBatchTransfer), 1);
        mockERC721_2.approve(address(nftBatchTransfer), 2);
    }

    function offerPunkForSale() public {
        // Approve Punks to be bought by the Batch Transfer contract
        mockPunkMarket.offerPunkForSaleToAddress(
            1,
            0,
            address(nftBatchTransfer)
        );
    }

    function checkOwner(address expected, uint256 tokenId) public {
        assertEq(mockERC721_1.ownerOf(tokenId), expected);
    }

    function testSingleTransfer() public {
        mintNFTs();
        approveNFTs();

        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](1);

        transfers[0] = NFTBatchTransfer.NftTransfer(address(mockERC721_1), 1);

        address receiver = address(0x123);

        nftBatchTransfer.batchTransferFrom(transfers, receiver);

        checkOwner(receiver, 1);
    }

    function testBatchTransfer() public {
        mintNFTs();
        approveNFTs();

        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](2);
        transfers[0] = NFTBatchTransfer.NftTransfer(address(mockERC721_1), 1);
        transfers[1] = NFTBatchTransfer.NftTransfer(address(mockERC721_1), 2);

        address receiver = address(0x124);
        nftBatchTransfer.batchTransferFrom(transfers, receiver);

        checkOwner(receiver, 1);
        checkOwner(receiver, 2);
    }

    function testSinglePunkTransfer() public {
        mintNFTs();
        approveNFTs();
        offerPunkForSale();

        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](1);
        transfers[0] = NFTBatchTransfer.NftTransfer(address(mockPunkMarket), 1);

        address receiver = address(0x125);
        nftBatchTransfer.batchPunkTransferFrom(transfers, receiver);

        assertEq(mockPunkMarket.punkIndexToAddress(1), receiver);
    }

    function testBatchPunkTransfer() public {
        mintNFTs();
        approveNFTs();

        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](2);
        transfers[0] = NFTBatchTransfer.NftTransfer(address(mockPunkMarket), 1);
        transfers[1] = NFTBatchTransfer.NftTransfer(address(mockPunkMarket), 2);

        address receiver = address(0x126);
        nftBatchTransfer.batchPunkTransferFrom(transfers, receiver);

        assertEq(mockPunkMarket.punkIndexToAddress(1), receiver);
        assertEq(mockPunkMarket.punkIndexToAddress(2), receiver);
    }

    function testMixedBatchTransfer() public {
        mintNFTs();
        approveNFTs();

        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](3);
        transfers[0] = NFTBatchTransfer.NftTransfer(address(mockERC721_1), 1);
        transfers[1] = NFTBatchTransfer.NftTransfer(address(mockPunkMarket), 1);
        transfers[2] = NFTBatchTransfer.NftTransfer(address(mockERC721_2), 2);

        address receiver = address(0x127);
        nftBatchTransfer.batchPunkTransferFrom(transfers, receiver);

        checkOwner(receiver, 1);
        assertEq(mockPunkMarket.punkIndexToAddress(1), receiver);
        assertEq(mockERC721_2.ownerOf(2), receiver);
    }
}
