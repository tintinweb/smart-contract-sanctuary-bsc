// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;


interface IERC20 {
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
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract FTC is IERC20 {
    using SafeMath for uint256;
    //用户内部持有的实际币数量
    mapping(address => uint256) private _rOwned;
    //只用于非分红用户的转账
    mapping(address => uint256) private _tOwned;
    //类似于ERC20的allowance，指用户授权某些账户的可使用额度
    mapping(address => mapping(address => uint256)) private _allowances;
    //账户白名单，用来判断是否需要转账手续费
    mapping(address => bool) private _isExcludedFromFee;

    uint256 private constant MAX = ~uint256(0);
    //对外-总量
    uint256 private _tTotal;
    //对内-实际量
    uint256 private _rTotal;
    //收取的手续费
    uint256 private _tFeeTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;

    //市值管理
    address private _marketAddress = address(0x601927D8eC1617b6AE06aB063Ed0dd14ca28Ce5e);
    //生态营销
    address private _ecoAddress = address(0x8b3cFEd42390e5483e359e56d52e368E666F8Ff6);
    //nft 分红
    address private _nftAwardAddress = address(0x608CF2283D7Cb996f97e8DDDc4A434BDfCECad3a);

    uint256 public _LockTime;
    //上线12个月内每个用户最多持有12枚FTC，12月后开放限制
    uint256 public _balanceLmtTime;

    event eveSetInitLockTime(uint256 lockTime);
    event eveSetBalanceLmtTime(uint256);

    address public uniswapV2Pair;
    bool public swapAction = true;

    IERC20 usdt;

    uint256 public _initPrice = 10;

    event eveSetInitAmount(uint256 nfree_amount);


    //关系链
    mapping(address => address) public inviter;

    //累计注入保险金 1000
    uint256 public _insureTotal;

    //质押累计产出 6900
    uint256 public _releaseTotal;

    //当前质押总量
    uint256 public _curTotalDeposit = 0;

    //用户质押信息
    struct UserInfo {
        //剩余质押量
        uint256 _restStake;
        //剩余收益
        uint256 _restAward;
        //已领取收益
        uint256 _earnAward;
    }

    //质押信息
    mapping(address => UserInfo) public _deposits;

    //领取信息
    struct Profit {
        uint256 _time;
        uint256 _num;
    }
    //游标
    mapping(address => uint256) public _profitIds;
    //领取记录
    mapping(address => mapping(uint256 => Profit)) public _profits;

    //质押事件
    event Deposit(address, uint256);
    //解锁事件
    event Release(address, uint256);
    //领取事件
    event Claim(address, uint256);


    //质押用户列表
    address[] public allDepositAddr;


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;


    modifier lock() {
        _lockBefore();
        _;
        _lockAfter();
    }

    function _lockBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _lockAfter() private {
        _status = _NOT_ENTERED;
    }

    address public _owner;


    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }


    constructor(IERC20 _usdt) {
        _name = "FUTURE COIN";
        _symbol = "FTC";
        _decimals = 18;
        _tTotal = 10000 * 10 ** _decimals;

        usdt = _usdt;

        _status = _NOT_ENTERED;

        _rTotal = (MAX - (MAX % _tTotal));

        _rOwned[msg.sender] = _rTotal.div(100).mul(21);
        _rOwned[address(this)] = _rTotal.div(100).mul(79);

        _isExcludedFromFee[msg.sender] = true;
        _owner = msg.sender;

        _LockTime = block.timestamp;
        _balanceLmtTime = _LockTime + 365 days;
        //保险金1000
        _insureTotal = 1000 * 10 ** _decimals;
        //挖矿产出 6900
        _releaseTotal = 6900 * 10 ** _decimals;
        emit Transfer(address(0), msg.sender, _tTotal.div(100).mul(21));
        emit Transfer(address(0), address(this), _tTotal.div(100).mul(79));
    }

    function setInitAmount(uint256 _amount) public onlyOwner {
        _initPrice = _amount;
        emit eveSetInitAmount(_initPrice);
    }


    function setInitLockTime(uint256 lockTime) public onlyOwner {
        _LockTime = lockTime;
        emit eveSetInitLockTime(_LockTime);
    }

