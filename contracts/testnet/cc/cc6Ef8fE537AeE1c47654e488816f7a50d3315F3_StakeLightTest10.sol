// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


import "./SafeMath.sol";
interface IBEP20Token
{
    function mintTokens(address receipient, uint256 tokenAmount) external returns(bool);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function balanceOf(address user) external view returns(uint256);
    function totalSupply() external view returns (uint256);
    function maxsupply() external view returns (uint256);
    function repurches(address _from, address _to, uint256 _value) external returns(bool);
    function burn_internal(uint256 _value, address _to) external returns (bool);
}

contract StakeLightTest10{
  AggregatorV3Interface internal priceFeed;
  IBEP20Token public token;
  using SafeMath for uint;


  struct Deposit {
	uint amountUSD;
    uint withdrawn;
    uint tokenAmount;
	uint start;
    uint withdrwanUSD;
    bool roiActive;
	}
  struct Restake{
    uint amountUSD;
    uint amountBNB;
    uint start;
    bool status;
  }

	struct User {
    Deposit[] deposits;
    uint checkpoint;
    address referrer;
    address[15] refAddress;
    uint[15] refs;
    uint[15] refStageBusiness;
    uint directBusiness;
    uint bonus;
    uint totalBonus;
    uint maxDeposit;
    uint withdrawn;
    uint[15] refStageBonus;
    uint rankWithdraw;
    uint totalRoiIncome;
    uint totalPassiveRoi;
    uint dataWithdrwan;
    uint reStakeAmount;
    uint reStakeDone;
    uint boosterCount;
	}


  struct RankIncome{
    uint amountUSD;
    uint maturityDate;
  }

struct x5{
  uint start;
  uint last;
  uint checkPoint;
  uint maxamount;
}

struct x20{
  uint start;
  uint last;
  uint checkPoint;
  uint maxamount;
}

struct x100{
  uint start;
  uint last;
  uint checkPoint;
  uint maxamount;

}


  uint256  public INVEST_MIN_AMOUNT;
  uint256[15] public PASSIVE_PERCENTS;
  uint[10] public refBonus;
  uint[3] public rankPercnetage;
  uint public percentDivider;
  uint public maxDeposit;
  uint public contractStart;
  address payable public ownerWallet; 
  address payable public supportWallet;
  uint[15] private requireDirect;
  uint public totalUser;
  uint public timeStamp;
  uint public roiStartDate;
  uint[3] public changeDays;
  uint[2] public mainRoiPercentage;
  uint[3] private roiPercentDecrement;
  uint public tokenPrice;
  uint private rankTime_stamp;
  bool private IsInitinalized; 



  mapping(address => User) public users;
  mapping (address => mapping(uint => address)) public direct_ref;
  mapping (address => mapping(uint => address[])) public refDetails;
  mapping(address =>x5) private x5Booster;
  mapping(address =>x20) private x20Booster;
  mapping(address =>x100) private x100Booster;
  mapping(address => RankIncome[]) public rankIncomes;

   modifier adminOnly() {
    require(msg.sender == ownerWallet, "admin: wut?");
    _;
}


   function initialize(address payable _ownerWallet ,address payable _supportWallet,IBEP20Token _tokenAddress) public {
        require(IsInitinalized==false,"You can use it only one time");
            ownerWallet = _ownerWallet;
            supportWallet = _supportWallet;
            priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
            INVEST_MIN_AMOUNT = 10*1e8;
            PASSIVE_PERCENTS = [1000,700,500,400,300,200,100,100,100,100,100,200,300,400,500];
            requireDirect = [0,1,2,2,3,3,4,4,5,6,7,7,7,7,7];
            percentDivider = 10000;
            refBonus = [500,400,300,200,100,100,100,100,100,200];
            rankPercnetage = [500,1000,2000];
            maxDeposit = 100000*1e8;
            contractStart = block.timestamp;
            roiPercentDecrement= [3,2,1];
            changeDays = [34,83,134];
            tokenPrice = 1e8;
            token = _tokenAddress;
            roiStartDate = block.timestamp;
            timeStamp = 1 hours;
            rankTime_stamp = 1 hours;
            mainRoiPercentage = [300,50];
            IsInitinalized = true;
    }


    function invest(address _referrer,uint _amount) public payable {
        User storage user = users[msg.sender];
        uint _amountBNB;
        uint reStakeValue = user.reStakeAmount;
        if(reStakeValue>0){
          _amount = _amount.add(reStakeValue);
          _amountBNB = getCalculatedBnbRecieved(reStakeValue);
        }
        uint256 usdValue = uint256(TotalusdPrice(int(msg.value.add(_amountBNB))));
        // uint count = user.deposits.length;
        // // if(count>0){
        // // // if(user.deposits[count-1].roiActive ==true){
        // // //     revert("Your last Roi is not completed");
        // // // }
        // // }
        require(usdValue >= INVEST_MIN_AMOUNT,"min amount is $100");
        require((users[_referrer].deposits.length > 0 && _referrer != msg.sender) || ownerWallet == msg.sender,  "No upline found");
        require(_amount.mod(INVEST_MIN_AMOUNT) == 0 && _amount >= INVEST_MIN_AMOUNT, "mod err");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "less before");
        if(user.maxDeposit == 0){
            user.maxDeposit = _amount;
        }else if(user.maxDeposit < _amount){
            user.maxDeposit = _amount;
        }
 
        if (user.referrer == address(0) && ownerWallet != msg.sender) {
			        user.referrer = _referrer;
        }
        address upline = user.referrer;
          for(uint i=0; i<15; i++){
             if (upline != address(0)){
                if(user.deposits.length == 0 ){
                    users[upline].refs[i] += 1; 
                    refDetails[upline][i+1].push(msg.sender);
                }
                if(i==0 && block.timestamp <= users[upline].deposits[0].start.add(rankTime_stamp)){
                  users[upline].directBusiness =  users[upline].directBusiness.add(_amount);
                }
                if(i==0 && block.timestamp >= users[upline].deposits[0].start.add(rankTime_stamp)){
                  uint percnet = calaculateRankIncomePercentage(upline);
                  uint amount = users[upline].directBusiness.mul(percnet).div(percentDivider);
                  amount = amount.div(12);
                  uint time = rankTime_stamp;
                  if(amount>0){
                      for(uint j=0 ; j<12;j++){                    
                    rankIncomes[upline].push(RankIncome(amount,block.timestamp.add(time)));
                    time = time.add(rankTime_stamp);           
                  }
                  }
                  
                }
                users[upline].refStageBusiness[i] = users[upline].refStageBusiness[i].add(_amount);
                if(i < 10 && users[upline].refs[0] >= requireDirect[i]){
                    uint bonus = _amount.mul(refBonus[i]).div(percentDivider);
                    users[upline].bonus = users[upline].bonus.add(bonus);
                    users[upline].refStageBonus[i] = users[upline].refStageBonus[i].add(bonus);
                }
                
             }else break; 
                 upline = users[upline].referrer;
          }

        if(user.referrer != address(0) && user.deposits.length == 0 ){
            direct_ref[user.referrer][users[user.referrer].refs[0]-1] = msg.sender;
        }
        if(user.deposits.length == 0){
            totalUser++;
            user.checkpoint = block.timestamp; 
        }
        

       user.deposits.push(Deposit(_amount,msg.value,0, block.timestamp, 0,true));
       checkBooster(msg.sender);


    }

    function investToken(address _referrer,uint _token) public {
        User storage user = users[msg.sender];
        uint _amountBNB;
        uint usdFromToken = _token.mul(tokenPrice).div(1e8);
        uint remaingAmount = usdFromToken.mod(INVEST_MIN_AMOUNT);
        uint _amount = usdFromToken.sub(remaingAmount);
        uint reStakeValue = user.reStakeAmount;
        if(reStakeValue>0){
          _amount = _amount.add(reStakeValue);
          _amountBNB = getCalculatedBnbRecieved(reStakeValue);
        }
        require(_amount >= INVEST_MIN_AMOUNT,"min amount is $100");
        require((users[_referrer].deposits.length > 0 && _referrer != msg.sender) || ownerWallet == msg.sender,  "No upline found");
        require(_amount.mod(INVEST_MIN_AMOUNT) == 0 && _amount >= INVEST_MIN_AMOUNT, "mod err");
        require(user.maxDeposit == 0 || _amount >= user.maxDeposit, "less before");
        if(user.maxDeposit == 0){
            user.maxDeposit = _amount;
        }else if(user.maxDeposit < _amount){
            user.maxDeposit = _amount;
        }
 
        if (user.referrer == address(0) && ownerWallet != msg.sender) {
			        user.referrer = _referrer;
        }
        address upline = user.referrer;
          for(uint i=0; i<15; i++){
             if (upline != address(0)){
                if(user.deposits.length == 0 ){
                    users[upline].refs[i] += 1; 
                    refDetails[upline][i+1].push(msg.sender);
                }

                if(i==0 && block.timestamp <= users[upline].deposits[0].start.add(rankTime_stamp)){
                  users[upline].directBusiness =  users[upline].directBusiness.add(_amount);
                }
                if(i==0 && block.timestamp >= users[upline].deposits[0].start.add(rankTime_stamp)){
                  uint percnet = calaculateRankIncomePercentage(upline);
                  uint amount = users[upline].directBusiness.mul(percnet).div(percentDivider);
                  amount = amount.div(12);
                  uint time = rankTime_stamp;
                 if(amount>0){
                      for(uint j=0 ; j<12;j++){                    
                    rankIncomes[upline].push(RankIncome(amount,block.timestamp.add(time)));
                    time = time.add(rankTime_stamp);           
                  }
                  }
                  
                }
                users[upline].refStageBusiness[i] = users[upline].refStageBusiness[i].add(_amount);
                if(i < 10){
                    uint bonus = _amount.mul(refBonus[i]).div(percentDivider);
                    users[upline].bonus = users[upline].bonus.add(bonus);
                    users[upline].refStageBonus[i] = users[upline].refStageBonus[i].add(bonus);
                }
                
             }else break; 
                 upline = users[upline].referrer;
          }

        if(user.referrer != address(0) && user.deposits.length == 0 ){
            direct_ref[user.referrer][users[user.referrer].refs[0]-1] = msg.sender;
        }
        if(user.deposits.length == 0){
            totalUser++;
            user.checkpoint = block.timestamp; 
        }
        
        token.burn_internal(_token, msg.sender);

       user.deposits.push(Deposit(_amount,0,_token, block.timestamp, 0,true));
       checkBooster(msg.sender);


    }

