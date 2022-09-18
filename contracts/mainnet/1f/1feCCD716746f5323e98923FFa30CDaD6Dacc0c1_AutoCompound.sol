/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

/**
 * Develop by CPTRedHawk
 * @ Esse contrato Foi desenvolvido por https://t.me/redhawknfts
 * Caso queira ter uma plataforma similar, gentileza chamar no Telegram!
 * SPDX-License-Identifier: MIT
 * Entrega teu caminho ao senhor, e tudo ele o fará! Salmos 37
 */
 pragma solidity ^0.8.17;

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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Proprietario nao pode ser o endereco Zero"); // R
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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: contracts/Compound/UserInfo.sol


pragma solidity ^0.8.16;


library UserInfo {
    using SafeMath for uint256;
    struct Data {
        uint256 amount;
        uint256 autoCompound;
        uint256 rewards;
        uint256 rewardPerTokenPaid;
    }
    function deposit(
        UserInfo.Data storage data,
        uint256 amount
    ) internal {
        data.amount = data.amount.add(amount);
    }

    function withdraw(
        UserInfo.Data storage data,
        uint256 amount
    ) internal {
        data.amount = data.amount.sub(amount);
    }

    function updateReward(
        UserInfo.Data storage data,
        uint256 rewards,
        uint256 rewardPerTokenPaid
    ) internal {
        data.rewards = rewards;
        data.rewardPerTokenPaid = rewardPerTokenPaid;
    }
}

// File: contracts/Compound/AutoCompound.sol






