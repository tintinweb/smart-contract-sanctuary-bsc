// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/ICrossFarmTypes.sol";
import "./interfaces/ICrossFarm.sol";

import "../session/SessionManager.sol";
import "../session/Node.sol";
import "../libraries/WireLibrary.sol";
import "../periphery/interfaces/IMaker.sol";
import "../periphery/interfaces/ITaker.sol";
import "./interfaces/ICrssToken.sol";
import "./interfaces/IXCrssToken.sol";
import "./interfaces/ICrssReferral.sol";
import "./BaseRelayRecipient.sol";
import "../libraries/math/SafeMath.sol";
import "../libraries/FarmLibrary.sol";

import "../libraries/utils/TransferHelper.sol";
import "../libraries/CrossLibrary.sol";

contract CrossFarm is Node, ICrossFarm, BaseRelayRecipient, SessionManager {
    // Do not inherit from Ownable and Context, as they conflicts with BaseRelayRecipient at _mseSender().
    // Instead, implement them here, except _msgSender(). Context plays a role for that.

    //--------------------- Context, except _msgSender -----------------------
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    //--------------------- Ownerble -----------------------------------------

    address private _owner;

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    //=========================================================
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //=========================================================

    uint256 constant vestMonths = 5;
    uint256 constant depositFeeLimit = 5000; // 5.0%

    address crss;
    FarmParams public farmParams;
    uint256 public startBlock;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(address => uint256) public accumulated;

    uint256 public lastPatrolRound;
    uint256 public patrolCycle;

    FarmFeeParams feeParams;

    IMigratorChef public migrator;

    address public backendCaller;

    string private sForbidden;
    string private sZeroAddress;
    string private sInvalidPoolId;
    string private sExceedsBalance;
    string private sInvalidFee;
    string private sInconsistent;

    // modifier onlyOwner() {
    //     require(_msgSender() == owner(), "Caller must be owner");
    //     _;
    // }

    function getOwner() public view virtual override returns (address) {
        return owner();
    }

    modifier validPid(uint256 _pid) {
        require(_pid < poolInfo.length, sInvalidPoolId);
        _;
    }

    receive() external payable {}

    constructor(
        address _crss,
        uint256 _crssPerBlock,
        uint256 _startBlock
    ) Node(NodeType.Farm) {
        _transferOwnership(_msgSender());
        // This is the contrutor part of Ownable. Read the comments at the contract declaration.

        crss = _crss;
        farmParams.crssPerBlock = _crssPerBlock;
        farmParams.bonusMultiplier = 1;

        require(block.number < _startBlock, sForbidden);
        startBlock = _startBlock;

        trackFeeStores = true;
        trackFeeRates = true;
        trackPairStatus = true;

        patrolCycle = 3600;

        // temporary
        feeParams.crssReferral = address(0);
        feeParams.referralCommissionRate = 100; // 0.1%
        feeParams.nonVestBurnRate = 25000; // 25.0%
        feeParams.compoundFeeRate = 5000; // 5%
        feeParams.stakeholders = 0x23C6D84c09523032B08F9124A349760721aF64f6;

        sForbidden = "Forbidden";
        sZeroAddress = "Zero address";
        sInvalidPoolId = "Invalid pool id";
        sExceedsBalance = "Exceeds balance";
        sInvalidFee = "Invalid fee";
        sInconsistent = "Inconsistent";
    }

    function setCrssPerBlock(uint256 _crssPerBlock) public onlyOwner {
        require(_crssPerBlock <= 10**18, "Invalid Crss Per Block");
        massUpdatePools();
        farmParams.crssPerBlock = _crssPerBlock;
    }

    function setNode(
        NodeType nodeType,
        address node,
        address caller
    ) public virtual override wired {
        if (caller != address(this)) {
            // let caller be address(0) when an actor initiats this loop.
            WireLibrary.setNode(nodeType, node, nodes);
            if (nodeType == NodeType.Token) {
                require(crss == address(0) || crss == node, sInconsistent);
                sessionRegistrar = ISessionRegistrar(node);
                sessionFees = ISessionFees(node);
            }
            address trueCaller = caller == address(0) ? address(this) : caller;
            INode(nextNode).setNode(nodeType, node, trueCaller);
        } else {
            emit SetNode(nodeType, node);
        }
    }

    function begin(address caller) public virtual override wired {
        if (caller != address(this)) {
            // let caller be address(0) when an actor initiats this loop.
            farmParams.totalAllocPoint = add(15, crss, true, 0, 0);
            INode(nextNode).begin(caller == address(0) ? address(this) : caller);
        } else {
            emit Begin();
        }
    }

    function changePatrolCycle(uint256 newCycle) public virtual onlyOwner {
        patrolCycle = newCycle;
    }

    function _revertOnZeroAddress(address addr) internal view {
        require(addr != address(0), sZeroAddress);
    }

    //==================== Fee Rates and Accounts ====================

    function setFeeParams(
        address _stakeholders,
        address _crssReferral,
        uint256 _referralCommissionRate,
        uint256 _nonVestBurnRate,
        uint256 _compoundFeeRate
    ) external onlyOwner {
        feeParams.stakeholders = _stakeholders;
        feeParams.crssReferral = _crssReferral;
        feeParams.referralCommissionRate = _referralCommissionRate;
        feeParams.nonVestBurnRate = _nonVestBurnRate;
        feeParams.compoundFeeRate = _compoundFeeRate;

        emit SetFeeParamsReferral(_crssReferral, _referralCommissionRate);
        emit SetFeeParamsOthers(_stakeholders, _nonVestBurnRate, _compoundFeeRate);
    }

    function setBackendCaller(address _backendCaller) external onlyOwner {
        backendCaller = _backendCaller;
    }

    ///==================== Farming ====================

    function updateMultiplier(uint256 multiplierNumber) public override onlyOwner {
        farmParams.bonusMultiplier = multiplierNumber;
    }

    function poolLength() external view override returns (uint256) {
        return poolInfo.length;
    }

    /**
     * @dev Add a farming pool.
     */
    function add(
        uint256 _allocPoint,
        address _lpToken,
        bool _withUpdate,
        uint256 _depositFeeRate,
        uint256 _withdrawLock // Shoule be in sec format
    ) public override wired returns (uint256 totalAllocPoint) {
        require(_lpToken != address(0), sForbidden);
        IERC20 lpToken = IERC20(_lpToken);
        // for (uint256 i = 0; i < poolInfo.length; i++) {
        //     // takes little gas.
        //     require(poolInfo[i].lpToken != lpToken, "Used LP");
        // }
        require(pairs[_lpToken].status == ListStatus.Enlisted, sForbidden);
        require(_depositFeeRate <= depositFeeLimit, sInvalidFee);
        if (_withUpdate) massUpdatePools();
        totalAllocPoint = FarmLibrary.addPool(
            _allocPoint,
            _lpToken,
            _depositFeeRate,
            _withdrawLock,
            startBlock,
            poolInfo
        );
        farmParams.totalAllocPoint = totalAllocPoint;
    }

    /**
     * @dev Reset a farming pool, with new alloccation points and deposit fee rate.
     */
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate,
        uint256 _depositFeeRate,
        uint256 _withdrawLock // Shoule be in sec format
    ) public override onlyOwner returns (uint256 totalAllocPoint) {
        require(_pid != 0, sInvalidPoolId);
        require(_depositFeeRate <= depositFeeLimit, sInvalidFee);
        if (_withUpdate) massUpdatePools();
        totalAllocPoint = FarmLibrary.setPool(poolInfo, _pid, _allocPoint, _depositFeeRate, _withdrawLock);
        farmParams.totalAllocPoint = totalAllocPoint;
    }

    // // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    // function migrate(uint256 _pid) public onlyOwner {
    //     PoolInfo storage pool = poolInfo[_pid];
    //     FarmLibrary.migrate(pool, migrator);
    // }

    function getMultiplier(uint256 _from, uint256 _to) public view override returns (uint256) {
        return (_to - _from) * farmParams.bonusMultiplier;
    }

    /**
     * @dev update all existing pools.
     * Average 30,000 gas is used to update a pool.
     * The 90 million gas, which is the current block gas limit of the BSC chain, can update 200 pools.
     */

    function massUpdatePools() public override {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            FarmLibrary.updatePool(pool, farmParams, nodes, feeStores);
        }
    }

    /**
     * @dev Update pool from outside.
     * Control its session.
     */
    function updatePool(uint256 _pid) public override validPid(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        FarmLibrary.updatePool(pool, farmParams, nodes, feeStores);
    }

    /**
     * @dev Change the referral ledger contract.
     */
    function changeReferrer(address user, address referrer) public override {
        require(_msgSender() == backendCaller, sForbidden);
        require(referrer != user, sForbidden);
        ICrssReferral(feeParams.crssReferral).recordReferral(user, referrer);
        emit ChangeReferer(user, referrer);
    }

    function getOutstandingCommission(address referrer) external view returns (uint256 amount) {
        return ICrssReferral(feeParams.crssReferral).getOutstandingCommission(referrer);
    }

    function withdrawOutstandingCommission(uint256 amount) external {
        FarmLibrary.withdrawOutstandingCommission(_msgSender(), amount, feeParams, nodes);
    }

    /**
     * @dev update all existing pools.
     * Average 400,000 gas is used to patrol a pool.
     * As the BSC chain's block gas limit is 90 million gas, we can expect 200 pools can be patrolled in a call.
     */

    function periodicPatrol() public virtual override returns (bool done) {
        require(_msgSender() == backendCaller, sForbidden);
        uint256 newLastPatrolRound = FarmLibrary.periodicPatrol(
            poolInfo,
            farmParams,
            feeParams,
            nodes,
            lastPatrolRound,
            patrolCycle,
            feeStores
        );
        if (newLastPatrolRound != 0) {
            lastPatrolRound = newLastPatrolRound;
            done = true;
        }
    }

    function getUserState(uint256 pid, address userAddress) external view validPid(pid) returns (UserState memory) {
        return FarmLibrary.getUserState(userAddress, pid, poolInfo, userInfo, nodes, farmParams, vestMonths);
    }

    function getVestList(uint256 pid, address userAddress) external view validPid(pid) returns (VestChunk[] memory) {
        return userInfo[pid][userAddress].vestList;
    }

    function getSubPooledCrss(uint256 pid, address userAddress)
        external
        view
        validPid(pid)
        returns (SubPooledCrss memory)
    {
        return FarmLibrary.getSubPooledCrss(poolInfo[pid], userInfo[pid][userAddress]);
    }

    // ============================== Session (Transaction) Area ==============================
    /**
     * @dev Deposit LP tokens to gain reward emission.
     */
    function deposit(
        uint256 _pid,
        uint256 _amount,
        UserRewardBehavior memory behavior
    ) public override validPid(_pid) returns (uint256 deposited) {
        _openAction(ActionType.Deposit, true);

        address msgSender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msgSender];

        _checkEnlisted(address(pool.lpToken));

        behavior.crssBusd = crssBusd;
        FarmLibrary.finishRewardCycle2(pool, user, behavior, msgSender, feeParams, nodes, farmParams, feeStores);

        if (_amount > pool.lpToken.balanceOf(msgSender)) _amount = pool.lpToken.balanceOf(msgSender);
        if (_amount > 0) {
            _amount = FarmLibrary.pullFromUser(address(pool.lpToken), msgSender, _amount, nodes.token);
            _amount -= _payTransactonFee(address(pool.lpToken), address(this), _amount, false);
            _amount -= FarmLibrary.payDepositFeeLPFromFarm(pool, _amount, feeStores);
            deposited = _amount;
            FarmLibrary.startRewardCycle(pool, user, msgSender, nodes, feeParams, deposited, true); // false: addNotSubract
            emit Deposit(_msgSender(), _pid, deposited);
        }

        _closeAction();
    }

    /**
     * @dev Withdraw LP tokens deposited in the past.
     */
    function withdraw(
        uint256 _pid,
        uint256 _amount,
        UserRewardBehavior memory behavior
    ) public override validPid(_pid) returns (uint256 withdrawn) {
        _openAction(ActionType.Withdraw, true);

        address msgSender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msgSender];

        behavior.crssBusd = crssBusd;
        FarmLibrary.finishRewardCycle2(pool, user, behavior, msgSender, feeParams, nodes, farmParams, feeStores);
        if (user.amount < _amount) _amount = user.amount;

        if (_amount > 0) {
            withdrawn = _amount;
            _amount -= _payTransactonFee(address(pool.lpToken), address(this), _amount, false);
            FarmLibrary.pushToUser(address(pool.lpToken), msgSender, _amount, nodes.token); // withdraw.
            FarmLibrary.startRewardCycle(pool, user, msgSender, nodes, feeParams, withdrawn, false); // false: addNotSubract
            emit Withdraw(msgSender, _pid, withdrawn);
        }

        _closeAction();
    }

    // /**
    // * @dev Withdraw a given amount of unlocked Crss amount form the user's vesting process.
    // */

    // function withdrawVest(uint256 _pid, uint256 _amount, UserRewardBehavior memory behavior)
    //  public override validPid(_pid)  returns (uint256 withdrawn) {
    //     _openAction(ActionType.WithdrawVest, true);

    //     address msgSender = _msgSender();
    //     PoolInfo storage pool = poolInfo[_pid];
    //     UserInfo storage user = userInfo[_pid][msgSender];
    //     behavior.crssBusd = crssBusd;
    //     FarmLibrary.finishRewardCycle2(pool, user, bahavior, msgSender, feeParams, nodes, farmParams);
    //
    //     if (_amount > 0) {
    //         _amount -= FarmLibrary.withdrawVestPieces(user.vestList, vestMonths, _amount);
    //         withdrawn = _amount;
    //         _amount -= _payTransactonFee(nodes.token, nodes.xToken, _amount, false);
    //         ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, msgSender, _amount);
    //         emit WithdrawVest(msgSender, _pid, withdrawn);
    //     }

    //     _closeAction();
    // }

    /**
     * @dev Withdraw a user's deposit in a given pool, without operning session, for emergency use.
     */

    // function vestAccumulated(uint256 _pid, UserRewardBehavior memory behavior)
    //     public
    //     virtual
    //     override
    //     validPid(_pid)
    //     returns (uint256 vested)
    // {
    //     _openAction(ActionType.VestAccumulated, true);

    //     address msgSender = _msgSender();
    //     PoolInfo storage pool = poolInfo[_pid];
    //     UserInfo storage user = userInfo[_pid][msgSender];

    //     _checkEnlisted(address(pool.lpToken));

    //     behavior.crssBusd = crssBusd;
    //     FarmLibrary.finishRewardCycle2(pool, user, behavior, msgSender, feeParams, nodes, farmParams, feeStores);

    //     uint256 amount = user.accumulated;
    //     if (amount > 0) {
    //         amount -= _payTransactonFee(nodes.token, nodes.xToken, amount, false);
    //         user.vestList.push(VestChunk({principal: amount, withdrawn: 0, startTime: block.timestamp}));
    //         vested = amount;
    //         user.accumulated = 0;
    //         emit VestAccumulated(msgSender, _pid, vested);
    //     }

    //     _closeAction();
    // }

    // function compoundAccumulated(uint256 _pid, UserRewardBehavior memory behavior)
    //  public override virtual validPid(_pid) returns (uint256 compounded) {
    //     _openAction(ActionType.CompoundAccumulated);

    //     address msgSender = _msgSender();
    //     PoolInfo storage pool = poolInfo[_pid];
    //     UserInfo storage user = userInfo[_pid][msgSender];
    //     behavior.crssBusd = crssBusd;
    //     FarmLibrary.finishRewardCycle2(pool, user, behavior, msgSender, feeParams, nodes, farmParams);

    //     uint256 amount = user.accumulated;

    //     uint256 newLpAmount;
    //     if (amount > 0) {
    //         amount -= _payTransactonFee(nodes.token, nodes.xToken, amount, false);
    //         amount -= FarmLibrary.payCompoundFee(nodes.token, feeParams, amount, nodes);
    //         compounded = amount;
    //         newLpAmount = FarmLibrary.changeCrssInXTokenToLpInFarm(address(pool.lpToken), nodes, amount, feeParams.stakeholders);
    //         FarmLibrary.startRewardCycle(pool, user, msgSender, newLpAmount, true);  // true: addNotSubract
    //         user.accumulated = 0;
    //         emit CompoundAccumulated(msgSender, _pid, compounded, newLpAmount);
    //     }
    //     _closeAction();
    // }

    function harvestAccumulated(uint256 _pid, UserRewardBehavior memory behavior)
        public
        virtual
        override
        validPid(_pid)
        returns (uint256 harvested)
    {
        _openAction(ActionType.HarvestAccumulated, true);

        address msgSender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msgSender];

        behavior.crssBusd = crssBusd;
        FarmLibrary.finishRewardCycle2(pool, user, behavior, msgSender, feeParams, nodes, farmParams, feeStores);

        uint256 amount = type(uint256).max;
        amount -= FarmLibrary.withdrawVestPieces(user.vestList, vestMonths, amount);
        amount += user.accumulated;

        if (amount > 0) {
            amount -= _payTransactonFee(nodes.token, nodes.xToken, amount, false);
            harvested = amount;
            ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, msgSender, amount);
            user.accumulated = 0;
            emit HarvestAccumulated(msgSender, _pid, amount);
        }

        _closeAction();
    }

    function stakeAccumulated(uint256 _pid, UserRewardBehavior memory behavior)
        public
        virtual
        override
        validPid(_pid)
        returns (uint256 staked)
    {
        _openAction(ActionType.StakeAccumulated, true);

        address msgSender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msgSender];

        _checkEnlisted(address(pool.lpToken));

        behavior.crssBusd = crssBusd;
        FarmLibrary.finishRewardCycle2(pool, user, behavior, msgSender, feeParams, nodes, farmParams, feeStores);

        uint256 amount = type(uint256).max;
        amount -= FarmLibrary.withdrawVestPieces(user.vestList, vestMonths, amount);
        amount += user.accumulated;

        if (amount > 0) {
            amount -= _payTransactonFee(nodes.token, nodes.xToken, amount, false);
            pool = poolInfo[0];
            user = userInfo[0][msgSender];
            FarmLibrary.finishRewardCycle(pool, user, msgSender, feeParams, nodes, farmParams, feeStores);
            uint256 balance0 = IERC20(nodes.token).balanceOf(address(this));
            ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, address(this), amount);
            amount = IERC20(nodes.token).balanceOf(address(this)) - balance0;
            amount -= FarmLibrary.payDepositFeeLPFromFarm(pool, amount, feeStores);
            staked = amount;
            FarmLibrary.startRewardCycle(pool, user, msgSender, nodes, feeParams, staked, true); // false: addNotSubract
            user.accumulated = 0;
            emit StakeAccumulated(msgSender, _pid, amount);
        }

        _closeAction();
    }

    function emergencyWithdraw(uint256 _pid, UserRewardBehavior memory behavior) public override validPid(_pid) {
        _openAction(ActionType.EmergencyWithdraw, true);

        address msgSender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msgSender];

        behavior.crssBusd = crssBusd;
        FarmLibrary.finishRewardCycle2(pool, user, behavior, msgSender, feeParams, nodes, farmParams, feeStores);
        uint256 amount = user.amount;

        if (amount > 0) {
            uint256 withdrawn = amount;
            CrossLibrary.lightTransferFrom(address(pool.lpToken), address(this), msgSender, amount, nodes.token);
            FarmLibrary.startRewardCycle(pool, user, msgSender, nodes, feeParams, withdrawn, false); // false: addNotSubract
            emit EmergencyWithdraw(msgSender, _pid, withdrawn);
        }

        _closeAction();
    }

    /**
     * @dev Change users' auto option.
     */
    function switchCollectOption(
        uint256 _pid,
        CollectOption newOption,
        UserRewardBehavior memory behavior
    ) public override validPid(_pid) {
        _openAction(ActionType.SwitchCollectOption, true);

        address msgSender = _msgSender();
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msgSender];

        behavior.crssBusd = crssBusd;
        if (
            FarmLibrary.switchCollectOption(
                pool,
                user,
                behavior,
                newOption,
                msgSender,
                feeParams,
                nodes,
                farmParams,
                feeStores
            )
        ) {
            emit SwitchCollectOption(msgSender, _pid, newOption);
        }

        _closeAction();
    }

    /**
     * @dev Take all accumulated Crss rewards, across the given list of pool, of the calling user to their wallet.
     */
    function massHarvestRewards() public virtual override returns (uint256 rewards) {
        _openAction(ActionType.MassHarvestRewards, true);

        address msgSender = _msgSender();
        uint256 amount = FarmLibrary.collectAccumulated(
            msgSender,
            poolInfo,
            userInfo,
            feeParams,
            nodes,
            farmParams,
            feeStores
        );

        if (amount > 0) {
            rewards = amount;
            amount -= _payTransactonFee(nodes.token, nodes.xToken, amount, false);
            ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, msgSender, amount);
            emit MassHarvestRewards(msgSender, rewards);
        }

        _closeAction();
    }

    /**
     * @dev Stake all accumulated Crss rewards, accross the given list of pools, of the calling user to the first Crss staking pool.
     */
    function massStakeRewards() external virtual override returns (uint256 rewards) {
        _openAction(ActionType.MassStakeRewards, true);

        address msgSender = _msgSender();
        uint256 amount = FarmLibrary.collectAccumulated(
            msgSender,
            poolInfo,
            userInfo,
            feeParams,
            nodes,
            farmParams,
            feeStores
        );
        if (amount > 0) {
            amount -= _payTransactonFee(nodes.token, nodes.xToken, amount, false);
            PoolInfo storage pool = poolInfo[0];
            amount -= FarmLibrary.payDepositFeeCrssFromXCrss(pool, nodes.token, nodes.xToken, amount, feeStores);
            uint256 balance0 = IERC20(nodes.token).balanceOf(address(this));
            ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, address(this), amount);
            amount = IERC20(nodes.token).balanceOf(address(this)) - balance0;

            rewards = amount;

            UserInfo storage user = userInfo[0][msgSender];
            FarmLibrary.finishRewardCycle(pool, user, msgSender, feeParams, nodes, farmParams, feeStores);
            FarmLibrary.startRewardCycle(pool, user, msgSender, nodes, feeParams, rewards, true); // false: addNotSubract
            emit MassStakeRewards(msgSender, rewards);
        }

        _closeAction();
    }

    // function massCompoundRewards() external virtual override {
    //     _openAction(ActionType.MassCompoundRewards, true);

    //     address msgSender = _msgSender();
    //     uint256 totalCompounded = FarmLibrary.massCompoundRewards(
    //         msgSender,
    //         poolInfo,
    //         userInfo,
    //         nodes,
    //         feeParams,
    //         farmParams,
    //         feeStores
    //     );
    //     emit MassCompoundRewards(msgSender, totalCompounded);

    //     _closeAction();
    // }

    function _payTransactonFee(
        address payerToken,
        address payerAddress,
        uint256 principal,
        bool fromAllowance
    ) internal virtual returns (uint256 feesPaid) {
        if (actionParams.isUserAction && principal > 0) {
            if (address(payerToken) == nodes.token) {
                feesPaid = _payFeeCrss(payerAddress, principal, feeRates[actionParams.actionType], fromAllowance);
            } else {
                feesPaid = CrossLibrary.transferFeesFrom(
                    payerToken,
                    address(this),
                    principal,
                    feeRates[actionParams.actionType],
                    feeStores,
                    nodes.token,
                    true
                ); // payerAddress: address(this).
            }
        }
    }

    //==============================   ==============================

    /**
     * @dev Set the trusted forwarder who works as a middle man between client and this contract.
     * The forwarder verifies client signature, append client's address to call data, and forward the client's call.
     * This contract, as a BaseRelayRecipient, calls _msgSender() to get the appended client address,
     * if msg.sender matches the trusted forwarder. If not, msg.sender itself is returned.
     * This way, the trusted forwader can pay gas fee for the client.
     * See https://eips.ethereum.org/EIPS/eip-2771 for more.
     */
    function setTrustedForwarder(address _trustedForwarder) external onlyOwner {
        require(_trustedForwarder != address(0), sForbidden);
        trustedForwarder = _trustedForwarder;
        emit SetTrustedForwarder(_trustedForwarder);
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
    }
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

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

