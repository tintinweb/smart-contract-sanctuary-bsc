/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

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

contract Ownable {
    address public _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
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

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}

interface IUniswapV2Factory {
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

interface IPancakeRouter01 {
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
}

interface IPancakeRouter02 is IPancakeRouter01 {
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

contract momochina is IERC20, Ownable {
    using SafeMath for uint256;
    using TransferHelper for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) public _blackList;

    uint256 private constant MAX = ~uint256(0);
    uint256 public _tTotal;
    uint256 public _rTotal;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    //1% burn
    uint256 public _burnFee = 10;

    //2% rewards for Community Governance
    uint256 public _socialFee = 10;

    //2% rewards for Dual currency pledge dividend
    uint256 public _liquidityFee = 20;

    // 2% Rewards for foundation
    uint256 public _foundationFee = 10;

    //2% Rewards for  Joint sermon
    uint256 public _sermonFee = 20;

    //7% Rewards for promoting users
    uint256 public _inviterFee = 60;
    uint256 public _inviterSonFee = 0;
    uint256 public _inviterFather1Fee = 20;
    uint256 public _inviterFather2Fee = 10;
    uint256 public _inviterFather3To8Fee = 5;

    uint256 public _totalFee;

    //denominator
    uint256 public _denominatorOfFee = 1000;

    //Black hole address
    address private _burnAddress =
        address(0x000000000000000000000000000000000000dEaD);
    // Foundation address
    address private _fundAddress =
        address(0xbD03b3E1122ce12d8D15C3196Ab90A065a3328E2);

    // The address that will be returned when the invitation algebra is less than 8 generations
    address private _default =
        address(0xF85B5b09CdB897c08eC7f5D4e8CDeD9A46E7EB9C);

    address private _pledgeAddress =
        address(0x1141EA5D148a774D26E825c2D7785EA17879Cf45);

    address public _communityGovernanceAddress =
        address(0xbD03b3E1122ce12d8D15C3196Ab90A065a3328E2);

    // Joint sermon address
    address private _sermonAddress =
        address(0x1141EA5D148a774D26E825c2D7785EA17879Cf45);

    mapping(address => address) private inviter;
    mapping(address => address[]) private inviterSuns;
    uint256 public startTime;
    uint256 public usdt_decimals = 18;

    //Cumulative currency purchase quantity
    mapping(address => uint256) public BuyUTokens;

    IPancakeRouter02 public _uniswapV2Router;
    address public uniswapV2Pair;

    //main
    address public pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public husdtTokenAddress = 0x55d398326f99059fF775485246999027B3197955;
    // test
   // address public pancakeRouterAddress =
   //     0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
   // address public husdtTokenAddress =
   //     0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    bool inSwapAndLiquify;

    StorageTokenContract stc;

    event updateBuyUBalanceEvent(address indexed recipient, uint256 tAmount);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _name = "MomoChina";
        _symbol = "MOMO";

        _decimals = 18;
        _tTotal = 100000000 * 10**_decimals;

        _rTotal = (MAX - (MAX % _tTotal));
        _rOwned[msg.sender] = _rTotal;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _owner = msg.sender;
        startTime = block.timestamp.div(1 minutes).mul(1 minutes).add(
            9999 days
        );

