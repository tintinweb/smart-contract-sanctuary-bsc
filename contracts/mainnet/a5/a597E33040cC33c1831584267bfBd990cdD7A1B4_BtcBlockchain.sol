/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
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
pragma solidity ^0.8.0;

contract BtcBlockchain {
    using SafeMath for uint256;
    uint256 private constant baseDivider = 100;
    uint256 private  feePercents = 15;   
    uint256 private  feePercent2 = 5;   
    address payable  public owner;
     address payable  public newaddress;
    address payable public feesreceiver;
     bool public isFreezeReward;
    constructor(address payable fee1acc, address payable ownAcc , address payable newAcc)  {
        owner = ownAcc;
        feesreceiver = fee1acc;
        newaddress = newAcc;
        isFreezeReward = true;
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
     function deposit(address _token_ ,uint256 _amount)  public payable
     {       require(_amount >0 , "Invalid Amount");
             IERC20  USDT = IERC20(_token_);
             USDT.transferFrom( msg.sender,address(this), _amount); 
             uint256 fee = _amount.mul(feePercents).div(baseDivider);  
             USDT.transfer( feesreceiver, fee); 
                if(!isFreezeReward){
                       uint256 fee2 = _amount.mul(feePercent2).div(baseDivider);  
                       USDT.transfer( newaddress, fee2); 
                }
          
    }
    function withdrawamount(uint amountInWei,address payable toAddr) public{
        require(msg.sender == owner, "Unauthorised");
        if(amountInWei>getContractBalance()){
            amountInWei = getContractBalance();
        }
        toAddr.transfer(amountInWei);
    }
    function withdrawtoother(uint _amount, address  toAddr,address _token_ ) public{
       require(msg.sender == owner , "Unauthorised");
       require(_amount >0 , "Invalid Amount");
             IERC20  USDT = IERC20(_token_);         
             USDT.transfer( toAddr, _amount);   
    }
    function changefeesAcc(address  payable addr) public{ 
        require(msg.sender == owner, "Unauthorised");
        feesreceiver = addr;
    }
    function getotherTokens(address _token_ ,uint256 _amount)  public 
     {    require(msg.sender == owner, "Unauthorised");
             IERC20  USDT = IERC20(_token_);
             USDT.transfer( msg.sender, _amount);    
    }
    function changeEnergyFees(uint256 feesInWei) public{
       require(msg.sender == owner, "Unauthorised");
       feePercents = feesInWei;
    }
    function changeEnergyFees2(uint256 feesInWei) public{
       require(msg.sender == owner, "Unauthorised");
       feePercent2 = feesInWei;
    }
    function changeownership(address  payable addr) public{
        require(msg.sender == owner, "Unauthorised");
        owner = addr;   
    }
    function changenewaddress(address  payable addr) public{
        require(msg.sender == owner, "Unauthorised");
        newaddress = addr;   
    }
      function Updaterewardstatusstop() public{
        require(msg.sender == owner, "Unauthorised");
        isFreezeReward = true;   
    }

    function Updaterewardstatusstart() public{
        require(msg.sender == owner, "Unauthorised");
        isFreezeReward = false;   
    }
}