struct VestChunk {
    uint256 principal;
    uint256 withdrawn;
    uint256 startTime;
}

uint256 constant month = 30 days;

enum CollectOption {
    OffOff,
    OnOff,
    OnOn,
    OffOn
} // Compound_Off Vest_Off is the default.
enum RewardOption {
    FullProcess,
    IndividualOnly,
    NoProcess
}

struct DepositInfo {
    uint256 depositAt;
    uint256 amount;
}

struct UserInfo {
    uint256 amount;
    uint256 rewardDebt;
    uint256 debt1;
    uint256 debt2;
    uint256 accumulated;
    VestChunk[] vestList;
    DepositInfo[] depositList;
    CollectOption collectOption;
}

struct SubPool {
    uint256 bulk;
    uint256 accPerShare;
}
struct Struct_OnOff {
    uint256 sumAmount;
    SubPool Comp;
    SubPool PreComp;
}
struct Struct_OnOn {
    uint256 sumAmount;
    SubPool Comp;
    SubPool PreComp;
    SubPool Vest;
}
struct Struct_OffOn {
    uint256 sumAmount;
    SubPool Vest;
    SubPool Accum;
}
struct Struct_OffOff {
    uint256 sumAmount;
    SubPool Accum;
}
struct Struct_Accum {
    uint256 sumAmount;
    SubPool Pass;
}

