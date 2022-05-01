/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

pragma solidity 0.5.12;

contract Payment {

    mapping(address => uint256) public balances;

    address payable wallet;

    constructor(address payable _wallet) public {
        wallet = _wallet;
    }

    function buyToken() public payable {

        wallet.transfer(0.1 ether);

    }

    function () payable external{}

    function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }

}