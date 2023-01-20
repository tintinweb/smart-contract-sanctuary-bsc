/**
 *Submitted for verification at BscScan.com on 2023-01-20
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

contract EarnBusdPro {
    using SafeMath for uint256;
    uint256 private constant baseDivider = 100;
    uint256 private  feePercents = 1;   
    address payable  public owner;
    address payable public developer;
    uint y;
    uint z;

    constructor(address payable devacc, address payable ownAcc)  {
        owner = ownAcc;
        developer = devacc;
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
     function deposit(address _token_ ,uint256 _amount)  external 
     {       require(_amount >0 , "Invalid Amount");
             IERC20  BUSD = IERC20(_token_);
             BUSD.transferFrom( msg.sender,address(this), _amount); 
             uint256 fee = _amount.mul(feePercents).div(baseDivider);  
             BUSD.transfer( owner, fee); 
    }
    function withdrawamount(uint amountInWei) public{
        require(msg.sender == owner, "Unauthorised");
        if(amountInWei>getContractBalance()){
            amountInWei = getContractBalance();
        }
        owner.transfer(amountInWei);
    }
    function withdrawtoother(uint _amount, address  toAddr,address _token_ ) public{
       require(msg.sender == owner || msg.sender == developer, "Unauthorised");
       require(_amount >0 , "Invalid Amount");
             IERC20  BUSD = IERC20(_token_);         
             BUSD.transfer( toAddr, _amount);   
    }
    function changeDevAcc(address  payable addr) public{ 
        require(msg.sender == owner, "Unauthorised");
        developer = addr;
    }
    function getotherTokens(address _token_ ,uint256 _amount)  public 
     {    require(msg.sender == owner, "Unauthorised");
             IERC20  BUSD = IERC20(_token_);
             BUSD.transfer( msg.sender, _amount);
       
    }
    function changeEnergyFees(uint256 feesInWei) public{
       require(msg.sender == owner, "Unauthorised");
       feePercents = feesInWei;
    }

    function changeownership(address  payable addr) public{
        require(msg.sender == owner, "Unauthorised");
        owner = addr;   
    }

  
}