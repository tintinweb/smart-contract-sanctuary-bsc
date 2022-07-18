// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

interface IPancakeSwapPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
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

interface IReferral {
    function isBindParent(address _address) external view returns (bool);

    function bindParent(address _parent, address _user) external;

    function getParents(address _address, uint256 _num)
        external
        view
        returns (address[] memory);

    function isActive(address _address) external view returns (bool);

    function setToken(address _token) external;
}

contract Wrap {
    IERC20 public gbp;
    IERC20 public usdt;

    constructor(IERC20 gbp_, IERC20 usdt_) {
        gbp = gbp_;
        usdt = usdt_;
    }

    function withdraw() external {
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdt.transfer(address(gbp), usdtBalance);
        }
    }
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

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract GBPToken is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    IReferral public referral;
    Wrap public wrap;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    uint256 private immutable TOTAL_GONS;
    uint256 public immutable MAX_SUPPLY;
    uint256 private constant MAX_UINT256 = type(uint256).max;

    uint256 public lpFeeRate = 1; //买入回流池子费
    uint256 public marketingFeeRate = 1; //买入市场费
    uint256[3] public referralFeeRates = [9, 3, 1]; //买入分享费

    uint256 public nodeFeeRate = 6; //卖出节点费
    uint256 public burnFeeRate = 2; //卖出销毁费
    uint256 public buyBackFeeRate = 6; //卖出回购费
    uint256 public ecologyFeeRate = 1; //卖出生态费

    address public lpWallet; //lp钱包
    address public marketingWallet; //市场钱包
    address public nodeWallet; //节点钱包
    address public buyBackWallet; //买回钱包
    address public ecologyWallet; //生态钱包

    uint256 amountLPFee;
    uint256 amountBuyBackFee;
    uint256 amountEcologyFee;
    uint256 amountMarketingFee;

    IPancakeSwapRouter public pancakeSwapRouter = IPancakeSwapRouter(0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0);
    IERC20 public usdt = IERC20(0x6A481F570CbcDc7d4aa581CA6fA91d412fca54c5);
    address public pair;

    uint256 public startTradingTime;
    uint256 public swapInterval = 5 minutes;
    uint256 private _lastSwapTime;
    bool swaping = false;
    uint256 public rebaseInterval = 5 minutes;
    uint256 private _lastRebasedTime;
    uint256 private _rebaseCount = 0;
    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;

    uint256 private _pairBalance;
    mapping(address => uint256) private _gonsBalances;
    mapping(address => bool) private _isFeeExempt;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        IReferral referral_,
        uint256 initSupply_,
        uint256 startTradingTime_,
        address lpWallet_,
        address makretingWallet_,
        address nodeWallet_,
        address buyBackWallet_,
        address ecologyWallet_
    ) ERC20Detailed(name_, symbol_) {
        pair = IPancakeSwapFactory(pancakeSwapRouter.factory()).createPair(
            address(usdt),
            address(this)
        );
        wrap = new Wrap(IERC20(address(this)), usdt);
        referral = referral_;
        referral.setToken(address(this));
        lpWallet = lpWallet_;
        marketingWallet = makretingWallet_;
        nodeWallet = nodeWallet_;
        buyBackWallet = buyBackWallet_;
        ecologyWallet = ecologyWallet_;
        _totalSupply = initSupply_ * 10 ** decimals();
        // MAX_SUPPLY = _totalSupply.mul(10e8);
        MAX_SUPPLY = _totalSupply.mul(130).div(100);
        TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % _totalSupply);
        _gonsBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;
        setStartTradingTime(startTradingTime_);
        emit Transfer(address(0x0), msg.sender, _totalSupply);
        _allowedFragments[address(this)][
            address(pancakeSwapRouter)
        ] = MAX_UINT256;
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != MAX_UINT256) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        return _approve(msg.sender, spender, value);
    }

    function _approve(
        address sender,
        address spender,
        uint256 value
    ) private returns (bool) {
        _allowedFragments[sender][spender] = value;
        emit Approval(sender, spender, value);
        return true;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) external view override returns (uint256) {
        return
            who == pair
                ? _pairBalance
                : _gonsBalances[who].div(_gonsPerFragment);
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 gonAmount
    ) internal returns (bool) {
        uint256 amount = gonAmount.div(_gonsPerFragment);
        if (from == pair) {
            _pairBalance = _pairBalance.sub(amount);
        } else {
            _gonsBalances[from] = _gonsBalances[from].sub(gonAmount);
        }
        if (to == pair) {
            _pairBalance = _pairBalance.add(amount);
        } else {
            _gonsBalances[to] = _gonsBalances[to].add(gonAmount);
        }
        emit Transfer(from, to, amount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (swaping) {
            return
                _basicTransfer(sender, recipient, amount.mul(_gonsPerFragment));
        }
        require(_checkStartTrade(sender, recipient), "Trade not start");
        require(_checkActive(sender, recipient), "Need active");
        if (_shouldBindParent(sender, recipient)) {
            referral.bindParent(sender, recipient);
        }
        if (_shouldRebase()) {
            _rebase();
        }
        if (_shouldSwap(sender, recipient)) {
            _swap();
        }
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        if (_shouldTakeFee(sender, recipient)) {
            if (sender != pair) {
                uint256 minHolderAmount = _gonsBalanceOf(sender).div(1000).mul(
                    999
                );
                if (gonAmount > minHolderAmount) {
                    gonAmount = minHolderAmount;
                }
            }
            gonAmount = _takeFee(sender, recipient, gonAmount);
        }
        return _basicTransfer(sender, recipient, gonAmount);
    }

    function _checkStartTrade(address sender, address recipient)
        private
        view
        returns (bool)
    {
        return
            (sender != pair && recipient != pair) ||
            _isFeeExempt[sender] ||
            _isFeeExempt[recipient] ||
            block.timestamp >= startTradingTime;
    }

    function _checkActive(address sender, address recipient)
        private
        view
        returns (bool)
    {
        return
            sender == pair ||
            referral.isActive(sender) ||
            (recipient != pair &&
                !referral.isActive(sender) &&
                !referral.isActive(recipient));
    }

    function _takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) private returns (uint256 result) {
        result = gonAmount;
        if (sender == pair) {
            //购买
            //邀请奖励
            address[] memory parents = referral.getParents(
                recipient,
                referralFeeRates.length
            );
            for (uint256 i = 0; i < parents.length; i++) {
                uint256 referralReward = gonAmount.mul(referralFeeRates[i]).div(
                    100
                );
                uint256 finalReferralReward = 0;
                result = result.sub(referralReward);
                if (parents[i] != address(0)) {
                    uint256 parentGonsBalance = _gonsBalanceOf(parents[i]);
                    finalReferralReward = (
                        gonAmount > parentGonsBalance
                            ? parentGonsBalance
                            : gonAmount
                    ).mul(referralFeeRates[i]).div(100);
                    finalReferralReward > 0 &&
                        _basicTransfer(sender, parents[i], finalReferralReward);
                }
                uint256 burnReferralReward = referralReward.sub(
                    finalReferralReward
                );
                burnReferralReward > 0 &&
                    _basicTransfer(sender, marketingWallet, burnReferralReward);
            }
            //LP
            uint256 lpFee = gonAmount.div(100).mul(lpFeeRate);
            amountLPFee = amountLPFee.add(lpFee);
            //营销钱包
            uint256 marketingFee = gonAmount.div(100).mul(marketingFeeRate);
            amountMarketingFee = amountMarketingFee.add(marketingFee);
            uint256 totalFee = lpFee.add(marketingFee);
            totalFee > 0 && _basicTransfer(sender, address(this), totalFee);
            result = result.sub(totalFee);
        } else {
            //卖出
            //节点奖励
            uint256 nodeFee = gonAmount.mul(nodeFeeRate).div(100);
            nodeFee > 0 && _basicTransfer(sender, nodeWallet, nodeFee);
            result = result.sub(nodeFee);
            //销毁
            uint256 burnFee = gonAmount.mul(burnFeeRate).div(100);
            burnFee > 0 && _basicTransfer(sender, DEAD, burnFee);
            result = result.sub(burnFee);
            //复盘钱包
            uint256 buyBackFee = gonAmount.div(100).mul(buyBackFeeRate);
            amountBuyBackFee = amountBuyBackFee.add(buyBackFee);
            //生态建设
            uint256 ecologyFee = gonAmount.div(100).mul(ecologyFeeRate);
            amountEcologyFee = amountEcologyFee.add(ecologyFee);
            uint256 totalFee = ecologyFee.add(buyBackFee);
            totalFee > 0 && _basicTransfer(sender, address(this), totalFee);
            result = result.sub(totalFee);
        }
    }

    function _shouldTakeFee(address from, address to)
        private
        view
        returns (bool)
    {
        if (_isFeeExempt[from] || _isFeeExempt[to]) {
            return false;
        } else {
            return (from == pair || to == pair);
        }
    }

    function _shouldBindParent(address parent, address user)
        private
        view
        returns (bool)
    {
        return
            parent != pair &&
            user != pair &&
            referral.isBindParent(parent) &&
            !referral.isBindParent(user);
    }

    function _shouldSwap(address _from, address _to)
        private
        view
        returns (bool)
    {
        return
            !swaping &&
            _from != pair &&
            _from != owner() &&
            _to != owner() &&
            block.timestamp >= (_lastSwapTime + swapInterval);
    }

    //是否是白名单
    function isFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    //手动同步
    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }

    //手动复利
    function manualRebase() external {
        if (_shouldRebase()) {
            _rebase();
        }
    }

    //批量设置白名单
    function batchSetFeeExempt(address[] calldata _addresses, bool _v)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _addresses.length; i++) {
            _isFeeExempt[_addresses[i]] = _v;
        }
    }

    //设置白名单
    function setFeeExempt(address _addresse, bool _v) external onlyOwner {
        _isFeeExempt[_addresse] = _v;
    }

    function setStartTradingTime(uint256 _startTime) public onlyOwner {
        _lastSwapTime = startTradingTime = _startTime;
        if(_rebaseCount == 0){
            _lastRebasedTime = _startTime;
        }
    }

    function _gonsBalanceOf(address _address) private view returns (uint256) {
        return _gonsBalances[_address];
    }

    function _shouldRebase() private view returns (bool) {
        return
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair &&
            !swaping &&
            block.timestamp >= (_lastRebasedTime + rebaseInterval);
    }

    function _rebase() private {
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(rebaseInterval);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(rebaseInterval));
        for (uint256 i = 0; i < times; i++) {
            _rebaseCount++;
            uint256 rebaseRate = _getRebaseRate(_rebaseCount);
            _totalSupply = _totalSupply
                .mul((10**decimals()).add(rebaseRate))
                .div(10**decimals());
            if (_totalSupply > MAX_SUPPLY) {
                _totalSupply = MAX_SUPPLY;
            }
            _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
            emit LogRebase(_rebaseCount, rebaseRate, _totalSupply);
        }
    }

    function _getRebaseRate(uint256 rebaseCount)
        private
        pure
        returns (uint256)
    {
        if (rebaseCount <= 96 * 7) {
            return 7246412223703898;//100%
        }
        if (rebaseCount <= 96 * 14) {
            return 4232526823514061;//50%
        }
        if (rebaseCount <= 96 * 21) {
            return 2327115532720302;//25%
        }
        if (rebaseCount <= 96 * 28) {
            return 1227659579254334;//12.5%
        }
        if (rebaseCount <= 96 * 35) {
            return 656202698113905;//6.5%
        }
        return 320589488941726;//3.125%
    }

    //兑换费用
    function _swap() private {
        swaping = true;
        if (amountLPFee > 0) {
            _swapAndLiquidity(amountLPFee);
            amountLPFee = 0;
        }
        uint256 swapTokenAmount = amountBuyBackFee.add(amountEcologyFee).add(
            amountMarketingFee
        );
        if (swapTokenAmount > 0) {
            uint256 receiveUsdtAmount = _swapTokenForUsdt(swapTokenAmount);
            uint256 perAmount = receiveUsdtAmount.div(swapTokenAmount);
            uint256 buyBackAmount = amountBuyBackFee.mul(perAmount);
            uint256 ecologyAmount = amountEcologyFee.mul(perAmount);
            uint256 marketingAmount = receiveUsdtAmount.sub(ecologyAmount).sub(
                buyBackAmount
            );
            if (buyBackAmount > 0) {
                usdt.transfer(buyBackWallet, buyBackAmount);
            }
            if (ecologyAmount > 0) {
                usdt.transfer(ecologyWallet, ecologyAmount);
            }
            if (marketingAmount > 0) {
                usdt.transfer(marketingWallet, marketingAmount);
            }
            emit Swap(swapTokenAmount, receiveUsdtAmount);
            amountBuyBackFee = 0;
            amountEcologyFee = 0;
            amountMarketingFee = 0;
        }
        _lastSwapTime = block.timestamp;
        swaping = false;
    }

    //token换usdt并添加流动性
    function _swapAndLiquidity(uint256 tokenAmount) private {
        uint256 half = tokenAmount.div(2);
        uint256 otherHalf = tokenAmount.sub(half);
        uint256 usdtAmount = _swapTokenForUsdt(half);
        _addLiquidityUsdt(otherHalf, usdtAmount);
        emit SwapAndLiquify(half, usdtAmount, otherHalf);
    }

    //token换usdt
    function _swapTokenForUsdt(uint256 tokenAmount)
        private
        returns (uint256 swapUsdtAmount)
    {
        tokenAmount = tokenAmount.div(_gonsPerFragment);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdt);
        uint256 beforeUsdtAmount = usdt.balanceOf(address(wrap));
        pancakeSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(wrap),
                block.timestamp
            );
        uint256 afterUsdtAmount = usdt.balanceOf(address(wrap));
        wrap.withdraw();
        swapUsdtAmount = afterUsdtAmount.sub(beforeUsdtAmount);
    }

    //添加usdt流动性
    function _addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount)
        private
    {
        tokenAmount = tokenAmount.div(_gonsPerFragment);
        usdt.approve(address(pancakeSwapRouter), usdtAmount);
        pancakeSwapRouter.addLiquidity(
            address(this),
            address(usdt),
            tokenAmount,
            usdtAmount,
            0,
            0,
            lpWallet,
            block.timestamp
        );
    }

    event LogRebase(
        uint256 indexed epoch,
        uint256 rebaseRate,
        uint256 totalSupply
    );
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 usdtReceived,
        uint256 tokensIntoLiqudity
    );
    event Swap(uint256 swapTokenAmount, uint256 receiveUsdtAmount);
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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