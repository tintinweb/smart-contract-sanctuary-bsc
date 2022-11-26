pragma solidity ^0.8.2;
pragma abicoder v2;

contract Count {
    mapping(address => uint256) public count;

    function UpCount(uint256 _count) external {
        count[msg.sender] = _count;
    }
}