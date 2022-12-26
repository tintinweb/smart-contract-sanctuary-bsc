/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

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
    uint256 public tokenPrice=1e17;
    uint256 public rewardCapping;    
    
    uint256 public  total_staking_token;
    uint256 public  total_staking_busd;
    
    uint256 public  total_withdraw_token;
    uint256 public  total_withdraw_busd;
    
    uint256 public  total_gnr_buy;
    uint256 public  total_gro_buy;
    uint256 public  total_gro_sell;
    uint256 public  total_gnr_sell;
	
	bool   public  buyOnGNR;
    bool   public  buyOnGRO;
    bool   public  sellOnGRO;
	bool   public  sellOnGNR;
	bool   public  stakingOn;

    uint256 public busdTognrFee;
    uint256 public gnrTobusdFee;
    uint256 public gnrTogroFee;
    uint256 public groTognrFee;
	
    address public owner;
    address public marketingAddress;
    address public rewardWallet;
 
    
    event Registration(address indexed user, address indexed referrer, uint256 indexed userId, uint256 referrerId);
    event CycleStarted(address indexed user,uint256 stakeID, uint256 totalGNR, uint256 totalGRO);
    event TokenDistribution(address sender, address receiver, IBEP20 tokenFirst, IBEP20 tokenSecond, uint256 tokenIn, uint256 tokenOut);
    event onWithdraw(address  _user, uint256 withdrawalAmount, uint256 withdrawalAmountToken);
    event ReferralReward(address  _user, address _from, uint8 level, uint256 reward);
    IBEP20 private gnrToken;
    IBEP20 private groToken; 
    IBEP20 private busdToken; 

    constructor(address ownerAddress, address _marketingAddress, address _rewardWallet,IBEP20 _busdToken, IBEP20 _groToken, IBEP20 _gnrToken) public 
    {
        owner = ownerAddress;
        marketingAddress = _marketingAddress;
        rewardWallet = _rewardWallet;
        gnrToken  = _gnrToken;
        groToken  = _groToken;
        busdToken = _busdToken;
        rewardCapping = 2;

        buyOnGNR = true;
        buyOnGRO = true;
        sellOnGRO = true;
	    sellOnGNR = true;
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

    function withdrawBalance(uint256 amt,uint8 _type) public 
    {
        require(msg.sender == owner, "onlyOwner");
        if(_type==1)
        msg.sender.transfer(amt);
        else if(_type==2)
        busdToken.transfer(msg.sender,amt);
        else
        groToken.transfer(msg.sender,amt);
    }
    
      function multisend(address payable[]  memory  _contributors, uint256[] memory _balances) public payable 
     {
        require(msg.sender==owner,"Only Owner");
        uint256 i = 0;
        for (i; i < _contributors.length; i++) 
        {
            groToken.transfer(_contributors[i],_balances[i]);
        }
    }

    function updateFee(uint256 _busdTognrFee, uint256 _gnrTobusdFee, uint256 _gnrTogroFee, uint256 _groTognrFee) public {
        busdTognrFee = _busdTognrFee;
        gnrTobusdFee = _gnrTobusdFee;
        gnrTogroFee = _gnrTogroFee;
        groTognrFee = _groTognrFee;
    }

    function updateFee(uint256 _rewardCapping) public {
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
    
    function start_staking(uint256 tokenQty, uint256 _programId,address referrer) public 
    {
        require(stakingOn,"Staking Stopped.");

        require(_programId==0, "Wrong staking program id");
        if(!isUserExists(msg.sender))
	    {
	        registration(msg.sender, referrer);   
	    }
	   
        require(isUserExists(msg.sender), "user not exists");
        require(users[msg.sender].nextWithdrawDate<block.timestamp);
        gnrToken.transferFrom(msg.sender,address(this),tokenQty);
        uint256 groQty = (tokenQty*1e18)/getGROPrice();
        uint256 stakingReward = (groQty*30)/100;
        groToken.transfer(rewardWallet,(groQty+stakingReward));

        require(tokenQty>=1000*1e18, "Minimum 1000 GNR");
        
        uint256 programCount = users[msg.sender].programCount;

        
        users[msg.sender].programs[programCount].programId = _programId;
        users[msg.sender].programs[programCount].stakingDate = block.timestamp;
        users[msg.sender].programs[programCount].lastWithdrawalDate = block.timestamp;
        users[msg.sender].programs[programCount].staking = tokenQty;
        users[msg.sender].programs[programCount].currentRewards = 0;
        users[msg.sender].programs[programCount].isExpired = false;
        users[msg.sender].programs[programCount].stakingToken = groQty;
        users[msg.sender].programCount = users[msg.sender].programCount.add(1);
        users[msg.sender].nextWithdrawDate=block.timestamp+5 minutes;
        users[msg.sender].totalStakingToken = users[msg.sender].totalStakingToken.add(groQty);
        uint256 treward = groQty+((groQty*30)/100);
        uint256 newRefReward = (groQty*rewardCapping)-treward;
        users[msg.sender].restRefIncome+=newRefReward;
	    emit CycleStarted(msg.sender, users[msg.sender].programCount, tokenQty, groQty);
    }

    function swapBUSDtoGNR(uint256 busdQty) public payable
	{
	     require(buyOnGNR,"Buy Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");
         busdToken.transferFrom(msg.sender ,address(this), (busdQty));
         uint256 ded=(busdQty*busdTognrFee)/100;
         busdToken.transfer(marketingAddress, ded);
	     uint256 totalGNR=((busdQty-ded)*1e18)/tokenPrice;  
         gnrToken.transfer(msg.sender , totalGNR);	     
         total_gnr_buy=total_gnr_buy+busdQty;
		 emit TokenDistribution(address(this), msg.sender, busdToken, gnrToken, busdQty, totalGNR);					
	 }

    function swapGNRtoBUSD(uint256 tokenQty) public payable
	{
	     require(sellOnGNR,"Sell Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");    
	     gnrToken.transferFrom(msg.sender,address(this),tokenQty);
         uint256 ded=(tokenQty*gnrTobusdFee)/100;
         gnrToken.transfer(marketingAddress, ded);
         uint256 busd_amt=((tokenQty-ded)/1e18)*tokenPrice;	     
	     busdToken.transfer(msg.sender,busd_amt);
         total_gnr_sell=total_gnr_sell+tokenQty;
         emit TokenDistribution(msg.sender, address(this), gnrToken, busdToken, tokenQty, busd_amt);					
	 } 
	 
     function swapGNRtoGRO(uint256 gnrQty) public payable
	{
	     require(buyOnGRO,"Buy Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");  
	     gnrToken.transferFrom(msg.sender, address(this), gnrQty);
         uint256 ded=(gnrQty*gnrTogroFee)/100;
         gnrToken.transfer(marketingAddress, ded);
	     uint256 totalGRO=((gnrQty-ded)*1e18)/getGROPrice();  
         groToken.transfer(msg.sender , totalGRO);	     
         total_gro_buy=total_gro_buy+gnrQty;
		 emit TokenDistribution(address(this), msg.sender, gnrToken, groToken, gnrQty, totalGRO);					
	 }


	function swapGROtoGNR(uint256 groQty) public payable
	{
	     require(sellOnGRO,"Sell Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");
	     groToken.transferFrom(msg.sender,address(this),groQty);
         uint256 ded=(groQty*groTognrFee)/100;
         groToken.transfer(marketingAddress, ded);
         uint256 restToken = groQty-ded;
	     uint256 totalGNR = (restToken/1e18)*getGROPrice();
	     gnrToken.transfer(msg.sender,totalGNR);
         total_gro_sell=total_gro_sell+groQty;
         emit TokenDistribution(msg.sender, address(this), groToken,  gnrToken, groQty, totalGNR);					
	 } 	

     function getBUSDtoGNR(uint256 busdQty) public view returns(uint256)
     {
         uint256 ded=(busdQty*busdTognrFee)/100;
	     return ((busdQty-ded)*1e18)/tokenPrice;  
     }

    function getGNRtoBUSD(uint256 tokenQty) public view returns(uint256)
	{
         uint256 ded=(tokenQty*gnrTobusdFee)/100;
         return ((tokenQty-ded)/1e18)*tokenPrice;
    } 
	 
     function getGNRtoGRO(uint256 gnrQty) public view returns(uint256)
	{
        uint256 ded=(gnrQty*gnrTogroFee)/100;
	    return ((gnrQty-ded)*1e18)/getGROPrice();      
    }


	function getGROtoGNR(uint256 groQty) public view returns(uint256)
	{
	     uint256 ded=(groQty*groTognrFee)/100;
	     return ((groQty-ded)/1e18)*getGROPrice();
    } 	

     
    
    function withdraw() public payable 
	{
        require(msg.value == 0, "withdrawal doesn't allow to transfer bnb simultaneously");
        require(block.timestamp>users[msg.sender].nextWithdrawDate,"Withdraw after 30 days!");
        uint256 uid = users[msg.sender].id;
        require(uid != 0, "Can not withdraw because no any stakings");
        uint256 withdrawalAmount = 0;
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
                    withdrawalAmount+=users[msg.sender].programs[i].stakingToken;
                }
            }
            
            uint256 amount = _calculateRewards(users[msg.sender].programs[i].stakingToken , stakingPrograms_[users[msg.sender].programs[i].programId].dailyInterest , withdrawalDate , users[msg.sender].programs[i].lastWithdrawalDate , stakingPrograms_[users[msg.sender].programs[i].programId].dailyInterest);

            withdrawalAmount += amount;
            
            users[msg.sender].programs[i].lastWithdrawalDate = withdrawalDate;
            users[msg.sender].programs[i].isExpired = isExpired;
            users[msg.sender].programs[i].isAddedStaked = isAddedStaked;
            users[msg.sender].programs[i].currentRewards += amount;
            address referrerAddress=users[msg.sender].referrer;

            if(msg.sender!=owner)
            {
                for(uint8 j=1; j<=10; j++){
                    uint256 totRef=users[referrerAddress].referralCount;
                if(totRef>=j)
                {
                    uint256 refBonus=(amount.mul(REFERRAL_PERCENTS[i-1])).div(100);
                    if(users[referrerAddress].restRefIncome>0 && users[referrerAddress].nextWithdrawDate>block.timestamp)
                    {
                        if(users[referrerAddress].restRefIncome>refBonus)
                        {
                           groToken.transfer(referrerAddress, refBonus);
                           users[msg.sender].restRefIncome-=refBonus;
                           emit ReferralReward(referrerAddress, msg.sender, j, refBonus); 
                        }
                        else
                        {
                           groToken.transfer(referrerAddress, users[msg.sender].restRefIncome);
                           users[msg.sender].restRefIncome=0;
                           emit ReferralReward(referrerAddress, msg.sender, j, users[msg.sender].restRefIncome); 
                        }
                        
                    }
                    
                }
                if(users[referrerAddress].referrer!=address(0))
                referrerAddress=users[referrerAddress].referrer;
                else
                break;
                }
            }
        }
        
        if(withdrawalAmount>0)
        {
            groToken.transfer(msg.sender,withdrawalAmount);
            total_withdraw_token=total_withdraw_token+(withdrawalAmount);
            emit onWithdraw(msg.sender, total_withdraw_busd,withdrawalAmount);
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
   
    
    function updatePrice(uint256 _price) public payable
    {
              require(msg.sender==owner,"Only Owner"); 
              tokenPrice=_price;
    }
    
    
    function switchStaking(uint8 _type) public payable
    {
        require(msg.sender==owner,"Only Owner");
            if(_type==1)
            stakingOn=true;
            else
            stakingOn=false;
    }
    
    function switchBuyGNR(bool e) public payable
    {
        require(msg.sender==owner,"Only Owner");
            buyOnGNR=e;
    }

    function switchBuyGRO(bool e) public payable
    {
        require(msg.sender==owner,"Only Owner");
            buyOnGRO=e;
    }
    
    function switchSellGNR(bool e) public payable
    {
        require(msg.sender==owner,"Only Owner");
            sellOnGNR=e;
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