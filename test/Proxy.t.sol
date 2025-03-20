// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract OnchainGitV2 is OnchainGit {
    function newFunction() public pure returns (string memory) {
        return "Aboba";
    }
}

contract OnchainGitTest is Test {
    OnchainGit logic;
    OnchainGitV2 logicV2;
    ERC1967Proxy proxy;
    OnchainGit proxyAsLogic;
    address owner = address(this);

    function setUp() public {
        logic = new OnchainGit();
        proxy = new ERC1967Proxy(address(logic), "");
        proxyAsLogic = OnchainGit(address(proxy));
        logicV2 = new OnchainGitV2();
        proxyAsLogic.initialize();
    }

    function testInitialize() public {
        assertEq(proxyAsLogic.currentVersion(), address(proxyAsLogic));
        assertEq(proxyAsLogic.getVersionHistory().length, 1);
    }

    function testUpgrade() public {
        logicV2 = new OnchainGitV2();
        proxyAsLogic.upgradeTo(address(logicV2));
        assertEq(proxyAsLogic.currentVersion(), address(logicV2));
        assertEq(proxyAsLogic.getVersionHistory().length, 2);
    }

    function testRollback() public {
        logicV2 = new OnchainGitV2();
        proxyAsLogic.upgradeTo(address(logicV2));
        proxyAsLogic.rollbackTo(0);
        assertEq(proxyAsLogic.currentVersion(), address(logic));
    }

    function testOnlyOwnerCanUpgrade() public {
        logicV2 = new OnchainGitV2();
        vm.prank(address(0x2));
        vm.expectRevert();
        proxyAsLogic.upgradeTo(address(logicV2));
    }

    function testOnlyOwnerCanRollback() public {
        vm.prank(address(0x2));
        vm.expectRevert();
        proxyAsLogic.rollbackTo(0);
    }

    function testNewFunctionalityAfterUpgrade() public {
        proxyAsLogic.upgradeTo(address(logicV2));

        OnchainGitV2 proxyAsLogicV2 = OnchainGitV2(address(proxy));
        assertEq(proxyAsLogicV2.newFunction(), "Aboba");
    }
}