    function setBalanceLmtTime(uint256 _time) public onlyOwner {
        _balanceLmtTime = _time;
        emit eveSetBalanceLmtTime(_balanceLmtTime);
    }


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
    public
    override
    returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
    public
    view
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
    public
    override
    returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if (uniswapV2Pair == address(0) && amount >= _tTotal.div(100)) {
            uniswapV2Pair = recipient;
        }
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount)
    public
    view
    returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    function changeswapAction() public onlyOwner {
        swapAction = !swapAction;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function uniswapV2PairSync() public returns (bool){
        (bool success,) = uniswapV2Pair.call(abi.encodeWithSelector(0xfff6cae9));
        return success;
    }

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // 转账
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");


        if (block.timestamp <= _balanceLmtTime && to != uniswapV2Pair && to != address(this))
        {
            UserInfo storage user = _deposits[to];
            uint256 preValue = balanceOf(to).add(amount).add(user._restStake);
            require(preValue <= 12 * 10 ** _decimals, "ERC20: no more than 12");
        }


        _updateBill();
        uint256 balanceERC = balanceOf(uniswapV2Pair);
        //1000枚底池保险金（当底池低于200枚FTC，保险金分10次每次100FTC自动回流底池护盘
        if (balanceERC > 0 && balanceERC <= 200 * 10 ** _decimals && _insureTotal > 0)
        {
            _tokenTransfer(address(this), uniswapV2Pair, 100 * 10 ** _decimals, false);
            _insureTotal = _insureTotal.sub(100 * 10 ** _decimals);
        }


        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            _tokenTransfer(from, to, amount, false);
        } else {
            if (from != uniswapV2Pair && to != uniswapV2Pair) {
                _tokenTransfer(from, to, amount, false);
            } else {
                _tokenTransfer(from, to, amount, true);
            }
        }

        //to未绑定、from 、to都非合约地址
        bool shouldInvite = (inviter[to] == address(0) && !isContract(from) && !isContract(to));

        if (shouldInvite) {
            inviter[to] = from;
        }


    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);

        uint256 rate;
        uint256 _linFee = 0;

        if (sender == _owner) {
            rate = 0;
        } else {
            if (takeFee) {
                if (sender == uniswapV2Pair) {
                    // buy 买入
                    // 9
                    //7%回流底池  2%市值管理
                    rate = 9;
                    uint256 _lpRate = 7;
                    uint256 _marketRte = 2;

                    _rOwned[uniswapV2Pair] = _rOwned[uniswapV2Pair].add(
                        rAmount.div(100).mul(_lpRate)
                    );
                    _rOwned[_marketAddress] = _rOwned[_marketAddress].add(
                        rAmount.div(100).mul(_marketRte)
                    );

                    emit Transfer(sender, uniswapV2Pair, tAmount.div(100).mul(_lpRate));
                    emit Transfer(sender, _marketAddress, tAmount.div(100).mul(_marketRte));

                } else if (recipient == uniswapV2Pair) {
                    // sell
                    //11
                    // 直推3%，间推2%，第三层1%，后五层共1%每层0.2%,0.2%,0.2%,0.2%,0.2%,合计八层。
                    // 2%回流底池   1%生态营销（转入一个地址）   1%NFT分红（转入一个地址）

                    rate = 11;


                    address cur = sender;
                    // 直推3%，间推2%，第三层1%，后五层共1%每层0.2%,0.2%,0.2%,0.2%,0.2%,合计八层。
                    uint8[8] memory inviteRate = [30, 20, 10, 2, 2, 2, 2, 2];

                    for (uint8 i = 0; i < inviteRate.length; i++) {
                        cur = inviter[cur];
                        if (cur == address(0)) {
                            cur = uniswapV2Pair;
                            //如果没有推荐地址，回流底池
                        }
                        else {

                            //上级是否有持仓限制
                            if (block.timestamp <= _balanceLmtTime)
                            {
                                uint256 tmpAmount = tAmount.div(1000).mul(inviteRate[i]);
                                UserInfo storage user = _deposits[cur];
                                uint256 preValue = balanceOf(cur).add(tmpAmount).add(user._restStake);
                                if (preValue > 12 * 10 ** _decimals)
                                {
                                    cur = uniswapV2Pair;
                                }

                            }


                        }

                        _rOwned[cur] = _rOwned[cur].add(
                            rAmount.div(1000).mul(inviteRate[i])
                        );

                        emit Transfer(sender, cur, tAmount.div(1000).mul(inviteRate[i]));
                    }


                    _rOwned[uniswapV2Pair] = _rOwned[uniswapV2Pair].add(
                        rAmount.div(100).mul(2)
                    );

                    _rOwned[_ecoAddress] = _rOwned[_ecoAddress].add(
                        rAmount.div(100).mul(1)
                    );

                    _rOwned[_nftAwardAddress] = _rOwned[_nftAwardAddress].add(
                        rAmount.div(100).mul(1)
                    );

                    emit Transfer(sender, uniswapV2Pair, tAmount.div(100).mul(2));
                    emit Transfer(sender, _ecoAddress, tAmount.div(100).mul(1));
                    emit Transfer(sender, _nftAwardAddress, tAmount.div(100).mul(1));

                    // 检测暴跌
                    uint256 balanceUsdt = usdt.balanceOf(uniswapV2Pair);
                    uint256 balanceERC = balanceOf(uniswapV2Pair);

                    uint price = balanceERC.div(balanceUsdt);

                    if (price <= _initPrice) {
                        _initPrice = price;
                        emit eveSetInitAmount(_initPrice);
                    } else {
                        uint256 r_am = tAmount;
                        uint ratio = (price - _initPrice) * 10 ** _decimals / _initPrice;
                        //当币价格下跌40%，卖出手续费增加10%
                        //当币价格下跌50%，卖出手续费增加20%
                        //当币价格下跌60%，卖出手续费增加30%
                        //增加卖出的手续费全部回流底池
                        // 50%
                        _linFee = 0;
                        if (ratio >= 40 * 10 ** 17) {
                            _linFee = 10;
                        }
                        if (ratio >= 50 * 10 ** 17) {
                            _linFee = 20;
                        }
                        if (ratio >= 60 * 10 ** 17) {
                            _linFee = 30;
                        }


                        if (_linFee > 0) {
                            rate = rate.add(_linFee);

                            _rOwned[uniswapV2Pair] = _rOwned[uniswapV2Pair].add(
                                rAmount.div(100).mul(_linFee)
                            );

                            emit Transfer(sender, uniswapV2Pair, r_am.div(100).mul(_linFee));
                        }

                    }
                }
            }

        }

        // compound interest

        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }


    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }


    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    //质押
    function deposit(uint _amount) external lock {

        UserInfo storage user = _deposits[msg.sender];
        user._restStake = user._restStake.add(_amount);
        _deposits[msg.sender] = user;
        _curTotalDeposit = _curTotalDeposit.add(_amount);
        allDepositAddr.push(msg.sender);
        _transfer(msg.sender, address(this), _amount);
        emit Deposit(msg.sender, _amount);
    }

    //解锁
    function release(uint _amount) external lock {
        UserInfo storage user = _deposits[msg.sender];
        require(user._restStake >= _amount, "Amount to release too high");

        user._restStake = user._restStake.sub(_amount);
        _deposits[msg.sender] = user;
        _curTotalDeposit = _curTotalDeposit.sub(_amount);

        _transfer(address(this), msg.sender, _amount);
        emit Release(msg.sender, _amount);
    }

    //领取
    function claim(uint _amount) external lock {
        UserInfo storage user = _deposits[msg.sender];
        require(user._restAward >= _amount, "Amount to claim too high");

        user._restAward = user._restAward.sub(_amount);
        user._earnAward = user._earnAward.add(_amount);
        _deposits[msg.sender] = user;


        _profits[msg.sender][_profitIds[msg.sender]] = Profit(block.timestamp, _amount);
        _profitIds[msg.sender] = _profitIds[msg.sender].add(1);

        _transfer(address(this), msg.sender, _amount);

        emit Claim(msg.sender, _amount);
    }


    function _updateBill() private {
        //每日释放量
        uint256 value = 95833333 * 10 ** (_decimals - 7);
        if (value > _releaseTotal)
        {
            value = _releaseTotal;
        }
        if (block.timestamp >= (_LockTime + 1 days) && swapAction && allDepositAddr.length > 0 && _releaseTotal > 0) {

            uint256 billTotal = _curTotalDeposit;

            for (uint i = 0; i < allDepositAddr.length; i++) {
                UserInfo storage user = _deposits[allDepositAddr[i]];
                if (user._restStake > 0) {
                    uint256 rAmount = user._restStake.mul(value).div(billTotal);
                    user._restAward = user._restAward.add(rAmount);
                    _deposits[allDepositAddr[i]] = user;
                }
            }
            _releaseTotal = _releaseTotal.sub(value);
            _LockTime = block.timestamp;
            emit eveSetInitLockTime(_LockTime);
        }
    }


}