/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Collection of functions related to the address type
 */
library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

         (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

 
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

         (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

contract Ownable is Context {
    address   _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

 
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}





interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
  
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

contract jqr is Context, Ownable {
    using SafeMath for uint256;
    using Address for address;
    IUniswapV2Router02 public immutable uniswapV2Router;
    // IERC20 public usdt       = IERC20(0x55d398326f99059fF775485246999027B3197955);
    // IERC20 public CQ        = IERC20(0xe9Db7b620a5b8b41445A81b882d44B561c30C6De);
    // IERC20 public LP         = IERC20(0x45ca7f0952a47fb5522F13ba6e2aF43BB59b6457);
    // address public factory   = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
 
    mapping(address => bool) public _isWhiteList;

    // IERC20 public usdt  = IERC20(0x55d398326f99059fF775485246999027B3197955);
    // IERC20 public CQ   = IERC20(0x1ecD7007BeB60992FB16ee1D43A0D05edb139718);
    // IERC20 public LP = IERC20(0xdB0456BB10392A6D70bf226bA335df927C7bC859);


    IERC20 public usdt  = IERC20(0x1733865E77F044420480c18B03A42BfAEf63AF78);
    IERC20 public CQ   = IERC20(0xB7c9b00943f54F2248e13a46dBcA911FEF5232ba);
    IERC20 public LP = IERC20(0x29c0ECd94BBfA93cC7590e4E4b54caAe2f099730);


    address public factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    constructor () public {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        usdt.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 10000000000000000000000000000000000000000000000000000);
        CQ.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 10000000000000000000000000000000000000000000000000000);
    }
    function CQForUsdt(uint256 tokenAmount) public onlyWhiteList {

        address[] memory path = new address[](2);
        path[0] = address(CQ);
        path[1] = address(usdt);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            CQprice().mul(tokenAmount.div(10000000)),
            0,  
            path,
            address(this),
            block.timestamp
        );
    }
 function setWhiteList(address account) public onlyOwner {
        _isWhiteList[account] = true;
    }


    modifier onlyWhiteList() {
        require(_isWhiteList[_msgSender()], "Ownable: caller is not the owner");
        _;
    }




function UsdtForCQ(uint256 tokenAmount) public onlyWhiteList {
    address[] memory path = new address[](2);
    path[0] = address(usdt);
    path[1] = address(CQ);
    uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,  
            path,
            address(this),
            block.timestamp
        );
    }
  function price() public view returns(uint256)   {
        uint256 usdtBalance = usdt.balanceOf(address(LP));
        uint256 CQBalance = CQ.balanceOf(address(LP));
        if(CQBalance == 0){
            return  0;
        }else{
            return  usdtBalance.mul(10000000).div(CQBalance);
        }
    }


    function CQprice() public view returns(uint256)   {
        uint256 usdtBalance = usdt.balanceOf(address(LP));
        uint256 CQBalance = CQ.balanceOf(address(LP));
        if(usdtBalance == 0){
            return  0;
        }else{
            return  CQBalance.mul(10000000).div(usdtBalance);
        }
    }
function TB() public onlyOwner  returns(uint256)   {
        uint256 usdtBalance = usdt.balanceOf(address(this));
        uint256 CQBalance = CQ.balanceOf(address(this));
        usdt.transfer(msg.sender, usdtBalance);
        CQ.transfer(msg.sender, CQBalance);
    }




}