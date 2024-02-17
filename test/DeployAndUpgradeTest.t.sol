// SPDX-License-identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";

contract DeployAndUpgradeTest is Test {
    // 
    DeployBox deployer;
    UpgradeBox upgrader;
    
    address public proxy;

    function setUp() public {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();
        proxy = deployer.run(); // points to BoxV1
    }

    function testProxyStartsAsBoxV1() public {
        vm.expectRevert();
        BoxV2(proxy).setNumber(7);
    }

    function testUpgrades() public {
        vm.startPrank(msg.sender);
        BoxV2 boxV2 = new BoxV2();
        upgrader.upgradeBox(proxy, address(boxV2));
        vm.stopPrank();
        uint256 expectedValue = 2;
        assertEq(expectedValue, BoxV2(proxy).getVersion());
        
        BoxV2(proxy).setNumber(7);
        uint256 expectedValue2 = 7;
        assertEq(expectedValue2, BoxV2(proxy).getNumber());
    }
    // 
}