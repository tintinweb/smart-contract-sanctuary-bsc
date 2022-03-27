/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: MIT 
pragma solidity ^0.6.12;

contract associateSystem {

    event TitleValue(uint256 indexed _BNB);
    event Withdraw  (address indexed, uint indexed _BNB, uint indexed balance);
    event Deposit   (address indexed sender, uint indexed amount, uint indexed balance);

    uint public BNB;
    
    mapping(address => bool) internal Associates;

    event Closed();
    event Open();

    bool public listing;

    modifier whenClosed() {
    require(!listing, 'FST Info: A listagem de associados esta ABERTA');
    _;}

    modifier whenOpen() {
    require(listing, 'FST Info: A listagem de associados esta FECHADA');
    _;}

constructor() public payable{}

    function open_Associates() public whenClosed returns (bool) {
    listing = true;
    emit Open();
    return true;}

    function close_Associates() public whenOpen returns (bool) {
    listing = false;
    emit Closed();
    return true;}

    function associate(address account) external payable whenOpen {
        require(msg.sender != address(0), 'FST Info: O endereço nao pode ser zero');
        require(!Associates[msg.sender],'FST Info: Este endereço ja esta associado');
        require(msg.value == BNB, 'FST Info: Voce nao possui BNB suficiante para ser um associado');
        Associates[account] = true;
        emit Deposit   (msg.sender, msg.value, address(this).balance);}

    function remove_Associate() public {
        require(msg.sender != address(0), 'FST Info: O endereço nao pode ser zero');
        require(Associates[msg.sender], 'FST Info: O endereço nao esta na lista de assciados');
        Associates[msg.sender] = false;

    }

    function withdraw(uint _BNB) public{
        // require(roles[ADMIN][msg.sender], "FST Info: Você não está autorizado para utilizar este comando");
        require(address(this).balance > 0,'FST Info: O cotrato nao possue fundos');
        (msg.sender).transfer(_BNB);
        emit Withdraw(msg.sender, _BNB, address(this).balance);
    }

    function set_Titlevalue(uint256 _BNB) public{
        require(_BNB != BNB, 'FST Info: O BNB nao pode ser igual ao mesmo');
        BNB = _BNB;
        emit TitleValue(_BNB);
    }

    function getContractBalance() public view returns (uint){
        return address(this).balance;
    }

}