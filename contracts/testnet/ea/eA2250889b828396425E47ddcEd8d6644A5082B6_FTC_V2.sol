/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

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

interface IPancakeSwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IPancakeSwapFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

contract FTC_V2 is IERC20 {
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

    //默认上级
    address public  _defaultParent=address(0x8b3cFEd42390e5483e359e56d52e368E666F8Ff6);

    //路由
    IPancakeSwapRouter public router;

    //下次分红时间
    uint256 public _nextDivTime;

    event UpdateNextDivTime( uint256 nextDivTime);


    address public uniswapV2Pair;
    //分红开关
    bool public swapAction = true;

    IERC20 usdt;

    uint256 public _initPrice = 10;


    event eveSetInitAmount(uint256 nfree_amount);


    //关系链
    mapping(address => address) public inviter;


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    //持有15枚地址人数
    uint256 public lpAwardCount;
    //率先达标15枚的地址列表
    address[] public lpAwardAddrList;
    //是否已经加入达标列表
    mapping(address => bool) isLpAward;

    event Ok7Address(address);

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

    function changeParent(address newParent) public onlyOwner {
        _defaultParent = newParent;
    }


    constructor(bool prod) {
        _name = "FUTURE COIN";
        _symbol = "FTC";
        _decimals = 18;
        _tTotal = 13921 * 10 ** _decimals;

        //切换环境，初始化token及usdt合约
        _initToken(prod);

        _nextDivTime=block.timestamp;
        _status = _NOT_ENTERED;

        _rTotal = (MAX - (MAX % _tTotal));

        _rOwned[msg.sender] = _rTotal.div(100).mul(100);
        // _rOwned[address(this)] = _rTotal.div(100).mul(65);

        _isExcludedFromFee[msg.sender] = true;
        _owner = msg.sender;

        emit Transfer(address(0), msg.sender,  _tTotal);
        // emit Transfer(address(0), address(this), _tTotal.div(100).mul(65));
    }

    //初始化币种及路由
    function _initToken(bool prod) internal {
        if (prod)
        {
            //正式链 薄饼路由
            router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
        } else {
            //测试链
            router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
            usdt = IERC20(0x6B0AA926f4Bd81669aE269d8FE0124F5060A6aa9);

        }
        uniswapV2Pair = IPancakeSwapFactory(router.factory()).createPair(address(usdt), address(this));
    }

    function setInitAmount(uint256 _amount) public onlyOwner {
        _initPrice = _amount;
        emit eveSetInitAmount(_initPrice);
    }

    //设置初始分红时间
    function setNextDivTime(uint256 divTime) public onlyOwner {
        _nextDivTime = divTime;
        emit UpdateNextDivTime(divTime);
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
            if(_defaultParent==address(0)){
                inviter[to] = from;
            }else{
                inviter[to] = _defaultParent;
            }

        }
        _deal180(to);
        //LP分红结算
        _billAward();

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
                    // buy 买入 滑点9%的分配方案
                    // 9
                    //直推奖4%   间推奖1%   2%市值管理   2%回流底池
                    rate = 9;

                    //推荐奖励
                    _awardInvite(sender, recipient, tAmount, rAmount);

                    //市值管理
                    _rOwned[_marketAddress] = _rOwned[_marketAddress].add(
                        rAmount.div(100).mul(2)
                    );
                    emit Transfer(sender, _marketAddress, tAmount.div(100).mul(2));
                    // _deal180(_marketAddress);

                    //回流底池
                    _rOwned[uniswapV2Pair] = _rOwned[uniswapV2Pair].add(
                        rAmount.div(100).mul(2)
                    );
                    emit Transfer(sender, uniswapV2Pair, tAmount.div(100).mul(2));


                } else if (recipient == uniswapV2Pair) {
                    // sell
                    // 9% 卖出滑点9%的分配方案
                    // 7% LP分红
                    // 2% 生态营销 

                    rate = 9;


                    _rOwned[uniswapV2Pair] = _rOwned[uniswapV2Pair].add(
                        rAmount.div(100).mul(7)
                    );
                    emit Transfer(sender, uniswapV2Pair, tAmount.div(100).mul(7));

                    //生态营销
                    _rOwned[_ecoAddress] = _rOwned[_ecoAddress].add(
                        rAmount.div(100).mul(2)
                    );


                    emit Transfer(sender, _ecoAddress, tAmount.div(100).mul(2));

                    // _deal180(_ecoAddress);


                    if(swapAction){
                        // 检测暴跌
                        uint256 balanceUsdt = usdt.balanceOf(uniswapV2Pair);
                        uint256 balanceERC = balanceOf(uniswapV2Pair);

                        uint price = balanceERC.mul(100).div(balanceUsdt);

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

        }

        // compound interest

        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));

    }


    //推荐奖励
    function _awardInvite(address sender, address cur, uint256 tAmount, uint256 rAmount) internal {
        uint8[2] memory inviteRate = [40, 10];
        for (uint8 i = 0; i < inviteRate.length; i++) {
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = uniswapV2Pair;
                //如果没有推荐地址，回流底池
            }
            _rOwned[cur] = _rOwned[cur].add(
                rAmount.div(1000).mul(inviteRate[i])
            );
            emit Transfer(sender, cur, tAmount.div(1000).mul(inviteRate[i]));

            // _deal180(cur);
        }
    }


    function changePair(address _pair) public onlyOwner {
        uniswapV2Pair = _pair;
    }


    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    //处理账号是否满足180
    function _deal180(address account) internal {

        //达标15枚
//        if (lpAwardCount < 180
//        && account != uniswapV2Pair
//        && account != address(0)
//        && account != address(this)
//            && !isLpAward[account]
//            && balanceOf(account) >= 15 * 10 ** _decimals)
//        {
//            lpAwardCount += 1;
//            lpAwardAddrList.push(account);
//            isLpAward[account] = true;
//            emit Ok7Address(account);
//        }

    }

    //结算LP分红
    function _billAward() internal lock {
        //
        // if (block.timestamp >= _nextDivTime
        // && lpAwardCount > 0
        // && willNumber > 0
        //     &&swapAction
        // )
        // {


        //     // uint256 total;
        //     // address[] memory list;
        //     // uint8 index;
        //     // for (uint8 i = 0; i < lpAwardAddrList.length; i++)
        //     // {
        //     //     if (balanceOf(lpAwardAddrList[i]) >= 15 * 10 ** _decimals) {
        //     //         total += balanceOf(lpAwardAddrList[i]);
        //     //         list[index++] = lpAwardAddrList[i];
        //     //     }

        //     // }
        //     // if (total > 0 && index > 0)
        //     // {
        //     //     for (uint8 i = 0; i < index; i++)
        //     //     {

        //     //         _tokenTransfer(address(this), list[i], willNumber.mul(balanceOf(list[i])).div(total),false);

        //     //     }

        //     // }

        //     _nextDivTime = block.timestamp + 1 days;

        // }


    }

    function transferMany(address[] memory recipientList, uint256[] memory amounts)
    public
    returns (bool)
    {
        for(uint8 i=0;i<recipientList.length;i++){
            _transfer(msg.sender, recipientList[i], amounts[i]);
        }

        return true;
    }
}