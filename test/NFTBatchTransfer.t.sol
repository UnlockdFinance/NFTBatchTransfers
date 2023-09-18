// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/NFTBatchTransfer.sol";
import "./mocks/MockERC721.sol";

// added to test fallback!
interface NonExistentFunction {
    function nonExistent() external payable;
}

contract NFTBatchTransferTest is Test {
    NFTBatchTransfer nftBatchTransfer;

    MockERC721 mfers;
    MockERC721 nakamigos;

    address internal deployer = address(0x123);
    address internal alice = address(0x456);
    address internal bob = address(0x789);

    function setUp() public {
        vm.startPrank(deployer);
        mfers = new MockERC721("MFERS", "MFERS");
        nakamigos = new MockERC721("NAKAMIGOS", "NAKAMIGOS");

        nftBatchTransfer = new NFTBatchTransfer();
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

    ///////////////////////////////////////////////////////////////////////////////////////////
    //                                      NEGATIVES                                        //
    ///////////////////////////////////////////////////////////////////////////////////////////

    function testTransferRevert() public {
        vm.startPrank(alice);
        mintAndApproveNFTs();

        mfers.approve(address(0), 1); // revoke approval

        NFTBatchTransfer.NftTransfer[]
            memory transfers = new NFTBatchTransfer.NftTransfer[](1);
        transfers[0] = NFTBatchTransfer.NftTransfer(address(mfers), 1);

        vm.expectRevert("Gas too low");
        nftBatchTransfer.batchTransferFrom(transfers, bob);

        assertEq(mfers.ownerOf(1), alice);

        vm.stopPrank();
    }

    function testFallbackFunction() public {
        vm.expectRevert("Fallback not allowed");
        NonExistentFunction nef = NonExistentFunction(address(nftBatchTransfer));
        nef.nonExistent{value: 1 ether}();  // This will trigger the fallback function
    }

    function testReceiveRevert() public {
        vm.expectRevert("Contract does not accept Ether");
        payable(address(nftBatchTransfer)).transfer(1 ether);
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
    }
}