struct PoolInfo {
    IERC20 lpToken;
    uint256 allocPoint;
    uint256 lastRewardBlock;
    uint256 accCrssPerShare;
    uint256 depositFeeRate;
    uint256 reward;
    uint256 withdrawLock;
    Struct_OnOff OnOff;
    Struct_OnOn OnOn;
    Struct_OffOn OffOn;
    Struct_OffOff OffOff;
}

struct FarmFeeParams {
    address crssReferral;
    address treasury;
    uint256 referralCommissionRate;
    uint256 maximumReferralCommisionRate;
    uint256 nonVestBurnRate;
    address stakeholders;
    uint256 compoundFeeRate;
}

struct UserRewardBehavior {
    uint256 blockNo;
    uint256 pendingCrss;
    uint256 pendingPerBlock;
    uint256 collectiveCrss;
    uint256 rewardPayroll;
    uint256 thresholdBusdWei;
    address crssBusd;
}

struct UserAssets {
    uint256 collectOption;
    uint256 deposit;
    DepositInfo[] depositList;
    uint256 accRewards;
    uint256 totalVest;
    uint256 totalMatureVest;
    // uint256 lpBalance;
    // uint256 crssBalance;
    // uint256 totalAccRewards;
}

struct UserState {
    UserRewardBehavior behavior;
    UserAssets assets;
}

struct SubPooledCrss {
    uint256 toVest;
    uint256 toAccumulate;
}

struct FarmParams {
    uint256 totalAllocPoint;
    uint256 crssPerBlock;
    uint256 bonusMultiplier;
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IMigratorChef.sol";
import "../xCrssToken.sol";

import "./ICrossFarmTypes.sol";
import "../../session/interfaces/IConstants.sol";
import "../../session/interfaces/INode.sol";

interface ICrossFarm {
    function updateMultiplier(uint256 multiplierNumber) external;

    function poolLength() external view returns (uint256);

    function add(
        uint256 _allocPoint,
        address _lpToken,
        bool _withUpdate,
        uint256 _depositFeeRate,
        uint256 _withdrawLock
    ) external returns (uint256 totalAllocPoint);

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate,
        uint256 _depositFeeRate,
        uint256 _withdrawLock
    ) external returns (uint256 totalAllocPoint);

    event SetFeeParamsReferral(address crssReferral, uint256 referralCommissionRate);
    event SetFeeParamsOthers(address stakeholders, uint256 nonVestBurnRate, uint256 compoundFeeRate);

