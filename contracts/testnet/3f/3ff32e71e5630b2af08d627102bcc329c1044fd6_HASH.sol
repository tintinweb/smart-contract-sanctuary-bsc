/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// File: HASH2.sol

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;





contract HASH is Ownable {
    using SafeMath for uint256;

    enum BettorType {
        Big,            // 大  0
        Small,          // 小
        Single,         // 单
        Double,         // 双
        SmallSingle,    // 小单
        SmallDouble,    // 小双
        BigSingle,      // 大单
        BigDouble,      // 大双
        Dragon,         // 龙
        Tiger,          // 虎
        Combine,        // 合
        BaccaratBanker, // 百家乐压庄
        BaccaratIdle,   // 百家乐压闲
        BaccaratSame    // 百家乐压和 13
    }

    IERC20 public betteToken;        // 质押 Token
    uint256 public gameBlock;            // 游戏的每期块的数量，默认 30，可以设置
    uint256 public hgmGlobalId;          // 每一期游戏的Id, 从 1 开始递增, 查看开始游戏函数

    uint256 public startBlock;           // 起始区块
    uint256 public endBlock;             // 结束区块
    bool private isEnding = false;

    //每期开奖结果
    struct WinningResult {
        uint256  startBlock;           // 起始区块
        uint256  endBlock;             // 结束区块
        bool     hasReward;              // 是否结算
        uint256[]  numberList;            // 三个数字数组
        uint256    sumResult;             //三个数字相加
        uint256    bankerNumber;            // 庄的数字
        uint256    idleNumber;              // 闲的数字
        uint256 totalBetted;             // 当期下注总金额
        uint256 totalReward;             // 当期中奖总金额
    }

    //下注信息
    struct GuessBettor {
        address account;
        uint256 index;        //这一期中下注的下标
        uint256 value;        // 投注金额 >= 10U
        uint256 hgmId;        // 游戏期数
        uint256 betType;      // 投注情况
        bool    isReward;     // 是否中奖
        uint256 reWardVale;   // 奖励金额，投注失败为 0
    }

    //玩家信息
    struct userInfo {
        uint256 rewardBalance;     // 玩家待提取金额
        uint256 totalReward;       // 玩家历史总收益总额
        uint256 totalBetted;       // 玩家历史总下注金额
    }

    // 玩家事件
    event GuessBettorCreate(
        address account,
        uint256 value,
        uint256 betType,
        uint256 hgmId,
        uint256 index
    );

    mapping (uint256 => GuessBettor[]) public guessListMap;   // 玩家历史记录
    mapping (uint256 => WinningResult) public WinningMap;          // 往期记录
    mapping (address => mapping (uint256 => GuessBettor[])) public usersGuessListMap;   // 玩家记录
    mapping (address => userInfo) public userInfoList;     // 玩家信息列表


    constructor(address bettorToken_) {
        gameBlock = 30;
        hgmGlobalId = 0;
        betteToken = IERC20(bettorToken_);
    }

    // 设置每一期游戏的块的数量
    function setGameBlock(uint256 _block) public onlyOwner {
        gameBlock = _block;
    }

    // 设置博彩 Token 的信息
    function setBetteToken(address _address) public onlyOwner {
        betteToken = IERC20(_address);
    }

    // 返回地址上面的betteToken余额
    function getTokenBalance(address _address) public view returns (uint256) {
        return betteToken.balanceOf(_address);
    }

    // 投注
    function createBettor(uint256 _amount, uint256 _betType) public returns (bool) {
        // 检查投注类别是否正确
        require(_betType >= uint256(BettorType.Big) && _betType <= uint256(BettorType.BaccaratSame), "createBettor: invalid bettor type, please bette repeat");
        // 最少投资金额 10U
        require(_amount >= 10000000, "createBettor: bette amount must more than 10U");
        // 检查投注者的余额是否足够
        require(betteToken.balanceOf(msg.sender) >= _amount, "createBettor: bettor account balance not enough");
        
        require(block.number <= endBlock, "createBettor: block.number must less or equal than endBlock");

        // if (block.number > endBlock) {
        //     //结束当前期游戏
        //     endHashGame();
        // }
        GuessBettor memory gb = GuessBettor({
            account: msg.sender,
            index: (usersGuessListMap[msg.sender][hgmGlobalId]).length,
            value: _amount,
            hgmId: hgmGlobalId,
            betType: _betType,
            isReward: false,
            reWardVale: 0
        });
        //玩家历史记录
        guessListMap[hgmGlobalId].push(gb);
        //玩家信息列表
        userInfo storage user = userInfoList[msg.sender];
        user.totalBetted = user.totalBetted + _amount;
        //玩家下注记录
        usersGuessListMap[msg.sender][hgmGlobalId].push(gb);
        //当期下注总额
        WinningResult storage currentWinningResult = WinningMap[hgmGlobalId];
        currentWinningResult.totalBetted = currentWinningResult.totalBetted + _amount;
        emit GuessBettorCreate(msg.sender, _amount, _betType, hgmGlobalId, gb.index);
        require(betteToken.transferFrom(msg.sender, address(this), _amount));
        return true;
    }

    // 游戏开始
    function startHashGame() public onlyOwner {
        // 启动新的游戏，设置启动块
        require(startBlock == 0, "only startHashGame when startBlock = 0");
        startBlock = block.number;
        // 游戏结束块
        endBlock = startBlock + gameBlock;
        // 每一期的 ID
        hgmGlobalId = hgmGlobalId + 1;
    }

    // 游戏结束
    function endHashGame() public {
        require(!isEnding);
        require(block.number > endBlock, "endHashGame: game is not over");
        isEnding = true;
        WinningResult storage w = WinningMap[hgmGlobalId];
        w.startBlock = startBlock;
        w.endBlock = endBlock;
        w.bankerNumber = createRandomByDifficulty(100);
        w.idleNumber = createRandomByGaslimit(100);
        uint secodNo = createRandomByDifficulty(9);
        uint thirdNo = createRandomByGaslimit(9);
        uint firstNo = createRandomByBlock(9);

        w.numberList.push(firstNo);
        w.numberList.push(secodNo);
        w.numberList.push(thirdNo);

        for(uint i = 0; i < w.numberList.length; i++){
            w.sumResult = w.sumResult + w.numberList[i];
        }
        updateReward();
        w.hasReward = true;
        hgmGlobalId = hgmGlobalId + 1;
        isEnding = false;
        startBlock = block.number;
        endBlock = startBlock + gameBlock;
    }

    // 更新统计数据
    function updateRewardLists(address _account, uint256 _hgmId, uint256 _bettotIndex, uint256 _reWardVale) private {
        userInfo storage user = userInfoList[_account];
        WinningResult storage wr = WinningMap[hgmGlobalId];
        user.rewardBalance = user.rewardBalance + _reWardVale;
        user.totalReward = user.totalReward + _reWardVale;
        wr.totalReward = wr.totalReward + _reWardVale;
        GuessBettor storage bettorInfo = usersGuessListMap[_account][_hgmId][_bettotIndex];
        bettorInfo.isReward = true;
        bettorInfo.reWardVale = _reWardVale;
    }

    // 更新奖励的情况
    function updateReward() private  {
        uint256 GuessBettorNums = (guessListMap[hgmGlobalId]).length;
        for(uint256 i = 0; i < GuessBettorNums; i++) {
            GuessBettor storage gb = guessListMap[hgmGlobalId][i];
            WinningResult memory wr = WinningMap[hgmGlobalId];
            if (gb.betType == uint256(BettorType.Big) && (wr.sumResult >= 14 && wr.sumResult <= 27)) {
                gb.isReward = true;
                uint256 _reWardVale = gb.value.mul(195).div(100);
                gb.reWardVale = _reWardVale; // 1.95
                updateRewardLists(gb.account, gb.hgmId, gb.index, _reWardVale);
                continue;
            }
            if (gb.betType == uint256(BettorType.Small) && (wr.sumResult >= 0 && wr.sumResult <= 13)) {
                gb.isReward = true;
                uint256 _reWardVale = gb.value.mul(195).div(100);
                gb.reWardVale = _reWardVale; // 1.95
                updateRewardLists(gb.account, gb.hgmId, gb.index, _reWardVale);
                continue;
            }
            if (gb.betType == uint256(BettorType.Single) && wr.sumResult % 2 == 1) {
                gb.isReward = true;
                uint256 _reWardVale = gb.value.mul(195).div(100);
                gb.reWardVale = _reWardVale; // 1.95
                updateRewardLists(gb.account, gb.hgmId, gb.index, _reWardVale);
                continue;
            }
            if (gb.betType == uint256(BettorType.Double) && wr.sumResult % 2 == 0) {
                gb.isReward = true;
                uint256 _reWardVale = gb.value.mul(195).div(100);
                gb.reWardVale = _reWardVale; // 1.95
                updateRewardLists(gb.account, gb.hgmId, gb.index, _reWardVale);
                continue;
            }
            if (gb.betType == uint256(BettorType.SmallSingle) && wr.sumResult % 2 == 1 && (wr.sumResult >= 0 && wr.sumResult <= 13)) {
                gb.isReward = true;
                uint256 _reWardVale = gb.value.mul(195).div(100);
                gb.reWardVale = _reWardVale; // 4.87
                updateRewardLists(gb.account, gb.hgmId, gb.index, _reWardVale);
                continue;
            }
            if (gb.betType == uint256(BettorType.SmallDouble) && wr.sumResult % 2 == 0 && (wr.sumResult >= 0 && wr.sumResult <= 13)) {
                gb.isReward = true;
                uint256 _reWardVale = gb.value.mul(325).div(100);
                gb.reWardVale = _reWardVale; // 3.25
                updateRewardLists(gb.account, gb.hgmId, gb.index, _reWardVale);
                continue;
            }
            if (gb.betType == uint256(BettorType.BigSingle) && wr.sumResult % 2 == 1 && (wr.sumResult >= 14 && wr.sumResult <= 27)) {
                gb.isReward = true;
                uint256 _reWardVale = gb.value.mul(325).div(100); // 3.25;
                gb.reWardVale = _reWardVale;
                updateRewardLists(gb.account, gb.hgmId, gb.index, _reWardVale);
                continue;
            }
            if (gb.betType == uint256(BettorType.BigDouble)  && wr.sumResult % 2 == 0 && (wr.sumResult >= 14 && wr.sumResult <= 27)) {
                gb.isReward = true;
                uint256 _reWardVale = gb.value.mul(487).div(100);
                gb.reWardVale = _reWardVale; // 4.87
                updateRewardLists(gb.account, gb.hgmId, gb.index, _reWardVale);
                continue;
            }
            if (gb.betType == uint256(BettorType.Dragon) && wr.numberList[0] > wr.numberList[2]) {
                gb.isReward = true;
                uint256 _reWardVale = gb.value.mul(200).div(100); // 2
                gb.reWardVale = _reWardVale;
                updateRewardLists(gb.account, gb.hgmId, gb.index, _reWardVale);
                continue;
            }
            if (gb.betType == uint256(BettorType.Tiger) && wr.numberList[0] < wr.numberList[2]) {
                gb.isReward = true;
                uint256 _reWardVale = gb.value.mul(200).div(100); // 2
                gb.reWardVale = _reWardVale;
                updateRewardLists(gb.account, gb.hgmId, gb.index, _reWardVale);
                continue;
            }
            if (gb.betType == uint256(BettorType.Combine) && wr.numberList[0] == wr.numberList[2]) {
                gb.isReward = true;
                uint256 _reWardVale = gb.value.mul(800).div(100); // 8
                gb.reWardVale = _reWardVale;
                updateRewardLists(gb.account, gb.hgmId, gb.index, _reWardVale);
                continue;
            }
            if (gb.betType == uint256(BettorType.BaccaratBanker) && wr.bankerNumber > wr.idleNumber) {
                gb.isReward = true;
                uint256 _reWardVale = gb.value.mul(200).div(100); // 2
                gb.reWardVale = _reWardVale;
                updateRewardLists(gb.account, gb.hgmId, gb.index, _reWardVale);
                continue;
            }
            if (gb.betType == uint256(BettorType.BaccaratIdle) && wr.bankerNumber < wr.idleNumber) {
                gb.isReward = true;
                uint256 _reWardVale = gb.value.mul(200).div(100); // 2
                gb.reWardVale = _reWardVale;
                updateRewardLists(gb.account, gb.hgmId, gb.index, _reWardVale);
                continue;
            }
            if (gb.betType == uint256(BettorType.BaccaratSame)  && wr.bankerNumber == wr.idleNumber) {
                gb.isReward = true;
                uint256 _reWardVale = gb.value.mul(800).div(100); // 8
                gb.reWardVale = _reWardVale;
                updateRewardLists(gb.account, gb.hgmId, gb.index, _reWardVale);
                continue;
            }
        }
    }

    // 根据区块难度生成随机数
    function createRandomByDifficulty(uint256 _percent) private view returns(uint256) {
        uint256 randFactor = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % _percent;
        bytes32 randomKk = keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, randFactor));
        uint256 random = uint256(randomKk) % _percent;
        return random;
    }

    // 根据块的 gaslimit 生成随机数字
    function createRandomByGaslimit(uint256 _percent) private view returns(uint256) {
        uint256 randFactor = uint256(keccak256(abi.encodePacked(block.timestamp, block.gaslimit, msg.sender))) % _percent;
        bytes32 randomKk = keccak256(abi.encodePacked(block.timestamp, block.gaslimit, msg.sender, randFactor));
        uint256 random = uint256(randomKk) % _percent;
        return random;
    }

    // 根据区块号生成随机数字
    function createRandomByBlock(uint256 _percent) private view returns(uint256) {
        uint256 randFactor = uint256(keccak256(abi.encodePacked(block.timestamp, block.number, msg.sender))) % _percent;
        bytes32 randomKk = keccak256(abi.encodePacked(block.timestamp, block.number, msg.sender, randFactor));
        uint256 random = uint256(randomKk) % _percent;
        return random;
    }

    // 查询往期中奖号码
    function getWinningResultNumlist(uint256 _hgmId) public view returns (uint256[] memory) {
        return WinningMap[_hgmId].numberList;
    }

    // 提取自己的待收取余额
    function withdrawReward() public  {
        uint256  userRewardBalance = userInfoList[msg.sender].rewardBalance;
        require(userRewardBalance > 0, "user's balance is 0");
        userInfoList[msg.sender].rewardBalance = 0;
        require(betteToken.transfer(msg.sender, userRewardBalance));
    }

    //获取下注记录
    function getUserGuessList(address _account, uint256 _hgmId) public view returns (GuessBettor[] memory) {
        return usersGuessListMap[_account][_hgmId];
    } 
}