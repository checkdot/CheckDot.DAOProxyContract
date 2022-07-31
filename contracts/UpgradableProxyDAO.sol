// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./utils/ProxyUpgrades.sol";
import "./utils/ProxyAddresses.sol";
import "./interfaces/IERC20.sol";

/**
 * @title UpgradableProxyDAO
 * @author Jeremy Guyet (@jguyet)
 * @dev Smart contract to implement on a contract proxy.
 * This contract allows the management of the important memory of a proxy.
 * The memory spaces are extremely far from the beginning of the memory
 * which allows a high security against collisions.
 * This contract allows updates using a DAO program governed by an
 * ERC20 governance token. A voting session is mandatory for each update.
 * All holders of at least one whole token are eligible to vote.
 * There are several memory locations dedicated to the proper functioning
 * of the proxy (Implementation, admin, governance, upgrades).
 * For more information about the security of these locations please refer
 * to the discussions around the EIP-1967 standard we have been inspired by.
 */
contract UpgradableProxyDAO {
    using ProxyAddresses for ProxyAddresses.AddressSlot;
    using ProxyUpgrades for ProxyUpgrades.Upgrades;
    using ProxyUpgrades for ProxyUpgrades.Upgrade;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation"
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "org.zeppelinos.proxy.admin"
     */
    bytes32 private constant _ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

    /**
     * @dev Storage slot with the address of the gourvenance token of the contract.
     * This is the keccak-256 hash of "io.checkdot.proxy.governance-token"
     */
    bytes32 private constant _GOUVERNANCE_SLOT = 0xa104a226b802ae177ad07b7b101c32acd246fa967c70ae9245f6070074d0ef0e;

    /**
     * @dev Storage slot with the upgrades of the contract.
     * This is the keccak-256 hash of "io.checkdot.proxy.upgrades"
     */
    bytes32 private constant _UPGRADES_SLOT = 0x5369eef32e208f60e8918f320ffd798e56b416ec90d29edfed41f71d65e56166;

    constructor(address _cdtGouvernanceAddress) {
        _setOwner(msg.sender);
        _setGouvernance(_cdtGouvernanceAddress);
    }

    function getImplementation() external view returns (address) {
        return ProxyAddresses.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function getOwner() external view returns (address) {
        return _getOwner();
    }

    function upgrade(address _newAddress, uint256 _utcStartVote, uint256 _utcEndVote) external payable {
        require(_getOwner() == msg.sender, "Only owner");
        ProxyUpgrades.Upgrades storage _proxyUpgrades = ProxyUpgrades.getUpgradesSlot(_UPGRADES_SLOT).value;

        require(_proxyUpgrades.isEmpty() || _proxyUpgrades.current().isFinished, "Upgrade in progress");
        if (_getImplementation() == address(0)) { // first time
            _upgrade(_newAddress);
        } else {
            _proxyUpgrades.add(_newAddress, _utcStartVote, _utcEndVote);
        }
    }

    function voteUpgradeCounting() external payable {
        require(_getOwner() == msg.sender, "Only owner");
        ProxyUpgrades.Upgrades storage _proxyUpgrades = ProxyUpgrades.getUpgradesSlot(_UPGRADES_SLOT).value;

        require(!_proxyUpgrades.isEmpty(), "No Upgrade");
        require(_proxyUpgrades.current().voteFinished(), "Vote in progress");
        require(!_proxyUpgrades.current().isFinished, "Upgrade in already finished");

        _proxyUpgrades.current().setFinished(true);
        if (_proxyUpgrades.current().totalApproved > _proxyUpgrades.current().totalUnapproved) {
            _upgrade(_proxyUpgrades.current().submitedNewFunctionalAddress);
        }
    }

    function voteUpgrade(bool approve) external payable {
        ProxyUpgrades.Upgrades storage _proxyUpgrades = ProxyUpgrades.getUpgradesSlot(_UPGRADES_SLOT).value;

        require(!_proxyUpgrades.isEmpty(), "No Upgrade");
        require(!_proxyUpgrades.current().isFinished, "Vote finished");
        require(_proxyUpgrades.current().voteInProgress(), "Vote not started");
        require(!_proxyUpgrades.current().hasVoted(_proxyUpgrades, msg.sender), "Already voted");
        require(IERC20(_getGourvernance()).balanceOf(msg.sender) >= 1, "Vote not allowed");

        _proxyUpgrades.current().vote(_proxyUpgrades, msg.sender, approve);
    }

    function getAllUpgrades() external view returns (ProxyUpgrades.Upgrade[] memory) {
        return ProxyUpgrades.getUpgradesSlot(_UPGRADES_SLOT).value.all();
    }

    function getLastUpgrade() external view returns (ProxyUpgrades.Upgrade memory) {
        return ProxyUpgrades.getUpgradesSlot(_UPGRADES_SLOT).value.getLastUpgrade();
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return ProxyAddresses.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address _newImplementation) private {
        ProxyAddresses.getAddressSlot(_IMPLEMENTATION_SLOT).value = _newImplementation;
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _getOwner() internal view returns (address) {
        return ProxyAddresses.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setOwner(address _owner) private {
        ProxyAddresses.getAddressSlot(_ADMIN_SLOT).value = _owner;
    }

    /**
     * @dev Returns the gouvernance address.
     */
    function _getGourvernance() internal view returns (address) {
        return ProxyAddresses.getAddressSlot(_GOUVERNANCE_SLOT).value;
    }

    /**
     * @dev Stores a new address in the gouvernance slot.
     */
    function _setGouvernance(address _newGouvernance) private {
        ProxyAddresses.getAddressSlot(_GOUVERNANCE_SLOT).value = _newGouvernance;
    }

    function _upgrade(address _newFunctionalAddress) internal {
        _setImplementation(_newFunctionalAddress);
        _afterUpgrade(_newFunctionalAddress);
    }

    function _afterUpgrade(address _newFunctionalAddress) internal virtual { }

}