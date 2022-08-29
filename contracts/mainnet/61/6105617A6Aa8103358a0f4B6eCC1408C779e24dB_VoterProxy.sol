// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
// General imports
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./GovernableImplementation.sol";
import "./ProxyImplementation.sol";

// Interfaces
import "./interfaces/IGauge.sol";
import "./interfaces/IUnCone.sol";
import "./interfaces/IUnkwnPool.sol";
import "./interfaces/IUnkwnPoolFactory.sol";
import "./interfaces/IRewardsDistributor.sol";
import "./interfaces/IController.sol";
import "./interfaces/ICone.sol";
import "./interfaces/IConeBribe.sol";
import "./interfaces/IConeGauge.sol";
import "./interfaces/IConePool.sol";
import "./interfaces/IConeLens.sol";
import "./interfaces/ITokensAllowlist.sol";
import "./interfaces/IVe.sol";
import "./interfaces/IVoter.sol";
import "./interfaces/IVoterProxy.sol";
import "./interfaces/IVoterProxyAssets.sol";
import "./interfaces/IVeDist.sol";

/**************************************************
 *                   Voter Proxy
 **************************************************/

contract VoterProxy is
    IERC721Receiver,
    GovernableImplementation,
    ProxyImplementation
{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // Public addresses
    address public unkwnPoolFactoryAddress;
    address public unConeAddress;
    uint256 public primaryTokenId;
    address public rewardsDistributorAddress;
    address public coneAddress;
    address public veAddress;
    address public veDistAddress;
    address public votingSnapshotAddress;

    // Public vars
    uint256 public coneInflationSinceInception;

    // Internal addresses
    address internal voterProxyAddress;

    // Internal interfaces
    IVoter internal voter;
    IController internal controller;
    IVe internal ve;
    IVeDist internal veDist;
    ITokensAllowlist internal tokensAllowlist;

    mapping(address => bool) internal claimDisabledByUnkwnPoolAddress;
    address whitelistCaller;
    bool whitelistNotRestricted;

    // Records cone stored in voterProxy for an unkwnPool
    mapping(address => uint256) public coneStoredForUnkwnPool;

    // Migration
    address public voterProxyAssetsAddress;
    IVoterProxyAssets internal voterProxyAssets;
    address public voterProxyTargetAddress;
    mapping(address => bool) public conePoolMigrated;

    // Operator for maximizing bribes and fees via votes
    mapping(address => bool) public operator;

    /**************************************************
     *                    Events
     **************************************************/
    event OperatorStatus(address indexed candidate, bool status);

    /**
     * @notice Initialize proxy storage
     */
    function initializeProxyStorage(
        address _veAddress,
        address _veDistAddress,
        address _tokensAllowlistAddress
    ) public checkProxyInitialized {
        // Set addresses
        veAddress = _veAddress;
        veDistAddress = _veDistAddress;

        // Set inflation
        coneInflationSinceInception = 1e18;

        // Set interfaces
        ve = IVe(veAddress);
        veDist = IVeDist(veDistAddress);
        controller = IController(ve.controller());
        voter = IVoter(controller.voter());
        tokensAllowlist = ITokensAllowlist(_tokensAllowlistAddress);
    }

    /**************************************************
     *                    Modifiers
     **************************************************/
    modifier onlyUnCone() {
        require(msg.sender == unConeAddress, "Only unCone can deposit NFTs");
        _;
    }

    modifier onlyUnkwnPool() {
        bool _isUnkwnPool = IUnkwnPoolFactory(unkwnPoolFactoryAddress)
            .isUnkwnPool(msg.sender);
        require(_isUnkwnPool, "Only unkwn pools can stake");
        _;
    }

    modifier onlyUnkwnPoolOrLegacyUnkwnPool() {
        require(
            IUnkwnPoolFactory(unkwnPoolFactoryAddress)
                .isUnkwnPoolOrLegacyUnkwnPool(msg.sender),
            "Only unkwn pools can stake"
        );
        _;
    }

    modifier onlyGovernanceOrVotingSnapshotOrOperator() {
        require(
            msg.sender == governanceAddress() ||
                operator[msg.sender] ||
                msg.sender == votingSnapshotAddress,
            "Only governance, voting snapshot, or operator"
        );
        _;
    }

    modifier voterProxyAssetsSet() {
        require(
            voterProxyAssetsAddress != address(0),
            "voterProxyAssetsAddress not set"
        );
        _;
    }

    /**
     * @notice Initialization
     * @param _unkwnPoolFactoryAddress unkwnPool factory address
     * @param _unConeAddress unCone address
     * @dev Can only be initialized once
     */
    function initialize(
        address _unkwnPoolFactoryAddress,
        address _unConeAddress,
        address _votingSnapshotAddress
    ) public {
        bool notInitialized = unkwnPoolFactoryAddress == address(0);
        require(notInitialized, "Already initialized");

        // Set addresses and interfaces
        unkwnPoolFactoryAddress = _unkwnPoolFactoryAddress;
        unConeAddress = _unConeAddress;
        coneAddress = IVe(veAddress).token();
        voterProxyAddress = address(this);
        rewardsDistributorAddress = IUnkwnPoolFactory(_unkwnPoolFactoryAddress)
            .rewardsDistributorAddress();
        votingSnapshotAddress = _votingSnapshotAddress;
    }

    /**************************************************
     *                  Gauge interactions
     **************************************************/

    /**
     * @notice Deposit CONE LP into a gauge
     * @param conePoolAddress Address of LP to deposit
     * @param amount Amount of LP to deposit
     */
    function depositInGauge(address conePoolAddress, uint256 amount)
        public
        onlyUnkwnPool
        voterProxyAssetsSet
    {
        // Cannot deposit nothing
        require(amount > 0, "Nothing to deposit");

        // unkwnPool has transferred LP to VoterProxy...

        // Find gauge address
        address gaugeAddress = voter.gauges(conePoolAddress);
        IConePool conePool = IConePool(conePoolAddress);
        conePool.transfer(voterProxyAssetsAddress, amount);

        // Claim cone on every interaction if possible
        bool coneClaimed = claimCone(msg.sender);

        // Deposit all LP if cone is claimed, withdraw all if not
        if (coneClaimed) {
            // Deposit CONE LP into gauge
            voterProxyAssets.depositInGauge(conePoolAddress, gaugeAddress);
        } else {
            uint256 gaugeBalance = IConeGauge(gaugeAddress).balanceOf(
                voterProxyAssetsAddress
            );
            if (gaugeBalance > 0) {
                voterProxyAssets.withdrawFromGauge(
                    conePoolAddress,
                    gaugeAddress,
                    IConeGauge(gaugeAddress).balanceOf(voterProxyAssetsAddress)
                );
            }
        }
    }

    /**
     * @notice Withdraw CONE LP from a gauge
     * @param conePoolAddress Address of LP to withdraw
     * @param amount Amount of LP to withdraw
     */
    function withdrawFromGauge(address conePoolAddress, uint256 amount)
        public
        onlyUnkwnPoolOrLegacyUnkwnPool
        voterProxyAssetsSet
    {
        require(amount > 0, "Nothing to withdraw");

        // Fetch gauge address
        address gaugeAddress = voter.gauges(conePoolAddress);
        IConePool conePool = IConePool(conePoolAddress);

        /**
         * Claim cone on every interaction if possible
         * In some cases it's not possible to claim due to an unbounded for loop in Coney gauge.getReward
         */
        bool coneClaimed = claimCone(msg.sender, false);

        if (!conePoolMigrated[conePoolAddress]) {
            migrateLp(conePoolAddress);
        }

        // Only withdraw from gauge if coneClaimed, otherwise enter caching mode
        if (coneClaimed) {
            // If there's LP in voterProxyAssets, it means we just got back from caching mode
            // deposit all except the withdrawal amount

            if (conePool.balanceOf(voterProxyAssetsAddress) > 0) {
                conePool.transferFrom(
                    voterProxyAssetsAddress,
                    msg.sender,
                    amount
                );
                voterProxyAssets.depositInGauge(conePoolAddress, gaugeAddress);
            } else {
                voterProxyAssets.withdrawFromGauge(
                    conePoolAddress,
                    gaugeAddress,
                    amount
                );
                conePool.transferFrom(
                    voterProxyAssetsAddress,
                    msg.sender,
                    amount
                );
            }
        } else {
            uint256 gaugeBalance = IConeGauge(gaugeAddress).balanceOf(
                voterProxyAssetsAddress
            );
            if (gaugeBalance > 0) {
                voterProxyAssets.withdrawFromGauge(
                    conePoolAddress,
                    gaugeAddress,
                    gaugeBalance
                );
            }
            conePool.transferFrom(voterProxyAssetsAddress, msg.sender, amount);
        }
    }

    /**
     * @notice Pokes LP into gauge if gauge is sync'd
     * @param unkwnPoolAddress Address of unkwnPool to poke
     * @param batchAmount Amount of checkpoints to sync
     */
    function pokeGauge(address unkwnPoolAddress, uint256 batchAmount)
        external
        voterProxyAssetsSet
    {
        // Find addresses
        address conePoolAddress = IUnkwnPool(unkwnPoolAddress)
            .conePoolAddress();
        address gaugeAddress = voter.gauges(conePoolAddress);

        // Determine lag
        uint256 lag = bribeSupplyLag(gaugeAddress, coneAddress);
        // If batchAmount is 0, default to max batch if lag > bribeSyncLagLimit
        // Adjust batchAmount to max batch if lag > bribeSyncLagLimit
        if (
            (batchAmount == 0 || batchAmount >= lag) &&
            lag > tokensAllowlist.bribeSyncLagLimit()
        ) {
            batchAmount = lag.sub(1);
        }
        // Batch checkpoints
        batchCheckPointOrGetReward(gaugeAddress, coneAddress, batchAmount);

        // Claim cone on every interaction if possible
        bool coneClaimed = claimCone(unkwnPoolAddress);

        // Deposit all LP if cone is claimed
        if (coneClaimed) {
            // Deposit CONE LP into gauge
            voterProxyAssets.depositInGauge(conePoolAddress, gaugeAddress);
        }
        notifyConeRewards(unkwnPoolAddress);
    }

    /**************************************************
     *                      Rewards
     **************************************************/

    /**
     * @notice Get fees from bribe
     * @param unkwnPoolAddress Address of unkwnPool
     */
    function getFeeTokensFromBribe(address unkwnPoolAddress)
        public
        returns (bool allClaimed)
    {
        // auth to prevent legacy pools from claiming but without reverting
        if (
            !IUnkwnPoolFactory(unkwnPoolFactoryAddress).isUnkwnPool(
                unkwnPoolAddress
            )
        ) {
            return true;
        }
        IUnkwnPool unkwnPool = IUnkwnPool(unkwnPoolAddress);
        IConeLens.Pool memory conePoolInfo = unkwnPool.conePoolInfo();
        address gaugeAddress = conePoolInfo.gaugeAddress;

        address[] memory feeTokenAddresses = new address[](2);
        feeTokenAddresses[0] = conePoolInfo.token0Address;
        feeTokenAddresses[1] = conePoolInfo.token1Address;
        (allClaimed, ) = getRewardFromBribe(
            unkwnPoolAddress,
            feeTokenAddresses
        );
        if (allClaimed) {
            // low-level call, so rest will still run even if revert
            // doing this because tax-on-transfer tokens brick cone's fee contracts
            gaugeAddress.call(abi.encodeWithSignature("claimFees()"));
        }
    }

    /**
     * @notice Claims LP CONE emissions and calls rewardsDistributor,
     * with a check if notifyConeThreshold should be respected or not.
     * @param unkwnPoolAddress the unkwnPool to claim for
     * @param isRespectingThreshold is it respecting the notifyConeThreshold
     * or not?
     */
    function claimCone(address unkwnPoolAddress, bool isRespectingThreshold)
        public
        returns (bool _claimCone)
    {
        // auth to prevent legacy pools from claiming but without reverting
        if (
            !IUnkwnPoolFactory(unkwnPoolFactoryAddress).isUnkwnPool(
                unkwnPoolAddress
            )
        ) {
            return false;
        }
        IUnkwnPool unkwnPool = IUnkwnPool(unkwnPoolAddress);
        IConeLens.Pool memory conePoolInfo = unkwnPool.conePoolInfo();
        address gaugeAddress = conePoolInfo.gaugeAddress;

        // low-level call, so rest will still run even if revert
        // doing this because tax-on-transfer tokens brick cone's fee contracts
        (bool distributed, ) = address(voter).call(
            abi.encodeWithSignature("distribute(address)", gaugeAddress)
        );

        _claimCone = (distributed &&
            _batchCheckPointOrGetReward(gaugeAddress, coneAddress));

        if (_claimCone) {
            // Claim CONE via voterProxyAssets
            uint256 amountClaimed = voterProxyAssets.claimCone(gaugeAddress);
            // Record CONE claimed
            coneStoredForUnkwnPool[unkwnPoolAddress] = coneStoredForUnkwnPool[
                unkwnPoolAddress
            ].add(amountClaimed);

            bool isStoredConeExceedingThreshold =
                coneStoredForUnkwnPool[unkwnPoolAddress] >
                tokensAllowlist.notifyConeThreshold();
            if (isRespectingThreshold ? isStoredConeExceedingThreshold : true) {
                notifyConeRewards(unkwnPoolAddress);
            }
        }
    }

    /**
     * @notice Claims LP CONE emissions and calls rewardsDistributor
     * @param unkwnPoolAddress the unkwnPool to claim for
     */
    function claimCone(address unkwnPoolAddress)
        public
        returns (bool _claimCone)
    {
        // auth to prevent legacy pools from claiming but without reverting
        if (
            !IUnkwnPoolFactory(unkwnPoolFactoryAddress).isUnkwnPool(
                unkwnPoolAddress
            )
        ) {
            return false;
        }
        IUnkwnPool unkwnPool = IUnkwnPool(unkwnPoolAddress);
        IConeLens.Pool memory conePoolInfo = unkwnPool.conePoolInfo();
        address gaugeAddress = conePoolInfo.gaugeAddress;

        // low-level call, so rest will still run even if revert
        // doing this because tax-on-transfer tokens brick cone's fee contracts
        (bool distributed, ) = address(voter).call(
            abi.encodeWithSignature("distribute(address)", gaugeAddress)
        );

        _claimCone = (distributed &&
            _batchCheckPointOrGetReward(gaugeAddress, coneAddress));

        if (_claimCone) {
            // Claim CONE via voterProxyAssets
            uint256 amountClaimed = voterProxyAssets.claimCone(gaugeAddress);
            // Record CONE claimed
            coneStoredForUnkwnPool[unkwnPoolAddress] = coneStoredForUnkwnPool[
                unkwnPoolAddress
            ].add(amountClaimed);

            if (
                coneStoredForUnkwnPool[unkwnPoolAddress] >
                tokensAllowlist.notifyConeThreshold()
            ) {
                notifyConeRewards(unkwnPoolAddress);
            }
        }
    }

    /**
     * @notice Notify cone rewards for an unkwnPool
     * @param unkwnPoolAddress the unkwnPool to nottify rewards for
     */
    function notifyConeRewards(address unkwnPoolAddress) public {
        // auth to prevent legacy pools from claiming but without reverting
        require(
            IUnkwnPoolFactory(unkwnPoolFactoryAddress).isUnkwnPool(
                unkwnPoolAddress
            ),
            "Not an unkwnPool"
        );

        IUnkwnPool unkwnPool = IUnkwnPool(unkwnPoolAddress);
        address stakingAddress = unkwnPool.stakingAddress();

        uint256 _coneEarned = coneStoredForUnkwnPool[unkwnPoolAddress];

        coneStoredForUnkwnPool[unkwnPoolAddress] = 0;

        IERC20(coneAddress).safeTransferFrom(
            voterProxyAssetsAddress,
            rewardsDistributorAddress,
            _coneEarned
        );
        IRewardsDistributor(rewardsDistributorAddress).notifyRewardAmount(
            stakingAddress,
            coneAddress,
            _coneEarned
        );
    }

    /**
     * @notice Claim bribes and notify rewards contract of new balances
     * @param unkwnPoolAddress unkwnPool address
     * @param _tokensAddresses Bribe tokens addresses
     */
    function getRewardFromBribe(
        address unkwnPoolAddress,
        address[] memory _tokensAddresses
    ) public returns (bool allClaimed, bool[] memory claimed) {
        (allClaimed, claimed) = _getRewardFromCone(
            unkwnPoolAddress,
            _tokensAddresses,
            true
        );
    }

    /**
     * @notice Fetch reward from unkwnPool given token addresses
     * @param unkwnPoolAddress Address of the unkwnPool
     * @param tokensAddresses Tokens to fetch rewards for
     */
    function getRewardFromUnkwnPool(
        address unkwnPoolAddress,
        address[] memory tokensAddresses
    ) public {
        getRewardFromGauge(unkwnPoolAddress, tokensAddresses);
    }

    /**
     * @notice Fetch reward from gauge
     * @param unkwnPoolAddress Address of unkwnPool contract
     * @param _tokensAddresses Tokens to fetch rewards for
     */
    function getRewardFromGauge(
        address unkwnPoolAddress,
        address[] memory _tokensAddresses
    ) public returns (bool allClaimed, bool[] memory claimed) {
        (allClaimed, claimed) = _getRewardFromCone(
            unkwnPoolAddress,
            _tokensAddresses,
            false
        );
    }

    /**
     * @notice Fetch reward from CONE bribe or gauge
     * @param unkwnPoolAddress Address of unkwnPool contract
     * @param _tokensAddresses Tokens to fetch rewards for
     * @param fromBribe getting from bribe rather than gauge
     */
    function _getRewardFromCone(
        address unkwnPoolAddress,
        address[] memory _tokensAddresses,
        bool fromBribe
    )
        internal
        voterProxyAssetsSet
        returns (bool allClaimed, bool[] memory claimed)
    {
        // auth to prevent legacy pools from claiming but without reverting
        if (
            !IUnkwnPoolFactory(unkwnPoolFactoryAddress).isUnkwnPool(
                unkwnPoolAddress
            )
        ) {
            claimed = new bool[](_tokensAddresses.length);
            for (uint256 i; i < _tokensAddresses.length; i++) {
                claimed[i] = false;
            }
            return (false, claimed);
        }

        // Establish addresses
        IUnkwnPool unkwnPool = IUnkwnPool(unkwnPoolAddress);
        address _stakingAddress = unkwnPool.stakingAddress();
        address _gaugeOrBribeAddress;
        if (fromBribe) {
            IConeLens.Pool memory conePoolInfo = unkwnPool.conePoolInfo();
            _gaugeOrBribeAddress = conePoolInfo.bribeAddress;
        } else {
            _gaugeOrBribeAddress = unkwnPool.gaugeAddress();
        }

        // New array to record whether a token's claimed
        claimed = new bool[](_tokensAddresses.length);

        // Preflight - check whether to batch checkpoints or to claim said token
        address[] memory _claimableAddresses;
        _claimableAddresses = new address[](_tokensAddresses.length);
        uint256 j;

        // Populate a new array with addresses that are ready to be claimed
        for (uint256 i; i < _tokensAddresses.length; i++) {
            if (
                _batchCheckPointOrGetReward(
                    _gaugeOrBribeAddress,
                    _tokensAddresses[i]
                )
            ) {
                _claimableAddresses[j] = _tokensAddresses[i];
                claimed[j] = true;
                j++;
            }
        }
        // Clean up _claimableAddresses array, so we don't pass a bunch of address(0)s to IConeBribe
        address[] memory claimableAddresses = new address[](j);
        for (uint256 k; k < j; k++) {
            claimableAddresses[k] = _claimableAddresses[k];
        }

        // Actually claim rewards that are deemed claimable
        if (claimableAddresses.length != 0) {
            if (fromBribe) {
                voterProxyAssets.getRewardFromBribe(
                    _stakingAddress,
                    _gaugeOrBribeAddress,
                    claimableAddresses
                );
            } else {
                voterProxyAssets.getRewardFromGauge(
                    _stakingAddress,
                    _gaugeOrBribeAddress,
                    claimableAddresses
                );
            }
            // If everything was claimable, flag return to true
            if (claimableAddresses.length == _tokensAddresses.length) {
                if (
                    claimableAddresses[claimableAddresses.length - 1] !=
                    address(0)
                ) {
                    allClaimed = true;
                }
            }
        }
    }

    /**
     * @notice Batch fetch reward
     * @param bribeAddress Address of bribe
     * @param tokenAddress Reward token address
     * @param lagLimit Number of indexes per batch
     * @dev This method is important because if we don't do this CONE claiming can be bricked due to gas costs
     */
    function batchCheckPointOrGetReward(
        address bribeAddress,
        address tokenAddress,
        uint256 lagLimit
    ) public returns (bool _getReward) {
        if (tokenAddress == address(0)) {
            return _getReward; //returns false if address(0)
        }
        IConeBribe bribe = IConeBribe(bribeAddress);
        uint256 lastUpdateTime = bribe.lastUpdateTime(tokenAddress);
        uint256 priorSupplyIndex = bribe.getPriorSupplyIndex(lastUpdateTime);
        uint256 supplyNumCheckpoints = bribe.supplyNumCheckpoints();
        uint256 lag;
        if (supplyNumCheckpoints > priorSupplyIndex) {
            lag = supplyNumCheckpoints.sub(priorSupplyIndex);
        }
        if (lag > lagLimit) {
            bribe.batchRewardPerToken(
                tokenAddress,
                priorSupplyIndex.add(lagLimit)
            ); // costs about 250k gas, around 3% of an ftm block. Don't want to do too many since we need to chain these sometimes. Hardcoded to save some gas (probably don't need changing anyway)
        } else {
            _getReward = true;
        }
    }

    /**
     * @notice Internal reward batching
     * @param bribeAddress Address of bribe
     * @param tokenAddress Reward token address
     */
    function _batchCheckPointOrGetReward(
        address bribeAddress,
        address tokenAddress
    ) internal returns (bool _getReward) {
        uint256 lagLimit = tokensAllowlist.bribeSyncLagLimit();
        _getReward = batchCheckPointOrGetReward(
            bribeAddress,
            tokenAddress,
            lagLimit
        );
    }

    /**
     * @notice returns bribe contract supply checkpoint lag
     * @param bribeAddress Address of bribe
     * @param tokenAddress Reward token address
     * @dev This method is important because if we don't do this CONE claiming can be bricked due to gas costs
     */
    function bribeSupplyLag(address bribeAddress, address tokenAddress)
        public
        view
        returns (uint256 lag)
    {
        if (tokenAddress == address(0)) {
            return lag; //returns 0
        }
        IConeBribe bribe = IConeBribe(bribeAddress);
        uint256 lastUpdateTime = bribe.lastUpdateTime(tokenAddress);
        uint256 priorSupplyIndex = bribe.getPriorSupplyIndex(lastUpdateTime);
        uint256 supplyNumCheckpoints = bribe.supplyNumCheckpoints();
        if (supplyNumCheckpoints > priorSupplyIndex) {
            lag = supplyNumCheckpoints.sub(priorSupplyIndex);
        }
    }

    /**
     * @notice returns bribe contract supply checkpoint lag is out of sync or not
     * @param bribeAddress Address of bribe
     * @param tokenAddress Reward token address
     * @dev This method is important because if we don't do this CONE claiming can be bricked due to gas costs
     */
    function bribeSupplyOutOfSync(address bribeAddress, address tokenAddress)
        public
        view
        returns (bool outOfSync)
    {
        if (tokenAddress == address(0)) {
            return false; //returns false
        }
        IConeBribe bribe = IConeBribe(bribeAddress);
        uint256 lastUpdateTime = bribe.lastUpdateTime(tokenAddress);
        uint256 priorSupplyIndex = bribe.getPriorSupplyIndex(lastUpdateTime);
        uint256 supplyNumCheckpoints = bribe.supplyNumCheckpoints();
        uint256 lag;
        if (supplyNumCheckpoints > priorSupplyIndex) {
            lag = supplyNumCheckpoints.sub(priorSupplyIndex);
        }
        if (lag > tokensAllowlist.bribeSyncLagLimit()) {
            outOfSync = true;
        }
    }

    /**
     * @notice checks whether claiming cone can be done within block gas limit, returns false if it will run out-of-gas
     * @param gaugeAddress Address of gauge
     * @param tokenAddress Reward token address
     */
    function gaugeWithinOogSyncLimit(address gaugeAddress, address tokenAddress)
        public
        view
        returns (bool canClaim)
    {
        if (tokenAddress == address(0)) {
            return canClaim; //returns false if address(0)
        }
        uint256 lag = gaugeAccountLag(gaugeAddress, tokenAddress);

        uint256 oogLimit = tokensAllowlist.oogLoopLimit();
        if (oogLimit > lag) {
            canClaim = true;
        }
    }

    /**
     * @notice returns gauge account checkpoint lag
     * @param gaugeAddress Address of gauge
     * @param tokenAddress Reward token address
     */
    function gaugeAccountLag(address gaugeAddress, address tokenAddress)
        public
        view
        returns (uint256 lag)
    {
        if (tokenAddress == address(0)) {
            return lag; //returns 0
        }
        IConeGauge gauge = IConeGauge(gaugeAddress);
        uint256 lastUpdateTime = Math.max(
            gauge.lastEarn(tokenAddress, voterProxyAssetsAddress),
            gauge.rewardPerTokenCheckpoints(tokenAddress, 0).timestamp
        );

        uint256 priorBalanceIndex = gauge.getPriorBalanceIndex(
            voterProxyAssetsAddress,
            lastUpdateTime
        );
        uint256 numCheckpoints = gauge.numCheckpoints(voterProxyAssetsAddress);

        if (numCheckpoints > priorBalanceIndex.add(1)) {
            lag = numCheckpoints.sub(priorBalanceIndex).sub(1);
        }
    }

    /**************************************************
     *             Voting and Whitelisting
     **************************************************/

    /**
     * @notice Submit vote to CONE
     * @param poolVote Addresses of pools to vote on
     * @param weights Weights of pools to vote on
     * @dev For first round only governnce can vote, after that voting snapshot can vote
     */
    function vote(address[] memory poolVote, int256[] memory weights)
        external
        onlyGovernanceOrVotingSnapshotOrOperator
    {
        voterProxyAssets.vote(poolVote, weights);
    }

    /**
     * @notice Whitelist a token on CONE
     * @param tokenAddress Address to whitelist
     * @param tokenId Token ID to use for whitelist
     */
    function whitelist(address tokenAddress, uint256 tokenId)
        external
        onlyGovernanceOrVotingSnapshotOrOperator
    {
        voterProxyAssets.whitelist(tokenAddress, tokenId);
    }

    function whitelist(address tokenAddress) external {
        require(
            IUnCone(unConeAddress).balanceOf(msg.sender) > whitelistingFee(),
            "Insufficient unConelance"
        );
        require(
            msg.sender == whitelistCaller || whitelistNotRestricted,
            "Restricted function"
        );
        voterProxyAssets.whitelist(tokenAddress, primaryTokenId);
    }

    /**
     * @notice Sets operator that can vote and whitelist to maximize bribes
     * @param candidate Address of candidate
     * @param status candidate operator status
     */
    function setOperator(address candidate, bool status)
        external
        onlyGovernance
    {
        operator[candidate] = status;
        emit OperatorStatus(candidate, status);
    }

    /**************************************************
     *                   Migration
     **************************************************/

    function detachNFT(uint256 startingIndex, uint256 range)
        external
        onlyGovernance
    {
        IUnkwnPoolFactory unkwnPoolFactory = IUnkwnPoolFactory(
            unkwnPoolFactoryAddress
        );

        // calc endIndex, compare to existing unkwnPoolsLength
        uint256 endIndex = startingIndex.add(range);
        uint256 unkwnPoolsLength = unkwnPoolFactory.unkwnPoolsLength();
        if (endIndex > unkwnPoolsLength) {
            endIndex = unkwnPoolsLength;
        }

        // operation for each unkwnPool
        for (uint256 i = startingIndex; i < endIndex; i++) {
            // get gauge via unkwnPool
            IConeGauge gauge = IConeGauge(
                IUnkwnPool(unkwnPoolFactory.unkwnPools(i)).gaugeAddress()
            );

            // check if detached, detach if not
            if (gauge.tokenIds(address(this)) > 0) {
                gauge.withdrawToken(0, primaryTokenId);
            }
        }

        // if all done, transfer NFT and activate it in voterProxyAssets
        if (endIndex == unkwnPoolsLength) {
            // clear votes
            voter.reset(primaryTokenId);

            // transfer NFT
            ve.safeTransferFrom(
                address(this),
                voterProxyAssetsAddress,
                primaryTokenId
            );

            // setup NFT in voterProxyAssets
            voterProxyAssets.setPrimaryTokenId();
        }
    }

    function setVoterProxyAssetsAddress(address _voterProxyAssetsAddress)
        external
        onlyGovernance
    {
        require(
            _voterProxyAssetsAddress != address(0),
            "Invalid _voterProxyAssetsAddress"
        );
        IERC20 cone = IERC20(coneAddress);
        voterProxyAssetsAddress = _voterProxyAssetsAddress;
        voterProxyAssets = IVoterProxyAssets(_voterProxyAssetsAddress);
        cone.transfer(_voterProxyAssetsAddress, cone.balanceOf(address(this)));
    }

    function migrateLp(address conePoolAddress) public voterProxyAssetsSet {
        // this can replace auth, silently fail so it doesn't revert batch txs
        if (conePoolMigrated[conePoolAddress]) {
            return;
        }

        // Fetch gauge
        address gaugeAddress = voter.gauges(conePoolAddress);

        // Determine voter proxy addresses
        address _voterProxyAddress = address(this);

        // Find gauge balance of voter proxy
        uint256 gaugeBalance = IConeGauge(gaugeAddress).balanceOf(
            _voterProxyAddress
        );

        // Withdraw LP from voter proxy
        IConeGauge(gaugeAddress).withdraw(gaugeBalance);

        // TODO: make sure balance increased

        // Find total LP amount in voter proxy
        IConePool conePool = IConePool(conePoolAddress);
        uint256 totalBalance = conePool.balanceOf(address(this));

        // Transfer LP tokens to voterProxyAssets
        conePool.transfer(voterProxyAssetsAddress, totalBalance);
        bool gaugeSynced = _batchCheckPointOrGetReward(
            gaugeAddress,
            coneAddress
        );
        if (gaugeSynced) {
            voterProxyAssets.depositInGauge(conePoolAddress, gaugeAddress);
        } else {
            voterProxyAssets.withdrawFromGauge(
                conePoolAddress,
                gaugeAddress,
                0
            );
        }

        /**
         * Keep track of whether or not a migration is complete
         * This will be used during deposit and withdraw logic
         */
        conePoolMigrated[conePoolAddress] = true;
    }

    /**************************************************
     *               Ve Dillution mechanism
     **************************************************/

    /**
     * @notice Claims CONE inflation for veNFT, logs inflation record, mints corresponding UnCONE, and distributes UnCONE
     */
    function claim() external {
        uint256 lockedAmount = ve.locked(primaryTokenId);
        uint256 inflationAmount = voterProxyAssets.claim();
        coneInflationSinceInception = coneInflationSinceInception
            .mul(
                (inflationAmount.add(lockedAmount)).mul(1e18).div(lockedAmount)
            )
            .div(1e18);
        IUnCone(unConeAddress).mint(voterProxyAddress, inflationAmount);
        IERC20(unConeAddress).safeTransfer(
            rewardsDistributorAddress,
            inflationAmount
        );
        IRewardsDistributor(rewardsDistributorAddress).notifyRewardAmount(
            voterProxyAddress,
            unConeAddress,
            inflationAmount
        );
    }

    /**************************************************
     *                    Claims
     **************************************************/

    function setClaimDisabledUnkwnByPoolAddress(
        address poolAddress,
        bool disabled
    ) public onlyGovernance {
        claimDisabledByUnkwnPoolAddress[poolAddress] = disabled;
    }

    /**************************************************
     *                 NFT Interactions
     **************************************************/

    /**
     * @notice Deposit and merge NFT
     * @param tokenId The token ID to deposit
     * @dev Note: Depositing is a one way/nonreversible action
     */
    function depositNft(uint256 tokenId) public onlyUnCone {
        // Set primary token ID if it hasn't been set yet
        bool primaryTokenIdSet = primaryTokenId > 0;
        if (!primaryTokenIdSet) {
            primaryTokenId = tokenId;
        }

        // Transfer NFT from msg.sender to voterProxyAssets
        ve.safeTransferFrom(msg.sender, voterProxyAssetsAddress, tokenId);

        // If primary token ID is set, merge the NFT
        if (primaryTokenIdSet) {
            voterProxyAssets.depositNft(tokenId);
        }
    }

    /**
     * @notice Convert CONE to veNFT and deposit for UnCONE
     * @param amount The amount of CONE to lock
     */
    function lockCone(uint256 amount) external {
        ICone cone = ICone(coneAddress);
        cone.transferFrom(msg.sender, voterProxyAssetsAddress, amount);
        voterProxyAssets.lockCone(amount);
        IUnCone(unConeAddress).mint(msg.sender, amount);
    }

    /**
     * @notice Don't do anything with direct NFT transfers
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    // function voterAddress() public view returns (address) {
    //     return ve.voter();
    // }

    /**************************************************
     *                   View methods
     **************************************************/

    /**
     * @notice Calculate amount of CONE currently claimable by VoterProxy
     * @param gaugeAddress The address of the gauge VoterProxy has earned on
     */
    function coneEarned(address gaugeAddress) public view returns (uint256) {
        return
            IGauge(gaugeAddress).earned(coneAddress, voterProxyAssetsAddress);
    }

    function whitelistingFee() public view returns (uint256) {
        return voter.listingFee();
    }

    /**************************************************
     *                   Setters
     **************************************************/

    function setWhitelistCaller(address _whitelistCaller)
        public
        onlyGovernance
    {
        whitelistCaller = _whitelistCaller;
    }

    function setWhitelistNotRestricted(bool _whitelistNotRestricted)
        public
        onlyGovernance
    {
        whitelistNotRestricted = _whitelistNotRestricted;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

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
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11||0.6.12;

/**
 * @title Ownable contract which allows governance to be killed, adapted to be used under a proxy
 * @author Unknown
 */
contract GovernableImplementation {
    address internal doNotUseThisSlot; // used to be governanceAddress, but there's a hash collision with the proxy's governanceAddress
    bool public governanceIsKilled;

    /**
     * @notice legacy
     * @dev public visibility so it compiles for 0.6.12
     */
    constructor() public {
        doNotUseThisSlot = msg.sender;
    }

    /**
     * @notice Only allow governance to perform certain actions
     */
    modifier onlyGovernance() {
        require(msg.sender == governanceAddress(), "Only governance");
        _;
    }

    /**
     * @notice Set governance address
     * @param _governanceAddress The address of new governance
     */
    function setGovernanceAddress(address _governanceAddress)
        public
        onlyGovernance
    {
        require(msg.sender == governanceAddress(), "Only governance");
        assembly {
            sstore(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103,
                _governanceAddress
            ) // keccak256('eip1967.proxy.admin')
        }
    }

    /**
     * @notice Allow governance to be killed
     */
    function killGovernance() external onlyGovernance {
        setGovernanceAddress(address(0));
        governanceIsKilled = true;
    }

    /**
     * @notice Fetch current governance address
     * @return _governanceAddress Returns current governance address
     * @dev directing to the slot that the proxy would use
     */
    function governanceAddress()
        public
        view
        returns (address _governanceAddress)
    {
        assembly {
            _governanceAddress := sload(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103
            ) // keccak256('eip1967.proxy.admin')
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11||0.6.12;

/**
 * @title Implementation meant to be used with a proxy
 * @author Unknown
 */
contract ProxyImplementation {
    bool public proxyStorageInitialized;

    /**
     * @notice Nothing in constructor, since it only affects the logic address, not the storage address
     * @dev public visibility so it compiles for 0.6.12
     */
    constructor() public {}

    /**
     * @notice Only allow proxy's storage to be initialized once
     */
    modifier checkProxyInitialized() {
        require(
            !proxyStorageInitialized,
            "Can only initialize proxy storage once"
        );
        proxyStorageInitialized = true;
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IGauge {
    function rewardTokens(uint256) external returns (address);

    function rewardTokensLength() external view returns (uint256);

    function earned(address, address) external view returns (uint256);

    function getReward(address account, address[] memory tokens) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUnCone is IERC20 {
    function mint(address, uint256) external;

    function convertNftToUnCone(uint256) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "./IConeLens.sol";

interface IUnkwnPool {
    function stakingAddress() external view returns (address);

    function conePoolAddress() external view returns (address);

    function conePoolInfo() external view returns (IConeLens.Pool memory);

    function depositLpAndStake(uint256) external;

    function depositLp(uint256) external;

    function withdrawLp(uint256) external;

    function syncBribeTokens() external;

    function notifyBribeOrFees() external;

    function initialize(
        address,
        address,
        address,
        string memory,
        string memory,
        address,
        address
    ) external;

    function gaugeAddress() external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IUnkwnPoolFactory {
    function unkwnPoolsLength() external view returns (uint256);

    function isUnkwnPool(address) external view returns (bool);

    function isUnkwnPoolOrLegacyUnkwnPool(address) external view returns (bool);

    function UNKWN() external view returns (address);

    function syncPools(uint256) external;

    function unkwnPools(uint256) external view returns (address);

    function unkwnPoolByConePool(address) external view returns (address);

    function vlUnkwnAddress() external view returns (address);

    function conePoolByUnkwnPool(address) external view returns (address);

    function syncedPoolsLength() external returns (uint256);

    function coneLensAddress() external view returns (address);

    function voterProxyAddress() external view returns (address);

    function rewardsDistributorAddress() external view returns (address);

    function tokensAllowlist() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IRewardsDistributor {
    function notifyRewardAmount(
        address stakingAddress,
        address rewardToken,
        uint256 amount
    ) external;

    function setRewardPoolOwner(address stakingAddress, address _owner)
        external;

    function setOperator(address candidate, bool status) external;

    function operator(address candidate) external returns (bool status);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IController {

  function veDist() external view returns (address);

  function voter() external view returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface ICone {
    function transferFrom(
        address,
        address,
        uint256
    ) external;

    function allowance(address, address) external view returns (uint256);

    function approve(address, uint256) external;

    function balanceOf(address) external view returns (uint256);

    function router() external view returns (address);

    function minter() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IConeBribe {
    struct RewardPerTokenCheckpoint {
        uint256 timestamp;
        uint256 rewardPerToken;
    }

    function balanceOf(uint256 tokenId) external returns (uint256 balance);

    function getPriorSupplyIndex(uint256 timestamp)
        external
        view
        returns (uint256);

    function rewardPerTokenNumCheckpoints(address rewardTokenAddress)
        external
        view
        returns (uint256);

    function lastUpdateTime(address rewardTokenAddress)
        external
        view
        returns (uint256);

    function batchRewardPerToken(address token, uint256 maxRuns) external;

    function getReward(uint256 tokenId, address[] memory tokens) external;

    function supplyNumCheckpoints() external view returns (uint256);

    function rewardPerTokenCheckpoints(address token, uint256 checkpoint)
        external
        view
        returns (RewardPerTokenCheckpoint memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IConeGauge {
    struct RewardPerTokenCheckpoint {
        uint256 timestamp;
        uint256 rewardPerToken;
    }

    function deposit(uint256, uint256) external;

    function withdraw(uint256) external;

    function withdrawToken(uint256, uint256) external;

    function balanceOf(address) external view returns (uint256);

    function getReward(address account, address[] memory tokens) external;

    function claimFees() external returns (uint256 claimed0, uint256 claimed1);

    function lastEarn(address, address) external view returns (uint256);

    function rewardPerTokenCheckpoints(address, uint256)
        external
        view
        returns (RewardPerTokenCheckpoint memory);

    function getPriorBalanceIndex(address account, uint256 timestamp)
        external
        view
        returns (uint256);

    function numCheckpoints(address) external view returns (uint256);

    function tokenIds(address) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IConePool {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function fees() external view returns (address);

    function stable() external view returns (bool);

    function symbol() external view returns (string memory);

    function claimable0(address) external view returns (uint256);

    function claimable1(address) external view returns (uint256);

    function approve(address, uint256) external;

    function transfer(address, uint256) external;

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address) external view returns (uint256);

    function getReserves()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function reserve0() external view returns (uint256);

    function reserve1() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function claimFees() external returns (uint256 claimed0, uint256 claimed1);

    function allowance(address, address) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IConeLens {
    struct Pool {
        address id;
        string symbol;
        bool stable;
        address token0Address;
        address token1Address;
        address gaugeAddress;
        address bribeAddress;
        address[] bribeTokensAddresses;
        address fees;
        uint256 totalSupply;
    }

    struct PoolReserveData {
        address id;
        address token0Address;
        address token1Address;
        uint256 token0Reserve;
        uint256 token1Reserve;
        uint8 token0Decimals;
        uint8 token1Decimals;
    }

    struct PositionVe {
        uint256 tokenId;
        uint256 balanceOf;
        uint256 locked;
    }

    struct PositionBribesByTokenId {
        uint256 tokenId;
        PositionBribe[] bribes;
    }

    struct PositionBribe {
        address bribeTokenAddress;
        uint256 earned;
    }

    struct PositionPool {
        address id;
        uint256 balanceOf;
    }

    function poolsLength() external view returns (uint256);

    function voterAddress() external view returns (address);

    function veAddress() external view returns (address);

    function poolsFactoryAddress() external view returns (address);

    function gaugesFactoryAddress() external view returns (address);

    function minterAddress() external view returns (address);

    function coneAddress() external view returns (address);

    function vePositionsOf(address) external view returns (PositionVe[] memory);

    function bribeAddresByPoolAddress(address) external view returns (address);

    function gaugeAddressByPoolAddress(address) external view returns (address);

    function poolsPositionsOf(address)
        external
        view
        returns (PositionPool[] memory);

    function poolsPositionsOf(
        address,
        uint256,
        uint256
    ) external view returns (PositionPool[] memory);

    function poolInfo(address) external view returns (Pool memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface ITokensAllowlist {
    function tokenIsAllowed(address) external view returns (bool);

    function bribeTokensSyncPageSize() external view returns (uint256);

    function bribeTokensNotifyPageSize() external view returns (uint256);

    function bribeSyncLagLimit() external view returns (uint256);

    function notifyFrequency()
        external
        view
        returns (uint256 bribeFrequency, uint256 feeFrequency);

    function feeClaimingDisabled(address) external view returns (bool);

    function periodBetweenClaimCone() external view returns (uint256);

    function periodBetweenClaimFee() external view returns (uint256);

    function periodBetweenClaimBribe() external view returns (uint256);

    function tokenIsAllowedInPools(address) external view returns (bool);

    function setTokenIsAllowedInPools(
        address[] memory tokensAddresses,
        bool allowed
    ) external;

    function oogLoopLimit() external view returns (uint256);

    function notifyConeThreshold() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVe {
    function safeTransferFrom(
        address,
        address,
        uint256
    ) external;

    function ownerOf(uint256) external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function balanceOfNFT(uint256) external view returns (uint256);

    function balanceOfNFTAt(uint256, uint256) external view returns (uint256);

    function balanceOfAtNFT(uint256, uint256) external view returns (uint256);

    function locked(uint256) external view returns (uint256);

    function createLock(uint256, uint256) external returns (uint256);

    function approve(address, uint256) external;

    function merge(uint256, uint256) external;

    function token() external view returns (address);

    function controller() external view returns (address);

    function voted(uint256) external view returns (bool);

    function tokenOfOwnerByIndex(address, uint256)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVoter {
    function listingFee() external view returns (uint);

    function isWhitelisted(address) external view returns (bool);

    function poolsLength() external view returns (uint256);

    function pools(uint256) external view returns (address);

    function gauges(address) external view returns (address);

    function bribes(address) external view returns (address);

    function factory() external view returns (address);

    function gaugeFactory() external view returns (address);

    function vote(
        uint256,
        address[] memory,
        int256[] memory
    ) external;

    function whitelist(address, uint256) external;

    function updateFor(address[] memory _gauges) external;

    function claimRewards(address[] memory _gauges, address[][] memory _tokens)
        external;

    function distribute(address _gauge) external;

    function usedWeights(uint256) external returns (uint256);

    function reset(uint256 _tokenId) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVoterProxy {
    function depositInGauge(address, uint256) external;

    function withdrawFromGauge(address, uint256) external;

    function getRewardFromGauge(address _conePool, address[] memory _tokens)
        external;

    function depositNft(uint256) external;

    function veAddress() external returns (address);

    function veDistAddress() external returns (address);

    function lockCone(uint256 amount) external;

    function primaryTokenId() external view returns (uint256);

    function vote(address[] memory, int256[] memory) external;

    function votingSnapshotAddress() external view returns (address);

    function coneInflationSinceInception() external view returns (uint256);

    function getRewardFromBribe(
        address conePoolAddress,
        address[] memory _tokensAddresses
    ) external returns (bool allClaimed, bool[] memory claimed);

    function getFeeTokensFromBribe(address conePoolAddress)
        external
        returns (bool allClaimed);

    function claimCone(address conePoolAddress)
        external
        returns (bool _claimCone);

    function setVoterProxyAssetsAddress(address _voterProxyAssetsAddress)
        external;

    function detachNFT(uint256 startingIndex, uint256 range) external;

    function claim() external;

    function whitelist(address tokenAddress) external;

    function whitelistingFee() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVoterProxyAssets {
    function initializeProxyStorage(
        address _veAddress,
        address _veDistAddress,
        address _voterProxyAddress,
        address _rewardsDistributorAddress
    ) external;

    function depositInGauge(address conePoolAddress, address gaugeAddress)
        external;

    function withdrawFromGauge(
        address conePoolAddress,
        address gaugeAddress,
        uint256 amount
    ) external;

    function veAddress() external returns (address);

    function primaryTokenId() external view returns (uint256);

    function vote(address[] memory, int256[] memory) external;

    function getRewardFromBribe(
        address _stakingAddress,
        address _bribeAddress,
        address[] memory claimableAddresses
    ) external;

    function claimCone(address gaugeAddress)
        external
        returns (uint256 amountClaimed);

    function getRewardFromGauge(
        address stakingAddress,
        address gaugeAddress,
        address[] memory tokensAddresses
    ) external;

    function whitelist(address tokenAddress, uint256 tokenId) external;

    function claim() external returns (uint256 inflationAmount);

    function setPrimaryTokenId() external;

    function depositNft(uint256 tokenId) external;

    function lockCone(uint256 amount) external;

    function approveConeToVoterProxy() external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVeDist {
    function claim(uint256) external returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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