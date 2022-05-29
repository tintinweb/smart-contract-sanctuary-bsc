/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// File: accumulation.sol


pragma solidity ^0.8.9;

contract accumulation {

    mapping(uint => address) public addresses;
    address owner;
    uint public t;
    
    constructor(address Owner){
        owner = Owner;
        addresses[1] = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        addresses[2] = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        addresses[3] = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
    }

    receive() external payable {
        uint value = msg.value;
        if (value < 10) {  
            // address payable receiver = payable (msg.sender);         
            // receiver.transfer(value);
            t = 1;
        } else {
            // transaction(value);
            t = 2;
        }
    }

    modifier onlyOwner() {
        require (msg.sender == owner, "you are not owner");
        _;
    }

    function balance() public view returns(uint) {
        return (address(this).balance);
    }

    function transaction (uint value) internal {
        for (uint i = 1; i<=3; i++) {
            address payable receiver = payable (addresses[i]);
            receiver.transfer(value/3);
            }
            uint remainder = address(this).balance;
            if (remainder > 0) {
                for (uint i = 1; i<=remainder; i++) {
                address payable receiver = payable (addresses[i]);
                receiver.transfer(1);  
                }
            }
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}