contract AutoCompound is Ownable {
    using SafeMath for uint256;
    using UserInfo for UserInfo.Data;
    /*
    * -------------------------------------------
    * |               Constructor               |
    * -------------------------------------------
    */
    constructor(address _tokenReward) {
        tokenReward = IERC20(_tokenReward);
    }
    /*
    * -------------------------------------------
    * |               Unitarios                 |
    * -------------------------------------------
    */
    uint256 public lastPoolReward;
    uint256 public lastUpdateTime;
    uint256 private periodFinish;
    uint256 public lastUpdatePoolReward = 900000;
    uint256 public totalSupply;
    uint256 public totalFee; // Taxas Arrecadadas
    uint256 private feeBNB = 7000000000000000; 
    uint256 private feeTax = 12; // Taxa em ARC
    uint256 public totalValueLocked; // Valor total em Stake
    uint256 public rewardRate;
    uint256 public totalLiquidity; // Liquidez total na Pool
    uint256 public harvTime = 46061; // Tempo entre Colheita
    uint256 public rewardsDuration = 900000;
    uint256 public rewardPerTokenStored;
    /*
    ---------------------------------
    -           Address             -
    ---------------------------------
    */
    IERC20 public tokenReward;
    address private receiveAddress;
    /*
    * -------------------------------------------
    * |               Mapping                   |
    * -------------------------------------------
    */
    mapping(address => UserInfo.Data) public userInfo;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public balanceUser;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping (address => uint256) public harvestTime; // Tempo de Colheita
    /*
    * -------------------------------------------
    * |               Modificador               |
    * -------------------------------------------
    */
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
     /*=== Private/Internal/Public ===*/
    function blockHarvest() internal {
        harvestTime[_msgSender()] = block.timestamp + harvTime;
    }
    /*
    * -------------------------------------------
    * |    Internal/Pure/Public views           |
    * -------------------------------------------
    */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function lastTimeRewardApplicable() public view returns (uint256) {
        return min(block.timestamp, periodFinish);
    }
    function compound(address account) public view returns(uint256 rCompound) {
        return (     
            balanceUser[account].add(earned(account))
            .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
            .div(1e18)
            .add(rewards[account]));
    }
    function inCompound(address account) public view returns(uint256) {
        return balanceUser[account].add(compound(account));
    }
    function earned(address account) public view returns (uint256) {
        return         
            balanceUser[account]
            .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
            .div(1e18)
            .add(rewards[account]);
    }
    function rewardPerToken() public view returns(uint256) {
        if(totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return 
            rewardPerTokenStored.add(lastTimeRewardApplicable()
            .sub(lastUpdateTime)
            .mul(_getRate(totalPoolRewards()))
            .mul(1e18)
            .div(totalSupply));
    }
    function _getRate(uint256 tAmount) private view returns(uint256) {
       uint256 rate = tAmount.div(rewardsDuration);
       return rate;
    }
    function totalPoolRewards() public view returns(uint256) {
        return IERC20(tokenReward).balanceOf(address(this));
    }
    function harvestUser() public view returns(uint256) {
        uint256 currentTimes = block.timestamp;
        uint256 userHarv = harvestTime[_msgSender()];
        if(currentTimes >= userHarv) {
            return 0;
        }
        else {
            return userHarv - currentTimes;
        }
    }
    function initCompound(uint256 tAmount) external payable updateReward(_msgSender()) {
        if(feeBNB > 0) {
            require(msg.value == feeBNB, "Saldo em BNB nao definido");
        }
        IERC20(tokenReward).transferFrom(_msgSender(), address(this),tAmount);
        totalSupply += tAmount;
        totalLiquidity += tAmount;
        balanceUser[_msgSender()] += tAmount;
        lastUpdateTime = lastTimeRewardApplicable();
    }
    function exit() external payable updateReward(_msgSender()) {
        if(feeBNB > 0) {
            require(msg.value == feeBNB, "ARC:Taxa Precisa ser Cobrada");
        }
        totalSupply -= balanceUser[_msgSender()];
        balanceUser[_msgSender()] = 0;
    }
    function initRewards(uint256 rAmount, uint256 tDurantion) external onlyOwner updateReward(address(0)) {
        rewardRate = (rAmount * 10**18).div(tDurantion);
        periodFinish = block.timestamp + tDurantion;
        rewardsDuration = tDurantion;
        lastUpdateTime = block.timestamp;
    }
    function takeMyRewards() external payable updateReward(_msgSender())  {
        if(feeBNB > 0) {
            require(msg.value == feeBNB, "ARC:Taxa Precisa ser Cobrada");
        }
        require(harvestUser() == 0, "Tempo de Colheita nao liberado");
        blockHarvest();
        uint256 reward = rewards[_msgSender()];
        if (reward > 0) {
            uint256 fee = reward.mul(feeTax).div(100);
            reward = reward.sub(fee);
            totalFee += fee;
            totalLiquidity -= reward;
            rewards[_msgSender()] = 0;
            IERC20(tokenReward).transfer(_msgSender(), reward);
        }
        else {
            revert("ARC:Voce nao Possui Saldo de Recompensa");
        }
    }
    function changeReceive(address _receiveAddress) external onlyOwner {
        receiveAddress = _receiveAddress;
    }
    function getToken() external onlyOwner {
        uint256 balance = IERC20(tokenReward).balanceOf(address(this));
        IERC20(tokenReward).transfer(_msgSender(), balance);
    }
    function removePoolRewards() external onlyOwner {
        uint256 removeLiquidity = totalLiquidity;
        totalLiquidity -= removeLiquidity;
        IERC20(tokenReward).transfer(_msgSender(), removeLiquidity);
    }
    function removeTotalValueLocked() external onlyOwner {
        uint256 locked = totalValueLocked;
        totalValueLocked -= locked;
        IERC20(tokenReward).transfer(_msgSender(), locked);
    }
    function emergencialWithdraw(uint256 eAmount) external onlyOwner {
        IERC20(tokenReward).transfer(_msgSender(), eAmount);
    }
    function setFeeBNB(uint256 _feeBNB) external onlyOwner {
        feeBNB = _feeBNB;
    }
    function withdrawBNBManually() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(receiveAddress).transfer(balance);
    }
    function setFeeTax(uint256 _feeTax) external onlyOwner {
        feeTax = _feeTax;
    }
    function setHarvest(uint256 _harvTime) external onlyOwner {
        harvTime = _harvTime;
    }

}