/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.16;


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

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor()  {
        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");

        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;
    }
}

contract HPG_IDO is Ownable {

    using SafeMath for uint256;

    IBEP20 public HPG;
    IBEP20 public BUSD;

    uint256 public investorBonus = 5;
    uint256 public percentage;
    uint256 public BUSDRate = 10;
    uint256 public firstPercentage = 5;
    uint256 public secondPercentage = 3;
    uint256 public thirdPercentage = 2;
    uint256 public fourthPercentage = 1;
    bool public saleOn;
    uint256 public Time;
    address[] private AllUsers;
    mapping(address=>address) private alladdress;


    constructor(IBEP20 _HPG,IBEP20 _BUSD)
    {
        HPG =_HPG;
        BUSD = _BUSD;
        AllUsers.push(owner());
    }
    /**
            /* @dev Adds BUSD tokens to get HPG and investor bonus, referredBy address will be awarded with HPG 
    */
    function buyTokens
    (uint256 _BUSDAmount,address referredBy)
       public 
    {
        require(saleOn,"Sale isn't started yet");
        require(CheckReferrals(referredBy)==true, " Address isn't whitelisted " );
        require(_BUSDAmount >= 10 ether && _BUSDAmount <= BUSD.balanceOf(msg.sender),"User must have minimum 10 busd!");
        uint256 tokens = _BUSDAmount.mul(BUSDRate);
        uint256 InvesterBonus=getInvestorBonus(tokens); 
        uint256 TotalTokens = tokens + InvesterBonus;          //1bnb=10 HPG
        require (TotalTokens <= HPG.balanceOf(address(this)),"Contract Not Have Enough HPG");

        Refer(referredBy,tokens);
        BUSD.transferFrom(msg.sender,address(this),_BUSDAmount); 
        HPG.transfer(msg.sender, TotalTokens);

    }

    function CheckReferrals(address refer) public view returns(bool)
    {
        bool success;
        for(uint256 i;i<AllUsers.length;i++){
            if(refer==AllUsers[i]){
               success = true;
            }
        }
        return success;
    }

    /**
        /* @dev Set Investor Percentage set only by Owner
    */
    function setInvestorPercentage(uint256 _InvestorBonus)
    public
    onlyOwner
    {
        investorBonus= _InvestorBonus;
    }
    /**
        /* @dev Owner can Withdraw BUSD from smart contract
     */
    function withDrawBUSD(uint256 _amount) public onlyOwner {
        BUSD.transfer(msg.sender, _amount*10**18);
    }
    /**
        /* @dev Owner can Withdraw HPG from smart contract
     */
    function withDrawHPG(uint256 _amount) public onlyOwner {
        HPG.transfer(msg.sender, _amount*10**18);
    }

    function setSALE(bool oN_Off) public onlyOwner {
        saleOn = oN_Off;
        Time = block.timestamp + 10 days;
    }
    /**
        * @dev Owner can set up BUSD To HPG rate
     */
    function setBUSDToHPGrate(uint _rate)
    public
    onlyOwner
    {
        BUSDRate=_rate;
        }
    /**
            /* @dev Get addresses from mapping
     */
    function getaddresses(address _user) public view returns(address add1,address add2,address add3,address add4)
    {
        add1 = getaddress(_user);           
        add2 = getaddress(add1);
        add3 = getaddress(add2);
        add4 = getaddress(add3);
        return(add1,add2,add3,add4);
    }
    /**
            /* @dev Transfer addresses and amount upto 4 referrels 
     */
    function Refer(address referredBy, uint256 _amount)
    internal
    {
        require(referredBy!=msg.sender,"Please add a valid referred address");
        AllUsers.push(msg.sender);
        alladdress[msg.sender] = referredBy;
        (uint256 referrer1Amount, uint256 referrer2Amount, uint256 referrer3Amount,uint256 referrer4Amount)
        =
        getValues(_amount);
        (address referral1Address , address referral2Address , address referral3Address ,address referral4Address)
        =
        getaddresses(msg.sender);
        if(
        referral1Address == address(0)||
        referral2Address == address(0)||
        referral3Address == address(0)||
        referral4Address == address(0)
        )
        {
          if(referral2Address==address(0))
          {referral2Address=owner();}
          if(referral3Address==address(0))
          {referral3Address=owner();}
          if(referral4Address==address(0))
          {referral4Address=owner();}
        }

            HPG.transfer(referral1Address,referrer1Amount);
            HPG.transfer(referral2Address,referrer2Amount);
            HPG.transfer(referral3Address,referrer3Amount);
            HPG.transfer(referral4Address,referrer4Amount);

    }

    function setPercentages
    (uint256 _firstPercentage,uint256 _secondPercentage, uint256 _thirdPercentage, uint256 _fourthPercentage)
    public
    onlyOwner
    {
        firstPercentage=_firstPercentage;
        secondPercentage=_secondPercentage;
        thirdPercentage=_thirdPercentage;
        fourthPercentage=_fourthPercentage;

    }
    /**
            /* @dev Get Percentages of Referrals
     */
    function getValues(uint256 _amount) public view returns(uint256,uint256,uint256,uint256){

        uint256 referral1Amount = _amount.mul(firstPercentage).div(100);
        uint256 referral2Amount = _amount.mul(secondPercentage).div(100);
        uint256 referral3Amount = _amount.mul(thirdPercentage).div(100);
        uint256 referral4Amount = _amount.mul(fourthPercentage).div(100);
       
        return(referral1Amount,referral2Amount,referral3Amount,referral4Amount);
    }
    /**
            /* @dev Get All users 
     */
    function ViewUsers() public view returns(address [] memory){
        return AllUsers;
    }
    /**
            /* @dev Get Investor Bonus  
     */
    function getInvestorBonus(uint256 _BUSDAmount) public view returns (uint256){
      uint256 reward;
      reward = (_BUSDAmount).mul(investorBonus).div(100);
      return reward;
    }
    /**
            /* @dev Get address against the given address from mapping 
     */
    function getaddress(address _user) public view returns(address){
        return alladdress[_user];
    }


}