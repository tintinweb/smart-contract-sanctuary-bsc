// SPDX-License-Identifier: MIT

import "./Bitkanz-BSC.sol";

pragma solidity = 0.8.10;

contract BTKambassador {
    using SafeMath for uint256;
    BitKanz public BTK;
    address private owner;
    uint256 fractions = 10**18;
    uint256 private IDambassador;
    uint256 private Price;
    uint256 private limit = 10 * fractions;

    event BTKsale(address Investor, uint256 ForInvestor, uint256 ForAmbassador, uint256 AmbassadorID, string Country);
    event ChangeOwner(address NewOwner);
    event WithdrawalBNB(uint256 _amount, uint256 decimal, address to); 
    event WithdrawalBTK(uint256 _amount,uint256 decimals, address to);
    event WithdrawalERC20(address _tokenAddr, uint256 _amount,uint256 decimals, address to);
    
    struct newAmbsdr{
        uint256 ID;
        address ambsdrAddress;
        uint256 percentage;
        string Country;
    }

    mapping(address => bool) private Ambassador;
    mapping(uint256 => newAmbsdr) private ambassadorID;

    modifier onlyOwner (){
        require(msg.sender == owner, "Only BitKanz owner can add Investors");
        _;
    }

    constructor(BitKanz _btk) {
        owner = msg.sender;
        IDambassador = 0;
        BTK = _btk;
    }
    function transferOwnership(address _newOwner)external onlyOwner{
        emit ChangeOwner(_newOwner);
        owner = _newOwner;
    }
    function setPrice(uint256 _price) external onlyOwner{
        Price = _price.mul(fractions);
    }
    function setLimit(uint256 _limit) external onlyOwner{
        limit = _limit;
    }
    function addAmbassador(uint256 _ID, address _ambsdr, uint256 _percentage, string memory _country) external onlyOwner{
        IDambassador++;
        ambassadorID[IDambassador].ID = _ID;
        ambassadorID[IDambassador].ambsdrAddress = _ambsdr;
        ambassadorID[IDambassador].percentage = _percentage;
        ambassadorID[IDambassador].Country = _country;
    }
    function privateSaleA(uint256 _ambassadorID) public payable returns(bool success){
        require(IDambassador > 0,"No ambassadors added!");
        uint256 _eth = msg.value;
        require(_eth > 0 && _eth < limit, "Amount should be greater than Zero and less than limit!");
        uint256 _tkns;
        uint256 forAmbsdr;
        uint256 _ID = ambassadorID[_ambassadorID].ID;
        address ambsdr = ambassadorID[_ambassadorID].ambsdrAddress;
        string memory _country = ambassadorID[_ambassadorID].Country;
        uint256 _percentage = ambassadorID[_ambassadorID].percentage;
       _tkns = (Price.mul(_eth)).div(1 ether);
       forAmbsdr = (_tkns.mul(_percentage)).div(100);
       uint256 totalAmount = _tkns.add(forAmbsdr);
       require(BTK.balanceOf(address(this))> totalAmount, "Insufficient Balance!");
       emit BTKsale(msg.sender, _tkns.div(fractions), forAmbsdr.div(fractions), _ID, _country);
       BTK.transfer(msg.sender, _tkns);
       BTK.transfer(ambsdr, forAmbsdr);
       return true;
    } 
    function withdrawalBTK(uint256 _amount, uint256 decimal, address to) external onlyOwner() {
        ERC20 _tokenAddr = BTK;
        uint256 dcml = 10 ** decimal;
        ERC20 token = _tokenAddr;
        emit WithdrawalBTK( _amount, decimal, to);
        token.transfer(to, _amount*dcml);
    }
    function withdrawalERC20(address _tokenAddr, uint256 _amount, uint256 decimal, address to) external onlyOwner() {
        uint256 dcml = 10 ** decimal;
        ERC20 token = ERC20(_tokenAddr);
        require(token != BTK, "Can't withdraw BTK using this function!");
        emit WithdrawalERC20(_tokenAddr, _amount, decimal, to);
        token.transfer(to, _amount*dcml); 
    }  
    function withdrawalBNB(uint256 _amount, uint256 decimal, address to) external onlyOwner() {
        require(address(this).balance >= _amount);
        uint256 dcml = 10 ** decimal;
        emit WithdrawalBNB(_amount, decimal, to);
        payable(to).transfer(_amount*dcml);      
    }
    receive() external payable {}
}


//********************************************************
// Proudly Developed by MetaIdentity ltd. Copyright 2022
//********************************************************