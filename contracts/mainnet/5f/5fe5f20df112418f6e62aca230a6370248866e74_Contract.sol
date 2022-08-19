/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract Contract {

    MyContract contract1 = new MyContract();

    function getSelector() public view returns (bytes4, bytes4) {
        return (contract1.function1.selector, contract1.getBalance.selector);
    }

    function callGetValue(uint _x) public view returns (uint) {

        bytes4 selector = contract1.getValue.selector;

        bytes memory data = abi.encodeWithSelector(selector, _x);
        (bool success, bytes memory returnedData) = address(contract1).staticcall(data);
        require(success);

        return abi.decode(returnedData, (uint256));
    }
}

contract MyContract {

    function function1() public {}

    function getBalance(address _address) public view returns (uint256){}

    function getValue (uint _value) public pure returns (uint) {
        return _value;
    }

}