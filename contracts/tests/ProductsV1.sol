pragma solidity ^0.8.9;

import "../utils/ProxyStorage.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

contract ProductsV1 is ProxyStorage {
    using Counters for Counters.Counter;

    bytes32 private constant _ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

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