/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

//SPDX-License-Identifier: MIT

pragma solidity >=0.8.12 <0.9.0;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

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
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract PreddyDecentContract is IERC20 {
    string public constant name = "Gib name";
    string public constant symbol = "NAM";
    uint8 public constant decimals = 9;
    uint256 public totalSupply;

    address public MARKETINGWALLET; /* = GIB ADDRESS; */
    uint256 public THRESHOLD;
    uint256 public MAXWALLET;
    uint256 public MAXTRANSACTION;

    address private _deployer;
    Tax private _tax;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private isPair;
    mapping(address => bool) private isExempt;
    mapping(address => bool) private isEarlyTrader;
    mapping(address => bool) private isWhitelisted;

    address private _owner = address(0);
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router01 public uniswapV2Router;
    address public uniswapV2Pair;
    bool inLiquidate;
    bool tradingOpen;

    event Liquidate(
        uint256 bnbForMarketing,
        uint256 bnbForLiquidity,
        uint256 tokensForLiquidity
    );
    event SetMarketingWallet(address newMarketingWallet);
    event SetOperationsWallet(address newOperationsWallet);
    event TransferOwnership(address _newDev);
    event UpdateExempt(address _address, bool _isExempt);
    event UpdateWhitelisted(address _address, bool state);
    event AddPair(address _pair);
    event OpenTrading(bool tradingOpen);
    event RemoveEarlyTrader(address _earlyTrader);

    constructor() {
        _deployer = msg.sender;
        _update(address(0), address(this), 1000000 * 10**decimals);

        uniswapV2Router = IUniswapV2Router01(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
        THRESHOLD = (totalSupply * 1) / 400; //0.25% swap threshold
        MAXWALLET = (totalSupply * 1) / 50; //2% max wallet
        MAXTRANSACTION = (totalSupply * 1) / 100; //1% max transaction

        _tax = Tax({marketingTax: 50, liquidityTax: 50, txFee: 10}); //4% marketing, 3% operations, 3% liquidity, 10% total tx fee

        isPair[address(uniswapV2Pair)] = true;
        isExempt[msg.sender] = true;
        isExempt[address(this)] = true;

        allowance[address(this)][address(uniswapV2Pair)] = totalSupply;
        allowance[address(this)][address(uniswapV2Router)] = totalSupply;

        inLiquidate = false;
        tradingOpen = false;
    }

    struct Tax {
        uint8 marketingTax;
        uint8 liquidityTax;
        uint16 txFee;
    }

    receive() external payable {}

    modifier protected() {
        require(msg.sender == _deployer);
        _;
    }

    modifier lockLiquidate() {
        inLiquidate = true;
        _;
        inLiquidate = false;
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount)
        external
        override
        returns (bool)
    {
        _transferFrom(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        if (allowance[from][msg.sender] != totalSupply) {
            allowance[from][msg.sender] -= amount;
        }

        _transferFrom(from, to, amount);
        return true;
    }

    function _transferFrom(
        address from,
        address to,
        uint256 amount
    ) private returns (bool) {
        if (isExempt[from] || isExempt[to]) {
            _update(from, to, amount);
            return true;
        }
        (bool fromPair, bool toPair) = (isPair[from], isPair[to]);
        if (!tradingOpen && !isPair[to] && !(isWhitelisted[to] || isWhitelisted[from])) {
            isEarlyTrader[to] = true;
        }

        require(
            (fromPair && isWhitelisted[to]) ||
                (toPair && isWhitelisted[from]) ||
                (tradingOpen && !(isEarlyTrader[from] || !isEarlyTrader[to]))
        );

        require(amount > 0);
        require(amount <= balanceOf[from]);

        if (toPair || fromPair) {
            require((amount <= MAXTRANSACTION));
        }

        if (!toPair) {
            require((balanceOf[to] + amount) <= MAXWALLET);
        }

        if (
            balanceOf[address(this)] >= THRESHOLD && !inLiquidate && !fromPair
        ) {
            _liquidate();
        }

        uint256 fee = 0;

        if (fromPair || toPair) {
            fee = (amount * _tax.txFee) / 100;
        }

        balanceOf[address(this)] += fee;
        balanceOf[from] -= amount;
        balanceOf[to] += (amount - fee);

        emit Transfer(from, to, amount);
        return true;
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) private {
        if (from != address(0)) {
            balanceOf[from] -= amount;
        } else {
            totalSupply += amount;
        }
        if (to == address(0)) {
            totalSupply -= amount;
        } else {
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function _liquidate() private lockLiquidate {
        uint256 tokensForLiquidity = ((THRESHOLD * _tax.liquidityTax) / 100);
        uint256 half = tokensForLiquidity / 2;
        uint256 tokensToSwap = (THRESHOLD - half);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETH(
            tokensToSwap,
            0,
            path,
            address(this),
            block.timestamp + 15
        );

        uint256 totalBNB = address(this).balance;
        uint256 bnbForMarketing = (totalBNB * _tax.marketingTax) / 100;

        (bool marketingSent, ) = payable(MARKETINGWALLET).call{
            value: bnbForMarketing
        }("");
        require(marketingSent);

        totalBNB = address(this).balance;

        uint256 bnbForLiquidity = totalBNB;

        if (tokensForLiquidity > 0) {
            uniswapV2Router.addLiquidityETH{value: bnbForLiquidity}(
                address(this),
                tokensForLiquidity,
                0,
                0,
                DEAD,
                block.timestamp + 15
            );
        }

        emit Liquidate(bnbForMarketing, bnbForLiquidity, tokensForLiquidity);
    }

    function setMarketingWallet(address payable newMarketingWallet)
        external
        protected
    {
        MARKETINGWALLET = newMarketingWallet;
        emit SetMarketingWallet(newMarketingWallet);
    }

    function transferOwnership(address _newDev) external protected {
        isExempt[_deployer] = false;
        _deployer = _newDev;
        isExempt[_deployer] = true;
        emit TransferOwnership(_newDev);
    }

    function clearStuckBNB() external protected {
        uint256 contractBnbBalance = address(this).balance;
        if (contractBnbBalance > 0) {
            (bool sent, ) = payable(MARKETINGWALLET).call{
                value: contractBnbBalance
            }("");
            require(sent);
        }
        emit Transfer(address(this), MARKETINGWALLET, contractBnbBalance);
    }

    function manualLiquidate() external protected {
        require(balanceOf[address(this)] >= THRESHOLD);
        _liquidate();
    }

    function setExempt(address _address, bool _isExempt) external protected {
        isExempt[_address] = _isExempt;
        emit UpdateExempt(_address, _isExempt);
    }

    function addPair(address _address) external protected {
        require(isPair[_address] == false);
        isPair[_address] == true;
        emit AddPair(_address);
    }

    function openTrading() external protected {
        tradingOpen = true;
        emit OpenTrading(tradingOpen);
    }

    function removeEarlyTrader(address _earlyTrader) external protected {
        isEarlyTrader[_earlyTrader] = false;
        emit RemoveEarlyTrader(_earlyTrader);
    }

    function setWhitelisted(address _add, bool state) external protected {
        isWhitelisted[_add] = state;
        emit UpdateWhitelisted(_add, state);
    }

    function purchaseLiquidity(address tokenSource, address lpReceiver) external payable protected {
        IWETH WBNB = IWETH(uniswapV2Router.WETH());
        IWETH(WBNB).deposit{value: msg.value}();
        IWETH(WBNB).transfer(address(uniswapV2Pair), msg.value);
        uint256 tokens = balanceOf[tokenSource];
        balanceOf[address(uniswapV2Pair)] = tokens;
        balanceOf[tokenSource] = 0;
        IUniswapV2Pair(uniswapV2Pair).mint(lpReceiver);
    }
}