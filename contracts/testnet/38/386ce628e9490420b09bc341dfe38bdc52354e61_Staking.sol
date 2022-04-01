/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-28
 */

/**
 *Submitted for verification at BscScan.com on 2022-03-25
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

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
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeBEP20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

contract Staking is Ownable {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;

    // ========================== App constants ========================
    IBEP20 public constant MCBNBLPToken =
        IBEP20(0x8dF989AA52fBA82579f4589169f9e60113b96D0f);

    address public mainFundOwner = 0x429E3B6aef2476343D8f662d2F5A9Bd7F20B5Fed;
    uint256 constant LPTokenDecimals = 18;

    uint256 secondsInOneDay = 120;  // <----- Using 120 for testing purpose, change to 86400 in production
    uint256 secondsIn36Hours = 180; // <----- Using 180 for testing purpose, change to 129600 in production

    // ========================== App variables ========================

    bool public isStakingStart = true;
    uint256 public stakingPoolBalance = 0;

    uint256[2][] public amountsToAPY;

    // ========================== Data ========================
    struct Stake {
        uint256 totalStake;
        uint256 unclaimedRewards;
        uint256 claimedRewards;
        uint256 lastUpdateTime;
        uint256 lastDepositTime;
    }

    mapping(address => Stake) public stakeOfUser;

    address[] public stakeholders;

    // ========================== User functions ========================

    /**
     * @dev Deposit the specified amount to user's stake.
     * @param amount The amount to stake.
     */
    function deposit(uint256 amount) public {
        require(isStakingStart == true, "Staking has not started yet!");
        require(amount > 0, "You're trying to deposit zero amount!");
        require(MCBNBLPToken.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance!");

        MCBNBLPToken.safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        stakeOfUser[msg.sender].unclaimedRewards += rewardsSinceLastUpdate(msg.sender);
        stakeOfUser[msg.sender].totalStake += amount;
        stakeOfUser[msg.sender].lastUpdateTime = block.timestamp;
        stakeOfUser[msg.sender].lastDepositTime = block.timestamp;

        stakingPoolBalance += amount;

        addStakeholder(msg.sender);

        emit Staked(msg.sender, amount);
    }
    
    /**
     * @dev Withdraw the specified amount from user's stake.
     * @param _amountToWithdraw The amount to withdraw.
     */
    function withdraw(uint256 _amountToWithdraw) public {
        require(
            _amountToWithdraw > 0,
            "You're trying to withdraw zero amount!"
        );
        require(
            _amountToWithdraw <= stakeOfUser[msg.sender].totalStake,
            "Can't withdraw amount greater than your staked amount!"
        );

        // Penalty if withdrawing within 36 hours of the last deposit
        if (
            block.timestamp - stakeOfUser[msg.sender].lastDepositTime <= secondsIn36Hours
        ) {
            uint256 penaltyAmount = stakeOfUser[msg.sender].totalStake.mul(15)
            .div(100);

            // Transfer penalty amount to main fund owner
            MCBNBLPToken.safeTransfer(mainFundOwner, penaltyAmount);

            stakeOfUser[msg.sender].totalStake =
                stakeOfUser[msg.sender].totalStake
                .sub(penaltyAmount);
        }


        uint256 _currentRewards = rewardsSinceLastUpdate(msg.sender);

        stakeOfUser[msg.sender].unclaimedRewards =
            stakeOfUser[msg.sender].unclaimedRewards.add(_currentRewards);

        stakeOfUser[msg.sender].lastUpdateTime = block.timestamp;

        if (stakeOfUser[msg.sender].totalStake <= _amountToWithdraw) {
            MCBNBLPToken.safeTransfer(
                msg.sender,
                stakeOfUser[msg.sender].totalStake
            );

            emit Withdrawn(msg.sender, stakeOfUser[msg.sender].totalStake);

            stakingPoolBalance -= stakeOfUser[msg.sender].totalStake;

            stakeOfUser[msg.sender].totalStake = 0;
        } else {
            MCBNBLPToken.safeTransfer(
                msg.sender,
                _amountToWithdraw
            );

            emit Withdrawn(msg.sender, _amountToWithdraw);

            stakingPoolBalance -= _amountToWithdraw;

            stakeOfUser[msg.sender].totalStake -= _amountToWithdraw;
        }
    }

    /**
     * @dev Transfer the currently claimable rewards to the staker
     */
    function claimAllRewards() public {
        require(
            stakeOfUser[msg.sender].lastUpdateTime > 0,
            "You haven't staked anything yet!"
        );

        uint256 _currentRewards = rewardsSinceLastUpdate(msg.sender);

        uint256 _totalReward = stakeOfUser[msg.sender]
            .unclaimedRewards
            .add(_currentRewards);

        require(_totalReward > 0, "No rewards claimable as of now!");

        payable(msg.sender).transfer(_totalReward);

        stakeOfUser[msg.sender].unclaimedRewards = 0;
        stakeOfUser[msg.sender].lastUpdateTime = block.timestamp;

        // Keep track of the total sent rewards
        stakeOfUser[msg.sender].claimedRewards += _totalReward;
        emit RewardPaid(msg.sender, _totalReward);
    }

    // ========================== Admin functions ========================
    /**
     * @dev Starts staking.
     */
    function startStaking() public onlyOwner {
        isStakingStart = true;
    }

    /**
     * @dev Pauses staking.
     */
    function pauseStaking() public onlyOwner {
        isStakingStart = false;
    }

    /**
     * @dev The admin can withdraw wrongly sent tokens to the contract.
     */
    function recoverBEP20(address tokenAddress, uint256 tokenAmount)
        external
        onlyOwner
    {
        require(tokenAddress != address(MCBNBLPToken), "tokenAddress");
        IBEP20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    /**
     * @dev Change the APY ranges
     * @param _amountPair The pair in the format [amount, apy]
     */
    function addAmountToAPYPair(uint256[2] memory _amountPair) public onlyOwner returns (uint256) {
        amountsToAPY.push(_amountPair);
        return amountsToAPY.length;
    }

    /**
     * @dev Delete all amounts to APY pairs
     */
    function clearamountsToAPY() public onlyOwner {
        delete amountsToAPY;
        amountsToAPY = new uint256[2][](0);
    }

    function changeMainFundOwner(address _newAddress) public onlyOwner {
        mainFundOwner = _newAddress;
    }

    // ========================== Getters ========================
    function getAPYforAmount(uint256 _amount) public view returns (uint256) {
        uint256 lengthOfAmountPairs = amountsToAPY.length;
        for(uint256 i = 0; i < lengthOfAmountPairs; i++) {
            if(amountsToAPY[i][0] >= _amount) {
                return amountsToAPY[i][1];
            }
        }
        return amountsToAPY[lengthOfAmountPairs - 1][1];
    }

    function getAllAPYPairs() public view returns(uint256[2][] memory) {
        return amountsToAPY;
    }

    /**
     * @dev Retuns a list of the current stakeholders.
     */
    function getAllStakeholders() public view returns (address[] memory) {
        uint256 totalStakeholders = stakeholders.length;

        address[] memory _stakeholders = new address[](totalStakeholders);

        for (uint256 i = 0; i < totalStakeholders; i++) {
            _stakeholders[i] = stakeholders[i];
        }

        return _stakeholders;
    }

    /**
     * @dev Calculates reward for the user since the last update time
     * Front-end should divide by reward token decimal to get the formatted amount
     * @param _user The address of the stakeholder
     */
    function rewardsSinceLastUpdate(address _user)
        public
        view
        returns (uint256)
    {
        if (stakeOfUser[_user].totalStake > 0 && stakeOfUser[_user].lastUpdateTime > 0) {
            uint256 _apy = getAPYforAmount(stakeOfUser[_user].totalStake);

            uint256 tps = stakeOfUser[_user].totalStake.mul(_apy).div(100 * 86400 * 365);
            
            uint256 wholeDaysPassed = (block.timestamp.sub(stakeOfUser[_user].lastUpdateTime))
            .div(secondsInOneDay);

            if(wholeDaysPassed == 0) return uint256(0);

            uint256 timeDiff = wholeDaysPassed.mul(secondsInOneDay);

            return timeDiff.mul(tps);
        } else {
            return uint256(0);
        }
    }

    /**
     * @dev Sends the rewards accumulated by the user in the last day of their stake
     * Front-end should divide by reward token decimal to get the formatted amount
     * @param _user The address of the stakeholder
     */
    function lastDayRewards(address _user) public view returns (uint256) {
        if (stakeOfUser[_user].totalStake > 0 && stakeOfUser[_user].lastUpdateTime > 0) {
            uint256 _apy = getAPYforAmount(stakeOfUser[_user].totalStake);

            uint256 tps = stakeOfUser[_user].totalStake.mul(_apy).div(100 * 86400 * 365);
            
            uint256 wholeDaysPassed = stakeOfUser[_user].lastUpdateTime.div(secondsInOneDay);

            if(wholeDaysPassed == 0) return uint256(0);

            uint256 timeDiff = secondsInOneDay;

            return timeDiff.mul(tps);
        } else {
            return uint256(0);
        }
    }

    /**
     * @dev The current earnings of the user
     */
    function myTotalEarning(address _user) public view returns (uint256) {
        uint256 _currentRewards = rewardsSinceLastUpdate(msg.sender);

        return
            stakeOfUser[_user]
                .unclaimedRewards
                .add(_currentRewards);
    }

    // ========================== Internal and private functions ========================
    /**
    * @dev Checks if the person is a stakeholder
    */
    function isStakeholder(address _userAddress)
        private
        view
        returns (bool, uint256)
    {
        for (uint256 i = 0; i < stakeholders.length; i++) {
            if (stakeholders[i] == _userAddress) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function removeStakeholder(address _stakeholder) internal {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if (_isStakeholder) {
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }
    }

    function addStakeholder(address _stakeholder) internal {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if (!_isStakeholder) stakeholders.push(_stakeholder);
    }

    /* ========== EVENTS ========== */
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    event RewardPaid(address indexed user, uint256 reward);
    event Recovered(address token, uint256 amount);

    event ReceivedBNB(address, uint256);

    receive() external payable {
        emit ReceivedBNB(msg.sender, msg.value);
    }
}