    event SetTrustedForwarder(address _trustedForwarder);
    event SwitchCollectOption(address indexed user, uint256 poolId, CollectOption option);
    event SetMigrator(address migrator);
    event ChangeReferer(address indexed user, address referrer);

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event WithdrawVest(address indexed user, uint256 indexed pid, uint256 amount);
    event VestAccumulated(address indexed user, uint256 indexed pid, uint256 crssAmount);
    event CompoundAccumulated(address indexed user, uint256 indexed pid, uint256 crssAmount, uint256 lpAmount);
    event HarvestAccumulated(address indexed user, uint256 indexed pid, uint256 crssAmount);
    event StakeAccumulated(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event MassHarvestRewards(address indexed user, uint256 crssAmount);
    event MassStakeRewards(address indexed user, uint256 crssAmount);
    // event MassCompoundRewards(address indexed user, uint256 crssAmount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function getMultiplier(uint256 _from, uint256 _to) external view returns (uint256);

    function massUpdatePools() external;

    function updatePool(uint256 _pid) external;

    function changeReferrer(address user, address referrer) external;

    function deposit(
        uint256 _pid,
        uint256 _amount,
        UserRewardBehavior calldata behavior
    ) external returns (uint256 deposited);

    function withdraw(
        uint256 _pid,
        uint256 _amount,
        UserRewardBehavior memory behavior
    ) external returns (uint256 withdrawn);

    //function withdrawVest(uint256 _pid, uint256 _amount, UserRewardBehavior memory behavior) external returns (uint256 withdrawn);
    // function vestAccumulated(uint256 _pid, UserRewardBehavior memory behavior) external returns (uint256 vested);
    //function compoundAccumulated(uint256 _pid, UserRewardBehavior memory behavior) external returns (uint256 compounded);
    function harvestAccumulated(uint256 _pid, UserRewardBehavior memory behavior) external returns (uint256 harvested);

    function stakeAccumulated(uint256 _pid, UserRewardBehavior memory behavior) external returns (uint256 staked);

    function emergencyWithdraw(uint256 _pid, UserRewardBehavior memory behavior) external;

    function switchCollectOption(
        uint256 _pid,
        CollectOption newOption,
        UserRewardBehavior memory behavior
    ) external;

    function massHarvestRewards() external returns (uint256 rewards);

    function massStakeRewards() external returns (uint256 rewards);

    // function massCompoundRewards() external;

    function periodicPatrol() external returns (bool done);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./interfaces/IConstants.sol";
import "./interfaces/ISessionRegistrar.sol";
import "./interfaces/ISessionManager.sol";

abstract contract SessionManager is ISessionManager {

    ActionParams actionParams;
    ISessionRegistrar sessionRegistrar;
    ISessionFees sessionFees;

    function _openAction(ActionType actionType, bool blockReentry) internal {
        actionParams = sessionRegistrar.registerAction(actionType, blockReentry);
    }
    function _closeAction() internal {
        sessionRegistrar.unregisterAction();
    }

    function _payFeeCrss(address account, uint256 principal, FeeRates memory rates, bool fromAllowance ) internal virtual returns (uint256 feesPaid) {
        feesPaid = sessionFees.payFeeCrssLogic(account, principal, rates, fromAllowance);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./interfaces/INode.sol";
import "../libraries/WireLibrary.sol";

abstract contract Node is INode {
    NodeType thisNode;

    address public prevNode;
    address public nextNode;

    Nodes nodes;
    address crssBusd;

    mapping(address => Pair) public override pairs;
    mapping(address => mapping(address => address)) public override pairFor;

    FeeStores public feeStores;
    mapping(ActionType => FeeRates) public feeRates;

    function getOwner() public virtual returns (address);

    modifier wired() {
        require(msg.sender == prevNode || msg.sender == address(this) || msg.sender == getOwner(), "Invalid caller 1");
        _;
    }

    modifier internalCall() virtual {
        require(WireLibrary.isWiredCall(nodes), "Invalid caller 2");
        _;
    }

    constructor(NodeType _nodeType) {
        thisNode = _nodeType;
    }

    function wire(address _prevNode, address _nextNode) external virtual override {
        require(msg.sender == getOwner(), "Invalid caller 3");
        prevNode = _prevNode;
        nextNode = _nextNode;
    }

    function setNode(
        NodeType nodeType,
        address node,
        address caller
    ) public virtual override wired {
        if (caller != address(this)) {
            // let caller be address(0) when an actor initiats this loop.
            WireLibrary.setNode(nodeType, node, nodes);
            address trueCaller = caller == address(0) ? address(this) : caller;
            INode(nextNode).setNode(nodeType, node, trueCaller);
        } else {
            emit SetNode(nodeType, node);
        }
    }

    bool internal trackPairStatus;

    function changePairStatus(
        address pair,
        address token0,
        address token1,
        ListStatus status,
        address caller
    ) public virtual override wired {
        if (caller != address(this)) {
            // let caller be address(0) when an actor initiats this loop.
            if (trackPairStatus) {
                pairs[pair] = Pair(token0, token1, status);
                pairFor[token0][token1] = pair;
                pairFor[token1][token0] = pair;

                if ((token0 == nodes.token && token1 == BUSD) || (token0 == BUSD && token1 == nodes.token)) {
                    crssBusd = pair;
                }
            }
            address trueCaller = caller == address(0) ? address(this) : caller;
            INode(nextNode).changePairStatus(pair, token0, token1, status, trueCaller);
        } else {
            emit ChangePairStatus(pair, token0, token1, status);
        }
    }

    function _checkEnlisted(address pair) internal view {
        require(pairs[pair].status == ListStatus.Enlisted, "Pair not enlisted");
    }

    bool internal trackFeeStores;

    function setFeeStores(FeeStores memory _feeStores, address caller) public virtual override wired {
        if (caller != address(this)) {
            // let caller be address(0) when an actor initiats this loop.
            if (trackFeeStores) WireLibrary.setFeeStores(feeStores, _feeStores);
            address trueCaller = caller == address(0) ? address(this) : caller;
            INode(nextNode).setFeeStores(_feeStores, trueCaller);
        } else {
            emit SetFeeStores(_feeStores);
        }
    }

    bool internal trackFeeRates;

    function setFeeRates(
        ActionType _sessionType,
        FeeRates memory _feeRates,
        address caller
    ) public virtual override wired {
        if (caller != address(this)) {
            // let caller be address(0) when an actor initiats this loop.
            if (trackFeeRates) WireLibrary.setFeeRates(_sessionType, feeRates, _feeRates);
            address trueCaller = caller == address(0) ? address(this) : caller;
            INode(nextNode).setFeeRates(_sessionType, _feeRates, trueCaller);
        } else {
            emit SetFeeRates(_sessionType, _feeRates);
        }
    }

    function begin(address caller) public virtual override wired {
        if (caller != address(this)) {
            // let caller be address(0) when an actor initiats this loop.
            INode(nextNode).begin(caller == address(0) ? address(this) : caller);
        } else {
            emit Begin();
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../session/interfaces/INode.sol";

library WireLibrary {
    function setNode(
        NodeType nodeType,
        address node,
        Nodes storage nodes
    ) external {
        if (nodeType == NodeType.Token) {
            nodes.token = node;
        } else if (nodeType == NodeType.Center) {
            nodes.center = node;
        } else if (nodeType == NodeType.Maker) {
            nodes.maker = node;
        } else if (nodeType == NodeType.Taker) {
            nodes.taker = node;
        } else if (nodeType == NodeType.Farm) {
            nodes.farm = node;
        } else if (nodeType == NodeType.Repay) {
            nodes.repay = node;
        } else if (nodeType == NodeType.Factory) {
            nodes.factory = node;
        } else if (nodeType == NodeType.XToken) {
            nodes.xToken = node;
        }
    }

    function isWiredCall(Nodes storage nodes) external view returns (bool) {
        return
            msg.sender != address(0) &&
            (msg.sender == nodes.token ||
                msg.sender == nodes.maker ||
                msg.sender == nodes.taker ||
                msg.sender == nodes.farm ||
                msg.sender == nodes.repay ||
                msg.sender == nodes.factory ||
                msg.sender == nodes.xToken);
    }

    function setFeeStores(FeeStores storage feeStores, FeeStores memory _feeStores) external {
        require(_feeStores.accountant != address(0), "Zero address");
        feeStores.accountant = _feeStores.accountant;
        feeStores.dev = _feeStores.dev;
    }

    function setFeeRates(
        ActionType _sessionType,
        mapping(ActionType => FeeRates) storage feeRates,
        FeeRates memory _feeRates
    ) external {
        require(uint256(_sessionType) < NumberSessionTypes, "Wrong ActionType");
        require(_feeRates.accountant <= FeeMagnifier, "Fee rates exceed limit");

        feeRates[_sessionType].accountant = _feeRates.accountant;
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../session/interfaces/IConstants.sol";
interface IMaker {
    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function wired_addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function wired_removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function sim_removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity
    ) external view returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getReserveOnETHPair(address token) external view returns (uint256 reserve);
    
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../session/interfaces/IConstants.sol";
interface ITaker {
    function WETH() external view returns (address);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function wired_swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to
    ) external returns (uint256[] memory amounts);

    function sim_swapExactTokensForTokens(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICrssToken is IERC20 {

    function maxSupply() external view returns (uint256);
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function maxTransferAmountRate() external view returns (uint256);
    function changeMaxTransferAmountRate(uint _maxTransferAmountRate) external;
    function tolerableTransfer(address from, address to, uint256 value) external returns (bool);
    function transferDirectSafe(address sender, address recipient, uint256 amount) external virtual;
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IXCrssToken is IERC20 {

    function getOwner() external view returns (address);
    function safeCrssTransfer(address _to, uint256 _amount) external;
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

interface ICrssReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer, uint256 commission) external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);

    function getOutstandingCommission(address _referrer) external view returns (uint256 amount);

    function debitOutstandingCommission(address _referrer, uint256 _debit) external;
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./interfaces/IRelayRecipient.sol";

/**
 * A base contract to be inherited by any contract that want to receive relayed transactions
 * A subclass must use "_msgSender()" instead of "msg.sender"
 */
abstract contract BaseRelayRecipient is IRelayRecipient {
    /*
     * Forwarder singleton we accept calls from
     */
    address public trustedForwarder;

    /*
     * require a function to be called through GSN only
     */
    modifier trustedForwarderOnly() {
        require(msg.sender == address(trustedForwarder), "Function can only be called through the trusted Forwarder");
        _;
    }

    function isTrustedForwarder(address forwarder) public view override returns (bool) {
        return forwarder == trustedForwarder;
    }

    /**
     * return the sender of this call.
     * if the call came through our trusted forwarder, return the original sender.
     * otherwise, return `msg.sender`.
     * should be used in the contract anywhere instead of msg.sender
     */
    function _msgSender() internal view override virtual returns (address payable ret) {
        if (msg.data.length >= 24 && isTrustedForwarder(msg.sender)) {
            // At this point we know that the sender is a trusted forwarder,
            // so we trust that the last bytes of msg.data are the verified sender address.
            // extract sender address from the end of msg.data
            assembly {
                ret := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return payable(msg.sender);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

    function abs(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a > b ? a - b : b - a;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../session/interfaces/ISessionManager.sol";
import "../session/interfaces/ISessionFees.sol";
import "../periphery/interfaces/IMaker.sol";
import "../periphery/interfaces/ITaker.sol";
import "../farm/interfaces/ICrssToken.sol";
import "../farm/interfaces/IXCrssToken.sol";
import "../core/interfaces/IPancakePair.sol";
import "../farm/interfaces/ICrssReferral.sol";
import "../farm/interfaces/IMigratorChef.sol";
import "../farm/interfaces/ICrossFarmTypes.sol";
import "../farm/interfaces/ICrossFarm.sol";
import "../libraries/utils/TransferHelper.sol";
import "../libraries/CrossLibrary.sol";
import "./math/SafeMath.sol";
import "hardhat/console.sol";

library FarmLibrary {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function sim_changeLpTokensToCrssInFarm(
        address sourceLpToken,
        Nodes storage nodes,
        uint256 lpAmount
    ) public view returns (uint256 newCrss) {
        if (address(sourceLpToken) != address(0) && lpAmount > 0) {
            if (sourceLpToken == nodes.token) {
                newCrss = lpAmount;
            } else {
                (address token0, address token1, ) = INode(nodes.maker).pairs(sourceLpToken);

                bool foundDirectSwapPath;
                {
                    address pair0 = INode(nodes.maker).pairFor(nodes.token, token0);
                    address pair0BNB = INode(nodes.maker).pairFor(IMaker(nodes.maker).WETH(), token0);
                    address pair1 = INode(nodes.maker).pairFor(nodes.token, token1);
                    address pair1BNB = INode(nodes.maker).pairFor(IMaker(nodes.maker).WETH(), token1);
                    foundDirectSwapPath =
                        (address(nodes.token) == token0 || pair0 != address(0) || pair0BNB != address(0)) &&
                        (nodes.token == token1 || pair1 != address(0) || pair1BNB != address(0));
                }
                require(foundDirectSwapPath, "Swap path not found");

                (uint256 amount0, uint256 amount1) = IMaker(nodes.maker).sim_removeLiquidity(token0, token1, lpAmount);

                newCrss += _sim_swapExactNonCrssForCrss(ITaker(nodes.taker), nodes.token, token0, amount0, nodes);
                newCrss += _sim_swapExactNonCrssForCrss(ITaker(nodes.taker), nodes.token, token1, amount1, nodes);
            }
        }
    }

    // Save code size.
    // function changeLpTokensToCrssInFarm(
    //     address sourceLpToken,
    //     Nodes storage nodes,
    //     uint256 lpAmount
    // ) external returns (uint256 newCrss) {
    //     if (address(sourceLpToken) != address(0) && lpAmount > 0) {
    //         if (sourceLpToken == nodes.token) {
    //             newCrss = lpAmount;
    //         } else {
    //             (address token0, address token1, ) = INode(nodes.maker).pairs(sourceLpToken);

    //             bool foundDirectSwapPath;
    //             {
    //                 address pair0 = INode(nodes.maker).pairFor(nodes.token, token0);
    //                 address pair1 = INode(nodes.maker).pairFor(nodes.token, token1);
    //                 foundDirectSwapPath =
    //                     (address(nodes.token) == token0 || pair0 != address(0)) &&
    //                     (nodes.token == token1 || pair1 != address(0));
    //             }
    //             require(foundDirectSwapPath, "Swap path not found");

    //             uint256 balance0_old = IERC20(token0).balanceOf(address(this));
    //             uint256 balance1_old = IERC20(token1).balanceOf(address(this));
    //             IMaker(nodes.maker).wired_removeLiquidity(token0, token1, lpAmount, 0, 0, address(this), block.timestamp);
    //             uint256 amount0 = IERC20(token0).balanceOf(address(this)) - balance0_old;
    //             uint256 amount1 = IERC20(token1).balanceOf(address(this)) - balance1_old;

    //             require(amount0 > 0 && amount1 > 0, "RemoveLiqudity failed");
    //             newCrss += _swapExactNonCrssForCrss(ITaker(nodes.taker), nodes.token, token0, amount0);
    //             newCrss += _swapExactNonCrssForCrss(ITaker(nodes.taker), nodes.token, token1, amount1);
    //         }
    //     }
    // }

    function changeCrssInXTokenToLpInFarm(
        address targetLpToken,
        Nodes storage nodes,
        uint256 amountCrssInXToken,
        address dustBin
    ) public returns (uint256 newLpAmountInFarm) {
        if (targetLpToken != address(0) && amountCrssInXToken > 0) {
            uint256 balance0 = ICrssToken(nodes.token).balanceOf(address(this));
            ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, address(this), amountCrssInXToken);
            uint256 amountCrssInFarm = ICrssToken(nodes.token).balanceOf(address(this)) - balance0;

            if (targetLpToken == nodes.token) {
                newLpAmountInFarm = amountCrssInFarm; // Staked Crss tokens reside in token.balanceOf[address(this)].
            } else {
                uint256 amount0 = amountCrssInFarm / 2;
                uint256 amount1 = amountCrssInFarm - amount0;

                (address token0, address token1, ) = INode(nodes.maker).pairs(targetLpToken);

                {
                    bool token0Swapable = nodes.token == token0 ||
                        INode(nodes.maker).pairFor(nodes.token, token0) != address(0) ||
                        INode(nodes.maker).pairFor(IMaker(nodes.maker).WETH(), token0) != address(0);
                    bool token1Swapable = nodes.token == token1 ||
                        INode(nodes.maker).pairFor(nodes.token, token1) != address(0) ||
                        INode(nodes.maker).pairFor(IMaker(nodes.maker).WETH(), token1) != address(0);

                    require(token0Swapable && token1Swapable, "Swap path not found");
                }
                amount0 = _swapExactCrssForNonCrss(ITaker(nodes.taker), nodes, nodes.token, token0, amount0); // From farm to farm
                amount1 = _swapExactCrssForNonCrss(ITaker(nodes.taker), nodes, nodes.token, token1, amount1); // From farm to farm

                require(amount0 > 0 && amount1 > 0, "Swap failed");

                balance0 = IERC20(targetLpToken).balanceOf(address(this));
                IERC20(token0).safeIncreaseAllowance(nodes.maker, amount0);
                IERC20(token1).safeIncreaseAllowance(nodes.maker, amount1);

                (uint256 _amount0, uint256 _amount1, ) = IMaker(nodes.maker).wired_addLiquidity(
                    token0,
                    token1,
                    amount0,
                    amount1,
                    0,
                    0,
                    address(this), // lp tokens sent to farm.
                    block.timestamp
                );
                newLpAmountInFarm = IERC20(targetLpToken).balanceOf(address(this)) - balance0;

                // Dust is neglected for gas saving:

                // if (amount0 > _amount0) { // remove dust
                //     pushToUser(token0, dustBin, amount0 - _amount0, nodes.token);
                // }
                // if (amount1 > _amount1) { // remove dust
                //     pushToUser(token1, dustBin, amount1 - _amount1, nodes.token);
                // }
            }
        }
    }

    function _swapExactCrssForNonCrss(
        ITaker taker,
        Nodes storage nodes,
        address token,
        address tokenTo,
        uint256 amount
    ) internal returns (uint256 resultingAmount) {
        if (tokenTo == token) {
            resultingAmount = amount;
        } else {
            uint256 balance0 = IERC20(tokenTo).balanceOf(address(this));

            ICrssToken(token).approve(address(taker), amount);
            address[] memory path;

            if (INode(nodes.maker).pairFor(nodes.token, tokenTo) != address(0)) {
                path = new address[](2);
                path[0] = token;
                path[1] = tokenTo;
            } else {
                path = new address[](3);
                path[0] = token;
                path[1] = IMaker(nodes.maker).WETH();
                path[2] = tokenTo;
            }

            taker.wired_swapExactTokensForTokens(
                amount,
                0, // in trust of taker's price control.
                path,
                address(this)
            );
            resultingAmount = IERC20(tokenTo).balanceOf(address(this)) - balance0;
        }
    }

    function _swapExactNonCrssForCrss(
        ITaker taker,
        address token,
        address tokenFr,
        uint256 amount
    ) internal returns (uint256 resultingAmount) {
        if (tokenFr == token) {
            resultingAmount = amount;
        } else {
            uint256 balance0 = IERC20(token).balanceOf(address(this));

            ICrssToken(tokenFr).approve(address(taker), amount);
            address[] memory path = new address[](2);
            path[0] = tokenFr;
            path[1] = token;
            taker.wired_swapExactTokensForTokens(
                amount,
                0, // in trust of taker's price control.
                path,
                address(this)
            );
            resultingAmount = IERC20(token).balanceOf(address(this)) - balance0;
        }
    }

    function _sim_swapExactNonCrssForCrss(
        ITaker taker,
        address token,
        address tokenFr,
        uint256 amount,
        Nodes storage nodes
    ) internal view returns (uint256 resultingAmount) {
        if (tokenFr == token) {
            resultingAmount = amount;
        } else {
            address[] memory path;
            if (INode(nodes.maker).pairFor(token, tokenFr) != address(0)) {
                path = new address[](2);
                path[0] = tokenFr;
                path[1] = token;
            } else {
                path = new address[](3);
                path[0] = tokenFr;
                path[1] = IMaker(nodes.maker).WETH();
                path[2] = token;
            }

            uint256[] memory amounts = taker.sim_swapExactTokensForTokens(amount, path);
            resultingAmount = amounts[1];
        }
    }

    // Save code size.
    // function swapExactTokenForToken(
    //     ITaker taker,
    //     address token,
    //     address tokenFr,
    //     address tokenTo,
    //     uint256 amount
    // ) external returns (uint256 tokenToAmount) {
    //     if (tokenFr != tokenTo) {
    //         uint256 _tokenToAmt = IERC20(tokenTo).balanceOf(address(this));

    //         ICrssToken(token).approve(address(taker), amount);
    //         address[] memory path = new address[](2);
    //         path[0] = tokenFr;
    //         path[1] = tokenTo;
    //         taker.wired_swapExactTokensForTokens(
    //             amount,
    //             0, // in trust of taker's price control.
    //             path,
    //             address(this),
    //             block.timestamp
    //         );
    //         tokenToAmount = IERC20(tokenTo).balanceOf(address(this)) - _tokenToAmt;
    //     } else {
    //         return amount;
    //     }
    // }

    function getTotalVestPrincipals(VestChunk[] storage vestList) public view returns (uint256 amount) {
        for (uint256 i = 0; i < vestList.length; i++) {
            amount += vestList[i].principal;
        }
    }

    function getTotalMatureVestPieces(VestChunk[] storage vestList, uint256 vestMonths)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < vestList.length; i++) {
            // Time simulation for test: 600 * 24 * 30. A hardhat block pushes 2 seconds of timestamp. 3 blocks will be equivalent to a month.
            uint256 elapsed = (block.timestamp - vestList[i].startTime); // * 600 * 24 * 30;
            uint256 monthsElapsed = elapsed / month >= vestMonths ? vestMonths : elapsed / month;
            uint256 unlockAmount = (vestList[i].principal * monthsElapsed) / vestMonths - vestList[i].withdrawn;
            amount += unlockAmount;
        }
    }

    function withdrawVestPieces(
        VestChunk[] storage vestList,
        uint256 vestMonths,
        uint256 amount
    ) internal returns (uint256 _amountToFill) {
        _amountToFill = amount;

        uint256 i;
        while (_amountToFill > 0 && i < vestList.length) {
            // Time simulation for test: 600 * 24 * 30. A hardhat block pushes 2 seconds of timestamp. 3 blocks will be equivalent to a month.
            uint256 elapsed = (block.timestamp - vestList[i].startTime); // * 600 * 24 * 30;
            uint256 monthsElapsed = elapsed / month >= vestMonths ? vestMonths : elapsed / month;
            uint256 unlockAmount = (vestList[i].principal * monthsElapsed) / vestMonths - vestList[i].withdrawn;
            if (unlockAmount > _amountToFill) {
                vestList[i].withdrawn += _amountToFill; // so, vestList[i].withdrawn < vestList[i].principal * monthsElapsed / vestMonths.
                _amountToFill = 0;
            } else {
                _amountToFill -= unlockAmount;
                vestList[i].withdrawn += unlockAmount; // so, vestList[i].withdrawn == vestList[i].principal * monthsElapsed / vestMonths.
            }
            if (vestList[i].withdrawn == vestList[i].principal) {
                // if and only if monthsElapsed == vestMonths.
                for (uint256 j = i; j < vestList.length - 1; j++) vestList[j] = vestList[j + 1];
                vestList.pop();
            } else {
                i++;
            }
        }
    }

    function takePendingCollectively(
        PoolInfo storage pool,
        FarmFeeParams storage feeParams,
        Nodes storage nodes,
        bool periodic
    ) public {
        uint256 subPoolPending;
        uint256 totalRewards;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        uint256 feePaid;
        uint256 halfToCompound;
        uint256 newLpAmountInFarm;
        uint256 halfToVest;
        uint256 halfToSend;

        // pendingCrss == (getRewardPayroll(pool, user) * pool.accCrssPerShare) / 1e12 - user.rewardDebt
        // is implicitly taken to appropriate subPools here, for all users.

        if (lpSupply > 0) {
            //-------------------- OnOff SubPool Group Takes -------------------- Compound On, Vest Off
            uint256 sumAmount = pool.OnOff.sumAmount;
            subPoolPending = ((sumAmount + pool.OnOff.Comp.bulk) * pool.reward) / lpSupply;

            if (subPoolPending > 0) {
                totalRewards += subPoolPending;
                feePaid = (subPoolPending * feeParams.nonVestBurnRate) / FeeMagnifier;
                ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, feeParams.stakeholders, feePaid);
                subPoolPending -= feePaid;
                subPoolPending -= payCompoundFee(nodes.token, feeParams, subPoolPending, nodes);
            }

            if (periodic) {
                // It takes the amount that belong to the users who left this branch after the latest patrol.
                subPoolPending += _emptySubPool(pool.OnOff.PreComp);
                if (subPoolPending > 0) {
                    newLpAmountInFarm = changeCrssInXTokenToLpInFarm(
                        address(pool.lpToken),
                        nodes,
                        subPoolPending,
                        feeParams.stakeholders
                    );
                    _addToSubPool(pool.OnOff.Comp, sumAmount, newLpAmountInFarm); // updates bulk & accPerShare.
                }
            } else {
                // This amount is not guranteed to be returned to the users who's deposits participate in sumAmount, if they leave this branch.
                if (subPoolPending > 0) _addToSubPool(pool.OnOff.PreComp, sumAmount, subPoolPending); // updates bulk & accPerShare.
            }

            //-------------------- OnOn SubPool Group Takes -------------------- Compound On, Vest On
            sumAmount = pool.OnOn.sumAmount;
            subPoolPending = ((sumAmount + pool.OnOn.Comp.bulk) * pool.reward) / lpSupply;

            if (subPoolPending > 0) {
                totalRewards += subPoolPending;
                halfToCompound = subPoolPending / 2;
                halfToVest = subPoolPending - halfToCompound;
                halfToCompound -= payCompoundFee(nodes.token, feeParams, halfToCompound, nodes);
            } // else: halfToCompound = 0, halfToVest = 0; implicitly.

            if (periodic) {
                // It takes the amount that belong to the users who left this branch after the latest patrol.
                halfToCompound += _emptySubPool(pool.OnOn.PreComp);
                if (halfToCompound > 0) {
                    newLpAmountInFarm = changeCrssInXTokenToLpInFarm(
                        address(pool.lpToken),
                        nodes,
                        halfToCompound,
                        feeParams.stakeholders
                    );
                    _addToSubPool(pool.OnOn.Comp, sumAmount, newLpAmountInFarm); // updates bulk & accPerShare.
                }
            } else {
                // This amount is not guranteed to be returned to the users who's deposits participate in sumAmount, if they leave this branch.
                if (halfToCompound > 0) _addToSubPool(pool.OnOn.PreComp, sumAmount, halfToCompound); // updates bulk & accPerShare.
            }
            if (halfToVest > 0) _addToSubPool(pool.OnOn.Vest, sumAmount, halfToVest); // updates bulk & accPerShare.

            //-------------------- OffOn SubPool Group Takes -------------------- Compound Off, Vest On

            subPoolPending = ((pool.OffOn.sumAmount) * pool.reward) / lpSupply;

            if (subPoolPending > 0) {
                totalRewards += subPoolPending;
                halfToVest = subPoolPending / 2;
                halfToSend = subPoolPending - halfToVest;
                _addToSubPool(pool.OffOn.Vest, pool.OffOn.sumAmount, halfToVest); // updates bulk & accPerShare.
                _addToSubPool(pool.OffOn.Accum, pool.OffOn.sumAmount, halfToSend); // updates bulk & accPerShare.
            }
            //-------------------- OffOff SubPool Group Takes -------------------- Compound Off, Vest Off

            subPoolPending = ((pool.OffOff.sumAmount) * pool.reward) / lpSupply;

            if (subPoolPending > 0) {
                totalRewards += subPoolPending;
                feePaid = (subPoolPending * feeParams.nonVestBurnRate) / FeeMagnifier;
                ICrssToken(nodes.token).burn(nodes.xToken, feePaid);
                subPoolPending -= feePaid;
                _addToSubPool(pool.OffOff.Accum, pool.OffOff.sumAmount, subPoolPending); // updates bulk & accPerShare.
            }
        }
    }

    function _addToSubPool(
        SubPool storage subPool,
        uint256 totalShare,
        uint256 newAmount
    ) internal {
        subPool.bulk += newAmount;
        if (totalShare > 0) {
            // Note: that inteter devision is not greater than real division. So it's safe.
            // Note: if it's less than real division, then a seed of dust is formed here.
            subPool.accPerShare += ((newAmount * 1e12) / totalShare);
        }
    }

    function _emptySubPool(SubPool storage subPool) internal returns (uint256 amount) {
        amount = subPool.bulk;
        subPool.bulk = 0;
        subPool.accPerShare = 0;
    }

    function payCompoundFee(
        address payerToken,
        FarmFeeParams storage feeParams,
        uint256 amount,
        Nodes storage nodes
    ) public returns (uint256 feesPaid) {
        feesPaid = (amount * feeParams.compoundFeeRate) / FeeMagnifier;
        if (feesPaid > 0) {
            if (payerToken == nodes.token) {
                ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, feeParams.stakeholders, feesPaid);
            } else {
                TransferHelper.safeTransfer(payerToken, feeParams.stakeholders, feesPaid);
            }
        }
    }

    function payReferralComission(
        PoolInfo storage pool,
        UserInfo storage user,
        address msgSender,
        FarmFeeParams storage feeParams,
        Nodes storage nodes
    ) public {
        //-------------------- Pay referral fee outside of user's pending reward --------------------
        // This is the only place user.rewardDebt works explicitly.
        uint256 userPending = (getRewardPayroll(pool, user) * pool.accCrssPerShare) / 1e12 - user.rewardDebt;
        if (userPending > 0) {
            if (feeParams.crssReferral != address(0)) {
                uint256 commission = userPending.mul(feeParams.referralCommissionRate).div(FeeMagnifier);
                if (commission > 0) {
                    address referrer = ICrssReferral(feeParams.crssReferral).getReferrer(msgSender);
                    if (referrer != address(0)) {
                        ICrssToken(nodes.token).mint(nodes.xToken, commission);
                        ICrssReferral(feeParams.crssReferral).recordReferralCommission(referrer, commission);
                    }
                }
            }
            //user.rewardDebt = (getRewardPayroll(pool, user) * pool.accCrssPerShare) / 1e12;
        }
    }

    function getCollectiveRewards(
        PoolInfo storage pool,
        UserInfo storage user,
        Nodes storage nodes
    ) internal view returns (uint256 collectiveCrss) {
        //-------------------- Calling User Takes -------------------------------------------------------------------------
        uint256 collectiveCompound;

        if (user.collectOption == CollectOption.OnOff && user.amount > 0) {
            collectiveCompound = (user.amount * pool.OnOff.Comp.accPerShare) / 1e12 - user.debt1;
        } else if (user.collectOption == CollectOption.OnOn && user.amount > 0) {
            collectiveCompound = (user.amount * pool.OnOn.Comp.accPerShare) / 1e12 - user.debt1;
            collectiveCrss = (user.amount * pool.OnOn.Vest.accPerShare) / 1e12 - user.debt2;
        } else if (user.collectOption == CollectOption.OffOn && user.amount > 0) {
            collectiveCrss = (user.amount * pool.OffOn.Vest.accPerShare) / 1e12 - user.debt1;
            collectiveCrss += (user.amount * pool.OffOn.Accum.accPerShare) / 1e12 - user.debt2;
        } else if (user.collectOption == CollectOption.OffOff && user.amount > 0) {
            collectiveCrss = (user.amount * pool.OffOff.Accum.accPerShare) / 1e12 - user.debt1;
        }

        if (collectiveCompound > 0) {
            collectiveCrss += sim_changeLpTokensToCrssInFarm(address(pool.lpToken), nodes, collectiveCompound);
        }
    }

    /**
     * @dev Take the current rewards related to user's deposit, so that the user can change their deposit further.
     */

    function takeIndividualReward(PoolInfo storage pool, UserInfo storage user) public {
        //-------------------- Calling User Takes -------------------------------------------------------------------------
        if (user.collectOption == CollectOption.OnOff && user.amount > 0) {
            // dust may be formed here, due to accPerShare less than its real value.
            uint256 userCompound = (user.amount * pool.OnOff.Comp.accPerShare) / 1e12 - user.debt1;
            if (userCompound > 0) {
                if (pool.OnOff.Comp.bulk < userCompound) userCompound = pool.OnOff.Comp.bulk;
                pool.OnOff.Comp.bulk -= userCompound;
                user.amount += userCompound; //---------- Compound substantially
                pool.OnOff.sumAmount += userCompound;
                // if it's guranteed user.debt1 is not used again, we can remove the following line to save gas.
                // user.debt1 = (user.amount * pool.OnOff.Comp.accPerShare) / 1e12;
            }
        } else if (user.collectOption == CollectOption.OnOn && user.amount > 0) {
            uint256 userAmount = user.amount;
            // dust may be formed here, due to accPerShare less than its real value.
            uint256 userCompound = (user.amount * pool.OnOn.Comp.accPerShare) / 1e12 - user.debt1;
            if (userCompound > 0) {
                if (pool.OnOn.Comp.bulk < userCompound) userCompound = pool.OnOn.Comp.bulk;
                pool.OnOn.Comp.bulk -= userCompound;
                user.amount += userCompound; //---------- Compound substantially
                pool.OnOn.sumAmount += userCompound;
                // if it's guranteed user.debt1 is not used again, we can remove the following line to save gas.
                // user.debt1 = (user.amount * pool.OnOn.Comp.accPerShare) / 1e12;
            }

            // dust may be formed here, due to accPerShare less than its real value.
            uint256 userVest = (userAmount * pool.OnOn.Vest.accPerShare) / 1e12 - user.debt2;
            if (userVest > 0) {
                if (pool.OnOn.Vest.bulk < userVest) userVest = pool.OnOn.Vest.bulk;
                pool.OnOn.Vest.bulk -= userVest;
                user.vestList.push(VestChunk({principal: userVest, withdrawn: 0, startTime: block.timestamp})); //---------- Put in vesting.
                // if it's guranteed user.debt2 is not used again, we can remove the following line to save gas.
                // user.debt2 = (user.amount * pool.OnOn.Vest.accPerShare) / 1e12;
            }
        } else if (user.collectOption == CollectOption.OffOn && user.amount > 0) {
            // dust may be formed here, due to accPerShare less than its real value.
            uint256 userVest = (user.amount * pool.OffOn.Vest.accPerShare) / 1e12 - user.debt1; //
            if (userVest > 0) {
                if (pool.OffOn.Vest.bulk < userVest) userVest = pool.OffOn.Vest.bulk;
                pool.OffOn.Vest.bulk -= userVest;
                user.vestList.push(VestChunk({principal: userVest, withdrawn: 0, startTime: block.timestamp})); //---------- Put in vesting.
                // if it's guranteed user.debt1 is not used again, we can remove the following line to save gas.
                // user.debt1 = (user.amount * pool.OffOn.Vest.accPerShare) / 1e12;
            }

            // dust may be formed here, due to accPerShare less than its real value.
            uint256 userAccum = (user.amount * pool.OffOn.Accum.accPerShare) / 1e12 - user.debt2;
            if (userAccum > 0) {
                if (pool.OffOn.Accum.bulk < userAccum) userAccum = pool.OffOn.Accum.bulk;
                pool.OffOn.Accum.bulk -= userAccum;
                user.accumulated += userAccum; //---------- Accumulate.
                // if it's guranteed user.debt2 is not used again, we can remove the following line to save gas.
                // user.debt2 = (user.amount * pool.OffOn.Accum.accPerShare) / 1e12;
            }
        } else if (user.collectOption == CollectOption.OffOff && user.amount > 0) {
            // dust may be formed here, due to accPerShare less than its real value.
            uint256 userAccum = (user.amount * pool.OffOff.Accum.accPerShare) / 1e12 - user.debt1;
            if (userAccum > 0) {
                if (pool.OffOff.Accum.bulk < userAccum) userAccum = pool.OffOff.Accum.bulk;
                pool.OffOff.Accum.bulk -= userAccum;
                user.accumulated += userAccum; //---------- Accumulate.
                // if it's guranteed user.debt1 is not used again, we can remove the following line to save gas.
                // user.debt1 = (user.amount * pool.OffOff.Accum.accPerShare) / 1e12;
            }
        }

        // if it's guranteed user.rewardDebt is not used again, we can remove the following line to save gas.
        user.rewardDebt = (getRewardPayroll(pool, user) * pool.accCrssPerShare) / 1e12;
    }

    /**
     * @dev Begine a new rewarding interval with a new user.amount.
     * @dev Change the user.amount value, change branches' sum of user.amounts, and reset all debt so that pendings are zero now.
     * Note: This is not the place to upgrade accPerShare, because this call is not a reward gain.
     * Reward gain, instead, takes place in _updatePool, for pools, and _takeIndividualRewards, for branches and subpools.
     */
    function startRewardCycle(
        PoolInfo storage pool,
        UserInfo storage user,
        address msgSender,
        Nodes storage nodes,
        FarmFeeParams storage feeParams,
        uint256 amount,
        bool addNotSubtract
    ) public {
        // Open it for 0 amount, as it re-bases user debts.

        payReferralComission(pool, user, msgSender, feeParams, nodes); // Pay commission before user.debtReward will change.

        // If pool has unlock period, add deposit list to user info
        if (pool.withdrawLock > 0) {
            if (addNotSubtract) {
                user.depositList.push(DepositInfo({depositAt: block.timestamp, amount: amount}));
            } else {
                bool withdrawable = withdrawLockedLP(pool, user, amount);
                require(withdrawable, "Lock Time Unreached");
            }
        }
        user.amount = addNotSubtract ? (user.amount + amount) : (user.amount - amount);
        if (user.collectOption == CollectOption.OnOff) {
            pool.OnOff.sumAmount = addNotSubtract ? pool.OnOff.sumAmount + amount : pool.OnOff.sumAmount - amount;
            // if (pool.OnOff.sumAmount == 0) {
            //     pushToUser(address(pool.lpToken), msgSender, _emptySubPool(pool.OnOff.Comp), nodes.token);
            //     ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, msgSender, _emptySubPool(pool.OnOff.PreComp));
            // }
            user.debt1 = (user.amount * pool.OnOff.Comp.accPerShare) / 1e12;
        } else if (user.collectOption == CollectOption.OnOn) {
            pool.OnOn.sumAmount = addNotSubtract ? pool.OnOn.sumAmount + amount : pool.OnOn.sumAmount - amount;
            // if (pool.OnOn.sumAmount == 0) {
            //     pushToUser(address(pool.lpToken), msgSender, _emptySubPool(pool.OnOn.Comp), nodes.token);
            //     ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, msgSender, _emptySubPool(pool.OnOn.PreComp));
            //     user.vestList.push(VestChunk({principal: _emptySubPool(pool.OnOn.Vest), withdrawn: 0, startTime: block.timestamp})); //---------- Put in vesting.
            //     // ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, msgSender, _emptySubPool(pool.OnOn.Vest));
            // }
            user.debt1 = (user.amount * pool.OnOn.Comp.accPerShare) / 1e12;
            user.debt2 = (user.amount * pool.OnOn.Vest.accPerShare) / 1e12;
        } else if (user.collectOption == CollectOption.OffOn) {
            pool.OffOn.sumAmount = addNotSubtract ? pool.OffOn.sumAmount + amount : pool.OffOn.sumAmount - amount;
            // if (pool.OffOn.sumAmount == 0) {
            //     user.vestList.push(VestChunk({principal: _emptySubPool(pool.OffOn.Vest), withdrawn: 0, startTime: block.timestamp})); //---------- Put in vesting.
            //     // ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, msgSender, _emptySubPool(pool.OffOn.Vest));
            //     user.accumulated += _emptySubPool(pool.OffOn.Accum);
            //     // ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, msgSender, _emptySubPool(pool.OffOn.Accum));
            // }
            user.debt1 = (user.amount * pool.OffOn.Vest.accPerShare) / 1e12;
            user.debt2 = (user.amount * pool.OffOn.Accum.accPerShare) / 1e12;
        } else if (user.collectOption == CollectOption.OffOff) {
            pool.OffOff.sumAmount = addNotSubtract ? pool.OffOff.sumAmount + amount : pool.OffOff.sumAmount - amount;
            // if (pool.OffOff.sumAmount == 0) {
            //     user.accumulated += _emptySubPool(pool.OffOff.Accum);
            //     // ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, msgSender, _emptySubPool(pool.OffOff.Accum));
            // }
            user.debt1 = (user.amount * pool.OffOff.Accum.accPerShare) / 1e12;
        }

        // No matter if acc has been updated or not since the last visit to this line.
        // [updatePool(), ..., takePendingCollectively()] called after the previous call of this function
        // has collectively taken (getRewardPayroll(pool, user) * pool.accCrssPerShare) / 1e12 - user.rewardDebt.
        user.rewardDebt = (getRewardPayroll(pool, user) * pool.accCrssPerShare) / 1e12;
    }

    function withdrawLockedLP(
        PoolInfo storage pool,
        UserInfo storage user,
        uint256 amount
    ) internal returns (bool) {
        DepositInfo[] storage depositList = user.depositList;
        uint256 lockPeriod = pool.withdrawLock;

        uint256 i;
        uint256 amountWithdraw = amount;

        while (amountWithdraw > 0 && i < depositList.length) {
            // Time simulation for test: 600 * 24 * 30. A hardhat block pushes 2 seconds of timestamp. 3 blocks will be equivalent to a month.
            uint256 elapsed = (block.timestamp - depositList[i].depositAt); // * 600 * 24 * 30;
            if (elapsed > lockPeriod) {
                if (amountWithdraw >= depositList[i].amount) {
                    amountWithdraw -= depositList[i].amount;
                    for (uint256 j = i; j < depositList.length - 1; j++) depositList[j] = depositList[j + 1];
                    depositList.pop();
                } else {
                    depositList[i].amount -= amountWithdraw;
                    amountWithdraw = 0;
                }
            } else {
                i++;
            }
        }
        if (amountWithdraw == 0) return true;
        else return false;
    }

    /**
     * @dev Take the current rewards related to user's deposit, so that the user can change their deposit further.
     */

    function getRewardPayroll(PoolInfo storage pool, UserInfo storage user) public view returns (uint256 userLp) {
        userLp = user.amount;

        if (user.collectOption == CollectOption.OnOff && user.amount > 0) {
            userLp += ((user.amount * pool.OnOff.Comp.accPerShare) / 1e12 - user.debt1); //---------- Compound
        } else if (user.collectOption == CollectOption.OnOn && user.amount > 0) {
            userLp += ((user.amount * pool.OnOn.Comp.accPerShare) / 1e12 - user.debt1); //---------- Compound
        }
    }

    function withdrawOutstandingCommission(
        address referrer,
        uint256 amount,
        FarmFeeParams storage feeParams,
        Nodes storage nodes
    ) external {
        uint256 available = ICrssReferral(feeParams.crssReferral).getOutstandingCommission(referrer);
        if (available < amount) amount = available;
        if (amount > 0) {
            ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, referrer, amount);
            ICrssReferral(feeParams.crssReferral).debitOutstandingCommission(referrer, amount);
        }
    }

    // function migratePool(PoolInfo storage pool, IMigratorChef migrator) external returns (IERC20 newLpToken) {
    //     IERC20 lpToken = pool.lpToken;
    //     uint256 bal = lpToken.balanceOf(address(this));
    //     lpToken.safeApprove(address(migrator), bal);
    //     newLpToken = migrator.migrate(lpToken);
    //     require(bal == newLpToken.balanceOf(address(this)), "migration inconsistent");
    // }

    function switchCollectOption(
        PoolInfo storage pool,
        UserInfo storage user,
        UserRewardBehavior memory behavior,
        CollectOption newOption,
        address msgSender,
        FarmFeeParams storage feeParams,
        Nodes storage nodes,
        FarmParams storage farmParams,
        FeeStores storage feeStores
    ) external returns (bool switched) {
        CollectOption orgOption = user.collectOption;

        if (orgOption != newOption) {
            finishRewardCycle2(pool, user, behavior, msgSender, feeParams, nodes, farmParams, feeStores);

            uint256 userAmount = user.amount;
            startRewardCycle(pool, user, msgSender, nodes, feeParams, userAmount, false); // false: addNotSubract

            user.collectOption = newOption;

            startRewardCycle(pool, user, msgSender, nodes, feeParams, userAmount, true); // true: addNotSubract

            switched = true;
        }
    }

    function collectAccumulated(
        address msgSender,
        PoolInfo[] storage poolInfo,
        mapping(uint256 => mapping(address => UserInfo)) storage userInfo,
        FarmFeeParams storage feeParams,
        Nodes storage nodes,
        FarmParams storage farmParams,
        FeeStores storage feeStores
    ) external returns (uint256 rewards) {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid++) {
            PoolInfo storage pool = poolInfo[pid];
            UserInfo storage user = userInfo[pid][msgSender];

            if (
                (user.collectOption == CollectOption.OffOn || user.collectOption == CollectOption.OffOff) &&
                user.amount > 0
            ) {
                finishRewardCycle(pool, user, msgSender, feeParams, nodes, farmParams, feeStores);
            }
            rewards += user.accumulated;
            user.accumulated = 0;
        }
    }

    // function massCompoundRewards(
    //     address msgSender,
    //     PoolInfo[] storage poolInfo,
    //     mapping(uint256 => mapping(address => UserInfo)) storage userInfo,
    //     Nodes storage nodes,
    //     FarmFeeParams storage feeParams,
    //     FarmParams storage farmParams,
    //     FeeStores storage feeStores
    // ) external returns (uint256 totalCompounded) {
    //     uint256 crssToPay;
    //     uint256 len = poolInfo.length;
    //     for (uint256 pid = 0; pid < len; pid++) {
    //         PoolInfo storage pool = poolInfo[pid];
    //         UserInfo storage user = userInfo[pid][msgSender];
    //         if (
    //             (user.collectOption == CollectOption.OffOn || user.collectOption == CollectOption.OffOff) &&
    //             user.amount > 0
    //         ) {
    //             finishRewardCycle(pool, user, msgSender, feeParams, nodes, farmParams, feeStores);
    //         }

    //         address _msgSender = msgSender;
    //         uint256 newLpAmount;
    //         {
    //             uint256 accumCrss = user.accumulated;
    //             if (feeParams.compoundFeeRate > 0) {
    //                 uint256 fee = (accumCrss * feeParams.compoundFeeRate) / FeeMagnifier;
    //                 accumCrss -= fee;
    //                 crssToPay += fee;
    //             }
    //             totalCompounded += accumCrss;
    //             newLpAmount = changeCrssInXTokenToLpInFarm(
    //                 address(pool.lpToken),
    //                 nodes,
    //                 accumCrss,
    //                 feeParams.stakeholders
    //             );
    //         }
    //         startRewardCycle(pool, user, _msgSender, nodes, feeParams, newLpAmount, true); // true: addNotSubract

    //         user.accumulated = 0;
    //     }

    //     if (crssToPay > 0) {
    //         ICrssToken(nodes.token).transferDirectSafe(nodes.xToken, feeParams.stakeholders, crssToPay);
    //     }
    // }

    function calcTotalAlloc(PoolInfo[] storage poolInfo) internal view returns (uint256 totalAllocPoint) {
        uint256 length = poolInfo.length;
        uint256 points;
        for (uint256 pid = 0; pid < length; ++pid) {
            points = points + poolInfo[pid].allocPoint;
        }
        totalAllocPoint = points;
    }

    function setPool(
        PoolInfo[] storage poolInfo,
        uint256 pid,
        uint256 _allocPoint,
        uint256 _depositFeeRate,
        uint256 _withdrawLock
    ) external returns (uint256 totalAllocPoint) {
        PoolInfo storage pool = poolInfo[pid];
        pool.allocPoint = _allocPoint;
        pool.depositFeeRate = _depositFeeRate;
        pool.withdrawLock = _withdrawLock;

        totalAllocPoint = calcTotalAlloc(poolInfo);
        require(_allocPoint < 100, "Invalid allocPoint");
    }

    function addPool(
        uint256 _allocPoint,
        address _lpToken,
        uint256 _depositFeeRate,
        uint256 _withdrawLock,
        uint256 startBlock,
        PoolInfo[] storage poolInfo
    ) external returns (uint256 totalAllocPoint) {
        poolInfo.push(buildStandardPool(_lpToken, _allocPoint, startBlock, _depositFeeRate, _withdrawLock));

        totalAllocPoint = calcTotalAlloc(poolInfo);
        require(_allocPoint < 100, "Invalid allocPoint");
    }

    function getMultiplier(
        uint256 _from,
        uint256 _to,
        uint256 bonusMultiplier
    ) public pure returns (uint256) {
        return (_to - _from) * bonusMultiplier;
    }

    /**
     * @dev Mint rewards, and increase the pool's accCrssPerShare, accordingly.
     * accCrssPerShare: the amount of rewards that a user would have gaind NOW
     * if they had maintained 1e12 LP tokens as user.amount since the very beginning.
     */

    function updatePool(
        PoolInfo storage pool,
        FarmParams storage farmParams,
        Nodes storage nodes,
        FeeStores storage feeStores
    ) public {
        if (pool.lastRewardBlock < block.number) {
            // lpSupply includes comp.bulk amount.
            uint256 lpSupply = pool.lpToken.balanceOf(address(this));
            if (0 < pool.allocPoint && 0 < lpSupply) {
                uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number, farmParams.bonusMultiplier);
                uint256 crssReward = (multiplier * farmParams.crssPerBlock * pool.allocPoint) /
                    farmParams.totalAllocPoint;
                // Mint 8% to dev wallet
                uint256 teamEmission = (crssReward * 8) / 100;
                crssReward -= teamEmission;
                ICrssToken(nodes.token).mint(feeStores.dev, teamEmission);
                ICrssToken(nodes.token).mint(nodes.xToken, crssReward);
                pool.reward = crssReward; // used as a checksum
                pool.accCrssPerShare += ((crssReward * 1e12) / lpSupply);
            } else {
                pool.reward = 0;
            }
            pool.lastRewardBlock = block.number;
        } else {
            pool.reward = 0;
        }
    }

    function pendingCrss(
        PoolInfo storage pool,
        UserInfo storage user,
        FarmParams storage farmParams
    ) public view returns (uint256) {
        uint256 accCrssPerShare = pool.accCrssPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number, farmParams.bonusMultiplier);
            uint256 crssReward = (multiplier * farmParams.crssPerBlock * pool.allocPoint) / farmParams.totalAllocPoint;
            accCrssPerShare += ((crssReward * 1e12) / lpSupply);
        }
        return (getRewardPayroll(pool, user) * accCrssPerShare) / 1e12 - user.rewardDebt;
    }

    function pendingPerBlock(
        PoolInfo storage pool,
        UserInfo storage user,
        FarmParams storage farmParams
    ) public view returns (uint256) {
        uint256 accCrssPerShare = pool.accCrssPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(block.number - 1, block.number, farmParams.bonusMultiplier);
            uint256 crssReward = (multiplier * farmParams.crssPerBlock * pool.allocPoint) / farmParams.totalAllocPoint;
            accCrssPerShare += ((crssReward * 1e12) / lpSupply);
        }
        return (getRewardPayroll(pool, user) * accCrssPerShare) / 1e12 - user.rewardDebt;
    }

    function finishRewardCycle(
        PoolInfo storage pool,
        UserInfo storage user,
        address msgSender,
        FarmFeeParams storage feeParams,
        Nodes storage nodes,
        FarmParams storage farmParams,
        FeeStores storage feeStores
    ) public {
        updatePool(pool, farmParams, nodes, feeStores);
        if (pool.reward > 0) {
            payReferralComission(pool, user, msgSender, feeParams, nodes);
            //userShare = getRewardPayroll(pool, user);
            takePendingCollectively(pool, feeParams, nodes, false); // subPools' bulk and accPerShare.. periodic: false
            pool.reward = 0;
        }

        takeIndividualReward(pool, user);
    }

    function finishRewardCycle2(
        PoolInfo storage pool,
        UserInfo storage user,
        UserRewardBehavior memory behavior,
        address msgSender,
        FarmFeeParams storage feeParams,
        Nodes storage nodes,
        FarmParams storage farmParams,
        FeeStores storage feeStores
    ) public {
        require(behavior.crssBusd != address(0), "CrssBusd missing");
        (uint256 reserve0, uint256 reserve1, ) = ICrossPair(behavior.crssBusd).getReserves();
        (uint256 reserveCrss, uint256 reserveBusd) = ICrossPair(behavior.crssBusd).token0() == nodes.token
            ? (reserve0, reserve1)
            : (reserve1, reserve0);

        // We know both Crss and Busd has a decimal of 18.
        uint256 pendingEstimate = ((behavior.pendingCrss +
            behavior.pendingPerBlock *
            (block.number - behavior.blockNo)) * reserveBusd) / reserveCrss;
        uint256 collectiveAssets = (behavior.collectiveCrss * reserveBusd) / reserveCrss;

        uint256 threshold = behavior.thresholdBusdWei > 0 ? behavior.thresholdBusdWei : 50e18;
        if (pendingEstimate > threshold) {
            // if larger than 50 usd

            updatePool(pool, farmParams, nodes, feeStores);
            if (pool.reward > 0) {
                takePendingCollectively(pool, feeParams, nodes, false); // subPools' bulk and accPerShare.. periodic: false
                pool.reward = 0;
            }
            takeIndividualReward(pool, user);
        } else if (collectiveAssets > threshold) {
            // if larger than 50 usd
            takeIndividualReward(pool, user);
        }
    }

    // Save code size.
    // function finishRewardCycleForCollectAccum(
    //     PoolInfo storage pool,
    //     UserInfo storage user,
    //     address msgSender,
    //     FarmFeeParams storage feeParams,
    //     Nodes storage nodes,
    //     FarmParams storage farmParams,
    //     FeeStores storage feeStores
    // ) public {
    //     if ( (user.collectOption == CollectOption.OffOn || user.collectOption == CollectOption.OffOff) && user.amount > 0 ) {
    //         updatePool(pool, farmParams, nodes, feeStores);
    //         if (pool.reward > 0) {
    //             payReferralComission(pool, user, msgSender, feeParams, nodes);
    //             uint256 userShare = getRewardPayroll(pool, user);
    //             takePendingCollectively(pool, feeParams, nodes, false); // subPools' bulk and accPerShare.. periodic: false
    //             takeIndividualReward(pool, user, userShare);
    //             pool.reward = 0;
    //         }
    //     }
    // }

    function getUserState(
        address msgSender,
        uint256 pid,
        PoolInfo[] storage poolInfo,
        mapping(uint256 => mapping(address => UserInfo)) storage userInfo,
        Nodes storage nodes,
        FarmParams storage farmParams,
        uint256 vestMonths
    ) external view returns (UserState memory userState) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msgSender];
        userState.behavior.blockNo = block.number;

        userState.behavior.pendingCrss = pendingCrss(pool, user, farmParams);
        userState.behavior.pendingPerBlock = pendingPerBlock(pool, user, farmParams);
        userState.behavior.collectiveCrss = getCollectiveRewards(pool, user, nodes);
        userState.behavior.rewardPayroll = getRewardPayroll(pool, user);

        userState.assets.collectOption = uint256(user.collectOption);
        userState.assets.deposit = user.amount;
        userState.assets.depositList = user.depositList;
        userState.assets.accRewards = user.accumulated;
        userState.assets.totalVest = getTotalVestPrincipals(user.vestList);
        userState.assets.totalMatureVest = getTotalMatureVestPieces(user.vestList, vestMonths);
        // userState.assets.lpBalance = pool.lpToken.balanceOf(msgSender);
        // userState.assets.crssBalance = ICrssToken(nodes.token).balanceOf(msgSender);
        // for (pid = 0; pid < poolInfo.length; pid++) {
        //     userState.assets.totalAccRewards += userInfo[pid][msgSender].accumulated;
        // }
    }

    function getSubPooledCrss(PoolInfo storage pool, UserInfo storage user)
        external
        view
        returns (SubPooledCrss memory spc)
    {
        if (user.collectOption == CollectOption.OnOff && user.amount > 0) {} else if (
            user.collectOption == CollectOption.OnOn && user.amount > 0
        ) {
            spc.toVest = (user.amount * pool.OnOn.Vest.accPerShare) / 1e12 - user.debt2;
        } else if (user.collectOption == CollectOption.OffOn && user.amount > 0) {
            spc.toVest = (user.amount * pool.OffOn.Vest.accPerShare) / 1e12 - user.debt1;
            spc.toAccumulate = (user.amount * pool.OffOn.Accum.accPerShare) / 1e12 - user.debt2;
        } else if (user.collectOption == CollectOption.OffOff && user.amount > 0) {
            spc.toAccumulate = (user.amount * pool.OffOff.Accum.accPerShare) / 1e12 - user.debt1;
        }
    }

    function payDepositFeeLPFromFarm(
        PoolInfo storage pool,
        uint256 amount,
        FeeStores storage feeStores
    ) external returns (uint256 feePaid) {
        if (pool.depositFeeRate > 0) {
            feePaid = (amount * pool.depositFeeRate) / FeeMagnifier;
            pool.lpToken.safeTransfer(feeStores.accountant, feePaid);
        }
    }

    function payDepositFeeCrssFromXCrss(
        PoolInfo storage pool,
        address crssToken,
        address xToken,
        uint256 amount,
        FeeStores storage feeStores
    ) external returns (uint256 feePaid) {
        if (pool.depositFeeRate > 0) {
            feePaid = (amount * pool.depositFeeRate) / FeeMagnifier;
            ICrssToken(crssToken).transferDirectSafe(xToken, feeStores.accountant, feePaid);
        }
    }

    function periodicPatrol(
        PoolInfo[] storage poolInfo,
        FarmParams storage farmParams,
        FarmFeeParams storage feeParams,
        Nodes storage nodes,
        uint256 lastPatrolRound,
        uint256 patrolCycle,
        FeeStores storage feeStores
    ) external returns (uint256 newLastPatrolRound) {
        uint256 currRound = block.timestamp / patrolCycle;
        if (lastPatrolRound < currRound) {
            // do periodicPatrol
            for (uint256 pid; pid < poolInfo.length; pid++) {
                PoolInfo storage pool = poolInfo[pid];
                updatePool(pool, farmParams, nodes, feeStores);
                if (pool.reward > 0) {
                    takePendingCollectively(pool, feeParams, nodes, true); // periodic: true
                    pool.reward = 0;
                }
            }
            newLastPatrolRound = currRound;
        }
    }

    function pullFromUser(
        address tokenToPull,
        address userAddr,
        uint256 amount,
        address crssToken
    ) external returns (uint256 arrived) {
        uint256 oldBalance = IERC20(tokenToPull).balanceOf(address(this));
        if (tokenToPull == crssToken) {
            ICrssToken(tokenToPull).transferDirectSafe(userAddr, address(this), amount);
        } else {
            TransferHelper.safeTransferFrom(tokenToPull, userAddr, address(this), amount);
        }
        uint256 newBalance = IERC20(tokenToPull).balanceOf(address(this));
        arrived = newBalance - oldBalance;
    }

    function pushToUser(
        address tokenToPush,
        address userAddr,
        uint256 amount,
        address crssToken
    ) public returns (uint256 arrived) {
        if (tokenToPush == crssToken) {
            ICrssToken(crssToken).transferDirectSafe(address(this), userAddr, amount);
        } else {
            TransferHelper.safeTransfer(tokenToPush, userAddr, amount);
        }
    }

    function buildStandardPool(
        address lp,
        uint256 allocPoint,
        uint256 startBlock,
        uint256 depositFeeRate,
        uint256 withdrawLock
    ) public view returns (PoolInfo memory pool) {
        pool = PoolInfo({
            lpToken: IERC20(lp),
            allocPoint: allocPoint,
            lastRewardBlock: (block.number > startBlock ? block.number : startBlock),
            accCrssPerShare: 0,
            depositFeeRate: depositFeeRate,
            withdrawLock: withdrawLock * month,
            reward: 0,
            OnOff: Struct_OnOff(0, SubPool(0, 0), SubPool(0, 0)),
            OnOn: Struct_OnOn(0, SubPool(0, 0), SubPool(0, 0), SubPool(0, 0)),
            OffOn: Struct_OffOn(0, SubPool(0, 0), SubPool(0, 0)),
            OffOff: Struct_OffOff(0, SubPool(0, 0))
        });
    }

    // function migrate(PoolInfo storage pool, IMigratorChef migrator) external {
    //     require(address(migrator) != address(0), "migrate: no migrator");
    //     IERC20 lpToken = pool.lpToken;
    //     uint256 bal = lpToken.balanceOf(address(this));
    //     lpToken.safeApprove(address(migrator), bal);
    //     IERC20 newLpToken = migrator.migrate(lpToken);
    //     require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
    //     pool.lpToken = newLpToken;
    // }
}

//  1  function Dijkstra(Graph, source):
//  2
//  3      for each vertex v in Graph.Vertices:
//  4          dist[v] ← INFINITY
//  5          prev[v] ← UNDEFINED
//  6          add v to Q
//  7      dist[source] ← 0
//  8
//  9      while Q is not empty:
// 10          u ← vertex in Q with min dist[u]
// 11          remove u from Q
// 12
// 13          for each neighbor v of u still in Q:
// 14              alt ← dist[u] + Graph.Edges(u, v)
// 15              if alt < dist[v]:
// 16                  dist[v] ← alt
// 17                  prev[v] ← u
// 18
// 19      return dist[], prev[]

// 1  S ← empty sequence
// 2  u ← target
// 3  if prev[u] is defined or u = source:          // Do something only if the vertex is reachable
// 4      while u is defined:                       // Construct the shortest path with a stack S
// 5          insert u at the beginning of S        // Push the vertex onto the stack
// 6          u ← prev[u]                           // Traverse from target to source

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./math/SafeMath.sol";
import "../core/interfaces/ICrossPair.sol";
import "../farm/interfaces/ICrssToken.sol";
import "../session/interfaces/IConstants.sol";
import "../libraries/utils/TransferHelper.sol";
import "hardhat/console.sol";

library CrossLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "CrossLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "CrossLibrary: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"3072ceae68369bfde002753bac665d189287fcdc6b837988c69a30cdbf0bee7c" // init code hash
                        )
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = ICrossPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "CrossLibrary: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "CrossLibrary: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "CrossLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "CrossLibrary: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn.mul(9983); // 0.17% for LP providers.
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "CrossLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "CrossLibrary: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn.mul(amountOut).mul(10000);
        uint256 denominator = reserveOut.sub(amountOut).mul(9983); // 0.17% for LP providers.
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "CrossLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "CrossLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

