/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
interface IERC20 
{
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

contract ENFT_BUY_PRODUCT {
    using SafeMath for uint256;
    address public  ceoWallet;
    address   authAddress;
    uint256 public totalPercentage=10;
  
    IERC20 USDT;
    struct User
    {
        address upline;
    }
    mapping (address=>User) users;
    event BuyOrder(address indexed user, string packageId,uint256 amount,string userId); 
    event BuyPower(address indexed user, string packageId,uint256 amount,string userId,string shoesId); 

    constructor(address payable ceoAddr,address payable  _authAddress) {
        ceoWallet = ceoAddr;
        authAddress = _authAddress;
        USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
         }

    modifier onlyOwner {
      require(msg.sender == ceoWallet,"Invalid User");
      _;
   }

   function refPercents(uint256 _totalPercentage) external onlyOwner
   {
       totalPercentage = _totalPercentage;
   }

   function buyOrder(uint256 amount,string memory orderId,string memory userId) external 
   {
        USDT.transferFrom(msg.sender,address(this), amount);
        USDT.transfer(authAddress, amount*totalPercentage/100);
        emit BuyOrder(msg.sender,orderId,amount,userId);
   }

   function buyPower(uint256 amount,string memory orderId,string memory userId,string memory shoesId) external 
   {
        USDT.transferFrom(msg.sender,address(this), amount);
        USDT.transfer(authAddress, amount*totalPercentage/100);
        emit BuyPower(msg.sender,orderId,amount,userId,shoesId);
   }

    function withdrawUSDT(address userAddress,uint256 amount) external onlyOwner
    {
        USDT.transfer(userAddress, amount);
    }

    function setAuthAddress(address _authAddress) external onlyOwner
    {
        authAddress = _authAddress;
    }

   
}