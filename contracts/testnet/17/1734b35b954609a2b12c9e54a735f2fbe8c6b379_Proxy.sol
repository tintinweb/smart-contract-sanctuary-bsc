/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;
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
        
        uint256 c = a / b;
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

    function ceil(uint a, uint m) internal pure returns (uint r) {
        return (a + m - 1) / m * m;
    }
    }

contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}


interface IToken {
    function decimals() external view returns (uint256);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function burnTokens(uint256 _amount) external;
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function approve(address _spender, uint256 _amount) external returns (bool success);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}



interface IProxy{
    function getTierUserCount(uint _tier) external view returns (uint);
    function getAllocationToken() external returns (uint256);
    function tierAllocationPerUser(uint256 supply,uint _tier) external view returns (uint256);
    function getUsertier(address _address) external view returns (uint256);
}

contract BitdriveLaunchpad is Owned {
    using SafeMath for uint256;
    address public tokenAddress; // buy
    uint256 public tokenDecimals = 18;
    
    address public _crypto; // cool
    address public PROXY;

    struct UserInfo {
        uint256 investAmount1;
        uint256 investAmount2;
        uint256 remainingallocationAmount1;
        uint256 remainingallocationAmount2;
        bool isExits;
        bool isround2; 
        uint256 SwapTokens;
        uint256 round1Tokens;
        uint256 round2Tokens;
        uint256 round3Tokens;
        uint256 lastClaimed;
        uint256 totalVesting;
    }

    mapping (address => UserInfo) public userInfo;

    uint256 public tokensPerBusd;
    uint256 public rateDecimals = 0;
    
    uint256 public soldTokens=0;
    
    uint256 public endTime = 2 days;
    uint256 public round1Start;
    
    uint256 public round2Start;
    
    uint256 public round3Start;
    uint256 public end ;
    
    uint256 public round2Eligible;
    
    uint256 public hardCap;
    
    uint256 public earnedCap =0;
    
    uint256 public currentPoolId = 0;
    bool public isVest;
    uint256 public vestDays;
    uint256 public vestPercent;
    
    constructor(
        address _tokenAddress,
        uint256 _tokensPerBusd,
        uint256 _hardCap,
        uint256 _poolId,
        address _owner,
        uint256 _round1,
        uint256 _round2,
        uint256 _round3,
        uint256 _end,
        address _busdAddress,
        bool _isVest,
        uint256 _vestPercent,
        uint256 _vestDays
    ) public {
        tokenAddress = _tokenAddress;
        tokensPerBusd = _tokensPerBusd;  // 1 means 1000
        hardCap = _hardCap;
        currentPoolId = _poolId;
        owner = payable(_owner);
        PROXY = msg.sender;
        round1Start = _round1;
        round2Start = _round2;
        round3Start = _round3;
        end = _end;
        isVest = _isVest;
        vestPercent = _vestPercent;
        vestDays = _vestDays;
        _crypto = _busdAddress;
    }
  
    function getTokenPerBusd(address _userAddress) public view returns(uint256){
        uint getTier = IProxy(PROXY).getUsertier(_userAddress);
        uint256 perBusdToken = IProxy(PROXY).tierAllocationPerUser(hardCap,getTier);
        return perBusdToken; // original value id should divide by 1e18
    }

    function checkBronzeUserCount() internal view returns(uint){
        return IProxy(PROXY).getTierUserCount(1);
    }

    function getTokenPerUser() public view returns(uint256){
        //get Bronze Users 
            uint256 brozeUser = checkBronzeUserCount();
            uint256 round2Users = brozeUser + round2Eligible;
            uint soldAmount = soldTokens/1e18;
            uint256 remainingTokens =  (hardCap>=soldAmount)?hardCap - soldAmount:0;
            uint256 eachTier = (remainingTokens * 1e18)/round2Users;
        // uint256 perBusdRound2   = eachTier / tokensPerBusd;
            uint256 perBusdRound2   = eachTier;
            return perBusdRound2;
    }

    function getUserAllocationRound1(address _userAddress) public view returns(uint256){
        uint256 remainingAllocation = getTokenPerBusd(msg.sender);
        uint256 remainingallocationAmount = remainingAllocation - userInfo[_userAddress].investAmount1;
        return remainingallocationAmount;
    }
    function getUserAllocationRound1test(address _userAddress) public view returns(uint256,uint256,uint256){
        uint256 remainingAllocation = getTokenPerBusd(msg.sender);
        uint256 remainingallocationAmount = remainingAllocation - userInfo[_userAddress].investAmount1;
        return (remainingAllocation,userInfo[_userAddress].investAmount1,remainingallocationAmount);
    }

    function getUserAllocationRound2(address _userAddress) public view returns(uint256){
        uint256 remainingAllocation = getTokenPerUser();
        uint256 remainingallocationAmount = remainingAllocation - userInfo[_userAddress].investAmount2;
        return remainingallocationAmount;
    }

    function buyTokenRound1(uint256 amount) public {
        require(block.timestamp >= round1Start, "Presale is not open.");
        require(block.timestamp < round2Start, "Sale Closed.");
        require(earnedCap <= hardCap * 1e18 ,"Reached hardCap");
        //check user remaining allocation
        uint getTier = IProxy(PROXY).getUsertier(msg.sender);
        require(getTier > 1, "Not a valid User");
        uint256 remainingAllocation = getTokenPerBusd(msg.sender);
        userInfo[msg.sender].investAmount1 += amount;
        userInfo[msg.sender].isExits = true;
        require(remainingAllocation >= userInfo[msg.sender].investAmount1,"Amount not exceed");
        require(IToken(_crypto).transferFrom(msg.sender,address(this), amount),"Insufficient balance from User");
        userInfo[msg.sender].remainingallocationAmount1 = remainingAllocation - userInfo[msg.sender].investAmount1;
        uint256 swappedToken = (tokensPerBusd * amount) / 1000;
        userInfo[msg.sender].SwapTokens += swappedToken;
        userInfo[msg.sender].round1Tokens += swappedToken;
            if(!userInfo[msg.sender].isround2){
            uint halfAmount = remainingAllocation/2;
            if(userInfo[msg.sender].investAmount1 >= halfAmount){
                userInfo[msg.sender].isround2 = true;
                round2Eligible++;
            }
        }
        earnedCap += userInfo[msg.sender].investAmount1;   
        soldTokens += swappedToken;
    }  

    function buyTokenRound2(uint256 amount) public {
        require(block.timestamp >= round2Start, "Not started.");
        require(block.timestamp < round3Start, "Sale Closed.");
        require(earnedCap <= hardCap * 1e18 ,"Reached hardCap");
        //check user remaining allocation
        uint256 remainingAllocation = getTokenPerUser(); 
        userInfo[msg.sender].isExits = true;
        userInfo[msg.sender].investAmount2 += amount;
        uint getTier = IProxy(PROXY).getUsertier(msg.sender);
        require(userInfo[msg.sender].isround2 || getTier == 0,"User Not eligible to participate");
        require(remainingAllocation >= userInfo[msg.sender].investAmount2,"Amount not exceed");
        require(IToken(_crypto).transferFrom(msg.sender,address(this), amount),"Insufficient balance from User");
        userInfo[msg.sender].remainingallocationAmount2 = remainingAllocation - userInfo[msg.sender].investAmount2;
        uint256 swappedToken = (tokensPerBusd * amount) / 1000;
        userInfo[msg.sender].SwapTokens += swappedToken;
        userInfo[msg.sender].round2Tokens += swappedToken;
        earnedCap += userInfo[msg.sender].investAmount2;
        soldTokens += swappedToken;
    }

    function buyTokenRound3(uint256 amount) public {
        require(block.timestamp >= round3Start, "Not started.");
        require(block.timestamp < end, "Sale Closed.");
        require(earnedCap <= hardCap * 1e18 ,"Reached hardCap");
        require(IToken(_crypto).transferFrom(msg.sender,address(this), amount),"Insufficient balance from User");
        //check user remaining allocation
        uint256 swappedToken = (tokensPerBusd * amount) / 1000;
        userInfo[msg.sender].SwapTokens += swappedToken;
        userInfo[msg.sender].round3Tokens += swappedToken;
        earnedCap += amount;
        soldTokens += swappedToken;
    }


    function claimToken() public {
        require(block.timestamp > end, "Sale Not Closed.");
        require(userInfo[msg.sender].SwapTokens > 0,"You already taken");
        if(!isVest){
            uint256 transferAmount = userInfo[msg.sender].SwapTokens;
            IToken(tokenAddress).transfer(msg.sender,transferAmount);
        }else{
            require( block.timestamp > userInfo[msg.sender].lastClaimed * vestDays * 1 days, "Vesting period error");
            userInfo[msg.sender].totalVesting += vestPercent;
            uint256 vestRemainingPercent = vestPercent;

                uint256 toTransfer =  userInfo[msg.sender].SwapTokens.mul(vestRemainingPercent).div(10000);
            require(IToken(tokenAddress).transfer(msg.sender, toTransfer), "Insufficient balance of presale contract!");
            
            if(userInfo[msg.sender].totalVesting > 10000){
                vestRemainingPercent = 10000 - (userInfo[msg.sender].totalVesting - vestPercent);
                userInfo[msg.sender].SwapTokens = 0;
            }else{
                    userInfo[msg.sender].SwapTokens = userInfo[msg.sender].SwapTokens.sub(toTransfer);
            }
            userInfo[msg.sender].lastClaimed = block.timestamp; 
        }
        
    }

    function setTokenAddress(address token) external onlyOwner {
        tokenAddress = token;
    }

    function setCurrentPoolId(uint256 _pid) external onlyOwner {
        currentPoolId = _pid;
    }
    
    function setTokenDecimals(uint256 decimals) external onlyOwner {
        tokenDecimals = decimals;
    }
    
    function setCryptoAddress(address token) external onlyOwner {
        _crypto = token;
    }
    
    function setRoundtiming(uint256 _round1,uint256 _round2,uint256 _round3,uint256 _end) external onlyOwner {
        require(_round1 > block.timestamp && _round2 > _round1 && _round3 > _round2 && _end > _round3, "Invalid time" );
        round1Start = _round1;
        round2Start = _round2;
        round3Start = _round3;
        end = _end;
    }
    
    function settokensPerBusd(uint256 tokenPerBusd) external onlyOwner {
        tokensPerBusd = tokenPerBusd;
    }
    
    function setRateDecimals(uint256 decimals) external onlyOwner {
        rateDecimals = decimals;
    }
    
    function setHardCap(uint256 _hardCap) public onlyOwner{
        hardCap = _hardCap;
    }
    
    function getUnsoldTokensBalance() public view returns(uint256) {
        return IToken(tokenAddress).balanceOf(address(this));
    }
    
    function burnUnsoldTokens() external onlyOwner {
        require(block.timestamp > end, "You cannot burn tokens untitl the presale is closed.");
        IToken(tokenAddress).burnTokens(IToken(tokenAddress).balanceOf(address(this)));   
    }
    
    function getUnsoldTokens() external onlyOwner {
        require(block.timestamp > end, "You cannot get tokens until the presale is closed.");
        soldTokens = 0;
        IToken(tokenAddress).transfer(owner, (IToken(tokenAddress).balanceOf(address(this))));
    }

    function getBusdTokens() external onlyOwner {
        require(block.timestamp > end, "You cannot get tokens until the presale is closed.");
        IToken(_crypto).transfer(owner, (IToken(_crypto).balanceOf(address(this))));
    }
}


