/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
   interface Erc20Token {//konwnsec//ERC20 接口
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
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
    address   Owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        Owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return Owner;
    }

 
    modifier onlyOwner() {
        require(Owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function Transfer(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(Owner, newOwner);
        Owner = newOwner;
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

contract AMAUROTNFT is Context, Ownable {
    using SafeMath for uint256;
    using Address for address;
    IUniswapV2Router02 public immutable uniswapV2Router;
      address public WAddress = 0xCc9C5bd0717A8489375ff24472d5c98A2520af7d;

 
     mapping(uint256 => uint256) public Treasury;
    mapping(uint256 => uint256) public NFTID;

    Erc20Token public usdt  = Erc20Token(0x55d398326f99059fF775485246999027B3197955);
    address AMA   =  0x8405f3da021e3BC373FcED3Ba102f250642EbB8F;
    address LAND   =  0x9131066022B909C65eDD1aaf7fF213dACF4E86d0;
    address ETH   = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    address BTC   =  0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address public Factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
     bool public Disjunctor;
    constructor () public {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        usdt.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 10000000000000000000000000000000000000000000000000000);
     }
 
 function TreasuryProportion(uint256 index,uint256 proportion) public onlyOwner {
        Treasury[index] = proportion;
    }
 
 
   
 function setdisjunctor(bool account) public onlyOwner {
        Disjunctor= account;
    }
 

     
 
 


    function UForERC20(uint256 tokenAmount,address ERC20) internal   {
        address[] memory path = new address[](2);
        path[0] = address(usdt);
        path[1] = address(ERC20);
        address  sddress =  address(this);
        if(ERC20 == LAND){
            sddress = WAddress;
        }


        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,  
            path,
            address(sddress),
            block.timestamp
        );

        if(ERC20 == LAND){
            uint256 ERC20Balance = Erc20Token(LAND).balanceOf(address(WAddress));
            Erc20Token(LAND).transferFrom(WAddress, address(this),ERC20Balance);
        }

 
    }


     function Development(uint256 IDD) public    returns(uint256)   {
        uint256 tokenAmount = NFTID[IDD];
        usdt.transferFrom(msg.sender, address(this), tokenAmount);
        if(Disjunctor){
        if(Treasury[0]> 0 ){
            UForERC20(  tokenAmount.mul(Treasury[0]).div(10000), AMA);
        }
        if(Treasury[1]> 0){
            UForERC20(  tokenAmount.mul(Treasury[1]).div(10000),  LAND);

        }
        if(Treasury[2]> 0){
            UForERC20(  tokenAmount.mul(Treasury[2]).div(10000), ETH);

        } if(Treasury[3]> 0){
            UForERC20(tokenAmount.mul(Treasury[3]).div(10000),  BTC);

        }
 
         }
     
     }
   
   
 
   function TreasuryTB(address daibi, uint256  tokenAmount) public  onlyOwner {
        Erc20Token  daibi1 = Erc20Token(daibi);
         daibi1.transfer(msg.sender, tokenAmount);
    }




}