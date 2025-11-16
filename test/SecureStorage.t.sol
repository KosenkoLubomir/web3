pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SecureStorage} from "../src/SecureStorage.sol";

contract SecureStorageTest is Test {
    SecureStorage s;

    address owner = 0xD5453C4AceB157Ae04f4Ff0Eb73e3Bf8Da718f46;
    address user  = 0xe8fe0eC2462edE11feE8155102DfF12a694712D5;

    function setUp() public {
        vm.prank(owner);
        s = new SecureStorage("1");
    }

    function test_storeAndRetrieveRecords() public {
        vm.startPrank(user);
        s.store(123);
        vm.stopPrank();

        uint value = s.getMyRecord(user);
        assertEq(value, 123);
    }

    function test_onlyOwnerCanSetVersion() public {
        vm.expectRevert(SecureStorage.NotOwner.selector);
        vm.prank(user);
        s.setVersion("2");
    }

    function test_ownerCanSetAndGetVersion() public {
        vm.prank(owner);
        s.setVersion("1.1");

        string memory currentVersion = s.getVersion();
        assertEq(currentVersion, "1.1");
    }
}
