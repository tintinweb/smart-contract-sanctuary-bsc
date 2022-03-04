/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// 0x25D567d425B24F3E5784738deb70eE1ffd616A80
// 0xCF1AeCc287027f797b99650B1E020fFa0fb0e248
// 0xeBEC496E971cb81779fE17e0e2e5387CC30EBcE4

pragma solidity 0.5.4;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender)
  external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value)
  external returns (bool);
  
  function transferFrom(address from, address to, uint256 value)
  external returns (bool);
  function burn(uint256 value)
  external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract AuraStakingProgram  {
     using SafeMath for uint256;
     
    struct Staking {
        uint256 programId;
        uint256 stakingDate;
        uint256 staking;
        uint256 lastWithdrawalDate;
        uint256 currentRewards;
        bool    isExpired;
        uint256 genRewards;
        uint256 stakingToken;
        uint8   releaseCount;
    }

    struct Program {
        uint256 dailyInterest;
        uint256 term; //0 means unlimited
        uint256 maxDailyInterest;
    }
  
     
    struct User {
        uint id;
        address referrer;
        uint256 programCount;
        uint256 totalStakingBusd;
        uint256 totalStakingToken;
        uint256 currentPercent;
        uint256 airdropReward;
        mapping(uint256 => Staking) programs;
    }
    
    mapping(address => address[]) public referrals;

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    
    Program[] private stakingPrograms_;
    
    uint256 private constant INTEREST_CYCLE = 1 days;
    uint256[] public REFERRAL_PERCENTS = [8000, 3000, 2000, 1000, 500, 500, 500, 500, 500, 25, 25];
    uint public lastUserId = 2;
    uint256 public tokenPrice=4e16;
   
    
    uint256 public  total_staking_token = 0;
    uint256 public  total_staking_busd = 0;
    
    uint256 public  total_withdraw_token = 0;
    uint256 public  total_withdraw_busd = 0;
    
    uint256 public  total_token_buy = 0;
    uint256 public  total_token_sell = 0;
	
	bool   public  buyOn = true;
	bool   public  sellOn = true;
	bool   public  stakingOn = true;
	
	uint256 public  MINIMUM_BUY = 1e9;
	uint256 public  MINIMUM_SELL = 1e9;	

    uint256 public  BUY_FEE = 1e18;
	uint256 public  SELL_FEE = 1e18;	

    address public owner; 
    
    event Registration(address indexed user, address indexed referrer, uint256 indexed userId, uint256 referrerId);
    event CycleStarted(address indexed user,uint256 stakeID, uint256 walletUsedBusd, uint256 totalToken);
    event TokenDistribution(address indexed sender, address indexed receiver, uint total_token, uint live_rate, uint busd_amount);
    event onWithdraw(address  _user, uint256 withdrawalAmount,uint256 withdrawalAmountToken);
    event ReferralReward(address  _user,address _from,uint256 reward,uint8 level,uint8 _type);
    IBEP20 private AuraToken; 
    IBEP20 private busdToken; 

    constructor(address ownerAddress, IBEP20 _busdToken, IBEP20 _AuraToken) public 
    {
        owner = ownerAddress;
        
        AuraToken = _AuraToken;
        busdToken = _busdToken;
        
        stakingPrograms_.push(Program(6,24*60*60*730,6));

        stakingPrograms_.push(Program(80000,24*60*60*730,80000));
        stakingPrograms_.push(Program(30000,24*60*60*730,30000));
        stakingPrograms_.push(Program(20000,24*60*60*730,20000));
        stakingPrograms_.push(Program(10000,24*60*60*730,10000));
        stakingPrograms_.push(Program(5000,24*60*60*730,5000));
        stakingPrograms_.push(Program(5000,24*60*60*730,5000));
        stakingPrograms_.push(Program(5000,24*60*60*730,5000));
        stakingPrograms_.push(Program(5000,24*60*60*730,5000));
        stakingPrograms_.push(Program(2500,24*60*60*730,2500));
        stakingPrograms_.push(Program(2500,24*60*60*730,2500));
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            programCount: uint(0),
            totalStakingBusd: uint(0),
            totalStakingToken: uint(0),
            currentPercent: uint(0),
            airdropReward:uint(0)
        });
        users[ownerAddress] = user;
        idToAddress[1] = ownerAddress;
    } 
    
    function() external payable 
    {
        if(msg.data.length == 0) {
            return registration(msg.sender, owner);
        }
        
        registration(msg.sender, bytesToAddress(msg.data));
    }

    function withdrawBalance(uint256 amt,uint8 _type) public 
    {
        require(msg.sender == owner, "onlyOwner");
        if(_type==1)
        msg.sender.transfer(amt);
        else if(_type==2)
        busdToken.transfer(msg.sender,amt);
        else
        AuraToken.transfer(msg.sender,amt);
    }
    
      function multisend(address payable[]  memory  _contributors, uint256[] memory _balances) public payable 
     {
        require(msg.sender==owner,"Only Owner");
        uint256 i = 0;
        for (i; i < _contributors.length; i++) 
        {
            AuraToken.transfer(_contributors[i],_balances[i]);
        }
    }
    
  
    function registration(address userAddress, address referrerAddress) private 
    {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            programCount: 0,
            totalStakingBusd: 0,
            totalStakingToken: 0,
            currentPercent: 0,
            airdropReward:0
        });
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        
        referrals[referrerAddress].push(userAddress);

        lastUserId++;
        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    
    // Staking Process
    
    function start_staking(uint256 walletUsedBusd,uint256 _programId,address referrer) public 
    {
        require(stakingOn,"Staking Stopped.");
        require(_programId==0, "Wrong staking program id");
        if(!isUserExists(msg.sender))
	    {
	        registration(msg.sender, referrer);   
	    }
	    else
	    {
	        updateRewards();
	    }
        require(isUserExists(msg.sender), "user not exists");
        
        // wallet balance 
        uint256 walletUsed=(walletUsedBusd.mul(1e9)).div(tokenPrice);
        require(AuraToken.balanceOf(msg.sender)>=walletUsed,"Low wallet balance");
        require(AuraToken.allowance(msg.sender,address(this))>=walletUsed,"Allow token first");
      
        AuraToken.transferFrom(msg.sender,address(this),walletUsed);
       
        uint256 _busdAmount=walletUsedBusd;
        require(_busdAmount>=25*1e18, "Minimum 25 Dollar");
        
        uint256 programCount = users[msg.sender].programCount;

        
        users[msg.sender].programs[programCount].programId = _programId;
        users[msg.sender].programs[programCount].stakingDate = block.timestamp;
        users[msg.sender].programs[programCount].lastWithdrawalDate = block.timestamp;
        users[msg.sender].programs[programCount].staking = _busdAmount;
        users[msg.sender].programs[programCount].currentRewards = 0;
        users[msg.sender].programs[programCount].genRewards = 0;
        users[msg.sender].programs[programCount].isExpired = false;
        users[msg.sender].programs[programCount].stakingToken = walletUsed;
        users[msg.sender].programCount = users[msg.sender].programCount.add(1);
        
        users[msg.sender].totalStakingToken = users[msg.sender].totalStakingToken.add(walletUsed);
        users[msg.sender].totalStakingBusd = users[msg.sender].totalStakingBusd.add(_busdAmount);
        users[msg.sender].currentPercent=getStakingPercent(msg.sender);
        address referrerAddress=users[msg.sender].referrer;
        
        uint256 refBonus=(walletUsed.mul(REFERRAL_PERCENTS[0])).div(100000);
        AuraToken.transfer(referrerAddress,refBonus);
        emit ReferralReward(referrerAddress,msg.sender,refBonus,1,1);

        uint256 passiveIncome=(walletUsed.mul(users[msg.sender].currentPercent)).div(1000000);


        programCount = users[referrerAddress].programCount;
        users[referrerAddress].programs[programCount].programId = 1;
        users[referrerAddress].programs[programCount].stakingDate = block.timestamp;
        users[referrerAddress].programs[programCount].lastWithdrawalDate = block.timestamp;
        users[referrerAddress].programs[programCount].staking = passiveIncome;
        users[referrerAddress].programs[programCount].currentRewards = 0;
        users[referrerAddress].programs[programCount].genRewards = 0;
        users[referrerAddress].programs[programCount].isExpired = false;
        users[referrerAddress].programs[programCount].stakingToken = passiveIncome;
        users[referrerAddress].programCount = users[referrerAddress].programCount.add(1);


        referrerAddress=users[referrerAddress].referrer;
        if(referrerAddress!=address(0))
        {
            for(uint8 i=1;i<10;i++)
            {
                if(isQualifiedForLevel(referrerAddress))
                {
                    refBonus=(walletUsed.mul(REFERRAL_PERCENTS[i])).div(100000);
                    AuraToken.transfer(referrerAddress,refBonus);
                    emit ReferralReward(referrerAddress,msg.sender,refBonus,i+1,1);
                    
                    programCount = users[referrerAddress].programCount;

                    users[referrerAddress].programs[programCount].programId = i+1;
                    users[referrerAddress].programs[programCount].stakingDate = block.timestamp;
                    users[referrerAddress].programs[programCount].lastWithdrawalDate = block.timestamp;
                    users[referrerAddress].programs[programCount].staking = passiveIncome;
                    users[referrerAddress].programs[programCount].currentRewards = 0;
                    users[referrerAddress].programs[programCount].genRewards = 0;
                    users[referrerAddress].programs[programCount].isExpired = false;
                    users[referrerAddress].programs[programCount].stakingToken = passiveIncome;
                    users[referrerAddress].programCount = users[referrerAddress].programCount.add(1);
                }
                if(users[referrerAddress].referrer!=address(0))
                referrerAddress=users[referrerAddress].referrer;
                else
                break;
            }
        }
	    	
	    emit CycleStarted(msg.sender,users[msg.sender].programCount, walletUsedBusd,walletUsed);
    }

    function buyToken(uint256 tokenQty) public payable
	{
	     require(buyOn,"Buy Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");
	     require(tokenQty>=MINIMUM_BUY,"Invalid minimum quantity");
	     uint256 buy_amt=(tokenQty/1e9)*tokenPrice;	  
         buy_amt+=(buy_amt*BUY_FEE)/1e20;
         busdToken.transferFrom(msg.sender ,address(this), (buy_amt));
	     AuraToken.transfer(msg.sender , tokenQty);	     
         total_token_buy=total_token_buy+tokenQty;
		 emit TokenDistribution(address(this), msg.sender, tokenQty, tokenPrice, buy_amt);					
	 }
	 
	function sellToken(uint256 tokenQty) public payable
	{
	     require(sellOn,"Sell Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");
	     require(tokenQty>=MINIMUM_SELL,"Invalid minimum quantity");
	     require(isUserExists(msg.sender),"User Not Exist");
	     AuraToken.transferFrom(msg.sender,address(this),tokenQty);
	     uint256 busd_amt=(tokenQty/1e9)*tokenPrice;
         busd_amt-=(busd_amt*SELL_FEE)/1e20;     
	     busdToken.transfer(msg.sender,busd_amt);
         total_token_sell=total_token_sell+tokenQty;
         emit TokenDistribution(address(this), msg.sender, tokenQty, tokenPrice, busd_amt);					
	 } 
	 

	
	function withdraw() public payable 
	{
        require(msg.value == 0, "withdrawal doesn't allow to transfer bnb simultaneously");
        uint256 uid = users[msg.sender].id;
        require(uid != 0, "Can not withdraw because no any stakings");
        uint256 withdrawalAmount = 0;
        for (uint256 i = 0; i < users[msg.sender].programCount; i++) 
        {
            if(users[msg.sender].programs[i].programId==0 && block.timestamp>users[msg.sender].programs[i].stakingDate.add(240 days) && users[msg.sender].programs[i].releaseCount<3)
            {
                if(users[msg.sender].programs[i].releaseCount==0){
                    withdrawalAmount+=(users[msg.sender].programs[i].stakingToken.mul(30)).div(100);
                    users[msg.sender].programs[i].releaseCount=1;
                }

                if(block.timestamp>users[msg.sender].programs[i].stakingDate.add(480 days) && users[msg.sender].programs[i].releaseCount==1){
                    withdrawalAmount+=(users[msg.sender].programs[i].stakingToken.mul(30)).div(100);
                    users[msg.sender].programs[i].releaseCount=2;
                }

                if(block.timestamp>users[msg.sender].programs[i].stakingDate.add(720 days) && users[msg.sender].programs[i].releaseCount==2){
                    withdrawalAmount+=(users[msg.sender].programs[i].stakingToken.mul(40)).div(100);
                    users[msg.sender].programs[i].releaseCount=3;
                }
            }

            if (users[msg.sender].programs[i].isExpired) {
                users[msg.sender].programs[i].genRewards=0;
                continue;
            }

            Program storage program = stakingPrograms_[users[msg.sender].programs[i].programId];

            bool isExpired;
            uint256 withdrawalDate = block.timestamp;
            if (program.term > 0) {
                uint256 endTime = users[msg.sender].programs[i].stakingDate.add(program.term);
                if (withdrawalDate >= endTime) {
                    withdrawalDate = endTime;
                    isExpired = true;
                }
            }
            

            uint256 stakingPercent;
            
            if(users[msg.sender].programs[i].programId==0)
            stakingPercent=users[msg.sender].currentPercent;
            else
            stakingPercent=stakingPrograms_[users[msg.sender].programs[i].programId].dailyInterest;

            uint256 amount = _calculateRewards(users[msg.sender].programs[i].stakingToken , stakingPercent , withdrawalDate , users[msg.sender].programs[i].lastWithdrawalDate , stakingPercent);

            withdrawalAmount += amount;
            withdrawalAmount += users[msg.sender].programs[i].genRewards;
            
            users[msg.sender].programs[i].lastWithdrawalDate = withdrawalDate;
            users[msg.sender].programs[i].isExpired = isExpired;
            users[msg.sender].programs[i].currentRewards += amount;
            users[msg.sender].programs[i].genRewards=0;
        }
        
        if(withdrawalAmount>0)
        {
            AuraToken.transfer(msg.sender,withdrawalAmount);
            total_withdraw_busd=total_withdraw_busd+(withdrawalAmount.mul(tokenPrice.div(1e18)));
            total_withdraw_token=total_withdraw_token+(withdrawalAmount);
            emit onWithdraw(msg.sender, total_withdraw_busd,withdrawalAmount);
        }
    }
    
    
    function updateRewards() private
	{
        require(msg.value == 0, "withdrawal doesn't allow to transfer bnb simultaneously");
        uint256 uid = users[msg.sender].id;
        require(uid != 0, "Can not withdraw because no any stakings");
        
        for (uint256 i = 0; i < users[msg.sender].programCount; i++) 
        {
            if (users[msg.sender].programs[i].isExpired) {
                continue;
            }

            Program storage program = stakingPrograms_[users[msg.sender].programs[i].programId];

            bool isExpired = false;
            uint256 withdrawalDate = block.timestamp;
            if (program.term > 0) {
                uint256 endTime = users[msg.sender].programs[i].stakingDate.add(program.term);
                if (withdrawalDate >= endTime) {
                    withdrawalDate = endTime;
                }
            }
            
            uint256 stakingPercent;
            if(users[msg.sender].programs[i].programId==0)
            stakingPercent=users[msg.sender].currentPercent;
            else
            stakingPercent=stakingPrograms_[users[msg.sender].programs[i].programId].dailyInterest;
            
            uint256 amount = _calculateRewards(users[msg.sender].programs[i].stakingToken , stakingPercent , withdrawalDate , users[msg.sender].programs[i].lastWithdrawalDate , stakingPercent);

            users[msg.sender].programs[i].lastWithdrawalDate = withdrawalDate;
            users[msg.sender].programs[i].isExpired = isExpired;
            users[msg.sender].programs[i].currentRewards += amount;
            users[msg.sender].programs[i].genRewards += amount;
        }
    }
    
    function getStakingProgram(address _user) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory,uint256[] memory, bool[] memory) 
    {       
        User storage staker = users[_user];
        uint256[] memory stakingIds = new  uint256[](staker.programCount);
        uint256[] memory stakingDates = new  uint256[](staker.programCount);
        uint256[] memory stakings = new  uint256[](staker.programCount);
        uint256[] memory currentRewards = new  uint256[](staker.programCount);
        bool[] memory isExpireds = new  bool[](staker.programCount);
        uint256[] memory newRewards = new uint256[](staker.programCount);
        uint256[] memory genRewards = new uint256[](staker.programCount);

        for(uint256 i=0; i<staker.programCount; i++){
            require(staker.programs[i].stakingDate!=0,"wrong staking date");
            currentRewards[i] = staker.programs[i].currentRewards;
            genRewards[i] = staker.programs[i].genRewards;
            stakingDates[i] = staker.programs[i].stakingDate;
            stakings[i] = staker.programs[i].stakingToken;
            stakingIds[i] = staker.programs[i].programId;

            uint256 stakingPercent;
            if(staker.programs[i].programId==0)
            stakingPercent=staker.currentPercent;
            else
            stakingPercent=stakingPrograms_[staker.programs[i].programId].dailyInterest;
            
            if (staker.programs[i].isExpired) {
                isExpireds[i] = true;
                
            } else {
                isExpireds[i] = false;
                if (stakingPrograms_[staker.programs[i].programId].term > 0) {
                    if (block.timestamp >= staker.programs[i].stakingDate.add(stakingPrograms_[staker.programs[i].programId].term)) {
                        newRewards[i] = _calculateRewards(staker.programs[i].stakingToken, stakingPercent, staker.programs[i].stakingDate.add(stakingPrograms_[staker.programs[i].programId].term), staker.programs[i].lastWithdrawalDate, stakingPercent);
                        isExpireds[i] = true;
                       
                    }
                    else{
                        newRewards[i] = _calculateRewards(staker.programs[i].stakingToken, stakingPercent, block.timestamp, staker.programs[i].lastWithdrawalDate, stakingPercent);
                      
                    }
                } else {
                    newRewards[i] = _calculateRewards(staker.programs[i].stakingToken, stakingPercent, block.timestamp, staker.programs[i].lastWithdrawalDate, stakingPercent);
                 
                }
            }
        }

        return
        (
        stakingIds,
        stakingDates,
        stakings,
        currentRewards,
        newRewards,
        genRewards,
        isExpireds
        );
    }
    

    function isQualifiedForLevel(address _user) public view returns (bool) 
    {
        if(referrals[_user].length<3)
        return false;
        uint256 totalInvestment;
        uint256 count;
        for(uint256 i=0;i<referrals[_user].length;i++)
        {
            if(users[referrals[_user][i]].totalStakingBusd>=100e18)
            {
                count++;
                totalInvestment=totalInvestment+users[referrals[_user][i]].totalStakingBusd;
            }

            if(count>=3 && totalInvestment>=1000e18)
            return true;
        }  
        if(count>=3 && totalInvestment>=1000e18)
        return true;
        else return false;
    }

	function _calculateRewards(uint256 _amount, uint256 _dailyInterestRate, uint256 _now, uint256 _start , uint256 _maxDailyInterest) private pure returns (uint256) {

        uint256 numberOfDays =  (_now - _start) / INTEREST_CYCLE ;
        uint256 result = 0;
        uint256 index = 0;
        if(numberOfDays > 0){
          uint256 secondsLeft = (_now - _start);
           for (index; index < numberOfDays; index++) {
               if(_dailyInterestRate + index <= _maxDailyInterest ){
                   secondsLeft -= INTEREST_CYCLE;
                     result += (_amount * (_dailyInterestRate + index) / 1000000 * INTEREST_CYCLE) / (24*60*60);
               }
               else
               {
                 break;
               }
            }

            result += (((_amount.mul(_dailyInterestRate)).div(1000000)) * secondsLeft) / (24*60*60);

            return result;

        }else{
            return (_amount * _dailyInterestRate / 1000000 * (_now - _start)) / (24*60*60);
        }

    }   
   	
	
	// ***Staking Percent***
	
	function getStakingPercent(address _user) public view returns(uint16)
	{
	    if(!isUserExists(_user))
        return 0;
	    
	    if(users[_user].totalStakingBusd>=25001*1e18)
	    return 1972;
	    else if(users[_user].totalStakingBusd>=5001*1e18)
	    return 1644;
	    else if(users[_user].totalStakingBusd>=1001*1e18)
	    return 1315;
	    else
	    return 986;
	}

 
	
    function isContract(address _address) public view returns (bool _isContract)
    {
          uint32 size;
          assembly {
            size := extcodesize(_address)
          }
          return (size > 0);
    }   
   
    
   
    
  
    
    function updatePrice(uint256 _price) public payable
    {
       require(msg.sender==owner,"Only Owner");
       tokenPrice=_price;
    }


    function tokenSetting(uint256 _minimumBuy, uint256 _minimumSell, uint256 _buyFee, uint256 _sellFee) public payable
    {
       require(msg.sender==owner,"Only Owner");
       MINIMUM_BUY=_minimumBuy;
       MINIMUM_SELL=_minimumSell;
       BUY_FEE=_buyFee;
       SELL_FEE=_sellFee;
    }
    
    
    function switchStaking(uint8 _type) public payable
    {
        require(msg.sender==owner,"Only Owner");
            if(_type==1)
            stakingOn=true;
            else
            stakingOn=false;
    }
    
    function switchBuy(uint8 _type) public payable
    {
        require(msg.sender==owner,"Only Owner");
            if(_type==1)
            buyOn=true;
            else
            buyOn=false;
    }
    
    
    function switchSell(uint8 _type) public payable
    {
        require(msg.sender==owner,"Only Owner");
            if(_type==1)
            sellOn=true;
            else
            sellOn=false;
    }
    
    
    function isUserExists(address user) public view returns (bool) 
    {
        return (users[user].id != 0);
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}