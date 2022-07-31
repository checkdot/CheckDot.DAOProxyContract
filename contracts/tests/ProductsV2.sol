pragma solidity ^0.8.9;

import "./Storage.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * ONLY USED ON THE UNIT TESTS
 */
contract ProductsV2 is Storage {
    using Counters for Counters.Counter;

    mapping(uint256 => address) public products;

    constructor() {}

    function initialize() external payable {
        // new empty content
        // ninja = 1236;
        products[_counterStorage["productCount"].current()] = msg.sender;
        _counterStorage["productCount"].increment();
    }

    function ninja() public view returns (uint256) {
        return _uintStorage["ninja"];
    }

    function initialized() public view returns (bool) {
        return _boolStorage["initialized"];
    }

    function testAddProduct(address _productAddress) external payable {
        products[_counterStorage["productCount"].current()] = _productAddress;
        _counterStorage["productCount"].increment();
    }

    function getCount() external view returns (uint256) { // new function
        return _counterStorage["productCount"].current();
    }

    function getOwner() public view returns (address) {
        return _owner();
    }

    function _owner() internal view returns (address impl) {
        assembly {
            impl := sload(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
        }
    }
}