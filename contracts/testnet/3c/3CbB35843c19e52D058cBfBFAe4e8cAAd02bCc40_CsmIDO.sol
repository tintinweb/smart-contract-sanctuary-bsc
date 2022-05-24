// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IcsmIDO {
    //募集函数
    //参数1 募集份额数量,参数2是否白名单(true则为白名单)
    function IodUsed(uint256 share, bool whitelist) external returns (bool);

    //第二次释放函数
    function twoIdoUsed() external returns (bool);

    //第三次释放函数
    function threeIdoUsed() external returns (bool);

    //关闭募集
    function closeRecruitment() external returns (bool);

    //返回募集用户已募集的量
    function getUserRaiseQuantity(address account)
        external
        view
        returns (uint256);

    //关闭募集资产后，用户提现函数
    function extractUsed() external returns (bool);

    //返回值已募集的份额，第一期募集倒计时，第二期募集倒计时，以及第三次募集倒计时
  function getRaised()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );
    //防止to锁死函数
  function withdraw(address token, uint256 amount) external;

    //关闭事件
    event closureCandy(address indexed owner);
}
contract CsmIDO {
    //单个募集额度上限
    uint256 private constant UsedenterMax = 20;
    //1份金额
    uint256 private constant value = 100 * 1e18;

    //需要募集的份额
    uint256 constant UsedAmoutMax = 10000;

    //已募集的份额
    uint256 AmountRaised;

    //管理者地址
    address private marketingAddress =
        0x4c526bf93DEea923f56D127E9420696A7da9108e;

    address private owner;

    //需要募集的token =>usdt
    IERC20 private Usdt;
    //IDO的token
    address public constant csm = 0x6AB822812606f9f220250C5B932695D628cbD270;

    //募集开启时间
    uint32 private startBlock;
    //募集结束时间
    uint32 private endBlock;

    //第二次释放时间
    uint256 private twoBlock;
    //第三释放时间
    uint256 private threeBloc;

    //用户信息
    struct User {
        uint256 userShare; //用户已购份数
        uint256 amount; //用户募集金额
        uint256 frequency; //第几次释放
        bool whetherToRaise; //是否白名单（按第一次募集时的传参决定）
    }
    //
    //用户映射
    mapping(address => User) public Users;

    //募集开关 默认值false
    bool public raiseSwitch;
    modifier IDOclosure() {
        require(!raiseSwitch, "IDO closed");
        _;
    }
    bool internal locked; //重入bool
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
    modifier isWoner() {
        require(msg.sender == owner, "permission denied");
        _;
    }

    event closureCandy(address indexed owner);

    //需要募集的资金合约，以及募集开启的时间
    constructor(address _Usdt, uint32 _startBlock) {
        Usdt = IERC20(_Usdt);
        startBlock = _startBlock;
        //募集结束时间为开启时间后的第三天  测试需求改成分钟
        endBlock = startBlock + 1440 minutes;
        //默认第二次募集时间为第一次募集结束时间后的40天
        twoBlock = endBlock + 180 minutes;
        //默认第三次募集时间为第二次募集结束时间后的40天
        threeBloc = twoBlock + 180 minutes;
        owner = msg.sender;
    }

    //参与IDO的函数,
    function IodUsed(uint256 share, bool whitelist)
        external
        IDOclosure
        noReentrant
        returns (bool)
    {
        require(
            msg.sender == tx.origin,
            "Limit calls"
        );
        //募集时间必须在开始和结束时间之内
        require(
            block.timestamp >= startBlock && block.timestamp <= endBlock,
            "in time"
        );
        //募集总上限
        require(AmountRaised + share <= UsedAmoutMax, "share cap");

        //获取用户信息
        User storage _Users = Users[msg.sender];

        //用户已购份数不能超过20份
        uint256 _userShare = _Users.userShare + share;
        require(_userShare <= UsedenterMax, "more than");
        //计算份额对应的金额
        uint256 amount = value * share;
        //判断是否是复购
        if (_Users.frequency == 1) {
            //复购 不改变之前白名单状态
            whitelist = _Users.whetherToRaise;
        }
        //判断是否是白名单，转移用户usdt到当前合约地址
        if (whitelist) {
            //白名单  只需转同等数量的usdt
            Usdt.transferFrom(msg.sender, marketingAddress, amount);
        } else {
            //非白名单转过来的usdt*1.2倍
            Usdt.transferFrom(
                msg.sender,
                marketingAddress,
                (amount * 120) / 100
            );
        }
        //给用户转入百分之50的Bogt
        IERC20(csm).transfer(msg.sender, amount / 2);

        uint256 userAaiseAmount = _Users.amount + amount;
        //存入用户信息
        Users[msg.sender] = User({
            userShare: _userShare,
            amount: userAaiseAmount,
            frequency: 1,
            whetherToRaise: whitelist
        });
        //更新已募集
        AmountRaised = AmountRaised + share;
        return true;
    }

    //第二次释放
    function twoIdoUsed() external IDOclosure noReentrant returns (bool) {
        //当前时间要大于第二次区块释放时间
        require(block.timestamp >= twoBlock, "time Small twoBlock");
        //获取用户信息必须是已参与过的用户
        User storage _Users = Users[msg.sender];
        require(_Users.frequency == 1, "the second time");
        //已完成第二次募集
        _Users.frequency = 2;
        //发放4分之1
        IERC20(csm).transfer(msg.sender, _Users.amount / 4);

        return true;
    }

    //第三次释放
    function threeIdoUsed() external IDOclosure noReentrant returns (bool) {
        //当前时间要大于第三次次区块释放时间
        require(block.timestamp >= threeBloc, "time Small threeBloc");
        //获取用户信息
        User storage _Users = Users[msg.sender];
        //必须是已参与的用户
        require(_Users.frequency >= 1, "non-participating users");
        if (_Users.frequency == 1) {
            //目前已经是第三次募集了,用户
            IERC20(csm).transfer(msg.sender, _Users.amount / 2);
            delete Users[msg.sender];

            return true;
        }
        IERC20(csm).transfer(msg.sender, _Users.amount / 4);

       
        delete Users[msg.sender];
        return true;
    }

    //修改第二次，第三次募集时间 保证修改的时间小于原定设定的时间
    function setRaiseTime(uint256 _twoBlock, uint256 _threeBloc)
        external
        isWoner
    {
        require(_twoBlock < twoBlock, "time< twoBlock");
        require(_threeBloc < threeBloc, "time< threeBloc");
        twoBlock = _twoBlock;
        threeBloc = _threeBloc;
    }

    //关闭募集资产后，用户提现函数
    function extractUsed() external noReentrant returns (bool) {
        require(raiseSwitch == true, "not closed");
        User storage _Users = Users[msg.sender];
        //必须是参与的用户
        require(_Users.amount > 0, "non-participating users");
        uint256 amount = _Users.amount;
        //非白名单
        if (!_Users.whetherToRaise) {
            amount = (amount * 120) / 100;
        }
        Usdt.transfer(msg.sender, amount);
        //删除用户信息
        delete Users[msg.sender];
        return true;
    }

    //关闭募集
    function closeRecruitment() external isWoner IDOclosure returns (bool) {
        //调用者必须为管理者
        raiseSwitch = true;
        emit closureCandy(msg.sender);
        return true;
    }

    //返回值已募集的份额，第一期募集倒计时，第二期募集倒计时，以及第三次募集倒计时
    function getRaised()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 _enBlock;
        uint256 _twoBlock;
        uint256 _threeBloc;
        if (endBlock > block.timestamp) {
            _enBlock = endBlock - block.timestamp;
        }
        if (twoBlock > block.timestamp) {
            _twoBlock = twoBlock - block.timestamp;
        }
        if (threeBloc > block.timestamp) {
            _threeBloc = threeBloc - block.timestamp;
        }
        return (AmountRaised, _enBlock, _twoBlock, _threeBloc);
    }
    //募集时间结束  管理员把 u拿走
    function takeUsed() external isWoner returns (bool) {
        //领取时间必须>募集结束时间
        require(block.timestamp >= endBlock, "too early");
        uint256 _thisamount = Usdt.balanceOf(address(this));
        Usdt.transfer(marketingAddress, _thisamount);
        return true;
    }
    function withdraw(address token, uint256 amount) external isWoner {
        require(block.timestamp >= endBlock, "too early");
        IERC20(token).transfer(marketingAddress, amount);
    }
    //返回募集用户已募集的量
    function getUserRaiseQuantity(address account)
        external
        view
        returns (uint256)
    {
        User storage _Users = Users[account];
        return _Users.amount;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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