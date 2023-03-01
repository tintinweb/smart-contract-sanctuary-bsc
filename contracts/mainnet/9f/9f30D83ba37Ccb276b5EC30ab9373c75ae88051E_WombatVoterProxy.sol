// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./Interfaces/IVirtualBalanceRewardPool.sol";
import "./Interfaces/IWombatVoterProxy.sol";
import "./Interfaces/Wombat/IBribe.sol";
import "./Interfaces/Wombat/IMasterWombatV2.sol";
import "./Interfaces/Wombat/IMasterWombatV3.sol";
import "./Interfaces/Wombat/IVeWom.sol";
import "./Interfaces/Wombat/IVoter.sol";
import "@shared/lib-contracts/contracts/Dependencies/TransferHelper.sol";

contract WombatVoterProxy is IWombatVoterProxy, OwnableUpgradeable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using TransferHelper for address;

    address public wom;
    IMasterWombatV2 public masterWombat;
    address public veWom;

    address public booster;
    address public depositor;

    IVoter public voter;
    address public bribeManager;
    uint256 constant FEE_DENOMINATOR = 10000;
    uint256 public bribeCallerFee;
    uint256 public bribeProtocolFee;
    address public bribeFeeCollector;

    modifier onlyBooster() {
        require(msg.sender == booster, "!auth");
        _;
    }

    modifier onlyDepositor() {
        require(msg.sender == depositor, "!auth");
        _;
    }

    function initialize() public initializer {
        __Ownable_init();
    }

    function setParams(
        address _masterWombat,
        address _booster,
        address _depositor
    ) external onlyOwner {
        require(booster == address(0), "!init");

        require(_masterWombat != address(0), "invalid _masterWombat!");
        require(_booster != address(0), "invalid _booster!");
        require(_depositor != address(0), "invalid _depositor!");

        masterWombat = IMasterWombatV2(_masterWombat);
        wom = masterWombat.wom();
        veWom = masterWombat.veWom();

        booster = _booster;
        depositor = _depositor;

        emit BoosterUpdated(_booster);
        emit DepositorUpdated(_depositor);
    }

    function setVoter(address _voter) external onlyOwner {
        require(_voter != address(0), "invalid _voter!");

        voter = IVoter(_voter);
    }

    function setBribeManager(address _bribeManager) external onlyOwner {
        require(_bribeManager != address(0), "invald _bribeManager!");

        bribeManager = _bribeManager;
    }

    function setBribeCallerFee(uint256 _bribeCallerFee) external onlyOwner {
        require(_bribeCallerFee <= 100, "invalid _bribeCallerFee!");
        bribeCallerFee = _bribeCallerFee;
    }

    function setBribeProtocolFee(uint256 _bribeProtocolFee) external onlyOwner {
        require(_bribeProtocolFee <= 2000, "invalid _bribeProtocolFee!");
        bribeProtocolFee = _bribeProtocolFee;
    }

    function setBribeFeeCollector(address _bribeFeeCollector)
        external
        onlyOwner
    {
        require(
            _bribeFeeCollector != address(0),
            "invalid _bribeFeeCollector!"
        );
        bribeFeeCollector = _bribeFeeCollector;
    }

    function getLpToken(uint256 _pid) external view override returns (address) {
        (address token, , , , , , ) = masterWombat.poolInfo(_pid);
        return token;
    }

    function getLpTokenV2(address _masterWombat, uint256 _pid)
        public
        view
        override
        returns (address)
    {
        address token;
        if (_masterWombat == address(masterWombat)) {
            (token, , , , , , ) = masterWombat.poolInfo(_pid);
        } else {
            (token, , , , , , , ) = IMasterWombatV3(_masterWombat).poolInfoV3(
                _pid
            );
        }

        return token;
    }

    function getBonusTokens(uint256 _pid)
        public
        view
        override
        returns (address[] memory)
    {
        (address[] memory bonusTokenAddresses, ) = masterWombat
            .rewarderBonusTokenInfo(_pid);
        for (uint256 i = 0; i < bonusTokenAddresses.length; i++) {
            if (bonusTokenAddresses[i] == address(0)) {
                // bnb
                bonusTokenAddresses[i] = AddressLib.PLATFORM_TOKEN_ADDRESS;
            }
        }
        return bonusTokenAddresses;
    }

    function getBonusTokensV2(address _masterWombat, uint256 _pid)
        public
        view
        override
        returns (address[] memory)
    {
        // V2 & V3 have the same interface
        (address[] memory bonusTokenAddresses, ) = IMasterWombatV3(
            _masterWombat
        ).rewarderBonusTokenInfo(_pid);
        for (uint256 i = 0; i < bonusTokenAddresses.length; i++) {
            if (bonusTokenAddresses[i] == address(0)) {
                // bnb
                bonusTokenAddresses[i] = AddressLib.PLATFORM_TOKEN_ADDRESS;
            }
        }
        return bonusTokenAddresses;
    }

    function deposit(uint256 _pid, uint256 _amount)
        external
        override
        onlyBooster
        returns (address[] memory rewardTokens, uint256[] memory rewardAmounts)
    {
        (address token, , , , , , ) = masterWombat.poolInfo(_pid);
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance >= _amount, "insufficient balance");

        IERC20(token).safeApprove(address(masterWombat), 0);
        IERC20(token).safeApprove(address(masterWombat), balance);
        masterWombat.deposit(_pid, balance);
        (rewardTokens, rewardAmounts) = _claimRewards(_pid);

        emit Deposited(_pid, balance);
    }

    function depositV2(
        address _masterWombat,
        uint256 _pid,
        uint256 _amount
    )
        external
        override
        onlyBooster
        returns (address[] memory rewardTokens, uint256[] memory rewardAmounts)
    {
        address token = getLpTokenV2(_masterWombat, _pid);
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance >= _amount, "insufficient balance");

        IERC20(token).safeApprove(_masterWombat, 0);
        IERC20(token).safeApprove(_masterWombat, balance);
        // V2 & V3 have the same interface
        IMasterWombatV3(_masterWombat).deposit(_pid, balance);
        (rewardTokens, rewardAmounts) = _claimRewardsV2(_masterWombat, _pid);

        emit DepositedV2(_masterWombat, _pid, balance);
    }

    // Withdraw partial funds
    function withdraw(uint256 _pid, uint256 _amount)
        public
        override
        onlyBooster
        returns (address[] memory rewardTokens, uint256[] memory rewardAmounts)
    {
        (address token, , , , , , ) = masterWombat.poolInfo(_pid);
        uint256 _balance = IERC20(token).balanceOf(address(this));
        if (_balance < _amount) {
            masterWombat.withdraw(_pid, _amount.sub(_balance));
            (rewardTokens, rewardAmounts) = _claimRewards(_pid);
        }
        IERC20(token).safeTransfer(booster, _amount);

        emit Withdrawn(_pid, _amount);
    }

    // Withdraw partial funds
    function withdrawV2(
        address _masterWombat,
        uint256 _pid,
        uint256 _amount
    )
        public
        override
        onlyBooster
        returns (address[] memory rewardTokens, uint256[] memory rewardAmounts)
    {
        address token = getLpTokenV2(_masterWombat, _pid);
        uint256 _balance = IERC20(token).balanceOf(address(this));
        if (_balance < _amount) {
            // V2 & V3 have the same interface
            IMasterWombatV3(_masterWombat).withdraw(
                _pid,
                _amount.sub(_balance)
            );
            (rewardTokens, rewardAmounts) = _claimRewardsV2(
                _masterWombat,
                _pid
            );
        }
        IERC20(token).safeTransfer(booster, _amount);

        emit WithdrawnV2(_masterWombat, _pid, _amount);
    }

    function withdrawAll(uint256 _pid)
        external
        override
        onlyBooster
        returns (address[] memory, uint256[] memory)
    {
        (address token, , , , , , ) = masterWombat.poolInfo(_pid);
        uint256 amount = balanceOfPool(_pid).add(
            IERC20(token).balanceOf(address(this))
        );
        return withdraw(_pid, amount);
    }

    function withdrawAllV2(address _masterWombat, uint256 _pid)
        external
        override
        onlyBooster
        returns (address[] memory, uint256[] memory)
    {
        address token = getLpTokenV2(_masterWombat, _pid);
        uint256 amount = balanceOfPoolV2(_masterWombat, _pid).add(
            IERC20(token).balanceOf(address(this))
        );
        return withdrawV2(_masterWombat, _pid, amount);
    }

    function claimRewards(uint256 _pid)
        external
        override
        onlyBooster
        returns (address[] memory, uint256[] memory)
    {
        // call deposit with _amount == 0 to claim current rewards
        masterWombat.deposit(_pid, 0);

        return _claimRewards(_pid);
    }

    function claimRewardsV2(address _masterWombat, uint256 _pid)
        external
        override
        onlyBooster
        returns (address[] memory, uint256[] memory)
    {
        // call deposit with _amount == 0 to claim current rewards
        IMasterWombatV3(_masterWombat).deposit(_pid, 0);

        return _claimRewardsV2(_masterWombat, _pid);
    }

    // send claimed rewards to booster
    function _claimRewards(uint256 _pid)
        internal
        returns (address[] memory rewardTokens, uint256[] memory rewardAmounts)
    {
        address[] memory bonusTokenAddresses = getBonusTokens(_pid);
        rewardTokens = new address[](1 + bonusTokenAddresses.length);
        rewardAmounts = new uint256[](1 + bonusTokenAddresses.length);

        uint256 _balance = IERC20(wom).balanceOf(address(this));
        rewardTokens[0] = wom;
        rewardAmounts[0] = _balance;
        IERC20(wom).safeTransfer(booster, _balance);
        emit RewardsClaimed(_pid, _balance);

        for (uint256 i = 0; i < bonusTokenAddresses.length; i++) {
            address bonusTokenAddress = bonusTokenAddresses[i];
            uint256 bonusTokenBalance = TransferHelper.balanceOf(
                bonusTokenAddress,
                address(this)
            );
            rewardTokens[1 + i] = bonusTokenAddress;
            rewardAmounts[1 + i] = bonusTokenBalance;
            if (bonusTokenBalance == 0) {
                continue;
            }
            bonusTokenAddress.safeTransferToken(booster, bonusTokenBalance);

            emit BonusRewardsClaimed(
                _pid,
                bonusTokenAddress,
                bonusTokenBalance
            );
        }
    }

    // send claimed rewards to booster
    function _claimRewardsV2(address _masterWombat, uint256 _pid)
        internal
        returns (address[] memory rewardTokens, uint256[] memory rewardAmounts)
    {
        address[] memory bonusTokenAddresses = getBonusTokensV2(
            _masterWombat,
            _pid
        );
        rewardTokens = new address[](1 + bonusTokenAddresses.length);
        rewardAmounts = new uint256[](1 + bonusTokenAddresses.length);

        uint256 _balance = IERC20(wom).balanceOf(address(this));
        rewardTokens[0] = wom;
        rewardAmounts[0] = _balance;
        IERC20(wom).safeTransfer(booster, _balance);
        emit RewardsClaimedV2(_masterWombat, _pid, _balance);

        for (uint256 i = 0; i < bonusTokenAddresses.length; i++) {
            address bonusTokenAddress = bonusTokenAddresses[i];
            uint256 bonusTokenBalance = TransferHelper.balanceOf(
                bonusTokenAddress,
                address(this)
            );
            rewardTokens[1 + i] = bonusTokenAddress;
            rewardAmounts[1 + i] = bonusTokenBalance;
            if (bonusTokenBalance == 0) {
                continue;
            }
            bonusTokenAddress.safeTransferToken(booster, bonusTokenBalance);

            emit BonusRewardsClaimedV2(
                _masterWombat,
                _pid,
                bonusTokenAddress,
                bonusTokenBalance
            );
        }
    }

    function balanceOfPool(uint256 _pid)
        public
        view
        override
        returns (uint256)
    {
        (uint256 amount, , , ) = masterWombat.userInfo(_pid, address(this));
        return amount;
    }

    function balanceOfPoolV2(address _masterWombat, uint256 _pid)
        public
        view
        override
        returns (uint256)
    {
        (uint256 amount, , , ) = IMasterWombatV3(_masterWombat).userInfo(
            _pid,
            address(this)
        );
        return amount;
    }

    function migrate(
        uint256 _pid,
        address _masterWombat,
        address _newMasterWombat
    )
        external
        override
        onlyBooster
        returns (
            uint256 newPid,
            address[] memory rewardTokens,
            uint256[] memory rewardAmounts
        )
    {
        if (_masterWombat == address(0)) {
            _masterWombat = address(masterWombat);
        }

        address token = getLpTokenV2(_masterWombat, _pid);
        // will revert if not exist
        newPid = IMasterWombatV3(_newMasterWombat).getAssetPid(token);
        uint256 balanceOfOld = balanceOfPoolV2(_masterWombat, _pid);
        uint256 balanceofNewBefore = balanceOfPoolV2(_newMasterWombat, newPid);

        uint256[] memory pids = new uint256[](1);
        pids[0] = _pid;
        IMasterWombatV2(_masterWombat).migrate(pids);

        uint256 balanceOfNewAfter = balanceOfPoolV2(_newMasterWombat, newPid);
        require(
            balanceOfNewAfter.sub(balanceofNewBefore) >= balanceOfOld,
            "migration failed"
        );

        (rewardTokens, rewardAmounts) = _claimRewardsV2(_masterWombat, _pid);
    }

    function lockWom(uint256 _lockDays) external override onlyDepositor {
        uint256 balance = IERC20(wom).balanceOf(address(this));

        if (balance == 0) {
            return;
        }

        IERC20(wom).safeApprove(veWom, 0);
        IERC20(wom).safeApprove(veWom, balance);

        IVeWom(veWom).mint(balance, _lockDays);

        emit WomLocked(balance, _lockDays);
    }

    function unlockWom(uint256 _slot) external onlyOwner {
        IVeWom(veWom).burn(_slot);

        emit WomUnlocked(_slot);
    }

    function vote(
        address[] calldata _lpVote,
        int256[] calldata _deltas,
        address[] calldata _rewarders,
        address _caller
    )
        external
        override
        returns (address[][] memory rewardTokens, uint256[][] memory feeAmounts)
    {
        require(msg.sender == bribeManager, "!auth");
        uint256 length = _lpVote.length;
        require(length == _rewarders.length, "Not good rewarder length");
        uint256[][] memory bribeRewards = voter.vote(_lpVote, _deltas);

        rewardTokens = new address[][](length);
        feeAmounts = new uint256[][](length);

        for (uint256 i = 0; i < length; i++) {
            uint256[] memory rewardAmounts = bribeRewards[i];
            (, , , , , , address bribesContract) = voter.infos(_lpVote[i]);
            feeAmounts[i] = new uint256[](rewardAmounts.length);
            if (bribesContract != address(0)) {
                rewardTokens[i] = _getBribeRewardTokens(bribesContract);
                for (uint256 j = 0; j < rewardAmounts.length; j++) {
                    uint256 rewardAmount = rewardAmounts[j];
                    if (rewardAmount > 0) {
                        uint256 protocolFee = bribeFeeCollector != address(0)
                            ? rewardAmount.mul(bribeProtocolFee).div(
                                FEE_DENOMINATOR
                            )
                            : 0;
                        if (protocolFee > 0) {
                            rewardTokens[i][j].safeTransferToken(
                                bribeFeeCollector,
                                protocolFee
                            );
                        }
                        uint256 callerFee = _caller != address(0)
                            ? rewardAmount.mul(bribeCallerFee).div(
                                FEE_DENOMINATOR
                            )
                            : 0;
                        if (callerFee != 0) {
                            rewardTokens[i][j].safeTransferToken(
                                bribeManager,
                                callerFee
                            );
                            feeAmounts[i][j] = callerFee;
                        }
                        rewardAmount = rewardAmount.sub(protocolFee).sub(
                            callerFee
                        );

                        if (AddressLib.isPlatformToken(rewardTokens[i][j])) {
                            IVirtualBalanceRewardPool(_rewarders[i])
                                .queueNewRewards{value: rewardAmount}(
                                rewardTokens[i][j],
                                rewardAmount
                            );
                        } else {
                            _approveTokenIfNeeded(
                                rewardTokens[i][j],
                                _rewarders[i],
                                rewardAmount
                            );
                            IVirtualBalanceRewardPool(_rewarders[i])
                                .queueNewRewards(
                                    rewardTokens[i][j],
                                    rewardAmount
                                );
                        }
                    }
                }
            }
        }

        emit Voted(_lpVote, _deltas, _rewarders, _caller);
    }

    function pendingBribeCallerFee(address[] calldata _pendingPools)
        external
        view
        override
        returns (
            address[][] memory rewardTokens,
            uint256[][] memory callerFeeAmount
        )
    {
        // Warning: Arguments do not take into account repeated elements in the pendingPools list
        (
            address[][] memory bribeTokenAddresses,
            ,
            uint256[][] memory bribeRewards
        ) = voter.pendingBribes(_pendingPools, address(this));
        uint256 length = bribeTokenAddresses.length;
        rewardTokens = new address[][](length);
        callerFeeAmount = new uint256[][](length);
        for (uint256 i; i < length; i++) {
            rewardTokens[i] = new address[](bribeTokenAddresses[i].length);
            callerFeeAmount[i] = new uint256[](bribeTokenAddresses[i].length);
            for (uint256 j; j < bribeTokenAddresses[i].length; j++) {
                // if rewardToken is 0, native token is used as reward token
                if (bribeTokenAddresses[i][j] == address(0)) {
                    rewardTokens[i][j] = AddressLib.PLATFORM_TOKEN_ADDRESS;
                } else {
                    rewardTokens[i][j] = bribeTokenAddresses[i][j];
                }
                callerFeeAmount[i][j] = bribeRewards[i][j]
                    .mul(bribeCallerFee)
                    .div(FEE_DENOMINATOR);
            }
        }
    }

    function _getBribeRewardTokens(address _bribesContract)
        internal
        view
        returns (address[] memory)
    {
        address[] memory rewardTokens = IBribe(_bribesContract).rewardTokens();
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            // if rewardToken is 0, native token is used as reward token
            if (rewardTokens[i] == address(0)) {
                rewardTokens[i] = AddressLib.PLATFORM_TOKEN_ADDRESS;
            }
        }
        return rewardTokens;
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

