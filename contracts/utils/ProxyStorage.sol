// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./ProxyUpgrades.sol";

contract ProxyStorage {
    using Counters for Counters.Counter;
    using ProxyUpgrades for ProxyUpgrades.Upgrades;
    using ProxyUpgrades for ProxyUpgrades.Upgrade;

    /**
     * Address of the ERC20 CDT token to check the balance of participants in upgrade votes.
     */
    address public cdtGouvernanceAddress;

    /**
     * Lib containing the history of all updates.
     */
    ProxyUpgrades.Upgrades _proxyUpgrades;

    mapping(string => uint256) _uintStorage;
    mapping(string => address) _addressStorage;
    mapping(string => bool)    _boolStorage;
    mapping(string => string)  _stringStorage;
    mapping(string => Counters.Counter) _counterStorage;
}