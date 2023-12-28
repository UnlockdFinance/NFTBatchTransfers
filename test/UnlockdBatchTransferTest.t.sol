// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {UnlockdBatchTransfer} from "../src/UnlockdBatchTransfer.sol";
import {MockERC721} from "./mocks/MockERC721.sol";
import {MockPunkMarket} from "./mocks/MockPunkMarket.sol";
import {MockACLManager} from "./mocks/MockACLManager.sol";
import {MockSoulbound} from "./mocks/MockSoulbound.sol";

// added to test fallback!
interface NonExistentFunction {
    function nonExistent() external payable;
}

contract _unlockdBatchTransferTest is Test {
    UnlockdBatchTransfer _unlockdBatchTransfer;

    MockACLManager _aclManager;
    MockERC721 _mfers;
    MockERC721 _nakamigos;
    MockSoulbound _uMfers;

    MockPunkMarket _punkMarket;

    address internal _deployer = address(0x123);
    address internal _alice = address(0x456);
    address internal _bob = address(0x789);

    uint256 public _adminPK = 0xC0C00DEAD;
    address internal _admin = vm.addr(_adminPK);

    function setUp() public {
        vm.startPrank(_admin);
        _mfers = new MockERC721("MFERS", "MFERS");
        _nakamigos = new MockERC721("NAKAMIGOS", "NAKAMIGOS");
        _uMfers = new MockSoulbound(address(_mfers), "uMFERS", "Unlockd Bound Mfers");

        _punkMarket = new MockPunkMarket();
        _punkMarket.allInitialOwnersAssigned();

        deploy_acl_manager();
        
        MockERC721(_mfers).setApprovalForAll(address(_unlockdBatchTransfer), true);
        _unlockdBatchTransfer = new UnlockdBatchTransfer(address(_punkMarket), address(_aclManager));
        _unlockdBatchTransfer.addToBeWrapped(address(_mfers), address(_uMfers));
        vm.stopPrank();
    }

    ///////////////////////////////////////////////////////////////////////////////////////////
    //                                      POSITIVES                                        //
    ///////////////////////////////////////////////////////////////////////////////////////////

    function testSingleTransfer() public {
        vm.startPrank(_alice);
        mintAndApproveNFTs();

        UnlockdBatchTransfer.NftTransfer[]
            memory transfers = new UnlockdBatchTransfer.NftTransfer[](1);
        transfers[0] = UnlockdBatchTransfer.NftTransfer(address(_mfers), 1);
        
        _unlockdBatchTransfer.batchTransferFrom(transfers, _bob);
        
        assertEq(_mfers.ownerOf(1), _bob);
        vm.stopPrank();
    }

    function testBatchTransferFromSameCollection() public {
        vm.startPrank(_alice);
        mintAndApproveNFTs();

        UnlockdBatchTransfer.NftTransfer[]
            memory transfers = new UnlockdBatchTransfer.NftTransfer[](2);
        transfers[0] = UnlockdBatchTransfer.NftTransfer(address(_mfers), 1);
        transfers[1] = UnlockdBatchTransfer.NftTransfer(address(_mfers), 2);

        _unlockdBatchTransfer.batchTransferFrom(transfers, _bob);
        
        assertEq(_mfers.ownerOf(1), _bob);
        assertEq(_mfers.ownerOf(2), _bob);
        vm.stopPrank();
    }

    function testBatchTransferFromMultipleCollections() public {
        vm.startPrank(_alice);
        mintAndApproveNFTs();

        UnlockdBatchTransfer.NftTransfer[]
            memory transfers = new UnlockdBatchTransfer.NftTransfer[](4);
        transfers[0] = UnlockdBatchTransfer.NftTransfer(address(_mfers), 1);
        transfers[1] = UnlockdBatchTransfer.NftTransfer(address(_nakamigos), 1);
        transfers[2] = UnlockdBatchTransfer.NftTransfer(address(_mfers), 2);
        transfers[3] = UnlockdBatchTransfer.NftTransfer(address(_nakamigos), 2);

        _unlockdBatchTransfer.batchTransferFrom(transfers, _bob);
        
        assertEq(_mfers.ownerOf(1), _bob);
        assertEq(_nakamigos.ownerOf(1), _bob);
        assertEq(_mfers.ownerOf(2), _bob);
        assertEq(_nakamigos.ownerOf(2), _bob);

        vm.stopPrank();
    }

    function testSinglePunkTransfer() public {
        vm.startPrank(_alice);
        mintAndApproveNFTs();

        UnlockdBatchTransfer.NftTransfer[]
            memory transfers = new UnlockdBatchTransfer.NftTransfer[](1);
        transfers[0] = UnlockdBatchTransfer.NftTransfer(address(_punkMarket), 1);
        
        _unlockdBatchTransfer.batchPunkTransferFrom(transfers, _bob);
        
        assertEq(_punkMarket.punkIndexToAddress(1), _bob);
        vm.stopPrank();
    }

    function testBatchPunkTransferFromSameCollection() public {
        vm.startPrank(_alice);
        mintAndApproveNFTs();

        UnlockdBatchTransfer.NftTransfer[]
            memory transfers = new UnlockdBatchTransfer.NftTransfer[](2);
        transfers[0] = UnlockdBatchTransfer.NftTransfer(address(_punkMarket), 1);
        transfers[1] = UnlockdBatchTransfer.NftTransfer(address(_punkMarket), 2);
        
        _unlockdBatchTransfer.batchPunkTransferFrom(transfers, _bob);
        
        assertEq(_punkMarket.punkIndexToAddress(1), _bob);
        assertEq(_punkMarket.punkIndexToAddress(2), _bob);
        vm.stopPrank();
    }

    function testBatchPunkTransferFromMultipleCollections() public {
        vm.startPrank(_alice);
        mintAndApproveNFTs();

        UnlockdBatchTransfer.NftTransfer[]
            memory transfers = new UnlockdBatchTransfer.NftTransfer[](6);
        transfers[0] = UnlockdBatchTransfer.NftTransfer(address(_mfers), 1);
        transfers[1] = UnlockdBatchTransfer.NftTransfer(address(_nakamigos), 1);
        transfers[2] = UnlockdBatchTransfer.NftTransfer(address(_punkMarket), 1);
        transfers[3] = UnlockdBatchTransfer.NftTransfer(address(_mfers), 2);
        transfers[4] = UnlockdBatchTransfer.NftTransfer(address(_nakamigos), 2);
        transfers[5] = UnlockdBatchTransfer.NftTransfer(address(_punkMarket), 2);

        _unlockdBatchTransfer.batchPunkTransferFrom(transfers, _bob);        

        assertEq(_mfers.ownerOf(1), _bob);
        assertEq(_nakamigos.ownerOf(1), _bob);
        assertEq(_mfers.ownerOf(2), _bob);
        assertEq(_nakamigos.ownerOf(2), _bob);
        assertEq(_punkMarket.punkIndexToAddress(1), _bob);
        assertEq(_punkMarket.punkIndexToAddress(2), _bob);

        vm.stopPrank();
    }

    function testSetPunkContract() public {
        address expectedPunkContract = address(_punkMarket);

        _unlockdBatchTransfer = new UnlockdBatchTransfer(expectedPunkContract, address(_aclManager));

        assertEq(address(_unlockdBatchTransfer._punkContract()), expectedPunkContract);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////
    //                                      NEGATIVES                                        //
    ///////////////////////////////////////////////////////////////////////////////////////////

    function testTransferRevert() public {
        vm.startPrank(_alice);
        mintAndApproveNFTs();

        _mfers.approve(address(0), 1); // revoke approval

        UnlockdBatchTransfer.NftTransfer[]
            memory transfers = new UnlockdBatchTransfer.NftTransfer[](1);
        transfers[0] = UnlockdBatchTransfer.NftTransfer(address(_mfers), 1);

        vm.expectRevert(0x7939f424);
        _unlockdBatchTransfer.batchTransferFrom(transfers, _bob);

        assertEq(_mfers.ownerOf(1), _alice);

        vm.stopPrank();
    }

    function testPunkTransferRevert() public {
        vm.startPrank(_alice);
        mintAndApproveNFTs();

        UnlockdBatchTransfer.NftTransfer[]
            memory transfers = new UnlockdBatchTransfer.NftTransfer[](1);
        transfers[0] = UnlockdBatchTransfer.NftTransfer(address(_punkMarket), 3);

        vm.expectRevert(0x30cd7471);
        _unlockdBatchTransfer.batchPunkTransferFrom(transfers, _bob);

        assertEq(_punkMarket.punkIndexToAddress(1), _alice);

        vm.stopPrank();
    }

    function testFallbackFunction() public {
        vm.expectRevert(0x52b4643c);
        NonExistentFunction nef = NonExistentFunction(address(_unlockdBatchTransfer));
        nef.nonExistent{value: 1 ether}();  // This will trigger the fallback function
    }

    function testReceiveRevert() public {
        vm.expectRevert(0xabdfd301);
        payable(address(_unlockdBatchTransfer)).transfer(1 ether);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////
    //                                      UTILS                                            //
    ///////////////////////////////////////////////////////////////////////////////////////////
    function mintAndApproveNFTs() internal {
        _mfers.mint(_alice, 1);
        _mfers.mint(_alice, 2);
        _nakamigos.mint(_alice, 1);
        _nakamigos.mint(_alice, 2);

        _mfers.approve(address(_unlockdBatchTransfer), 1);
        _mfers.approve(address(_unlockdBatchTransfer), 2);
        _nakamigos.approve(address(_unlockdBatchTransfer), 1);
        _nakamigos.approve(address(_unlockdBatchTransfer), 2);

        _punkMarket.getPunk(1);
        _punkMarket.getPunk(2);
        _punkMarket.offerPunkForSaleToAddress(1, 0, address(_unlockdBatchTransfer));
        _punkMarket.offerPunkForSaleToAddress(2, 0, address(_unlockdBatchTransfer));
    }

    function deploy_acl_manager() internal {
        vm.startPrank(_deployer);
        _aclManager = new MockACLManager(_admin);
        vm.stopPrank();
        vm.startPrank(_admin);
        // Configure ADMINS
        _aclManager.addUTokenAdmin(_admin);
        _aclManager.addProtocolAdmin(_admin);
        _aclManager.addGovernanceAdmin(_admin);
        _aclManager.addAuctionAdmin(_admin);
        _aclManager.addEmergencyAdmin(_admin);
        _aclManager.addPriceUpdater(_admin);

        vm.stopPrank();
    }
}
