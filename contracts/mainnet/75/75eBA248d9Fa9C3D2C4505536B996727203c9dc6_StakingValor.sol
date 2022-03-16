// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./RewardsDistributionRecipient.sol";
import "./interfaces/IValor.sol";

contract StakingValor is RewardsDistributionRecipient, ReentrancyGuard, Pausable  {
    /* ========== STATE VARIABLES ========== */

    IERC20 public rewardsToken1;

    IERC20 public stakingToken;
    //address public stakingTokenMultiplier1;

    uint256 public periodFinish;
    
    uint256 public rewardRate1; 

    uint256 public rewardsDuration ;
    uint256 public lastUpdateTime;
    uint256 public rewardPerToken1Stored;

    address public stakingPoolFeeAdd = 0xaaf0B9C08D4884851f726e540f36492739c32764;
    address public devFundAdd = 0xaaf0B9C08D4884851f726e540f36492739c32764;
    uint256 public stakingPoolFeeWithdraw;
    uint256 public devFundFeeWithdraw;

    mapping(address => uint256) public userRewardPerToken1Paid;

    mapping(address => uint256) public rewards1;

    uint256 private _totalSupply;
    //uint256 private _totalSupplyMultiplier1; // boost token 1
    //uint256 private _totalSupplyMultiplier2; // boost token 2  // BNB
    mapping(address => uint256) private _balances;
    //mapping(address => uint256) private _balancesMultiplier1; // boost token 1 => 40% boost possible
    //mapping(address => uint256) private _balancesMultiplier2; // boost token 2  // BNB => 20% boost possible
    
    //mapping(address=>bool) allowedERC721NFTContracts;

    mapping(address => uint256) public lockingPeriodStaking;

    //mapping(address => uint256) public multiplierFactor;

    uint256 public lockTimeStakingToken; 

    uint256 public totalToken1ForReward;
    
    //uint256[4] public multiplierRewardToken1Amt; // 40% boost by Boost Token1
    //uint256[2] public multiplierRewardToken2Amt; // 20% boost for BNB

    //mapping(address=>uint256) public multiplierFactorNFT; // user address => NFT's M.F.
    //mapping(address=>mapping(address=>uint256)) public boostedByNFT; // user address => NFT contract => total boosts done if boosted by that particular NFT
    // avoids double boost 

    //address[] NFTboostedAddresses; // all addresses who boosted by NFT

    //mapping(address=>uint256) public totalNFTsBoostedBy; // total NFT boosts done by user

    //mapping(address=>uint256) public boostPercentNFT; // set by owner 1*10^17 = 10% boost
    //address[] public erc721NFTContracts;

    //uint256 public maxNFTsBoosts;
    bool public stakingEnabled = true;
    address public valor = 0x588Ff59EE7ba59c33d1e891468a168770E0AE7d8;

    constructor(        
        address _rewardsDistribution,
        address _rewardsToken1,
        address _stakingToken)
    {
        
        rewardsToken1 = IERC20(_rewardsToken1);

        stakingToken = IERC20(_stakingToken);
        //stakingTokenMultiplier1 = _stakingTokenMultiplier1;
        rewardsDistribution = _rewardsDistribution;

        periodFinish = 0;
        rewardRate1 = 0;
        totalToken1ForReward=0;
        rewardsDuration = 30 days; 

        // boost token 1 => 40% boost possible
        // boost token 2  // BNB => 20% boost possible
    
        //multiplierRewardToken1Amt = [200 ether, 400 ether, 600 ether, 800 ether];
        //multiplierRewardToken2Amt = [20 ether, 50 ether]; // BNB
        //multiplierRewardToken2Amt = [0,0]; // BNB

        stakingPoolFeeWithdraw = 0; 
        devFundFeeWithdraw = 0; // 10000 = 10%

        lockTimeStakingToken = 30 days;
    }

    /* ========== VIEWS ========== */
    
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

/*     function totalSupplyMultiplier() external view returns (uint256,uint256) {
        return (_totalSupplyMultiplier1,_totalSupplyMultiplier2);
    }

    function balanceOfMultiplier(address account) external view returns (uint256,uint256) {
        return (_balancesMultiplier1[account],_balancesMultiplier2[account]);
    } */

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken1() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerToken1Stored;
        }
        return
            rewardPerToken1Stored + (
                lastTimeRewardApplicable() - (lastUpdateTime) * (rewardRate1) * (1e9) / (_totalSupply)
            );
    }
      
    // divide by 10^6 and add decimals => 6 d.p.
