/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// SPDX-License-Identifier: non
pragma solidity ^0.8.10;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

contract MVPStake{
  struct Tariff {
    uint time;
    uint percent;
  }
  
  struct Deposit {
    uint tariff;
    uint amount;
    uint at;
    uint amountUsd;
    uint apyPerSecond;
    bool initiateUnstake;
    uint initiateUnstakeAt;
    bool unstake;
    uint unstakeAt;
    uint apyPaidAt;
    uint apyPercent;
}
  
  struct Investor {
    bool registered;
    Deposit[] deposits;
    uint invested;
    uint investedUsd;
    uint apyAmount;
    uint withdrawn;
  }

   using SafeMath for uint256;  
 
  address public owner = msg.sender;
  
  Tariff[] public tariffs;
  uint public totalInvestors;
  uint public totalInvested;
  uint public totalWithdrawal;
  //uint oneDay = 86400;
  uint oneDay = 3600;
  address public token1 = 0xf50B0a35EfdF8F247625E2A0695D56a63b30B7ff;
  IERC20 public stakeToken;
  //uint coolingPeriod = 7;
  uint coolingPeriod = 1;
  mapping (address => Investor) public investors;

  
  event DepositAt(address user, uint tariff, uint amount);
  event Withdraw(address user, uint amount);
  event TransferOwnership(address user);
  

  
  
  constructor()  {

    //tariffs.push(Tariff(180 * oneDay, 20));
    tariffs.push(Tariff(6 * oneDay, 20));
    stakeToken = IERC20(token1);
  }
  
  function updateTariffPercent(uint _percent) external {
      require(msg.sender == owner);
      tariffs[0].percent = _percent;
  }

  
  function stake(uint256 amount) external {
   
    require(amount >= 1, "stake more than minimum amount");
    require(stakeToken.allowance(msg.sender,address(this))>=amount,"Insufficient allowance");
    stakeToken.transferFrom(msg.sender,address(this),amount);
    uint tariff = 0;
  	if (!investors[msg.sender].registered) {
      investors[msg.sender].registered = true;
      totalInvestors++;
      
    }
		
	
	investors[msg.sender].invested += amount;
    uint256 M1VERSEVAL = getPriceinUSD();

    uint investedUsd = (amount.mul(M1VERSEVAL)).div(1e18);
    investors[msg.sender].investedUsd += investedUsd;

	totalInvested += amount;
    Tariff storage tariffData = tariffs[tariff];
	uint apyPerSecond = 	tariffData.percent*(1e18)/tariffData.time;
	investors[msg.sender].deposits.push(Deposit(tariff, amount, block.timestamp,investedUsd,apyPerSecond,false,0,false,0,0,tariffData.percent));
		
	emit DepositAt(msg.sender, tariff, amount);
	
  }
  
  function withdrawable(address user,uint i) public view returns (uint amount) {
    Investor storage investor = investors[user];
    
    
      Deposit storage dep = investor.deposits[i];
      Tariff storage tariff = tariffs[dep.tariff];
      
      uint finish = dep.at + tariff.time;
      uint since = dep.apyPaidAt > dep.at ? dep.apyPaidAt : dep.at;
      uint till = dep.initiateUnstake==true ? dep.initiateUnstakeAt : (block.timestamp > finish ? finish : block.timestamp);

      if (since < till) {
        amount += dep.amountUsd * (till - since) * (dep.apyPerSecond) / 100 / (1e18) ;
      }
    
  }

  function withdrawApy (uint i) external {
    Investor storage investor = investors[msg.sender];
    
    uint amount = withdrawable(msg.sender,i);
    uint256 M1VERSEVAL = getPriceinUSD();
    uint amountToken =    amount.mul(1e9).div(M1VERSEVAL);
    stakeToken.transfer(msg.sender,amountToken);
        investor.deposits[i].apyPaidAt = block.timestamp;
        investors[msg.sender].apyAmount += amountToken;
        totalWithdrawal +=amountToken;
        emit Withdraw(msg.sender, amountToken);
   
 }
  
   
    function initiateUnstakeFunc (uint i) external {
        require(investors[msg.sender].deposits[i].initiateUnstake==false,"already initiated");
        investors[msg.sender].deposits[i].initiateUnstake = true;
        investors[msg.sender].deposits[i].initiateUnstakeAt = block.timestamp;
    }
  
    function unstakeFunc(uint i) external{
        address  user = msg.sender;
        require(investors[user].deposits[i].initiateUnstake==true,
                "initiate Unstake First");
        require(investors[user].deposits[i].unstake==false,
        "already unstaked");
        uint coolingTimeCalculate = block.timestamp - investors[user].deposits[i].initiateUnstakeAt;
        require(coolingTimeCalculate  >= (coolingPeriod*oneDay),"Cooling Period not completed");
        
        uint256 M1VERSEVAL = getPriceinUSD();
        
        uint apyAmount = withdrawable(user,i);  
        uint apyAmountToken = apyAmount.mul(1e18).div(M1VERSEVAL);
        
        uint unstakeAmt = investors[user].deposits[i].amountUsd;
        uint unstakeAmtToken = unstakeAmt.mul(1e18).div(M1VERSEVAL);

        uint amountToken = apyAmountToken.add(unstakeAmtToken);  
        stakeToken.transfer(user,amountToken);
        investors[user].deposits[i].unstake=true;
        investors[user].deposits[i].unstakeAt=block.timestamp;
        investors[user].deposits[i].apyPaidAt=block.timestamp;
        investors[user].apyAmount += apyAmountToken;
        investors[user].withdrawn += unstakeAmtToken;
    }
  


     
    function userData(address addr) public view returns(uint totalStakeAmt,
                                                        uint totalUnStakeAmt,
                                                        uint totalApyAmt,            
                                                        uint[] memory stakeAmt,
                                                        uint[] memory stakeUsdAmt,
                                                        uint[] memory stakeAt,
                                                        uint[] memory gainApy,
                                                        bool[] memory coolingStatus,
                                                        uint[] memory coolingStatusAt,
                                                        bool[] memory unstakeStatus,
                                                        uint[] memory stakeApyPercent
                                                        ) {
        totalStakeAmt = investors[addr].investedUsd;
        totalUnStakeAmt = investors[addr].withdrawn;
        totalApyAmt = investors[addr].apyAmount;
        
        uint len = investors[addr].deposits.length;
        stakeAmt = new uint[](len);
        stakeUsdAmt = new uint[](len);
        stakeAt = new uint[](len);
        gainApy = new uint[](len);
        coolingStatus = new bool[](len);
        coolingStatusAt = new uint[](len);
        unstakeStatus = new bool[](len);
        stakeApyPercent = new uint[](len);
        for(uint i = 0; i < len; i++){

            stakeAmt[i] = investors[addr].deposits[i].amount;
            stakeUsdAmt[i] = investors[addr].deposits[i].amountUsd;
            stakeAt[i] = investors[addr].deposits[i].at;
            gainApy[i] = withdrawable(addr,i);
            coolingStatus[i] = investors[addr].deposits[i].initiateUnstake;
            coolingStatusAt[i] = investors[addr].deposits[i].initiateUnstakeAt;
            unstakeStatus[i] = investors[addr].deposits[i].unstake;
            stakeApyPercent[i] = investors[addr].deposits[i].apyPercent;

        }
        return (totalStakeAmt,
                totalUnStakeAmt,
                totalApyAmt,
                stakeAmt,
                stakeUsdAmt,
                stakeAt,
                gainApy,
                coolingStatus,
                coolingStatusAt,
                unstakeStatus,
                stakeApyPercent);
    }


    function userApyPerSecond(address addr,uint index) public view returns(uint totalStakeAmt) {
     
        
        totalStakeAmt = investors[addr].deposits[index].apyPerSecond;
        
    }

    





  
  function withdrawalToAddress(address payable to,uint amount) external {
        require(msg.sender == owner);
        to.transfer(amount);
  }

   function withdrawalToken(address tokenAddr,address to, uint amount) external {
        require(msg.sender == owner);
        IERC20(tokenAddr).transfer(to,amount);
  }
  
  function transferOwnership(address to) external {
        require(msg.sender == owner);
        owner = to;
        emit TransferOwnership(owner);
  }

  function getPriceinUSD() public view returns (uint256){
        
        address BUSD_WBNB = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;
        
        IERC20 BUSDTOKEN = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        IERC20 WBNBTOKEN = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        
        uint256 BUSDSUPPLYINBUSD_WBNB = BUSDTOKEN.balanceOf(BUSD_WBNB);
        uint256 WBNBSUPPLYINBUSD_WBNB = WBNBTOKEN.balanceOf(BUSD_WBNB);
        
        uint256 BNBPRICE = (BUSDSUPPLYINBUSD_WBNB.mul(1e18)).div(WBNBSUPPLYINBUSD_WBNB);

        address M1VERSE_WBNB = 0x5cd2Ec8FAC611097a08349CcA37FceF82755447f;
        IERC20 M1VERSETOKEN = IERC20(0xf50B0a35EfdF8F247625E2A0695D56a63b30B7ff);

        uint256 WBNBSUPPLYINM1VERSE_WBNB =(WBNBTOKEN.balanceOf(M1VERSE_WBNB));
        uint256 M1VERSESUPPLYINM1VERSE_WBNB = (M1VERSETOKEN.balanceOf(M1VERSE_WBNB));

        uint256 M1VERSEUSDVAL = (((WBNBSUPPLYINM1VERSE_WBNB.mul(1e9)).div((M1VERSESUPPLYINM1VERSE_WBNB))).mul(BNBPRICE)).div(1e18);
        return M1VERSEUSDVAL;
        
    }
}