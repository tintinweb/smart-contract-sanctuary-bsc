/**
 *Submitted for verification at BscScan.com on 2022-03-20
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
    
    bool isStakingStart = true;
    uint256 public minimumDepositAmount;
    uint256 public maximumDepositAmount;

    IBEP20 public stakedToken;

    // Tokens per second ratios calculated corresponding to 10%, 20%, 40% and 60% for an eighteen decimal token
    uint256[] tpsRatios = [3170979198, 6341958396, 12683916793, 19025875190];
    uint256[] stakeDurations = [1, 3, 6, 12];

    struct Stake {
        uint256 amount;
        uint256 stakedTime;
        uint256 withdrawalTime;
        uint256 claimedRewards;
        uint256 stakeId;
        bool isWithdrawn;
    }
    
    mapping(address => mapping(uint256 => Stake)) public stakesOfUser;
    mapping(address => uint256) public currentIdOfUser;

    /**
    * @dev Starts staking.
    */
    function startStaking() public onlyOwner {
        require(isStakingStart == false, "Staking is already running!");
        isStakingStart = true;
    }

    /**
    * @dev Pauses staking.
    */
    function pauseStaking() public onlyOwner {
        require(isStakingStart == true, "Staking is already paused!");
        isStakingStart = false;
    }

    /**
    * @dev Sets the maximum and minimum staking deposit limits
    * @param minimumAmount The minimum amount to be staked. Send the absolute value, ignoring decimal expansion
    * @param maximumAmount The maximum amount to be staked. Send the absolute value, ignoring decimal expansion
    */
    function setDepositLimits(uint256 minimumAmount, uint256 maximumAmount) public onlyOwner {
        maximumDepositAmount = maximumAmount;
        minimumDepositAmount = minimumAmount;
    }
     
    /**
    * @dev Adds the deposit amount to the user's stakes
    * @param amount The amount to stake. Send the absolute value, ignoring decimal expansion
    * @param months The duration (in months) to stake
    */
    function addUserStake(uint256 amount, uint256 months) internal {
        uint256 _currentId = currentIdOfUser[msg.sender];
        stakesOfUser[msg.sender][_currentId].amount = amount.mul(1e18);
        stakesOfUser[msg.sender][_currentId].stakeId = _currentId;
        stakesOfUser[msg.sender][_currentId].claimedRewards = 0;
        uint256 currentTime = block.timestamp;
        stakesOfUser[msg.sender][_currentId].stakedTime = currentTime;
        if (months == 1) {
            stakesOfUser[msg.sender][_currentId].withdrawalTime = currentTime + 2592000;
        } else if (months == 3) {
            stakesOfUser[msg.sender][_currentId].withdrawalTime = currentTime + 7776000;
        } else if(months == 6) {
            stakesOfUser[msg.sender][_currentId].withdrawalTime = currentTime + 15552000;
        } else if(months == 12) {
            stakesOfUser[msg.sender][_currentId].withdrawalTime = currentTime + 31104000;
        } else {
            revert("Duration is not supported!");
        }
        stakesOfUser[msg.sender][_currentId].isWithdrawn = false;
        currentIdOfUser[msg.sender] = _currentId.add(1);
    }

    /**
    * @dev Deposit the specified amount to user's stake.
    * @param amount The amount to stake. Send the absolute value, ignoring decimal expansion
    * @param months The duration (in months) to stake
    */
    function deposit(uint256 amount, uint256 months) public {
        require(isStakingStart == true, "Staking is paused right now!");
        require(amount > 0, "Can't stake zero amount!");
        require(amount >= minimumDepositAmount, "Amount must be greater than the minimum deposit amount!");
        require(amount <= maximumDepositAmount, "Amount must be less than the maximum deposit amount!");
        bool isDurationValid = false;

        for(uint256 i = 0; i <= 3; i++) {
            if(months == stakeDurations[i]) {
                isDurationValid = true;
                break;
            }
        }
        require(isDurationValid, "Duration is invalid!");
        
        require(
            stakedToken.allowance(msg.sender, address(this)) >= amount.mul(1e18),
            "Insufficient spend limit!"
        );

        stakedToken.safeTransferFrom(
            msg.sender,
            address(this),
            amount.mul(1e18)
        );

        addUserStake(amount, months);
    }
    
    /**
    * @dev Calculate reward for the particular stake id of the user.
    * @param id The stake id of user.
    */
    function calculateReward(address account, uint256 id) public view returns (uint256) {
        require(!stakesOfUser[account][id].isWithdrawn, "This stake was withdrawn!");
        
        uint256 stakedTime = stakesOfUser[account][id].stakedTime;
        uint256 currentTime = block.timestamp;
        uint256 timeDiff = currentTime.sub(stakedTime);

        if(timeDiff <= 2592000) {
            return stakesOfUser[account][id].amount.mul(tpsRatios[0]).mul(timeDiff).div(1e18);
        } else if(timeDiff <= 7776000) {
            return stakesOfUser[account][id].amount.mul(tpsRatios[1]).mul(timeDiff).div(1e18);
        } else if(timeDiff <= 15552000) {
            return stakesOfUser[account][id].amount.mul(tpsRatios[2]).mul(timeDiff).div(1e18);
        } else {
            return stakesOfUser[account][id].amount.mul(tpsRatios[3]).mul(timeDiff).div(1e18);
        }
    }

    /**
    * @dev Sends the staked tokens by stake id to the user
    * @param id The stake id of the user.
    */
    function claim(uint256 id) public {
        require(stakesOfUser[msg.sender][id].amount > 0, "There is no such stake!");
        require(!stakesOfUser[msg.sender][id].isWithdrawn, "Stake was already withdrawn!");

        uint256 currentTime = block.timestamp;
        require(currentTime > stakesOfUser[msg.sender][id].withdrawalTime, "Tried to withdraw before the withdrawal time!");

        uint256 reward = calculateReward(msg.sender, id);
        uint256 totalAmount = reward.sub(stakesOfUser[msg.sender][id].claimedRewards).add(stakesOfUser[msg.sender][id].amount);

        require(
            stakedToken.balanceOf(address(this)) >= totalAmount,
            "Insufficent Balance"
        );

        stakedToken.safeTransfer(msg.sender, totalAmount);
        stakesOfUser[msg.sender][id].isWithdrawn = true;
    }

    /**
    * @dev Sends the monthly claimable rewards to the user.
    * @param id The stake id of the user.
    */
    function claimRewards(uint256 id) public {
        require(stakesOfUser[msg.sender][id].amount > 0, "There is no such stake!");
        require(!stakesOfUser[msg.sender][id].isWithdrawn, "Can't claim rewards for a withdrawn stake!");

        uint256 currentTime = block.timestamp;

        uint256 wholeMonthsPassed = (currentTime.sub(stakesOfUser[msg.sender][id].stakedTime)).div(2592000);
        
        require(wholeMonthsPassed != 0, "Must wait at least a month before rewards can be claimed!");
        
        uint256 reward;

        if(wholeMonthsPassed <= 3) {
            reward = stakesOfUser[msg.sender][id].amount.mul(tpsRatios[0]).mul(wholeMonthsPassed * 2592000).div(1e18);
        } else if(wholeMonthsPassed <= 6) {
            reward = stakesOfUser[msg.sender][id].amount.mul(tpsRatios[1]).mul(wholeMonthsPassed * 2592000).div(1e18);
        } else if(wholeMonthsPassed <= 9) {
            reward = stakesOfUser[msg.sender][id].amount.mul(tpsRatios[2]).mul(wholeMonthsPassed * 2592000).div(1e18);
        } else {
            reward = stakesOfUser[msg.sender][id].amount.mul(tpsRatios[3]).mul(wholeMonthsPassed * 2592000).div(1e18);
        }

        uint256 effectiveReward = reward.sub(stakesOfUser[msg.sender][id].claimedRewards);

        require(effectiveReward > 0, "Zero rewards claimable as of now!");
        
        stakedToken.safeTransfer(msg.sender, effectiveReward);

        stakesOfUser[msg.sender][id].claimedRewards += effectiveReward;
    }

    /**
    * @dev Allow the owner to withdraw wrongly sent tokens to the contract.
    * @param token The contract addres of the token to withdraw.
    * @param amount Decimal expanded amount.
    */
    function withdraw(IBEP20 token, uint256 amount) public onlyOwner {
        require(
            token.balanceOf(address(this)) >= amount,
            "Contract balance is low"
        );
        token.safeTransfer(msg.sender, amount);
    }

    constructor(IBEP20 _stakedToken) {
        stakedToken = _stakedToken;
        minimumDepositAmount = 1000;
        maximumDepositAmount = 1000000000;
    }
}