/*     function getMultiplyingFactor(address account) public view returns (uint256) {
        if (multiplierFactor[account] == 0 && multiplierFactorNFT[account] == 0) {
            return 1000000;
        }
        uint256 MFwei = multiplierFactor[account] + (multiplierFactorNFT[account]);
        if(multiplierFactor[account]==0)
            MFwei = MFwei + (1e18);
        return MFwei / (1e12);
    }

    function getMultiplyingFactorWei(address account) public view returns (uint256) {
        if (multiplierFactor[account] == 0 && multiplierFactorNFT[account] == 0) {
            return 1e18;
        }
        uint256 MFwei = multiplierFactor[account] + (multiplierFactorNFT[account]);
        if(multiplierFactor[account]==0)
            MFwei = MFwei + (1e18);
        return MFwei;
    } */

    function earnedtokenRewardToken1(address account) public view returns (uint256) {
        return _balances[account] * (rewardPerToken1() - (userRewardPerToken1Paid[account]))
         / (1e9) + (rewards1[account]);
    }
    
    
    function totalEarnedRewardToken1(address account) public view returns (uint256) {
        return (_balances[account] * (rewardPerToken1() - (userRewardPerToken1Paid[account]))
         /// (1e18) + (rewards1[account])) * (getMultiplyingFactorWei(account)) / (1e18);
         / (1e9) + (rewards1[account])) / (1e9);
    }
    
    function getReward1ForDuration() external view returns (uint256) {
        return rewardRate1 * (rewardsDuration);
    }

    function getRewardToken1APY() external view returns (uint256) {
        //3153600000 = 365*24*60*60
        if(block.timestamp>periodFinish) return 0;
        uint256 rewardForYear = rewardRate1 * (31536000); 
        if(_totalSupply<=1e9) return rewardForYear / (1e8);
        return rewardForYear * (1e8) / (_totalSupply); // put 6 dp
    }

    function getRewardToken1WPY() external view returns (uint256) {
        //60480000 = 7*24*60*60
        if(block.timestamp>periodFinish) return 0;
        uint256 rewardForWeek = rewardRate1 * (604800); 
        if(_totalSupply<=1e9) return rewardForWeek / (1e2);
        return rewardForWeek * (1e8) / (_totalSupply); // put 6 dp
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function toggleStakingEnabled() external onlyOwner {
        stakingEnabled = !stakingEnabled;
    }

    // feeAmount = 100 => 1%
    function setTransferParams(address _stakingPoolFeeAdd, address _devFundAdd, uint256 _stakingPoolFeeStaking, 
        uint256 _devFundFeeStaking) external onlyOwner
    {
            stakingPoolFeeAdd = _stakingPoolFeeAdd;
            devFundAdd = _devFundAdd;
            stakingPoolFeeWithdraw = _stakingPoolFeeStaking;
            devFundFeeWithdraw = _devFundFeeStaking;
    }

    function setTimelockStakingToken(uint256 lockTime) external onlyOwner{
         lockTimeStakingToken=lockTime;   
    }
    
    function pause() external onlyOwner{
        _pause();
    }
    function unpause() external onlyOwner{
        _unpause();
    }

    function stake(uint256 amount) external nonReentrant whenNotPaused updateReward(msg.sender) {
        require(stakingEnabled, "STAKING_DISABLED");
        require(amount > 0, "Cannot stake 0");
        require(IValor(valor).totalTaxIfBuying() == 0, "BUY_TAX_>0");
        lockingPeriodStaking[msg.sender]= block.timestamp + (lockTimeStakingToken);
        _totalSupply = _totalSupply + (amount);
        _balances[msg.sender] = _balances[msg.sender] + (amount);        
        stakingToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

/*    function boostByToken1(uint256 amount) external nonReentrant whenNotPaused {
         require(stakingTokenMultiplier1 != address(0), "BOOST_NOT_ALLOWED");
        require(stakingEnabled, "STAKING_DISABLED");
        require(amount > 0, "Cannot stake 0");
        _totalSupplyMultiplier1 = _totalSupplyMultiplier1 + (amount);
        _balancesMultiplier1[msg.sender] = _balancesMultiplier1[msg.sender] + (amount);
        // send the whole multiplier fee to dev fund address
        IERC20(stakingTokenMultiplier1).transferFrom(msg.sender, devFundAdd, amount);
        getTotalMultiplier(msg.sender);
        emit BoostedStakeToken1(msg.sender, amount);
    }

    function boostByBNB() external payable nonReentrant whenNotPaused {
        require(multiplierRewardToken2Amt[0] != 0, "BOOST_NOT_ALLOWED");
        require(stakingEnabled, "STAKING_DISABLED");
        uint256 amount = msg.value;
        require(amount > 0, "Cannot stake 0");

        _totalSupplyMultiplier2 = _totalSupplyMultiplier2 + (amount);
        _balancesMultiplier2[msg.sender] = _balancesMultiplier2[msg.sender] + (amount);

        // send the whole multiplier fee to dev fund address
        (bool success,) = devFundAdd.call{ value: amount }("");
        require (success, "Transfer failed");
        
        getTotalMultiplier(msg.sender);
        emit BoostedByBNB(msg.sender, amount);
    } */

    // _boostPercent = 10000 => 10% => 10^4 * 10^13
/*     function addNFTasMultiplier(address _erc721NFTContract, uint256 _boostPercent) external onlyOwner {
        
        require(block.timestamp >= periodFinish, 
            "Cannot set NFT boosts after staking starts"
        );
        require(allowedERC721NFTContracts[_erc721NFTContract]==false,"This NFT is already allowed for boosts");
        allowedERC721NFTContracts[_erc721NFTContract]=true;

        erc721NFTContracts.push(_erc721NFTContract);
        boostPercentNFT[_erc721NFTContract] = _boostPercent * (1e13);
    }

    // if next cycle of staking starts it resets for all users
    function _resetNFTasMultiplierForUser() internal {

        for(uint i=0;i<NFTboostedAddresses.length;i++){
            totalNFTsBoostedBy[NFTboostedAddresses[i]]=0;

            for(uint j=0;j<erc721NFTContracts.length;j++)
                    boostedByNFT[NFTboostedAddresses[i]][erc721NFTContracts[j]]=0;

            multiplierFactorNFT[NFTboostedAddresses[i]]=0;
        }

        delete NFTboostedAddresses;
    } */

    // reset possible after Previous rewards period finishes
/*     function resetNFTasMultiplier() external onlyOwner {
        require(block.timestamp > periodFinish,
            "Previous rewards period must be complete before resetting"
        );

        for(uint i=0;i<erc721NFTContracts.length;i++){
            boostPercentNFT[erc721NFTContracts[i]] = 0;
            allowedERC721NFTContracts[erc721NFTContracts[i]]=false;
        }

        _resetNFTasMultiplierForUser();
        delete erc721NFTContracts;
    }

    // can get total boost possible by user's NFTs
    function getNFTBoostPossibleByAddress(address NFTowner) public view returns(uint256){

        uint256 multiplyFactor = 0;
        for(uint i=0;i<erc721NFTContracts.length;i++){

            if(IERC721(erc721NFTContracts[i]).balanceOf(NFTowner)>=1)
                multiplyFactor = multiplyFactor + (boostPercentNFT[erc721NFTContracts[i]]);

        }

        uint256 boostWei= multiplierFactor[NFTowner] + (multiplyFactor);
        return boostWei / (1e12);
    }

    function setTotalNFTsBoostsPossible(uint256 _tBoosts) external onlyOwner{
        maxNFTsBoosts = _tBoosts;
    }

    // view function 3/10 boosts done => a,b,c NFT
    function getBoostsByUser(address _userAddress) external view returns(address[] memory, uint256[] memory, uint256, uint256 ){
        uint tBoosts = 0;
        uint[] memory userBoostByNFTs = new uint[](erc721NFTContracts.length);
        
        for(uint i=0;i<erc721NFTContracts.length;i++){
            tBoosts = tBoosts + (boostedByNFT[_userAddress][erc721NFTContracts[i]]);
            userBoostByNFTs[i] = boostedByNFT[_userAddress][erc721NFTContracts[i]];
        }
        return (erc721NFTContracts, userBoostByNFTs, tBoosts, maxNFTsBoosts);
    }

    // approve all NFTs to contract before you call this function
    function boostByNFTsBulk(address[] calldata _erc721NFTContracts, uint256[] calldata _tokenIds) external nonReentrant whenNotPaused {
        require(stakingEnabled, "STAKING_DISABLED");

        for(uint i; i<_erc721NFTContracts.length; i++){
            boostByNFT(_erc721NFTContracts[i], _tokenIds[i]);   
        }
    }

    // approve NFT to contract before you call this function
    function boostByNFT(address _erc721NFTContract, uint256 _tokenId) public nonReentrant whenNotPaused {
        require(stakingEnabled, "STAKING_DISABLED");
        require(block.timestamp <= periodFinish, "Cannot use NFT boosts before staking starts");
        require(allowedERC721NFTContracts[_erc721NFTContract]==true,"This NFT is not allowed for boosts");

        uint256 multiplyFactor = boostPercentNFT[_erc721NFTContract];

        if(totalNFTsBoostedBy[msg.sender]==0){
            NFTboostedAddresses.push(msg.sender);
        }

        // CHECK already boosted by same NFT contract??
        require(boostedByNFT[msg.sender][_erc721NFTContract]<maxNFTsBoosts,"Already boosted by this NFT");

        multiplierFactorNFT[msg.sender]= multiplierFactorNFT[msg.sender] + (multiplyFactor);
        
        IERC721(_erc721NFTContract).transferFrom(msg.sender, devFundAdd, _tokenId);

        totalNFTsBoostedBy[msg.sender]=totalNFTsBoostedBy[msg.sender] + (1);
        boostedByNFT[msg.sender][_erc721NFTContract] = boostedByNFT[msg.sender][_erc721NFTContract] + (1);
        require(totalNFTsBoostedBy[msg.sender]<=erc721NFTContracts.length,"Total boosts cannot be more than MAX NfT boosts available");

        emit NFTMultiplier(msg.sender, _erc721NFTContract, _tokenId);
    } */
    
    function withdraw(uint256 amount) internal nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(amount<=_balances[msg.sender],"Staked amount is lesser");

        _totalSupply = _totalSupply - (amount);
        _balances[msg.sender] = _balances[msg.sender] - (amount);

        if(block.timestamp < lockingPeriodStaking[msg.sender]){
            uint256 devFee = amount * (devFundFeeWithdraw) / (100000); // feeWithdraw = 100000 = 100%
            stakingToken.transfer(devFundAdd, devFee);
            uint256 stakingFee = amount * (stakingPoolFeeWithdraw) / (100000); // feeWithdraw = 100000 = 100%
            stakingToken.transfer(stakingPoolFeeAdd, stakingFee);
            uint256 remAmount = amount - (devFee) - (stakingFee);
            stakingToken.transfer(msg.sender, remAmount);
        }
        else    
            stakingToken.transfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public nonReentrant whenNotPaused updateReward(msg.sender) {
        //uint256 reward1 = rewards1[msg.sender] * (getMultiplyingFactorWei(msg.sender)) / (1e9);
        uint256 reward1 = rewards1[msg.sender];
        if (reward1 > 0) {
            rewards1[msg.sender] = 0;
            rewardsToken1.transfer(_msgSender(), reward1);
            totalToken1ForReward = totalToken1ForReward - (reward1);
        }       
        emit RewardPaid(msg.sender, reward1);
    }

    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */
    // reward 1  => DMagic
    function notifyRewardAmount(uint256 rewardToken1Amount) external onlyRewardsDistribution updateReward(address(0)) {

        totalToken1ForReward = totalToken1ForReward + (rewardToken1Amount);

        // using x% of reward amount, remaining locked for multipliers 
        // x * 1.3 (max M.F.) = 100
/*         uint256 multiplyFactor = 1e9 + 3e17; // 130%
        for(uint i=0;i<erc721NFTContracts.length;i++){
                multiplyFactor = multiplyFactor + (boostPercentNFT[erc721NFTContracts[i]]);
        }

        uint256 denominatorForMF = 1e20; */

        // reward * 100 / 130 ~ 76% (if NO NFT boost)
        //uint256 reward1Available = rewardToken1Amount * (denominatorForMF) / (multiplyFactor) / (100); 
        // uint256 reward2Available = rewardToken2 * (denominatorForMF) / (multiplyFactor) / (100);

        if (block.timestamp >= periodFinish) {
            //rewardRate1 = reward1Available / (rewardsDuration);
            rewardRate1 = rewardToken1Amount / (rewardsDuration);
            //_resetNFTasMultiplierForUser();
        } 
        else {
            uint256 remaining = periodFinish - (block.timestamp);
            uint256 leftover1 = remaining * (rewardRate1);
            //rewardRate1 = reward1Available + (leftover1) / (rewardsDuration);
            rewardRate1 = rewardToken1Amount + (leftover1) / (rewardsDuration);
        }
        
        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint balance1 = rewardsToken1.balanceOf(address(this));
        require(rewardRate1 <= balance1 / (rewardsDuration), "Provided reward too high");

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + (rewardsDuration);

        //emit RewardAdded(reward1Available);
        emit RewardAdded(rewardToken1Amount);
    }

    // only left over reward provided by owner can be withdrawn after reward period finishes
    function withdrawNotified() external onlyOwner {
        require(block.timestamp >= periodFinish, 
            "Cannot withdraw before reward time finishes"
        );
        
        address owner = Ownable.owner();
        // only left over reward amount will be left
        IERC20(rewardsToken1).transfer(owner, totalToken1ForReward);
        
        emit Recovered(address(rewardsToken1), totalToken1ForReward);
        
        totalToken1ForReward=0;
    }

    // only reward provided by owner can be withdrawn in emergency, user stakes are safe
    function withdrawNotifiedEmergency(uint256 reward1Amount) external onlyOwner {

        require(reward1Amount<=totalToken1ForReward,"Total reward left to distribute is lesser");

        address owner = Ownable.owner();
        // only left over reward amount will be left
        IERC20(rewardsToken1).transfer(owner, reward1Amount);
        
        emit Recovered(address(rewardsToken1), reward1Amount);
        
        totalToken1ForReward=totalToken1ForReward - (reward1Amount);

    }
    
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        // Cannot recover the staking token or the rewards token
        require(
            //tokenAddress != address(stakingToken) && tokenAddress != address(stakingTokenMultiplier1) && tokenAddress != address(rewardsToken1),
            tokenAddress != address(stakingToken) && tokenAddress != address(rewardsToken1),
            "Cannot withdraw the staking or rewards tokens"
        );
        address owner = Ownable.owner();
        IERC20(tokenAddress).transfer(owner, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        require(block.timestamp > periodFinish,
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }


/*     function setOnMultiplierAmounts1(uint256[4] calldata _values) external onlyOwner {
        multiplierRewardToken1Amt = _values;
    }

    function setOnMultiplierAmounts2(uint256[2] calldata _values) external onlyOwner {
        multiplierRewardToken2Amt = _values;
    } */

    // view function for input as multiplier token amount
    // returns Multiply Factor in 6 decimal place
    // _amount => Multiplier token 1 , _amount2 => Multiplier token 2 (BNB)
/*    function getMultiplierForAmount(uint256 _amount, uint256 _amount2) public view returns(uint256) {
         uint256 multiplier=0;        
        uint256 parts=0;
        uint256 totalParts=1;

        if(_amount>=multiplierRewardToken1Amt[0] && _amount < multiplierRewardToken1Amt[1]) {
            totalParts = multiplierRewardToken1Amt[1] - (multiplierRewardToken1Amt[0]);
            parts = _amount - (multiplierRewardToken1Amt[0]); 
            multiplier = parts * (1e17) / (totalParts) + (10 ** 17); 
        }
        else if(_amount>=multiplierRewardToken1Amt[1] && _amount < multiplierRewardToken1Amt[2]) {
            totalParts = multiplierRewardToken1Amt[2] - (multiplierRewardToken1Amt[1]);
            parts = _amount - (multiplierRewardToken1Amt[1]); 
            multiplier = parts * (1e17) / (totalParts) + (2 * 10 ** 17); 
        }
        else if(_amount>=multiplierRewardToken1Amt[2] && _amount < multiplierRewardToken1Amt[3]) {
            totalParts = multiplierRewardToken1Amt[3] - (multiplierRewardToken1Amt[2]);
            parts = _amount - (multiplierRewardToken1Amt[2]); 
            multiplier = parts * (1e17) / (totalParts) + (3 * 10 ** 17); 
        }
        else if(_amount>=multiplierRewardToken1Amt[3]){
            multiplier = 4 * 10 ** 17;
        }

        uint256 multiplyFactor1 = multiplier + (1e18);
    */
        /* ========== Boost token 2 ========== */
    /*
        uint256 multiplier2=0;        
        uint256 parts2=0;
        uint256 totalParts2=1;

        if(_amount2>=multiplierRewardToken2Amt[0] && _amount2 < multiplierRewardToken2Amt[1]) {
            totalParts2 = multiplierRewardToken2Amt[1] - (multiplierRewardToken2Amt[0]);
            parts2 = _amount2 - (multiplierRewardToken2Amt[0]); 
            multiplier2 = parts2 * (1e17) / (totalParts2) + (10 ** 17); 
        }
        else if(_amount2>=multiplierRewardToken2Amt[1]){
            multiplier2 = 2 * 10 ** 17;
        }

        uint256 multiplyFactor2 = multiplier2 + (1e18);


        uint256 multiplyFactor=multiplyFactor1 + (multiplyFactor2);
        return multiplyFactor / (1e12);
    } */


//    function getTotalMultiplier(address account) internal{
        /* ========== Boost token 1 ========== */

/*         uint256 multiplier=0;        
        uint256 parts=0;
        uint256 totalParts=1;

        uint256 _amount = _balancesMultiplier1[account];

        if(_amount>=multiplierRewardToken1Amt[0] && _amount < multiplierRewardToken1Amt[1]) {
            totalParts = multiplierRewardToken1Amt[1] - (multiplierRewardToken1Amt[0]);
            parts = _amount - (multiplierRewardToken1Amt[0]); 
            multiplier = parts * (1e17) / (totalParts) + (10 ** 17); 
        }
        else if(_amount>=multiplierRewardToken1Amt[1] && _amount < multiplierRewardToken1Amt[2]) {
            totalParts = multiplierRewardToken1Amt[2] - (multiplierRewardToken1Amt[1]);
            parts = _amount - (multiplierRewardToken1Amt[1]); 
            multiplier = parts * (1e17) / (totalParts) + (2 * 10 ** 17); 
        }
        else if(_amount>=multiplierRewardToken1Amt[2] && _amount < multiplierRewardToken1Amt[3]) {
            totalParts = multiplierRewardToken1Amt[3] - (multiplierRewardToken1Amt[2]);
            parts = _amount - (multiplierRewardToken1Amt[2]); 
            multiplier = parts * (1e17) / (totalParts) + (3 * 10 ** 17); 
        }
        else if(_amount>=multiplierRewardToken1Amt[3]){
            multiplier = 4 * 10 ** 17;
        }

        uint256 multiplyFactor = multiplier + (1e18); */
    
        /* ========== Boost token 2 ========== */

/*         uint256 multiplier2=0;        
        uint256 parts2=0;
        uint256 totalParts2=1;

        uint256 _amount2 = _balancesMultiplier2[account];

        if(_amount2>=multiplierRewardToken2Amt[0] && _amount2 < multiplierRewardToken2Amt[1]) {
            totalParts2 = multiplierRewardToken2Amt[1] - (multiplierRewardToken2Amt[0]);
            parts2 = _amount2 - (multiplierRewardToken2Amt[0]); 
            multiplier2 = parts2 * (1e17) / (totalParts2) + (10 ** 17); 
        }
        else if(_amount2>=multiplierRewardToken2Amt[1]){
            multiplier2 = 2 * 10 ** 17;
        }

        uint256 multiplyFactor2 = multiplier2 + (1e18);


        multiplierFactor[msg.sender]=multiplyFactor + (multiplyFactor2); 
        
    }*/
    
    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        rewardPerToken1Stored = rewardPerToken1();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards1[account] = earnedtokenRewardToken1(account);
            userRewardPerToken1Paid[account] = rewardPerToken1Stored;
        }
        _;
    }

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward1);
    event Staked(address indexed user, uint256 amount);
    event BoostedStakeToken1(address indexed user, uint256 amount);
    event BoostedByBNB(address indexed user, uint256 amount);
    
    event NFTMultiplier(address indexed user, address ERC721NFTContract, uint256 tokenId);
    
    event Withdrawn(address indexed user, uint256 amount);
    event WithdrawnMultiplier(address indexed user, uint256 amount);

    event RewardPaid(address indexed user, uint256 reward1);

    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);
    

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract RewardsDistributionRecipient is Ownable {
    address public rewardsDistribution;

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "Caller is not RewardsDistribution contract");
        _;
    }

    function setRewardsDistribution(address _rewardsDistribution) external onlyOwner {
        rewardsDistribution = _rewardsDistribution;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IValor
{
    function totalTaxIfBuying() external returns(uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}