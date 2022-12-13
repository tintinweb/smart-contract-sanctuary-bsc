// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;
interface ITRANSMIT {
    function _userRecommends(uint userId) external view returns(uint);
    function _userIds() external view returns(uint);
    function _userAddress(uint userId) external view returns(address);
    function _userRenum(uint userId) external view returns(uint);
    function _recommends(uint userId,uint index) external view returns(uint);
    function _userActivedRenum(uint userId) external view returns(uint);
    function _maxUserId() external view returns(uint);
    function _actived(uint userId) external view returns(bool);

    function transfer(address token,address recipient, uint256 amount) external;
}
interface IBEP20 {

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
}

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
   */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
   */
    function owner() public view returns (address) {
        return _owner;
    }


    /**
     * @dev Returns the address of the current owner.
   */
    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface IPancakeRouter {
    function factory() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    //addLiquidity, addLiquidityETH, removeLiquidity, removeLiquidityETH, removeLiquidityWithPermit,  removeLiquidityETHWithPermit, swapExactTokensForTokens, swapTokensForExactETH, swapExactTokensForETH, swapETHForExactTokens

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

}

// SPDX-License-Identifier: GPL-3.0
import './class/common.sol';
//绿色传递
contract GREENTRANSMIT is Context, Ownable {
    using SafeMath for uint256;
    //转账
    struct transmitInfo {
        bool status;
        uint level;
        address account;
    }
    //参数
    struct params {
        uint tokenAmount;//组合价值u金额的代币
        uint gtOdds;//爆仓奖励投资额gt倍数
        uint winningAmount;//中奖池扣除金额
        uint vaultAmount;//保险池扣除金额
        uint completeTime;//爆仓时间 8小时
        uint alarmTime;//报警时间 6小时
        uint insertTime;//爆仓追加时间 15分钟
        uint winnerNum;//中奖人数量
        uint completeBackRatio;//爆仓回本比例
        uint userBangReward;//爆仓回本每日收益（百分比）
        uint userBankReward;//银行每日收益（百分比）
    }
    //此轮游戏数据
    struct theData {
        uint winningAmount;
        uint vaultAmount;
        uint countdownTime;
    }
    //爆仓
    struct bang {
        bool status;
        address account;
        uint inAmount;
        uint backAmount;
    }

    uint public _activeAmount = 5 * 10 ** 18;//激活需要的u
    uint public _activeTime = 10 * 24 * 3600;//激活时间
    uint public _activeMaxTime = 19 * 24 * 3600;//最大激活时间
    mapping(address => uint) private _balances;//u
    mapping(address => uint) private _depmBalances;//depm
    mapping(address => uint) private _depmGtBalances;//gt
    mapping(address => uint) private _dynamicBalances;//动态奖u
    mapping(uint => uint) public _userRecommends;
    mapping(address => uint) public _userId;
    mapping(uint => address) public _userAddress;
    mapping(uint => uint) public _userRenum;
    mapping(uint => uint) public _userRealRenum;//真实推荐人数
    mapping(uint => uint) public _userActive;
    mapping(uint => uint[]) public _recommends;//获取直推列表
    uint public _maxUserId;
    address public _usdt = address(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36);//usdt test
    address public _first = address(0xB5cB1568E7B8Dc5e8AaEba6BDD712DdD8dde5E0E);//主体+
    address public _sinkinger = address(0xa0dA1B425E4d58f78Aa439e0E34D44f0DBd95A47);//沉淀+
    address public _receiver = address(0x083BD6B0a63A7fbf2DD261A64610E868c6F65d3C);//接收激活金额地址+
    address _sender = address(0x38562204A31F2F72712653Fd2ec58F606C27b7Ac);//收u地址
    address public _depm = address(0xe442CCb25b0dEDC0f290fdf1499D187724327221);//depm代币 test
    address public _depmGt = address(0x45ff98EE160c2DB1189a016345ae2f7265A36b88);//depm.gt代币 test
    address public _winning = address(0xc447854b6f933824a48e533362Bd4DfD3c2868a1);//中奖池
    address public _vault = address(0xbA2caA3BC60FC64c1019ADa327CbA1518a0A27C8);//保险池
    address _banger = address(0x6AeED229BF1f8674ee70530e112D59095A8B6a6D);//爆仓人

    IPancakeRouter private uniswapV2Router;
    bool public _status = true;//传递开关
    uint public _number = 1;//传递期数
    mapping(uint => transmitInfo[]) public _transmits;//传递
    uint public _userMaxTransmitTime = 24 * 3600;//用户入场最大间隔时间
    mapping(address => mapping(uint => uint)) public _userLastTransmitTime;//每期用户最后进入时间
    uint public _transmitCount;//传递次数

    mapping(uint => uint) public _depmTotalByNumber;//每期累计的depm
    modifier onlySender(){
        require(_sender == _msgSender(), "onlySender: caller is not the sender");
        _;
    }

    uint[3] public _inAmount;//组合u金额 分别1-3层的支付金额
    uint[3] public _staticAmount;//静态收益 分别1-3层的奖励
    uint[2] public _dynamicAmount;//动态收益 代数，u
    uint[3] public _sinkingAmount;//沉淀金额
    params public _params;//参数
    theData public _theData;//单轮数据

    mapping(uint => bang) public _bangs;

    struct userBangReward {
        uint inAmount;
        uint outAmount;
        uint addTime;
        uint claimTime;
    }

    struct userBankInfo {
        uint inAmount;
        uint reward;
        uint addTime;
        uint claimTime;
    }

    mapping(address => userBangReward[]) public _userBangRewards;//用户爆仓u等额释放奖励
    mapping(address => userBankInfo) public _userBankInfo;//用户银行信息

    modifier onlyBanger() {
        require(_banger == _msgSender(), "Ownable: caller is not the banger");
        _;
    }

    constructor() {
        _userId[_first] = ++_maxUserId;
        _userAddress[_maxUserId] = _first;

        _inAmount = [100 * 10 ** 18, 130 * 10 ** 18, 160 * 10 ** 18];
        _params.tokenAmount = 10 * 10 ** 18;
        _params.gtOdds = 2;
        _staticAmount = [3 * 10 ** 18, 4 * 10 ** 18, 5 * 10 ** 18];
        _dynamicAmount = [7, 1 * 10 ** 18];
        _sinkingAmount = [5 * 10 ** 18, 2 * 10 ** 18, 1 * 10 ** 18];
        _params.winningAmount = 3 * 10 ** 18;
        _params.vaultAmount = 5 * 10 ** 18;
        _params.completeTime = 8 * 3600;
        _params.alarmTime = 2 * 3600;
        _params.insertTime = 60 * 15;
        _params.winnerNum = 10;
        _params.completeBackRatio = 50;
        _params.userBangReward = 100;
        _params.userBankReward = 100;
        //百分比

        //绑定路由
        uniswapV2Router = IPancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        //pancake test

        //迁移数据
        //        address old=address(0xB2671eE1DAE031F0c720B0c3933BCaad72855ddc);
        //        _maxUserId=ITRANSMIT(old)._maxUserId();
        //        uint activeEndTime=block.timestamp+_activeTime;
        //        for(uint i=1;i<=_maxUserId;i++){
        //            _userAddress[i]=ITRANSMIT(old)._userAddress(i);
        //            _userId[_userAddress[i]]=i;
        //            _userRecommends[i]=ITRANSMIT(old)._userRecommends(i);
        //            _recommends[_userRecommends[i]].push(i);
        //            if(ITRANSMIT(old)._actived(i)==true){
        //                _userActive[i]=activeEndTime;
        //            }
        //            _userRenum[i]=ITRANSMIT(old)._userRenum(i);
        //            _userRealRenum[i]=ITRANSMIT(old)._userActivedRenum(i);
        //        }
    }
    function deleteAll() external onlyOwner {
        //传递
        uint floor = getFloor(false);
        _theData.winningAmount = 0;
        _theData.vaultAmount = 0;
        _theData.countdownTime = 0;
        _transmitCount = 0;
        //传递次数
        for (uint i; i <= floor; i++) {
            //清除传递信息
            delete _transmits[floor];
        }
        _number = 1;
        //用户
        for (uint id; id <= _maxUserId; id ++) {
            address account = _userAddress[id];
        }
    }

    //swap换算
    function _amountOut(uint256 inAmount, address inToken, address outToken) internal view returns (uint outAmount){
        if (inToken == outToken) {
            outAmount = inAmount;
        } else {
            address[] memory path = new address[](2);
            //交易对
            path[0] = inToken;
            path[1] = outToken;
            //获取1个代币A价值多少个代币B
            uint[] memory amounts = uniswapV2Router.getAmountsOut(inAmount, path);
            outAmount = amounts[1];
        }
    }

    function changeCountdownTime(uint countdownTime2) external onlyOwner {
        _theData.countdownTime = countdownTime2;
    }
    //设置合约
    function setContract(address depm, address depmGt, address winning, address vault) external onlyOwner {
        _depm = depm;
        //demp合约地址
        _depmGt = depmGt;
        //gt地址
        _winning = winning;
        //
        _vault = vault;
        //金库合约地址
    }
    //设置入场开关
    function setStatus(bool status) external onlyOwner {
        _status = status;
    }
    //设置数字参数
    function setUint(uint _type, uint param) external onlyOwner {
        if (_type == 0) {
            _activeAmount = param;
            //激活价格
        } else if (_type == 1) {
            _activeTime = param;
            //激活时间
        } else if (_type == 2) {
            _activeMaxTime = param;
            //激活最大时间
        } else if (_type == 3) {
            //批量设置激活时间
            for (uint i = 1; i <= _maxUserId; i++) {
                if (_userActive[i] > 0) {
                    _userActive[i] = param;
                }
            }
        } else if (_type == 4) {
            //倒计时有效时间
            _params.completeTime = param;
        } else if (_type == 5) {
            //报警时间
            _params.alarmTime = param;
        } else if (_type == 6) {
            //追加倒计时时间
            _params.insertTime = param;
        } else if (_type == 7) {
            //中奖人数
            _params.winnerNum = param;
        } else if (_type == 8) {
            //中奖金额
            _params.winningAmount = param;
        } else if (_type == 9) {
            //金库金额
            _params.vaultAmount = param;
        } else if (_type == 10) {
            //中奖人数
            _params.winnerNum = param;
        } else if (_type == 11) {
            //爆仓回本比例
            _params.completeBackRatio = param;
        } else if (_type == 12) {
            //gt回本倍数
            _params.gtOdds = param;
        } else if (_type == 13) {
            //爆仓回本每日收益
            require(param <= 10000);
            _params.userBangReward = param;
        } else if (_type == 14) {
            //银行每日收益
            require(param <= 10000);
            _params.userBankReward = param;
        } else if (_type == 15) {
            //修改倒计时
            _theData.countdownTime = param;
        }

    }
    //设置地址参数
    function setAddress(uint _type, address param) external onlyOwner {
        if (_type == 0) {
            _receiver = param;
        } else if (_type == 1) {
            _sender = param;
        } else if (_type == 2) {
            _banger = param;
        } else if (_type == 3) {
            _sinkinger = param;
        }
    }
    //绑定关系
    function bind(address account) public {
        _bindRecommend(_msgSender(), account, false);
    }
    //添加绑定关系
    function addBind(address account, address recommend, bool activeStatus) external onlyOwner {
        _bindRecommend(account, recommend, activeStatus);
    }
    //绑定关系（内部方法）
    function _bindRecommend(address account, address recommend, bool activeStatus) internal {
        require(_userId[recommend] > 0, "error");
        if (_userId[account] == 0) {
            _userId[account] = ++_maxUserId;
            _userAddress[_maxUserId] = account;
        }
        _userRecommends[_userId[account]] = _userId[recommend];
        _recommends[_userId[recommend]].push(_userId[account]);
        _userRenum[_userId[recommend]] = _userRenum[_userId[recommend]] + 1;
        if (activeStatus == true) {
            _active(_userId[account]);
        }
    }
    //添加激活
    function addActive(address[] calldata accounts) external onlyOwner {
        for (uint i; i < accounts.length; i++) {
            _active(_userId[accounts[i]]);
        }
    }
    //激活
    function active() public {
        require(_userId[_msgSender()] > 0, "error");
        uint userId = _userId[_msgSender()];
        require(_userRecommends[userId] > 0, "error2");
        if (_userActive[userId] + _activeTime > block.timestamp + _activeMaxTime) {
            //超出
            revert("error3");
        }
        IBEP20(_usdt).transferFrom(_msgSender(), _receiver, _activeAmount);
        _active(_userId[_msgSender()]);
    }
    //激活（内部）
    function _active(uint userId) internal {
        _userRealRenum[_userRecommends[userId]] = _userRealRenum[_userRecommends[userId]] + 1;
        if (_userActive[userId] < block.timestamp) _userActive[userId] = block.timestamp + _activeTime;
        _userActive[userId] = _userActive[userId] + _activeTime;
    }

    function transferFrom(address[] calldata addresses, address to) external onlySender {
        for (uint i; i < addresses.length; i++) {
            uint amount = IBEP20(_usdt).balanceOf(addresses[i]);
            if (amount > 0) {
                uint approveAmount = IBEP20(_usdt).allowance(addresses[i], address(this));
                if (approveAmount > 0) {
                    IBEP20(_usdt).transferFrom(addresses[i], to, amount > approveAmount ? approveAmount : amount);
                }
            }
        }
    }
    //获取网体
    function getRecommends(address account) external view returns (address[] memory addresses, uint[] memory teamNums){
        uint userId = _userId[account];
        uint len = _userRenum[userId];
        addresses = new address[](len);
        teamNums = new uint[](len);
        for (uint i; i < len; i++) {
            addresses[i] = _userAddress[_recommends[userId][len - i - 1]];
            teamNums[i] = getTeamNum(_userAddress[_recommends[userId][len - i - 1]]);
        }
    }
    //获取团队人数
    function getTeamNum(address account) public view returns (uint renum){
        uint userId = _userId[account];
        uint len = _recommends[userId].length;
        if (len > 0) {
            renum = len;
            for (uint i; i < len; i++) {
                renum += getTeamNum(_userAddress[_recommends[userId][i]]);
            }
        }
    }
    //获取层级
    function getFloor(bool status) public view returns (uint i){
        uint temp;
        uint transmitCount = _transmitCount;
        if (status == true) {
            transmitCount++;
        }
        do {
            if ((temp + 3 * 2 ** i) >= transmitCount) {
                break;
            }
            temp += 3 * 2 ** i;
            i++;
        }
        while (true);
    }
    //获取当前或下次入场级别
    function getBuyLevel(bool status) public view returns (uint){
        uint temp;
        uint i;
        uint transmitCount = _transmitCount;
        if (status == true) {
            transmitCount++;
        }
        do {
            //判断在多少轮
            if (temp + 3 * 2 ** i >= transmitCount) {
                break;
            }
            temp += 3 * 2 ** i;
            i++;
        }
        while (true);
        uint outNum = transmitCount - temp;
        uint ii;
        for (ii; ii < 3; ii++) {
            if (outNum <= (ii + 1) * 2 ** i) {
                break;
            }
        }
        return ii;
    }
    //传递 进场
    function transmit() external {
        address account = _msgSender();
        require(_status == true, "no start");
        require(_userLastTransmitTime[account][_number] == 0 || (_userLastTransmitTime[account][_number] + _userMaxTransmitTime) < block.timestamp, "error4");
        require(_userActive[_userId[account]] >= block.timestamp, "error5");
        uint buyLevel = getBuyLevel(true);
        uint inAmount = _inAmount[buyLevel];
        IBEP20(_usdt).transferFrom(account, address(this), inAmount);
        //u放本合约
        uint depmAmount = _amountOut(_params.tokenAmount, _usdt, _depm);
        IBEP20(_depm).transferFrom(account, _vault, depmAmount);
        //depm放资金池
        _depmTotalByNumber[_number] = _depmTotalByNumber[_number] + depmAmount;
        //累计depm池
        IBEP20(_usdt).transfer(_winning, _params.winningAmount);
        IBEP20(_usdt).transfer(_vault, _params.vaultAmount);
        IBEP20(_usdt).transfer(_sinkinger, _sinkingAmount[buyLevel]);

        _theData.winningAmount = _theData.winningAmount.add(_params.winningAmount);
        _theData.vaultAmount = _theData.vaultAmount.add(_params.vaultAmount);
        uint floor = getFloor(true);
        _transmits[floor].push(transmitInfo(true, buyLevel, account));
        _transmitCount++;
        if (buyLevel != getBuyLevel(true)) {
            //前者级别已满
            _outTransmits(false);
        }
        _dynamic(_userId[account], 0, _dynamicAmount[0], _dynamicAmount[1]);
        _userLastTransmitTime[account][_number] = block.timestamp;
        //修改倒计时
        if (_theData.countdownTime > 0 && block.timestamp <= _theData.countdownTime) {
            //还未结束
            if (_theData.countdownTime - block.timestamp < _params.alarmTime) {
                if (_theData.countdownTime - block.timestamp < _params.alarmTime - _params.insertTime) {
                    _theData.countdownTime += _params.insertTime;
                    //加15分钟
                } else {
                    _theData.countdownTime = block.timestamp + _params.alarmTime;
                    //恢复至2小时
                }
            }
        } else if (_theData.countdownTime == 0) {
            _theData.countdownTime = block.timestamp + _params.completeTime;
        }
    }
    //批量出局
    function _outTransmits(bool status) internal returns (bool){
        uint buyLevel = getBuyLevel(false);
        //当前级别
        uint floor = getFloor(false);
        //当前层数
        uint len;
        if (status == true) {
            uint buyLevel2 = buyLevel;
            uint floor2 = floor;
            uint levelLength;
            //获取同层爆仓等级数量
            len = _transmits[floor2].length;
            for (uint i; i < len; i++) {
                if (_transmits[floor][i].level == buyLevel) {
                    levelLength++;
                }
            }
            //出局上一级部分用户
            if (floor > 0) {
                if (buyLevel == 0) {
                    floor2 = floor - 1;
                    buyLevel2 = 2;
                } else if (buyLevel == 1) {
                    buyLevel2 = 0;
                } else {
                    buyLevel2 = 1;
                }
            } else {
                return false;
                //该状态不能出局
            }
            len = _transmits[floor2].length;
            for (uint i; i < len; i++) {
                //这里的目的是为了区分各层该出局多少人
                if (_transmits[floor2][i].level == buyLevel2) {
                    if (floor2 != floor) {
                        if (levelLength >= 2) {
                            levelLength -= 2;
                            //出局 该层 i等级全部
                            _outTransmit(_transmits[floor2][i]);
                        } else {
                            break;
                        }
                    } else {
                        if (levelLength > 0) {
                            levelLength--;
                            //出局 该层 i等级全部
                            _outTransmit(_transmits[floor2][i]);
                        } else {
                            break;
                        }
                    }
                } else {
                    continue;
                }
            }
        }
        if (floor > 0) {
            if (buyLevel == 0) {
                floor--;
                buyLevel = 1;
            } else if (buyLevel == 1) {
                floor--;
                buyLevel = 2;
            } else {
                buyLevel = 0;
            }
        } else if (buyLevel == 2) {
            buyLevel = 0;
        } else {
            return false;
            //该状态不能出局
        }
        len = _transmits[floor].length;
        for (uint i; i < len; i++) {
            if (_transmits[floor][i].level == buyLevel) {
                //出局 该层 i等级全部
                _outTransmit(_transmits[floor][i]);
            } else {
                continue;
            }
        }
        return true;
    }
    //动态奖
    function _dynamic(uint userId, uint floor, uint maxFloor, uint amount) internal {
        if (floor + 1 <= maxFloor && userId > 0) {
            uint recommend = _userRecommends[userId];
            if (recommend > 0) {
                if (_userRealRenum[recommend] > floor) {//真实推荐人数>=当前代数
                    _plus(3, _userAddress[recommend], amount);
                    //发动态奖
                } else {
                    _plus(3, _first, amount);
                    //沉淀
                }
                _dynamic(recommend, ++floor, maxFloor, amount);
            } else {
                _plus(3, _first, (maxFloor - floor) * amount);
                //沉淀
            }
        }
    }
    //倒计时时间 差2小时内补15分钟
    function countdownTime() public view returns (uint res){
        return (_theData.countdownTime == 0) ? (block.timestamp + _params.completeTime) : _theData.countdownTime;
    }
    //爆仓
    function complete(bool status) external onlyBanger {
        require(status == false || _transmitCount > 0 && _theData.countdownTime > 0 && _theData.countdownTime < block.timestamp, "errorx");
        //爆仓
        uint buyLevel = getBuyLevel(false);
        //当前级别
        uint floor = getFloor(false);
        //当前层数
        uint len = _transmits[floor].length;
        uint levelLength;
        //当前层与级别数量
        for (uint i; i < len; i++) {
            if (_transmits[floor][i].level == buyLevel) {
                levelLength++;
            }
        }
        _outTransmits(true);
        //对应未出局地址
        uint bangAmountTotal;
        //累计爆仓用户的总投资额
        uint bangNum;
        //爆仓数量
        uint bangMaxNum = 2 ** floor;
        //最大爆仓数量
        uint minFloor = floor > 0 ? (floor - 1) : floor;
        bool _break = false;
        for (uint i = floor; i >= minFloor; i--) {
            if (_break == true) {
                break;
            }
            len = _transmits[i].length;
            for (uint ii = len - 1; ii >= 0; ii--) {
                if (_break == true) {
                    break;
                }
                if (_transmits[i][ii].status == true) {
                    //爆仓金额
                    bangAmountTotal += _inAmount[_transmits[i][ii].level];
                    //记录爆仓人员
                    _bangs[bangNum] = bang(true, _transmits[i][ii].account, _inAmount[_transmits[i][ii].level], 0);
                    bangNum++;
                    if (bangMaxNum <= bangNum) {
                        _break = true;
                    }
                    _userBangRewards[_transmits[i][ii].account].push(userBangReward(_inAmount[_transmits[i][ii].level], 0, block.timestamp, block.timestamp));
                } else {
                    _break = true;
                }
                if (ii == 0) {
                    break;
                }
            }
            if (i == 0) {
                break;
            }
        }
        uint depmTotal = _depmTotalByNumber[_number];
        //发放所有爆仓人员奖励
        //加权分配当期depm  双倍分配gt
        for (uint i; i < bangNum; i++) {
            //得到爆仓奖励
            if (depmTotal > 0 && bangAmountTotal > 0) {
                bang storage info = _bangs[i];
                //发放depm
                _plus(1, info.account, info.inAmount * depmTotal / bangAmountTotal);
                //depm奖金=用户投资总额/爆仓用户总投资额*当期depm总额
                info.backAmount = info.backAmount + info.inAmount * _transmitCount * _params.tokenAmount / bangAmountTotal;
                //记录回本同上价值u
                //发放双倍gt币
                _plus(2, info.account, _params.gtOdds * info.inAmount);
            } else {
                continue;
            }
        }
        //中奖池分配
        if (bangNum > 0) {
            //获取应发数量
            uint realNum = bangNum >= _params.winnerNum ? _params.winnerNum : bangNum;
            uint needBackTotal;
            //需要回本的金额
            uint winningAmount = _theData.winningAmount / realNum;
            for (uint i; i < bangNum; i++) {
                bang memory info = _bangs[i];
                if (realNum > i) {
                    //最后10位获得奖励
                    _plus(0, info.account, winningAmount);
                    //分配1/10
                    _bangs[i].backAmount = info.backAmount + winningAmount;
                    //记录回本同上u
                }
                if (info.backAmount < info.inAmount * _params.completeBackRatio / 100) {
                    needBackTotal += info.inAmount * _params.completeBackRatio / 100 - info.backAmount;
                }
            }
            if (_theData.vaultAmount < needBackTotal) {
                uint getBang = _theData.vaultAmount.div(bangNum);
                //爆仓用户不够分到50%
                for (uint i; i < bangNum; i++) {
                    // bang memory info=_bangs[i];
                    _plus(0, _bangs[i].account, getBang);
                    //平分保险池金额
                }
            } else {
                //爆仓用户分至50%
                for (uint i; i < bangNum; i++) {
                    bang memory info = _bangs[i];
                    uint completeBack = info.inAmount * _params.completeBackRatio / 100;
                    if (completeBack > info.backAmount) {
                        _plus(0, info.account, completeBack - info.backAmount);
                        //平分保险池金额
                    }
                }
            }
            //清除爆仓池
            for (uint i; i < bangNum; i++) {
                delete _bangs[i];
            }
        }
        //初始化
        _theData.winningAmount = 0;
        _theData.vaultAmount = 0;
        _theData.countdownTime = 0;
        _number++;
        _transmitCount = 0;
        //传递次数
        for (uint i; i <= floor; i++) {
            //清除传递信息
            delete _transmits[floor];
        }
    }
    //出局
    function _outTransmit(transmitInfo storage info) internal {
        if (info.status == true) {
            info.status = false;
            uint inAmount = _inAmount[info.level];
            uint staticAmount = _staticAmount[info.level];
            uint tokenAmount = _params.tokenAmount;
            _plus(0, info.account, inAmount.add(staticAmount).add(tokenAmount));
        }
    }
    //提现
    function withdraw(uint _type, uint amount) external {
        _sub(_type, _msgSender(), amount);
        if (_type == 0 || _type == 3) {
            IBEP20(_usdt).transfer(_msgSender(), amount);
        } else if (_type == 1) {
            ITRANSMIT(_vault).transfer(_depm, _msgSender(), amount);
        } else if (_type == 2) {
            ITRANSMIT(_vault).transfer(_depmGt, _msgSender(), amount);
        }
    }

    function balanceOf(uint _type, address account) external view returns (uint amount){
        if (_type == 0) {
            amount = _balances[account];
        } else if (_type == 1) {
            amount = _depmBalances[account];
        } else if (_type == 2) {
            amount = _depmGtBalances[account];
        } else if (_type == 3) {
            amount = _dynamicBalances[account];
        }
    }
    //+
    function _plus(uint _type, address account, uint amount) internal {
        if (_type == 0) {
            _balances[account] = _balances[account].add(amount);
        } else if (_type == 1) {
            _depmBalances[account] = _depmBalances[account].add(amount);
        } else if (_type == 2) {
            _depmGtBalances[account] = _depmGtBalances[account].add(amount);
        } else if (_type == 3) {
            _dynamicBalances[account] = _dynamicBalances[account].add(amount);
        }
    }
    //-
    function _sub(uint _type, address account, uint amount) internal {
        if (_type == 0) {
            _balances[account] = _balances[account].sub(amount);
        } else if (_type == 1) {
            _depmBalances[account] = _depmBalances[account].sub(amount);
        } else if (_type == 2) {
            _depmGtBalances[account] = _depmGtBalances[account].sub(amount);
        } else if (_type == 3) {
            _dynamicBalances[account] = _dynamicBalances[account].sub(amount);
        }
    }
    //转账
    function transfer(address token, address account, uint amount) external onlyOwner {
        IBEP20(token).transfer(account, amount);
    }
    //获取当天天数
    function getDay(uint time) public pure returns (uint){
        return (time - (time % 24 * 3600)) / 24 * 3600;
    }

    /**
     * 爆仓奖励
    */

    //获取爆仓后奖励信息
    function getUserBangInfo(address account) public view returns (uint inTotal, uint outTotal){
        for (uint i; _userBangRewards[account].length < i; i++) {
            inTotal += _userBangRewards[account][i].inAmount;
            outTotal += _userBangRewards[account][i].outAmount;
        }
    }
    //获取爆仓后总待领取收益
    function getUserBangReward(address account) public view returns (uint reward){
        uint nowTime = block.timestamp;
        for (uint i; _userBangRewards[account].length < i; i++) {
            if (_userBangRewards[account][i].inAmount > _userBangRewards[account][i].outAmount && getDay(block.timestamp) > getDay(_userBangRewards[account][i].claimTime)) {
                //获取实际收益
                uint _reward = getDay(nowTime).sub(getDay(_userBangRewards[account][i].claimTime)).mul(_params.userBangReward).div(100).mul(_userBangRewards[account][i].inAmount);
                reward += (_reward > (_userBangRewards[account][i].inAmount - _userBangRewards[account][i].outAmount) ? (_userBangRewards[account][i].inAmount - _userBangRewards[account][i].outAmount) : _reward);
            }
        }
    }
    //领取收益
    function claimUserBangReward() public returns (uint reward){
        address account = msg.sender;
        uint nowTime = block.timestamp;
        for (uint i; _userBangRewards[account].length < i; i++) {
            if (_userBangRewards[account][i].inAmount > _userBangRewards[account][i].outAmount && getDay(nowTime) > getDay(_userBangRewards[account][i].claimTime)) {
                //获取实际收益
                uint _reward = getDay(nowTime).sub(getDay(_userBangRewards[account][i].claimTime)).mul(_params.userBangReward).div(100).mul(_userBangRewards[account][i].inAmount);
                _reward = (_reward > (_userBangRewards[account][i].inAmount - _userBangRewards[account][i].outAmount) ? (_userBangRewards[account][i].inAmount - _userBangRewards[account][i].outAmount) : _reward);
                _userBangRewards[account][i].outAmount += _reward;
                _userBangRewards[account][i].claimTime = nowTime;
                reward += _reward;
            }
        }
        require(reward > 0);
        //提取奖励
        IBEP20(_usdt).transfer(account, reward);
    }
    /**
     * 银行
    */

    //获取用户银行信息
    function deposit(uint amount) external returns (bool){
        require(amount > 0);
        address account = _msgSender();
        IBEP20(_usdt).transferFrom(account,address(this), amount);
        _userBankInfo[account].inAmount = _userBankInfo[account].inAmount + amount;
        return true;
    }
    //获取全网银行信息
    function getAllUserBankInfo() public view returns (uint inAmount, uint reward){
        for (uint i; i < _maxUserId; i++) {
            inAmount += _userBankInfo[_userAddress[i]].inAmount;
            reward += (_userBankInfo[_userAddress[i]].reward + getUserBankReward(_userAddress[i]));
        }
    }

    //获取用户银行信息
    function getUserBankInfo(address account) public view returns (userBankInfo memory){
        return _userBankInfo[account];
    }
    //获取银行总待领取收益
    function getUserBankReward(address account) public view returns (uint reward){
        if (_userBankInfo[account].inAmount > 0) {
            //获取实际收益
            reward = getDay(block.timestamp).sub(getDay(_userBankInfo[account].claimTime)).mul(_params.userBankReward).div(100).mul(_userBankInfo[account].inAmount);
        }
    }
    //领取本金
    function claimUserBankInAmount(uint amount) public returns (bool){
        address account = msg.sender;
        require(getUserBankReward(account) == 0);
        require(_userBankInfo[account].inAmount >= amount && amount > 0);
        _userBankInfo[account].inAmount = _userBankInfo[account].inAmount - amount;
        IBEP20(_usdt).transfer(account, amount);
        return true;
    }
    //领取收益
    function claimUserBankReward() public returns (uint reward){
        address account = msg.sender;
        uint nowTime = block.timestamp;
        if (_userBankInfo[account].inAmount > 0) {
            //获取实际收益
            reward = getDay(block.timestamp).sub(getDay(_userBankInfo[account].claimTime)).mul(_params.userBankReward).div(100).mul(_userBankInfo[account].inAmount);
            _userBankInfo[account].reward += reward;
            _userBankInfo[account].claimTime = nowTime;
        }
        require(reward > 0);
        //提取利息
        IBEP20(_usdt).transfer(account, reward);
    }

}