/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

pragma solidity 0.5.4;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender)
  external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value)  external returns (bool);  
  function transferFrom(address from, address to, uint256 value)  external returns (bool);
  function burn(uint256 value) external;
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

contract GROASIA  {
     using SafeMath for uint256;
     
    struct Staking {
        uint256 programId;
        uint256 stakingDate;
        uint256 staking;
        uint256 lastWithdrawalDate;
        uint256 currentRewards;
        bool    isExpired;
        uint256 stakingToken;
        bool    isAddedStaked;
        uint8   stakingType;
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
        mapping(uint256 => Staking) programs;        
        uint256 referralCount;
        uint256 nextWithdrawDate;
        uint256 restRefIncome;
    }
    
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    
    Program[] private stakingPrograms_;

    uint256[] public REFERRAL_PERCENTS = [40,20,10,5,5,4,4,4,4,4];
    
    uint256 private constant INTEREST_CYCLE = 1 days;

    uint public lastUserId = 2;
    
    uint256 public rewardCapping;    
    
    uint256 public  total_staking_token;

    
    uint256 public  total_withdraw_token;
   
    bool   public  buyOnGRO;
    bool   public  sellOnGRO;
	bool   public  stakingOn;
    uint256 public groTognrFee;
	
    address public owner;
    address public devAddress;
    address public marketingAddress;
    address public rewardWallet;
    address public realEstateWallet;
    address public burningWallet;
 
    
    event Registration(address indexed user, address indexed referrer, uint256 indexed userId, uint256 referrerId);
    event CycleStarted(address indexed user,uint256 stakeID, uint256 totalGNR, uint256 totalGRO, uint256 stakingType);
    event TokenDistribution(address sender, address receiver, IBEP20 tokenFirst, IBEP20 tokenSecond, uint256 tokenIn, uint256 tokenOut);
    event onWithdraw(address  _user, uint256 withdrawalAmountToken);
    event ReferralReward(address  _user, address _from, uint8 level, uint256 reward);
    IBEP20 private gnrToken;
    IBEP20 private groToken; 

    constructor(address ownerAddress, address _devAddress, address _marketingAddress, address _rewardWallet, address _realEstateWallet, address _burningWallet, IBEP20 _groToken, IBEP20 _gnrToken) public 
    {
        owner = ownerAddress;
        devAddress = _devAddress;
        marketingAddress = _marketingAddress;
        rewardWallet = _rewardWallet;
        realEstateWallet = _realEstateWallet;
        burningWallet = _burningWallet;
        gnrToken  = _gnrToken;
        groToken  = _groToken;
        rewardCapping = 3;

        buyOnGRO = true;
        sellOnGRO = true;
	    stakingOn = true;
        
        stakingPrograms_.push(Program(10,300,10)); 
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            programCount: uint(0),
            totalStakingBusd: uint(0),
            totalStakingToken: uint(0),
            referralCount:uint(0),
            nextWithdrawDate:uint(0),
            restRefIncome:uint(0)
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

    function updateFee(uint256 _groTognrFee) public {
        groTognrFee = _groTognrFee;
    }

    function updateCapping(uint256 _rewardCapping) public {
      rewardCapping = _rewardCapping;
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
            programCount:0,
            totalStakingBusd:0,
            totalStakingToken:0,
            referralCount:0,
            nextWithdrawDate:0,
            restRefIncome:0
        });
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        users[referrerAddress].referralCount+=1;
        lastUserId++;        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    
    // Staking Process
    
    function start_staking(uint256 tokenQty, uint256 _programId, address referrer) public 
    {
        require(stakingOn,"Staking Stopped.");
        require(_programId==0, "Wrong staking program id");
         require(tokenQty>=1000*1e18, "Minimum 1000 GNR");
        if(!isUserExists(msg.sender))
	    {
	        registration(msg.sender, referrer);   
	    }
	   
        require(isUserExists(msg.sender), "user not exists");
        require(users[msg.sender].nextWithdrawDate<block.timestamp);   
        uint256 groQty = (tokenQty*1e18)/getGROPrice();
        uint256 stakingReward = (groQty*30)/100;
        uint256 burnQty = (groQty*10)/100;
        groToken.transfer(rewardWallet,(groQty+stakingReward));
        gnrToken.transferFrom(msg.sender, address(this), tokenQty);
        gnrToken.transfer(burningWallet, (tokenQty*10)/100);
        groToken.burn(burnQty);
        uint256 programCount = users[msg.sender].programCount;

        
        users[msg.sender].programs[programCount].programId = _programId;
        users[msg.sender].programs[programCount].stakingDate = block.timestamp;
        users[msg.sender].programs[programCount].lastWithdrawalDate = block.timestamp;
        users[msg.sender].programs[programCount].staking = tokenQty;
        users[msg.sender].programs[programCount].currentRewards = 0;
        users[msg.sender].programs[programCount].isExpired = false;
        users[msg.sender].programs[programCount].stakingToken = groQty;
        users[msg.sender].programs[programCount].stakingType = 1;
        users[msg.sender].programCount = users[msg.sender].programCount.add(1);
        users[msg.sender].nextWithdrawDate=block.timestamp+5 minutes;
        users[msg.sender].totalStakingToken = users[msg.sender].totalStakingToken.add(groQty);
        uint256 treward = groQty+((groQty*30)/100);        
        uint256 newRefReward = (groQty*rewardCapping)-treward;
        users[msg.sender].restRefIncome=0;
        users[msg.sender].restRefIncome+=newRefReward;
	    emit CycleStarted(msg.sender, users[msg.sender].programCount, tokenQty, groQty, 1);
    }

    function real_estate_staking(address _user, address referrer, uint256 tokenQty) public 
    {
        require(msg.sender==devAddress || msg.sender==owner, "Only Owner!");
        require(isUserExists(referrer), "referrer not exists");
        require(users[_user].nextWithdrawDate<block.timestamp);                        
        uint256 groQty = (tokenQty*1e18)/getGROPrice();
        uint256 stakingReward = (groQty*30)/100;
        uint256 burnToken = (groQty*10)/100;
        if(!isUserExists(_user))
	    {
	        registration(_user, referrer);   
	    }	   
        require(isUserExists(_user), "user not exists");
        groToken.transfer(rewardWallet,stakingReward);
        gnrToken.transferFrom(msg.sender,address(this),tokenQty);  
        gnrToken.transfer(burningWallet, (tokenQty*10)/100);       
        gnrToken.transfer(realEstateWallet, (tokenQty*60)/100); 
        groToken.burn(burnToken);
        uint256 programCount = users[_user].programCount;        
        users[_user].programs[programCount].programId = 0;
        users[_user].programs[programCount].stakingDate = block.timestamp;
        users[_user].programs[programCount].lastWithdrawalDate = block.timestamp;
        users[_user].programs[programCount].staking = tokenQty;
        users[_user].programs[programCount].currentRewards = 0;
        users[_user].programs[programCount].isExpired = false;
        users[_user].programs[programCount].stakingToken = groQty;
        users[_user].programs[programCount].stakingType = 2;
        users[_user].programCount = users[_user].programCount.add(1);
        users[_user].nextWithdrawDate=block.timestamp+5 minutes;
        users[_user].totalStakingToken = users[_user].totalStakingToken.add(groQty);
        uint256 treward = groQty+((groQty*30)/100);
        uint256 newRefReward = (groQty*rewardCapping)-treward;
        users[_user].restRefIncome=0;
        users[_user].restRefIncome+=newRefReward;
	    emit CycleStarted(_user, users[_user].programCount, tokenQty, groQty, 2);
    }

     function swapGNRtoGRO(uint256 gnrQty) public payable
	{
	     require(buyOnGRO,"Buy Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");  
	     uint256 totalGRO=(gnrQty*1e18)/getGROPrice();  
         groToken.transfer(msg.sender , totalGRO);
	     gnrToken.transferFrom(msg.sender, address(this), gnrQty);
		 emit TokenDistribution(address(this), msg.sender, gnrToken, groToken, gnrQty, totalGRO);					
	 }


	function swapGROtoGNR(uint256 groQty) public payable
	{
	     require(sellOnGRO,"Sell Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");	     
         uint256 ded=(groQty*groTognrFee)/100;         
         uint256 restToken = groQty-ded;
	     uint256 totalGNR = (restToken*getGROPrice())/1e18;
	     gnrToken.transfer(msg.sender,totalGNR);
         groToken.transferFrom(msg.sender,address(this),groQty);
         if(ded>0)
         groToken.transfer(marketingAddress, ded);
         emit TokenDistribution(msg.sender, address(this), groToken,  gnrToken, groQty, totalGNR);					
	 } 	

	 
     function getGNRtoGRO(uint256 gnrQty) public view returns(uint256)
	{
	    return (gnrQty*1e18)/getGROPrice();      
    }


	function getGROtoGNR(uint256 groQty) public view returns(uint256)
	{
	     uint256 ded=(groQty*groTognrFee)/100;
	     return ((groQty-ded)*getGROPrice())/1e18;
    } 	

     
    
    function withdraw() public payable 
	{
        require(msg.value == 0, "withdrawal doesn't allow to transfer bnb simultaneously");
        require(block.timestamp>users[msg.sender].nextWithdrawDate,"Withdraw after 30 days!");
        uint256 uid = users[msg.sender].id;
        require(uid != 0, "Can not withdraw because no any stakings");
        uint256 withdrawalAmount = 0;
        uint256 amount=0;
        for (uint256 i = 0; i < users[msg.sender].programCount; i++) 
        {
            if (users[msg.sender].programs[i].isExpired) {
                continue;
            }

            Program storage program = stakingPrograms_[users[msg.sender].programs[i].programId];

            bool isExpired = false;
            bool isAddedStaked = false;
            uint256 withdrawalDate = block.timestamp;
            if (program.term > 0) {
                uint256 endTime = users[msg.sender].programs[i].stakingDate.add(program.term);
                if (withdrawalDate >= endTime) {
                    withdrawalDate = endTime;
                    isExpired = true;
                    isAddedStaked=true;
                    if(users[msg.sender].programs[i].stakingType==1)
                    withdrawalAmount+=users[msg.sender].programs[i].stakingToken;
                }
            }
            
            amount += _calculateRewards(users[msg.sender].programs[i].stakingToken , stakingPrograms_[users[msg.sender].programs[i].programId].dailyInterest , withdrawalDate , users[msg.sender].programs[i].lastWithdrawalDate , stakingPrograms_[users[msg.sender].programs[i].programId].dailyInterest);
            
            users[msg.sender].programs[i].lastWithdrawalDate = withdrawalDate;
            users[msg.sender].programs[i].isExpired = isExpired;
            users[msg.sender].programs[i].isAddedStaked = isAddedStaked;
            users[msg.sender].programs[i].currentRewards += amount;            
        }
        address referrerAddress=users[msg.sender].referrer;
        if(msg.sender!=owner)
            {
                for(uint8 j=1; j<=10; j++){
                    uint256 totRef=users[referrerAddress].referralCount;
                if(totRef>=j)
                {
                    uint256 refBonus=(amount.mul(REFERRAL_PERCENTS[j-1])).div(100);
                    if(users[referrerAddress].restRefIncome>0 && users[referrerAddress].nextWithdrawDate>block.timestamp)
                    {
                        if(users[referrerAddress].restRefIncome>refBonus)
                        {
                           groToken.transfer(referrerAddress, refBonus);
                           users[referrerAddress].restRefIncome-=refBonus;
                           emit ReferralReward(referrerAddress, msg.sender, j, refBonus); 
                        }
                        else
                        {
                           groToken.transfer(referrerAddress, users[referrerAddress].restRefIncome);                           
                           emit ReferralReward(referrerAddress, msg.sender, j, users[referrerAddress].restRefIncome); 
                           users[referrerAddress].restRefIncome=0;
                        }
                        
                    }
                    
                }
                if(users[referrerAddress].referrer!=address(0))
                referrerAddress=users[referrerAddress].referrer;
                else
                break;
                }
            }
        withdrawalAmount=withdrawalAmount+amount;
        if(withdrawalAmount>0)
        {
            groToken.transferFrom(rewardWallet, msg.sender, withdrawalAmount);
            total_withdraw_token=total_withdraw_token+(withdrawalAmount);
            emit onWithdraw(msg.sender, withdrawalAmount);
        }
    }
    
    function getStakingProgramByUID(address _user) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, bool[] memory, bool[] memory) 
    {
       
        User storage staker = users[_user];
        uint256[] memory stakingDates = new  uint256[](staker.programCount);
        uint256[] memory stakings = new  uint256[](staker.programCount);
        uint256[] memory currentRewards = new  uint256[](staker.programCount);
        bool[] memory isExpireds = new  bool[](staker.programCount);
        uint256[] memory newRewards = new uint256[](staker.programCount);
        bool[] memory isAddedStakeds = new bool[](staker.programCount);

        for(uint256 i=0; i<staker.programCount; i++){
            require(staker.programs[i].stakingDate!=0,"wrong staking date");
            currentRewards[i] = staker.programs[i].currentRewards;
            isAddedStakeds[i] = staker.programs[i].isAddedStaked;
            stakingDates[i] = staker.programs[i].stakingDate;
            stakings[i] = staker.programs[i].stakingToken;
            
            uint256 stakingPercent=stakingPrograms_[staker.programs[i].programId].dailyInterest;
            
            if (staker.programs[i].isExpired) {
                isExpireds[i] = true;
                newRewards[i] = 0;
                
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
        stakingDates,
        stakings,
        currentRewards,
        newRewards,
        isExpireds,
        isAddedStakeds
        );
    }

    function getGROPrice() public view returns(uint256)
    {
       return ((gnrToken.balanceOf(address(this))*1e18)/groToken.balanceOf(address(this)));
    }
    
    function getStakingToken(address _user) public view returns (uint256[] memory) 
    {
       
        User storage staker = users[_user];
        uint256[] memory stakings = new  uint256[](staker.programCount);

        for(uint256 i=0; i<staker.programCount; i++){
            require(staker.programs[i].stakingDate!=0,"wrong staking date");
            stakings[i] = staker.programs[i].stakingToken;
        }

        return
        (
            stakings
        );
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
                     result += (_amount * (_dailyInterestRate + index) / 1000 * INTEREST_CYCLE) / (10);
               }
               else
               {
                 break;
               }
            }

            result += (((_amount.mul(_dailyInterestRate)).div(1000)) * secondsLeft) / (10);

            return result;

        }else{
            return (_amount * _dailyInterestRate / 1000 * (_now - _start)) / (10);
        }

    }
	
	
    function isContract(address _address) public view returns (bool _isContract)
    {
          uint32 size;
          assembly {
            size := extcodesize(_address)
          }
          return (size > 0);
    }   
   
    function switchStaking(uint8 _type) public payable
    {
        require(msg.sender==owner,"Only Owner");
            if(_type==1)
            stakingOn=true;
            else
            stakingOn=false;
    }
    

    function switchBuyGRO(bool e) public payable
    {
        require(msg.sender==owner,"Only Owner");
            buyOnGRO=e;
    }

    
    function switchSellGRO(bool e) public payable
    {
        require(msg.sender==owner,"Only Owner");
            sellOnGRO=e;
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