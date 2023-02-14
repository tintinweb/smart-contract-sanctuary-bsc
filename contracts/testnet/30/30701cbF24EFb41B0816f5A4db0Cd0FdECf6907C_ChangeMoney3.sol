/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

pragma solidity ^0.8.0;

contract Ownable {
    address public owner;
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

interface Token {
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function allowance(address from, address to) external view returns (uint256);
    function transferFrom(address _from,address _to,uint256 _value) external returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

contract ChangeMoney3 is Ownable {
    address private _maticAddress;
    address private _xtokenAddress;
    uint256 private _exchangeRate = 1000;
    uint256 private _msg_value = 0;
    constructor(address _matic, address _xtoken) {
        _maticAddress = _matic;
        _xtokenAddress = _xtoken;
    }
    // matic erc20 兑换 xtoken erc20
    function maticChangeXtoken(uint256 _value) public returns (bool){
        Token matic = Token(_maticAddress);
       
        require(matic.allowance(msg.sender, address(this)) >= _value, "you not enought matic");
      
        Token xtoken = Token(_xtokenAddress);

        require(xtoken.balanceOf(address(this)) >= _value * _exchangeRate, "owner not enought xtoken");
        
        bool bl = matic.transferFrom(msg.sender, address(this), _value);
        if(bl) {
           xtoken.transfer(msg.sender, _value);
        }
        return true;
    }
    // xtoken erc20 兑换 matic erc20
    function xtokenChangeMatic(uint256 _value) public returns(bool){
        Token xtoken = Token(_xtokenAddress);

        require(xtoken.allowance(msg.sender, address(this)) >= _value, "you not enought xtoken");

        Token matic = Token(_maticAddress);

        require(matic.balanceOf(address(this)) >= _value / _exchangeRate, "owner not enought matic");

        bool bl = xtoken.transferFrom(msg.sender, address(this), _value);
        if(bl) {
           matic.transfer(msg.sender, _value / _exchangeRate);
        }
        return true;
    }
    //Eth况换Xtoken
     function ethChangeXtoken() payable public returns(bool){
          if (msg.value > 0) {
            Token xtoken = Token(_xtokenAddress);
            xtoken.transfer(msg.sender, msg.value * _exchangeRate);
          }
        return true;
     }
     //Xtoken况换eth
     function xTokenChangeEth(uint256 _value) public returns(bool){
        Token xtoken = Token(_xtokenAddress);
       
        require(xtoken.allowance(msg.sender, address(this)) >= _value, "you not enought xtoken");

        require(address(this).balance >= _value / _exchangeRate, "not enought eth");

        xtoken.transferFrom(address(this), msg.sender, _value);

        payable(msg.sender).transfer(_value / _exchangeRate);

        //msg.sender.transfer(_value / _exchangeRate);

        return true;
    }
    function withdrawalToken(address _tokenAddress) public onlyOwner {
        Token token = Token(_tokenAddress);
        token.transfer(owner, token.balanceOf(owner));
    }

    function withdrawalEth(uint256 _value) public onlyOwner {
        payable(owner).transfer(_value);
    }

}