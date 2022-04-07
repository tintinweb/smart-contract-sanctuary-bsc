/**
 *Submitted for verification at BscScan.com on 2022-04-07
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

contract LibertyCoin is IERC20Extended, Auth {

    address private constant DEAD = address(0xdead);
    address private constant ZERO = address(0);

    string private constant _name = "Liberty Coin";
    string private constant _symbol = "LBC";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1000000 * 10**18;

    IUniswapV2Router02 public router;
    address public pair;
    address public marketAddress = 0x41B35fB40071be41096C4600fa44ba1DE68FEDA1;

    uint256 public buyFee = 8;
    uint256 public sellFee = 12;
    uint256 public botFee = 90;
    uint256 public feeDenominator = 100;

    uint256 public launchedAt = 0;
    uint256 public cooldownInternal = 1;
    uint256 public limitAmount = 40000 * 10**18;
    uint256 public swapThreshold = 5000 * 10**18;
    bool public swapEnabled;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public isFeeExempt;
    mapping(address => uint256) public addrCooldown;
    mapping(address => bool) private _blackList;

    event AutoLiquify(uint256 amountBNB, uint256 amount);

    bool private inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(address router_) Auth(msg.sender) {
        router = IUniswapV2Router02(router_);
        pair = IUniswapV2Factory(router.factory()).createPair(
            address(this),
            router.WETH()
        );

        swapEnabled = false;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[marketAddress] = true;

        _allowances[address(this)][address(router)] = _totalSupply;

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

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        if (msg.sender == pair) {
            _transfer(msg.sender, recipient, amount);
        } else {
            _tokenOlnyTransfer(msg.sender, recipient, amount);
        }
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] -= amount;
        }

        if (recipient == pair) {
            _transfer(sender, recipient, amount);
        } else {
            _tokenOlnyTransfer(sender, recipient, amount);
        }
        return true;
    }

    function _transfer(
        address sender, address recipient, uint256 amount
    ) private returns (bool) {
        require(sender != address(0), "From zero address");
        require(recipient != address(0), "To zero address");
        require(amount > 0, "Zero amount");
        require(!_blackList[sender] && !_blackList[recipient], "BLACKED");

        uint256 feeAmount = 0;
        bool isTakeFee = true;
        if(isFeeExempt[sender] || isFeeExempt[recipient]) {
            isTakeFee = false;
        }

        if (isBuy(sender)) {
            require(launchedAt > 0, "Not opened");
            if (launchedAt + 1 >= block.number) {
                uint256 botFeeAmount = amount * botFee / feeDenominator;
                if (botFeeAmount > 0) amount = takeFee(sender, marketAddress, botFeeAmount, amount);
            }
            require(
                (addrCooldown[recipient] + cooldownInternal) < block.number, 
                "Wait a moment"
            );
            if (isTakeFee) {
                require(amount <= limitAmount, "Limited");
                feeAmount = amount * buyFee / feeDenominator;
            }
        }

        if (isSell(recipient) && isTakeFee) {
            feeAmount = amount * sellFee / feeDenominator;
        }
        
        if (shouldSwapMarket()) {
            swapMarket();
        }

        uint256 amountReceived = feeAmount > 0
            ? takeFee(sender, address(this), feeAmount, amount)
            : amount;

        _balances[sender] -= amountReceived;
        _balances[recipient] += amountReceived;

        if (isBuy(sender)) {
            addrCooldown[recipient] = block.number;
        }

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _tokenOlnyTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // buy or removeLiquidity
    function isBuy(address from) internal view returns (bool) {
        return from == pair;
    }

    // sell or addLiquidity
    function isSell(address to) internal view returns (bool) {
        return to == pair;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 feeAmount,
        uint256 amount
    ) internal returns (uint256) {
        _balances[sender] -= feeAmount;
        _balances[recipient] += feeAmount;
        emit Transfer(sender, recipient, feeAmount);
        return amount - feeAmount;
    }

    function shouldSwapMarket() internal view returns (bool) {
        return
            msg.sender != pair &&
            !inSwap &&
            swapEnabled && 
            balanceOf(address(this)) >= swapThreshold;
    }

    function swapMarket() internal swapping {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            swapThreshold,
            0,
            path,
            address(this),
            block.timestamp
        );

        payable(marketAddress).transfer(address(this).balance);
    }

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }
    
    function setIsBlack(address _addr, bool _isBlack) external authorized {
        _blackList[_addr] = _isBlack;
    }

    function setMarket(
        address _marketAddress,
        uint256 _buyFee,
        uint256 _sellFee,
        uint256 _botFee
    ) external authorized {
        marketAddress = _marketAddress;
        buyFee = _buyFee;
        sellFee = _sellFee;
        botFee = _botFee;
    }

    function openSwap()
        external
        authorized
    {
        require(!swapEnabled && launchedAt == 0, "Swap opened");
        swapEnabled = true;
        launchedAt = block.number;
    }

    function setSwapEnable(bool _enable)
        external
        authorized
    {
        swapEnabled = _enable;
    }

    function setSwapThreshold(uint256 _amount)
        external
        authorized
    {
        swapThreshold = _amount;
    }
}