// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployOnchainGit is Script {
    function run() external {
        vm.startBroadcast();

        OnchainGit logic = new OnchainGit();
        
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(logic),
            abi.encodeWithSignature("initialize()")
        );

        OnchainGit proxyAsLogic = OnchainGit(address(proxy));

        console.log("OnchainGit Logic deployed at:", address(logic));
        console.log("OnchainGit Proxy deployed at:", address(proxy));

        vm.stopBroadcast();
    }
}
