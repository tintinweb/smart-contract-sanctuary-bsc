// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract TokenManager{
struct Token{
    string Ticker;
    address TokenAddress;
}
address public admin;
mapping(string=>Token) public tokens;
string[] public tokenList;

constructor()  {
    admin=msg.sender;

}

function getTokenAddress(string memory ticker) public view returns(address ){ 
    return tokens[ticker].TokenAddress;   
}

function getTokenList() public view returns(string[] memory){ 
    return tokenList;   
}

modifier onlyAdmin(){
    require(msg.sender==admin,"Unauthorized");
    _;
}

function addToken(string memory tiker,address tokenaddress)  public onlyAdmin() {
    tokens[tiker]=Token(tiker,tokenaddress);
    tokenList.push(tiker);
}

}