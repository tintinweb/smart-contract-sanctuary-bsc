// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./crycoll.sol";

contract CrycollBank is ICrycollBank {
    using SafeMath for uint256;
    IBEP20 bep_token;

    struct BankAccount {
        uint256 sharesAmount;
        uint256 totalRealised;
        uint256 unlockedTokens;
        uint256 lockedTokens;
		uint256 unpaidSocialRewards;
		uint256 totalPaidSocialRewards;
		address ambassador;
        uint256 locksCount;
        uint256 refferalsCount;
    }

    struct Locker {
        uint256 sharesFromLock;		
        uint256 lockAmount;
        uint256 unlockTime;
        uint256 lockTime;
    }

    IBEP20 BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public tokenAddress = 0xDb5f6dF84f043eF5546F12DA6Ec079D289094810;
    address DATAPROVIDER;
    address owner;
    IDEXRouter router;
    address dexRouter_;

    address[] public clients;
    mapping (address => uint256) clientIndexes;
    mapping (address => uint256) totalExcluded;
    mapping (address => uint256) previousUnpaidDividend;
    mapping (address => bool) accountCreated;
    mapping (string => bool[10]) nameIsTaken;    
    string[10] label;

    mapping (address => BankAccount) public account;
    mapping (address => Locker[]) public tokensLocker; 
    mapping (address => string[10]) public social;   

    uint256 public totalShares;
    uint256 public dividendPool;
    uint256 public totalLockedTokens;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 public minTokens = 400 * (10 ** 18);
    uint256 public minTokensAmbassador = minTokens.mul(5);
    uint256 public annualShareMultiplier = 200;
    uint256 public penaltyPercentage = 50;
    uint256 public maxAnnualRewardFactor = 40;
    uint256 public IntervalCreatePool = 7 days;
    uint256 public lowerLimiter = 1;
    uint256 public upperLimiter = 365;
    uint256 public maxLeverage = 5;
    uint256 public leverageFeeFactor = 4;
    uint256 public minTimeToReward = 40;
    uint256 public createPoolTimestamp;
    uint256 currentIndex;
    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
       require(msg.sender == tokenAddress); _;
    }

    modifier onlyClient() {
     require(accountCreated[msg.sender], "You are not a client"); _;
    }    

    constructor () {
        owner = msg.sender;
        dexRouter_ = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        DATAPROVIDER = 0xCA4258aE0EBb571DF3D1D91Ce3290b2cfEbc58A9;
        router = IDEXRouter(dexRouter_);
        bep_token = IBEP20(tokenAddress);    
    }

    modifier onlyDATAPROVIDER() {
       require(msg.sender == DATAPROVIDER, "!DATAPROVIDER"); _;
    }

    modifier onlyOwner() {
       require(msg.sender == owner, "!OWNER"); _;
    } 

    receive() external payable { }

    function lockTokens(uint256 amount, uint256 lockTime, uint256 leverage) external onlyClient{
        require(amount <= account[msg.sender].unlockedTokens  && amount > 0
        && account[msg.sender].unlockedTokens > 0, "Not enough unlocked tokens");     
        locker(msg.sender, amount, lockTime, leverage);
    }

    function locker(address client, uint256 amount, uint256 lockTime, uint256 leverage) internal {
        previousUnpaidDividend[client] = getUnpaidEarnings(client);

        uint256 lockIndex = tokensLocker[client].length;
        tokensLocker[client].push();

        if(lockTime < lowerLimiter ){ lockTime = lowerLimiter; }
        else if(lockTime > upperLimiter ){ lockTime = upperLimiter; }

        tokensLocker[client][lockIndex].lockTime = lockTime;
        account[client].unlockedTokens = account[client].unlockedTokens.sub(amount);      

        uint256 mulAmount = amount.div(100).mul(((lockTime.mul(annualShareMultiplier)).div(365)));
        mulAmount = mulAmount.add(amount);

        uint256 rewardAmount = amount.mul(maxAnnualRewardFactor.mul(lockTime).div(365)).div(200);
        uint256 leverageFeeReduction;
        address ambassador = account[client].ambassador;		
		if(lockTime >= minTimeToReward
        && amount >= minTokens 
        && bep_token.shouldPrintTokens() 
        && rewardAmount > 0
        && account[ambassador].lockedTokens >= minTokensAmbassador){
            uint256 totalRewardAmount;
            account[ambassador].unlockedTokens = account[ambassador].unlockedTokens.add(rewardAmount);   
            account[ambassador].refferalsCount++;
            totalRewardAmount = totalRewardAmount.add(rewardAmount);
            emit refReward(ambassador, totalRewardAmount);
            if(leverage < 2){
                account[client].unlockedTokens = account[client].unlockedTokens.add(rewardAmount);     
                totalRewardAmount = totalRewardAmount.add(rewardAmount);                  
            }
            else  leverageFeeReduction = 2;
            bep_token.printToken(totalRewardAmount);
		}
        if(leverage > maxLeverage) { leverage = maxLeverage; }
        if(leverage >= 2){
            mulAmount = mulAmount.mul(leverage);
            uint256 feeAmount = amount.mul(leverage.mul(leverageFeeFactor.sub(leverageFeeReduction))).div(100);
            amount = amount.sub(feeAmount);
            bep_token.burn(feeAmount);
            emit leverageFee(client, leverage, feeAmount);
            }

        lockTime = lockTime * 1 days;		
        tokensLocker[client][lockIndex].unlockTime = block.timestamp.add(lockTime);
        tokensLocker[client][lockIndex].lockAmount = amount;
        tokensLocker[client][lockIndex].sharesFromLock = mulAmount;

        account[client].lockedTokens = account[client].lockedTokens.add(amount);   
        account[client].sharesAmount = account[client].sharesAmount.add(mulAmount);
        account[client].locksCount = tokensLocker[client].length;

        totalShares = totalShares.add(mulAmount);
        totalLockedTokens = totalLockedTokens.add(amount);

        totalExcluded[client] = getCumulativeDividends(account[client].sharesAmount);
        emit lock(client, amount, mulAmount, tokensLocker[client][lockIndex].lockTime, leverage);
    }

    function unlocker(address client, uint256 lockIndex) internal {
        previousUnpaidDividend[client] = getUnpaidEarnings(client);

        totalLockedTokens = totalLockedTokens.sub(tokensLocker[client][lockIndex].lockAmount);
        account[client].lockedTokens = account[client].lockedTokens.sub(tokensLocker[client][lockIndex].lockAmount);
        account[client].unlockedTokens = account[client].unlockedTokens.add(tokensLocker[client][lockIndex].lockAmount); 

        uint256 penaltyAmount;
        if(tokensLocker[client][lockIndex].unlockTime > block.timestamp){
            penaltyAmount = tokensLocker[client][lockIndex].lockAmount.mul(penaltyPercentage).div(100);
            account[client].unlockedTokens = account[client].unlockedTokens.sub(penaltyAmount); 
            bep_token.burn(penaltyAmount); 
            emit brokenLock(client, penaltyAmount);   
        } 
        emit unlock(
        client, 
        tokensLocker[client][lockIndex].lockAmount.sub(penaltyAmount), 
        tokensLocker[client][lockIndex].sharesFromLock
        );

        account[client].sharesAmount = account[client].sharesAmount.sub(tokensLocker[client][lockIndex].sharesFromLock);              
        totalShares = totalShares.sub(tokensLocker[client][lockIndex].sharesFromLock);
        totalExcluded[client] = getCumulativeDividends(account[client].sharesAmount);

        tokensLocker[client][lockIndex] = tokensLocker[client][tokensLocker[client].length - 1];
        tokensLocker[client].pop();   
        account[client].locksCount = tokensLocker[client].length;   
    }   

    function depositToBank(address client, uint256 amount) external override onlyToken{ 
        if(!clientExist(client)){
            require(amount >= minTokens, "Not enough tokens to become a client");
            addclient(client);
        }
        account[client].unlockedTokens = account[client].unlockedTokens.add(amount); 
    }

    function insertAmbassador(address ambassador) external onlyClient { 
        require(ambassador != msg.sender, "You cannot refer yourself");
        require(msg.sender != account[ambassador].ambassador, "Illegal activity");
        require(ambassador != address(0), "You cannot refer ZERO address");
        account[msg.sender].ambassador = ambassador;
    }

    function withdrawTokens(uint256 amount) external onlyClient {
        address client = msg.sender;        
        unlockAllTokens(client, false);
		if(amount > account[client].unlockedTokens){
			amount = account[client].unlockedTokens;
		}
        bep_token.transfer(client, amount);
        account[client].unlockedTokens = account[client].unlockedTokens.sub(amount);
    }

    function unlockTokens(uint256 lock_index, bool breakLock, bool unlockAll) external onlyClient {
        address client = msg.sender;  
        require(lock_index < tokensLocker[client].length, "Invalid lock index");
		if(unlockAll){ unlockAllTokens(client, breakLock); }		
		else if(!unlockAll){ unlocker(client, lock_index); }     
    }

    function getAmbassadorList() public view returns (address[] memory, uint256[] memory) {
        uint256 k = 0;
        uint256 index;
        for (uint256 i = 0; i < clients.length; i++) {
            if(account[clients[i]].lockedTokens >= minTokensAmbassador){  index++; }  
            }     
        address[] memory refList = new address[](index);
        uint256[] memory refferals = new uint256[](index);
        for (uint256 i = 0; i < clients.length; i++) {
            if(account[clients[i]].lockedTokens >= minTokensAmbassador){
                refList[k] = clients[i];
                refferals[k] = account[clients[i]].refferalsCount;
                k++;
            }    
        }
        return (refList, refferals);
    }

    function getClientCount() public view returns (uint256) {
        return clients.length;
    }

    function unlockAllTokens(address client, bool breakLock) internal { 
        if(breakLock){
            while (0 < tokensLocker[client].length) {
                unlocker(client,0);
                }
        }
        else if(!breakLock){
            uint256 i = tokensLocker[client].length;
            while (0 < i) {
                if(tokensLocker[client][i.sub(1)].unlockTime < block.timestamp){
                    unlocker(client,i.sub(1));
                }
                i--;    
            }
        }
    }

    function bankSettings(
        uint256 _annualShareMultiplier,
        uint256 _penaltyPercentage,
        uint256 _IntervalCreatePool,
        uint256 _lowerLimiter,
        uint256 _upperLimiter,
    	uint256 _maxAnnualRewardFactor,
        uint256 _maxLeverage,
        uint256 _leverageFeeFactor,
        uint256 _minTimeToReward
    ) external onlyOwner {
        annualShareMultiplier = _annualShareMultiplier;
        penaltyPercentage = _penaltyPercentage;
        IntervalCreatePool = _IntervalCreatePool * 1 days;
        lowerLimiter = _lowerLimiter;
        upperLimiter = _upperLimiter;
        maxAnnualRewardFactor = _maxAnnualRewardFactor;
        maxLeverage = _maxLeverage;
        leverageFeeFactor = _leverageFeeFactor;
        minTimeToReward = _minTimeToReward;
    }

    function setTokenAmount(uint256 _minTokens, uint256 _minTokensAmbassador) external onlyOwner {
        minTokens = _minTokens * (10 ** 18);
        minTokensAmbassador = _minTokensAmbassador * (10 ** 18);
    }  

    function setDATAPROVIDER(address adr) external onlyOwner {
        DATAPROVIDER = adr;
    }    

    function setSocialAccountLabel(uint256 index, string memory _label) external onlyOwner {
        label[index] = _label;
    }    

    function createPool() external override onlyToken {
        if(createPoolTimestamp <= block.timestamp && address(this).balance > 0 && totalShares > 0){
            uint256 balanceBefore = BUSD.balanceOf(address(this));

            address[] memory path = new address[](2);
            path[0] = WBNB;
            path[1] = address(BUSD);

            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(
                0,
                path,
                address(this),
                block.timestamp
            );

            uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);
            createPoolTimestamp = block.timestamp + IntervalCreatePool;
            dividendPool = amount;
            totalDividends = totalDividends.add(amount);
            dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
            emit poolCreated(dividendPool, totalShares, totalLockedTokens);
        }
    }

    function getUnpaidEarnings(address client) public view returns (uint256) {
        uint256 clientTotalDividends = getCumulativeDividends(account[client].sharesAmount);
        clientTotalDividends = clientTotalDividends.add(previousUnpaidDividend[client]);
        uint256 clientTotalExcluded = totalExcluded[client];

        if(clientTotalDividends <= clientTotalExcluded){ return 0; }

        return clientTotalDividends.sub(clientTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function distributeDividend(address client) internal {
        uint256 amount = getUnpaidEarnings(client);
        if(amount > 0 && amount <= BUSD.balanceOf(address(this))){
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(client, amount);
            account[client].totalRealised = account[client].totalRealised.add(amount);
            totalExcluded[client] = getCumulativeDividends(account[client].sharesAmount);
            previousUnpaidDividend[client] = 0;
            emit claimed(msg.sender, amount);
        }
    }

    function distributeSocialReward(address client) internal {
        if(bep_token.shouldPrintTokens()){
            uint256 amount = account[client].unpaidSocialRewards;
            if(amount > 0){
                account[client].unpaidSocialRewards = 0;
                account[client].totalPaidSocialRewards = account[client].totalPaidSocialRewards.add(amount);
                account[client].unlockedTokens = account[client].unlockedTokens.add(amount);
                bep_token.printToken(amount);
                emit claimedSocialReward(msg.sender, amount);     
            }
        }
    }

    function claimDividend() external onlyClient {
        distributeDividend(msg.sender);
        unlockAllTokens(msg.sender, false); 
    }

    function claimSocialReward() external onlyClient {
        distributeSocialReward(msg.sender);
    }

    function checkIsTaken(string memory name, uint256 index) internal view returns (bool) {
        return nameIsTaken[name][index]; 
    }    

    function clientExist(address client) internal view returns (bool) {
        return accountCreated[client]; 
    } 
 
    function addSocialMedia(string memory name, uint256 index) external onlyClient{
        require(!checkIsTaken(name, index), label[index]);
        if(bytes(name).length > 0){
            social[msg.sender][index] = name;
            nameIsTaken[name][index] = true;
        }
    }  

   function recalculationSocialRewards(address[] memory client, uint256[] memory amount) external onlyDATAPROVIDER{
        for (uint256 i; i < client.length; i++) {
            amount[i] = amount[i].mul(10**18);
	        account[client[i]].unpaidSocialRewards = amount[i];        
            }
    }	

    function addclient(address client) internal {
        clientIndexes[client] = clients.length;
        clients.push(client);
        accountCreated[client] = true;
        emit accountAdded(client, clientIndexes[client]);
    }

    event refReward(address referrerAdr, uint256 rewardAmount);
    event leverageFee(address clientAdr, uint256 leverage, uint256 feeAmount);
    event brokenLock(address clientAdr, uint256 feeAmount);
    event lock(address clientAdr, uint256 lockedAmount, uint256 shares, uint256 lockTime, uint256 leverage);
    event unlock(address clientAdr, uint256 lockedAmount, uint256 shares);
    event poolCreated(uint256 pool, uint256 shares, uint256 lockedTokens);
    event accountAdded(address client, uint256 index);
    event claimed(address client, uint256 amount);
    event claimedSocialReward(address client, uint256 amount);
}