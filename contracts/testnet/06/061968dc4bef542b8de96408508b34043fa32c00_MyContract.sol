/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

pragma solidity ^0.8.7;

contract MyContract {

    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address _owner) {
        owner = _owner;
    }


    string value;
    uint incrementedNum;

    function getValue() public view returns (string memory) {
        return value;
    }

    function viewNum() public view returns (uint) {
        return incrementedNum;
    }

    function set(string memory _value) public {
        value = _value;
    }

    function incrementNumber() public {
        incrementedNum = incrementedNum + 1;
    }

    function killContract() public onlyOwner {
        selfdestruct(payable(msg.sender));
    }
}