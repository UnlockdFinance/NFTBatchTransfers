// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/NFTBatchTransfer.sol";
import "./MockERC721.sol";
import "./MockPunkMarket.sol";

contract NFTBatchTransferTest is Test {
    NFTBatchTransfer nftBatchTransfer;

    MockERC721 mfers;
    MockERC721 nakamigos;

    MockPunkMarket punkMarket;

    address internal deployer = address(0x123);
    address internal alice = address(0x456);
    address internal bob = address(0x789);

    function setUp() public {
        vm.startPrank(deployer);
        mfers = new MockERC721("MFERS", "MFERS");
        nakamigos = new MockERC721("NAKAMIGOS", "NAKAMIGOS");

        punkMarket = new MockPunkMarket();
        punkMarket.allInitialOwnersAssigned();

        nftBatchTransfer = new NFTBatchTransfer(address(punkMarket));
        vm.stopPrank();
    }

    ///////////////////////////////////////////////////////////////////////////////////////////
    //                                      POSITIVES                                        //
    ///////////////////////////////////////////////////////////////////////////////////////////

    function testSingleTransfer() public {
        vm.startPrank(alice);
        mintAndApproveNFTs();

        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](1);
        transfers[0] = NFTBatchTransfer.NftTransfer(address(mfers), 1);
        nftBatchTransfer.batchTransferFrom(transfers, bob);

        assertEq(mfers.ownerOf(1), bob);
        vm.stopPrank();
    }

    function testBatchTransferFromSameCollection() public {
        vm.startPrank(alice);
        mintAndApproveNFTs();

        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](2);
        transfers[0] = NFTBatchTransfer.NftTransfer(address(mfers), 1);
        transfers[1] = NFTBatchTransfer.NftTransfer(address(mfers), 2);

        nftBatchTransfer.batchTransferFrom(transfers, bob);

        assertEq(mfers.ownerOf(1), bob);
        assertEq(mfers.ownerOf(2), bob);
        vm.stopPrank();
    }

    function testBatchTransferFromMultipleCollections() public {
        vm.startPrank(alice);
        mintAndApproveNFTs();

        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](4);
        transfers[0] = NFTBatchTransfer.NftTransfer(address(mfers), 1);
        transfers[1] = NFTBatchTransfer.NftTransfer(address(nakamigos), 1);
        transfers[2] = NFTBatchTransfer.NftTransfer(address(mfers), 2);
        transfers[3] = NFTBatchTransfer.NftTransfer(address(nakamigos), 2);

        nftBatchTransfer.batchTransferFrom(transfers, bob);

        assertEq(mfers.ownerOf(1), bob);
        assertEq(nakamigos.ownerOf(1), bob);
        assertEq(mfers.ownerOf(2), bob);
        assertEq(nakamigos.ownerOf(2), bob);

        vm.stopPrank();
    }

    function testSinglePunkTransfer() public {
        vm.startPrank(alice);
        mintAndApproveNFTs();

        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](1);
        transfers[0] = NFTBatchTransfer.NftTransfer(address(punkMarket), 1);
        nftBatchTransfer.batchPunkTransferFrom(transfers, bob);

        assertEq(punkMarket.punkIndexToAddress(1), bob);
        vm.stopPrank();
    }

    function testBatchPunkTransferFromSameCollection() public {
        vm.startPrank(alice);
        mintAndApproveNFTs();

        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](2);
        transfers[0] = NFTBatchTransfer.NftTransfer(address(punkMarket), 1);
        transfers[1] = NFTBatchTransfer.NftTransfer(address(punkMarket), 2);

        nftBatchTransfer.batchPunkTransferFrom(transfers, bob);

        assertEq(punkMarket.punkIndexToAddress(1), bob);
        assertEq(punkMarket.punkIndexToAddress(2), bob);
        vm.stopPrank();
    }

    function testBatchPunkTransferFromMultipleCollections() public {
        vm.startPrank(alice);
        mintAndApproveNFTs();

        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](6);
        transfers[0] = NFTBatchTransfer.NftTransfer(address(mfers), 1);
        transfers[1] = NFTBatchTransfer.NftTransfer(address(nakamigos), 1);
        transfers[2] = NFTBatchTransfer.NftTransfer(address(punkMarket), 1);
        transfers[3] = NFTBatchTransfer.NftTransfer(address(mfers), 2);
        transfers[4] = NFTBatchTransfer.NftTransfer(address(nakamigos), 2);
        transfers[5] = NFTBatchTransfer.NftTransfer(address(punkMarket), 2);

        nftBatchTransfer.batchPunkTransferFrom(transfers, bob);

        assertEq(mfers.ownerOf(1), bob);
        assertEq(nakamigos.ownerOf(1), bob);
        assertEq(mfers.ownerOf(2), bob);
        assertEq(nakamigos.ownerOf(2), bob);
        assertEq(punkMarket.punkIndexToAddress(1), bob);
        assertEq(punkMarket.punkIndexToAddress(2), bob);

        vm.stopPrank();
    }

    ///////////////////////////////////////////////////////////////////////////////////////////
    //                                      NEGATIVES                                        //
    ///////////////////////////////////////////////////////////////////////////////////////////

    function testZeroAddressRevert() public {
        vm.startPrank(alice);
        vm.expectRevert("Invalid address");
        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](1);
        transfers[0] = NFTBatchTransfer.NftTransfer(
            address(nftBatchTransfer),
            1
        );

        nftBatchTransfer.batchTransferFrom(transfers, address(0));

        vm.stopPrank();
    }

    function testTransferRevert() public {
        vm.startPrank(alice);
        mintAndApproveNFTs();

        mfers.approve(address(0), 1); // revoke approval

        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](1);
        transfers[0] = NFTBatchTransfer.NftTransfer(address(mfers), 1);

        vm.expectRevert("Transfer failed");
        nftBatchTransfer.batchTransferFrom(transfers, bob);

        assertEq(mfers.ownerOf(1), alice);

        vm.stopPrank();
    }

    ///////////////////////////////////////////////////////////////////////////////////////////
    //                                        GAS                                            //
    ///////////////////////////////////////////////////////////////////////////////////////////

    // The following tests are for just for gas metrics and understanding the gas costs of
    // the batch transfer function.
    function testBatchSizeLimit() public {
        vm.startPrank(alice);
        // Mint lots of NFTs
        uint numNFTs = 1192;
        for (uint i = 1; i <= numNFTs; i++) {
            mfers.mint(alice, i);
        }

        mfers.setApprovalForAll(address(nftBatchTransfer), true);

        // Try to batch transfer them all
        uint tokenId = 1;
        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](numNFTs);
        for (uint i = 0; i < numNFTs; i++) {
            transfers[i] = NFTBatchTransfer.NftTransfer(
                address(mfers),
                tokenId
            );
            tokenId++;
        }

        uint startGas = gasleft();

        nftBatchTransfer.batchTransferFrom(transfers, bob);

        assertTrue(startGas - gasleft() < 10000000); // 10 Million gas limit
        vm.stopPrank();
    }

    function testGasOptimization() public {
        vm.startPrank(alice);

        uint numNFTs = 19;
        for (uint i = 1; i <= numNFTs; i++) {
            mfers.mint(alice, i);
        }

        mfers.setApprovalForAll(address(nftBatchTransfer), true);

        // Record starting gas
        uint startGas = gasleft();
        uint tokenId = 1;

        // Batch transfer
        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](numNFTs);
        for (uint i = 0; i < numNFTs; i++) {
            transfers[i] = NFTBatchTransfer.NftTransfer(
                address(mfers),
                tokenId
            );
            tokenId++;
        }

        nftBatchTransfer.batchTransferFrom(transfers, bob);

        // Assert gas used is under limit
        assertTrue(startGas - gasleft() < 200000);

        vm.stopPrank();
    }

    ///////////////////////////////////////////////////////////////////////////////////////////
    //                                      UTILS                                            //
    ///////////////////////////////////////////////////////////////////////////////////////////
    function mintAndApproveNFTs() internal {
        mfers.mint(alice, 1);
        mfers.mint(alice, 2);
        nakamigos.mint(alice, 1);
        nakamigos.mint(alice, 2);

        mfers.approve(address(nftBatchTransfer), 1);
        mfers.approve(address(nftBatchTransfer), 2);
        nakamigos.approve(address(nftBatchTransfer), 1);
        nakamigos.approve(address(nftBatchTransfer), 2);

        punkMarket.getPunk(1);
        punkMarket.getPunk(2);
        punkMarket.offerPunkForSaleToAddress(1, 0, address(nftBatchTransfer));
        punkMarket.offerPunkForSaleToAddress(2, 0, address(nftBatchTransfer));
    }
}