interface IBribe {
    function onVote(
        address user,
        uint256 newVote,
        uint256 originalTotalVotes
    ) external returns (uint256[] memory rewards);

    function pendingTokens(address _user)
        external
        view
        returns (uint256[] memory rewards);

    function rewardTokens() external view returns (address[] memory tokens);

    function rewardLength() external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IMasterWombatV2 {
    function poolInfo(uint256)
        external
        view
        returns (
            // storage slot 1
            address lpToken, // Address of LP token contract.
            uint96 allocPoint, // How many allocation points assigned to this pool. WOMs to distribute per second.
            // storage slot 2
            address rewarder,
            // storage slot 3
            uint256 sumOfFactors, // the sum of all boosted factors by all of the users in the pool
            // storage slot 4
            uint104 accWomPerShare, // 19.12 fixed point. Accumulated WOMs per share, times 1e12.
            uint104 accWomPerFactorShare, // 19.12 fixed point.accumulated wom per factor share
            uint40 lastRewardTimestamp // Last timestamp that WOMs distribution occurs.
        );

    function userInfo(uint256, address)
        external
        view
        returns (
            // storage slot 1
            uint128 amount, // 20.18 fixed point. How many LP tokens the user has provided.
            uint128 factor, // 20.18 fixed point. boosted factor = sqrt (lpAmount * veWom.balanceOf())
            // storage slot 2
            uint128 rewardDebt, // 20.18 fixed point. Reward debt. See explanation below.
            uint128 pendingWom // 20.18 fixed point. Amount of pending wom
            //
            // We do some fancy math here. Basically, any point in time, the amount of WOMs
            // entitled to a user but is pending to be distributed is:
            //
            //   ((user.amount * pool.accWomPerShare + user.factor * pool.accWomPerFactorShare) / 1e12) -
            //        user.rewardDebt
            //
            // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
            //   1. The pool's `accWomPerShare`, `accWomPerFactorShare` (and `lastRewardTimestamp`) gets updated.
            //   2. User receives the pending reward sent to his/her address.
            //   3. User's `amount` gets updated.
            //   4. User's `rewardDebt` gets updated.
        );

    function wom() external view returns (address);

    function veWom() external view returns (address);

    function getAssetPid(address asset) external view returns (uint256 pid);

    function poolLength() external view returns (uint256);

    function pendingTokens(uint256 _pid, address _user)
        external
        view
        returns (
            uint256 pendingRewards,
            address[] memory bonusTokenAddress,
            string[] memory bonusTokenSymbol,
            uint256[] memory pendingBonusRewards
        );

    function rewarderBonusTokenInfo(uint256 _pid)
        external
        view
        returns (
            address[] memory bonusTokenAddresses,
            string[] memory bonusTokenSymbols
        );

    function massUpdatePools() external;

    function updatePool(uint256 _pid) external;

    function deposit(uint256 _pid, uint256 _amount)
        external
        returns (uint256, uint256[] memory);

    function multiClaim(uint256[] memory _pids)
        external
        returns (
            uint256 transfered,
            uint256[] memory rewards,
            uint256[][] memory additionalRewards
        );

    function withdraw(uint256 _pid, uint256 _amount)
        external
        returns (uint256, uint256[] memory);

    function emergencyWithdraw(uint256 _pid) external;

    function migrate(uint256[] calldata _pids) external;

    function depositFor(
        uint256 _pid,
        uint256 _amount,
        address _user
    ) external;

    function updateFactor(address _user, uint256 _newVeWomBalance) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IMasterWombatV3 {
    function poolInfoV3(uint256)
        external
        view
        returns (
            address lpToken, // Address of LP token contract.
            address rewarder,
            uint40 periodFinish,
            uint128 sumOfFactors, // 20.18 fixed point. the sum of all boosted factors by all of the users in the pool
            uint128 rewardRate, // 20.18 fixed point.
            uint104 accWomPerShare, // 19.12 fixed point. Accumulated WOM per share, times 1e12.
            uint104 accWomPerFactorShare, // 19.12 fixed point. Accumulated WOM per factor share
            uint40 lastRewardTimestamp
        );

    function userInfo(uint256, address)
        external
        view
        returns (
            // storage slot 1
            uint128 amount, // 20.18 fixed point. How many LP tokens the user has provided.
            uint128 factor, // 20.18 fixed point. boosted factor = sqrt (lpAmount * veWom.balanceOf())
            // storage slot 2
            uint128 rewardDebt, // 20.18 fixed point. Reward debt. See explanation below.
            uint128 pendingWom // 20.18 fixed point. Amount of pending wom
            //
            // We do some fancy math here. Basically, any point in time, the amount of WOMs
            // entitled to a user but is pending to be distributed is:
            //
            //   ((user.amount * pool.accWomPerShare + user.factor * pool.accWomPerFactorShare) / 1e12) -
            //        user.rewardDebt
            //
            // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
            //   1. The pool's `accWomPerShare`, `accWomPerFactorShare` (and `lastRewardTimestamp`) gets updated.
            //   2. User receives the pending reward sent to his/her address.
            //   3. User's `amount` gets updated.
            //   4. User's `rewardDebt` gets updated.
        );

    function getAssetPid(address asset) external view returns (uint256 pid);

    function poolLength() external view returns (uint256);

    function pendingTokens(uint256 _pid, address _user)
        external
        view
        returns (
            uint256 pendingRewards,
            address[] memory bonusTokenAddresses,
            string[] memory bonusTokenSymbols,
            uint256[] memory pendingBonusRewards
        );

    function rewarderBonusTokenInfo(uint256 _pid)
        external
        view
        returns (
            address[] memory bonusTokenAddresses,
            string[] memory bonusTokenSymbols
        );

    function massUpdatePools() external;

    function updatePool(uint256 _pid) external;

    function deposit(uint256 _pid, uint256 _amount)
        external
        returns (uint256, uint256[] memory);

    function multiClaim(uint256[] memory _pids)
        external
        returns (
            uint256 transfered,
            uint256[] memory rewards,
            uint256[][] memory additionalRewards
        );

    function withdraw(uint256 _pid, uint256 _amount)
        external
        returns (uint256, uint256[] memory);

    function emergencyWithdraw(uint256 _pid) external;

    function migrate(uint256[] calldata _pids) external;

    function depositFor(
        uint256 _pid,
        uint256 _amount,
        address _user
    ) external;

    function updateFactor(address _user, uint256 _newVeWomBalance) external;

    function notifyRewardAmount(address _lpToken, uint256 _amount) external;
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
        returns (
            address[][] memory bribeTokenAddresses,
            string[][] memory bribeTokenSymbols,
            uint256[][] memory bribeRewards
        );

    function distribute(address _lpToken) external;
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