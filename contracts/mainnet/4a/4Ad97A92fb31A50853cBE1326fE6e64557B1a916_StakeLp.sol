/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

// SPDX-License-Identifier: Unlicensed
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

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
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
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

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


interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint256);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IInviter {
    function getInviter(address account) external returns(address);
}

contract LPTokenWrapper {
    using SafeMath for uint256;

    IERC20 public lpt;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public virtual {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        lpt.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw() public virtual {
        uint256 amount = balanceOf(msg.sender);
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        lpt.transfer(msg.sender, amount);
    }
}

contract StakeLp is
    LPTokenWrapper,
    Ownable
{
    using SafeMath for uint256;
    IERC20 public mbaToken;

    uint256 public DURATION = 30 days;
    uint256 public LOCKDURATION = 60 days;

    address public inviteAddress;
    address public usdtAddress;

    mapping(address => uint256) public userActValue;
    mapping(address => uint256) public lastUpdateTime;
    mapping(address => uint256) public userStakeTime;
    mapping(address => uint256) public rewards;

    enum TYPELEVEL{LEVEL1, LEVEL2, LEVEL3, LEVEL4}
    mapping(TYPELEVEL => uint8) levelRewardRatio;
    mapping(TYPELEVEL => uint256[]) levelRequiredValue;

    uint8 public inviteLevel1RewardRatio = 15; //4%;
    uint8 public inviteLevel2RewardRatio = 8; //2%

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(
        address _mbaToken,
        address _lptoken,
        address _usdtAddress,
        address _inviteAddress
    ) {
        mbaToken = IERC20(_mbaToken);
        usdtAddress = _usdtAddress;
        lpt = IERC20(_lptoken);

        inviteAddress = _inviteAddress;
        levelRewardRatio[TYPELEVEL.LEVEL1] = 8; //8%
        levelRewardRatio[TYPELEVEL.LEVEL2] = 10; //8%
        levelRewardRatio[TYPELEVEL.LEVEL3] = 12; //10%
        levelRewardRatio[TYPELEVEL.LEVEL4] = 15; //10%

        levelRequiredValue[TYPELEVEL.LEVEL1] = [0, 999 * 10 ** 18];
        levelRequiredValue[TYPELEVEL.LEVEL2] = [1000 * 10 ** 18, 2999 * 10 ** 18];
        levelRequiredValue[TYPELEVEL.LEVEL3] = [3000 * 10 ** 18, 4999 * 10 ** 18];
        levelRequiredValue[TYPELEVEL.LEVEL4] = [5000 * 10 ** 18, 999999999 * 10 ** 18];
    }

    function setInviteLevelRatio(uint8 _inviteLevel1RewardRatio, uint8 _inviteLevel2RewardRatio) external onlyOwner {
        inviteLevel1RewardRatio = _inviteLevel1RewardRatio;
        inviteLevel2RewardRatio = _inviteLevel2RewardRatio;
    }

    function setLevelRewardRatio(TYPELEVEL _levelType, uint8 _ratio) external onlyOwner {
        levelRewardRatio[_levelType] = _ratio;
    }

    function setLevelRequiredValue(TYPELEVEL _levelType, uint256[] memory _arr) external onlyOwner {
        levelRequiredValue[_levelType] = _arr;
    }

    modifier updateReward(address account) {
        if (account != address(0)) {
            rewards[account] = earned(account);
            lastUpdateTime[account] = block.timestamp;
        }
        _;
    }

    function rewardPerToken(address account) public view returns (uint256) {
        uint256 ratio;
        if(userActValue[account] >= levelRequiredValue[TYPELEVEL.LEVEL4][0]) {
            ratio = levelRewardRatio[TYPELEVEL.LEVEL4];
        } else if (
            userActValue[account] >= levelRequiredValue[TYPELEVEL.LEVEL3][0] 
            && userActValue[account] <= levelRequiredValue[TYPELEVEL.LEVEL3][1]
        ) 
        {
            ratio = levelRewardRatio[TYPELEVEL.LEVEL3];
        } else if(
            userActValue[account] >= levelRequiredValue[TYPELEVEL.LEVEL2][0] 
            && userActValue[account] <= levelRequiredValue[TYPELEVEL.LEVEL2][1]
        ) {
            ratio = levelRewardRatio[TYPELEVEL.LEVEL2];
        } else if(
            userActValue[account] > levelRequiredValue[TYPELEVEL.LEVEL1][0] 
            && userActValue[account] <= levelRequiredValue[TYPELEVEL.LEVEL1][1]
        ) {
            ratio = levelRewardRatio[TYPELEVEL.LEVEL1];
        }
        uint256 perReward = ratio > 0 ? ratio.mul(1e18).div(100 * DURATION) : 0;
        return perReward;
    }

    function earned(address account) public view returns (uint256) {
        return
            userActValue[account]
                .mul(rewardPerToken(account))
                .mul(block.timestamp.sub(lastUpdateTime[account]))
                .add(rewards[account]);
    }

    function getMbaTokenNum(address account) public view returns(uint256 claimMbaTokenAmount) {
        uint256 reward = earned(account);
        claimMbaTokenAmount = calculateMbaToken(reward).div(1e18);
    }

    function getCurPrice() public view returns(uint _price){
        address t0 = IPancakePair(address(lpt)).token0();
        (uint r0,uint r1,) = IPancakePair(address(lpt)).getReserves();
        if( r0 > 0 && r1 > 0 ){
             if( t0 == address(mbaToken)){
                _price = r1 * 10 ** 18 / r0;
            }else{
                _price = r0 * 10 ** 18 / r1;
            }   
        }
    }

    function calculateValue(address account) public view returns(uint256 value) {
        uint256 balance = balanceOf(account);
        uint256 usdtAmount = IERC20(usdtAddress).balanceOf(address(lpt));
        value = usdtAmount.mul(2)*balance.mul(1e18).div(lpt.totalSupply());
    }

    function calculateAmountToValue(uint256 amount) public view returns(uint256 value) {
        uint256 usdtAmount = IERC20(usdtAddress).balanceOf(address(lpt));
        value = usdtAmount.mul(2) * amount.mul(1e18).div(lpt.totalSupply());
    }

    function calculateMbaToken(uint256 reward) public view returns(uint256 claimMbaTokenAmount) {
        claimMbaTokenAmount = reward.mul(1e18).div(getCurPrice());
    }   

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount)
        public
        override
        updateReward(msg.sender)
    {
        require(amount > 0, 'StakeLp: Cannot stake 0');
        super.stake(amount);
        userActValue[msg.sender] = calculateValue(msg.sender).div(1e18);
        sendRecommend(msg.sender, amount);
        userStakeTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, amount);
    }

    function sendRecommend(address toAddress, uint256 amount) private {
        uint256 reward;
        uint256 usdtAmount = IERC20(usdtAddress).balanceOf(address(lpt));
        uint256 values = usdtAmount.mul(2) * amount.mul(1e18).div(lpt.totalSupply());
        address index = IInviter(inviteAddress).getInviter(toAddress);
        for(uint256 i = 0; i < 2; i++) {
            if(i == 0) {
                reward = values.mul(inviteLevel1RewardRatio).div(1e20);
            } else {
                reward = values.mul(inviteLevel2RewardRatio).div(1e20);
            }
            if (index == address(0)) {
                break;
            }
            if (balanceOf(index) <= 0) {
                index = IInviter(inviteAddress).getInviter(index);
                continue;
            }
            if(reward > 0) {
                uint256 rewardMbaAmount = calculateMbaToken(reward);
                mbaToken.transfer(index, rewardMbaAmount);
            }
            index = IInviter(inviteAddress).getInviter(index);
        }
    }

    function withdraw()
        public
        override
        updateReward(msg.sender)
    {
        require(block.timestamp > userStakeTime[msg.sender].add(LOCKDURATION), "The lock time has not expired");
        uint256 amount = balanceOf(msg.sender);
        require(amount > 0, 'StackLp: Cannot withdraw 0');
        super.withdraw();
        userActValue[msg.sender] = 0;
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            uint256 claimMbaTokenAmount = calculateMbaToken(reward).div(1e18);
            rewards[msg.sender] = 0;
            
            mbaToken.transfer(msg.sender, claimMbaTokenAmount);
            emit RewardPaid(msg.sender, claimMbaTokenAmount);
        }
    }
}