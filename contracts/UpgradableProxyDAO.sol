// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./utils/ProxyStorage.sol";
import "./utils/ProxyUpgrades.sol";
import "./utils/StorageSlot.sol";
import "./interfaces/IERC20.sol";

contract UpgradableProxyDAO is ProxyStorage {
    using StorageSlot for StorageSlot.AddressSlot;
    using ProxyUpgrades for ProxyUpgrades.Upgrades;
    using ProxyUpgrades for ProxyUpgrades.Upgrade;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "org.zeppelinos.proxy.admin", and is
     * validated in the constructor.
     */
    bytes32 private constant _ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

    constructor(address _cdtGouvernanceAddress) {
        _setOwner(msg.sender);
        cdtGouvernanceAddress = _cdtGouvernanceAddress;
    }

    function getImplementation() external view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function getOwner() external view returns (address) {
        return _getOwner();
    }

    function upgrade(address _newAddress, uint256 _utcStartVote, uint256 _utcEndVote) external payable {
        require(_getOwner() == msg.sender, "Only owner");
        require(_proxyUpgrades.isEmpty() || _proxyUpgrades.current().isFinished, "Upgrade in progress");
        if (_getImplementation() == address(0)) { // first time
            _upgrade(_newAddress);
        } else {
            _proxyUpgrades.add(_newAddress, _utcStartVote, _utcEndVote);
        }
    }

    function voteUpgradeCounting() external payable {
        require(_getOwner() == msg.sender, "Only owner");
        require(!_proxyUpgrades.isEmpty(), "No Upgrade");
        require(_proxyUpgrades.current().voteFinished(), "Vote in progress");
        require(!_proxyUpgrades.current().isFinished, "Upgrade in already finished");

        _proxyUpgrades.current().setFinished(true);
        if (_proxyUpgrades.current().totalApproved > _proxyUpgrades.current().totalUnapproved) {
            _upgrade(_proxyUpgrades.current().submitedNewFunctionalAddress);
        }
    }

    function voteUpgrade(bool approve) external payable {
        require(!_proxyUpgrades.isEmpty(), "No Upgrade");
        require(!_proxyUpgrades.current().isFinished, "Vote finished");
        require(_proxyUpgrades.current().voteInProgress(), "Vote not started");
        require(!_proxyUpgrades.current().hasVoted(_proxyUpgrades, msg.sender), "Already voted");
        require(IERC20(cdtGouvernanceAddress).balanceOf(msg.sender) >= 1, "Vote not allowed");

        _proxyUpgrades.current().vote(_proxyUpgrades, msg.sender, approve);
    }

    function getAllUpgrades() external view returns (ProxyUpgrades.Upgrade[] memory) {
        return _proxyUpgrades.all();
    }

    function getLastUpgrade() external view returns (ProxyUpgrades.Upgrade memory) {
        return _proxyUpgrades.getLastUpgrade();
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address _newImplementation) private {
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = _newImplementation;
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _getOwner() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setOwner(address _owner) private {
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = _owner;
    }

    function _upgrade(address _newFunctionalAddress) internal {
        _setImplementation(_newFunctionalAddress);
        _afterUpgrade(_newFunctionalAddress);
    }

    function _afterUpgrade(address _newFunctionalAddress) internal virtual { }

}