    function transferFeesFrom(
        address token,
        address payer,
        uint256 principal,
        FeeRates memory rates,
        FeeStores memory feeStores,
        address crssToken,
        bool isFrom
    ) internal returns (uint256 feesPaid) {
        uint256 fee;
        if (principal != 0) {
            if (rates.accountant != 0) {
                fee = (principal * rates.accountant) / FeeMagnifier;
                if (isFrom) {
                    lightTransferFrom(token, payer, feeStores.accountant, fee, crssToken);
                } else {
                    lightTransfer(token, feeStores.accountant, fee, crssToken);
                }
                feesPaid += fee;
            }
        }
    }

    function lightTransferFrom(
        address tokenTransfer,
        address sender,
        address recipient,
        uint256 amount,
        address crssToken
    ) internal {
        if (tokenTransfer == crssToken) {
            ICrssToken(tokenTransfer).transferDirectSafe(sender, recipient, amount);
        } else {
            TransferHelper.safeTransferFrom(tokenTransfer, sender, recipient, amount);
        }
    }

    function lightTransfer(
        address tokenTransfer,
        address recipient,
        uint256 amount,
        address crssToken
    ) internal {
        if (tokenTransfer == crssToken) {
            ICrssToken(tokenTransfer).transferDirectSafe(address(this), recipient, amount);
        } else {
            TransferHelper.safeTransfer(tokenTransfer, recipient, amount);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMigratorChef {
    // Perform LP token migration from legacy CrosswiseSwap to CrssSwap.
    // Take the current LP token address and return the new LP token address.
    // Migrator should have full access to the caller's LP token.
    // Return the new LP token address.
    //
    // XXX Migrator must have allowance access to CrosswiseSwap LP tokens.
    // CrssSwap must mint EXACTLY the same amount of CrssSwap LP tokens or
    // else something bad will happen. Traditional CrosswiseSwap does not
    // do that so be careful!
    function migrate(IERC20 token) external returns (IERC20);
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../session/Node.sol";
import "./interfaces/IXCrssToken.sol";
import "./interfaces/ICrssToken.sol";
import "../libraries/math/SafeMath.sol";

// xCrssToken with Governance.
contract xCrssToken is Node, Ownable, IXCrssToken, ERC20 {
    using SafeMath for uint256;

    // Safe cake transfer function, just in case if rounding error causes pool to not have enough CAKEs.
    function safeCrssTransfer(address _to, uint256 _amount) public override {
        require(msg.sender == nodes.farm, "Forbidden");

        uint256 cakeBal = ICrssToken(nodes.token).balanceOf(address(this));
        if (_amount > cakeBal) {
            ICrssToken(nodes.token).transfer(_to, cakeBal);
        } else {
            ICrssToken(nodes.token).transfer(_to, _amount);
        }
    }

    function getOwner() public view override(IXCrssToken, Node) virtual returns (address) {
        return owner();
    }

    constructor(
        string memory name,
        string memory symbol
    )  Ownable() ERC20(name, symbol) Node(NodeType.XToken) {
   }

    // Copied and modified from YAM code:
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol
    // Which is copied and modified from COMPOUND:
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol

    mapping(address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping(address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping(address => uint256) public nonces;

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator) external view returns (address) {
        return _delegates[delegator];
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 domainSeparator = keccak256(
            abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), getChainId(), address(this))
        );

        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "CRSS::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "CRSS::delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "CRSS::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256) {
        require(blockNumber < block.number, "CRSS::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying CRSSs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {
        uint32 blockNumber = safe32(block.number, "CRSS::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

enum ActionType {
    None,
    Transfer,
    Swap,
    AddLiquidity,
    RemoveLiquidity,
    Deposit,
    Withdraw,
    CompoundAccumulated,
    VestAccumulated,
    HarvestAccumulated,
    StakeAccumulated,
    MassHarvestRewards,
    MassStakeRewards,
    MassCompoundRewards,
    WithdrawVest,
    UpdatePool,
    EmergencyWithdraw,
    SwitchCollectOption,
    HarvestRepay
}

uint256 constant NumberSessionTypes = 19;
uint256 constant CrssPoolAllocPercent = 25;
uint256 constant CompensationPoolAllocPercent = 2;

struct ActionParams {
    ActionType actionType;
    uint256 session;
    uint256 lastSession;
    bool isUserAction;
}

struct FeeRates {
    uint32 accountant;
}
struct FeeStores {
    address accountant;
    address dev;
}

struct PairSnapshot {
    address pair;
    address token0;
    address token1;
    uint256 reserve0;
    uint256 reserve1;
    uint8 decimal0;
    uint8 decimal1;
}

enum ListStatus {
    None,
    Cleared,
    Enlisted,
    Delisted
}

struct Pair {
    address token0;
    address token1;
    ListStatus status;
}

uint256 constant FeeMagnifierPower = 5;
uint256 constant FeeMagnifier = uint256(10)**FeeMagnifierPower;
uint256 constant SqaureMagnifier = FeeMagnifier * FeeMagnifier;
uint256 constant LiquiditySafety = 1e2;

address constant BUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; // BSC testnet
// address constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // BSC mainnet
// address constant BUSD = 0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82; // Hardhat chain, with my test script.

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./IConstants.sol";

struct Nodes {
    address token;
    address center;
    address maker;
    address taker;
    address farm;
    address factory;
    address xToken;
    address repay;
}

enum NodeType {
    Token,
    Center,
    Maker,
    Taker,
    Farm,
    Factory,
    XToken,
    Repay
}

interface INode {
    function pairs(address lp) external view returns (address token0, address token1, ListStatus status);
    function pairFor(address tokenA, address tokenB) external view returns (address lp);

    function wire(address _prevNode, address _nextNode) external;
    function setNode(NodeType nodeType, address node, address caller) external;
    function changePairStatus(address pair, address token0, address token1, ListStatus status, address caller) external;
    function setFeeStores(FeeStores memory _feeStores, address caller) external;
    function setFeeRates(ActionType _sessionType, FeeRates memory _feeRates, address caller) external;
    function begin(address caller) external;
    
    event SetNode(NodeType nodeType, address node);
    event ChangePairStatus(address pair, address tokenA, address tokenB, ListStatus status);
    event DeenlistToken(address token, address msgSender);
    event SetFeeStores(FeeStores _feeStores);
    event SetFeeRates(ActionType _sessionType, FeeRates _feeRates);
    event Begin();
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./IConstants.sol";
interface ISessionRegistrar {

    function registerAction(ActionType actionType,  bool blockReentry) external returns (ActionParams memory actionParams);
    function unregisterAction() external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./IConstants.sol";
import "./ISessionRegistrar.sol";
import "./ISessionFees.sol";

interface ISessionManager {

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./IConstants.sol";
interface ISessionFees {
    function payFeeCrssLogic(address account, uint256 principal, FeeRates calldata rates, bool fromAllowance) external returns (uint256 feesPaid);
}

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

/**
 * a contract must implement this interface in order to support relayed transaction.
 * It is better to inherit the BaseRelayRecipient as its implementation.
 */
abstract contract IRelayRecipient {
    /**
     * return if the forwarder is trusted to forward relayed transactions to us.
     * the forwarder is required to verify the sender's signature, and verify
     * the call is not a replay.
     */
    function isTrustedForwarder(address forwarder) public view virtual returns (bool);

    /**
     * return the sender of this call.
     * if the call came through our trusted forwarder, then the real sender is appended as the last 20 bytes
     * of the msg.data.
     * otherwise, return `msg.sender`
     * should be used in the contract anywhere instead of msg.sender
     */
    function _msgSender() internal view virtual returns (address payable);
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IPancakePair {
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);
    function permit(address owner, address spender, uint256 value, uint256 deadline,
        uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In,
        uint256 amount0Out, uint256 amount1Out, address indexed to );
    event Sync(uint112 reserve0, uint112 reserve1);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves()
        external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./IPancakePair.sol";
import "../../session/interfaces/IConstants.sol";

interface ICrossPair is IPancakePair {
    function initialize(address, address) external;
    function setNodes(address token, address maker, address taker, address farm) external;
    function status() external view returns (ListStatus);
    function changeStatus(ListStatus _status) external;
    function sim_burn(uint256 liquidity) external view returns (uint256 amount0, uint256 amount1);
}