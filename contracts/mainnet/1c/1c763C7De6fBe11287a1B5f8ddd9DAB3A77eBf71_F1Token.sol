/**
 *Submitted for verification at BscScan.com on 2022-07-13
*/

// File: default_workspace/F1/F1Token.sol


pragma solidity ^0.8.4;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

interface IUniswapV2Pair {
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBscPrice {
    function getTokenUsdtPrice(address _token) external view returns (uint256);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
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
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract F1Token is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public priceToken;
    uint256 constant baseTime = 1652025600;
    mapping(uint256 => uint256) public historyTokenPrice;

    uint256 public buyFee = 10;

    uint256 public totalSellFee = 15;
    uint256 public reflowFee = 5;
    uint256 public luckyPoolFee = 5;
    uint256 public deadFee = 5;

    //跌幅临界值
    uint256 public downCriticalFee = 15;
    uint256 public perDownDeadFee = 5;
    uint256 public maxSellFee = 49;

    address public luckyPoolWalletAddress;
    address public reflowWalletAddress;
    address public liqudityWalletAddress;
    uint256 public yDayTokenPrice;

    mapping(uint256 => uint256[]) public tokenPriceArray;
    uint256 public updatePriceInterval = 1800;
    uint256 public lastUpdateTime;
    bool public priceSwitch = true;

    //销毁地址
    address constant deadWalletAddress =
        0x000000000000000000000000000000000000dEaD;

    mapping(address => bool) private _isExcludedFromFees;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        address reflowWalletAddress_,
        address luckyPoolWalletAddress_,
        address liqudityWalletAddress_,
        address initHoldAddress_
    ) payable ERC20(name_, symbol_) {
        uint256 totalSupply = totalSupply_ * (10**18);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        reflowWalletAddress = reflowWalletAddress_;
        luckyPoolWalletAddress = luckyPoolWalletAddress_;
        liqudityWalletAddress = liqudityWalletAddress_;

        excludeFromFees(owner(), true);
        excludeFromFees(luckyPoolWalletAddress, true);
        excludeFromFees(reflowWalletAddress, true);
        excludeFromFees(liqudityWalletAddress, true);
        excludeFromFees(initHoldAddress_, true);
        _mint(initHoldAddress_, totalSupply);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        if (_isExcludedFromFees[account] != excluded) {
            _isExcludedFromFees[account] = excluded;
            emit ExcludeFromFees(account, excluded);
        }
    }

    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setLuckyPoolWalletAddress(address addr) external onlyOwner {
        luckyPoolWalletAddress = addr;
    }

    function setReflowWalletAddress(address addr) external onlyOwner {
        reflowWalletAddress = addr;
    }

    function setLiqudityWalletAddress(address addr) external onlyOwner {
        liqudityWalletAddress = addr;
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (
            _isExcludedFromFees[from] ||
            _isExcludedFromFees[to] ||
            _isExcludedFromFees[msg.sender]
        ) {
            super._transfer(from, to, amount);
            return;
        }
        uint256 finalAmount = takeAllFee(from, to, amount);
        super._transfer(from, to, finalAmount);
    }

    function setPriceSwitch(bool newValue) public onlyOwner {
        priceSwitch = newValue;
    }

    function takeAllFee(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256 amountAfter) {
        (uint256 currentDay, uint256 currentPrice) = pushAndGetTokenPrice();
        amountAfter = amount;
        if (from == uniswapV2Pair) {
            uint256 BFee = amount.mul(buyFee).div(100);
            if (BFee > 0) {
                super._transfer(from, liqudityWalletAddress, BFee);
                amountAfter = amountAfter.sub(BFee);
            }
        } else if (to == uniswapV2Pair) {
            uint256 RFee = amount.mul(reflowFee).div(100);
            if (RFee > 0) {
                super._transfer(from, reflowWalletAddress, RFee);
                amountAfter = amountAfter.sub(RFee);
            }
            uint256 LFee = amount.mul(luckyPoolFee).div(100);
            if (LFee > 0) {
                super._transfer(from, luckyPoolWalletAddress, LFee);
                amountAfter = amountAfter.sub(LFee);
            }
            if (priceSwitch) {
                uint256 totalDeadFee = getTotalSellDownFee(
                    currentDay,
                    currentPrice
                );
                uint256 DFee = amount.mul(totalDeadFee).div(100);
                if (DFee > 0) {
                    super._transfer(from, deadWalletAddress, DFee);
                    amountAfter = amountAfter.sub(DFee);
                }
            }
        }
        return amountAfter;
    }

