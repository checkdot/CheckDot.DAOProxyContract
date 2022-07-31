pragma solidity ^0.8.9;

import "./Storage.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * ONLY USED ON THE UNIT TESTS
 */
contract ProductsV1 is Storage {
    using Counters for Counters.Counter;

    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    mapping(uint256 => address) public products;

    constructor() {}

    modifier onlyOwner {
        require(msg.sender == getOwner(), "Only owner is allowed");
        _;
    }

    function initialize() external payable onlyOwner {
        _uintStorage["ninja"] = 1234;
        _boolStorage["initialized"] = true;
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

    function getLastProduct() public view returns (address) {
        return products[_counterStorage["productCount"].current() - 1];
    }

    function getCount() public view returns (uint256) { // new function
        return _counterStorage["productCount"].current();
    }

    function getOwner() public view returns (address) {
        return _owner();
    }

    function _owner() internal view returns (address impl) {
        bytes32 slot = _ADMIN_SLOT;
        assembly {
            impl := sload(slot)
        }
    }
}