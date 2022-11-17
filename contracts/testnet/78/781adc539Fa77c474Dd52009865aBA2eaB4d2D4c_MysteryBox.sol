/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// I'm a comment!
// SPDX-License-Identifier: MIT
// pragma solidity 0.8.7;
// pragma solidity ^0.8.0;
pragma solidity >=0.8.0 <0.9.0;

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


interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);
}


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

abstract contract Ownable is Context {
    address public _owner;

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

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity >=0.8.0 <0.9.0;


contract MysteryBox is Ownable{
    // 代币的合约地址 测试网络Newxx地址
    address public nxxToken = 0xED14423dfEd90173492BA4849194a7e070672dA6;

    // 最小参与众筹量
    uint256 public minAmount = 50 * 10 ** 18;

    // 最大单次参与众筹量
    uint256 public maxAmount = 5000 * 10 ** 18;

    // NXX与USDT的汇率
    uint32 public NxxExchangeRate = 5;

    // 手续费门票
    uint public handlingFee = 2500000000000000000;

    // 收益比例
    uint public profitRatio = 15;
    
    // 手续费奖池 默认9%
    uint public bonusPool = 9;

    mapping(uint32 => Box) public boxMap;
    mapping(address => Player[]) public users;

    struct Box{
        // 开始随机数
        uint startRandomDay;
        // 结束随机数
        uint endRandomDay;
        // 爆仓时间
        uint liquidationTime;
        // 资金池
        uint256 capitalPool;
    }

    struct Player{
        // 本次参与金额
        uint256 amount;
        // 可提取收益
        uint256 extractAmount;
        // 获取到盲盒天数
        uint getRandomDay;
        // 参与时间
        uint createTimestamp;
        // BoxID
        uint32 boxId;

    }

    // 用户钱包地址: {场次: obj}
    mapping(address => mapping(uint32 => uint256)) public cusers;

    function setBoxMap(uint32 boxID, uint _startRandomDay, uint _endRandomDay, uint _liquidationTime, uint256 _capitalPool) public onlyOwner{
        boxMap[boxID] = Box(_startRandomDay, _endRandomDay, _liquidationTime, _capitalPool);
    }

    function getBoxMap(uint32 boxID) public view returns (Box memory) {
        return boxMap[boxID];
    }


    // 系统配置
     function setting(uint256 _minAmount, uint256 _maxAmount, uint32 _NxxExchangeRate, uint256 _profitRatio, uint256 _bonusPool, uint _handlingFee) public onlyOwner{
        minAmount = _minAmount;
        maxAmount = _maxAmount;
        NxxExchangeRate = _NxxExchangeRate;
        profitRatio = _profitRatio;
        bonusPool = _bonusPool;
        handlingFee = _handlingFee;
      }

    
    // 用户参与盲盒抽取
    function game(uint32 boxID, uint256 _amount) public returns (uint ) {
        Box memory _box = boxMap[boxID];
        require(_box.endRandomDay > 0, "box not init");
        require(_amount >= minAmount, "once Min Newxx");
        require(_amount <= maxAmount, "once Max Newxx");
        require(_amount > handlingFee, "less than the handling fee");

        uint _randomDay = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.number))) % (_box.endRandomDay - _box.startRandomDay);
        _randomDay = _randomDay + _box.startRandomDay;

        // 操作调用者合约地址划转到当前合约地址中
        IERC20(nxxToken).transferFrom(msg.sender, address(this), _amount);

        // 扣除门票费
        uint256 reality = _amount - handlingFee;

        // 初始化用户数据
        users[msg.sender].push(Player(reality, reality, _randomDay, block.timestamp, boxID));

        // 计算9%的奖励资金
        uint256 add_amount = reality - (_amount * bonusPool / 100);

        // 增加到对应的资金池中
        boxMap[boxID].capitalPool += add_amount;

        return _randomDay;
    }

    
    // 用户本金提取
    function extract(uint index) public {
        Player[] storage _player = users[msg.sender];
        Box memory _box = boxMap[_player[index].boxId];

        require(_player[index].extractAmount > 0, "Balance is 0");
        // 600 * 24 * _player[index].getRandomDay
        require(block.timestamp >= _player[index].createTimestamp + 10 * _player[index].getRandomDay, "its not time yet");
        // 如果当前时间已经爆仓历史的本金无法再被领取
        require(block.timestamp > _box.liquidationTime, "Liquidated");

        // 计算应获得的收益 和 奖励
        uint256 principalAmount = _player[index].extractAmount;
        uint256 earningsAmount = principalAmount * profitRatio / 1000;
        uint256 withdrawAmount = principalAmount + earningsAmount;

        // 资金池小于用户提现触发爆仓
        if(_box.capitalPool <= withdrawAmount){
            // 判断下合约里是否有足够的币
            require(IERC20(nxxToken).balanceOf(address(this)) >= _box.capitalPool, "Contract Balance Insufficient");

            boxMap[_player[index].boxId].liquidationTime = block.timestamp;
            boxMap[_player[index].boxId].capitalPool = 0;
            IERC20(nxxToken).transfer(msg.sender, _box.capitalPool);
        }else{
            // 判断下合约里是否有足够的币
            require(IERC20(nxxToken).balanceOf(address(this)) >= withdrawAmount, "Contract Balance Insufficient");
            boxMap[_player[index].boxId].capitalPool -= withdrawAmount;
            IERC20(nxxToken).transfer(msg.sender, _box.capitalPool);
        }

        // 清除用户本次盲盒的金额
        _player[index].extractAmount = 0;

    }

    function getUserData(address _address) public view returns (Player[] memory ) {
        // Player _player = users[msg.sender];
        // returns (_player.amount, _player.getRandomDay);
        Player[] memory _player = users[_address];
        return _player;
    }
    
    

}