contract Proxy {
    mapping(address => address) public _presale;
    uint256 public stakeDays;
    IToken public tokenAddress;
    struct UserInfo {
        uint256 depositamount;
        uint256 tier;
        bool isExits; 
        uint256 investTime;
    }

    mapping (address => UserInfo) public userInfo;
    mapping (uint => uint) public STAKING_PRICE;
    mapping (uint => uint) public POOL_WEIGHT;
    uint public Bronzeusers;
    uint public Silverusers;
    uint public Goldusers;
    uint public Diamondusers;
    uint public totalparticipant;
    address public ownerAddress;

    constructor(IToken _tokenAddress,uint256 _stakeDays) public {
        tokenAddress = IToken(_tokenAddress);
        STAKING_PRICE[1]  = 10*1e18;
        STAKING_PRICE[2]  = 100*1e18;
        STAKING_PRICE[3]  = 500*1e18;
        STAKING_PRICE[4]  = 1000*1e18;
        POOL_WEIGHT[1]  = 10;
        POOL_WEIGHT[2]  = 30;
        POOL_WEIGHT[3]  = 60;
        stakeDays = _stakeDays;
        ownerAddress = msg.sender;
    }

    function deposit(uint256 _amount) public {
        require(!userInfo[msg.sender].isExits, "User already exist" );
        require( (IToken(tokenAddress).balanceOf(msg.sender)) > STAKING_PRICE[1] && _amount > STAKING_PRICE[1] ,"You dont have minimum balance");
        require(IToken(tokenAddress).transferFrom(msg.sender,address(this), _amount),"Insufficient balance from User");
        totalparticipant++;
        uint tier;
        if(_amount >= STAKING_PRICE[1] && _amount < STAKING_PRICE[2]){
            Bronzeusers++;
            tier = 1;
        }else if(_amount >= STAKING_PRICE[2] && _amount < STAKING_PRICE[3]){
            Silverusers++;
            tier = 2;
        }else if(_amount >= STAKING_PRICE[3] && _amount < STAKING_PRICE[4]){
            Goldusers++;
            tier = 3;
        }else if(_amount >= STAKING_PRICE[4]){
            Diamondusers++;
            tier = 4;
        }
        userInfo[msg.sender].isExits = true;
        userInfo[msg.sender].tier = tier;
        userInfo[msg.sender].investTime = block.timestamp;
        userInfo[msg.sender].depositamount = _amount;
    }

    function withdraw() public {
        require(userInfo[msg.sender].isExits, "User not exist" );
        uint256 endTime = userInfo[msg.sender].investTime + stakeDays * 1 days;
        require(endTime > block.timestamp , "Lock period not completed");

        IToken(tokenAddress).transfer(msg.sender,  userInfo[msg.sender].depositamount);

        totalparticipant--;
        uint tier =  userInfo[msg.sender].tier;
        if(tier == 1){
            Bronzeusers--;
        }else if(tier == 2){
            Silverusers--;
        }else if(tier == 3){
            Goldusers--;
        }else if(tier == 4){
            Diamondusers--;
        }
        userInfo[msg.sender].isExits = false;
        userInfo[msg.sender].tier = 0;
    }

    function getTierUserCount(uint _tier) public view returns (uint){
        uint tierCount;
        if( _tier == 1){
            tierCount = Bronzeusers;
        }else if( _tier == 2){
            tierCount = Silverusers;
        }else if( _tier == 3){
            tierCount = Goldusers;
        }else if( _tier == 4){
            tierCount = Diamondusers;
        }
        return tierCount;
    }

    function createPresale( address _tokenAddress,
        uint256 _tokensPerBusd,
        uint256 _hardCap,
        uint256 _poolId,
        uint256 _round1start,
        uint256 _round2start,
        uint256 _round3start,
        uint256 _end,
        address _busdAddress,
        bool isVest,
        uint256 vestPercent, // 1 means 100
        uint256 vestDays
        ) public {
            require(ownerAddress == msg.sender, "Not an Owner");   
        _presale[_tokenAddress] = address(new BitdriveLaunchpad(_tokenAddress,_tokensPerBusd,_hardCap,_poolId,msg.sender,_round1start,_round2start,_round3start,_end,_busdAddress,isVest,vestPercent,vestDays));
    }

    function getAllocationToken() public view returns(uint256){
        return (Silverusers * POOL_WEIGHT[1])+(Goldusers * POOL_WEIGHT[2])+(Diamondusers * POOL_WEIGHT[3]);
    }
    
    function tierAllocationPerUser(uint256 maxSupply,uint _tier) public view returns (uint256) {
        uint256 getallocationToken = getAllocationToken();
        uint256 eachTier = (maxSupply/getallocationToken) * 1e18;
        uint256 silverAllocation = Silverusers * eachTier * POOL_WEIGHT[1];
        uint256 goldAllocation = Goldusers * eachTier * POOL_WEIGHT[2];
        uint256 diamondAllocation = Diamondusers * eachTier * POOL_WEIGHT[3];
        uint256 allocToken = 0;
        if(_tier == 2 && Silverusers > 0)
          allocToken = silverAllocation / Silverusers;
        if(_tier == 3 && Goldusers > 0)
          allocToken = goldAllocation / Goldusers;
        if(_tier == 4 && Diamondusers > 0)
          allocToken = diamondAllocation / Diamondusers;
        
        return allocToken;
    }

    function getUsertier(address _useraddress) public view returns(uint256){
        return userInfo[_useraddress].tier;
    }
  

    function getPresale(address _token) public view returns (address){
        return _presale[_token];
    }
    function setStakeDays(uint256 _days) public {
        require(ownerAddress == msg.sender, "Not an Owner");   
        stakeDays = _days;
    }
}