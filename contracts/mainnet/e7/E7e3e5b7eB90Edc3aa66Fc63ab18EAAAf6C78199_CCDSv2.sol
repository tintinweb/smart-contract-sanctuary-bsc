/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IERC20Extended {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract CCDSv2 is IERC20Extended, Auth {
    address private constant DEAD_ADDR = 0x000000000000000000000000000000000000dEaD;

    string private constant _name = "CCDS v2";
    string private constant _symbol = "CCDS2.0";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 210000 * 10**18;

    IUniswapV2Router02 public router;
    address public pairAddress;
    address public usdAddress;
    address public marketAddress;
    uint256 public buyMarketFee = 2;
    uint256 public buyDestoryFee = 0;
    uint256 public buyLiquidityFee = 0;
    uint256 public sellMarketFee = 2;
    uint256 public sellDestoryFee = 0;
    uint256 public sellLiquidityFee = 0;
    uint256 public transferFee = 0;
    uint256 public feeDenominator = 100;
    uint256 public holdLimit = 210000 * 10**18;

    bool public isAutoLiquidity;
    bool public swapEnabled;
    uint256 public swapThreshold;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _blackList;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isHoldLimitExempt;

    event AutoLiquify(uint256 amountBNB, uint256 amount);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    /**
     *  Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E, 0x55d398326f99059fF775485246999027B3197955
     */
    constructor(address router_, address usd_, address market_) Auth(msg.sender) {
        router = IUniswapV2Router02(router_);
        pairAddress = IUniswapV2Factory(router.factory()).createPair(
            address(this),
            usd_
        );
        usdAddress = usd_;
        marketAddress = market_;

        swapEnabled = false;
        swapThreshold = _totalSupply / 10000;

        isFeeExempt[msg.sender] = true;

        isHoldLimitExempt[msg.sender] = true;
        isHoldLimitExempt[pairAddress] = true;
        isHoldLimitExempt[DEAD_ADDR] = true;
        isHoldLimitExempt[marketAddress] = true;
        isHoldLimitExempt[address(this)] = true;
        isHoldLimitExempt[address(router)] = true;

        _allowances[address(this)][address(router)] = _totalSupply;
        IERC20Extended(usdAddress).approve(address(router), type(uint256).max);

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        if(msg.sender == pairAddress){
            _transfer(msg.sender, recipient, amount);
        }else{
            _tokenOnlyTransfer(msg.sender, recipient, amount);
        }
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] < _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }

        if (recipient == pairAddress) {
            _transfer(sender, recipient, amount);
        } else {
            _tokenOnlyTransfer(sender, recipient, amount);
        }
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        _beforeTokenTransfer(sender, recipient, amount);
        
        if (shouldAutoSwap(sender)) {
            swapAndLiquify();
        }

        _balances[sender] = _balances[sender] - amount;

        bool isTakeFee = true;
        if(isFeeExempt[sender] || isFeeExempt[recipient]) {
            isTakeFee = false;
        }

        uint256 amountReceived = isTakeFee
            ? takeFee(sender, recipient, amount)
            : amount;

        _balances[recipient] = _balances[recipient] + amountReceived;

        emit Transfer(sender, recipient, amountReceived);
        _afterTokenTransfer(recipient);
        return true;
    }

    function _tokenOnlyTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender] - amount;

        uint256 amountReceived = amount;
        if(!isFeeExempt[sender] && !isFeeExempt[recipient]) {
            uint256 fee = amount * transferFee / feeDenominator;
            amountReceived = amount - fee;
        }

        _balances[recipient] = _balances[recipient] + amountReceived;
        emit Transfer(sender, recipient, amountReceived);
        _afterTokenTransfer(recipient);
        return true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) private view {
        require(from != address(0), "From zero address");
        require(to != address(0), "To zero address");
        require(amount > 0, "Zero amount");
        require(!_blackList[from] && !_blackList[to], "Blacked");
    }

    function _afterTokenTransfer(
        address to
    ) private view {
        if (!isHoldLimitExempt[to]) {
            require(balanceOf(to) <= holdLimit, "Max Hold");
        }
    }

    function isBuy(address from, address to) internal view returns (bool) {
        return from == pairAddress && to != address(router);
    }

    function isSell(address from, address to) internal view returns (bool) {
        return to == pairAddress && from != address(this);
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 marketAmount = 0;
        uint256 destoryAmount = 0;
        uint256 liquidityAmount = 0;
        if (isBuy(sender, recipient)) {
            marketAmount = amount * buyMarketFee / feeDenominator;
            destoryAmount = amount * buyDestoryFee / feeDenominator;
            liquidityAmount = amount * buyLiquidityFee / feeDenominator;
        } else if (isSell(sender, recipient)) {
            marketAmount = amount * sellMarketFee / feeDenominator;
            destoryAmount = amount * sellDestoryFee / feeDenominator;
            liquidityAmount = amount * sellLiquidityFee / feeDenominator;
        }
        if (marketAmount > 0) {
            _balances[marketAddress] = _balances[marketAddress] + marketAmount;
            emit Transfer(sender, marketAddress, marketAmount);
        }
        if (destoryAmount > 0) {
            _balances[DEAD_ADDR] = _balances[DEAD_ADDR] + destoryAmount;
            emit Transfer(sender, DEAD_ADDR, destoryAmount);
        }
        if (liquidityAmount > 0) {
            _balances[address(this)] = _balances[address(this)] + liquidityAmount;
            emit Transfer(sender, address(this), liquidityAmount);
        }
        return amount - marketAmount - destoryAmount - liquidityAmount;
    }

    function shouldAutoSwap(address sender) internal view returns (bool) {
        return
            sender != pairAddress &&
            !inSwap &&
            swapEnabled && 
            balanceOf(address(this)) >= swapThreshold;
    }

    function swapAndLiquify() private swapping {
        uint256 contractTokenBalance = balanceOf(address(this));
        // split the contract balance into halves
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        IERC20Extended usdToken = IERC20Extended(usdAddress);
        uint256 initialBalance = usdToken.balanceOf(address(this));
        // swap tokens for USD
        swapTokensForUsd(half);
        // USD just swap into?
        uint256 newBalance = usdToken.balanceOf(address(this)) - initialBalance;
        // add liquidity
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForUsd(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdAddress;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdAmount) private {
        // IERC20Extended(usdAddress).approve(address(router), usdAmount * 2);
        router.addLiquidity(
            address(this),
            usdAddress,
            tokenAmount,
            usdAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp
        );
    }
    
    function setBlackList(address[] memory _list, bool _isBlack) external authorized {
        for (uint256 i = 0; i < _list.length; i++) {
            _blackList[_list[i]] = _isBlack;
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsHoldLimitExempt(address holder, bool exempt) external authorized {
        isHoldLimitExempt[holder] = exempt;
    }

    function setFees(
        uint256 _buyMarketFee,
        uint256 _buyDestoryFee,
        uint256 _buyLiquidityFee,
        uint256 _sellMarketFee,
        uint256 _sellDestoryFee,
        uint256 _sellLiquidityFee,
        uint256 _transferFee
    ) external authorized {
        buyMarketFee = _buyMarketFee;
        buyDestoryFee = _buyDestoryFee;
        buyLiquidityFee = _buyLiquidityFee;
        sellMarketFee = _sellMarketFee;
        sellDestoryFee = _sellDestoryFee;
        sellLiquidityFee = _sellLiquidityFee;
        transferFee = _transferFee;
    }

    function setSwapEnable(bool _enable) external authorized {
        swapEnabled = _enable;
    }

    function setHoldLimit(uint256 _amount) external authorized {
        holdLimit = _amount;
    }

    function setSwapThreshold(uint256 _amount) external authorized {
        swapThreshold = _amount;
    }

    function setMarketAddress(address _market) external authorized {
        marketAddress = _market;
    }
}