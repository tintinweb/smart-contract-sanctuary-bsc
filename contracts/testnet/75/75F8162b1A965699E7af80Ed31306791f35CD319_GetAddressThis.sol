pragma solidity ^0.8.2;

contract GetAddressThis {

    function getAddress() public view returns(address){
        return address(this);
    }
}