    function setMaxSellFee(uint256 maxSellFee_) public onlyOwner {
        maxSellFee = maxSellFee_;
    }

    function getTotalSellDownFee(uint256 currentDay, uint256 currentPrice)
        public
        returns (uint256)
    {
        uint256 totalDeadFee = deadFee;
        uint256 downDeadFee = getPriceDownRate(currentDay, currentPrice);
        totalDeadFee = totalDeadFee.add(downDeadFee);
        return totalDeadFee > maxSellFee ? maxSellFee : totalDeadFee;
    }

    function setPriceToken(address addr) public onlyOwner {
        priceToken = addr;
    }

    function setBuyFee(uint256 buyFee_) public onlyOwner {
        buyFee = buyFee_;
    }

    function setFeflowFee(uint256 reflowFee_) public onlyOwner {
        reflowFee = reflowFee_;
        totalSellFee = reflowFee.add(luckyPoolFee).add(deadFee);
    }

    function setPerDownDeadFee(uint256 perDownDeadFee_) public onlyOwner {
        perDownDeadFee = perDownDeadFee_;
    }

    function setDeadFee(uint256 deadFee_) public onlyOwner {
        deadFee = deadFee_;
        totalSellFee = reflowFee.add(luckyPoolFee).add(deadFee);
    }

    function setLuckyPoolFee(uint256 luckyPoolFee_) public onlyOwner {
        luckyPoolFee = luckyPoolFee_;
        totalSellFee = reflowFee.add(luckyPoolFee).add(deadFee);
    }

    function getCurrentDay() internal view returns (uint256) {
        uint256 intervalDay = block.timestamp.sub(baseTime).div(1 days);
        return baseTime.add(intervalDay * 1 days);
    }

    function getTokenPrice() external view returns (uint256) {
        return _getTokenPrice();
    }

    function _getTokenPrice() internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uint256[] memory amounts = uniswapV2Router.getAmountsOut(1e18, path);
        return amounts[1];
    }

    function pushAndGetTokenPrice()
        internal
        returns (uint256 currentDay, uint256 currentPrice)
    {
        if (balanceOf(uniswapV2Pair) > 0) {
            currentDay = getCurrentDay();
            currentPrice = _getTokenPrice();
            uint256 currentTime = block.timestamp;
            if (currentTime.sub(lastUpdateTime) >= updatePriceInterval) {
                tokenPriceArray[currentDay].push(currentPrice);
                lastUpdateTime = currentTime;
            }
        }
    }

    function getPriceDownRate(uint256 currentDay, uint256 currentPrice)
        internal
        returns (uint256)
    {
        if (currentPrice == 0) {
            return 0;
        }
        uint256 yDay = currentDay.sub(1 days);
        uint256 yPrice = historyTokenPrice[yDay];
        uint256 plength = tokenPriceArray[yDay].length;
        if (yPrice == 0 && plength == 0) {
            yPrice = yDayTokenPrice;
        }
        if (yPrice == 0 && plength > 0) {
            uint256 sumPrice;
            for (uint256 i = 0; i < plength; i++) {
                sumPrice += tokenPriceArray[yDay][i];
            }
            yPrice = sumPrice.div(plength);
            yDayTokenPrice = yPrice;
            historyTokenPrice[yDay] = yPrice;
        }
        if (currentPrice >= yPrice) {
            return 0;
        }
        uint256 downRate = yPrice.sub(currentPrice).mul(100).div(yPrice);
        if (downRate > downCriticalFee) {
            return downRate.sub(downCriticalFee).mul(perDownDeadFee);
        }
        return 0;
    }

    function setDownCriticalFee(uint256 downCriticalFee_) public onlyOwner {
        downCriticalFee = downCriticalFee_;
    }

    function setUpdatePriceInterval(uint256 interval_) public onlyOwner {
        updatePriceInterval = interval_;
    }
}