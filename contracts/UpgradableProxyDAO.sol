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
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1
     */
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Storage slot with the address of the gorvenance token of the contract.
     * This is the keccak-256 hash of "io.checkdot.proxy.governance-token" subtracted by 1
     */
    bytes32 private constant _GOVERNANCE_SLOT = 0xa104a226b802ae177ad07b7b101c32acd246fa967c70ae9245f6070074d0ef0d;

    /**
     * @dev Storage slot with the upgrades of the contract.
     * This is the keccak-256 hash of "io.checkdot.proxy.upgrades" subtracted by 1
     */
    bytes32 private constant _UPGRADES_SLOT = 0x5369eef32e208f60e8918f320ffd798e56b416ec90d29edfed41f71d65e56165;

    constructor(address _cdtGouvernanceAddress) {
        _setOwner(msg.sender);
        _setGovernance(_cdtGouvernanceAddress);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }

    /**
     * @dev Returns the current Owner address.
     */
    function getOwner() external view returns (address) {
        return _getOwner();
    }

    /**
     * @dev Returns the current Governance address.
     */
    function getGovernance() external view returns (address) {
        return _getGovernance();
    }

    /**
     * @dev Creation and update function of the proxified implementation,
     * the entry of a start date and an end date of the voting period by
     * the governance is necessary. The start date of the period must be
     * greater or equals than the `block.timestamp`.
     * The start date and end date of the voting period must be at least
     * 86400 seconds apart.
     */
    function upgrade(address _newAddress, uint256 _utcStartVote, uint256 _utcEndVote) external payable {
        require(_getOwner() == msg.sender, "Proxy: FORBIDDEN");
        require(_utcStartVote >= block.timestamp, "Proxy: EXPIRED");
        require(_utcEndVote >= (_utcStartVote + 86400), "Proxy: MINIMUM_SPACING");
        ProxyUpgrades.Upgrades storage _proxyUpgrades = ProxyUpgrades.getUpgradesSlot(_UPGRADES_SLOT).value;

        require(_proxyUpgrades.isEmpty() || _proxyUpgrades.current().isFinished, "Proxy: UPGRADE_ALREADY_INPROGRESS");
        _proxyUpgrades.add(_newAddress, _utcStartVote, _utcEndVote);
    }

    /**
     * @dev Function to check the result of the vote of the implementation
     * update.
     * Only called by the owner and if the vote is favorable the
     * implementation is changed and a call to the initialize function of
     * the new implementation will be made.
     */
    function voteUpgradeCounting() external payable {
        require(_getOwner() == msg.sender, "Proxy: FORBIDDEN");
        ProxyUpgrades.Upgrades storage _proxyUpgrades = ProxyUpgrades.getUpgradesSlot(_UPGRADES_SLOT).value;

        require(!_proxyUpgrades.isEmpty(), "Proxy: EMPTY");
        require(_proxyUpgrades.current().voteFinished(), "Proxy: VOTE_ALREADY_INPROGRESS");
        require(!_proxyUpgrades.current().isFinished, "Proxy: UPGRADE_ALREADY_FINISHED");

        _proxyUpgrades.current().setFinished(true);
        if (_proxyUpgrades.current().totalApproved > _proxyUpgrades.current().totalUnapproved) {
            _upgrade(_proxyUpgrades.current().submitedNewFunctionalAddress);
        }
    }

    /**
     * @dev Function callable by the holder of at least one unit of the
     * governance token.
     * A voter can only vote once per update.
     */
    function voteUpgrade(bool approve) external payable {
        ProxyUpgrades.Upgrades storage _proxyUpgrades = ProxyUpgrades.getUpgradesSlot(_UPGRADES_SLOT).value;

        require(!_proxyUpgrades.isEmpty(), "Proxy: EMPTY");
        require(!_proxyUpgrades.current().isFinished, "Proxy: VOTE_FINISHED");
        require(_proxyUpgrades.current().voteInProgress(), "Proxy: VOTE_NOT_STARTED");
        require(!_proxyUpgrades.current().hasVoted(_proxyUpgrades, msg.sender), "Proxy: ALREADY_VOTED");
        require(IERC20(_getGovernance()).balanceOf(msg.sender) >= 1, "Proxy: INSUFFISANT_SOLD");

        _proxyUpgrades.current().vote(_proxyUpgrades, msg.sender, approve);
    }

    /**
     * @dev Returns the array of all upgrades.
     */
    function getAllUpgrades() external view returns (ProxyUpgrades.Upgrade[] memory) {
        return ProxyUpgrades.getUpgradesSlot(_UPGRADES_SLOT).value.all();
    }

    /**
     * @dev Returns the last upgrade.
     */
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
     * @dev Returns the governance address.
     */
    function _getGovernance() internal view returns (address) {
        return ProxyAddresses.getAddressSlot(_GOVERNANCE_SLOT).value;
    }

    /**
     * @dev Stores a new address in the governance slot.
     */
    function _setGovernance(address _newGovernance) private {
        ProxyAddresses.getAddressSlot(_GOVERNANCE_SLOT).value = _newGovernance;
    }

    /**
     * @dev Stores the new implementation address in the implementation slot
     * and call the internal _afterUpgrade function used for calling functions
     * on the new implementation just after the set in the same nonce block.
     */
    function _upgrade(address _newFunctionalAddress) internal {
        _setImplementation(_newFunctionalAddress);
        _afterUpgrade(_newFunctionalAddress);
    }

    /**
     * @dev internal virtual function implemented in the Proxy contract.
     * This is called just after all upgrades of the proxy implementation.
     */
    function _afterUpgrade(address _newFunctionalAddress) internal virtual { }

}