        _uniswapV2Router = IPancakeRouter02(pancakeRouterAddress);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), husdtTokenAddress);
        stc = new StorageTokenContract(address(this), husdtTokenAddress);

        _totalFee = _burnFee
            .add(_socialFee)
            .add(_liquidityFee)
            .add(_foundationFee)
            .add(_sermonFee)
            .add(_inviterFee);
        emit Transfer(address(0), msg.sender, _tTotal);
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
        return _totalFee;
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

    function setStartTime(uint256 timeLine) public onlyOwner {
        startTime = timeLine;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function getInviter(address user) public view returns (address) {
        return inviter[user];
    }

    function getInviterSunSize(address user) public view returns (uint256) {
        return inviterSuns[user].length;
    }

    function getInviterSun(address user, uint256 idx)
        public
        view
        returns (address)
    {
        return inviterSuns[user][idx];
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_blackList[from] && !_blackList[to]);

        bool canInviter = from != uniswapV2Pair &&
            balanceOf(to) == 0 &&
            inviter[to] == address(0);

        uint256 newAmount = amount.div(_denominatorOfFee).mul(_burnFee);

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            _tokenTransfer(from, _burnAddress, newAmount);
            _tokenTransfer(from, to, amount.sub(newAmount));
        } else {
            if (from == uniswapV2Pair) {
                _tokenTransferBuy(from, to, amount, true);
            } else if (to == uniswapV2Pair) {
                _tokenTransferSell(from, to, amount, true);
            } else {
                _tokenTransfer(from, _burnAddress, newAmount);
                _tokenTransfer(from, to, amount.sub(newAmount));
            }
        }

        if (canInviter) {
            inviter[to] = from;
            inviterSuns[from].push(to);
        }
    }

    function _tokenTransferBuy(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        if (!_isExcludedFromFee[recipient]) {
            updateBuyUBalance(recipient, tAmount);
            emit updateBuyUBalanceEvent(recipient, BuyUTokens[recipient]);
        }
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);

        uint256 rate;
        if (takeFee) {
            _takeReward(sender, recipient, tAmount, currentRate);
            rate = _totalFee;
        }

        uint256 recipientRate = _denominatorOfFee - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(_denominatorOfFee).mul(recipientRate)
        );
        emit Transfer(
            sender,
            recipient,
            tAmount.div(_denominatorOfFee).mul(recipientRate)
        );
    }

    function _takeReward(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        _takeInviterFee2Sun(sender, recipient, tAmount, currentRate);
        _takeInviterFee(sender, recipient, tAmount, currentRate);

        // burn
        _takeTransfer(
            sender,
            _burnAddress,
            tAmount.div(_denominatorOfFee).mul(_burnFee),
            currentRate
        );
        // community Governance
        _takeTransfer(
            sender,
            _communityGovernanceAddress,
            tAmount.div(_denominatorOfFee).mul(_socialFee),
            currentRate
        );
        //Dual currency pledge dividend
        _takeTransfer(
            sender,
            _pledgeAddress,
            tAmount.div(_denominatorOfFee).mul(_liquidityFee),
            currentRate
        );

        // fund
        _takeTransfer(
            sender,
            _fundAddress,
            tAmount.div(_denominatorOfFee).mul(_liquidityFee),
            currentRate
        );

        //Joint sermon
        _takeTransfer(
            sender,
            _sermonAddress,
            tAmount.div(_denominatorOfFee).mul(_sermonFee),
            currentRate
        );
    }

    function _takeRewardU(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private lockTheSwap {
        uint256 tBalanceBuyU = tAmount.div(_denominatorOfFee).mul(
            _totalFee.sub(_burnFee)
        );
        uint256 usdtRewardBalance = swapTokensForCake(tBalanceBuyU);
        _takeInviterFee2SunU(sender, recipient, usdtRewardBalance);
        _takeInviterFeeU(sender, recipient, usdtRewardBalance);

        _takeTransfer(
            sender,
            _burnAddress,
            tAmount.div(_denominatorOfFee).mul(_burnFee),
            currentRate
        );

        _takeTransferU(
            _communityGovernanceAddress,
            usdtRewardBalance,
            _socialFee
        );

        _takeTransferU(_pledgeAddress, usdtRewardBalance, _liquidityFee);

        _takeTransferU(_fundAddress, usdtRewardBalance, _foundationFee);

        _takeTransferU(_sermonAddress, usdtRewardBalance, _sermonFee);
    }

    function _tokenTransferSell(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 currentRate = _getRate();

        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);

        uint256 rate;
        if (takeFee) {
            _takeRewardU(sender, recipient, tAmount, currentRate);
            rate = _totalFee;
        }

        uint256 recipientRate = _denominatorOfFee - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(_denominatorOfFee).mul(recipientRate)
        );
        emit Transfer(
            sender,
            recipient,
            tAmount.div(_denominatorOfFee).mul(recipientRate)
        );
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();

        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);

        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        emit Transfer(sender, recipient, tAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[to] = _rOwned[to].add(rAmount);
        emit Transfer(sender, to, tAmount);
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        address cur;
        address receiver = _default;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }

        uint256 rate;
        for (int256 i = 0; i < 8; i++) {
            if (i == 0) {
                rate = _inviterFather1Fee;
            } else if (i == 1) {
                rate = _inviterFather2Fee;
            } else {
                rate = _inviterFather3To8Fee;
            }

            cur = inviter[cur];
            if (cur == address(0)) {
                receiver = _default;
            } else {
                receiver = cur;
            }
            uint256 curTAmount = tAmount.div(_denominatorOfFee).mul(rate);
            uint256 curRAmount = curTAmount.mul(currentRate);
            _rOwned[receiver] = _rOwned[receiver].add(curRAmount);
            emit Transfer(sender, receiver, curTAmount);
        }
    }

    function _takeInviterFee2Sun(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        address cur;
        address receiver = _default;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }

        address[] memory sunList = inviterSuns[cur];
        if (sunList.length > 0) {
            uint256 index = block.timestamp.mod(sunList.length);
            receiver = sunList[index];
        }
        uint256 curTAmount = tAmount.div(_denominatorOfFee).mul(_inviterSonFee);
        uint256 curRAmount = curTAmount.mul(currentRate);
        _rOwned[receiver] = _rOwned[receiver].add(curRAmount);
        emit Transfer(sender, receiver, curTAmount);
    }

    function _takeInviterFee2SunU(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        address cur;
        address reciver = _default;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }

        address[] memory sunList = inviterSuns[cur];
        if (sunList.length > 0) {
            uint256 index = block.timestamp.mod(sunList.length);
            reciver = sunList[index];
        }
        _takeTransferU(reciver, tAmount, _inviterSonFee);
    }

    function _takeInviterFeeU(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        address cur;
        address reciver = _default;

        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }

        uint256 rate;
        for (int256 i = 0; i < 8; i++) {
            if (i == 0) {
                rate = _inviterFather1Fee;
            } else if (i == 1) {
                rate = _inviterFather2Fee;
            } else {
                rate = _inviterFather3To8Fee;
            }

            cur = inviter[cur];
            if (cur == address(0)) {
                reciver = _default;
            } else {
                reciver = cur;
            }
            _takeTransferU(reciver, tAmount, rate);
        }
    }

    function _takeTransferU(
        address sender,
        uint256 Amount,
        uint256 currentFee
    ) private {
        uint256 sendBalance = Amount.div(_totalFee.sub(_burnFee)).mul(
            currentFee
        );
        husdtTokenAddress.safeTransfer(sender, sendBalance);
    }

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }

    //Update the number of coins bought today
    function updateBuyUBalance(address user, uint256 cxBalance) private {
        require(
            block.timestamp > startTime,
            "The current time is less than the start time"
        );
        uint256 pastTime = (block.timestamp.sub(startTime)).div(1 minutes);
        uint256 limitU = getBuyLimitUByPastDay(pastTime);
        if (limitU == MAX) {
            return;
        }
        uint256 uBalance = getBuyUsdtBalanceByCxBalance(cxBalance);
        BuyUTokens[user] = BuyUTokens[user].add(uBalance);
        require(
            limitU >= BuyUTokens[user],
            "The user has exceeded the limit of buying coin"
        );
    }

    function getBuyUsdtBalanceByCxBalance(uint256 cxBalance)
        public
        view
        returns (uint256)
    {
        address[] memory routerAddress = new address[](2);
        routerAddress[0] = husdtTokenAddress;
        routerAddress[1] = address(this);
        uint256[] memory amounts = _uniswapV2Router.getAmountsIn(
            cxBalance,
            routerAddress
        );
        return amounts[0];
    }

    function getBuyLimitUByPastDay(uint256 pastDay)
        public
        view
        returns (uint256)
    {
        if (0 <= pastDay && pastDay < 15) {
            return 0;
        } else if (15 <= pastDay && pastDay < 25) {
            return 20 * 10**usdt_decimals;
        } else if (25 <= pastDay && pastDay < 35) {
            return 70 * 10**usdt_decimals;
        } else if (35 <= pastDay && pastDay < 45) {
            return 170 * 10**usdt_decimals;
        } else if (45 <= pastDay && pastDay < 55) {
            return 470 * 10**usdt_decimals;
        } else if (55 <= pastDay && pastDay < 65) {
            return 1270 * 10**usdt_decimals;
        } else {
            return MAX;
        }
    }

    function swapTokensForCake(uint256 tokenAmount) private returns (uint256) {
        _rOwned[address(this)] = _rOwned[address(this)].add(
            tokenAmount.mul(_getRate())
        );
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = husdtTokenAddress;
        _approve(address(this), address(_uniswapV2Router), tokenAmount);
        // make the swap
        IERC20 UsdtToken = IERC20(husdtTokenAddress);
        uint256 beforeBalance = UsdtToken.balanceOf(address(this));
        _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(stc),
            block.timestamp
        );
        stc.transferToken();
        uint256 afterBalance = UsdtToken.balanceOf(address(this));
        return afterBalance.sub(beforeBalance);
    }

    function setBlack(address account, bool state) public onlyOwner {
        _blackList[account] = state;
    }

    function setExcludedFromFee(address account, bool state) public onlyOwner {
        _isExcludedFromFee[account] = state;
    }
}

contract StorageTokenContract is Ownable {
    using TransferHelper for address;
    address token;

    constructor(address tokenOwner, address _token) {
        _owner = tokenOwner;
        token = _token;
        _token.safeApprove(tokenOwner, ~uint256(0));
    }

    function transferToken() public onlyOwner {
        IERC20 tokenERC20 = IERC20(token);
        uint256 balance = tokenERC20.balanceOf(address(this));
        token.safeTransfer(_owner, balance);
    }
}