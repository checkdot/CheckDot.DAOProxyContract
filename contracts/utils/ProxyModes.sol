// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title ProxyModes
 * @author Jeremy Guyet (@jguyet)
 * @dev Library to manage the start of the protocol once the protocol is tested,
 * administrators must apply the production mode to ensure trust with their users,
 * this will activate the update mode by voting DAO.
 */
library ProxyModes {
    struct ModeSlot {
        bool value;
    }

    /**
     * @dev Returns an `ModeSlot` with member `value` located at `slot`.
     */
    function getModeSlot(bytes32 slot) internal pure returns (ModeSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}