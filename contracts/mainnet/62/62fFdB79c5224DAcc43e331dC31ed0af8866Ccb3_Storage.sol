/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;
interface ERC20 {

function transfer(address _to, uint _value) external returns (bool success);

}
/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Storage {
    address public owner;
    constructor() public {
     owner = msg.sender;

    }
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function withdraw_tokens(address _address,uint256 number,address contract_address) onlyOwner public returns(bool) {

ERC20 erc = ERC20(contract_address);
erc.transfer(_address,number);
return true;
}
function ser_owner(address _address) onlyOwner public returns(bool) {

owner = _address;
return true;
}
}