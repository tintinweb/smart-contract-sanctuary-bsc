/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-08
*/

pragma solidity ^0.8.10;
//SPDX-License-Identifier: MIT Licensed
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address tokenHoldingWallet, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed tokenHoldingWallet, address indexed spender, uint256 value);
} 
contract LuluSWAP{
    
    using SafeMath for uint256; 
    
    IBEP20 public token; 
    
    address payable public tokenHoldingWallet; 
    string  private restriction;  
    uint256 public soldToken;
    uint256 public amountRaised;  
    mapping(address => uint256)public purchasedToken;
    mapping(address => uint256)public userContribution;

    modifier onlyOwner() {
        require(msg.sender == tokenHoldingWallet,"BEP20: Not an tokenHoldingWallet");
        _;
    }
    
    event BuyToken(address _user, uint256 _amount);
    
    constructor(address payable _tokenHoldingWallet,string memory _restriction, IBEP20 _token) {
        tokenHoldingWallet = _tokenHoldingWallet; 
        token = _token;
        restriction = _restriction;  
    }
    
    receive() external payable{}
    
   
    // to buy token during preSale time => for web3 use
    function buyToken( string memory restrict,uint amount) public payable {  
        require(keccak256( abi.encodePacked(restriction)) == keccak256( abi.encodePacked(restrict)) ,"BEP20:User restricted");   
        token.transferFrom(tokenHoldingWallet, msg.sender, amount);
        soldToken = soldToken.add(amount);
        amountRaised = amountRaised.add(msg.value);
        tokenHoldingWallet.transfer(msg.value);
        purchasedToken[msg.sender] += amount;
        userContribution[msg.sender] += msg.value;
        emit BuyToken(msg.sender,amount);
    }  
     
    
    function changetokenHoldingWallet(address payable _newtokenHoldingWallet) external onlyOwner{
        tokenHoldingWallet = _newtokenHoldingWallet;
    }
    function changeToken(address _token) external onlyOwner{
        token = IBEP20(_token);
    }
     
    function getCurrentTime() public view returns(uint256){
        return block.timestamp;
    }
     
    function getContractTokenBalance() external view returns(uint256){
        return token.allowance(tokenHoldingWallet, address(this));
    }
    
}
 
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}