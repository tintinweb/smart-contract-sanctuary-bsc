/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

//SPDX-License-Identifier:MIT

pragma solidity ^0.8.13;

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// LIBRARIES
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// SAFEMATH its a Openzeppelin Lib. Check out for more info @ https://docs.openzeppelin.com/contracts/2.x/api/math
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INTERFACES
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INFMCONTROLLER
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmController {
    function _checkWLSC(address Controller, address Client)
        external
        pure
        returns (bool);

    function _getNFM() external pure returns (address);

    function _getTimer() external pure returns (address);

    function _getExchange() external pure returns (address);

    function _getLiquidity() external pure returns (address);

    function _getDistribute() external view returns (address);

    function _getTreasury() external view returns (address);

    function _getDaoReserveERC20() external view returns (address);

    function _getBonusBuyBack()
        external
        view
        returns (address Bonus, address Buyback);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// IERC20
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint256);

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
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INFMTIMER
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmTimer {
    function _getUV2_RemoveLiquidityTime() external view returns (uint256);

    function _updateUV2_RemoveLiquidity_event() external returns (bool);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INFMLIQUIDITY
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmLiquidity {
    function _returntotalLiquidity(address Coin)
        external
        view
        returns (uint256, uint256);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INFMORACLE
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmOracle {
    function _getLatestPrice(address coin) external view returns (uint256);

    function _addtoOracle(address Coin, uint256 Price) external returns (bool);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// IUNISWAPV2ROUTER01
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// IUNISWAPV2ROUTER02
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// IUNISWAPV2PAIR
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// IUNISWAPV2FACTORY
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/// @title NFMUniswap.sol
/// @author Fernando Viktor Seidl E-mail: [email protected]
/// @notice This contract is responsible for the Uniswap Protocol and supports the NFMSwap and NFMLiquidity Protocol.
///                All currencies for the NFMSwap and NFMLiquidity Protocol are sourced from this contract..
/// @dev This extension includes all necessary functionalities for redeeming the Liquidity Token after 11 years.
///
///         INFO:
///         -   After 11 years, all existing liquidity tokens are redeemed in a 29-day cycle and the profits are divided accordingly.
///
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
contract NFMUniswap {
    //include SafeMath
    using SafeMath for uint256;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    CONTROLLER
    OWNER = MSG.SENDER ownership will be handed over to dao
    */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    INfmController private _Controller;
    address private _Owner;
    address private _SController;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    address[] _CoinsArray       => Contains the all allowed currencies
    uint256 Index                 => Contains the upcoming index 
    uint256 Schalter            => Contains the step switcher for removing Liquidity  
    */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    address[] public _CoinsArray;
    uint256 public Index = 0;
    uint256 private Schalter = 0;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    uint256 _RemoveLPCounter    => Counts added Structs 
    uint256 nextRedeemption     => Contains the upcoming LP-Token Amount to be removed
    */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    uint256 public _RemoveLPCounter = 0;
    uint256 private nextRedeemption;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    address _uniswapV2Router    => Contains the UniswapRouter Interface 
    address _URouter            => Contains the Uniswap Router Address
    address _URouter            => Contains the actual UniswapPair to redeem
    */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    IUniswapV2Router02 public _uniswapV2Router;
    address private _URouter;
    address private _UV2Pair;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    struct LiquidityRemove      => Contains all Information about the removed Liquidity 
    */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    struct LiquidityRemove {
        uint256 AmountA;
        uint256 AmountB;
        uint256 LP;
        address currency;
        uint256 timer;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    MAPPINGS
    RDLP (Coin address, numeric boolean 0 if no 1 if true)     //Contains boolean value
    RDLP10Amount (Coin address, LP Token amount)     //Contains a tenth amount of the total amount
    _RemovedLiquidity (Index, Struct)     //Contains a struct for each realized redemption
    _totalLiquidity (Coin address, total amount liquidity)     //Contains the total Liquidity provided per Coin
    _totalLiquiditySet (Coin address, boolean)     //Contains a Boolean value whether the total liquidity data exists 
    _totalYield (Coin address, Yield amount)     //Contains the total yield per currency
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    mapping(address => uint256) public RDLP;
    mapping(address => uint256) public RDLP10Amount;
    mapping(uint256 => LiquidityRemove) public _RemovedLiquidity;
    mapping(address => uint256) public _totalLiquidity;
    mapping(address => bool) public _totalLiquiditySet;
    mapping(address => uint256) public _totalYield;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    CONTRACT EVENTS
    LPR(address indexed LPAddress, address indexed Coin, uint256 AmountCoin, uint256 AmountNFM, uint256 AmountLP);
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    event LPR(
        address indexed LPAddress,
        address indexed Coin,
        uint256 AmountCoin,
        uint256 AmountNFM,
        uint256 AmountLP
    );
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    MODIFIER
    onlyOwner       => Only Controller listed Contracts and Owner can interact with this contract.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    modifier onlyOwner() {
        require(
            _Controller._checkWLSC(_SController, msg.sender) == true ||
                _Owner == msg.sender,
            "oO"
        );
        require(msg.sender != address(0), "0A");
        _;
    }

    constructor(address Controller, address Router) {
        _Owner = msg.sender;
        INfmController Cont = INfmController(Controller);
        _Controller = Cont;
        _SController = Controller;
        _URouter = Router;
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(Router);
        _uniswapV2Router = uniswapV2Router;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @storeLiquidityRemove( uint256 AmountA, uint256 AmountB, uint256 LP, address currency);
    This function saves all the data of each individual redemption into a struct
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function storeLiquidityRemove(
        uint256 AmountA,
        uint256 AmountB,
        uint256 LP,
        address currency
    ) internal virtual onlyOwner {
        _RemovedLiquidity[_RemoveLPCounter] = LiquidityRemove(
            AmountA,
            AmountB,
            LP,
            currency,
            block.timestamp
        );
        _RemoveLPCounter++;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @getRemoveLPArray() returns (LiquidityRemove[] memory);
    This function returns all information about LP redemptions made.
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function getRemoveLPArray() public view returns (LiquidityRemove[] memory) {
        LiquidityRemove[] memory lLiquidityRemove = new LiquidityRemove[](
            _RemoveLPCounter
        );
        for (uint256 i = 0; i < _RemoveLPCounter; i++) {
            LiquidityRemove storage lLiquidityRem = _RemovedLiquidity[i];
            lLiquidityRemove[i] = lLiquidityRem;
        }
        return lLiquidityRemove;
    }

    function _approveWithdraw(
        address Coin,
        address to,
        uint256 amount
    ) public onlyOwner returns (bool) {
        if (IERC20(address(Coin)).approve(to, amount) == true) {
            return true;
        } else {
            return false;
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @returnCurrencyArray() returns (uint256);
    This function returns Array of all allowed currencies.
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function returnCurrencyArray() public view returns (address[] memory) {
        return _CoinsArray;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @returnCurrencyArrayLenght() returns (uint256);
    This function returns Array lenght.
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function returnCurrencyArrayLenght() public view returns (uint256) {
        return _CoinsArray.length;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @addCoinToList(address Coin) returns (bool);
    This function adds new Coins to the End of the Array.
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function addCoinToList(address Coin) public onlyOwner returns (bool) {
        _CoinsArray.push(Coin);
        RDLP[Coin] = 0;
        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @returnLPBalance(address Coin) returns (uint256);
    This function returns the balance of LP tokens in this pool
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function returnLPBalance(address Coin)
        public
        view
        returns (uint256, address)
    {
        address _UV2Pairs = IUniswapV2Factory(
            IUniswapV2Router02(_uniswapV2Router).factory()
        ).getPair(address(_Controller._getNFM()), Coin);
        return (IERC20(address(_UV2Pairs)).balanceOf(address(this)), _UV2Pairs);
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @inicialiseRedeemLPToken() returns (bool);
    This function initiates the payout of LP tokens. First, the contract account is set to zero. All balances are transferred to Treasury.
    The next step is to check whether a payment has already been made. If not, everything will be prepared for it. Payouts per pool 
    are made in 10 events.
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function inicialiseRedeemLPToken() public onlyOwner returns (bool) {
        if (Index >= returnCurrencyArrayLenght()) {
            Index = 0;
        }
        if (IERC20(address(_CoinsArray[Index])).balanceOf(address(this)) > 0) {
            IERC20(address(_CoinsArray[Index])).transfer(
                _Controller._getTreasury(),
                IERC20(address(_CoinsArray[Index])).balanceOf(address(this))
            );
        }
        if (
            IERC20(address(_Controller._getNFM())).balanceOf(address(this)) > 0
        ) {
            IERC20(address(_Controller._getNFM())).transfer(
                _Controller._getTreasury(),
                IERC20(address(_CoinsArray[Index])).balanceOf(address(this))
            );
        }
        (, _UV2Pair) = returnLPBalance(_CoinsArray[Index]);

        if (RDLP[_CoinsArray[Index]] == 0) {
            uint256 fullLP = IERC20(address(_UV2Pair)).balanceOf(address(this));
            if (fullLP > 0) {
                RDLP10Amount[_CoinsArray[Index]] = SafeMath.div(fullLP, 10);
                RDLP[_CoinsArray[Index]] = 1;
                nextRedeemption = SafeMath.sub(
                    fullLP,
                    SafeMath.mul(RDLP10Amount[_CoinsArray[Index]], 9)
                );
                return true;
            } else {
                RDLP[_CoinsArray[Index]] = 1;
                nextRedeemption = 0;
                return false;
            }
        } else {
            uint256 fullLP = IERC20(address(_UV2Pair)).balanceOf(address(this));
            if (fullLP > 0 && RDLP10Amount[_CoinsArray[Index]] > 0) {
                nextRedeemption = RDLP10Amount[_CoinsArray[Index]];
                return true;
            } else {
                nextRedeemption = 0;
                return false;
            }
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @removeLiquidity() returns (bool);
    This function initiates the withdrawal from the Uniswap pool against LP tokens.
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function removeLiquidity() public virtual onlyOwner returns (bool) {
        uint256 LPAmount = nextRedeemption;
        if (LPAmount > 0) {
            if (
                INfmTimer(address(_Controller._getTimer()))
                    ._getUV2_RemoveLiquidityTime() <= block.timestamp
            ) {
                uint256 fullLP = IERC20(address(_UV2Pair)).balanceOf(
                    address(this)
                );
                if (fullLP > 0 && fullLP >= LPAmount) {
                    IERC20(address(_UV2Pair)).approve(
                        address(_uniswapV2Router),
                        LPAmount
                    );
                    // remove the liquidity
                    (uint256 amountA, uint256 amountB) = _uniswapV2Router
                        .removeLiquidity(
                            address(_Controller._getNFM()),
                            address(_CoinsArray[Index]),
                            LPAmount,
                            0, // slippage is unavoidable
                            0, // slippage is unavoidable
                            address(this),
                            block.timestamp + 1
                        );
                    storeLiquidityRemove(
                        amountA,
                        amountB,
                        LPAmount,
                        address(_CoinsArray[Index])
                    );
                    emit LPR(
                        _UV2Pair,
                        _CoinsArray[Index],
                        amountB,
                        amountA,
                        LPAmount
                    );
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @calculatingreturns() returns (bool);
    This function retrieves the total liquidity that is in the pool. Then the profit can be calculated. The resulting profit 
    is shared. The liquidity fed in that does not count towards profit is allocated to treasury, governance and developers. 
    With the following split: 50/40/10
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function calculatingreturns() public onlyOwner returns (bool) {
        uint256 LiquidityTotalPool;
        uint256 Ovalue;
        if (_totalLiquiditySet[_CoinsArray[Index]] != true) {
            if (_totalLiquiditySet[_Controller._getNFM()] != true) {
                (LiquidityTotalPool, Ovalue) = INfmLiquidity(
                    address(_Controller._getLiquidity())
                )._returntotalLiquidity(_Controller._getNFM());
                _totalLiquiditySet[_Controller._getNFM()] = true;
                _totalLiquidity[_Controller._getNFM()] = LiquidityTotalPool;
            }
            (LiquidityTotalPool, Ovalue) = INfmLiquidity(
                address(_Controller._getLiquidity())
            )._returntotalLiquidity(_CoinsArray[Index]);
            _totalLiquiditySet[_CoinsArray[Index]] = true;
            _totalLiquidity[_CoinsArray[Index]] = LiquidityTotalPool;
        }
        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @splittingCoinreturns() returns (bool);
    This function checks whether the payouts count towards yield or liquidity. Liquidity is paid out to Treasury, Governance 
    and Devs. On the other hand, 20% of the yield is paid out to the NFM community.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function splittingCoinreturns(address Coin)
        public
        onlyOwner
        returns (bool)
    {
        if (_totalLiquiditySet[Coin] == true) {
            uint256 fullCoin = IERC20(address(Coin)).balanceOf(address(this));
            if (_totalLiquidity[Coin] == 0) {
                //just yield
                if (doYields(Coin, fullCoin) == true) {
                    _totalYield[Coin] += fullCoin;
                    return true;
                } else {
                    return false;
                }
            } else {
                //Liquidity and/or Yield
                if (fullCoin <= _totalLiquidity[Coin]) {
                    //Only Liquidity
                    if (doLiquidity(Coin, fullCoin) == true) {
                        _totalLiquidity[Coin] -= fullCoin;
                        return true;
                    } else {
                        return false;
                    }
                } else {
                    //Liquidity and Yield
                    uint256 yields = SafeMath.sub(
                        fullCoin,
                        _totalLiquidity[Coin]
                    );
                    if (
                        doYields(Coin, yields) == true &&
                        doLiquidity(Coin, SafeMath.sub(fullCoin, yields)) ==
                        true
                    ) {
                        _totalLiquidity[Coin] -= SafeMath.sub(fullCoin, yields);
                        _totalYield[Coin] += yields;
                        return true;
                    } else {
                        return false;
                    }
                }
            }
        } else {
            return false;
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @doLiquidity(address Coin, uint256 FullValue) returns (bool);
    This function handles the distribution of liquidity
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function doLiquidity(address Coin, uint256 FullValue)
        public
        onlyOwner
        returns (bool)
    {
        ///        - Governance will receive 40% of all Liquidity
        ///        - NFM Treasury will receive 50% of all Liquidity
        ///        - Developers will receive 10% of all Liquidity
        if (_totalLiquiditySet[Coin] == true) {
            uint256 marker10 = SafeMath.div(FullValue, 10);
            uint256 full = SafeMath.mul(marker10, 9);
            IERC20(address(Coin)).transfer(
                _Controller._getDaoReserveERC20(),
                SafeMath.mul(marker10, 4)
            );
            IERC20(address(Coin)).transfer(
                _Controller._getTreasury(),
                SafeMath.mul(marker10, 5)
            );
            IERC20(address(Coin)).transfer(
                _Controller._getDistribute(),
                SafeMath.sub(FullValue, full)
            );

            return true;
        } else {
            return false;
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @doYields(address Coin, uint256 FullValue) returns (bool);
    This function handles the distribution of the yields
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function doYields(address Coin, uint256 FullValue)
        public
        onlyOwner
        returns (bool)
    {
        ///                     - NFM Community will receive 20% of all LP-Yields (Yields will be distributed via the Bonus Event in the NFM Protocol.)
        ///                     - Governance will receive 30% of all LP-Yields (The proceeds are set aside for the BuyBack program and are intended
        ///                       to generate additional income for greater purchasing power.)
        ///                     - NFM Treasury will receive 40% of all LP-Yields (The proceeds are set aside for the bonus program and are intended to
        ///                       generate additional income for larger bonus payments.)
        ///                     - Developers will receive 10% of all LP-Yields (Is paid out as commission payments)
        if (_totalLiquiditySet[Coin] == true) {
            uint256 marker10 = SafeMath.div(FullValue, 10);
            uint256 full = SafeMath.mul(marker10, 9);
            (address Bonus, ) = _Controller._getBonusBuyBack();
            IERC20(address(Coin)).transfer(Bonus, SafeMath.mul(marker10, 2));
            IERC20(address(Coin)).transfer(
                _Controller._getDaoReserveERC20(),
                SafeMath.mul(marker10, 3)
            );
            IERC20(address(Coin)).transfer(
                _Controller._getTreasury(),
                SafeMath.mul(marker10, 4)
            );
            IERC20(address(Coin)).transfer(
                _Controller._getDistribute(),
                SafeMath.sub(FullValue, full)
            );

            return true;
        } else {
            return false;
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @redeemLPToken() returns (bool);
    This function is responsible for processing the protocol accordingly
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function redeemLPToken() public onlyOwner returns (bool) {
        if (Schalter == 0) {
            if (inicialiseRedeemLPToken() == true) {
                Schalter = 1;
                return true;
            } else {
                updateNext();
                return true;
            }
        } else if (Schalter == 1) {
            if (removeLiquidity() == true) {
                Schalter = 2;
                return true;
            } else {
                updateNext();
                return true;
            }
        } else if (Schalter == 2) {
            ///Spliting the returns
            if (calculatingreturns() == true) {
                Schalter = 3;
                return true;
            } else {
                updateNext();
                return true;
            }
        } else if (Schalter == 3) {
            ///Spliting the returns
            if (splittingCoinreturns(_CoinsArray[Index]) == true) {
                Schalter = 4;
                return true;
            } else {
                updateNext();
                return true;
            }
        } else if (Schalter == 4) {
            ///Spliting the returns
            if (splittingCoinreturns(_Controller._getNFM()) == true) {
                Schalter = 5;
                return true;
            } else {
                updateNext();
                return true;
            }
        } else if (Schalter == 5) {
            updateNext();
            return true;
        } else {
            return false;
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @updateSchalter() returns (bool);
    This function updates the switcher. This is used to separate logic that has to be executed once for the event from 
    the rest of the logic
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function updateSchalter() public onlyOwner returns (bool) {
        Schalter = 0;
        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @updateNext() returns (bool);
    This function updates the timer and the Index once Swap Event arrives final Step. Or if Swap can´t be executed.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function updateNext() public onlyOwner returns (bool) {
        if (
            INfmTimer(address(_Controller._getTimer()))
                ._updateUV2_RemoveLiquidity_event() == true
        ) {
            updateSchalter();
            Index++;
            return true;
        } else {
            return false;
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_getWithdraw(address Coin,address To,uint256 amount,bool percent) returns (bool);
    This function is used by NFMLiquidity and NFM Swap to execute transactions.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _getWithdraw(
        address Coin,
        address To,
        uint256 amount,
        bool percent
    ) public onlyOwner returns (bool) {
        require(To != address(0), "0A");
        uint256 CoinAmount = IERC20(address(Coin)).balanceOf(address(this));
        if (percent == true) {
            //makeCalcs on Percentatge
            uint256 AmountToSend = SafeMath.div(
                SafeMath.mul(CoinAmount, amount),
                100
            );
            IERC20(address(Coin)).transfer(To, AmountToSend);
            return true;
        } else {
            if (amount == 0) {
                IERC20(address(Coin)).transfer(To, CoinAmount);
            } else {
                IERC20(address(Coin)).transfer(To, amount);
            }
            return true;
        }
    }
}