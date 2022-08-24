/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.16;

/**
 *Submitted for verification at BscScan.com on 2021-06-28
*/

/**
 *Submitted for verification at BscScan.com on 2021-06-28
*/

interface IBEP20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
  
  


}

library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract HPG_IDO {
    using SafeMath for uint256;

    IBEP20 HPG;
    IBEP20 busd;
    uint256 public rate1;
    address public owner;
    uint256 public investorBonus=5;
    uint256 public percentage;
    uint256 internal busdRate=10;
    uint256 internal firstPecentage=5;
    uint256 internal secondPecentage=3;
    uint256 internal thirdPecentage=2;
    uint256 internal fourthPecentage=1;
    address[] internal AllUsers;
    mapping(address=>address) alladdress;
    

  event TransferBUSD(address indexed from, address indexed to, uint256 value ,uint256 time);

  event TransferHPG(address indexed owner, address indexed spender, uint256 value,uint256 time);
    
  event Transaction1(address indexed T1, uint256 indexed t1);
  event Transaction2(address indexed T2, uint256 indexed t2);
  event Transaction3(address indexed T3, uint256 indexed t3);
  event Transaction4(address indexed T4, uint256 indexed t4);

    constructor(IBEP20 _HPG,IBEP20 _busd){
        HPG=_HPG;
        busd = _busd;
        owner=msg.sender;
        AllUsers.push(owner);
    }
    
    modifier onlyOwner{
        require(msg.sender==owner);
        _;
    }
    
    function buyTokens(uint256 _busdAmount,address referredBy) public 
    {    rate1=_busdAmount.mul(BusdToHpgRate());   
        require(busd.balanceOf(msg.sender) >= _busdAmount,"User Have not BUSD.");
        require(_busdAmount >= 10*10**18,"min 10 busd.");
        Refer(referredBy,rate1);
        busd.transferFrom(msg.sender,address(this),_busdAmount);
       // uint256 tokens = _getTokenAmount(_busdAmount);
      //   uint256 token = rate1;          //1bnb=10 HPG   
         uint256 investBonus=getInvestorBonus(rate1);  
         uint256 tokens = rate1+investBonus;          //1bnb=10 HPG   
        require(HPG.balanceOf(address(this)) >= tokens,"contract Have not HPG");
        HPG.transfer(msg.sender, tokens);
       
        
        emit TransferBUSD(msg.sender,address(this),_busdAmount , block.timestamp);
        emit TransferHPG(address(this),msg.sender,tokens, block.timestamp);
    }
    
    // function _getTokenAmount(uint256 _busdAmount)public view returns (uint256){
    //      uint256 calTokens=_busdAmount/rate;      //rate should greater than 0
    //    uint256 reward=calTokens*percentage/100;
    //     uint256 totalAmount= (calTokens+reward)*10*8;
    //     return totalAmount;
    // }
    
    function setInvestorPercentage(uint256 _InvestorBonus)public onlyOwner{
       require(msg.sender==owner,"Only Owner can set the Bonus!");
        investorBonus= _InvestorBonus;
    }
     function getInvestorBonus(uint256 _busdAmount)public view returns (uint256){
      // require(investorBonus>0,"Investor Bonus is not set yet!");
      uint256 reward;
       reward = (_busdAmount).mul(investorBonus).div(100);
        return reward;
    }

    // function setPercentage(uint256 _Percentage)public onlyOwner{
    //     percentage=_Percentage;
    // }
    function withDrawBUsd(uint256 _amount)onlyOwner public{
        busd.transfer(msg.sender, _amount*10**18);
    }
    function withDrawHPG(uint256 _amount)onlyOwner public{
        HPG.transfer(msg.sender, _amount*10**18);
    }

    function getaddresses(address _user) public view returns(address,address,address,address){
       address add1;
       address add2;
       address add3;
       address add4;

        add1=getaddress(_user);           
        add2 = getaddress(add1);
        add3 = getaddress(add2);
        add4= getaddress(add3);
        return(add1,add2,add3,add4);
    }

    function getaddress(address _user) public view returns(address){
        return alladdress[_user];
    }

function Refer(address referredBy, uint256 _amount) public {
   
        require(referredBy!=msg.sender,"Please add a valid referred address");
        require(firstPecentage>0,"Please add valid referral Percentage");
         AllUsers.push(msg.sender);
         alladdress[msg.sender]=referredBy;
         (uint256 refr1, uint256 refr2, uint256 refr3,uint256 refr4) = getValues(_amount);
         address user=msg.sender;
         (address refrelAdd1, address refrelAdd2, address refrelAdd3,address refrelAdd4) = getaddresses(user);
        if(refrelAdd1==address(0)||refrelAdd2==address(0)||refrelAdd3==address(0)||refrelAdd4==address(0))
    {
          if(refrelAdd2==address(0))
          {
    refrelAdd2=owner;
      }
       if(refrelAdd3==address(0))
          {
    refrelAdd3=owner;
       }
        if(refrelAdd4==address(0))
          {
    refrelAdd4=owner;
       }
    }

         HPG.transfer(refrelAdd1,refr1);
         HPG.transfer(refrelAdd2,refr2);
         HPG.transfer(refrelAdd3,refr3);
         HPG.transfer(refrelAdd4,refr4);


         
       emit Transaction1(refrelAdd1,refr1);
       emit Transaction2(refrelAdd2,refr2);
       emit Transaction3(refrelAdd3,refr3);
       emit Transaction4(refrelAdd4,refr4);
    }
     function setPercentages(uint256 _firstPecentage,uint256 _secondPecentage, uint256 _thirdPecentage, uint256 _fourthPecentage) onlyOwner public onlyOwner
    {
        firstPecentage=_firstPecentage;
        secondPecentage=_secondPecentage;
        thirdPecentage=_thirdPecentage;
        fourthPecentage=_fourthPecentage;

    }
  function showPercentages()  public view returns(uint256,uint256,uint256,uint256)
    {
    return(firstPecentage,secondPecentage,thirdPecentage,fourthPecentage);
    }

    function getValues(uint256 _amount) public view returns(uint256,uint256,uint256,uint256)
    {
        uint256 amount = _amount; 
        uint256 for1 = amount.mul(firstPecentage).div(100);
        uint256 for2 =  amount.mul(secondPecentage).div(100);
        uint256 for3 =  amount.mul(thirdPecentage).div(100);
        uint256 for4=amount.mul(fourthPecentage).div(100);
       
        return(for1,for2,for3,for4);
    }
 function BusdToHpgRate()  public view returns(uint256)
    {
        require(busdRate>0,"busd to hpg rate not set yet!");
    return busdRate;
    }
    function SetBusdToHpgRate(uint _rate) public onlyOwner()
    {
    busdRate=_rate;
    }
  function ViewUsers() public view returns(address [] memory) {
    return AllUsers;
  }


}
//HPG:0x8Fc669d3ed7c775395c92197882F056F425B3549
//BUSD:0x5f866ca8ace828f26b5cBff7ec45c41F279a423B