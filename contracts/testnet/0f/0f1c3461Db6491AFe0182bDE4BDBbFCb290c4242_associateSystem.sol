/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: MIT 
pragma solidity ^0.6.12;

contract associateSystem {

    event TitleValue(uint256 indexed _BNB);
    event Withdraw  (address indexed, uint indexed balance);
    event Deposit   (address indexed sender, uint indexed amount, uint indexed balance);

    uint256 public BNB;
    
    mapping(address => bool) public Associates;

constructor() public payable{}

    function associate() public payable {
        require(msg.sender != address(0),"FST Info: O assiciado nao pode ser o endereço zero");
        require(!Associates[msg.sender] == true, "FST Info: O endereço ja esta na lsta de associados");
        require(msg.value == BNB, "FST Info: Voce nao possui BNB suficiante para ser um associado");
        
        Associates[msg.sender] = true;
        emit Deposit   (msg.sender, msg.value, address(this).balance);}

    function withdraw() public{
        // require(roles[ADMIN][msg.sender], "FST Info: Você não está autorizado para utilizar este comando");
        (msg.sender).transfer(address(this).balance);
        emit Withdraw(msg.sender, address(this).balance);
    }

    function set_Titlevalue(uint256 _BNB) public{
        require(_BNB != BNB, "FST Info: O BNB nao pode ser igual ao mesmo");
        BNB = _BNB;
        emit TitleValue(_BNB);
    }

    function getContractBalance() public view returns (uint){
        return address(this).balance;
    }
}