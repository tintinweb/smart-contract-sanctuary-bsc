/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

interface BEP20 {
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address to, uint value) external returns (bool success);
    function transferFrom(address from, address to, uint _value) external returns (bool success);
    function approve(address spender, uint value) external returns (bool success);
    function allowance(address owner, address spender) external view returns (uint remaining);
    event Transfer(address indexed from, address indexed to, uint _value);
    event Approval(address indexed owner, address indexed spender, uint _value);
}

contract TestScHrGame{
    //address payable[] winners;
    address public owner;
    address public admin;
    mapping(string => mapping(string => mapping(address => bool))) win;
    mapping(string => string) gameIdWinHorseId;
    

    modifier winners(address _addr, string memory _gameId){
        require(win[_gameId][gameIdWinHorseId[_gameId]][_addr] == true, "You are not the winner ");
        _;
    }

     modifier onlyAdmin() {
        require(msg.sender == admin, "You are not the Admin");
        _; 
    }

    modifier onlyOwner(){
        require(isOwner(), "You are not the owner");
        _;
    }

    constructor(){
        owner = msg.sender;
        admin = msg.sender;
    }

    BEP20 token = BEP20(0x97De951eDbFed50a0c80ffA61Ce06Ec7c62Bf70e); 

    function isOwner() public view returns(bool){        
        return (msg.sender == owner);
    } 

    function TransfertoCtoU(address _to, uint _amount, string memory _gameId) external winners(_to, _gameId){
        token.transfer(_to, _amount);
        //winners.pop();  
        //require(gameId == _gameId);
        win[_gameId][gameIdWinHorseId[_gameId]][_to] = false;
    }

    function transferFromUtoC(uint amount, string memory _gameId, string memory horseId) external {
        token.transferFrom(msg.sender, address(this), amount);
        win[_gameId][horseId][msg.sender] = true;
    }

    
    function balanceOf(address _addr) external view onlyOwner returns(uint){
        return token.balanceOf(_addr);
    } 

    function setID(string memory _gameId, string memory _horseId) external onlyAdmin(){
        gameIdWinHorseId[_gameId] = _horseId;
    }

    function transferOwnership(address _newOwner) external onlyOwner(){
        owner = _newOwner;
    }

    function setAdmin(address _admin) external onlyOwner(){
        admin = _admin;
    }


    function gethorseWin(string memory _gameId) external view returns(string memory){
        return gameIdWinHorseId[_gameId];
    }

    function withdrawTokens(address _to, uint _amount) external onlyOwner(){
         token.transfer(_to, _amount);

    }
}