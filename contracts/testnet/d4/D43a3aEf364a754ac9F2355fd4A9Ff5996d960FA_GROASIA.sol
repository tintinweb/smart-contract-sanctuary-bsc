/**
 *Submitted for verification at BscScan.com on 2022-12-24
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
        uint256 genRewards;
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
        uint256 airdropReward;
        mapping(uint256 => Staking) programs;        
        uint256 referralCount;
    }
    
    
    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    
    Program[] private stakingPrograms_;

    uint256[] public REFERRAL_PERCENTS = [50,20,10,5,3,2,1,1,1,1,1,1,1,1,1,1];
    
    uint256 private constant INTEREST_CYCLE = 1 days;

    uint public lastUserId = 2;
    uint256 public tokenPrice=1e17;
    
    
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
	
	uint256 public  MINIMUM_BUY;
	uint256 public  MINIMUM_SELL;
    uint256 public  MAXIMUM_BUY;
	uint256 public  MAXIMUM_SELL;

    uint256 public liquidityFee;
	
    address public owner;
 
    
    event Registration(address indexed user, address indexed referrer, uint256 indexed userId, uint256 referrerId);
    event CycleStarted(address indexed user,uint256 stakeID, uint256 totalToken);
    event TokenDistribution(address sender, address receiver, IBEP20 tokenFirst, IBEP20 tokenSecond, uint256 tokenIn, uint256 tokenOut);
    event onWithdraw(address  _user, uint256 withdrawalAmount, uint256 withdrawalAmountToken);
    event ReferralReward(address  _user, address _from, uint8 level, uint256 rewardGNR, uint256 rewardGRO);
    IBEP20 private gnrToken;
    IBEP20 private groToken; 
    IBEP20 private busdToken; 

    constructor(address ownerAddress, IBEP20 _busdToken, IBEP20 _groToken, IBEP20 _gnrToken) public 
    {
        owner = ownerAddress;
        gnrToken  = _gnrToken;
        groToken  = _groToken;
        busdToken = _busdToken;
        
        stakingPrograms_.push(Program(10,30*24*60*60,10)); 
        
        User memory user = User({
            id: 1,
            referrer: address(0),
            programCount: uint(0),
            totalStakingBusd: uint(0),
            totalStakingToken: uint(0),
            airdropReward:uint(0),
            referralCount:uint(0)
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

    function updateSetting(uint256 _MINIMUM_BUY, uint256 _MINIMUM_SELL, uint256 _MAXIMUM_BUY, uint256 _MAXIMUM_SELL, uint256 _liquidityFee) public {
        MINIMUM_BUY  = _MINIMUM_BUY;
        MINIMUM_SELL = _MINIMUM_SELL;
        MAXIMUM_BUY  = _MAXIMUM_BUY;
        MAXIMUM_SELL = _MAXIMUM_SELL;
        liquidityFee = _liquidityFee;
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
            airdropReward:0,
            referralCount:0
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
        

        require(gnrToken.balanceOf(msg.sender)>=tokenQty,"Low wallet balance");
        require(gnrToken.allowance(msg.sender,address(this))>=tokenQty,"Allow token first");
      
        gnrToken.transferFrom(msg.sender,address(this),tokenQty);

        require(tokenQty>=1000*1e18, "Minimum 1000 GNR");
        
        uint256 programCount = users[msg.sender].programCount;

        
        users[msg.sender].programs[programCount].programId = _programId;
        users[msg.sender].programs[programCount].stakingDate = block.timestamp;
        users[msg.sender].programs[programCount].lastWithdrawalDate = block.timestamp;
        users[msg.sender].programs[programCount].staking = tokenQty;
        users[msg.sender].programs[programCount].currentRewards = 0;
        users[msg.sender].programs[programCount].genRewards = 0;
        users[msg.sender].programs[programCount].isExpired = false;
        users[msg.sender].programs[programCount].stakingToken = tokenQty;
        users[msg.sender].programCount = users[msg.sender].programCount.add(1);
        
        users[msg.sender].totalStakingToken = users[msg.sender].totalStakingToken.add(tokenQty);
        address referrerAddress=users[msg.sender].referrer;
        
        if(msg.sender!=owner)
        {
            for(uint8 i=1; i<=16; i++){
                uint256 totRef=users[referrerAddress].referralCount;
            if((totRef>=i) || (totRef>=8 && (i==8 || i==9)) || (totRef>=9 && (i>=10 || i<=12)) || totRef>9)
            {
                uint256 refBonus=(tokenQty.mul(REFERRAL_PERCENTS[i-1])).div(100);
                groToken.transfer(referrerAddress,((refBonus*1e18)/getGROPrice()));
                emit ReferralReward(referrerAddress, msg.sender, i, refBonus, (refBonus*1e18)/getGROPrice());
            }
            if(users[referrerAddress].referrer!=address(0))
            referrerAddress=users[referrerAddress].referrer;
            else
            break;
            }
        }
	
	    emit CycleStarted(msg.sender, users[msg.sender].programCount, tokenQty);
    }

    function buyGNR(uint256 tokenQty) public payable
	{
	     require(buyOnGNR,"Buy Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");
	     require(tokenQty>=MINIMUM_BUY,"Invalid minimum quantity");
	     uint256 buy_amt=(tokenQty/1e18)*tokenPrice;
	     require(busdToken.balanceOf(msg.sender)>=(buy_amt),"Low Balance");
	     require(busdToken.allowance(msg.sender,address(this))>=buy_amt,"Invalid buy amount");
	     
	     busdToken.transferFrom(msg.sender ,address(this), (buy_amt));
	     gnrToken.transfer(msg.sender , (tokenQty-((tokenQty*liquidityFee)/100)));
	     
         total_gnr_buy=total_gnr_buy+tokenQty;
		 emit TokenDistribution(address(this), msg.sender, busdToken, gnrToken, buy_amt, tokenQty);					
	 }

    function sellGNR(uint256 tokenQty) public payable
	{
	     require(sellOnGNR,"Sell Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");
	     require(tokenQty>=MINIMUM_SELL,"Invalid minimum quantity");         
	     require(gnrToken.balanceOf(msg.sender)>=(tokenQty),"Low Balance");
	     require(gnrToken.allowance(msg.sender,address(this))>=tokenQty,"Invalid buy amount");

	     gnrToken.transferFrom(msg.sender,address(this),tokenQty);
	     uint256 busd_amt=(tokenQty-((tokenQty*liquidityFee)/100))*tokenPrice;
	     
	     busdToken.transfer(msg.sender,busd_amt);
         total_gnr_sell=total_gnr_sell+tokenQty;
         emit TokenDistribution(msg.sender, address(this), gnrToken, busdToken, tokenQty, busd_amt);					
	 } 
	 
    function swapGNRtoGRO(uint256 tokenQty) public payable
	{
	     require(buyOnGRO,"Buy Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");
	     require(tokenQty>=MINIMUM_BUY,"Invalid minimum quantity");	    
	     require(gnrToken.balanceOf(msg.sender)>=(tokenQty),"Low Balance");
	     require(gnrToken.allowance(msg.sender,address(this))>=tokenQty,"Invalid buy amount");
         gnrToken.transferFrom(msg.sender, address(this), tokenQty);
	     uint256 restToken = tokenQty-((tokenQty*liquidityFee)/100);
	     uint256 totalGRO = (restToken*1e18)/getGROPrice();
	     groToken.transfer(msg.sender, totalGRO);
	     
         total_gro_buy=total_gro_buy+tokenQty;
		 emit TokenDistribution(address(this), msg.sender, gnrToken, groToken, tokenQty, totalGRO);
	 }


	function swapGROtoGNR(uint256 tokenQty) public payable
	{
	     require(sellOnGRO,"Sell Stopped.");
	     require(!isContract(msg.sender),"Can not be contract");
	     require(tokenQty>=MINIMUM_SELL,"Invalid minimum quantity");

	     require(groToken.balanceOf(msg.sender)>=(tokenQty),"Low Balance");
	     require(groToken.allowance(msg.sender,address(this))>=tokenQty,"Invalid buy amount");
	     groToken.transferFrom(msg.sender,address(this),tokenQty);

         uint256 restToken = tokenQty-((tokenQty*liquidityFee)/100);
	     uint256 totalGNR = (restToken/1e18)*getGROPrice();

	     gnrToken.transfer(msg.sender,totalGNR);
         total_gro_sell=total_gro_sell+tokenQty;
         emit TokenDistribution(msg.sender, address(this), groToken,  gnrToken, tokenQty, totalGNR);					
	 } 	
    
    function withdraw() public payable 
	{
        require(msg.value == 0, "withdrawal doesn't allow to transfer bnb simultaneously");
        uint256 uid = users[msg.sender].id;
        require(uid != 0, "Can not withdraw because no any stakings");
        uint256 withdrawalAmount = 0;
        for (uint256 i = 0; i < users[msg.sender].programCount; i++) 
        {
            if (users[msg.sender].programs[i].isExpired) {
                users[msg.sender].programs[i].genRewards=0;
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
                    
                    if(users[msg.sender].programs[i].programId==0)
                    {
                        uint256 programCount = users[msg.sender].programCount;
                        users[msg.sender].programs[programCount].programId = 1;
                        users[msg.sender].programs[programCount].stakingDate = endTime;
                        users[msg.sender].programs[programCount].lastWithdrawalDate = endTime;
                        users[msg.sender].programs[programCount].staking = users[msg.sender].programs[i].staking;
                        users[msg.sender].programs[programCount].currentRewards = 0;
                        users[msg.sender].programs[programCount].genRewards = 0;
                        users[msg.sender].programs[programCount].isExpired = false;
                        users[msg.sender].programs[programCount].stakingToken = users[msg.sender].programs[i].stakingToken;
                        users[msg.sender].programCount = users[msg.sender].programCount.add(1);
                    }
                }
            }
            
            uint256 amount = _calculateRewards(users[msg.sender].programs[i].stakingToken , stakingPrograms_[users[msg.sender].programs[i].programId].dailyInterest , withdrawalDate , users[msg.sender].programs[i].lastWithdrawalDate , stakingPrograms_[users[msg.sender].programs[i].programId].dailyInterest);

            withdrawalAmount += amount;
            withdrawalAmount += users[msg.sender].programs[i].genRewards;
            
            users[msg.sender].programs[i].lastWithdrawalDate = withdrawalDate;
            users[msg.sender].programs[i].isExpired = isExpired;
            users[msg.sender].programs[i].isAddedStaked = isAddedStaked;
            users[msg.sender].programs[i].currentRewards += amount;
            users[msg.sender].programs[i].genRewards=0;
        }
        
        if(withdrawalAmount>0)
        {
            groToken.transfer(msg.sender,withdrawalAmount);
            total_withdraw_busd=total_withdraw_busd+(withdrawalAmount.mul(tokenPrice.div(1e18)));
            total_withdraw_token=total_withdraw_token+(withdrawalAmount);
            emit onWithdraw(msg.sender, total_withdraw_busd,withdrawalAmount);
        }
    }
    
    function getStakingProgramByUID(address _user) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory,uint256[] memory, bool[] memory, bool[] memory) 
    {
       
        User storage staker = users[_user];
        uint256[] memory stakingDates = new  uint256[](staker.programCount);
        uint256[] memory stakings = new  uint256[](staker.programCount);
        uint256[] memory currentRewards = new  uint256[](staker.programCount);
        bool[] memory isExpireds = new  bool[](staker.programCount);
        uint256[] memory newRewards = new uint256[](staker.programCount);
        uint256[] memory genRewards = new uint256[](staker.programCount);
        bool[] memory isAddedStakeds = new bool[](staker.programCount);

        for(uint256 i=0; i<staker.programCount; i++){
            require(staker.programs[i].stakingDate!=0,"wrong staking date");
            currentRewards[i] = staker.programs[i].currentRewards;
            genRewards[i] = staker.programs[i].genRewards;
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
        genRewards,
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
                     result += (_amount * (_dailyInterestRate + index) / 100000 * INTEREST_CYCLE) / (24*60*60);
               }
               else
               {
                 break;
               }
            }

            result += (((_amount.mul(_dailyInterestRate)).div(100000)) * secondsLeft) / (24*60*60);

            return result;

        }else{
            return (_amount * _dailyInterestRate / 100000 * (_now - _start)) / (24*60*60);
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