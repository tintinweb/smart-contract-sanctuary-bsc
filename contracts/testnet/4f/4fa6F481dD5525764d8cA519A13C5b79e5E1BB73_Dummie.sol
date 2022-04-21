// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;


contract Dummie {
    string public uri;

    event UriChanged(string URI);

    function decimals() public returns(uint) {
        return 10e18;
    }

    function totalSupplyAt(uint snapshotBlock) public returns(uint){
        return 100;
    }

    function totalSupply() public returns(uint){
        return 10000;
    }
    function balanceOfAt(address sender, uint snapshotBlock) public returns(uint){
        return 100;
    }

    function seturi(string memory _newuri) public {
        uri = _newuri;

        emit UriChanged(uri);
    }

    function geturi() public view returns (string memory){
        return uri;
    }
}