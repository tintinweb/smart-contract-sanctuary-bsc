// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@shared/lib-contracts/contracts/Dependencies/TransferHelper.sol";
import "./Interfaces/IBribeManager.sol";
import "./Interfaces/IDelegateVotePool.sol";
import "./Interfaces/INativeZapper.sol";
import "./Interfaces/IVirtualBalanceRewardPool.sol";
import "./Interfaces/IVlQuoV2.sol";
import "./Interfaces/IWombatVoterProxy.sol";
import "./Interfaces/Wombat/IVoter.sol";
import "./Interfaces/Wombat/IVeWom.sol";

contract BribeManager is IBribeManager, OwnableUpgradeable {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using SafeERC20 for IERC20;

    IVoter public voter;
    IVeWom public veWom;

    IWombatVoterProxy public voterProxy;
    IVlQuoV2 public vlQuoV2;
    INativeZapper public nativeZapper;

    address public delegatePool;

    struct Pool {
        address lpToken;
        address rewarder;
        bool isActive;
    }

    address[] public pools;
    mapping(address => Pool) public poolInfos;

    mapping(address => uint256) public poolTotalVote;
    mapping(address => uint256) public userTotalVote;
    mapping(address => mapping(address => uint256)) public userVoteForPools; // unit = vlQuo

    uint256 public totalVlQuoInVote;
    uint256 public lastCastTimer;
    uint256 public castVotesCooldown;

    function initialize() public initializer {
        __Ownable_init();
    }

    function setParams(
        address _voter,
        address _voterProxy,
        address _vlQuoV2,
        address _nativeZapper,
        address _delegatePool
    ) external onlyOwner {
        require(address(voter) == address(0), "params have already been set");

        require(_voter != address(0), "invalid _voter!");
        require(_voterProxy != address(0), "invalid _voterProxy!");
        require(_vlQuoV2 != address(0), "invalid _vlQuoV2!");
        require(_nativeZapper != address(0), "invalid _nativeZapper!");
        require(_delegatePool != address(0), "invalid _delegatePool!");

        voter = IVoter(_voter);
        veWom = IVeWom(voter.veWom());

        voterProxy = IWombatVoterProxy(_voterProxy);
        vlQuoV2 = IVlQuoV2(_vlQuoV2);
        nativeZapper = INativeZapper(_nativeZapper);

        delegatePool = _delegatePool;

        castVotesCooldown = 60;
    }

    function getUserTotalVote(address _user)
        external
        view
        override
        returns (uint256)
    {
        return userTotalVote[_user];
    }

    function getUserVoteForPool(address _lp, address _user)
        public
        view
        override
        returns (uint256)
    {
        return userVoteForPools[_user][_lp];
    }

    function getUserVoteForPools(address[] calldata _lps, address _user)
        external
        view
        override
        returns (uint256[] memory votes)
    {
        uint256 length = _lps.length;
        votes = new uint256[](length);
        for (uint256 i; i < length; i++) {
            votes[i] = getUserVoteForPool(_lps[i], _user);
        }
    }

    function getTotalVoteForPools(address[] calldata _lps)
        external
        view
        returns (uint256[] memory vlQuoVotes)
    {
        uint256 length = _lps.length;
        vlQuoVotes = new uint256[](length);
        for (uint256 i; i < length; i++) {
            vlQuoVotes[i] = poolTotalVote[_lps[i]];
        }
    }

    function getPoolsLength() external view returns (uint256) {
        return pools.length;
    }

    function getVeWomVoteForLp(address _lp) public view returns (uint256) {
        return voter.getUserVotes(address(voterProxy), _lp);
    }

    function getVeWomVoteForLps(address[] calldata _lps)
        external
        view
        returns (uint256[] memory votes)
    {
        uint256 length = _lps.length;
        votes = new uint256[](length);
        for (uint256 i; i < length; i++) {
            votes[i] = getVeWomVoteForLp(_lps[i]);
        }
    }

    function usedVote() public view returns (uint256) {
        return veWom.usedVote(address(voterProxy));
    }

    function totalVotes() public view returns (uint256) {
        return veWom.balanceOf(address(voterProxy));
    }

    function remainingVotes() external view returns (uint256) {
        return totalVotes().sub(usedVote());
    }

    function addPool(address _lp, address _rewarder) external onlyOwner {
        require(_lp != address(0), "_lp ZERO ADDRESS");
        if (_lp != delegatePool) {
            (, , , , , address gaugeManager, ) = voter.infos(_lp);
            require(gaugeManager != address(0), "gaugeManager ZERO ADDRESS");
        }

        Pool memory pool = Pool({
            lpToken: _lp,
            rewarder: _rewarder,
            isActive: true
        });
        if (_lp != delegatePool) {
            pools.push(_lp); // we don't want the delegatePool in this array
        }
        poolInfos[_lp] = pool;
        emit PoolAdded(_lp, _rewarder);
    }

    /// @notice Changes the votes to zero for all pools. Only internal.
    function _resetVotes() internal {
        uint256 length = pools.length;
        address[] memory lpVote = new address[](length);
        int256[] memory votes = new int256[](length);
        address[] memory rewarders = new address[](length);
        for (uint256 i; i < length; i++) {
            Pool memory pool = poolInfos[pools[i]];
            lpVote[i] = pool.lpToken;
            votes[i] = -int256(getVeWomVoteForLp(pool.lpToken));
            rewarders[i] = pool.rewarder;
        }
        voterProxy.vote(lpVote, votes, rewarders, address(0));
        emit AllVoteReset();
    }

    function isPoolActive(address pool) external view override returns (bool) {
        return poolInfos[pool].isActive;
    }

    function deactivatePool(address _lp) external onlyOwner {
        poolInfos[_lp].isActive = false;
    }

    /// @notice Changes the votes to zero for all pools. Only internal.
    /// @dev This would entirely kill all votings
    function clearPools() external onlyOwner {
        _resetVotes();
        uint256 length = pools.length;
        for (uint256 i; i < length; i++) {
            poolInfos[pools[i]].isActive = false;
        }
        delete pools;
    }

    function removePool(uint256 _index) external onlyOwner {
        uint256 length = pools.length;
        pools[_index] = pools[length - 1];
        pools.pop();
    }

    function getUserLocked(address _user) public view returns (uint256) {
        return
            _user == delegatePool
                ? poolTotalVote[delegatePool]
                : vlQuoV2.balanceOf(_user);
    }

    /// @notice Vote on pools. Need to compute the delta prior to casting this.
    function vote(address[] calldata _lps, int256[] calldata _deltas)
        external
        override
    {
        uint256 length = _lps.length;
        int256 totalUserVote;
        for (uint256 i; i < length; i++) {
            Pool memory pool = poolInfos[_lps[i]];
            require(pool.isActive, "Not active");
            int256 delta = _deltas[i];
            totalUserVote = totalUserVote.add(delta);
            if (delta != 0) {
                if (delta > 0) {
                    poolTotalVote[pool.lpToken] = poolTotalVote[pool.lpToken]
                        .add(uint256(delta));
                    userTotalVote[msg.sender] = userTotalVote[msg.sender].add(
                        uint256(delta)
                    );
                    userVoteForPools[msg.sender][
                        pool.lpToken
                    ] = userVoteForPools[msg.sender][pool.lpToken].add(
                        uint256(delta)
                    );
                    IVirtualBalanceRewardPool(pool.rewarder).stakeFor(
                        msg.sender,
                        uint256(delta)
                    );
                } else {
                    poolTotalVote[pool.lpToken] = poolTotalVote[pool.lpToken]
                        .sub(uint256(-delta));
                    userTotalVote[msg.sender] = userTotalVote[msg.sender].sub(
                        uint256(-delta)
                    );
                    userVoteForPools[msg.sender][
                        pool.lpToken
                    ] = userVoteForPools[msg.sender][pool.lpToken].sub(
                        uint256(-delta)
                    );
                    IVirtualBalanceRewardPool(pool.rewarder).withdrawFor(
                        msg.sender,
                        uint256(-delta)
                    );
                }

                emit VoteUpdated(
                    msg.sender,
                    pool.lpToken,
                    userVoteForPools[msg.sender][pool.lpToken]
                );
            }
        }
        if (msg.sender != delegatePool) {
            // this already gets updated when a user vote for the delegate pool
            if (totalUserVote > 0) {
                totalVlQuoInVote = totalVlQuoInVote.add(uint256(totalUserVote));
            } else {
                totalVlQuoInVote = totalVlQuoInVote.sub(
                    uint256(-totalUserVote)
                );
            }
        }
        require(
            userTotalVote[msg.sender] <= getUserLocked(msg.sender),
            "Above vote limit"
        );
    }

    /// @notice Unvote from an inactive pool. This makes it so that deleting a pool, or changing a rewarder doesn't block users from withdrawing
    function unvote(address _lp) external override {
        Pool memory pool = poolInfos[_lp];
        uint256 currentVote = userVoteForPools[msg.sender][pool.lpToken];
        if (currentVote == 0) {
            return;
        }
        require(!pool.isActive, "Active");
        poolTotalVote[pool.lpToken] = poolTotalVote[pool.lpToken].sub(
            currentVote
        );
        userTotalVote[msg.sender] = userTotalVote[msg.sender].sub(currentVote);
        userVoteForPools[msg.sender][pool.lpToken] = 0;
        IVirtualBalanceRewardPool(pool.rewarder).withdrawFor(
            msg.sender,
            currentVote
        );
        if (msg.sender != delegatePool) {
            totalVlQuoInVote = totalVlQuoInVote.sub(currentVote);
        }

        emit VoteUpdated(
            msg.sender,
            pool.lpToken,
            userVoteForPools[msg.sender][pool.lpToken]
        );
    }

    /// @notice cast all pending votes
    /// @notice this function will be gas intensive, hence a fee is given to the caller
    function castVotes(bool _swapForNative)
        public
        returns (
            address[][] memory finalRewardTokens,
            uint256[][] memory finalFeeAmounts
        )
    {
        require(
            block.timestamp - lastCastTimer > castVotesCooldown,
            "Last cast too recent"
        );
        lastCastTimer = block.timestamp;
        uint256 length = pools.length;
        address[] memory lpVote = new address[](length);
        int256[] memory votes = new int256[](length);
        address[] memory rewarders = new address[](length);
        for (uint256 i; i < length; i++) {
            Pool memory pool = poolInfos[pools[i]];
            lpVote[i] = pool.lpToken;
            rewarders[i] = pool.rewarder;

            uint256 currentVote = getVeWomVoteForLp(pool.lpToken);
            uint256 targetVote = poolTotalVote[pool.lpToken]
                .mul(totalVotes())
                .div(totalVlQuoInVote);
            if (targetVote >= currentVote) {
                votes[i] = int256(targetVote.sub(currentVote));
            } else {
                votes[i] = int256(targetVote).sub(int256(currentVote));
            }
        }
        (
            address[][] memory rewardTokens,
            uint256[][] memory feeAmounts
        ) = voterProxy.vote(lpVote, votes, rewarders, msg.sender);

        finalRewardTokens = new address[][](length);
        finalFeeAmounts = new uint256[][](length);
        if (_swapForNative) {
            for (uint256 i = 0; i < length; i++) {
                finalRewardTokens[i] = new address[](1);
                finalRewardTokens[i][0] = AddressLib.PLATFORM_TOKEN_ADDRESS;
                finalFeeAmounts[i] = new uint256[](1);
                finalFeeAmounts[i][0] = finalFeeAmounts[i][0].add(
                    _swapFeesForNative(
                        rewardTokens[i],
                        feeAmounts[i],
                        msg.sender
                    )
                );
            }
        } else {
            for (uint256 i = 0; i < length; i++) {
                _forwardRewards(rewardTokens[i], feeAmounts[i]);
                finalRewardTokens[i] = rewardTokens[i];
                finalFeeAmounts[i] = feeAmounts[i];
            }
        }
    }

    /// @notice Cast a zero vote to harvest the bribes of selected pools
    /// @notice this function has a lesser importance than casting votes, hence no rewards will be given to the caller.
    function harvestPools(address[] calldata _lps) external {
        uint256 length = _lps.length;
        int256[] memory votes = new int256[](length);
        address[] memory rewarders = new address[](length);
        for (uint256 i; i < length; i++) {
            address lp = _lps[i];
            Pool memory pool = poolInfos[lp];
            rewarders[i] = pool.rewarder;
            votes[i] = 0;
        }
        voterProxy.vote(_lps, votes, rewarders, address(0));
    }

    /// @notice Harvests user rewards for each pool
    /// @notice If bribes weren't harvested, this might be lower than actual current value
    function getRewardForPools(address[] calldata _lps) external {
        uint256 length = _lps.length;
        for (uint256 i; i < length; i++) {
            if (_lps[i] == delegatePool) {
                IDelegateVotePool(delegatePool).getReward(msg.sender);
            } else {
                IVirtualBalanceRewardPool(poolInfos[_lps[i]].rewarder)
                    .getReward(msg.sender);
            }
        }
    }

    /// @notice Harvests user rewards for each pool where he has voted
    /// @notice If bribes weren't harvested, this might be lower than actual current value
    function getRewardAll()
        external
        override
        returns (
            address[][] memory rewardTokens,
            uint256[][] memory earnedRewards
        )
    {
        address[] memory delegatePoolRewardTokens;
        uint256[] memory delegatePoolRewardAmounts;
        if (userVoteForPools[msg.sender][delegatePool] > 0) {
            (
                delegatePoolRewardTokens,
                delegatePoolRewardAmounts
            ) = IDelegateVotePool(delegatePool).getReward(msg.sender);
        }
        uint256 length = pools.length;
        rewardTokens = new address[][](length + 1);
        earnedRewards = new uint256[][](length + 1);
        for (uint256 i; i < length; i++) {
            Pool memory pool = poolInfos[pools[i]];
            if (userVoteForPools[msg.sender][pool.lpToken] > 0) {
                rewardTokens[i] = IVirtualBalanceRewardPool(pool.rewarder)
                    .getRewardTokens();
                earnedRewards[i] = new uint256[](rewardTokens[i].length);
                for (uint256 j = 0; j < rewardTokens[i].length; j++) {
                    earnedRewards[i][j] = IVirtualBalanceRewardPool(
                        pool.rewarder
                    ).earned(msg.sender, rewardTokens[i][j]);
                }

                IVirtualBalanceRewardPool(pool.rewarder).getReward(msg.sender);
            }
        }

        rewardTokens[length] = delegatePoolRewardTokens;
        earnedRewards[length] = delegatePoolRewardAmounts;
    }

    function previewNativeAmountForCast(address[] calldata _lps)
        external
        view
        returns (uint256)
    {
        (
            address[][] memory rewardTokens,
            uint256[][] memory amounts
        ) = voterProxy.pendingBribeCallerFee(_lps);
        uint256 feeAmount = 0;
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            for (uint256 j = 0; j < rewardTokens[i].length; j++) {
                if (rewardTokens[i][j] == AddressLib.PLATFORM_TOKEN_ADDRESS) {
                    feeAmount = feeAmount.add(amounts[i][j]);
                } else {
                    feeAmount = feeAmount.add(
                        nativeZapper.getAmountOut(
                            rewardTokens[i][j],
                            amounts[i][j]
                        )
                    );
                }
            }
        }
        return feeAmount;
    }

    function earned(address _lp, address _for)
        external
        view
        returns (address[] memory rewardTokens, uint256[] memory amounts)
    {
        Pool memory pool = poolInfos[_lp];
        rewardTokens = IVirtualBalanceRewardPool(pool.rewarder)
            .getRewardTokens();
        uint256 length = rewardTokens.length;
        amounts = new uint256[](length);
        for (uint256 index; index < length; ++index) {
            amounts[index] = IVirtualBalanceRewardPool(pool.rewarder).earned(
                _for,
                rewardTokens[index]
            );
        }
    }

    function _forwardRewards(
        address[] memory _rewardTokens,
        uint256[] memory _feeAmounts
    ) internal {
        uint256 length = _rewardTokens.length;
        for (uint256 i; i < length; i++) {
            if (_rewardTokens[i] != address(0) && _feeAmounts[i] > 0) {
                TransferHelper.safeTransferToken(
                    _rewardTokens[i],
                    msg.sender,
                    _feeAmounts[i]
                );
            }
        }
    }

    function _swapFeesForNative(
        address[] memory rewardTokens,
        uint256[] memory feeAmounts,
        address _receiver
    ) internal returns (uint256 nativeAmount) {
        uint256 length = rewardTokens.length;
        for (uint256 i; i < length; i++) {
            if (feeAmounts[i] == 0) {
                continue;
            }
            if (AddressLib.isPlatformToken(rewardTokens[i])) {
                nativeAmount = nativeAmount.add(feeAmounts[i]);
                TransferHelper.safeTransferETH(_receiver, feeAmounts[i]);
            } else {
                _approveTokenIfNeeded(
                    rewardTokens[i],
                    address(nativeZapper),
                    feeAmounts[i]
                );
                nativeAmount = nativeAmount.add(
                    nativeZapper.zapInToken(
                        rewardTokens[i],
                        feeAmounts[i],
                        _receiver
                    )
                );
            }
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

/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
 */
library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

    /**
     * @dev Returns the multiplication of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two signed integers. Reverts on
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
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    /**
     * @dev Returns the subtraction of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    /**
     * @dev Returns the addition of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
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

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IBribeManager {
    function isPoolActive(address pool) external view returns (bool);

    function getUserTotalVote(address _user) external view returns (uint256);

    function getUserVoteForPool(address _lp, address _user)
        external
        view
        returns (uint256);

    function getUserVoteForPools(address[] calldata _lps, address _user)
        external
        view
        returns (uint256[] memory votes);

    function vote(address[] calldata _lps, int256[] calldata _deltas) external;

    function unvote(address _lp) external;

    function getRewardAll()
        external
        returns (
            address[][] memory rewardTokens,
            uint256[][] memory earnedRewards
        );

    event PoolAdded(address indexed _lp, address indexed _rewarder);

    event AllVoteReset();

    event VoteUpdated(
        address indexed _user,
        address indexed _lp,
        uint256 _amount
    );
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IDelegateVotePool {
    function getReward(address _for)
        external
        returns (
            address[] memory rewardTokensList,
            uint256[] memory earnedRewards
        );
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface INativeZapper {
    function getAmountOut(address _from, uint256 _amount)
        external
        view
        returns (uint256);

    function zapInToken(
        address _from,
        uint256 _amount,
        address _receiver
    ) external returns (uint256 nativeAmount);

    event ZapIn(
        address indexed _from,
        uint256 _amount,
        address indexed _receiver,
        uint256 _amountOut
    );
    event AccessSet(address indexed _address, bool _status);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./IRewards.sol";

interface IVirtualBalanceRewardPool {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function stakeFor(address _for, uint256 _amount) external;

    function withdrawFor(address _account, uint256 _amount) external;

    function getReward(address _account) external;

    function donate(address, uint256) external payable;

    function queueNewRewards(address, uint256) external payable;

    function earned(address, address) external view returns (uint256);

    function getUserAmountTime(address) external view returns (uint256);

    function getRewardTokens() external view returns (address[] memory);

    function getRewardTokensLength() external view returns (uint256);

    function setAccess(address _address, bool _status) external;

    event OperatorUpdated(address _operator);

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

pragma solidity 0.6.12;

interface IVlQuoV2 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address _user) external view returns (uint256);

    function lock(
        address _user,
        uint256 _amount,
        uint256 _weeks
    ) external;
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

    function deposit(uint256, uint256) external;

    function depositV2(
        address,
        uint256,
        uint256
    ) external;

    function withdraw(uint256, uint256) external;

    function withdrawV2(
        address,
        uint256,
        uint256
    ) external;

    function withdrawAll(uint256) external;

    function withdrawAllV2(address, uint256) external;

    function claimRewards(uint256) external;

    function claimRewardsV2(address, uint256) external;

    function balanceOfPool(uint256) external view returns (uint256);

    function balanceOfPoolV2(address, uint256) external view returns (uint256);

    function migrate(
        uint256,
        address,
        address
    ) external returns (uint256);

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
pragma experimental ABIEncoderV2;

interface IVoter {
    function veWom() external view returns (address);

    function lpTokens(uint256) external view returns (address);

    function infos(address)
        external
        view
        returns (
            uint104 supplyBaseIndex, // 19.12 fixed point. distributed reward per alloc point
            uint104 supplyVoteIndex, // 19.12 fixed point. distributed reward per vote weight
            uint40 nextEpochStartTime,
            uint128 claimable, // 20.18 fixed point. Rewards pending distribution in the next epoch
            bool whitelist,
            address gaugeManager,
            address bribe // address of bribe
        );

    function lpTokenLength() external view returns (uint256);

    function getUserVotes(address _user, address _lpToken)
        external
        view
        returns (uint256);

    function vote(address[] calldata _lpVote, int256[] calldata _deltas)
        external
        returns (uint256[][] memory bribeRewards);

    function pendingBribes(address[] calldata _lpTokens, address _user)
        external
        view
        returns (uint256[][] memory bribeRewards);

    function distribute(address _lpToken) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Interface of the VeWom
 */
interface IVeWom {
    struct Breeding {
        uint48 unlockTime;
        uint104 womAmount;
        uint104 veWomAmount;
    }

    struct UserInfo {
        // reserve usage for future upgrades
        uint256[10] reserved;
        Breeding[] breedings;
    }

    function totalSupply() external view returns (uint256);

    function balanceOf(address _addr) external view returns (uint256);

    function isUser(address _addr) external view returns (bool);

    function mint(uint256 amount, uint256 lockDays)
        external
        returns (uint256 veWomAmount);

    function burn(uint256 slot) external;

    function usedVote(address) external view returns (uint256);
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

pragma solidity ^0.6.0;

library AddressLib {
    address public constant PLATFORM_TOKEN_ADDRESS =
        0xeFEfeFEfeFeFEFEFEfefeFeFefEfEfEfeFEFEFEf;

    function isPlatformToken(address addr) internal pure returns (bool) {
        return addr == PLATFORM_TOKEN_ADDRESS;
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