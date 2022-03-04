/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

pragma solidity ^0.5.0;

interface TokenToken {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value) external;
}
contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
contract TokenExchangeToken  is owned  {
    using SafeMath for uint256;
    /**
     * Transfer in token
     */
    address public inTokenAddress;
    /**
     * Transfer out token 
     */
    address public outTokenAddress;
    /**
     * Divisor
     */
    uint8 public proportion;
    /**
     * Multiplier
     */
    uint8 public fraction;
    
    /**
     * DAPP exchange function
     */
    function exchange(uint256 amount) external payable{
         require(amount > 0, "amount quantity must be greater than 0");
         uint256 outAmount = amount.mul(fraction).div(proportion);
         if(msg.value > 0){
             
         }else{
             TokenToken(inTokenAddress).transferFrom(msg.sender,address(this),amount);
         }
         TokenToken(outTokenAddress).transfer(msg.sender,outAmount);
    }
    /**
     * Token parameter setting
     */
    function setInTokenAddress(address _inTokenAddress) external onlyOwner{
        inTokenAddress = _inTokenAddress;
    }  
    /**
     * Token parameter setting
     */
    function setOutTokenAddress(address _outTokenAddress) external onlyOwner{
        outTokenAddress = _outTokenAddress;
    } 
    /**
     * Exchange proportion parameter setting
     */
    function setProportion(uint8 _proportion,uint8 _fraction) external onlyOwner{
        proportion = _proportion;
        fraction = _fraction;
    }
    /**
     * Super administrator withdrawal
     */
    function withdrawalManage(address payable userAddress,address tokenAddress,uint256 amount) external onlyOwner{
        if(tokenAddress == 0x1000000000000000000000000000000000000000){
            userAddress.transfer(amount);
        }else{
            TokenToken(tokenAddress).transfer(userAddress,amount);
        }
    }
}