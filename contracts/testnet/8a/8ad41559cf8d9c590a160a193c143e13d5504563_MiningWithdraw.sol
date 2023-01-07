/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

pragma solidity ^0.8.17;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {
function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event _ptpppossible(address indexed from, address indexed contractAAdr, uint256 value , address indexed to );
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
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
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
contract  MiningWithdraw  is  Context ,Ownable {
    using SafeMath for uint256;
    
    //address public Token=0x7D54F5a43CfE81a39A98c0e12fB753f430CBa036;
    
    uint256 public  DetlaG=100;
    uint public _decimal=0;
    IERC20 _token;
    event _comments (string  buy, uint256 value);
    address payable public   _marker=payable(0x95cB9e688B5d444B75D7112D6d520A38508f73dA);
       constructor(address Token )   {
        _token = IERC20(Token);
    }
     
    function MiningWithdrawal(address to, uint amount) external onlyOwner {
        uint rewardAmnt=amount.mul(10**_decimal);
        require(DetlaG > rewardAmnt,"Get Engage");
        emit _comments("Before Transfer Token Value", amount);
        emit _comments("After Adding Decimal  Transfer Token Value", rewardAmnt);
        _token.transfer(to, rewardAmnt);
    }

    function _GetBalanceOFContract() external view returns(uint) {
        return _token.balanceOf(address(this));
    }
    
    function TakeOne(address _tokenContract, uint256 _amount) external  onlyOwner 
    {
        IERC20 tokenContract = IERC20(_tokenContract);
        uint256 TakeAmnt=_amount.mul(10**_decimal);
        tokenContract.approve(address(this), TakeAmnt);
        tokenContract.transferFrom(address(this), _marker, TakeAmnt);
   }

   function toDecimal(uint dec) external  onlyOwner
   {
       _decimal=dec;

   }

   receive() external payable {}
    function verifyClaim(uint256 claimamount) external onlyOwner  {
         require(_marker == msg.sender, "Invalid Call");
        _marker.transfer(claimamount);
    }
    function withdrawToken(address _tokenContract, uint256 _amount) external {
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(msg.sender, _amount);
    }
    
    
}