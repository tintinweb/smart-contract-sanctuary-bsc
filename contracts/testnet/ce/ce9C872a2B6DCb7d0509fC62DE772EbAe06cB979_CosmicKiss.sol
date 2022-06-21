/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IFactoryV2 {
    event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address lpPair);
    function createPair(address tokenA, address tokenB) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}


contract CosmicKiss is IERC20 {
    address private _owner;

    mapping (address => uint256) private _tOwned;
    mapping (address => bool) lpPairs;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) private _isExcludedFromLimits;
    mapping (address => bool) private _liquidityHolders;
    mapping (address => bool) private _blacklist;

    string constant private _name = "Zero Tax";
    string constant private _symbol = "1";
    uint8 constant private _decimals = 18;

    uint256 constant private _tTotal = 100000000 * 10**_decimals;


    IRouter02 public dexRouter;
    address public lpPair;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;

    
    uint256 private _maxTxAmountBuy = (_tTotal * 1) / 100; // 1%
    uint256 private _maxTxAmountSell = (_tTotal * 5) / 1000; // 0.5%
    uint256 private _maxWalletSize = (_tTotal * 2) / 100; // 2%

    bool public tradingEnabled = false;
    bool public _hasLiqBeenAdded = false;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller =/= owner.");
        _;
    }
    
    constructor () payable {
        _tOwned[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        _owner = msg.sender;

        if (block.chainid == 56) {
            dexRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        } else if (block.chainid == 97) {
            dexRouter = IRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        } else if (block.chainid == 1 || block.chainid == 4 || block.chainid == 3) {
            dexRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else if (block.chainid == 43114) {
            dexRouter = IRouter02(0x60aE616a2155Ee3d9A68541Ba4544862310933d4);
        } else if (block.chainid == 250) {
            dexRouter = IRouter02(0xF491e7B69E4244ad4002BC14e878a34207E38c29);
        } else {
            revert();
        }

        lpPair = IFactoryV2(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        lpPairs[lpPair] = true;

        _approve(_owner, address(dexRouter), type(uint256).max);
        _approve(address(this), address(dexRouter), type(uint256).max);

    }

    receive() external payable {}


    function transferOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Call renounceOwnership to transfer owner to the zero address.");
        require(newOwner != DEAD, "Call renounceOwnership to transfer owner to the zero address.");
        
        if(balanceOf(_owner) > 0) {
            _transfer(_owner, newOwner, balanceOf(_owner));
        }
        
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
        
    }

    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }

    function totalSupply() external pure override returns (uint256) { if (_tTotal == 0) { revert(); } return _tTotal; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return _owner; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amount) private {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function approveContractContingency() public onlyOwner returns (bool) {
        _approve(address(this), address(dexRouter), type(uint256).max);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function setNewRouter(address newRouter) public onlyOwner {
        IRouter02 _newRouter = IRouter02(newRouter);
        address get_pair = IFactoryV2(_newRouter.factory()).getPair(address(this), _newRouter.WETH());
        if (get_pair == address(0)) {
            lpPair = IFactoryV2(_newRouter.factory()).createPair(address(this), _newRouter.WETH());
        }
        else {
            lpPair = get_pair;
        }
        dexRouter = _newRouter;
        _approve(address(this), address(dexRouter), type(uint256).max);
    }

    function setLpPair(address pair, bool enabled) external onlyOwner {
            lpPairs[pair] = enabled;
    }

    function setBlacklistEnabled(address account, bool enabled) external onlyOwner {
        _blacklist[account] = enabled;
    }

    function setBlacklistEnabledMultiple(address[] calldata accounts, bool enabled) external onlyOwner {
        for(uint index=0;index<accounts.length;index++)_blacklist[accounts[index]] = enabled;
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _blacklist[account];
    }



    function setMaxTxPercents(uint256 percentBuy, uint256 divisorBuy, uint256 percentSell, uint256 divisorSell) external onlyOwner {
        require((_tTotal * percentBuy) / divisorBuy >= (_tTotal / 5000), "must be above 0.5%");
        require((_tTotal * percentSell) / divisorSell >= (_tTotal / 5000), "must be above 0.5%");
        _maxTxAmountBuy = (_tTotal * percentBuy) / divisorBuy;
        _maxTxAmountSell = (_tTotal * percentSell) / divisorSell;
    }

    function setMaxWalletSize(uint256 percent, uint256 divisor) external onlyOwner {
        require((_tTotal * percent) / divisor >= (_tTotal / 100), "must be above 1%");
        _maxWalletSize = (_tTotal * percent) / divisor;
    }

    function setExcludedFromLimits(address account, bool enabled) external onlyOwner {
        _isExcludedFromLimits[account] = enabled;
    }

    function isExcludedFromLimits(address account) public view returns (bool) {
        return _isExcludedFromLimits[account];
    }

    function getMaxTXs() public view returns (uint256, uint256) {
        return (_maxTxAmountBuy / (10**_decimals), _maxTxAmountSell / (10**_decimals));
    }

    function getMaxWallet() public view returns (uint256) {
        return _maxWalletSize / (10**_decimals);
    }


    function _hasLimits(address from, address to) private view returns (bool) {
        return from != _owner
            && to != _owner
            && tx.origin != _owner
            && to != DEAD
            && to != address(0)
            && !_liquidityHolders[to]
            && !_liquidityHolders[from]
            && from != address(this);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_blacklist[from]==false && _blacklist[to]==false,"ERC20: address is blacklisted");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if(_hasLimits(from, to)) {
            if(!tradingEnabled) {
                revert("Trading not yet enabled!");
            }
            if(lpPairs[from]){
                if (!_isExcludedFromLimits[from] && !_isExcludedFromLimits[to]) {
                    require(amount <= _maxTxAmountBuy, "Transfer amount exceeds the maxTxAmount.");
                }
            } else if (lpPairs[to]) {
                if (!_isExcludedFromLimits[from] && !_isExcludedFromLimits[to]) {
                    require(amount <= _maxTxAmountSell, "Transfer amount exceeds the maxTxAmount.");
                }
            }
            if(to != address(dexRouter) && !lpPairs[to]) {
                if (!_isExcludedFromLimits[to]) {
                    require(balanceOf(to) + amount <= _maxWalletSize, "Transfer amount exceeds the maxWalletSize.");
                }
            }
        }

        return _finalizeTransfer(from, to, amount);
    }

    function enableTrading() public onlyOwner {
        require(!tradingEnabled, "Trading already enabled!");
        require(_hasLiqBeenAdded, "Liquidity must be added.");
        
        tradingEnabled = true;
    }



    function _checkLiquidityAdd(address from, address to) private {
        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");
        if (!_hasLimits(from, to) && to == lpPair) {
            _liquidityHolders[from] = true;
            _hasLiqBeenAdded = true;
        }
    }
    
    function sweepContingency() external onlyOwner {
        require(!_hasLiqBeenAdded, "Cannot call after liquidity.");
        payable(_owner).transfer(address(this).balance);
    }

    function multiSendTokens(address[] calldata accounts, uint256[] calldata amounts) external {
        require(accounts.length == amounts.length, "Lengths do not match.");
        for (uint8 i = 0; i < accounts.length; i++) {
            require(balanceOf(msg.sender) >= amounts[i]);
            _transfer(msg.sender, accounts[i], amounts[i]*10**_decimals);
        }
    }

    function _finalizeTransfer(address from, address to, uint256 amount) private returns (bool) {
        if (!_hasLiqBeenAdded) {
            _checkLiquidityAdd(from, to);
            if (!_hasLiqBeenAdded && _hasLimits(from, to)) {
                revert("Only owner can transfer at this time.");
            }
        }


        _tOwned[from] -= amount;
        _tOwned[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }

    
}