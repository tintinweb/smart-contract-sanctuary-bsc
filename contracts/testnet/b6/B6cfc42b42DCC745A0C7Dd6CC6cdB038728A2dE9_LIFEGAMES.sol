// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{
            value: weiValue
        }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
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

import "./LIFEGAMES_GAME_MANAGER.sol";
import "./IERC20.sol";

// INIT
contract LIFEGAMES is Context, IERC20, Ownable {
    LIFEGAMES_GAME_MANAGER public lifeGamesGameManager;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    mapping(address => bool) public _isBlacklisted;

    address bridgeAdmin;

    // --- code of token
    using SafeMath for uint256;
    using Address for address;

    address payable public liquidityAddress;
    // si la cartera de buybackandburn y la de liquidez son la misma eliminamos esta declaración y su update (línea 1147)
    address payable public buybackAndBurnAddress;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Anti-bot and anti-whale mappings and variables
    mapping(address => uint256) private _holderLastTransferTimestamp; // to hold last Transfers temporarily during launch
    bool public transferDelayEnabled = true;
    bool public limitsInEffect = true;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private  _tTotal = 1 * 1e6 * 1e18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "LIFEGAMES";
    string private constant _symbol = "LFG";
    uint8 private constant _decimals = 18;

    // these values are pretty much arbitrary since they get overwritten for every txn, but the placeholders make it easier to work with current contract.
    uint256 private _distributionHoldersFee;
    uint256 private _previousDistributionHoldersFee = _distributionHoldersFee;

    uint256 private _liquidityFee;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 private constant BUY = 1;
    uint256 private constant SELL = 2;
    uint256 private constant TRANSFER = 3;
    uint256 private buyOrSellSwitch;

    uint256 public _buyDistributionHoldersFee = 15;
    uint256 public _buyLiquidityFee = 5;
    uint256 public _buyBuybackAndBurnFee = 10;

    uint256 public _sellDistributionHoldersFee = 15;
    uint256 public _sellLiquidityFee = 5;
    uint256 public _sellBuybackAndBurnFee = 10;

    uint256 private BASE_FEE_PERCENT = 1000;

    uint256 public tradingActiveBlock = 0; // 0 means trading is not active

    uint256 public _liquidityTokensToSwap;
    uint256 public _buybackAndBurnToSwap;

    uint256 accumulatedLiquidityTokensAmount = 0;
    uint256 public swapLiquidityTokensThreshold = 0;

    mapping(address => bool) public _isExcludedMaxTransactionAmount;
    uint256 public intervalDelayInterval;

    bool private gasLimitActive = true;
    uint256 private gasPriceLimit = 40000000000; // do not allow over x gwei for launch

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 private minimumTokensBeforeSwap;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    address public busdAddress;

    bool inSwapAndLiquify;
    bool public autoAddLiquidity = false;
    bool public tradingActive = false;

    event AutoAddLiquidityUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 avaxReceived,
        uint256 tokensIntoLiquidity
    );

    //event SwapEthForTokens(uint256 amountIn, address[] path);
    event SwapExactTokensForTokens(uint256 amountIn, address[] path);
    event SetAutomatedMarketMakerPair(address pair, bool value);
    event ExcludeFromReward(address excludedAddress);
    event IncludeInReward(address includedAddress);
    event ExcludeFromFee(address excludedAddress);
    event IncludeInFee(address includedAddress);
    event SetBuyFee(
        uint256 marketingFee,
        uint256 liquidityFee,
        uint256 reflectFee
    );
    event SetSellFee(
        uint256 marketingFee,
        uint256 liquidityFee,
        uint256 reflectFee
    );
    event UpdatedMarketingAddress(address marketing);
    event UpdatedLiquidityAddress(address liquidity);
    event UpdatedBuybackAndBurnAddress(address dev);
    event OwnerForcedSwapBack(uint256 timestamp);
    event UpdateUniswapV2Router(address newAddress);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() payable {
        // Test
        _rOwned[_msgSender()] = (_rTotal / 100) * 100; // 100%
        _rOwned[address(this)] = 0;

        minimumTokensBeforeSwap = (_tTotal * 25) / 100000;
        // 0.025% swap tokens amount

        liquidityAddress = payable(owner());
        // Liquidity Address (switches to dead address once launch happens)

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[liquidityAddress] = true;
        _isExcludedFromFee[buybackAndBurnAddress] = true;

        excludeFromMaxTransaction(owner(), true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(0xdead), true);
        excludeFromMaxTransaction(buybackAndBurnAddress, true);
        excludeFromMaxTransaction(liquidityAddress, true);

        emit Transfer(address(0), _msgSender(), (_tTotal * 100) / 100);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(!_isBlacklisted[from], "NODE CREATION: Blacklisted address");

        if (!tradingActive) {
            require(
                _isExcludedFromFee[from] || _isExcludedFromFee[to],
                "Trading is not active yet."
            );
        }

        if (limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !inSwapAndLiquify
            ) {
                // only use to prevent sniper buys in the first blocks.
                if (gasLimitActive && automatedMarketMakerPairs[from]) {
                    require(
                        tx.gasprice <= gasPriceLimit,
                        "Gas price exceeds limit."
                    );
                }

                // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.
                if (transferDelayEnabled) {
                    if (
                        to != owner() &&
                        to != address(uniswapV2Router) &&
                        to != address(uniswapV2Pair)
                    ) {
                        require(
                            _holderLastTransferTimestamp[tx.origin] <
                                block.number * intervalDelayInterval,
                            "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                        );
                        _holderLastTransferTimestamp[tx.origin] = block.number;
                    }
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >=
            minimumTokensBeforeSwap;

        // swap and liquify (buy back)
        if (
            !inSwapAndLiquify &&
            autoAddLiquidity &&
            balanceOf(uniswapV2Pair) > 0 &&
            !_isExcludedFromFee[to] &&
            !_isExcludedFromFee[from] &&
            automatedMarketMakerPairs[to] &&
            overMinimumTokenBalance
        ) {
            doBuyBack();
        }

        removeAllFee();

        buyOrSellSwitch = TRANSFER;

        // if not excluded
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            // anti whale

            // Buy
            if (automatedMarketMakerPairs[from]) {
                _distributionHoldersFee = _buyDistributionHoldersFee;
                _liquidityFee = _buyLiquidityFee + _buyBuybackAndBurnFee;
                if (_liquidityFee > 0) {
                    buyOrSellSwitch = BUY;
                }
            }
            // Sell
            else if (automatedMarketMakerPairs[to]) {
                _distributionHoldersFee = _sellDistributionHoldersFee;
                _liquidityFee = _sellLiquidityFee + _sellBuybackAndBurnFee;
                if (_liquidityFee > 0) {
                    buyOrSellSwitch = SELL;
                }
            }
        }

        _tokenTransfer(from, to, amount);

        restoreAllFee();
    }

    function doBuyBack() private lockTheSwap {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = _liquidityTokensToSwap +
            _buybackAndBurnToSwap;

        // prevent overly large contract sells.
        if (contractBalance >= minimumTokensBeforeSwap * 10) {
            contractBalance = minimumTokensBeforeSwap * 10;
        }

        // check if we have tokens to swap
        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        // Halve the amount of liquidity tokens
        uint256 tokensForLiquidity = (contractBalance *
            _liquidityTokensToSwap) /
            totalTokensToSwap /
            2;
        uint256 amountToSwapForBUSD = contractBalance.sub(tokensForLiquidity);

        uint256 initialBUSDBalance = balanceOf(address(busdAddress));
        swapExactTokensForTokens(amountToSwapForBUSD);         // El token con el que se respalda liquidez
        uint256 busdBalance = balanceOf(address(busdAddress)).sub(initialBUSDBalance);

        uint256 busdForBuybackAndBurnPool = busdBalance
            .mul(_buybackAndBurnToSwap)
            .div(totalTokensToSwap);
        uint256 busdForLiquidity = busdBalance - busdForBuybackAndBurnPool;

        _liquidityTokensToSwap = 0;
        _buybackAndBurnToSwap = 0;


        require(IERC20(address(buybackAndBurnAddress)).transferFrom(address(this), buybackAndBurnAddress,busdForBuybackAndBurnPool));

        if (tokensForLiquidity > 0 && busdForLiquidity > 0) {

            uint256 initialLiquidityBUSDBalance = balanceOf(address(busdAddress));
            swapExactTokensForTokens(initialLiquidityBUSDBalance);
            uint256 afterSwapBalance = balanceOf(address(busdAddress)).sub(initialBUSDBalance);
            
            require(IERC20(address(liquidityAddress)).transferFrom(address(this), buybackAndBurnAddress,afterSwapBalance));
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[sender] = _tOwned[sender].sub(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[sender] = _tOwned[sender].sub(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidity
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateDistributionHoldersFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        if (buyOrSellSwitch == BUY) {
            _liquidityTokensToSwap +=
                (tLiquidity * _buyLiquidityFee) /
                _liquidityFee;
            _buybackAndBurnToSwap +=
                (tLiquidity * _buyBuybackAndBurnFee) /
                _liquidityFee;
        } else if (buyOrSellSwitch == SELL) {
            _liquidityTokensToSwap +=
                (tLiquidity * _sellLiquidityFee) /
                _liquidityFee;
            _buybackAndBurnToSwap +=
                (tLiquidity * _sellBuybackAndBurnFee) /
                _liquidityFee;
        }

        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);

        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
        }
    }

    function calculateDistributionHoldersFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_distributionHoldersFee).div(BASE_FEE_PERCENT);
    }

    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_liquidityFee).div(BASE_FEE_PERCENT);
    }

    function removeAllFee() private {
        if (_distributionHoldersFee == 0 && _liquidityFee == 0) return;

        _previousDistributionHoldersFee = _distributionHoldersFee;
        _previousLiquidityFee = _liquidityFee;

        _distributionHoldersFee = 0;
        _liquidityFee = 0;
    }

    function restoreAllFee() private {
        _distributionHoldersFee = _previousDistributionHoldersFee;
        _liquidityFee = _previousLiquidityFee;
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludeFromFee(account);
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludeInFee(account);
    }

    function setBuyFee(
        uint256 buyDistributionHoldersFee,
        uint256 buyLiquidityFee,
        uint256 buyBuybackAndBurnFee
    ) external onlyOwner {
        require(
            _buyDistributionHoldersFee +
                _buyLiquidityFee +
                _buyBuybackAndBurnFee <=
                30,
            "Must keep buy taxes below 3%"
        );

        _buyDistributionHoldersFee = buyDistributionHoldersFee;
        _buyLiquidityFee = buyLiquidityFee;
        _buyBuybackAndBurnFee = buyBuybackAndBurnFee;

        emit SetBuyFee(
            buyDistributionHoldersFee,
            buyLiquidityFee,
            buyBuybackAndBurnFee
        );
    }

    function setSellFee(
        uint256 sellDistributionHoldersFee,
        uint256 sellLiquidityFee,
        uint256 sellBuybackAndBurnFee
    ) external onlyOwner {
        require(
            _sellDistributionHoldersFee +
                _sellLiquidityFee +
                _sellBuybackAndBurnFee <=
                30,
            "Must keep buy taxes below 3%"
        );

        _sellDistributionHoldersFee = sellDistributionHoldersFee;
        _sellLiquidityFee = sellLiquidityFee;
        _sellBuybackAndBurnFee = sellBuybackAndBurnFee;

        emit SetSellFee(
            sellBuybackAndBurnFee,
            sellLiquidityFee,
            sellDistributionHoldersFee
        );
    }

    function setLiquidityAddress(address _liquidityAddress) public onlyOwner {
        require(
            _liquidityAddress != address(0),
            "_liquidityAddress address cannot be 0"
        );
        liquidityAddress = payable(_liquidityAddress);
        _isExcludedFromFee[liquidityAddress] = true;
        excludeFromMaxTransaction(liquidityAddress, true);
        emit UpdatedLiquidityAddress(_liquidityAddress);
    }

    function setBuybackAndBurnAddress(address _buybackAndBurnAddress)
        public
        onlyOwner
    {
        require(
            _buybackAndBurnAddress != address(0),
            "_buybackAndBurnAddress address cannot be 0"
        );
        buybackAndBurnAddress = payable(_buybackAndBurnAddress);
        _isExcludedFromFee[buybackAndBurnAddress] = true;
        excludeFromMaxTransaction(buybackAndBurnAddress, true);
        emit UpdatedBuybackAndBurnAddress(_buybackAndBurnAddress);
    }

    function setAutoAddLiquidity(bool _enabled) public onlyOwner {
        autoAddLiquidity = _enabled;
        emit AutoAddLiquidityUpdated(_enabled);
    }

    // To receive BUSD from uniswapV2Router when swapping
    receive() external payable {}

    function setGameManagement(address newAddress) external onlyOwner {
        require(newAddress != address(0), "GAME MANAGER CANNOT BE ZERO");
        lifeGamesGameManager = LIFEGAMES_GAME_MANAGER(newAddress);
    }

    function updateTransferDelayEnabled(bool newVal) external onlyOwner {
        transferDelayEnabled = newVal;
    }

    function setIsExcluded(address account, bool value) external onlyOwner {
        _isExcluded[account] = value;
    }

    function updateSwapLiquidityTokensThreshold(uint256 value)
        external
        onlyOwner
    {
        swapLiquidityTokensThreshold = value;
    }

    function swapAndSendToAddress(address destination, uint256 tokens)
        private
        returns (bool)
    {
        uint256 initialBUSDBalance = balanceOf(address(busdAddress));
        swapExactTokensForTokens(tokens);
        uint256 newBalance = balanceOf(address(busdAddress)).sub(initialBUSDBalance);
        payable(destination).transfer(newBalance);
        return true;
    }

    function swapExactTokensForTokens(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(busdAddress);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            tokenAmount,
            path,
            address(this),
            block.timestamp
        );
        emit SwapExactTokensForTokens(tokenAmount, path);
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(0), "ROUTER CANNOT BE ZERO");
        require(
            newAddress != address(uniswapV2Router),
            "TKN: The router already has that address"
        );
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), address(busdAddress));
        uniswapV2Pair = _uniswapV2Pair;

        _approve(
            address(this),
            address(uniswapV2Router),
            balanceOf(address(this))
        );

        _approve(
            address(this),
            address(uniswapV2Pair),
            balanceOf(address(this))
        );

        _isExcluded[address(this)] = true;
        excludeFromMaxTransaction(address(uniswapV2Pair), true);
        excludeFromMaxTransaction(address(uniswapV2Router), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        emit UpdateUniswapV2Router(address(uniswapV2Router));
    }

    function manualSwap(uint256 amount) public onlyOwner {
        require(balanceOf(address(this)) > 0, "Contract balance is zero");
        if (amount > balanceOf(address(this))) {
            amount = balanceOf(address(this));
        }
        swapExactTokensForTokens(amount);
    }

    function updateBUSDAddress(address newAddress) external onlyOwner {
        require(newAddress != address(0), "ROUTER CANNOT BE ZERO");
        require(
            newAddress != address(busdAddress),
            "TKN: The BUSD already has that address"
        );
        busdAddress = address(newAddress);
    }

    function withdrawStuckBUSD(uint256 amount) external onlyOwner {
        require(balanceOf(busdAddress) > 0, "Contract balance is zero");
        if (amount > balanceOf(busdAddress)) {
            amount = balanceOf(busdAddress);
        }

        IERC20(busdAddress).transferFrom(address(this), msg.sender, amount);
    }

    function withdrawStuckTokens(uint256 amount) public onlyOwner {
        require(balanceOf(address(this)) > 0, "Contract balance is zero");
        if (amount > balanceOf(address(this))) {
            amount = balanceOf(address(this));
        }

        _tokenTransfer(address(this), msg.sender, amount);
    }

    // get info
    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
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
        public
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
    ) external override returns (bool) {
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
        external
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
        external
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

    function isExcludedFromReward(address account)
        external
        view
        returns (bool)
    {
        return _isExcluded[account];
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    // update limits after token is stable - 30-60 minutes
    function updateLimits(bool newValue) external onlyOwner returns (bool) {
        limitsInEffect = newValue;
        gasLimitActive = newValue;
        transferDelayEnabled = newValue;
        return true;
    }

    // disable Transfer delay
    function disableTransferDelay() external onlyOwner returns (bool) {
        transferDelayEnabled = false;
        return true;
    }

    function excludeFromMaxTransaction(address updAds, bool isEx)
        public
        onlyOwner
    {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    // send tokens and BUSD for liquidity to contract directly, then call this (not required, can still use Uniswap to add liquidity manually, but this ensures everything is excluded properly and makes for a great stealth launch)
    function launch(address routerAddress, address busd) external onlyOwner {
        require(!tradingActive, "Trading is already active, cannot relaunch.");

        removeAllFee();
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
        excludeFromMaxTransaction(address(_uniswapV2Router), true);
        uniswapV2Router = _uniswapV2Router;
        busdAddress = address(busd);
        _approve(
            address(this),
            address(uniswapV2Router),
            balanceOf(address(this))
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), address(busdAddress));
        excludeFromMaxTransaction(address(uniswapV2Pair), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);
        restoreAllFee();

        tradingActive = true;
    }

    function minimumTokensBeforeSwapAmount() external view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    // change the minimum amount of tokens to sell from fees
    function updateMinimumTokensBeforeSwap(uint256 newAmount)
        external
        onlyOwner
    {
        require(
            newAmount >= (_tTotal * 1) / 100000,
            "Swap amount cannot be lower than 0.001% total supply."
        );
        require(
            newAmount <= (_tTotal * 5) / 1000,
            "Swap amount cannot be higher than 0.5% total supply."
        );
        minimumTokensBeforeSwap = newAmount;
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            pair != uniswapV2Pair,
            "The pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        _isExcludedMaxTransactionAmount[pair] = value;
        if (value) {
            excludeFromReward(pair);
        }
        if (!value) {
            includeInReward(pair);
        }
    }

    function setTradingActive() external onlyOwner {
        require(tradingActive != true);
        tradingActive = true;
    }

    function setGasPriceLimit(uint256 gas) external onlyOwner {
        require(gas >= 2700000000);
        gasPriceLimit = gas;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        external
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        require(
            _excluded.length + 1 <= 50,
            "Cannot exclude more than 50 accounts.  Include a previously excluded address."
        );
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) public onlyOwner {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // force Swap back if slippage above 49% for launch.
    function forceBuyBack() external onlyOwner {
        uint256 contractBalance = balanceOf(address(this));
        require(
            contractBalance >= _tTotal / 10000,
            "Can only swap back if more than .01% of tokens stuck on contract"
        );
        doBuyBack();
        emit OwnerForcedSwapBack(block.timestamp);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to
    ) private {
        _approve(address(this), address(uniswapV2Router), amountADesired);
        _approve(address(this), address(uniswapV2Router), amountBDesired);
        uniswapV2Router.addLiquidity(
            tokenA,
            tokenB,
            amountADesired, // slippage is unavoidable
            amountBDesired, // slippage is unavoidable
            amountAMin,
            amountBMin,
            to,
            block.timestamp
        );
    }

    function burn(address to, uint256 amount) public {
        require(amount >= 0, "Burn amount should be greater than zero");

        if (_msgSender() != to) {
            uint256 currentAllowance = _allowances[to][_msgSender()];
            if (currentAllowance != type(uint256).max) {
                require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            }
        }
       
        require(
            amount <= balanceOf(to),
            "Burn amount should be less than account balance"
        );
        removeAllFee();
        // creo que tenemos un problema al enviar, en algún momento no está registrando la cantidad enviada en tOwned y está quemando el rOwned
        //_rOwned[to] = _rOwned[to].sub(amount);
        _tOwned[to] = _tOwned[to].sub(amount);
        _tTotal = _tTotal.sub(amount);
        restoreAllFee();
        emit Transfer(to, address(0), amount);
    }

    function burn1(address to, uint256 amount) public {
        require(amount >= 0, "Burn amount should be greater than zero");

        if (_msgSender() != to) {
            uint256 currentAllowance = _allowances[_msgSender()][to];
            if (currentAllowance != type(uint256).max) {
                require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            }
        }
         
        require(
            amount <= balanceOf(to),
            "Burn amount should be less than account balance"
        );

        //_rOwned[to] = _rOwned[to].sub(amount);
        _tOwned[to] = _tOwned[to].sub(amount);
        _tTotal = _tTotal.sub(amount);

        emit Transfer(to, address(0), amount);
    }

    function updateAdmin(address newAdmin) external {
        require(msg.sender == bridgeAdmin, "only bridge admin");
        bridgeAdmin = newAdmin;
     }

     function mint(address to, uint256 amount) external {
        require(msg.sender == bridgeAdmin, "only bridge admin");
        _rOwned[to] = _rOwned[to].add(amount);
        _tTotal = _tTotal.add(amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "./SafeMath.sol";
import "./IterableMapping.sol";

contract LIFEGAMES_GAME_MANAGER {
    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;

    modifier onlyManager() {
        require(_managers[msg.sender] == true, "Only managers can call this function");
        _;
    }

    struct Player {
        address playerId;
        uint256 rewardAvailable;
        uint256 rewardNotClaimed;
    }

    IterableMapping.Map private playersOwners;
    mapping(address => Player[]) private _playerssOfUser;
    mapping(address => bool) public _managers;

    uint256 public playersPrice = 0; // 10
    uint256 public rewardsPerMinute = 0; // 1
    uint256 public claimInterval = 0; // 5 min

    bool public cashoutEnabled = false;


    constructor(
    ) {
        _managers[msg.sender] = true;
    }

    function updateManagers(address manager, bool newVal) external onlyManager {
        require(manager != address(0),"new manager is the zero address");
        _managers[manager] = newVal;
    }

    function _getPlayerNumberOf(address account) public view returns (uint256) {
        return playersOwners.get(account);
    }

    function uint2str(uint256 _i)
    internal
    pure
    returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is TKNaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouTKNd) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouTKNd) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key)
    public
    view
    returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
    public
    view
    returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 val
    ) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}