function getRankIncome(address _user) public view returns(uint _income){
  if(rankIncomes[_user].length>0){
    for(uint i= 0;i<12;i++){
    uint bal = rankIncomes[_user][i].amountUSD;
    if(block.timestamp>=rankIncomes[_user][i].maturityDate){
       _income= _income.add(bal);
    }  
  }
  _income = _income.sub(users[_user].rankWithdraw);
  }
  return _income;
  

  
}

function checkBooster(address _user) private {
  User storage user = users[_user];
  address upline =user.referrer;
  if(upline != address(0)){
    if(user.deposits[0].amountUSD >=users[upline].deposits[0].amountUSD){
      users[upline].boosterCount = users[upline].boosterCount.add(1);
      calaculateBosterRoi(upline);
   }
  }
   

}


function withdraw() public {
  User storage user = users[msg.sender];
  uint totalwithdrawAmount;
  uint count = user.deposits.length;
(uint payofMoney,) = payoutOf(msg.sender);
uint roi = getUserDividends(msg.sender);
uint passiveRoi =  getUserPassiveIncome(msg.sender);
if(payofMoney==0){
  user.deposits[count-1].roiActive = false;
}

uint bonus = user.bonus;
user.bonus = 0;
user.totalPassiveRoi = user.totalPassiveRoi.add(passiveRoi);
user.totalRoiIncome = user.totalRoiIncome.add(roi);
user.checkpoint = block.timestamp;
uint restakeMoney= payofMoney.mul(25).div(100);
uint payMoney = payofMoney.mul(75).div(100);
uint rankIncome = getRankIncome(msg.sender);
totalwithdrawAmount.add(payMoney).add(bonus).add(rankIncome);
user.withdrawn = user.withdrawn.add(payofMoney);
user.deposits[count-1].withdrwanUSD = user.deposits[count-1].withdrwanUSD.add(payofMoney);
user.deposits[count-1].withdrawn = user.deposits[count-1].withdrawn.add(roi);
user.rankWithdraw = user.rankWithdraw.add(rankIncome);
uint totalwithdrawToken = (totalwithdrawAmount.div(tokenPrice)).mul(1e8);
user.reStakeAmount = user.reStakeAmount.add(restakeMoney).sub(user.reStakeDone);
// token.mintTokens(msg.sender, totalwithdrawToken);
uint totalwithdrawTokenBNb = getCalculatedBnbRecieved(totalwithdrawToken);
payable(msg.sender).transfer(totalwithdrawTokenBNb);



}

  function payoutOf(address _addr) view public returns(uint256 payout, uint256 max_payout) {
        max_payout = maxPayoutOf(_addr);
        uint count = users[_addr].deposits.length;
        if(count >0){
            if(users[_addr].deposits[count-1].withdrwanUSD < max_payout) {
            payout = getUserDividends(_addr).add(getUserPassiveIncome(_addr)).add(getBoosterData(_addr));

            if(payout >= max_payout){
                payout -= max_payout;
            }
            
            if(users[_addr].deposits[count-1].withdrwanUSD.add(payout) > max_payout) {
                payout = max_payout.sub(users[_addr].deposits[count-1].withdrwanUSD);
            }
        }
        }
        
    }
    function maxPayoutOf(address userAddress) view private returns(uint256 amount) {
		User storage user = users[userAddress];
    if(user.deposits.length >0){
        uint count = user.deposits.length;
		amount = amount.add(user.deposits[count-1].amountUSD);
    }
        return amount *2;
    }

  function getUserDividends(address _userAddress) public view returns (uint) {
		User storage user = users[_userAddress];
		uint totalDividends;
		uint dividends;
    uint roi_user = getRoiPercentage(); 

		if(block.timestamp>= roiStartDate){
			for (uint i = 0; i < user.deposits.length; i++) {
        if(user.deposits[i].roiActive==true){
          if (user.deposits[i].start > user.checkpoint) {

							dividends = (user.deposits[i].amountUSD.mul(roi_user).div(percentDivider))
								.mul(block.timestamp.sub(user.deposits[i].start))
								.div(timeStamp);

						} else {

							dividends = (user.deposits[i].amountUSD.mul(roi_user).div(percentDivider))
								.mul(block.timestamp.sub(user.checkpoint))
								.div(timeStamp);

						}
						totalDividends = totalDividends.add(dividends);
          
        }	 
			}
		}

		return totalDividends;
	}

   function getUserDividendsByindex(address _userAddress, uint i) public view returns (uint) {
		User storage user = users[_userAddress];
		uint totalDividends;
		uint dividends;
    uint roi_user = getRoiPercentage();
		if(block.timestamp>=roiStartDate){
      if(user.deposits[i].roiActive==true){
                if (user.deposits[i].start > user.checkpoint) {
              
							dividends = (user.deposits[i].amountUSD.mul(roi_user).div(percentDivider))
								.mul(block.timestamp.sub(user.deposits[i].start))
								.div(timeStamp);

						} else {

							dividends = (user.deposits[i].amountUSD.mul(roi_user).div(percentDivider))
								.mul(block.timestamp.sub(user.checkpoint))
								.div(timeStamp);

						}
						totalDividends = totalDividends.add(dividends);
              }			 				
			}

		return totalDividends;
	}


  function getUserPassiveIncome(address _userAddress) public view returns(uint){
    uint passiveIncome;
    User storage user = users[_userAddress];
    uint c = user.deposits.length;
      	if(block.timestamp>= roiStartDate){
         if(user.deposits[c-1].roiActive==true){
             for(uint i = 0; i<15; i++){
            uint  count  = user.refs[i];
            if(user.refs[0]>=requireDirect[i]){
               for(uint j =0;j<count;j++){
                address downline = refDetails[_userAddress][i+1][j];
                  for(uint y=0;y<users[downline].deposits.length;y++){
                     uint downlineRoi = getUserDividendsByindex(downline, y);
                     uint income;
                     uint roi_user = PASSIVE_PERCENTS[i];
                     income = downlineRoi.mul(roi_user).div(percentDivider);
                    
                    passiveIncome = passiveIncome.add(income);                                
              }             
            }
            }
           
          }
         }
         

        }
        return passiveIncome;

  }

  function getcurrentPASSIVEincome(address userAddress) public view returns (uint256){
	    User storage user = users[userAddress];
	    return (getUserPassiveIncome(userAddress).sub(user.totalPassiveRoi));	    
	}

    function getcurrentDividendsincome(address userAddress) public view returns (uint256 _amount){
	    User storage user = users[userAddress];
        // uint max = maxPayoutOf(userAddress);
        // (uint progress,) = progressReport(userAddress);
        // if(progress < max){
             uint count =  user.deposits.length;
             _amount = getUserDividends(userAddress).sub(user.deposits[count-1].withdrawn);
        // }
      
	    return _amount ;	    
	}

  function calaculateRankIncomePercentage(address _user) public view returns(uint percent){
    uint value = users[_user].directBusiness;
    if(value >= 50*1e8 && value <100*1e8){
      percent = rankPercnetage[0];
    }

    if(value >= 100*1e8 && value <150*1e8){
      percent = rankPercnetage[1];
    }

    if(value >= 150*1e8){
      percent = rankPercnetage[2];
    }
    return percent;
  }

  function getCurDay() public view returns(uint _day) {
    if(block.timestamp>=roiStartDate){
      _day = (block.timestamp.sub(roiStartDate)).div(timeStamp);
      return _day;
    }     
    }

  function getRoiPercentage() public view returns(uint _percent){
    if(block.timestamp>=roiStartDate){
      uint day = getCurDay();
      if(day == 0){
        _percent = mainRoiPercentage[0];
      }
      if(day <=changeDays[0]){
        _percent = mainRoiPercentage[0].sub(roiPercentDecrement[0].mul(day));
      }
      if(day >changeDays[0] && day <=changeDays[1]){
        uint dayDiff = day.sub(changeDays[0]); 
        uint value = mainRoiPercentage[0].sub(roiPercentDecrement[0].mul(changeDays[0]));
        _percent = value.sub(roiPercentDecrement[1].mul(dayDiff));
      }
      if(day >changeDays[1] && day <=changeDays[2]){
        uint diff = changeDays[1].sub(changeDays[0]);
        uint value = mainRoiPercentage[0].sub(roiPercentDecrement[0].mul(changeDays[0]));
        uint dayDiff = day.sub(changeDays[1]); 
        value = value.sub(roiPercentDecrement[1].mul(diff));
      _percent = mainRoiPercentage[0].sub(roiPercentDecrement[2].mul(dayDiff));
    }
      if(day >changeDays[2]){
        _percent = mainRoiPercentage[1];
      }
    }
    return _percent;
  }


 function getLatestPrice() public view returns (int) {
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt */,
            /*uint timeStamp*/,
           /* uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

    function TotalusdPrice(int _amount) public view returns (int) {
        int usdt = getLatestPrice();
        return (usdt * _amount)/1e18;
    }

    function getCalculatedBnbRecieved(uint256 _amount) public view returns(uint256) {
		uint256 usdt = uint256(getLatestPrice());
		uint256 recieved_bnb = (_amount*1e18/usdt*1e18)/1e18;
		return recieved_bnb;
	  }


  function getBoosterData(address _user) public view returns(uint){
    uint data;
    uint totalData;
    uint count = users[_user].boosterCount;
   if(count>=2){
        data = getX5Booster(_user);
        totalData =totalData.add(data);
      }
    if(count>=4){
        data = getx20Booster(_user);
        totalData =totalData.add(data); 
      }
       if(count>=5){
        
        data = getx100Booster(_user);
        totalData =totalData.add(data);
      }
      totalData =totalData.sub(users[_user].dataWithdrwan);

      return totalData;
  }

    function calaculateBosterRoi(address _user) private{
      uint count = users[_user].boosterCount;
      if(count==2){
        x5Booster[_user].start = block.timestamp;
        x5Booster[_user].last = block.timestamp.add(5 days);
        uint amount = getUserDividendsByindex(_user, 0);
        x5Booster[_user].maxamount = amount.mul(1).mul(5);  
        x5Booster[_user].checkPoint = block.timestamp;
      }
       if(count==4){
        x20Booster[_user].start = block.timestamp;
        x20Booster[_user].last = block.timestamp.add(6 days);
        uint amount = getUserDividendsByindex(_user, 0);
        x20Booster[_user].maxamount = amount.mul(2).mul(6); 
        x20Booster[_user].checkPoint = block.timestamp;
      }
       if(count==5){
        
        x100Booster[_user].last = block.timestamp.add(7 days);
        uint amount = getUserDividendsByindex(_user, 0);
        x100Booster[_user].maxamount = amount.mul(3).mul(7); 
        x100Booster[_user].checkPoint = block.timestamp;
      }
       
    }

    function getX5Booster(address _useraddress) private view returns(uint){
       x5 storage boosters = x5Booster[_useraddress];
      uint amount;
      if(block.timestamp <=x5Booster[_useraddress].last){
          uint256 from = boosters.start > boosters.checkPoint ? boosters.start : boosters.checkPoint;
					amount =amount.add(boosters.maxamount.mul(block.timestamp.sub(from)).div(timeStamp));
      }else{
        amount =  boosters.maxamount;
      }
      return amount;
     
    }

    function getx20Booster(address _useraddress) private view returns(uint){
       x20 storage boosters = x20Booster[_useraddress];
      uint amount;
      if(block.timestamp <=x5Booster[_useraddress].last){
            uint256 from = boosters.start > boosters.checkPoint ? boosters.start : boosters.checkPoint;
					 amount =amount.add(boosters.maxamount.mul(block.timestamp.sub(from)).div(timeStamp));			
      }else{
        amount =  boosters.maxamount;
      }
      return amount;
     
    }

    function getx100Booster(address _useraddress) private view returns(uint){
       x100 storage boosters = x100Booster[_useraddress];
      uint amount;
      if(block.timestamp <=x5Booster[_useraddress].last){
            uint256 from = boosters.start > boosters.checkPoint ? boosters.start : boosters.checkPoint;
						amount =amount.add(boosters.maxamount.mul(block.timestamp.sub(from)).div(timeStamp));
      }else{
        amount =  boosters.maxamount;
      }
      
      return amount;
     
    }

  function getUserRef(address _useraddress , uint _index) public view returns(uint _refcount, uint _refStageBusiness,uint _refStageBonus) {
      User storage user = users[_useraddress];


      return(
          _refcount = user.refs[_index],
          _refStageBusiness = user.refStageBusiness[_index],
          _refStageBonus = user.refStageBonus[_index]  
      );
  }

  function getTotalDeposit(address _useraddress) public view returns(uint totalDeposit){
    for(uint i=0;i<users[_useraddress].deposits.length;i++){
      uint bal = users[_useraddress].deposits[i].amountUSD;
      totalDeposit = totalDeposit.add(bal);
    }
    return totalDeposit;
  }

  function availableWithdraw(address _user) public view returns(uint totalAmount,uint restakeAmount ,uint withdrawAmount){
        User storage user = users[_user];
        (uint payofMoney,) = payoutOf(_user);

        uint bonus = user.bonus;
        uint restakeMoney= payofMoney.mul(25).div(100);
        uint payMoney = payofMoney.mul(75).div(100);
        uint rankIncome = getRankIncome(_user);
        withdrawAmount = withdrawAmount.add(payMoney).add(bonus).add(rankIncome);
        restakeAmount =  restakeMoney;
        totalAmount = totalAmount.add(payofMoney).add(bonus).add(rankIncome);
    return (totalAmount,restakeAmount,withdrawAmount);
  }

  function getLevelPassiveIncome(address _userAddress,uint i) public view returns(uint){
    uint passiveIncome;
    User storage user = users[_userAddress];
      	if(block.timestamp>= roiStartDate){
            uint  count  = user.refs[i];
            if(user.refs[0]>=requireDirect[i]){
               for(uint j =0;j<count;j++){
                address downline = refDetails[_userAddress][i+1][j];
                  for(uint y=0;y<users[downline].deposits.length;y++){
                     uint downlineRoi = getUserDividendsByindex(downline, y);
                     uint income;
                     uint roi_user = PASSIVE_PERCENTS[i];
                     income = downlineRoi.mul(roi_user).div(percentDivider);
                    
                    passiveIncome = passiveIncome.add(income);                                
              }             
            }
            }

        }
        return passiveIncome;

  }

  function revertBack() public adminOnly {
    ownerWallet.transfer(address(this).balance);
  }

  function progressReport(address _addr) view public returns( uint256 progress, uint max) {
        uint max_payout = maxPayoutOf(_addr);
        max = max_payout;
        uint count = users[_addr].deposits.length;
        if(count >0){
            if(users[_addr].deposits[count-1].withdrwanUSD < max_payout) {
            uint payout = getUserDividends(_addr).add(getUserPassiveIncome(_addr)).add(getBoosterData(_addr).add(users[_addr].dataWithdrwan));

            if(payout >= max_payout){
                payout -= max_payout;
            }

            progress = payout;
        }else{
            progress = max_payout;
        }
        }
        return (progress,max);

  }
        

}


interface AggregatorV3Interface {

  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version()external view returns (uint);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)external view returns (
      uint80 roundId,
      int256 answer,
      uint startedAt,
      uint updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()external view returns (
      uint80 roundId,
      int256 answer,
      uint startedAt,
      uint updatedAt,
      uint80 answeredInRound
    );

}