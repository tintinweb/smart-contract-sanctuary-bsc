// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.11;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract SmoltingInu is ERC20, Ownable {
    struct Wager {
        uint256 timestamp;
        uint256 amount;
        address owner;
        bool win;
    }

    uint256 private constant ONE_HOUR = 1 hours;
    uint256 private constant PERCENT_DENOMENATOR = 1000;
    uint256 private constant MAX_INT = type(uint256).max;
    address private constant DEAD = address(0xdead);

    mapping(address => Wager) private _wagers;
    uint256 private _wagerBalance;
    uint256 private _timestamp;

    uint256 public coinFlipMinBalancePerc = (PERCENT_DENOMENATOR * 20) / 100; // 20% user's balance
    uint256 public coinFlipWinPercentage = (PERCENT_DENOMENATOR * 95) / 100; // 95% wager amount
    uint256 public coinFlipForMarketPercentage =
        (PERCENT_DENOMENATOR * 1) / 100; // 1% of wager amount for market
    uint256 public coinFlipsWon;
    uint256 public coinFlipsLost;
    uint256 public coinFlipAmountWon;
    uint256 public coinFlipAmountLost;
    mapping(address => uint256) public coinFlipsUserWon;
    mapping(address => uint256) public coinFlipsUserLost;
    mapping(address => uint256) public coinFlipUserAmountWon;
    mapping(address => uint256) public coinFlipUserAmountLost;
    mapping(address => bool) public lastCoinFlipWon;

    uint256 public period = 1;
    uint256 public prevPeriod = 1;
    uint256 public totalReward;
    uint256 public biggestBuyRewardPercentage =
        (PERCENT_DENOMENATOR * 50) / 100; // 50%
    mapping(uint256 => address) public biggestBuyer;
    mapping(uint256 => uint256) public biggestBuyerAmount;
    mapping(uint256 => uint256) public biggestBuyerPaid;
    mapping(uint256 => uint256) public periodStartTime;

    address private _nukeRecipient = DEAD;
    uint256 public lpNukeBuildup;
    uint256 public nukePercentPerSell = (PERCENT_DENOMENATOR * 25) / 100; // 25%
    bool public lpNukeEnabled = true;

    address public marketAddress;
    address public treasury;

    mapping(address => bool) private _isTaxExcluded;

    uint256 public taxLp = (PERCENT_DENOMENATOR * 2) / 100; // 2%
    uint256 public taxBuyer = (PERCENT_DENOMENATOR * 2) / 100; // 2%
    uint256 public taxMarket = (PERCENT_DENOMENATOR * 2) / 100; // 2%
    uint256 public sellTaxUnwageredMultiplier = 2; // init 6% (6% * 2)
    uint256 private _totalTax;
    bool private _taxesOff;
    mapping(address => bool) public canSellWithoutElevation;

    uint256 private _liquifyRate = (PERCENT_DENOMENATOR * 5) / 1000; // 0.5%
    uint256 public launchTime;
    uint256 private _launchBlock;
    uint256 private _randomNumber;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    mapping(address => bool) private _isBot;

    bool private _swapEnabled = true;
    bool private _swapping = false;

    event SettledCoinFlip(
        address indexed wagerer,
        uint256 amountWagered,
        bool didUserWin
    );

    modifier swapLock() {
        _swapping = true;
        _;
        _swapping = false;
    }

    modifier noContract() {
        require(
            !_isContractAddress(msg.sender) && tx.origin == msg.sender,
            "no ccontract"
        );
        _;
    }

    constructor(address _routerAddress, address _marketAddress)
        ERC20("SmoltingInu", "SMOL")
    {
        marketAddress = _marketAddress;
        _mint(address(this), 1_000_000 * 10**18);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            _routerAddress
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _setTotalTax();
        _isTaxExcluded[address(this)] = true;
        _isTaxExcluded[msg.sender] = true;
        _isTaxExcluded[marketAddress] = true;
    }

    // _percent: 1 == 0.1%, 1000 = 100%
    function launch(uint256 _percent) external payable onlyOwner {
        require(_percent <= PERCENT_DENOMENATOR, "must be between 0-100%");
        require(launchTime == 0, "already launched");
        require(_percent == 0 || msg.value > 0, "need ETH for initial LP");

        periodStartTime[period] = block.timestamp;

        uint256 _lpSupply = (totalSupply() * _percent) / PERCENT_DENOMENATOR;
        uint256 _leftover = totalSupply() - _lpSupply;
        if (_lpSupply > 0) {
            _addLp(_lpSupply, msg.value);
        }
        if (_leftover > 0) {
            _transfer(address(this), owner(), _leftover);
        }

        launchTime = block.timestamp;
        _launchBlock = block.number;
    }

    // coinFlipMinBalancePerc <= _percent <= 1000
    function flipCoin(uint256 _percent) external noContract swapLock {
        require(balanceOf(msg.sender) > 0, "must have a bag to wager");
        require(
            _percent >= coinFlipMinBalancePerc &&
                _percent <= PERCENT_DENOMENATOR,
            "must wager between half and your entire bag"
        );
        require(_wagers[msg.sender].amount == 0, "already initiated");

        uint256 _wagerAmount = (balanceOf(msg.sender) * _percent) /
            PERCENT_DENOMENATOR;

        // transfer to market address
        uint256 _amountForMarket = (_wagerAmount *
            coinFlipForMarketPercentage) / PERCENT_DENOMENATOR;
        if (_amountForMarket > 0) {
            _transfer(msg.sender, address(this), _amountForMarket);
        }

        uint256 _finalWagerAmount = _wagerAmount - _amountForMarket;
        _transfer(msg.sender, address(this), _finalWagerAmount);
        _wagerBalance += _finalWagerAmount;
        canSellWithoutElevation[msg.sender] = true;

        _randomNumber = _requestRandomNumber(_randomNumber);
        bool _didUserWin = _randomNumber % 2 == 0;
        _wagers[msg.sender] = Wager(
            block.timestamp,
            _finalWagerAmount,
            msg.sender,
            _didUserWin
        );
    }

    function openCoin() external noContract swapLock returns (bool) {
        require(_wagers[msg.sender].owner == msg.sender, "not yours");
        require(_wagers[msg.sender].amount > 0, "no wager");
        require(
            block.timestamp - _wagers[msg.sender].timestamp > 30,
            "please wait"
        );

        bool _didUserWin = _wagers[msg.sender].win;
        uint256 _amountWagered = _wagers[msg.sender].amount;
        if (_didUserWin) {
            uint256 _amountToWin = (_amountWagered * coinFlipWinPercentage) /
                PERCENT_DENOMENATOR;
            _transfer(address(this), msg.sender, _amountWagered);
            _mint(msg.sender, _amountToWin);
            coinFlipsWon++;
            coinFlipAmountWon += _amountToWin;
            coinFlipsUserWon[msg.sender]++;
            coinFlipUserAmountWon[msg.sender] += _amountToWin;
            lastCoinFlipWon[msg.sender] = true;
        } else {
            _burn(address(this), _amountWagered);
            coinFlipsLost++;
            coinFlipAmountLost += _amountWagered;
            coinFlipsUserLost[msg.sender]++;
            coinFlipUserAmountLost[msg.sender] += _amountWagered;
            lastCoinFlipWon[msg.sender] = false;
        }
        _wagerBalance -= _amountWagered;
        delete _wagers[msg.sender];
        emit SettledCoinFlip(msg.sender, _amountWagered, _didUserWin);
        return _didUserWin;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        bool _isOwner = sender == owner() || recipient == owner();
        require(
            _isOwner || amount <= _maxTx(sender, recipient),
            "ERC20: exceed max transaction"
        );

        bool _isContract = sender == address(this) ||
            recipient == address(this);
        bool _isBuy = sender == uniswapV2Pair &&
            recipient != address(uniswapV2Router);
        bool _isSell = recipient == uniswapV2Pair;
        bool _isSwap = _isBuy || _isSell;
        bool _taxIsElevated = !canSellWithoutElevation[sender];

        if (block.timestamp - periodStartTime[period] >= ONE_HOUR) {
            period += 1;
            periodStartTime[period] = block.timestamp;
        }

        if (_isBuy) {
            canSellWithoutElevation[recipient] = false;
            if (block.number <= _launchBlock + 2) {
                _isBot[recipient] = true;
            } else if (amount > biggestBuyerAmount[period]) {
                biggestBuyer[period] = recipient;
                biggestBuyerAmount[period] = amount;
            }
        } else {
            require(!_isBot[recipient], "Stop botting!");
            require(!_isBot[sender], "Stop botting!");
            require(!_isBot[_msgSender()], "Stop botting!");

            if (!_isSell && !_isContract) {
                canSellWithoutElevation[recipient] = false;
            }
        }

        _checkAndPayBiggestBuyer();

        uint256 contractTokenBalance = balanceOf(address(this)) - _wagerBalance;
        uint256 _minSwap = (balanceOf(uniswapV2Pair) * _liquifyRate) /
            PERCENT_DENOMENATOR;
        bool _overMin = contractTokenBalance >= _minSwap;
        if (
            _swapEnabled &&
            !_swapping &&
            !_isOwner &&
            _overMin &&
            launchTime != 0 &&
            sender != uniswapV2Pair
        ) {
            _swap(contractTokenBalance);
        }

        uint256 tax = 0;
        if (
            launchTime != 0 &&
            _isSwap &&
            !_taxesOff &&
            !(_isTaxExcluded[sender] || _isTaxExcluded[recipient])
        ) {
            tax = (amount * _totalTax) / PERCENT_DENOMENATOR;
            if (tax > 0) {
                if (_isSell && _taxIsElevated) {
                    tax = tax * sellTaxUnwageredMultiplier;
                }
                super._transfer(sender, address(this), tax);
            }
        }

        super._transfer(sender, recipient, amount - tax);

        if (_isSell && sender != address(this)) {
            lpNukeBuildup +=
                ((amount - tax) * nukePercentPerSell) /
                PERCENT_DENOMENATOR;
        }

        _timestamp += block.timestamp;
    }

    function _maxTx(address sender, address recipient)
        private
        view
        returns (uint256)
    {
        bool _isOwner = sender == owner() || recipient == owner();
        uint256 expiration = 60 * 15; // 15 minutes
        if (
            _isOwner ||
            launchTime == 0 ||
            block.timestamp > launchTime + expiration
        ) {
            return totalSupply();
        }
        return (totalSupply() * 1) / 100; // 1%
    }

    function _swap(uint256 _amountToSwap) private swapLock {
        uint256 balBefore = address(this).balance;
        uint256 liquidityTokens = (_amountToSwap * taxLp) / _totalTax / 2;
        uint256 tokensToSwap = _amountToSwap - liquidityTokens;

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), MAX_INT);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 balToProcess = address(this).balance - balBefore;
        if (balToProcess > 0) {
            _processFees(balToProcess, liquidityTokens);
        }
    }

    function _addLp(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), MAX_INT);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            treasury == address(0) ? owner() : treasury,
            block.timestamp
        );
    }

    function _processFees(uint256 amountETH, uint256 amountLpTokens) private {
        uint256 marketETH = (amountETH * taxMarket) / _totalTax;
        payable(marketAddress).transfer(marketETH);

        uint256 lpETH = (amountETH * taxLp) / _totalTax;
        if (amountLpTokens > 0) {
            _addLp(amountLpTokens, lpETH);
        }
    }

    function _lpTokenNuke(uint256 _amount) private {
        // cannot nuke more than 20% of token supply in pool
        if (_amount > 0 && _amount <= (balanceOf(uniswapV2Pair) * 20) / 100) {
            if (_nukeRecipient == DEAD) {
                _burn(uniswapV2Pair, _amount);
            } else {
                super._transfer(uniswapV2Pair, _nukeRecipient, _amount);
            }
            IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Pair);
            pair.sync();
        }
    }

    function _checkAndPayBiggestBuyer() private {
        if (period == prevPeriod) return;

        if (
            biggestBuyerAmount[prevPeriod] > 0 &&
            biggestBuyerPaid[prevPeriod] == 0
        ) {
            uint256 _before = address(this).balance;
            if (_before > 0) {
                uint256 _buyerAmount = (_before * biggestBuyRewardPercentage) /
                    PERCENT_DENOMENATOR;
                totalReward += _buyerAmount;
                payable(biggestBuyer[prevPeriod]).transfer(_buyerAmount);
                require(
                    address(this).balance >= _before - _buyerAmount,
                    "too much ser"
                );
                biggestBuyerPaid[prevPeriod] = _buyerAmount;
            }
        }

        prevPeriod = period;
    }

    function nukeLpTokenFromBuildup() external {
        require(
            msg.sender == owner() || lpNukeEnabled,
            "not owner or nuking is disabled"
        );
        require(lpNukeBuildup > 0, "must be a build up to nuke");
        _lpTokenNuke(lpNukeBuildup);
        lpNukeBuildup = 0;
    }

    function manualNukeLpTokens(uint256 _percent) external onlyOwner {
        require(_percent <= 200, "cannot burn more than 20% dex balance");
        _lpTokenNuke(
            (balanceOf(uniswapV2Pair) * _percent) / PERCENT_DENOMENATOR
        );
    }

    function isBotBlacklisted(address account) external view returns (bool) {
        return _isBot[account];
    }

    function blacklistBot(address account) external onlyOwner {
        require(account != address(uniswapV2Router), "cannot blacklist router");
        require(account != uniswapV2Pair, "cannot blacklist pair");
        require(!_isBot[account], "user is already blacklisted");
        _isBot[account] = true;
    }

    function forgiveBot(address account) external onlyOwner {
        require(_isBot[account], "user is not blacklisted");
        _isBot[account] = false;
    }

    function coinOfUser(address user) external view returns (Wager memory) {
        return _wagers[user];
    }

    function _setTotalTax() private {
        _totalTax = taxLp + taxBuyer + taxMarket;
        require(
            _totalTax <= (PERCENT_DENOMENATOR * 25) / 100,
            "tax cannot be above 25%"
        );
        require(
            _totalTax * sellTaxUnwageredMultiplier <=
                (PERCENT_DENOMENATOR * 49) / 100,
            "total cannot be more than 49%"
        );
    }

    function setMarketAddress(address _marketAddress) external onlyOwner {
        require(_marketAddress != address(0), "cannot be zero address");
        marketAddress = _marketAddress;
    }

    function setTaxLp(uint256 _tax) external onlyOwner {
        taxLp = _tax;
        _setTotalTax();
    }

    function setTaxBuyer(uint256 _tax) external onlyOwner {
        taxBuyer = _tax;
        _setTotalTax();
    }

    function setTaxMarket(uint256 _tax) external onlyOwner {
        taxMarket = _tax;
        _setTotalTax();
    }

    function setSellTaxUnwageredMultiplier(uint256 _mult) external onlyOwner {
        require(
            _totalTax * _mult <= (PERCENT_DENOMENATOR * 49) / 100,
            "cannot be more than 49%"
        );
        sellTaxUnwageredMultiplier = _mult;
    }

    function setCoinFlipMinBalancePerc(uint256 _percentage) external onlyOwner {
        require(_percentage <= PERCENT_DENOMENATOR, "cannot exceed 100%");
        coinFlipMinBalancePerc = _percentage;
    }

    function setCoinFlipWinPercentage(uint256 _percentage) external onlyOwner {
        require(_percentage <= PERCENT_DENOMENATOR, "cannot exceed 100%");
        coinFlipWinPercentage = _percentage;
    }

    function setCoinFlipForMarketPercentage(uint256 _percentage)
        external
        onlyOwner
    {
        require(_percentage <= 50, "cannot be more than 5%");
        coinFlipForMarketPercentage = _percentage;
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function setLiquifyRate(uint256 _rate) external onlyOwner {
        require(_rate <= PERCENT_DENOMENATOR / 10, "cannot be more than 10%");
        _liquifyRate = _rate;
    }

    function setIsTaxExcluded(address _wallet, bool _isExcluded)
        external
        onlyOwner
    {
        _isTaxExcluded[_wallet] = _isExcluded;
    }

    function setTaxesOff(bool _areOff) external onlyOwner {
        _taxesOff = _areOff;
    }

    function setSwapEnabled(bool _enabled) external onlyOwner {
        _swapEnabled = _enabled;
    }

    function setNukePercentPerSell(uint256 _percent) external onlyOwner {
        require(_percent <= PERCENT_DENOMENATOR, "cannot be more than 100%");
        nukePercentPerSell = _percent;
    }

    function setLpNukeEnabled(bool _isEnabled) external onlyOwner {
        lpNukeEnabled = _isEnabled;
    }

    function setBiggestBuyRewardPercentage(uint256 _percent)
        external
        onlyOwner
    {
        require(_percent <= PERCENT_DENOMENATOR, "cannot be more than 100%");
        biggestBuyRewardPercentage = _percent;
    }

    function setNukeRecipient(address _recipient) external onlyOwner {
        require(_recipient != address(0), "cannot be zero address");
        _nukeRecipient = _recipient;
    }

    function withdrawETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}

    function _isContractAddress(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    /**
     * @notice Create Random Number
     */
    function _requestRandomNumber(uint256 _number)
        private
        view
        returns (uint256)
    {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.number,
                        block.difficulty,
                        block.timestamp,
                        block.gaslimit,
                        _number,
                        _timestamp
                    )
                )
            );
    }
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
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

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}