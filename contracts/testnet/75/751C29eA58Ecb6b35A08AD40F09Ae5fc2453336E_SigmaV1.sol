pragma solidity ^0.8.4;

contract SigmaV1 {
    uint public store;
    uint256 public count;


    function set(uint _set, uint256 _count) external returns(uint) {
        store = _set;
        count = _count;
        return store;
    }

    function get() external view returns(uint) {
        return store;
    }

    function increment() external returns(uint) {
        store += 30;
        count += 40;
        return store;
    }
}