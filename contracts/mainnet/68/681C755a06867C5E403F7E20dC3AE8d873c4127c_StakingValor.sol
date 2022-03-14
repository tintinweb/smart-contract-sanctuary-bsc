// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./RewardsDistributionRecipient.sol";
import "./interfaces/IValor.sol";

contract StakingValor is RewardsDistributionRecipient, ReentrancyGuard, Pausable  {
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IERC20 public rewardsToken1;

    IERC20 public stakingToken;
    address public stakingTokenMultiplier1;

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
    uint256 private _totalSupplyMultiplier1; // boost token 1
    uint256 private _totalSupplyMultiplier2; // boost token 2  // BNB
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _balancesMultiplier1; // boost token 1 => 40% boost possible
    mapping(address => uint256) private _balancesMultiplier2; // boost token 2  // BNB => 20% boost possible
    
    mapping(address=>bool) allowedERC721NFTContracts;

    mapping(address => uint256) public lockingPeriodStaking;

    mapping(address => uint256) public multiplierFactor;

    uint256 public lockTimeStakingToken; 

    uint256 public totalToken1ForReward;
    
    uint256[4] public multiplierRewardToken1Amt; // 40% boost by Boost Token1
    uint256[2] public multiplierRewardToken2Amt; // 20% boost for BNB

    mapping(address=>uint256) public multiplierFactorNFT; // user address => NFT's M.F.
    mapping(address=>mapping(address=>uint256)) public boostedByNFT; // user address => NFT contract => total boosts done if boosted by that particular NFT
    // avoids double boost 

    address[] NFTboostedAddresses; // all addresses who boosted by NFT

    mapping(address=>uint256) public totalNFTsBoostedBy; // total NFT boosts done by user

    mapping(address=>uint256) public boostPercentNFT; // set by owner 1*10^17 = 10% boost
    address[] public erc721NFTContracts;

    uint256 public maxNFTsBoosts;
    bool public stakingEnabled = true;
    address public valor = 0x588Ff59EE7ba59c33d1e891468a168770E0AE7d8;

    constructor(        
        address _rewardsDistribution,
        address _rewardsToken1,
        address _stakingToken,
        address _stakingTokenMultiplier1)  
    {
        
        rewardsToken1 = IERC20(_rewardsToken1);

        stakingToken = IERC20(_stakingToken);
        stakingTokenMultiplier1 = _stakingTokenMultiplier1;
        rewardsDistribution = _rewardsDistribution;

        periodFinish = 0;
        rewardRate1 = 0;
        totalToken1ForReward=0;
        rewardsDuration = 30 days; 

        // boost token 1 => 40% boost possible
        // boost token 2  // BNB => 20% boost possible
    
        multiplierRewardToken1Amt = [200 ether, 400 ether, 600 ether, 800 ether];
        //multiplierRewardToken2Amt = [20 ether, 50 ether]; // BNB
        multiplierRewardToken2Amt = [0,0]; // BNB

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

    function totalSupplyMultiplier() external view returns (uint256,uint256) {
        return (_totalSupplyMultiplier1,_totalSupplyMultiplier2);
    }

    function balanceOfMultiplier(address account) external view returns (uint256,uint256) {
        return (_balancesMultiplier1[account],_balancesMultiplier2[account]);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken1() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerToken1Stored;
        }
        return
            rewardPerToken1Stored + (
                lastTimeRewardApplicable() - (lastUpdateTime) * (rewardRate1) * (1e18) / (_totalSupply)
            );
    }
      
    // divide by 10^6 and add decimals => 6 d.p.
    function getMultiplyingFactor(address account) public view returns (uint256) {
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
    }

    function earnedtokenRewardToken1(address account) public view returns (uint256) {
        return _balances[account] * (rewardPerToken1() - (userRewardPerToken1Paid[account]))
         / (1e18) + (rewards1[account]);
    }
    
    
    function totalEarnedRewardToken1(address account) public view returns (uint256) {
        return (_balances[account] * (rewardPerToken1() - (userRewardPerToken1Paid[account]))
         / (1e18) + (rewards1[account])) * (getMultiplyingFactorWei(account)) / (1e18);
    }
    
    function getReward1ForDuration() external view returns (uint256) {
        return rewardRate1 * (rewardsDuration);
    }


    function getRewardToken1APY() external view returns (uint256) {
        //3153600000 = 365*24*60*60
        if(block.timestamp>periodFinish) return 0;
        uint256 rewardForYear = rewardRate1 * (31536000); 
        if(_totalSupply<=1e18) return rewardForYear / (1e10);
        return rewardForYear * (1e8) / (_totalSupply); // put 6 dp
    }

    function getRewardToken1WPY() external view returns (uint256) {
        //60480000 = 7*24*60*60
        if(block.timestamp>periodFinish) return 0;
        uint256 rewardForWeek = rewardRate1 * (604800); 
        if(_totalSupply<=1e18) return rewardForWeek / (1e10);
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
        require(IValor(valor).totalTaxIfSelling() == 0, "SELL_TAX_>0");
        lockingPeriodStaking[msg.sender]= block.timestamp + (lockTimeStakingToken);
        _totalSupply = _totalSupply + (amount);
        _balances[msg.sender] = _balances[msg.sender] + (amount);        
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function boostByToken1(uint256 amount) external nonReentrant whenNotPaused {
        require(stakingTokenMultiplier1 != address(0), "BOOST_NOT_ALLOWED");
        require(stakingEnabled, "STAKING_DISABLED");
        require(amount > 0, "Cannot stake 0");
        _totalSupplyMultiplier1 = _totalSupplyMultiplier1 + (amount);
        _balancesMultiplier1[msg.sender] = _balancesMultiplier1[msg.sender] + (amount);
        // send the whole multiplier fee to dev fund address
        IERC20(stakingTokenMultiplier1).safeTransferFrom(msg.sender, devFundAdd, amount);
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
    }

    // _boostPercent = 10000 => 10% => 10^4 * 10^13
    function addNFTasMultiplier(address _erc721NFTContract, uint256 _boostPercent) external onlyOwner {
        
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
    }

    // reset possible after Previous rewards period finishes
    function resetNFTasMultiplier() external onlyOwner {
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
        
        IERC721(_erc721NFTContract).safeTransferFrom(msg.sender, devFundAdd, _tokenId);

        totalNFTsBoostedBy[msg.sender]=totalNFTsBoostedBy[msg.sender] + (1);
        boostedByNFT[msg.sender][_erc721NFTContract] = boostedByNFT[msg.sender][_erc721NFTContract] + (1);
        require(totalNFTsBoostedBy[msg.sender]<=erc721NFTContracts.length,"Total boosts cannot be more than MAX NfT boosts available");

        emit NFTMultiplier(msg.sender, _erc721NFTContract, _tokenId);
    }
    
    function withdraw(uint256 amount) internal nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(amount<=_balances[msg.sender],"Staked amount is lesser");

        _totalSupply = _totalSupply - (amount);
        _balances[msg.sender] = _balances[msg.sender] - (amount);

        if(block.timestamp < lockingPeriodStaking[msg.sender]){
            uint256 devFee = amount * (devFundFeeWithdraw) / (100000); // feeWithdraw = 100000 = 100%
            stakingToken.safeTransfer(devFundAdd, devFee);
            uint256 stakingFee = amount * (stakingPoolFeeWithdraw) / (100000); // feeWithdraw = 100000 = 100%
            stakingToken.safeTransfer(stakingPoolFeeAdd, stakingFee);
            uint256 remAmount = amount - (devFee) - (stakingFee);
            stakingToken.safeTransfer(msg.sender, remAmount);
        }
        else    
            stakingToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public nonReentrant whenNotPaused updateReward(msg.sender) {
        uint256 reward1 = rewards1[msg.sender] * (getMultiplyingFactorWei(msg.sender)) / (1e18);
        if (reward1 > 0) {
            rewards1[msg.sender] = 0;
            rewardsToken1.safeTransfer(_msgSender(), reward1);
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
        uint256 multiplyFactor = 1e18 + 3e17; // 130%
        for(uint i=0;i<erc721NFTContracts.length;i++){
                multiplyFactor = multiplyFactor + (boostPercentNFT[erc721NFTContracts[i]]);
        }

        uint256 denominatorForMF = 1e20;

        // reward * 100 / 130 ~ 76% (if NO NFT boost)
        uint256 reward1Available = rewardToken1Amount * (denominatorForMF) / (multiplyFactor) / (100); 
        // uint256 reward2Available = rewardToken2 * (denominatorForMF) / (multiplyFactor) / (100);

        if (block.timestamp >= periodFinish) {
            rewardRate1 = reward1Available / (rewardsDuration);
            _resetNFTasMultiplierForUser();
        } 
        else {
            uint256 remaining = periodFinish - (block.timestamp);
            uint256 leftover1 = remaining * (rewardRate1);
            rewardRate1 = reward1Available + (leftover1) / (rewardsDuration);
        }
        
        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint balance1 = rewardsToken1.balanceOf(address(this));
        require(rewardRate1 <= balance1 / (rewardsDuration), "Provided reward too high");

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + (rewardsDuration);

        emit RewardAdded(reward1Available);
    }

    // only left over reward provided by owner can be withdrawn after reward period finishes
    function withdrawNotified() external onlyOwner {
        require(block.timestamp >= periodFinish, 
            "Cannot withdraw before reward time finishes"
        );
        
        address owner = Ownable.owner();
        // only left over reward amount will be left
        IERC20(rewardsToken1).safeTransfer(owner, totalToken1ForReward);
        
        emit Recovered(address(rewardsToken1), totalToken1ForReward);
        
        totalToken1ForReward=0;
    }

    // only reward provided by owner can be withdrawn in emergency, user stakes are safe
    function withdrawNotifiedEmergency(uint256 reward1Amount) external onlyOwner {

        require(reward1Amount<=totalToken1ForReward,"Total reward left to distribute is lesser");

        address owner = Ownable.owner();
        // only left over reward amount will be left
        IERC20(rewardsToken1).safeTransfer(owner, reward1Amount);
        
        emit Recovered(address(rewardsToken1), reward1Amount);
        
        totalToken1ForReward=totalToken1ForReward - (reward1Amount);

    }
    
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        // Cannot recover the staking token or the rewards token
        require(
            tokenAddress != address(stakingToken) && tokenAddress != address(stakingTokenMultiplier1) && tokenAddress != address(rewardsToken1),
            "Cannot withdraw the staking or rewards tokens"
        );
        address owner = Ownable.owner();
        IERC20(tokenAddress).safeTransfer(owner, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        require(block.timestamp > periodFinish,
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }


    function setOnMultiplierAmounts1(uint256[4] calldata _values) external onlyOwner {
        multiplierRewardToken1Amt = _values;
    }

    function setOnMultiplierAmounts2(uint256[2] calldata _values) external onlyOwner {
        multiplierRewardToken2Amt = _values;
    }

    // view function for input as multiplier token amount
    // returns Multiply Factor in 6 decimal place
    // _amount => Multiplier token 1 , _amount2 => Multiplier token 2 (BNB)
    function getMultiplierForAmount(uint256 _amount, uint256 _amount2) public view returns(uint256) {
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
    
        /* ========== Boost token 2 ========== */

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
    }


    function getTotalMultiplier(address account) internal{

        /* ========== Boost token 1 ========== */

        uint256 multiplier=0;        
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

        uint256 multiplyFactor = multiplier + (1e18);
    
        /* ========== Boost token 2 ========== */

        uint256 multiplier2=0;        
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
        
    }
    
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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
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
    function totalTaxIfSelling() external returns(uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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