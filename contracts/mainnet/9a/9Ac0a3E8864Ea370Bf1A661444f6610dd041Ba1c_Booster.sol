// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./interfaces/Interfaces.sol";
import "@openzeppelin/contracts-0.6/math/SafeMath.sol";
import "@openzeppelin/contracts-0.6/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-0.6/utils/Address.sol";
import "@openzeppelin/contracts-0.6/token/ERC20/SafeERC20.sol";

/**
 * @title   Booster
 * @author  ConvexFinance -> WombexFinance
 * @notice  Main deposit contract; keeps track of pool info & user deposits; distributes rewards.
 * @dev     They say all paths lead to Rome, and the Booster is no different. This is where it all goes down.
 *          It is responsible for tracking all the pools, it collects rewards from all pools and redirects it.
 */
contract Booster{
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    uint256 public constant MAX_DISTRIBUTION = 2500;
    uint256 public constant MAX_EARMARK_INCENTIVE = 100;
    uint256 public constant MAX_PENALTY_SHARE = 3000;
    uint256 public constant DENOMINATOR = 10000;

    address public immutable crv;
    address public immutable cvx;
    address public immutable weth;
    address public immutable voterProxy;

    address public owner;
    address public feeManager;
    address public poolManager;
    address public rewardFactory;
    address public tokenFactory;
    address public voteDelegate;
    address public crvLockRewards;
    address public cvxLocker;

    IExtraRewardsDistributor public extraRewardsDist;

    uint256 public penaltyShare = 0;
    uint256 public earmarkIncentive;
    bool public earmarkOnDeposit;

    uint256 public minMintRatio;
    uint256 public maxMintRatio;
    uint256 public mintRatio;

    mapping(address => TokenDistro[]) public distributionByTokens;
    struct TokenDistro {
        address distro;
        uint256 share;
        bool callQueue;
    }
    address[] distributionTokens;

    bool public isShutdown;

    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        bool shutdown;
    }

    //index(pid) -> pool
    PoolInfo[] public poolInfo;
    mapping(address => bool) public votingMap;

    mapping(address => address[]) public lpPendingRewardTokens;
    mapping(address => mapping(address => uint256)) public lpPendingRewards;

    event Deposited(address indexed user, uint256 indexed poolid, uint256 amount);
    event Withdrawn(address indexed user, uint256 indexed poolid, uint256 amount);

    event PoolAdded(address indexed lpToken, address gauge, address token, address crvRewards, uint256 pid);
    event PoolShutdown(uint256 indexed poolId);
    event RewardMigrate(address indexed crvRewards, address indexed newBooster, uint256 indexed poolId);

    event OwnerUpdated(address newOwner);
    event FeeManagerUpdated(address newFeeManager);
    event PoolManagerUpdated(address newPoolManager);
    event FactoriesUpdated(address rewardFactory, address tokenFactory);
    event ExtraRewardsDistributorUpdated(address newDist);
    event LpPendingRewardTokensUpdated(address indexed lpToken, address[] pendingRewardTokens);
    event PenaltyShareUpdated(uint256 newPenalty);
    event VoteDelegateUpdated(address newVoteDelegate);
    event VotingMapUpdated(address voting, bool valid);
    event LockRewardContractsUpdated(address lockRewards, address cvxLocker);
    event MintRatioUpdated(uint256 mintRatio);
    event SetEarmarkIncentive(uint256 earmarkIncentive);
    event SetEarmarkOnDeposit(bool earmarkOnDeposit);
    event FeeInfoUpdated(address feeDistro, address lockFees, address feeToken);
    event FeeInfoChanged(address feeToken, bool active);
    event TokenDistributionUpdate(address indexed token, address indexed distro, uint256 share, bool callQueue);
    event DistributionUpdate(address indexed token, uint256 distrosLength, uint256 sharesLength, uint256 callQueueLength, uint256 totalShares);

    event EarmarkRewards(uint256 indexed pid, address indexed lpToken, address indexed rewardToken, uint256 amount);
    event EarmarkRewardsTransfer(uint256 indexed pid, address indexed lpToken, address indexed rewardToken, uint256 amount, address distro, bool queue);
    event RewardClaimed(uint256 indexed pid, address indexed user, uint256 amount, bool indexed lock, uint256 mintAmount, uint256 penalty);

    /**
     * @dev Constructor doing what constructors do. It is noteworthy that
     *      a lot of basic config is set to 0 - expecting subsequent calls to setFeeInfo etc.
     * @param _voterProxy             VoterProxy (locks the crv and adds to all gauges)
     * @param _cvx                    CVX/WMX token
     * @param _crv                    CRV/WOM
     * @param _weth                   WETH
     * @param _minMintRatio           Min mint ratio
     * @param _maxMintRatio           Max mint ratio
     */
    constructor(
        address _voterProxy,
        address _cvx,
        address _crv,
        address _weth,
        uint256 _minMintRatio,
        uint256 _maxMintRatio
    ) public {
        voterProxy = _voterProxy;
        cvx = _cvx;
        crv = _crv;
        weth = _weth;
        isShutdown = false;

        minMintRatio = _minMintRatio;
        maxMintRatio = _maxMintRatio;

        owner = msg.sender;
        voteDelegate = msg.sender;
        feeManager = msg.sender;
        poolManager = msg.sender;

        emit OwnerUpdated(msg.sender);
        emit VoteDelegateUpdated(msg.sender);
        emit FeeManagerUpdated(msg.sender);
        emit PoolManagerUpdated(msg.sender);
    }


    /// SETTER SECTION ///

    /**
     * @notice Owner is responsible for setting initial config, updating vote delegate and shutting system
     */
    function setOwner(address _owner) external {
        require(msg.sender == owner, "!auth");
        owner = _owner;

        emit OwnerUpdated(_owner);
    }

    /**
     * @notice Fee Manager can update the fees (lockIncentive, stakeIncentive, earmarkIncentive, platformFee)
     */
    function setFeeManager(address _feeM) external {
        require(msg.sender == owner, "!auth");
        feeManager = _feeM;

        emit FeeManagerUpdated(_feeM);
    }

    /**
     * @notice Pool manager is responsible for adding new pools
     */
    function setPoolManager(address _poolM) external {
        require(msg.sender == poolManager, "!auth");
        poolManager = _poolM;

        emit PoolManagerUpdated(_poolM);
    }

    /**
     * @notice Factories are used when deploying new pools.
     */
    function setFactories(address _rfactory, address _tfactory) external {
        require(msg.sender == owner, "!auth");
        require(rewardFactory == address(0), "!zero");

        //reward factory only allow this to be called once even if owner
        //removes ability to inject malicious staking contracts
        //token factory can also be immutable
        rewardFactory = _rfactory;
        tokenFactory = _tfactory;

        emit FactoriesUpdated(_rfactory, _tfactory);
    }

    /**
     * @notice Extra rewards distributor handles cvx/wmx penalty
     */
    function setExtraRewardsDistributor(address _dist) external {
        require(msg.sender==owner, "!auth");
        extraRewardsDist = IExtraRewardsDistributor(_dist);

        IERC20(cvx).safeApprove(_dist, 0);
        IERC20(cvx).safeApprove(_dist, type(uint256).max);

        emit ExtraRewardsDistributorUpdated(_dist);
    }

    /**
     * @notice Extra rewards distributor handles cvx/wmx penalty
     */
    function setRewardClaimedPenalty(uint256 _penaltyShare) external {
        require(msg.sender==owner, "!auth");
        require(_penaltyShare <= MAX_PENALTY_SHARE, ">max");
        penaltyShare = _penaltyShare;

        emit PenaltyShareUpdated(_penaltyShare);
    }

    function setRewardTokenPausedInPools(address[] memory _rewardPools, address _token, bool _paused) external {
        require(msg.sender==owner, "!auth");

        for (uint256 i = 0; i < _rewardPools.length; i++) {
            IRewards(_rewardPools[i]).setRewardTokenPaused(_token, _paused);
        }
    }

    /**
     * @notice Vote Delegate has the rights to cast votes on the VoterProxy via the Booster
     */
    function setVoteDelegate(address _voteDelegate) external {
        require(msg.sender==owner, "!auth");
        voteDelegate = _voteDelegate;

        emit VoteDelegateUpdated(_voteDelegate);
    }

    /**
     * @notice Vote Delegate has the rights to cast votes on the VoterProxy via the Booster
     */
    function setVotingValid(address _voting, bool _valid) external {
        require(msg.sender==owner, "!auth");
        votingMap[_voting] = _valid;

        emit VotingMapUpdated(_voting, _valid);
    }

    /**
     * @notice Set tokens to cache pending rewards
     */
    function setLpPendingRewardTokens(address _lpToken, address[] memory _addresses) external {
        require(msg.sender==owner, "!auth");
        lpPendingRewardTokens[_lpToken] = _addresses;

        emit LpPendingRewardTokensUpdated(_lpToken, _addresses);
    }

    /**
     * @notice Set tokens to cache pending rewards
     */
    function updateLpPendingRewardTokensByGauge(uint256 _pid) external {
        require(msg.sender==owner, "!auth");
        PoolInfo storage p = poolInfo[_pid];
        lpPendingRewardTokens[p.lptoken] = IStaker(voterProxy).getGaugeRewardTokens(p.lptoken, p.gauge);

        emit LpPendingRewardTokensUpdated(p.lptoken, lpPendingRewardTokens[p.lptoken]);
    }

    /**
     * @notice Only called once, to set the address of cvxCrv/wmxWOM (lockRewards)
     */
    function setLockRewardContracts(address _crvLockRewards, address _cvxLocker) external {
        require(msg.sender == owner, "!auth");

        //reward contracts are immutable or else the owner
        //has a means to redeploy and mint cvx/wmx via rewardClaimed()
        if (crvLockRewards == address(0)){
            crvLockRewards = _crvLockRewards;
            cvxLocker = _cvxLocker;
            IERC20(cvx).approve(cvxLocker, type(uint256).max);
            emit LockRewardContractsUpdated(_crvLockRewards, _cvxLocker);
        }
    }

    /**
     * @notice Change mint ratio in boundaries
     */
    function setMintRatio(uint256 _mintRatio) external {
        require(msg.sender == owner, "!auth");
        if (_mintRatio != 0) {
            require(_mintRatio >= minMintRatio && _mintRatio <= maxMintRatio, "!boundaries");
        }

        mintRatio = _mintRatio;
        emit MintRatioUpdated(_mintRatio);
    }

    /**
     * @notice Allows turning off or on for fee distro
     */
    function updateDistributionByTokens(address _token, address[] memory _distros, uint256[] memory _shares, bool[] memory _callQueue) external {
        require(msg.sender==owner, "!auth");
        uint256 len = _distros.length;
        require(len > 0, "zero");
        require(len==_shares.length && len==_callQueue.length, "!length");

        if (distributionByTokens[_token].length == 0) {
            distributionTokens.push(_token);
        }

        uint256 curLen = distributionByTokens[_token].length;
        for (uint256 i = 0; i < curLen; i++) {
            address distro = distributionByTokens[_token][distributionByTokens[_token].length - 1].distro;
            IERC20(_token).safeApprove(distro, 0);
            distributionByTokens[_token].pop();
        }

        uint256 totalShares = 0;
        for (uint256 i = 0; i < len; i++) {
            require(_distros[i] != address(0), "!distro");
            totalShares = totalShares.add(_shares[i]);
            distributionByTokens[_token].push(TokenDistro(_distros[i], _shares[i], _callQueue[i]));
            emit TokenDistributionUpdate(_token, _distros[i], _shares[i], _callQueue[i]);

            if (_callQueue[i]) {
                IERC20(_token).safeApprove(_distros[i], 0);
                IERC20(_token).safeApprove(_distros[i], type(uint256).max);
            }
        }
        require(totalShares <= MAX_DISTRIBUTION, ">max");

        uint256 poolLen = poolInfo.length;
        for (uint256 i = 0; i < poolLen; i++) {
            IERC20(_token).safeApprove(poolInfo[i].crvRewards, 0);
            IERC20(_token).safeApprove(poolInfo[i].crvRewards, type(uint256).max);
        }

        emit DistributionUpdate(_token, _distros.length, _shares.length, _callQueue.length, totalShares);
    }

    /**
     * @notice Fee manager can set all the relevant fees
     * @param _earmarkIncentive   % for whoever calls the claim where 1% == 100
     */
    function setEarmarkIncentive(uint256 _earmarkIncentive) external{
        require(msg.sender==feeManager, "!auth");
        require(_earmarkIncentive <= MAX_EARMARK_INCENTIVE, ">max");
        earmarkIncentive = _earmarkIncentive;
        emit SetEarmarkIncentive(_earmarkIncentive);
    }

    /**
     * @notice Fee manager can set earmarkOnDeposit flag
     * @param _earmarkOnDeposit   boolean that defines _earmarkRewards calling on pool deposit or withdraw
     */
    function setEarmarkOnDeposit(bool _earmarkOnDeposit) external{
        require(msg.sender==feeManager, "!auth");
        earmarkOnDeposit = _earmarkOnDeposit;
        emit SetEarmarkOnDeposit(_earmarkOnDeposit);
    }

    /// END SETTER SECTION ///

    /**
     * @notice Called by the PoolManager (i.e. PoolManagerProxy) to add a new pool - creates all the required
     *         contracts (DepositToken, RewardPool) and then adds to the list!
     */
    function addPool(address _lptoken, address _gauge) external returns(bool){
        //the next pool's pid
        uint256 pid = poolInfo.length;

        //create a tokenized deposit
        address token = ITokenFactory(tokenFactory).CreateDepositToken(_lptoken);
        //create a reward contract for crv rewards
        address newRewardPool = IRewardFactory(rewardFactory).CreateCrvRewards(pid,token,_lptoken);

        return addCreatedPool(_lptoken, _gauge, token, newRewardPool);
    }


    /**
     * @notice Called by the PoolManager (i.e. PoolManagerProxy) to add a new pool - creates all the required
     *         contracts (DepositToken, RewardPool) and then adds to the list!
     */
    function addCreatedPool(address _lptoken, address _gauge, address _token, address _crvRewards) public returns(bool){
        require(msg.sender==poolManager && !isShutdown, "!add");
        require(_gauge != address(0) && _lptoken != address(0),"!param");

        //the next pool's pid
        uint256 pid = poolInfo.length;

        if (IRewards(_crvRewards).pid() != pid) {
            IRewards(_crvRewards).updateOperatorData(address(this), pid);
        }

        IERC20(_token).safeApprove(_crvRewards, 0);
        IERC20(_token).safeApprove(_crvRewards, type(uint256).max);

        //add the new pool
        poolInfo.push(
            PoolInfo({
                lptoken: _lptoken,
                token: _token,
                gauge: _gauge,
                crvRewards: _crvRewards,
                shutdown: false
            })
        );

        uint256 distTokensLen = distributionTokens.length;
        for (uint256 i = 0; i < distTokensLen; i++) {
            IERC20(distributionTokens[i]).safeApprove(_crvRewards, 0);
            IERC20(distributionTokens[i]).safeApprove(_crvRewards, type(uint256).max);
        }

        emit PoolAdded(_lptoken, _gauge, _token, _crvRewards, pid);
        return true;
    }

    /**
     * @notice Shuts down the pool by withdrawing everything from the gauge to here (can later be
     *         claimed from depositors by using the withdraw fn) and marking it as shut down
     */
    function shutdownPool(uint256 _pid) external returns(bool){
        require(msg.sender==poolManager, "!auth");
        PoolInfo storage pool = poolInfo[_pid];

        //withdraw from gauge
        IStaker(voterProxy).withdrawAllLp(pool.lptoken,pool.gauge);

        pool.shutdown = true;

        emit PoolShutdown(_pid);
        return true;
    }

    /**
     * @notice Shuts down the pool and sets shutdown flag even if withdrawAllLp failed.
     */
    function forceShutdownPool(uint256 _pid) external returns(bool){
        require(msg.sender==poolManager, "!auth");
        PoolInfo storage pool = poolInfo[_pid];

        //withdraw from gauge
        try IStaker(voterProxy).withdrawAllLp(pool.lptoken, pool.gauge){} catch {}

        pool.shutdown = true;

        emit PoolShutdown(_pid);
        return true;
    }

    /**
     * @notice Shuts down the WHOLE SYSTEM by withdrawing all the LP tokens to here and then allowing
     *         for subsequent withdrawal by any depositors.
     */
    function shutdownSystem() external{
        require(msg.sender == owner, "!auth");
        isShutdown = true;

        for(uint i=0; i < poolInfo.length; i++){
            PoolInfo storage pool = poolInfo[i];
            if (pool.shutdown) continue;

            address token = pool.lptoken;
            address gauge = pool.gauge;

            //withdraw from gauge
            try IStaker(voterProxy).withdrawAllLp(token,gauge){
                pool.shutdown = true;
            }catch{}
        }
    }

    function migrateRewards(address[] calldata _rewards, uint256[] calldata _pids, address _newBooster) external {
        require(msg.sender == owner, "!auth");
        require(isShutdown, "!shutdown");

        uint256 len = _rewards.length;
        require(len == _pids.length, "!length");

        for (uint256 i = 0; i < len; i++) {
            if (_rewards[i] == address(0)) {
                continue;
            }
            IRewards(_rewards[i]).updateOperatorData(_newBooster, _pids[i]);
            if (_rewards[i] != crvLockRewards) {
                address stakingToken = IRewards(_rewards[i]).stakingToken();
                ITokenMinter(stakingToken).updateOperator(_newBooster);
            }
            emit RewardMigrate(_rewards[i], _newBooster, _pids[i]);
        }
    }

    /**
     * @notice  Deposits an "_amount" to a given gauge (specified by _pid), mints a `DepositToken`
     *          and subsequently stakes that on BaseRewardPool
     */
    function deposit(uint256 _pid, uint256 _amount, bool _stake) public returns(bool){
        return depositFor(_pid, _amount, _stake, msg.sender);
    }

    /**
     * @notice  Deposits an "_amount" to a given gauge (specified by _pid), mints a `DepositToken`
     *          and subsequently stakes that on BaseRewardPool
     */
    function depositFor(uint256 _pid, uint256 _amount, bool _stake, address _receiver) public returns(bool){
        require(!isShutdown,"shutdown");
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.shutdown == false, "pool is closed");

        //send to proxy to stake
        address lptoken = pool.lptoken;
        IERC20(lptoken).safeTransferFrom(msg.sender, voterProxy, _amount);

        //stake
        address gauge = pool.gauge;
        require(gauge != address(0),"!gauge setting");

        uint256[] memory rewardBalancesBefore = getPendingRewards(lptoken);
        IStaker(voterProxy).deposit(lptoken, gauge);
        _writePendingRewards(lptoken, rewardBalancesBefore);

        if (earmarkOnDeposit) {
            _earmarkRewards(_pid);
        }

        address token = pool.token;
        if(_stake){
            //mint here and send to rewards on user behalf
            ITokenMinter(token).mint(address(this), _amount);
            IRewards(pool.crvRewards).stakeFor(_receiver, _amount);
        }else{
            //add user balance directly
            ITokenMinter(token).mint(_receiver, _amount);
        }

        emit Deposited(_receiver, _pid, _amount);
        return true;
    }

    /**
     * @notice  Deposits all a senders balance to a given gauge (specified by _pid), mints a `DepositToken`
     *          and subsequently stakes that on BaseRewardPool
     */
    function depositAll(uint256 _pid, bool _stake) external returns(bool){
        address lptoken = poolInfo[_pid].lptoken;
        uint256 balance = IERC20(lptoken).balanceOf(msg.sender);
        deposit(_pid,balance,_stake);
        return true;
    }

    /**
     * @notice  Withdraws LP tokens from a given PID (& user).
     *          1. Burn the cvxLP/wmxLP balance from "_from" (implicit balance check)
     *          2. If pool !shutdown.. withdraw from gauge
     *          3. Transfer out the LP tokens
     */
    function _withdraw(uint256 _pid, uint256 _amount, address _from, address _to) internal {
        PoolInfo storage pool = poolInfo[_pid];
        address lptoken = pool.lptoken;
        address gauge = pool.gauge;

        //remove lp balance
        address token = pool.token;
        ITokenMinter(token).burn(_from,_amount);

        //pull from gauge if not shutdown
        // if shutdown tokens will be in this contract
        if (!pool.shutdown) {
            uint256[] memory rewardBalancesBefore = getPendingRewards(lptoken);
            IStaker(voterProxy).withdrawLp(lptoken, gauge, _amount);
            _writePendingRewards(lptoken, rewardBalancesBefore);

            if (earmarkOnDeposit) {
                _earmarkRewards(_pid);
            }
        }

        //return lp tokens
        IERC20(lptoken).safeTransfer(_to, _amount);

        emit Withdrawn(_to, _pid, _amount);
    }

    /**
     * @notice  Withdraw a given amount from a pool (must already been unstaked from the Reward Pool -
     *          BaseRewardPool uses withdrawAndUnwrap to get around this)
     */
    function withdraw(uint256 _pid, uint256 _amount) public returns(bool){
        _withdraw(_pid,_amount,msg.sender,msg.sender);
        return true;
    }

    /**
     * @notice  Withdraw all the senders LP tokens from a given gauge
     */
    function withdrawAll(uint256 _pid) public returns(bool){
        address token = poolInfo[_pid].token;
        uint256 userBal = IERC20(token).balanceOf(msg.sender);
        withdraw(_pid, userBal);
        return true;
    }

    /**
     * @notice Allows the actual BaseRewardPool to withdraw and send directly to the user
     */
    function withdrawTo(uint256 _pid, uint256 _amount, address _to) external returns(bool){
        address rewardContract = poolInfo[_pid].crvRewards;
        require(msg.sender == rewardContract,"!auth");

        _withdraw(_pid,_amount,msg.sender,_to);
        return true;
    }

    function getPendingRewardTokens(address _lptoken) public view returns (address[] memory tokens) {
        if (lpPendingRewardTokens[_lptoken].length > 0) {
            return lpPendingRewardTokens[_lptoken];
        } else {
            tokens = new address[](1);
            tokens[0] = crv;
        }
    }

    function getPendingRewards(address _lptoken) public view returns (uint256[] memory result) {
        address[] memory tokens = getPendingRewardTokens(_lptoken);
        uint256 len = tokens.length;
        result = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            uint256 balance = IERC20(tokens[i]).balanceOf(voterProxy);
            if (tokens[i] == weth) {
                balance = balance.add(voterProxy.balance);
            }
            result[i] = balance;
        }
    }

    function _writePendingRewards(address _lptoken, uint256[] memory _rewardsBefore) internal {
        address[] memory tokens = getPendingRewardTokens(_lptoken);
        uint256 len = _rewardsBefore.length;
        for (uint256 i = 0; i < len; i++) {
            address token = tokens[i];
            uint256 balance = IERC20(token).balanceOf(voterProxy);
            if (token == weth) {
                balance = balance.add(voterProxy.balance);
            }
            lpPendingRewards[_lptoken][token] = lpPendingRewards[_lptoken][token].add(balance.sub(_rewardsBefore[i]));
        }
    }

    /**
     * @notice set valid vote hash on VoterProxy
     */
    function setVote(bytes32 _hash, bool valid) external returns(bool){
        require(msg.sender == voteDelegate, "!auth");

        IStaker(voterProxy).setVote(_hash, valid);
        return true;
    }

    /**
     * @notice Delegate address votes on gauge weight via VoterProxy
     */
    function voteExecute(address _voting, uint256 _value, bytes calldata _data) external payable returns(bool) {
        require(msg.sender == voteDelegate, "!auth");
        require(votingMap[_voting], "!voting");

        IStaker(voterProxy).execute{value:_value}(_voting, _value, _data);
        return true;
    }

    /**
     * @notice Basically a hugely pivotal function.
     *         Responsible for collecting the crv/wom from gauge, and then redistributing to the correct place.
     *         Pays the caller a fee to process this.
     */
    function _earmarkRewards(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.shutdown == false, "pool is closed");

        //claim crv/wom and bonus tokens
        address[] memory tokens = IStaker(voterProxy).getGaugeRewardTokens(pool.lptoken, pool.gauge);
        uint256 tLen = tokens.length;
        uint256[] memory totalPendingRewards = new uint256[](tLen);
        for (uint256 i = 0; i < poolInfo.length; i++) {
            if (poolInfo[i].shutdown) {
                continue;
            }
            for (uint256 j = 0; j < tLen; j++) {
                totalPendingRewards[j] = totalPendingRewards[j].add(lpPendingRewards[poolInfo[i].lptoken][tokens[j]]);
            }
        }

        IStaker(voterProxy).claimCrv(pool.lptoken, pool.gauge);

        for (uint256 i = 0; i < tLen; i++) {
            IERC20 token = IERC20(tokens[i]);
            uint256 balance = token.balanceOf(address(this)).sub(totalPendingRewards[i]);
            if (lpPendingRewards[pool.lptoken][tokens[i]] > 0) {
                balance = balance.add(lpPendingRewards[pool.lptoken][tokens[i]]);
                lpPendingRewards[pool.lptoken][tokens[i]] = 0;
            }

            emit EarmarkRewards(_pid, pool.lptoken, address(token), balance);

            if (balance == 0) {
                continue;
            }
            uint256 dLen = distributionByTokens[address(token)].length;
            require(dLen > 0, "!dLen");

            uint256 earmarkIncentiveAmount = balance.mul(earmarkIncentive).div(DENOMINATOR);
            uint256 sentSum = earmarkIncentiveAmount;

            for (uint256 j = 0; j < dLen; j++) {
                TokenDistro memory tDistro = distributionByTokens[address(token)][j];
                if (tDistro.share == 0) {
                   continue;
                }
                uint256 amount = balance.mul(tDistro.share).div(DENOMINATOR);
                if (tDistro.callQueue) {
                    IRewards(tDistro.distro).queueNewRewards(address(token), amount);
                } else {
                    token.safeTransfer(tDistro.distro, amount);
                }
                emit EarmarkRewardsTransfer(_pid, pool.lptoken, address(token), amount, tDistro.distro, tDistro.callQueue);
                sentSum = sentSum.add(amount);
            }
            if (earmarkIncentiveAmount > 0) {
                token.safeTransfer(msg.sender, earmarkIncentiveAmount);
                emit EarmarkRewardsTransfer(_pid, pool.lptoken, address(token), earmarkIncentiveAmount, msg.sender, false);
            }
            //send crv to lp provider reward contract
            IRewards(pool.crvRewards).queueNewRewards(address(token), balance.sub(sentSum));
            emit EarmarkRewardsTransfer(_pid, pool.lptoken, address(token), balance.sub(sentSum), pool.crvRewards, true);
        }
    }

    /**
     * @notice Basically a hugely pivotal function.
     *         Responsible for collecting the crv/wom from gauge, and then redistributing to the correct place.
     *         Pays the caller a fee to process this.
     */
    function earmarkRewards(uint256 _pid) external returns(bool){
        require(!isShutdown,"shutdown");
        _earmarkRewards(_pid);
        return true;
    }

    /**
     * @notice Callback from reward contract when crv/wom is received.
     * @dev    Goes off and mints a relative amount of CVX/WMX based on the distribution schedule.
     */
    function rewardClaimed(uint256 _pid, address _address, uint256 _amount, bool _lock) external returns(bool){
        address rewardContract = poolInfo[_pid].crvRewards;
        require(msg.sender == rewardContract || msg.sender == crvLockRewards, "!auth");

        uint256 mintAmount = _amount;
        if (mintRatio > 0) {
            mintAmount = mintAmount.mul(mintRatio).div(DENOMINATOR);
        }

        uint256 penalty;
        if (_lock) {
            uint256 balanceBefore = IERC20(cvx).balanceOf(address(this));
            ITokenMinter(cvx).mint(address(this), mintAmount);
            ICvxLocker(cvxLocker).lock(_address, IERC20(cvx).balanceOf(address(this)).sub(balanceBefore));
        } else {
            penalty = mintAmount.mul(penaltyShare).div(DENOMINATOR);
            mintAmount = mintAmount.sub(penalty);
            //mint reward to user, except the penalty
            ITokenMinter(cvx).mint(_address, mintAmount);
            if (penalty > 0) {
                uint256 balanceBefore = IERC20(cvx).balanceOf(address(this));
                ITokenMinter(cvx).mint(address(this), penalty);
                extraRewardsDist.addReward(cvx, IERC20(cvx).balanceOf(address(this)).sub(balanceBefore));
            }
        }
        emit RewardClaimed(_pid, _address, _amount, _lock, mintAmount, penalty);
        return true;
    }


    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function distributionByTokenLength(address _token) external view returns (uint256) {
        return distributionByTokens[_token].length;
    }

    function distributionTokenList() external view returns (address[] memory) {
        return distributionTokens;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IMasterWombat {
    function deposit(uint256 _pid, uint256 _amount) external;
    function balanceOf(address) external view returns(uint256);
    function userInfo(uint256, address) external view returns (uint256 amount, uint256 rewardDebt, uint256 factor);
    function withdraw(uint256 _pid, uint256 _amount) external;
    function poolLength() external view returns(uint256);
    function poolInfo(uint256 _pid) external view returns (address lpToken, uint96 allocPoint, IMasterWombatRewarder rewarder, uint256 sumOfFactors, uint104 accWomPerShare, uint104 accWomPerFactorShare, uint40 lastRewardTimestamp);
}

interface IMasterWombatRewarder {
    function rewardTokens() external view returns (address[] memory tokens);
}

interface IVeWom {
    function mint(uint256 amount, uint256 lockDays) external returns (uint256 veWomAmount);
    function burn(uint256 slot) external;
    function vote(uint256, bool, bool) external; //voteId, support, executeIfDecided
}

interface IVoting{
    function vote(uint256, bool, bool) external; //voteId, support, executeIfDecided
    function getVote(uint256) external view returns(bool,bool,uint64,uint64,uint64,uint64,uint256,uint256,uint256,bytes memory);
    function vote_for_gauge_weights(address,uint256) external;
}

interface IMinter{
    function mint(address) external;
    function updateOperator() external;
    function operator() external returns(address);
}

interface ICvxLocker {
    function lock(address _account, uint256 _amount) external;
}

interface IStaker{
    function deposit(address, address) external returns (bool);
    function withdraw(address) external returns (uint256);
    function withdrawLp(address, address, uint256) external returns (bool);
    function withdrawAllLp(address, address) external returns (bool);
    function lock(uint256 _lockDays) external;
    function releaseLock(uint256 _slot) external returns(bool);
    function getGaugeRewardTokens(address _lptoken, address _gauge) external returns (address[] memory tokens);
    function claimCrv(address, address) external returns (address[] memory tokens);
    function balanceOfPool(address, address) external view returns (uint256);
    function operator() external view returns (address);
    function execute(address _to, uint256 _value, bytes calldata _data) external payable returns (bool, bytes memory);
    function setVote(bytes32 hash, bool valid) external;
    function setOperator(address _operator) external;
    function setOwner(address _owner) external;
    function setDepositor(address _depositor) external;
}

interface IRewards{
    function pid() external view returns(uint256);
    function stake(address, uint256) external;
    function stakeFor(address, uint256) external;
    function withdraw(address, uint256) external;
    function exit(address) external;
    function getReward(address) external;
    function queueNewRewards(address, uint256) external;
    function notifyRewardAmount(uint256) external;
    function setRewardTokenPaused(address, bool) external;
    function updateOperatorData(address, uint256) external;
    function addExtraReward(address) external;
    function extraRewardsLength() external view returns (uint256);
    function stakingToken() external view returns (address);
    function rewardToken() external view returns(address);
    function earned(address account) external view returns (uint256);
}

interface ITokenMinter{
    function mint(address,uint256) external;
    function burn(address,uint256) external;
    function updateOperator(address) external;
}

interface IDeposit{
    function isShutdown() external view returns(bool);
    function balanceOf(address _account) external view returns(uint256);
    function totalSupply() external view returns(uint256);
    function poolInfo(uint256) external view returns(address,address,address,address,address, bool);
    function rewardClaimed(uint256,address,uint256,bool) external;
    function withdrawTo(uint256,uint256,address) external;
    function claimRewards(uint256,address) external returns(bool);
    function rewardArbitrator() external returns(address);
    function setGaugeRedirect(uint256 _pid) external returns(bool);
    function owner() external returns(address);
    function deposit(uint256 _pid, uint256 _amount, bool _stake) external returns(bool);
}

interface ICrvDeposit{
    function deposit(uint256, bool) external;
    function lockIncentive() external view returns(uint256);
}

interface IRewardFactory{
    function setAccess(address,bool) external;
    function CreateCrvRewards(uint256,address,address) external returns(address);
    function CreateTokenRewards(address,address,address) external returns(address);
    function activeRewardCount(address) external view returns(uint256);
    function addActiveReward(address,uint256) external returns(bool);
    function removeActiveReward(address,uint256) external returns(bool);
}

interface IStashFactory{
    function CreateStash(uint256,address,address,uint256) external returns(address);
}

interface ITokenFactory{
    function CreateDepositToken(address) external returns(address);
}

interface IPools{
    function addPool(address _lptoken, address _gauge, uint256 _stashVersion) external returns(bool);
    function forceAddPool(address _lptoken, address _gauge, uint256 _stashVersion) external returns(bool);
    function shutdownPool(uint256 _pid) external returns(bool);
    function poolInfo(uint256) external view returns(address,address,address,address,address,bool);
    function poolLength() external view returns (uint256);
    function gaugeMap(address) external view returns(bool);
    function setPoolManager(address _poolM) external;
}

interface IVestedEscrow{
    function fund(address[] calldata _recipient, uint256[] calldata _amount) external returns(bool);
}

interface IRewardDeposit {
    function addReward(address, uint256) external;
}

interface IWETH {
    function deposit() external payable;
}

interface IExtraRewardsDistributor {
    function addReward(address _token, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity >=0.6.2 <0.8.0;

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}