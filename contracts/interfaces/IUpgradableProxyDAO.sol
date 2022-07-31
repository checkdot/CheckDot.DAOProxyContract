// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../utils/ProxyUpgrades.sol";

/**
 * @title IUpgradableProxyDAO
 * @author Jeremy Guyet (@jguyet)
 * @dev See {UpgradableProxyDAO}.
 */
interface IUpgradableProxyDAO {

    function getImplementation() external view returns (address);

    function getOwner() external view returns (address);

    function upgrade(address _newAddress, uint256 _utcStartVote, uint256 _utcEndVote) external payable;

    function voteUpgradeCounting() external payable;

    function voteUpgrade(bool approve) external payable;

    function getAllUpgrades() external view returns (ProxyUpgrades.Upgrade[] memory);

    function getLastUpgrade() external view returns (ProxyUpgrades.Upgrade memory);
}