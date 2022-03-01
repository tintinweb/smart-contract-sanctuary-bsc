// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Upgradable1155.sol";  
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StakingPool1155 is UpgradableV2{
    using SafeERC20 for IERC20;

    /**
     * @dev Init pool utility contracts 
     * @param _signatureUtils: address of SignatureUtils contract, for NFTs data verification
     * @param _collection1155: address of NFT1155 Marketplace contract, stake NFTs from this contract
     * @param _rewardToken: address of Z token contract, the token used for reward distribution
    */
    function initPool(address _signatureUtils, address _rewardToken, address _collection1155) external {
        rewardToken = IERC20(_rewardToken);
        collection1155 = IERC1155(_collection1155);
        signatureUtils =  SignatureUtils1155(_signatureUtils);

        isSignatureEnable = false;
    }
    
    /*=============================== 1155 Staking Pool ====================================== */

    /**
     * @dev Create 1155 pool   
     * @param strs_ strs[0]: poolId, strs[1]: internal txId
     * @param configs_ configs[0]: start date, configs[1]: end Date,  configs[2]: end Stake Date, configs[3]: lock duration,
     * @param scarcities_ The scarcity levels of tokens
     * @param scarcityMaxCopy_ Maximum copy corresponding to scarcity level
     * @param rewardPerSeconds_ Rewards per second of tokens with correspodning scarcity levels
     * @param magnifyingFactor_ handle decimal precision of reward per seconds
     */
 
    function createPool1155(
        string[] memory strs_,
        uint256[] memory configs_,  
        string[] memory scarcities_, 
        uint256[] memory scarcityMaxCopy_, 
        uint256[] memory rewardPerSeconds_,  
        uint256 magnifyingFactor_
    ) external onlyAdmins{
        string memory poolId_ = strs_[0];

        require(!isPoolExisted(poolId_),"Create1155Pool: Pool already existed");
        require(configs_.length == 4, "Create1155Pool: Invalid config length");
        require(configs_[0] < configs_[2] && configs_[2] <= configs_[1], "Create1155Pool: Invalid configs");
        require(scarcities_.length == scarcityMaxCopy_.length && scarcities_.length == rewardPerSeconds_.length, "Create1155Pool: Invalid scarcity data");

        // Calculate maximum reward of the pool 
        uint256 totalReward;
        uint256 poolDuration = configs_[1] - configs_[0];
        for (uint16 i =0; i< scarcities_.length; i++){
            totalReward += poolDuration * scarcityMaxCopy_[i] * rewardPerSeconds_[i] / magnifyingFactor_;
        }

        uint256[] memory stakedAmounts = new uint256[](scarcities_.length);
        Pool1155 memory pool = Pool1155(
            configs_,
            scarcities_,
            scarcityMaxCopy_,
            rewardPerSeconds_,
            stakedAmounts,
            0,
            0,
            0,
            totalReward,
            true,
            block.timestamp,
            magnifyingFactor_
        );

        poolInfo[poolId_] = pool;
        poolIdToInternalTxId[poolId_] = strs_[1];

        allPools.push(poolId_);

        emit PoolUpdated(totalReward, msg.sender, strs_[0], strs_[1]); 
    }


    /**
     * @dev stake1155
     * @param strs strs[0]: poolId, strs[1]: internalTxId (staking id)
     * @param tokenId_ Id of token 1155
     * @param amount_ amount of tokenId_
     * @param scarcityId_ Id of scarcity levels, corresponding to index of pool.scarcities[]
     * @param signature_ signature generated in the backend (for security)
     */
    function stake1155(
        string[] memory strs,
        uint256 tokenId_,
        uint16 amount_,
        uint16 scarcityId_,
        bytes memory signature_
    ) external notBlocked() poolEnable(strs[0]) {
        string memory poolId_ = strs[0];
        string memory internalTxId = strs[1];
        if (isSignatureEnable){
            require(isAdmin(signatureUtils.verify1155(poolId_, tokenId_, amount_, scarcityId_, signature_)), "Stake 1155: Signature not valid");
        }

        Pool1155 storage pool = poolInfo[poolId_];

        //check if valid stake date
        require(block.timestamp <= pool.configs[2] && block.timestamp >= pool.configs[0], "Stake1155: stake time not valid");

        require(scarcityId_ < pool.scarcities.length, "Stake1155: Invalid scarcityId");

        //check if not exceed staked amount 
        require(pool.stakedAmounts[scarcityId_] + amount_ <= pool.scarcitiyMaxCopy[scarcityId_], "Stake1155: Stake amount exceeds allowance");

        //create staking data 
        StakingData1155 memory data = StakingData1155(
            amount_,
            scarcityId_,
            block.timestamp, //stake time
            0, //unstake time
            block.timestamp, //last update time
            0,
            0,
            0
        );
  
        //increase staking amount of scarcity level of the pool
        pool.stakedAmounts[scarcityId_] += amount_;

        //calculate stake balance and total user staked 
        if (totalStakedInPoolByUser[poolId_][msg.sender] == 0){
            pool.totalUserStaked +=1;
        }
        
        //Save staking data
        stakingIds[poolId_][msg.sender][tokenId_].push(internalTxId);
        stakingDatas[poolId_][msg.sender][tokenId_][internalTxId] = data;

        //update helper data
        totalStakedInPoolByUser[poolId_][msg.sender] += amount_;
        pool.stakedBalance += amount_;
        totalEditionLocked += amount_;

        //transfer amount_ of 1155 token from the user to the contract  
        collection1155.safeTransferFrom(msg.sender, address(this), tokenId_, amount_, "");

        emit StakingEvent(amount_, msg.sender, poolId_, strs[1]);
    }

    /**
     * @dev unstake
     * @param strs strs[0]: poolId, strs[1]: internalTxId (staking id)
     * @param tokenId_ Id of token 1155
     * @param amount_ amount of tokenId_
     */
    function unstake1155(string[] memory strs, uint256 tokenId_, uint256 amount_) external notBlocked() poolEnable(strs[0]){
        string memory poolId_ = strs[0];
        string memory stakingId_ = strs[1];

        require(isStakingDataExisted(poolId_,msg.sender, tokenId_, stakingId_), "1155Unstake: You have no token to unstake");

        StakingData1155 storage data =  stakingDatas[poolId_][msg.sender][tokenId_][stakingId_];
        require(amount_ <= data.amount, "1155Unstake: Unstake amount exceed staked balance");
        
        Pool1155 storage pool = poolInfo[poolId_];

        uint256 reward =0;
        if (isLockedPool1155(poolId_)){
            require(amount_ == data.amount, "1155Unstake: Unstake amount not valid");
           
            if (!canClaimReward1155(poolId_, msg.sender, tokenId_, stakingId_)){
                //empty staking data 
                data.amount = 0;
                data.claimedReward = 0;
                data.recognizedReward = 0;
                data.claimableReward = 0;
                data.lastUpdateTime = block.timestamp;
                data.unstakedTime = block.timestamp;                
            }
            else{
                //calculate pending reward 
                uint256 pendingReward = calculatePendingReward1155(poolId_, msg.sender, tokenId_, stakingId_);

                //update staking data
                _updateReward(data, pendingReward);

                data.amount = 0;
                data.unstakedTime = block.timestamp;
                reward = data.claimableReward;

                //Transfer pending reward to the user 
                IERC20(rewardToken).safeTransfer(msg.sender, data.claimableReward);

                data.claimedReward += data.claimableReward;
                data.claimableReward = 0;

                //update pool total reward claimed
                pool.totalRewardClaimed += reward;
            }
        }
        else{
            //calculate pending reward 
            uint256 pendingReward = calculatePendingReward1155(poolId_, msg.sender, tokenId_, stakingId_);

            //update staking data
            _updateReward(data, pendingReward);
            
            data.amount -= amount_;
            data.unstakedTime = block.timestamp;

            //claim reward
            reward = data.claimableReward;

            //Transfer pending reward to the user 
            IERC20(rewardToken).safeTransfer(msg.sender, data.claimableReward);

            data.claimedReward += data.claimableReward;
            data.claimableReward = 0;

            //update pool total reward claimed
            pool.totalRewardClaimed += reward;
        }
        
        //reduce staked amount of scarcity level of the pool
        pool.stakedAmounts[data.scarcitiyId] -= amount_; 
        pool.stakedBalance -= amount_;

        //update helper data
        totalStakedInPoolByUser[poolId_][msg.sender] -= amount_;
        if (totalStakedInPoolByUser[poolId_][msg.sender] == 0){
            pool.totalUserStaked -= 1;
        }
        totalEditionLocked -= amount_;

        //transfer unstake amount of 1155 back to user (no reward)
        collection1155.safeTransferFrom(address(this), msg.sender, tokenId_, amount_, "");

        emit StakingEvent(reward, msg.sender, poolId_, strs[1]);
    }


    /**
     * @dev claim: claim all amount of staking data corresponding to stakign id 
     * @param strs strs[0]: poolId, strs[1]: internalTxId (staking id)
     * @param tokenId_ Id of token 1155
     */
    function claim1155(string[] memory strs, uint256 tokenId_) external notBlocked() poolEnable(strs[0]){
        string memory poolId_ = strs[0];
        string memory stakingId_ = strs[1];
        
        require(isStakingDataExisted(poolId_,msg.sender, tokenId_, stakingId_), "1155Claim: You have not stake this nft");
        
        StakingData1155 storage data =  stakingDatas[poolId_][msg.sender][tokenId_][stakingId_];

        //update reward 
        uint256 pendingReward = calculatePendingReward1155(poolId_, msg.sender, tokenId_, stakingId_);

        //update stakign data 
        _updateReward(data, pendingReward);

        require(canClaimReward1155(poolId_, msg.sender, tokenId_, stakingId_), "1155Claim: In lock duration period");
        require(data.claimableReward > 0, "1155Claim: You have no token to claim");

        uint256 reward = data.claimableReward;
        //transfer amount of claimable amount from the contract to the user 
        IERC20(rewardToken).safeTransfer(msg.sender, data.claimableReward);

        data.claimedReward += data.claimableReward;
        data.claimableReward = 0;

        //update pool total reward claimed
        Pool1155 storage pool = poolInfo[poolId_];
        pool.totalRewardClaimed += reward;

        emit StakingEvent(reward, msg.sender, poolId_, strs[1]);
    }

    
    /**
     * @dev calculate pending reward since last update time of stakingId_ (internal txId)
     * @param poolId_ id of pool
     * @param user_ user of pool 
     * @param tokenId_ 1155 token id
     * @param stakingId_ id of staking data (corresponding to internalTx id when staking)
     */
    function calculatePendingReward1155(
        string memory poolId_,
        address user_,
        uint256 tokenId_, 
        string memory stakingId_
    ) public view returns(uint256){
        Pool1155 storage pool = poolInfo[poolId_];
        StakingData1155 storage data = stakingDatas[poolId_][user_][tokenId_][stakingId_];

        uint256 lastApplicableTime = block.timestamp <= pool.configs[1] ? block.timestamp : pool.configs[1];
        uint256 validUpdateTime = data.lastUpdateTime <= pool.configs[1] ? data.lastUpdateTime : pool.configs[1]; 
        uint256 timeMultiplier = lastApplicableTime - validUpdateTime; //time passed since last update time (in seconds)

        uint256 pending_reward = timeMultiplier * data.amount * pool.rewardPerSeconds[data.scarcitiyId] / pool.magnifyingFactor;

        return pending_reward;
    }

    /**
     * @dev calculate claimable reward since last update time 
     * @param poolId_ id of pool
     * @param user_ user of pool 
     * @param tokenId_ 1155 token id
     * @param stakingId_ id of staking data (corresponding to internalTx id when staking)
     * @return return the total claimable reward of a staking id
     */
    function calculateClaimableReward1155(string memory poolId_, address user_, uint256 tokenId_, string memory stakingId_) public view returns(uint256){
        StakingData1155 storage data =  stakingDatas[poolId_][user_][tokenId_][stakingId_];
        uint256 pendingReward = calculatePendingReward1155(poolId_, user_, tokenId_, stakingId_);

        return data.claimableReward + pendingReward;
    }


    /**
     * @dev check if user_ can claim reward of stakingId_ of poolId_. 
     * @param poolId_ id of pool
     * @param user_ user of pool 
     * @param tokenId_ 1155 token id
     * @param stakingId_ id of staking data (corresponding to internalTx id when staking)
     */
    function canClaimReward1155(string memory poolId_, address user_, uint256 tokenId_, string memory stakingId_) public view returns(bool){
        Pool1155 storage pool = poolInfo[poolId_];
        StakingData1155 storage data = stakingDatas[poolId_][user_][tokenId_][stakingId_];

        // if no-locked pool
        if (pool.configs[3] == 0) return true;

        if (data.stakedTime + pool.configs[3] * 1 seconds > block.timestamp){
            return false;
        }
        else{
            return true;
        }
    }

    
    function _updateReward(StakingData1155 storage data, uint256 pendingReward) private {
        data.recognizedReward += pendingReward;
        data.lastUpdateTime = block.timestamp;
        data.claimableReward = data.recognizedReward - data.claimedReward;
    }
    /*================================ ADMINISTRATOR FUNCTIONS ================================*/

    /**
     * @dev Withdraw fund admin has sent to the pool
     * @param _tokenAddress: the token contract owner want to withdraw fund
     * @param _account: the account which is used to receive fund
     * @param _amount: the amount contract owner want to withdraw
    */
    function withdrawFund(address _tokenAddress, address _account, uint256 _amount) external {
        require(IERC20(_tokenAddress).balanceOf(address(this)) >= _amount, "Pool not has enough balance");
        
        // Transfer fund back to account
        IERC20(_tokenAddress).safeTransfer(_account, _amount);
    }

    /**
     * @dev enable pool
     */
    function disablePool(string memory poolId_) external onlyAdmins{
        poolInfo[poolId_].isActive = false;
    }

     /**
     * @dev disable pool
     */
    function enablePool(string memory poolId_) external onlyAdmins{
        poolInfo[poolId_].isActive = true;
    }

    /**
     * @dev Contract owner set admin for execute administrator functions
     * @param _address: wallet address of admin
     * @param _value: true/false
    */
    function setAdmin(address _address, bool _value) external { 
        adminList[_address] = _value;
    } 

    /**
     * @dev Check if a wallet address is admin or not
     * @param _address: wallet address of the user
    */
    function isAdmin(address _address) public view returns (bool) {
        return adminList[_address];
    }

    /**
     * @dev Block users
     * @param _address: wallet address of user
     * @param _value: true/false
    */
    function setBlacklist(address _address, bool _value) external onlyAdmins {
        blackList[_address] = _value;
    }
    
    /**
     * @dev Check if a user has been blocked
     * @param _address: user wallet 
    */
    function isBlackList(address _address) external view returns (bool) {
        return blackList[_address];
    }
    
    /**
     * @dev Set signature util contract address for signature verification
     * @param _signatureUtils: signature util contract address
    */
    function setSignatureUtilsAddress(address _signatureUtils) external {
        signatureUtils = SignatureUtils1155(_signatureUtils);
    }

    /**
     * @dev Set reward token contract address
     * @param _rewardToken: address of reward token contract
    */
    function setRewardToken(address _rewardToken) external {
        rewardToken = IERC20(_rewardToken);
    }
    
    /**
     * @dev disable checking signature when stake token
     */
    function disableSignature() external onlyAdmins{
        isSignatureEnable = false;
    }
    
     /**
     * @dev enable checking signature when stake token
     */
    function enableUsingSignature() external onlyAdmins{
        isSignatureEnable = true;
    }

    function emergencyWithdrawOfPool(string memory poolId_) external onlyAdmins{
        Pool1155 storage pool = poolInfo[poolId_];
        uint256 withdrawableAmount = pool.initialFund - pool.totalRewardClaimed;

        require(IERC20(rewardToken).balanceOf(address(this)) > withdrawableAmount, "EmergencyWithdraw: withdraw amount not valid");

        IERC20(rewardToken).safeTransfer(msg.sender, withdrawableAmount);
    }

        /**
     * @dev Emercency withdraw rewardtoken,  onlyProxyOwner can execute this function
     * @param poolId_: the poolId
     * @param account_: the user wallet address want to withdraw token
    */
    function emercencyWithdrawToken(string memory poolId_, address account_) external {
        Pool1155 storage pool = poolInfo[poolId_];

        uint256 withdrawableAmount = pool.initialFund - pool.totalRewardClaimed;
        require(withdrawableAmount> 0, "Staked balance is 0");
        
        // Transfer staking token back to user
        IERC20(rewardToken).safeTransfer(account_, withdrawableAmount);
        
        // update pool
        pool.totalRewardClaimed += withdrawableAmount;

        emit StakingEvent(withdrawableAmount, account_, poolId_, poolIdToInternalTxId[poolId_]);
    }

    function emercencyWithdrawNFT(string memory poolId_, address account_, uint256 tokenId_, string memory stakingId_) external {
        StakingData1155 storage data = stakingDatas[poolId_][account_][tokenId_][stakingId_];
        Pool1155 storage pool = poolInfo[poolId_];

        uint256 withdrawalAmount = data.amount;

        //reduce staked amount of scarcity level of the pool
        pool.stakedAmounts[data.scarcitiyId] -= data.amount; 
        pool.stakedBalance -= data.amount;

        //update helper data
        totalStakedInPoolByUser[poolId_][account_] -= data.amount;
        if (totalStakedInPoolByUser[poolId_][account_] == 0){
            pool.totalUserStaked -= 1;
        }
        totalEditionLocked -= data.amount;

        //transfer money back to the account 
        collection1155.safeTransferFrom(msg.sender, address(this), tokenId_, data.amount, "");

        delete stakingDatas[poolId_][account_][tokenId_][stakingId_];

        emit StakingEvent(withdrawalAmount, account_, poolId_, poolIdToInternalTxId[poolId_]);
    }

    

    /*================================ HELPERS FUNCTIONS ================================*/

    /**
    *  @dev Get total staked balacne of pool
     * @return 0: list of internal txids of pools, 
            1: list of total copies of nft staked of user by each poolid, 
            2: list of total copies of nft staked of all user by each poolid
            3: Total rewarded of each pools
     */
    function getTotalStakedBalanceByPool(address user_, string[] memory poolIds_) external view returns(string[] memory, uint256[] memory, uint256[] memory, uint256[] memory){
        uint256[] memory totalStakedBalanceInPoolByUser = new uint256[](poolIds_.length);
        uint256[] memory totalStakedBalanceOfPool = new uint256[](poolIds_.length);
        string[] memory poolInternalTxIds = new string[](poolIds_.length);
        uint256[] memory totalClaimedAmountOfPool = new uint256[](poolIds_.length);

        for (uint16 i =0; i < poolIds_.length; i ++){
            totalStakedBalanceInPoolByUser[i] = totalStakedInPoolByUser[poolIds_[i]][user_];
            totalStakedBalanceOfPool[i] = poolInfo[poolIds_[i]].stakedBalance;
            poolInternalTxIds[i] = poolIdToInternalTxId[poolIds_[i]];
            totalClaimedAmountOfPool[i] = poolInfo[poolIds_[i]].totalRewardClaimed;
        }

        return (poolInternalTxIds, totalStakedBalanceInPoolByUser, totalStakedBalanceOfPool,totalClaimedAmountOfPool);
    }


    /**
     * @dev get all stakign ids of a token id of user in a pool
     */
    function getStakingIds(string memory poolId_, address user_, uint256 tokenId_) public view returns(string[] memory){
        return stakingIds[poolId_][user_][tokenId_];
    }

    /**
     * @dev check if a pool having locked duration or not 
     */
    function isLockedPool1155(string memory poolId_) public view returns(bool) {
        Pool1155 storage pool = poolInfo[poolId_];
        return pool.configs[3] != 0;
    }

    /**
     * @dev Check if staking data existed 
     */
    function isStakingDataExisted(string memory poolId_, address user_, uint256 tokenId_, string memory stakingId_) public view returns(bool){
        return stakingDatas[poolId_][user_][tokenId_][stakingId_].amount != 0;
    }

    /**
     * @dev check if pool existed
     */
    function isPoolExisted(string memory poolId_) public view returns(bool) {
        return poolInfo[poolId_].createdTime !=0;
    }


    /**
     * @dev get Total reward claimed of all pools
     * @return 0: total intial reward, 1: total reward claimed  
     */
    function getTotalInitialAndClaimedReward() public view returns(uint256, uint256){
        uint256 totalInitalReward;
        uint256 totalRewardClaimed;

        for (uint16 i=0; i < allPools.length; i++){
            totalRewardClaimed += poolInfo[allPools[i]].totalRewardClaimed;
            totalInitalReward += poolInfo[allPools[i]].initialFund;
        }
        return (totalInitalReward,totalRewardClaimed);
    }

    /**
     * @dev for testing
     */
    function blockTime() external view returns(uint256){
        return block.timestamp;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./SignatureUtils1155.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UpgradableV2 is ERC1155Holder{
    IERC1155 public collection1155; // the collection of minted nfts
  
    IERC20 public rewardToken; // reward token 
    SignatureUtils1155 public signatureUtils; // used for signature verification

    bool public isSignatureEnable;
    mapping(address => bool) adminList; // admin list for updating pool
    mapping(address => bool) blackList; // blocked users
    mapping(address => bool) signers; // signers list


    modifier onlyAdmins() {
        require(adminList[msg.sender], "Only admins");
        _;
    }

    modifier notBlocked() {
        require(!blackList[msg.sender], "Caller has been blocked");
        _;
    }

    modifier poolEnable(string memory poolId_) {
        require(poolInfo[poolId_].isActive == true);
        _;
    }


    /**
        todo: how data stored?
     */

    struct Pool1155{
        uint256[] configs; //configs[0]: startDate, configs[1]: endDates ,configs[2]: endStakeDate, configs[3]:lockDuration 
        string[] scarcities; // scarcity level of token 1155
        uint256[] scarcitiyMaxCopy; // coressponding max edition/copy of scarcity level that user can stake to the pool
        uint256[] rewardPerSeconds; // coressponding reward per second for each edition/copy of token with scarcity level 
        uint256[] stakedAmounts; // corresponding staked amount of each scarcity level that user has staked to the pool
        uint256 stakedBalance; // total number of editions/copies that users have staked into the pool
        uint256 totalRewardClaimed; // total amount of reward users have claimed
        uint256 totalUserStaked; // total number of users who are staking
        uint256 initialFund; // expecated max amoutn of reward that will  be distributed to users
        bool isActive;
        uint256 createdTime;
        uint256 magnifyingFactor;  // to handle decimal
    }
 
    struct StakingData1155{
        uint256 amount;  // amount of copies/editions 
        uint256 scarcitiyId; // index in the list of scarcities of pool
        uint256 stakedTime; 
        uint256 unstakedTime;
        uint256 lastUpdateTime;
        uint256 recognizedReward; 
        uint256 claimedReward;
        uint256 claimableReward;
    }


    event StakingEvent( 
        uint256 amount,
        address indexed account,
        string poolId,
        string internalTxID
    );
    

    event PoolUpdated(
        uint256 rewardFund, 
        address indexed creator,
        string poolId,
        string internalTxID
    );

    string[] public allPools;
    uint256 public totalEditionLocked;

    mapping(string => Pool1155) public poolInfo;
    mapping(string => mapping(address => mapping(uint256=>mapping(string=>StakingData1155)))) public stakingDatas; //pool -> user -> tokenId -> internalTxid -> StakingData
    mapping(string=> mapping(address=>mapping(uint256=>string[]))) public stakingIds; // pool -> user -> tokenId -> stakingId[]

    mapping(string => mapping(address =>uint256)) public totalStakedInPoolByUser; // pool => user => totalStaked
    mapping(string => string) public poolIdToInternalTxId; // poolId => internalTxId
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SignatureUtils1155 {
    
    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function recoverSigner(bytes32 hash, bytes memory signature)
        public
        pure
        returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(hash, v, r, s);
        }
    }

    function getMessageHash1155( 
        string memory poolId,
        uint256 tokenId,
        uint256 amount,
        uint256 scarcityId 
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(poolId, tokenId, amount, scarcityId));
    }

    function verify1155(
         string memory poolId,
        uint256 tokenId,
        uint256 amount,
        uint256 scarcityId,
        bytes memory signature
    ) public pure returns (address) {
        bytes32 messageHash = getMessageHash1155(poolId, tokenId, amount, scarcityId);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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