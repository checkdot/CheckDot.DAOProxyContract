// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library ProxyUpgrades {

    struct Upgrade {
        uint256 id;
        address submitedNewFunctionalAddress;
        uint256 utcStartVote;
        uint256 utcEndVote;
        uint256 totalApproved;
        uint256 totalUnapproved;
        bool isFinished;
    }

    struct Upgrades {
        mapping(uint256 => Upgrade) upgrades;
        mapping(uint256 => mapping(address => address)) participators;
        uint256 counter;
    }

    /////////
    // Upgrades View
    /////////

    function isEmpty(Upgrades storage upgrades) internal view returns (bool) {
        return upgrades.counter == 0;
    }

    function current(Upgrades storage upgrades) internal view returns (Upgrade storage) {
        return upgrades.upgrades[upgrades.counter - 1];
    }

    function all(Upgrades storage upgrades) internal view returns (Upgrade[] memory) {
        uint256 totalUpgrades = upgrades.counter;
        Upgrade[] memory results = new Upgrade[](totalUpgrades);
        uint256 index = 0;

        for (index; index < totalUpgrades; index++) {
            Upgrade storage upgrade = upgrades.upgrades[index];

            results[index].id = upgrade.id;
            results[index].submitedNewFunctionalAddress = upgrade.submitedNewFunctionalAddress;
            results[index].utcStartVote = upgrade.utcStartVote;
            results[index].utcEndVote = upgrade.utcEndVote;
            results[index].totalApproved = upgrade.totalApproved;
            results[index].totalUnapproved = upgrade.totalUnapproved;
            results[index].isFinished = upgrade.isFinished;
        }
        return results;
    }

    function getLastUpgrade(Upgrades storage upgrades) internal view returns (Upgrade memory) {
        Upgrade memory result;
        Upgrade storage upgrade = upgrades.upgrades[upgrades.counter - 1];
                    
        result.id = upgrade.id;
        result.submitedNewFunctionalAddress = upgrade.submitedNewFunctionalAddress;
        result.utcStartVote = upgrade.utcStartVote;
        result.utcEndVote = upgrade.utcEndVote;
        result.totalApproved = upgrade.totalApproved;
        result.totalUnapproved = upgrade.totalUnapproved;
        result.isFinished = upgrade.isFinished;
        return result;
    }

    /////////
    // Upgrade View
    /////////

    function hasVoted(Upgrade storage upgrade, Upgrades storage upgrades, address _checkAddress) internal view returns (bool) {
        return upgrades.participators[upgrade.id][_checkAddress] == _checkAddress;
    }

    function voteInProgress(Upgrade storage upgrade) internal view returns (bool) {
        return upgrade.utcStartVote < block.timestamp
            && upgrade.utcEndVote > block.timestamp;
    }

    function voteFinished(Upgrade storage upgrade) internal view returns (bool) {
        return upgrade.utcStartVote < block.timestamp
            && upgrade.utcEndVote < block.timestamp;
    }

    /////////
    // Upgrades Functions
    /////////

    function add(Upgrades storage upgrades, address _submitedNewFunctionalAddress, uint256 _utcStartVote, uint256 _utcEndVote) internal {
        unchecked {
            uint256 id = upgrades.counter++;
            
            upgrades.upgrades[id].id = id;
            upgrades.upgrades[id].submitedNewFunctionalAddress = _submitedNewFunctionalAddress;
            upgrades.upgrades[id].utcStartVote = _utcStartVote;
            upgrades.upgrades[id].utcEndVote = _utcEndVote;
            upgrades.upgrades[id].totalApproved = 0;
            upgrades.upgrades[id].totalUnapproved = 0;
            upgrades.upgrades[id].isFinished = false;
        }
    }

    /////////
    // Upgrade Functions
    /////////

    function vote(Upgrade storage upgrade, Upgrades storage upgrades, address _from, bool _approved) internal {
        unchecked {
            if (_approved) {
                upgrade.totalApproved++;
            } else {
                upgrade.totalUnapproved++;
            }
            upgrades.participators[upgrade.id][_from] = _from;
        }
    }

    function setFinished(Upgrade storage upgrade, bool _finished) internal {
        unchecked {
            upgrade.isFinished = _finished;
        }
    }
}