/**
 *Submitted for verification at BscScan.com on 2022-11-13
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


contract CrowdFunding is Ownable{
    // 代币的合约地址 测试网络Newxx地址
    address public nxxToken = 0xED14423dfEd90173492BA4849194a7e070672dA6;
    address public withdrawToAddress = 0xC49843f3B121451F98C741555e0de005C72Aae44;

    // 最小参与众筹量
    uint256 public minAmount = 100 * 10 ** 18;
    // 最大单次参与众筹量
    uint256 public maxAmount = 10000 * 10 ** 18;
    // 默认可提取时间 秒x分钟
    uint public extractTimestamp = 60 * 1;
    uint public blowupRansomRatio = 7; 

    mapping(uint32 => Screening) public playerMap;

    struct Screening{
        // 目标金额
        uint256 target_amount;
        // 已筹集
        uint256 hasAmount;
        // 结束时间
        uint startTime;
        // 结束时间
        uint endTime;
        // 场次状态 0:默认状态(也可能的进行中) 1:爆仓的子场次 2:当前爆仓
        uint8 status;
    }

    // 用户钱包地址: {场次: obj}
    mapping(address => mapping(uint32 => uint256)) public player;

    // 管理员开启当前场次
    function play(uint32 _screeningId, uint256 _target_amount,  uint _endTime) public onlyOwner{
        playerMap[_screeningId] = Screening(_target_amount, 0, block.timestamp, _endTime, 0);
    }

    // 参与众筹
    function attend(uint32 _screeningId, uint256 _amount) external {
        // 判断结束时间
        require(block.timestamp < playerMap[_screeningId].endTime, "Game End");

        // 判断当前购买量大于xxU
        require(_amount >= minAmount, "once Min Newxx");
        require(_amount <= maxAmount, "once Max Newxx");

        // 已经达到今日众筹目标了
        Screening memory _screening = playerMap[_screeningId];
        require(_screening.hasAmount < _screening.target_amount, "meet");

        // 每个场次用户只能参与一次
        require(player[msg.sender][_screeningId] == 0, "Participated in the current session");

        // 操作调用者合约地址划转到当前合约地址中
        IERC20(nxxToken).transferFrom(msg.sender, address(this), _amount);

        // 添加到当前轮
        player[msg.sender][_screeningId] += _amount;
        playerMap[_screeningId].hasAmount = _screening.hasAmount + _amount;

    }

    // 查询用户当前场次的参与金额
    function getUserAttendAmount(address _address, uint32 payNumber) public view returns(uint256){
        return player[_address][payNumber];
    }

    // 用户本金赎回
    function ransom(uint32 payNumber) public {
        // 可提取的本金是否足够
        require(player[msg.sender][payNumber] > 0, "Balance is 0");

        Screening memory _screening = playerMap[payNumber];
        // 当前爆仓可以全额提取本金
        if(_screening.status == 2){
            IERC20(nxxToken).transfer(msg.sender, player[msg.sender][payNumber]);
            player[msg.sender][payNumber] = 0;
            return;
        }

        // 提前时间是否为4天后
        require(block.timestamp >= _screening.startTime + extractTimestamp, "it's not time yet");
        uint256 theRansom = player[msg.sender][payNumber];
        
        // 之后的4个场次如果爆仓只能提现70%的本金
        if(playerMap[payNumber].status == 1){
            theRansom = player[msg.sender][payNumber] * blowupRansomRatio / 10;
        }

        // 余额是否充足
        uint256 amount = IERC20(nxxToken).balanceOf(address(this));
        require(amount >= theRansom, "Contract Balance Insufficient");

        IERC20(nxxToken).transfer(msg.sender, theRansom);
        player[msg.sender][payNumber] = 0;
        
    }

    // 爆仓场次
    function overbook(uint32 _screeningId, uint32[] memory otherScreening) public onlyOwner{
        // 设置当前场次为爆仓
        playerMap[_screeningId].status = 2;

        // 最近的3个场次返回70%
        for(uint256 _index; _index < otherScreening.length; _index= _index + 1){
            playerMap[otherScreening[_index]].status = 1;
        }

    }

    // 一键提现合约中的Token 代币
    function withdraw(address _token, uint256 withdraw_amount) public onlyOwner{
        uint256 amount = IERC20(_token).balanceOf(address(this));
        require(amount >= withdraw_amount, ">=1 Newxx");

        IERC20(_token).transfer(withdrawToAddress, amount);
    }

    function setting(uint256 _minAmount, uint _extractTimestamp, uint256 _maxAmount, uint8 _blowupRansomRatio) public onlyOwner{
        minAmount = _minAmount;
        extractTimestamp = _extractTimestamp;
        maxAmount= _maxAmount;
        blowupRansomRatio = _blowupRansomRatio;
    }

    // 修改场次配置
    function setPlayerMap(uint32 _screeningId, uint256 _target_amount, uint _startTime, uint _endTime, uint8 _status) public onlyOwner{
        Screening memory _screening = playerMap[_screeningId];
        _screening.target_amount = _target_amount;
        _screening.startTime = _startTime;
        _screening.endTime = _endTime;
        _screening.status = _status;

        playerMap[_screeningId] = _screening;
        
    }


  

    


}