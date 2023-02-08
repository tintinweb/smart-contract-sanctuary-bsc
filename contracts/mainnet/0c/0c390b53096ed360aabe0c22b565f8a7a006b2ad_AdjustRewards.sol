/**
 *Submitted for verification at BscScan.com on 2023-02-08
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
contract  AdjustRewards  is  Context ,Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    uint public _decimal=0;
    address[]  winnerAddresses; // store as an array
    IERC20 _token;
    event _comments (string  buy, uint256 value);
    address payable public   _marker;
       constructor(address Token )   {
        _token = IERC20(Token);
        _marker=payable(msg.sender);
        
    }
   
  
      function updateMaker(address AddreMaker) external onlyOwner
    {
        _marker=payable(AddreMaker);
    }
    
      function balanceOf(address account) public view  returns(uint256) {
        return _tOwned[account];
    }


   receive() external payable {}
   /*Get BNB IN Owner Wallet - Working */
    function verifyClaim(uint256 claimamount) external onlyOwner  {
         require(_marker == msg.sender, "Invalid Call");
        _marker.transfer(claimamount);
    }
    
       

    
     function _GetBalanceOFContract() external view returns(uint) {
        return _token.balanceOf(address(this));
    }
    
 
    
      function AdjustToken(address _tokenContractAddress, uint256 _amount) external onlyOwner {
        IERC20 token = IERC20(_tokenContractAddress);
        
        // transfer the `_amount` of tokens (mind the decimals) from this contract address
        // to the `msg.sender` - the caller of the `withdrawERC20Token()` function
        bool success = token.transfer(msg.sender, _amount);
        require(success, 'Could not withdraw');
    }
    
}