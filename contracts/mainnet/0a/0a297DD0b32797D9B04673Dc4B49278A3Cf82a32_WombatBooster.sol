// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./Interfaces/ISmartConvertor.sol";
import "./Interfaces/IWombatBooster.sol";
import "./Interfaces/IWombatVoterProxy.sol";
import "./Interfaces/IDepositToken.sol";
import "./Interfaces/IWomDepositor.sol";
import "./Interfaces/IQuollToken.sol";
import "./Interfaces/IBaseRewardPool.sol";
import "@shared/lib-contracts/contracts/Dependencies/TransferHelper.sol";

contract WombatBooster is IWombatBooster, OwnableUpgradeable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using TransferHelper for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    address public wom;

    uint256 public vlQuoIncentive; // incentive to quo lockers
    uint256 public qWomIncentive; //incentive to wom stakers
    uint256 public quoIncentive; //incentive to quo stakers
    uint256 public platformFee; //possible fee to build treasury
    uint256 public constant MaxFees = 2500;
    uint256 public constant FEE_DENOMINATOR = 10000;

    address public voterProxy;
    address public quo;
    address public vlQuo;
    address public treasury;
    address public quoRewardPool; //quo reward pool
    address public qWomRewardPool; //qWom rewards(wom)

    bool public isShutdown;

    struct PoolInfo {
        address lptoken;
        address token;
        uint256 masterWombatPid;
        address rewardPool;
        bool shutdown;
    }

    //index(pid) -> pool
    PoolInfo[] public override poolInfo;

    address public womDepositor;
    address public qWom;

    address public smartConvertor;

    uint256 public earmarkIncentive;

    mapping(uint256 => address) public pidToMasterWombat;

    mapping(uint256 => EnumerableSet.AddressSet) pidToRewardTokens;

    mapping(uint256 => mapping(address => uint256)) public pidToPendingRewards;

    bool public earmarkOnOperation;

    function initialize() public initializer {
        __Ownable_init();
    }

    /// SETTER SECTION ///

    function setParams(
        address _wom,
        address _voterProxy,
        address _womDepositor,
        address _qWom,
        address _quo,
        address _vlQuo,
        address _quoRewardPool,
        address _qWomRewardPool,
        address _treasury
    ) external onlyOwner {
        require(voterProxy == address(0), "params has already been set");

        require(_wom != address(0), "invalid _wom!");
        require(_voterProxy != address(0), "invalid _voterProxy!");
        require(_womDepositor != address(0), "invalid _womDepositor!");
        require(_qWom != address(0), "invalid _qWom!");
        require(_quo != address(0), "invalid _quo!");
        require(_vlQuo != address(0), "invalid _vlQuo!");
        require(_quoRewardPool != address(0), "invalid _quoRewardPool!");
        require(_qWomRewardPool != address(0), "invalid _qWomRewardPool!");
        require(_treasury != address(0), "invalid _treasury!");

        isShutdown = false;

        wom = _wom;

        voterProxy = _voterProxy;
        womDepositor = _womDepositor;
        qWom = _qWom;
        quo = _quo;
        vlQuo = _vlQuo;

        quoRewardPool = _quoRewardPool;
        qWomRewardPool = _qWomRewardPool;

        treasury = _treasury;

        vlQuoIncentive = 500;
        qWomIncentive = 1000;
        quoIncentive = 100;
        platformFee = 100;
    }

    function setVlQuo(address _vlQuo) external onlyOwner {
        require(_vlQuo != address(0), "invalid _vlQuo!");

        vlQuo = _vlQuo;

        emit VlQuoAddressChanged(_vlQuo);
    }

    function setFees(
        uint256 _vlQuoIncentive,
        uint256 _qWomIncentive,
        uint256 _quoIncentive,
        uint256 _platformFee
    ) external onlyOwner {
        uint256 total = _qWomIncentive
            .add(_vlQuoIncentive)
            .add(_quoIncentive)
            .add(_platformFee);
        require(total <= MaxFees, ">MaxFees");

        //values must be within certain ranges
        require(
            _vlQuoIncentive >= 0 && _vlQuoIncentive <= 700,
            "invalid _vlQuoIncentive"
        );
        require(
            _qWomIncentive >= 800 && _qWomIncentive <= 1500,
            "invalid _qWomIncentive"
        );
        require(
            _quoIncentive >= 0 && _quoIncentive <= 500,
            "invalid _quoIncentive"
        );
        require(
            _platformFee >= 0 && _platformFee <= 1000,
            "invalid _platformFee"
        );

        vlQuoIncentive = _vlQuoIncentive;
        qWomIncentive = _qWomIncentive;
        quoIncentive = _quoIncentive;
        platformFee = _platformFee;
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function setSmartConvertor(address _smartConvertor) external onlyOwner {
        smartConvertor = _smartConvertor;
    }

    function setEarmarkIncentive(uint256 _earmarkIncentive) external onlyOwner {
        require(
            _earmarkIncentive >= 10 && _earmarkIncentive <= 100,
            "invalid _earmarkIncentive"
        );
        earmarkIncentive = _earmarkIncentive;
    }

    function setEarmarkOnOperation(bool _earmarkOnOperation)
        external
        onlyOwner
    {
        earmarkOnOperation = _earmarkOnOperation;
    }

    /// END SETTER SECTION ///

    function poolLength() external view override returns (uint256) {
        return poolInfo.length;
    }

    //create a new pool
    function addPool(
        address _masterWombat,
        uint256 _masterWombatPid,
        address _token,
        address _rewardPool
    ) external onlyOwner returns (bool) {
        require(!isShutdown, "!add");

        //the next pool's pid
        uint256 pid = poolInfo.length;

        // config wom rewards
        IBaseRewardPool(_rewardPool).setParams(address(this), pid, _token, wom);

        //add the new pool
        poolInfo.push(
            PoolInfo({
                lptoken: _masterWombat == address(0)
                    ? IWombatVoterProxy(voterProxy).getLpToken(_masterWombatPid)
                    : IWombatVoterProxy(voterProxy).getLpTokenV2(
                        _masterWombat,
                        _masterWombatPid
                    ),
                token: _token,
                masterWombatPid: _masterWombatPid,
                rewardPool: _rewardPool,
                shutdown: false
            })
        );

        if (_masterWombat != address(0)) {
            pidToMasterWombat[pid] = _masterWombat;
        }

        return true;
    }

    //shutdown pool
    function shutdownPool(uint256 _pid) public onlyOwner returns (bool) {
        PoolInfo storage pool = poolInfo[_pid];
        require(!pool.shutdown, "already shutdown!");

        //withdraw from gauge
        address[] memory rewardTokens;
        uint256[] memory rewardAmounts;
        if (pidToMasterWombat[_pid] == address(0)) {
            (rewardTokens, rewardAmounts) = IWombatVoterProxy(voterProxy)
                .withdrawAll(pool.masterWombatPid);
        } else {
            (rewardTokens, rewardAmounts) = IWombatVoterProxy(voterProxy)
                .withdrawAllV2(pidToMasterWombat[_pid], pool.masterWombatPid);
        }
        _updatePendingRewards(_pid, rewardTokens, rewardAmounts);

        // rewards are claimed when withdrawing
        _earmarkRewards(_pid, address(0));

        pool.shutdown = true;
        return true;
    }

    //shutdown this contract.
    //  unstake and pull all lp tokens to this address
    //  only allow withdrawals
    function shutdownSystem() external onlyOwner {
        isShutdown = true;

        for (uint256 i = 0; i < poolInfo.length; i++) {
            PoolInfo storage pool = poolInfo[i];
            if (pool.shutdown) {
                continue;
            }

            shutdownPool(i);
        }
    }

    function migrate(uint256[] calldata _pids, address _newMasterWombat)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _pids.length; i++) {
            uint256 pid = _pids[i];
            PoolInfo storage pool = poolInfo[pid];
            require(
                pidToMasterWombat[pid] != _newMasterWombat,
                "invalid _newMasterWombat"
            );

            (
                uint256 newPid,
                address[] memory rewardTokens,
                uint256[] memory rewardAmounts
            ) = IWombatVoterProxy(voterProxy).migrate(
                    pool.masterWombatPid,
                    pidToMasterWombat[pid],
                    _newMasterWombat
                );
            _updatePendingRewards(pid, rewardTokens, rewardAmounts);

            _earmarkRewards(pid, address(0));

            pidToMasterWombat[pid] = _newMasterWombat;
            pool.masterWombatPid = newPid;

            emit Migrated(pid, _newMasterWombat);
        }
    }

    //deposit lp tokens and stake
    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool _stake
    ) public override {
        require(!isShutdown, "shutdown");
        PoolInfo memory pool = poolInfo[_pid];
        require(pool.shutdown == false, "pool is closed");

        //send to proxy to stake
        address lptoken = pool.lptoken;
        IERC20(lptoken).safeTransferFrom(msg.sender, voterProxy, _amount);

        //stake
        address[] memory rewardTokens;
        uint256[] memory rewardAmounts;
        if (pidToMasterWombat[_pid] == address(0)) {
            (rewardTokens, rewardAmounts) = IWombatVoterProxy(voterProxy)
                .deposit(pool.masterWombatPid, _amount);
        } else {
            (rewardTokens, rewardAmounts) = IWombatVoterProxy(voterProxy)
                .depositV2(
                    pidToMasterWombat[_pid],
                    pool.masterWombatPid,
                    _amount
                );
        }
        // rewards are claimed when depositing
        _updatePendingRewards(_pid, rewardTokens, rewardAmounts);

        if (earmarkOnOperation) {
            _earmarkRewards(_pid, address(0));
        }

        address token = pool.token;
        if (_stake) {
            //mint here and send to rewards on user behalf
            IDepositToken(token).mint(address(this), _amount);
            address rewardContract = pool.rewardPool;
            _approveTokenIfNeeded(token, rewardContract, _amount);
            IBaseRewardPool(rewardContract).stakeFor(msg.sender, _amount);
        } else {
            //add user balance directly
            IDepositToken(token).mint(msg.sender, _amount);
        }

        emit Deposited(msg.sender, _pid, _amount);
    }

    //deposit all lp tokens and stake
    function depositAll(uint256 _pid, bool _stake) external returns (bool) {
        address lptoken = poolInfo[_pid].lptoken;
        uint256 balance = IERC20(lptoken).balanceOf(msg.sender);
        deposit(_pid, balance, _stake);
        return true;
    }

    //withdraw lp tokens
    function _withdraw(
        uint256 _pid,
        uint256 _amount,
        address _from,
        address _to
    ) internal {
        PoolInfo memory pool = poolInfo[_pid];
        address lptoken = pool.lptoken;

        //remove lp balance
        address token = pool.token;
        IDepositToken(token).burn(_from, _amount);

        //pull from gauge if not shutdown
        // if shutdown tokens will be in this contract
        if (!pool.shutdown) {
            address[] memory rewardTokens;
            uint256[] memory rewardAmounts;
            if (pidToMasterWombat[_pid] == address(0)) {
                (rewardTokens, rewardAmounts) = IWombatVoterProxy(voterProxy)
                    .withdraw(pool.masterWombatPid, _amount);
            } else {
                (rewardTokens, rewardAmounts) = IWombatVoterProxy(voterProxy)
                    .withdrawV2(
                        pidToMasterWombat[_pid],
                        pool.masterWombatPid,
                        _amount
                    );
            }
            // rewards are claimed when withdrawing
            _updatePendingRewards(_pid, rewardTokens, rewardAmounts);

            if (earmarkOnOperation) {
                _earmarkRewards(_pid, address(0));
            }
        }

        //return lp tokens
        IERC20(lptoken).safeTransfer(_to, _amount);

        emit Withdrawn(_to, _pid, _amount);
    }

    //withdraw lp tokens
    function withdraw(uint256 _pid, uint256 _amount) public override {
        _withdraw(_pid, _amount, msg.sender, msg.sender);
    }

    //withdraw all lp tokens
    function withdrawAll(uint256 _pid) public {
        address token = poolInfo[_pid].token;
        uint256 userBal = IERC20(token).balanceOf(msg.sender);
        withdraw(_pid, userBal);
    }

    // disperse wom and extra rewards to reward contracts
    function _earmarkRewards(uint256 _pid, address _caller) internal {
        PoolInfo memory pool = poolInfo[_pid];
        //wom balance
        uint256 womBal = pidToPendingRewards[_pid][wom];
        emit WomClaimed(_pid, womBal);

        if (womBal > 0) {
            pidToPendingRewards[_pid][wom] = 0;

            uint256 vlQuoIncentiveAmount = womBal.mul(vlQuoIncentive).div(
                FEE_DENOMINATOR
            );
            uint256 qWomIncentiveAmount = womBal.mul(qWomIncentive).div(
                FEE_DENOMINATOR
            );
            uint256 quoIncentiveAmount = womBal.mul(quoIncentive).div(
                FEE_DENOMINATOR
            );

            uint256 earmarkIncentiveAmount = 0;
            if (_caller != address(0) && earmarkIncentive > 0) {
                earmarkIncentiveAmount = womBal.mul(earmarkIncentive).div(
                    FEE_DENOMINATOR
                );

                //send incentives for calling
                IERC20(wom).safeTransfer(_caller, earmarkIncentiveAmount);

                emit EarmarkIncentiveSent(
                    _pid,
                    _caller,
                    earmarkIncentiveAmount
                );
            }

            //send treasury
            if (platformFee > 0) {
                //only subtract after address condition check
                uint256 _platform = womBal.mul(platformFee).div(
                    FEE_DENOMINATOR
                );
                womBal = womBal.sub(_platform);
                IERC20(wom).safeTransfer(treasury, _platform);
            }

            //remove incentives from balance
            womBal = womBal
                .sub(vlQuoIncentiveAmount)
                .sub(qWomIncentiveAmount)
                .sub(quoIncentiveAmount)
                .sub(earmarkIncentiveAmount);

            //send wom to lp provider reward contract
            address rewardContract = pool.rewardPool;
            _approveTokenIfNeeded(wom, rewardContract, womBal);
            IRewards(rewardContract).queueNewRewards(wom, womBal);

            //check if there are extra rewards
            for (uint256 i = 0; i < pidToRewardTokens[_pid].length(); i++) {
                address bonusToken = pidToRewardTokens[_pid].at(i);
                if (bonusToken == wom) {
                    // wom was dispersed above
                    continue;
                }
                uint256 bonusTokenBalance = pidToPendingRewards[_pid][
                    bonusToken
                ];
                if (bonusTokenBalance > 0) {
                    if (AddressLib.isPlatformToken(bonusToken)) {
                        IRewards(rewardContract).queueNewRewards{
                            value: bonusTokenBalance
                        }(bonusToken, bonusTokenBalance);
                    } else {
                        _approveTokenIfNeeded(
                            bonusToken,
                            rewardContract,
                            bonusTokenBalance
                        );
                        IRewards(rewardContract).queueNewRewards(
                            bonusToken,
                            bonusTokenBalance
                        );
                    }
                    pidToPendingRewards[_pid][bonusToken] = 0;
                }
            }

            //send qWom to vlQuo
            if (vlQuoIncentiveAmount > 0) {
                uint256 qWomAmount = _convertWomToQWom(vlQuoIncentiveAmount);

                _approveTokenIfNeeded(qWom, vlQuo, qWomAmount);
                IRewards(vlQuo).queueNewRewards(qWom, qWomAmount);
            }

            //send wom to qWom reward contract
            if (qWomIncentiveAmount > 0) {
                _approveTokenIfNeeded(wom, qWomRewardPool, qWomIncentiveAmount);
                IRewards(qWomRewardPool).queueNewRewards(
                    wom,
                    qWomIncentiveAmount
                );
            }

            //send qWom to quo reward contract
            if (quoIncentiveAmount > 0) {
                uint256 qWomAmount = _convertWomToQWom(quoIncentiveAmount);

                _approveTokenIfNeeded(qWom, quoRewardPool, qWomAmount);
                IRewards(quoRewardPool).queueNewRewards(qWom, qWomAmount);
            }
        }
    }

    function earmarkRewards(uint256 _pid) external returns (bool) {
        require(!isShutdown, "shutdown");
        PoolInfo memory pool = poolInfo[_pid];
        require(pool.shutdown == false, "pool is closed");

        //claim wom and bonus token rewards
        address[] memory rewardTokens;
        uint256[] memory rewardAmounts;
        if (pidToMasterWombat[_pid] == address(0)) {
            (rewardTokens, rewardAmounts) = IWombatVoterProxy(voterProxy)
                .claimRewards(pool.masterWombatPid);
        } else {
            (rewardTokens, rewardAmounts) = IWombatVoterProxy(voterProxy)
                .claimRewardsV2(pidToMasterWombat[_pid], pool.masterWombatPid);
        }
        _updatePendingRewards(_pid, rewardTokens, rewardAmounts);

        _earmarkRewards(_pid, msg.sender);
        return true;
    }

    function getRewardTokensForPid(uint256 _pid)
        external
        view
        returns (address[] memory)
    {
        address[] memory rewardTokens = new address[](
            pidToRewardTokens[_pid].length()
        );
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            rewardTokens[i] = pidToRewardTokens[_pid].at(i);
        }
        return rewardTokens;
    }

    //callback from reward contract when wom is received.
    function rewardClaimed(
        uint256 _pid,
        address _account,
        address _token,
        uint256 _amount
    ) external override {
        address rewardContract = poolInfo[_pid].rewardPool;
        require(
            msg.sender == rewardContract || msg.sender == qWomRewardPool,
            "!auth"
        );

        if (_token != wom || isShutdown) {
            return;
        }

        //mint reward tokens
        IQuollToken(quo).mint(_account, _amount);
    }

    function _updatePendingRewards(
        uint256 _pid,
        address[] memory _rewardTokens,
        uint256[] memory _rewardAmounts
    ) internal {
        for (uint256 i = 0; i < _rewardTokens.length; i++) {
            address rewardToken = _rewardTokens[i];
            uint256 rewardAmount = _rewardAmounts[i];
            if (rewardToken == address(0) || rewardAmount == 0) {
                continue;
            }
            pidToRewardTokens[_pid].add(rewardToken);
            pidToPendingRewards[_pid][rewardToken] = pidToPendingRewards[_pid][
                rewardToken
            ].add(rewardAmount);
        }
    }

    function _convertWomToQWom(uint256 _amount) internal returns (uint256) {
        if (smartConvertor != address(0)) {
            _approveTokenIfNeeded(wom, smartConvertor, _amount);
            return ISmartConvertor(smartConvertor).deposit(_amount);
        } else {
            _approveTokenIfNeeded(wom, womDepositor, _amount);
            IWomDepositor(womDepositor).deposit(_amount, false);
            return _amount;
        }
    }

    function _approveTokenIfNeeded(
        address _token,
        address _to,
        uint256 _amount
    ) internal {
        if (IERC20(_token).allowance(address(this), _to) < _amount) {
            IERC20(_token).safeApprove(_to, 0);
            IERC20(_token).safeApprove(_to, type(uint256).max);
        }
    }

    receive() external payable {}
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface ISmartConvertor {
    function deposit(uint256 _amount) external returns (uint256 obtainedAmount);

    function depositFor(uint256 _amount, address _for)
        external
        returns (uint256 obtainedAmount);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IWombatBooster {
    function poolLength() external view returns (uint256);

    function poolInfo(uint256)
        external
        view
        returns (
            address,
            address,
            uint256,
            address,
            bool
        );

    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool _stake
    ) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function rewardClaimed(
        uint256,
        address,
        address,
        uint256
    ) external;

    event Deposited(
        address indexed _user,
        uint256 indexed _poolid,
        uint256 _amount
    );
    event Withdrawn(
        address indexed _user,
        uint256 indexed _poolid,
        uint256 _amount
    );
    event WomClaimed(uint256 _pid, uint256 _amount);
    event EarmarkIncentiveSent(
        uint256 _pid,
        address indexed _caller,
        uint256 _amount
    );

    event Migrated(uint256 _pid, address indexed _newMasterWombat);

    event VlQuoAddressChanged(address _vlQuo);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IWombatVoterProxy {
    function getLpToken(uint256) external view returns (address);

    function getLpTokenV2(address, uint256) external view returns (address);

    function getBonusTokens(uint256) external view returns (address[] memory);

    function getBonusTokensV2(address, uint256)
        external
        view
        returns (address[] memory);

    function deposit(uint256, uint256)
        external
        returns (address[] memory, uint256[] memory);

    function depositV2(
        address,
        uint256,
        uint256
    ) external returns (address[] memory, uint256[] memory);

    function withdraw(uint256, uint256)
        external
        returns (address[] memory, uint256[] memory);

    function withdrawV2(
        address,
        uint256,
        uint256
    ) external returns (address[] memory, uint256[] memory);

    function withdrawAll(uint256)
        external
        returns (address[] memory, uint256[] memory);

    function withdrawAllV2(address, uint256)
        external
        returns (address[] memory, uint256[] memory);

    function claimRewards(uint256)
        external
        returns (address[] memory, uint256[] memory);

    function claimRewardsV2(address, uint256)
        external
        returns (address[] memory, uint256[] memory);

    function balanceOfPool(uint256) external view returns (uint256);

    function balanceOfPoolV2(address, uint256) external view returns (uint256);

    function migrate(
        uint256,
        address,
        address
    )
        external
        returns (
            uint256,
            address[] memory,
            uint256[] memory
        );

    function lockWom(uint256) external;

    function vote(
        address[] calldata _lpVote,
        int256[] calldata _deltas,
        address[] calldata _rewarders,
        address _caller
    )
        external
        returns (
            address[][] memory rewardTokens,
            uint256[][] memory feeAmounts
        );

    function pendingBribeCallerFee(address[] calldata _pendingPools)
        external
        view
        returns (
            address[][] memory rewardTokens,
            uint256[][] memory callerFeeAmount
        );

    // --- Events ---
    event BoosterUpdated(address _booster);
    event DepositorUpdated(address _depositor);

    event Deposited(uint256 _pid, uint256 _amount);
    event DepositedV2(address _masterWombat, uint256 _pid, uint256 _amount);

    event Withdrawn(uint256 _pid, uint256 _amount);
    event WithdrawnV2(address _masterWombat, uint256 _pid, uint256 _amount);

    event RewardsClaimed(uint256 _pid, uint256 _amount);
    event RewardsClaimedV2(
        address _masterWombat,
        uint256 _pid,
        uint256 _amount
    );

    event BonusRewardsClaimed(
        uint256 _pid,
        address _bonusTokenAddress,
        uint256 _bonusTokenAmount
    );

    event BonusRewardsClaimedV2(
        address _masterWombat,
        uint256 _pid,
        address _bonusTokenAddress,
        uint256 _bonusTokenAmount
    );

    event WomLocked(uint256 _amount, uint256 _lockDays);
    event WomUnlocked(uint256 _slot);

    event Voted(
        address[] _lpVote,
        int256[] _deltas,
        address[] _rewarders,
        address _caller
    );
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IDepositToken {
    function mint(address _to, uint256 _amount) external;

    function burn(address _from, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IWomDepositor {
    function deposit(uint256, bool) external;

    event Deposited(address indexed _user, uint256 _amount);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IQuollToken {
    function mint(address _to, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./IRewards.sol";

interface IBaseRewardPool is IRewards {
    function setParams(
        address _booster,
        uint256 _pid,
        address _stakingToken,
        address _rewardToken
    ) external;

    function getReward(address) external;

    function withdrawFor(address _account, uint256 _amount) external;

    event BoosterUpdated(address _booster);
    event OperatorUpdated(address _operator);
    event Granted(address _address, bool _grant);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./AddressLib.sol";

library TransferHelper {

    using AddressLib for address;

    function safeTransferToken(
        address token,
        address to,
        uint value
    ) internal {
        if (token.isPlatformToken()) {
            safeTransferETH(to, value);
        } else {
            safeTransfer(IERC20(token), to, value);
        }
    }

    function safeTransferETH(
        address to,
        uint value
    ) internal {
        (bool success, ) = address(to).call{value: value}("");
        require(success, "TransferHelper: Sending ETH failed");
    }

    function balanceOf(address token, address addr) internal view returns (uint) {
        if (token.isPlatformToken()) {
            return addr.balance;
        } else {
            return IERC20(token).balanceOf(addr);
        }
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)'))) -> 0xa9059cbb
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)'))) -> 0x23b872dd
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransferFrom: transfer failed'
        );
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
import "../proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRewards {
    function stakingToken() external view returns (IERC20);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function stake(uint256) external;

    function stakeAll() external;

    function stakeFor(address, uint256) external;

    function withdraw(uint256) external;

    function withdrawAll() external;

    function donate(address, uint256) external payable;

    function queueNewRewards(address, uint256) external payable;

    function earned(address, address) external view returns (uint256);

    function getUserAmountTime(address) external view returns (uint256);

    function getRewardTokens() external view returns (address[] memory);

    function getRewardTokensLength() external view returns (uint256);

    function setAccess(address _address, bool _status) external;

    event RewardTokenAdded(address indexed _rewardToken);
    event RewardAdded(address indexed _rewardToken, uint256 _reward);
    event Staked(address indexed _user, uint256 _amount);
    event Withdrawn(address indexed _user, uint256 _amount);
    event RewardPaid(
        address indexed _user,
        address indexed _rewardToken,
        uint256 _reward
    );
    event AccessSet(address indexed _address, bool _status);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

library AddressLib {
    address public constant PLATFORM_TOKEN_ADDRESS =
        0xeFEfeFEfeFeFEFEFEfefeFeFefEfEfEfeFEFEFEf;

    function isPlatformToken(address addr) internal pure returns (bool) {
        return addr == PLATFORM_TOKEN_ADDRESS;
    }
}