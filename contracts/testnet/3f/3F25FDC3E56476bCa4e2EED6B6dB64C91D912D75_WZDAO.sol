// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./interfaces/IReferral.sol";

contract Wrap {
    IERC20 public wzdao;
    IERC20 public usdt;

    constructor(IERC20 wzdao_, IERC20 usdt_) {
        wzdao = wzdao_;
        usdt = usdt_;
    }

    function withdraw() external {
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdt.transfer(address(wzdao), usdtBalance);
        }
    }
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

contract WZDAO is ERC20Detailed, Ownable {

    using Math for uint256;
    using SafeMath for uint256;
    using Address for address;

    IReferral public immutable referral;
    Wrap public immutable wrap;

    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant ZERO = 0x0000000000000000000000000000000000000000;

    uint256 private immutable TOTAL_GONS;
    uint256 public immutable MAX_SUPPLY;
    uint256 private constant MAX_UINT256 = type(uint256).max;

    uint256 private immutable _lpFeeRate = 5;
    uint256 public immutable marketingFeeRate1 = 2;
    uint256 public immutable marketingFeeRate2 = 1;
    uint256 public immutable burnFeeRate = 5;
    uint256[3] public referralFeeRates = [2];

    address public lpWallet;
    address public marketingWallet1;
    address public marketingWallet2;
    uint256 public gonsLPFee;

    IUniswapV2Router02 public immutable pancakeSwapRouter;
    IERC20 public immutable usdt;
    address public immutable pair;

    uint256 public startTradingTime;
    uint256 public swapInterval = 15 minutes;
    uint256 private _lastSwapTime;
    bool private _swapping = false;
    uint256 public immutable rebaseInterval = 15 minutes;
    uint256 public immutable rebaseRate = 51954907016092;
    uint256 private _lastRebasedTime;
    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    uint256 public holdCount;
    uint256 public noTakeFeeHoldCondition = 10000;
    uint256 public maxBurn = 20000000 * 10 ** decimals();

    uint256 private _pairBalance;
    mapping(address => uint256) private _gonsBalances;
    mapping(address => bool) private _isExcludedFromFees;
    // mapping(address => bool) private _isBlackLists;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(uint256 => uint256) private _todayBasePrices;
    mapping(address => bool) private _isHolds;
    mapping(address=>address) private _wReferrals;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        IUniswapV2Router02 pancakeSwapRouter_,
        IERC20 usdt_,
        IReferral referral_,
        uint256 initSupply_,
        uint256 maxSupply_,
        uint256 startTradingTime_,
        address lpWallet_,
        address makretingWallet1_,
        address makretingWallet2_
    ) ERC20Detailed(name_, symbol_) {
        pancakeSwapRouter = pancakeSwapRouter_;
        usdt = usdt_;
        referral = referral_;
        lpWallet = lpWallet_;
        marketingWallet1 = makretingWallet1_;
        marketingWallet2 = makretingWallet2_;
        setStartTradingTime(startTradingTime_);
        wrap = new Wrap(IERC20(address(this)), usdt);
        pair = IUniswapV2Factory(pancakeSwapRouter.factory()).createPair(
            address(usdt),
            address(this)
        );
        _totalSupply = initSupply_ * 10**decimals();
        MAX_SUPPLY = maxSupply_ * 10**decimals();
        TOTAL_GONS = MAX_UINT256/1e10 - (MAX_UINT256/1e10 % _totalSupply);
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _gonsBalances[msg.sender] = TOTAL_GONS;
        emit Transfer(address(0x0), msg.sender, _totalSupply);
        setHold(msg.sender);
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(this)] = true;
        _allowedFragments[address(this)][
            address(pancakeSwapRouter)
        ] = MAX_UINT256;
    }

    function getTodayBasePrice(uint256 _k) external view returns (uint256) {
        return _todayBasePrices[_k];
    }

    function isExcludedFromFee(address _address) external view returns (bool) {
        return _isExcludedFromFees[_address];
    }

    // function isBlackList(address _address) external view returns (bool) {
    //     return _isBlackLists[_address];
    // }

    function isHold(address _address) public view returns (bool) {
        return _isHolds[_address];
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

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) public view override returns (uint256) {
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
    ) internal returns (bool result) {
        if (_swapping) {
            return
                _basicTransfer(sender, recipient, amount.mul(_gonsPerFragment));
        }
        require(_isStartTrade(sender, recipient), "Trade not start");

        // require(
        //     !_isBlackLists[sender] && !_isBlackLists[recipient],
        //     "Is black list"
        // );

        _deliveryCurrentProce();

        if(!_isSwap(sender,recipient) && !recipient.isContract()){
            _ref(sender,recipient);
            _acceptRef(sender,recipient);
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
                uint256 minHolderAmount = _gonsBalanceOf(sender).div(100).mul(
                    99
                );
                if (gonAmount > minHolderAmount) {
                    gonAmount = minHolderAmount;
                }
            }
            gonAmount = _takeFee(sender, recipient, gonAmount);
        }
        result = _basicTransfer(sender, recipient, gonAmount);
        setHold(sender);
        setHold(recipient);
    }

    function _isStartTrade(address sender, address recipient)
        private
        view
        returns (bool)
    {
        return
            !_isSwap(sender, recipient) ||
            _isExcludedFromFees[sender] ||
            _isExcludedFromFees[recipient] ||
            block.timestamp >= startTradingTime;
    }

    function _shouldTakeFee(address from, address to)
        private
        view
        returns (bool)
    {
        if (
            _isExcludedFromFees[from] ||
            _isExcludedFromFees[to] ||
            _swapping ||
            holdCount >= noTakeFeeHoldCondition
        ) {
            return false;
        } else {
            return true;
            // return (from == pair || to == pair);
        }
    }

    function _isSwap(address _from,address _to)private view returns(bool){
        return pair == _from || pair == _to;
    }

    function _ref(address _parent,address _user) private  {
        if(referral.isBindReferral(_user) || !referral.isBindReferral(_parent)){
            return;
        }
        _wReferrals[_user] = _parent;
    }

    function _acceptRef(address _user,address _parent)  private {
        if(referral.isBindReferral(_user)){
            return;
        }
        address parent = _wReferrals[_user];
        if(parent != _parent){
            return;
        }
        _wReferrals[_user] = address(0);
        referral.bindReferral(parent,_user);
    }

    function _shouldRebase() private view returns (bool) {
        return
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair &&
            !_swapping &&
            block.timestamp >= (_lastRebasedTime + rebaseInterval);
    }

    function _shouldSwap(address _from, address _to)
        private
        view
        returns (bool)
    {
        return
            !_swapping &&
            _from != pair &&
            _from != owner() &&
            _to != owner() &&
            block.timestamp >= (_lastSwapTime + swapInterval);
    }

    function _takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) private returns (uint256 result) {
        result = gonAmount;
        //LP
        uint256 lpFee = gonAmount.div(100).mul(recipient==pair?lpFeeRate():_lpFeeRate);
        gonsLPFee = gonsLPFee.add(lpFee);
        lpFee > 0 && _basicTransfer(sender, address(this), lpFee);
        result = result.sub(lpFee);

        //销毁
        uint256 gonCirculation = totalSupply().sub(balanceOf(DEAD)).mul(
            _gonsPerFragment
        );
        uint256 minCirculationRate = MAX_SUPPLY.sub(maxBurn).mul(1e18).div(MAX_SUPPLY);
        uint256 gonMinCirculation = totalSupply().mul(minCirculationRate).div(1e18).mul(_gonsPerFragment);
        
        if (gonCirculation > gonMinCirculation) {
            uint256 burnFee = gonAmount.div(100).mul(burnFeeRate).min(
                gonCirculation.sub(gonMinCirculation)
            );
            burnFee > 0 && _basicTransfer(sender, DEAD, burnFee);
            result = result.sub(burnFee);
        }

        //分享奖励
        address[] memory referrals = referral.getReferrals(
            sender == pair ? recipient : sender,
            referralFeeRates.length
        );
        for (uint256 i = 0; i < referrals.length; i++) {
            address parent = referrals[i];
            uint256 reward = gonAmount.div(100).mul(referralFeeRates[i]);
            reward > 0 &&
                _basicTransfer(
                    sender,
                    parent == address(0) ? marketingWallet1 : parent,
                    reward
                );
            result = result.sub(reward);
        }

        //营销钱包1
        uint256 marketingFee1 = gonAmount.div(100).mul(marketingFeeRate1);
        marketingFee1 > 0 &&
            _basicTransfer(sender, marketingWallet1, marketingFee1);
        result = result.sub(marketingFee1);

        //营销钱包2
        uint256 marketingFee2 = gonAmount.div(100).mul(marketingFeeRate2);
        marketingFee2 > 0 &&
            _basicTransfer(sender, marketingWallet2, marketingFee2);
        result = result.sub(marketingFee2);
    }

    function _deliveryCurrentProce() private {
        uint256 price = _getCurrentPrice();
        uint256 zero = (block.timestamp / 1 days) * 1 days;
        _todayBasePrices[zero] = price;
        if (_todayBasePrices[zero - 1 days] == 0) {
            _todayBasePrices[zero - 1 days] = price;
        }
    }

    function _getCurrentPrice() private view returns (uint256) {
        (uint256 r0, uint256 r1, ) = IUniswapV2Pair(pair).getReserves();
        if (r0 > 0 && r1 > 0) {
            if (address(this) == IUniswapV2Pair(pair).token0()) {
                return (r1 * 10**18) / r0;
            } else {
                return (r0 * 10**18) / r1;
            }
        }
        return 0;
    }

    function lpFeeRate() public view returns (uint256) {
        uint256 price = _getCurrentPrice();
        uint256 base = _todayBasePrices[
            ((block.timestamp / 1 days) * 1 days) - 1 days
        ];
        if (price >= base) return _lpFeeRate;
        uint256 rate = ((base - price) * 100) / base;
        if (rate >= 10) {
            return 21;
        }
        return _lpFeeRate;
    }

    function _gonsBalanceOf(address _address) private view returns (uint256) {
        return _gonsBalances[_address];
    }

    function _rebase() private {
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(rebaseInterval);
        uint256 epoch = times.mul(15);
        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**decimals()).add(rebaseRate))
                .div(10**decimals());
            if (_totalSupply > MAX_SUPPLY) {
                _totalSupply = MAX_SUPPLY;
            }
        }
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(rebaseInterval));
        emit LogRebase(epoch, _totalSupply);
    }

    function setHold(address _address) public {
        uint256 balance = balanceOf(_address);
        bool isHol = isHold(_address);
        
        if (isHol && balance <= 0) {
            _isHolds[_address] = false;
            holdCount -= 1;
        }
        if (!isHol && balance > 0) {
            _isHolds[_address] = true;
            holdCount += 1;
        }
    }

    function _swap() private {
        _swapping = true;
        if (gonsLPFee > 0) {
            _swapAndLiquidity(gonsLPFee.div(_gonsPerFragment));
            gonsLPFee = 0;
        }
        _lastSwapTime = block.timestamp;
        _swapping = false;
    }

    function _swapAndLiquidity(uint256 tokenAmount) private {
        uint256 half = tokenAmount.div(2);
        uint256 otherHalf = tokenAmount.sub(half);
        uint256 usdtAmount = _swapTokensForUsdt(half);
        _addLiquidityUsdt(otherHalf, usdtAmount);
        emit SwapAndLiquify(half, usdtAmount, otherHalf);
    }

    function _swapTokensForUsdt(uint256 tokenAmount)
        private
        returns (uint256 swapUsdtAmount)
    {
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

    function _addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount)
        private
    {
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

    function manualSync() external {
        IUniswapV2Pair(pair).sync();
    }

    function manualRebase() external {
        if (_shouldRebase()) {
            _rebase();
        }
    }

    function setExcludedFromFee(address _address, bool _v) external onlyOwner {
        if (_isExcludedFromFees[_address] != _v) {
            _isExcludedFromFees[_address] = _v;
            emit SetExcludeFromFee(_address, _v);
        }
    }

    function batchSetExcludedFromFee(address[] calldata _addresses, bool _v)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _addresses.length; i++) {
            _isExcludedFromFees[_addresses[i]] = _v;
        }
        emit BatchSetExcludedFromFee(_addresses, _v);
    }

    // function setBlackList(address _address, bool _v) external onlyOwner {
    //     if (_isBlackLists[_address] != _v) {
    //         _isBlackLists[_address] = _v;
    //         emit SetBlackList(_address, _v);
    //     }
    // }

    // function batchSetBlackList(address[] calldata accounts, bool _v)
    //     external
    //     onlyOwner
    // {
    //     for (uint256 i = 0; i < accounts.length; i++) {
    //         _isBlackLists[accounts[i]] = _v;
    //     }
    //     emit BatchSetBlackList(accounts, _v);
    // }

    function setSwapInterval(uint256 _swapInterval) external onlyOwner {
        swapInterval = _swapInterval;
    }

    function setLpWallet(address _lpWallet) external onlyOwner {
        lpWallet = _lpWallet;
    }

    function setMarketingWallet1(address _marketingWallet) external onlyOwner {
        marketingWallet1 = _marketingWallet;
    }

    function setMarketingWallet2(address _marketingWallet) external onlyOwner {
        marketingWallet2 = _marketingWallet;
    }

    function setStartTradingTime(uint256 _startTime) public onlyOwner {
        _lastRebasedTime = _lastSwapTime = startTradingTime = _startTime;
    }

    function setMaxBurn(uint256 _maxBurn) external onlyOwner{
        maxBurn = _maxBurn;
    }

    function setNoTakeFeeHoldCondition(uint256 _noTakeFeeHoldCondition) external onlyOwner{
        noTakeFeeHoldCondition = _noTakeFeeHoldCondition;
    }

    function withdraw(address _token, address payable _to) external onlyOwner {
        if (_token == address(0x0)) {
            payable(_to).transfer(address(this).balance);
        }
        else {
            IERC20(_token).transfer(_to, IERC20(_token).balanceOf(address(this)));
        }
    }
    
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 usdtReceived,
        uint256 tokensIntoLiqudity
    );

    event Swap(uint256 swapTokenAmount, uint256 receiveUsdtAmount);
    event SetExcludeFromFee(address indexed account, bool v);
    event BatchSetExcludedFromFee(address[] accounts, bool v);
    // event SetBlackList(address indexed account, bool v);
    // event BatchSetBlackList(address[] accounts, bool v);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IReferral{
    
    event BindReferral(address indexed referral,address indexed user);
    
    function getReferral(address _address)external view returns(address);

    function isBindReferral(address _address) external view returns(bool);

    function getReferralCount(address _address) external view returns(uint256);

    function bindReferral(address _referral,address _user) external;

    function getReferrals(address _address,uint256 _num) external view returns(address[] memory);

    function getRootAddress()external view returns(address);
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
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

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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