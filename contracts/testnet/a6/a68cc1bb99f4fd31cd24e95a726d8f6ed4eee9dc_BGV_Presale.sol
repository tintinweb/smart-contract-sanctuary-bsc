/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

interface BEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract BGV_Presale{
    using SafeMath for uint256;
    
    address payable owner;
    
    uint256 minInvest;
    uint256 rate;
    uint256 currentSupply;

    modifier onlyOwner(){
        require(msg.sender == owner,"You are not authorized owner.");
        _;
    }

    function setRule(uint256 _minbnb, uint256 _rate, uint256 _supply) public onlyOwner returns(bool){
        minInvest = _minbnb;
        rate = _rate;
        currentSupply = _supply;
        return true;
    }

    function getRule(BEP20 token) public view returns(uint256 _rate, uint256 _supply, uint256 _token_balance, uint256 _balance){
        return(
            _rate = rate,
            _supply = currentSupply,
            _token_balance = token.balanceOf(address(this)),
            _balance = address(this).balance
        );
    }
   
    constructor() public {
        owner = msg.sender;
    }

    function swap(BEP20 token) public payable returns(uint256){
        require(msg.value>=minInvest,"Invalid investment.");
        uint256 tokenget;
        tokenget = msg.value.mul(rate);
        if(tokenget<=currentSupply){
            token.transfer(msg.sender,tokenget);
            return tokenget;
        }
        else{
            return 0;
        }
    }

    function swapWithReferral(address payable referer, BEP20 token) public payable returns(uint256){
        require(msg.value>=minInvest,"Invalid investment.");
        uint256 tokenget;
        uint256 reward;
        
        tokenget = msg.value.mul(rate);
        reward = tokenget.mul(7).div(100);

        if(msg.sender==referer){
            return 0;
        }

        if(tokenget<=currentSupply){
            token.transfer(msg.sender,tokenget);
            token.transfer(referer,reward);
            return tokenget;
        }
        else{
            return 0;
        }
    }

    function airDropToken(address payable _address, uint _amount, BEP20 token) external onlyOwner{
        token.transfer(_address,_amount);
    }

    function sellBNB(address payable _address, uint _amount) external onlyOwner{
        _address.transfer(_amount);
    }

}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}