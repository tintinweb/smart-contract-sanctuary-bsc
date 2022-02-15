/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

contract BEP20 {

    uint256 public totalSupply;
    string public tokenName;
    string public tokenSymbol;
    uint public decimals; //a small fraction of the token
    address payable public tokenOwner; 

    mapping(address => uint256) public balanceOf;
    //outer address will be owner of token
    //with each token owner we map a spender with a value that he can spend
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approve(address indexed owner, address indexed spender, uint256 value);

    constructor(){

        tokenName = "MY_BEP20";
        tokenSymbol = "MBEP";
        decimals = 18;
        totalSupply = 100000;

        tokenOwner = payable(msg.sender);
        balanceOf[tokenOwner] = totalSupply;

        emit Transfer(address(0), msg.sender, totalSupply);

    }
    
    function getOwner() public view returns (address){
        return tokenOwner;
    }

    function transferToken(address receiver, uint256 value) public returns (bool) {
        
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 receiverBalance = balanceOf[receiver];

        require(receiver != address(0), "provide correct address");
        require(value > 0, "please provide greater than 0");
        require(senderBalance > value, "insufficient sender balance");

        balanceOf[msg.sender] = senderBalance - value;
        balanceOf[receiver] = receiverBalance + value;

        emit Transfer(msg.sender, receiver, value);

        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        require(value > 0, "Value must be greater than 0");
        allowance[msg.sender][spender] = value;
        emit Approve(msg.sender, spender, value);
        return true;

    }

    function transferFrom(address _tokenOwner, address receiver, uint256 value) public returns (bool){

        uint256 tokenOwnerBalance = balanceOf[_tokenOwner];
        require(receiver != address(0), "receiver address incorrect");
        require(value > 0, "please provide greater than 0");
        require(tokenOwnerBalance >= value, "insufficient sender balance");
        require(allowance[_tokenOwner][msg.sender] >= value, "allowance must be greater than value");

        balanceOf[_tokenOwner] -= value;
        allowance[_tokenOwner][msg.sender] -= value;
        balanceOf[receiver] += value;
        

        emit Transfer(_tokenOwner, receiver, value);
        return true;

    }

    function mint(uint256 amountOfTokens) public returns (bool){

        require(msg.sender == tokenOwner, "You must be an owner to mint more tokens");
        totalSupply += amountOfTokens;
        balanceOf[msg.sender] += amountOfTokens;
        emit Transfer(address(0), msg.sender, amountOfTokens);
        return true;

    }

    function burn(uint256 amountOfTokens) public returns (bool) {

        require(msg.sender != address(0), "Burn recepient can't be 0 address");
        uint256 accountBalanceSender = balanceOf[msg.sender];
        require(accountBalanceSender > amountOfTokens, "The number of tokens you want to burb must be lesser than the balance");
        balanceOf[msg.sender] = accountBalanceSender - amountOfTokens;
        totalSupply -= amountOfTokens;
        emit Transfer(msg.sender, address(0), amountOfTokens);
        return true;

    }

    function Allowance(address owner, address spender) public view returns (uint256) {
        return allowance[owner][spender];
    }

}