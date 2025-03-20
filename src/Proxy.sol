// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract OnchainGitProxy is ERC1967Proxy {
    constructor(address _logic, bytes memory _data) ERC1967Proxy(_logic, _data) {}
}

contract OnchainGit is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    address[] public versionHistory;
    
    address public currentVersion;

    event Upgraded(address indexed newImplementation);
    event RolledBack(address indexed previousImplementation);

    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        versionHistory.push(address(this));
        currentVersion = address(this);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {
        versionHistory.push(newImplementation);
        currentVersion = newImplementation;
        emit Upgraded(newImplementation);
    }

    function rollbackTo(uint256 versionIndex) external onlyOwner {
        require(versionIndex < versionHistory.length, "Invalid version index");
        currentVersion = versionHistory[versionIndex];
        emit RolledBack(currentVersion);
    }

    function getVersionHistory() external view returns (address[] memory) {
        return versionHistory;
    }
}
