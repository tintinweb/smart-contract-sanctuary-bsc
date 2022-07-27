/**
 *Submitted for verification at BscScan.com on 2022-07-26
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

    function _getUV2Pool() external pure returns (address);

    function _getExchange() external pure returns (address);

    function _getTreasury() external pure returns (address);

    function _getBonusBuyBack() external pure returns (address, address);
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
    function _updateUV2_Swap_event() external returns (bool);

    function _getStartTime() external view returns (uint256);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INFMEXCHANGE
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmExchange {
    function calcNFMAmount(
        address Coin,
        uint256 amount,
        uint256 offchainOracle
    )
        external
        view
        returns (
            bool check,
            uint256 NFMsAmount,
            uint256 MedianPrice,
            bool MaxPrice,
            bool MinPrice
        );
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INFMUV2POOL
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmUV2Pool {
    function returnCurrencyArrayLenght() external returns (uint256);

    function returnCurrencyArray() external returns (address[] memory);

    function _getWithdraw(
        address Coin,
        address To,
        uint256 amount,
        bool percent
    ) external returns (bool);
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INFMORACLE
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmOracle {
    function _getLatestPrice(address coin) external view returns (uint256);
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
/// @title NFMSwap.sol
/// @author Fernando Viktor Seidl E-mail: [email protected]
/// @notice This contract is responsible for the liquidations. NFM is exchanged for other coins to obtain
///                liquidity for further LP tokens.
/// @dev This extension regulates UniswapV2 swap events every 9 days.
///
///         INFO:
///         -   Every 9 days, NFM are exchanged for other currencies. This resulting liquidity is split between the bonus
///             and the Uv2Pool in a 10/90 ratio
///
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
contract NFMSwap {
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
    uint256 _CoinArrLength        => Counts index length 
    address[] _CoinsArray           => Contains the all allowed currencies
    uint256 _SwapCounter          => Contains the upcoming index 
    uint256 _SwapingCounter     => Contains all fulfilled swaps 
    struct Exchanges                   => contains all important information about the swap 
    */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    uint256 public _CoinArrLength;
    address[] public _CoinsArray;
    uint256 public Index = 0;
    uint256 private _MinNFM = 1000 * 10**18;
    uint256 private _MaxNFM = 100000 * 10**18;
    uint256 private _SwapingCounter = 0;
    uint256 public _NFMPricing;
    uint256 public NextNFMSwapAmount;
    uint256 public Schalter = 0;
    IUniswapV2Router02 public _uniswapV2Router;
    address private _URouter;
    address private _OracleAdr;
    struct Exchanges {
        uint256 AmountA;
        uint256 AmountB;
        address currency;
        uint256 timer;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    MAPPINGS
    _RealizedSwaps (Index number => struct Exchanges);                        //Records all Swaps 
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    mapping(uint256 => Exchanges) public _RealizedSwaps;
    mapping(address => uint256) public _totalSwaped;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    CONTRACT EVENTS
    Swap(address indexed Coin, address indexed NFM, uint256 AmountCoin, uint256 AmountNFM);
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    event Swap(
        address indexed Coin,
        address indexed NFM,
        uint256 AmountCoin,
        uint256 AmountNFM
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

    constructor(
        address Controller,
        address Router,
        address NFMOracle,
        uint256 NFMPricing
    ) {
        _Owner = msg.sender;
        INfmController Cont = INfmController(Controller);
        _Controller = Cont;
        _SController = Controller;
        _URouter = Router;
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(Router);
        _uniswapV2Router = uniswapV2Router;
        _OracleAdr = NFMOracle;
        _NFMPricing = NFMPricing;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @returnBalanceContract(address Coin) returns (uint256);
    This function returns the Balance.
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function returnBalanceContract(address Coin) public view returns (uint256) {
        return IERC20(address(Coin)).balanceOf(address(this));
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_updateNFMPricing(uint256 price) returns (bool);
    This function updates Pricing.
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _updateNFMPricing(uint256 price) public onlyOwner returns (bool) {
        _NFMPricing = price;
        return true;
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
        return _CoinArrLength;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_updateCurrenciesList() returns (bool);
    This function checks the currencies in the UV2Pool. If the array in the UV2Pool is longer, then update Liquidity array
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _updateCurrenciesList() public onlyOwner returns (bool) {
        if (
            INfmUV2Pool(address(_Controller._getUV2Pool()))
                .returnCurrencyArrayLenght() > _CoinArrLength
        ) {
            _CoinsArray = INfmUV2Pool(address(_Controller._getUV2Pool()))
                .returnCurrencyArray();

            _CoinArrLength = _CoinsArray.length;
        }
        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_updateCurrenciesList() returns (bool);
    This function checks the currencies in the UV2Pool. If the array in the UV2Pool is longer, then update Liquidity array
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function storeSwap(
        uint256 AmountA,
        uint256 AmountB,
        address currency
    ) internal virtual onlyOwner {
        _RealizedSwaps[_SwapingCounter] = Exchanges(
            AmountA,
            AmountB,
            currency,
            block.timestamp
        );
        _SwapingCounter++;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_returnFullLiquidityArray(uint256 Elements) returns (Array);
    This function returns all stored liquidity supply information
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _returnFullSwapArray() public view returns (Exchanges[] memory) {
        Exchanges[] memory lExchanges = new Exchanges[](_SwapingCounter);
        for (uint256 i = 0; i < _SwapingCounter; i++) {
            Exchanges storage lExchang = _RealizedSwaps[i];
            lExchanges[i] = lExchang;
        }
        return lExchanges;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_returnLiquidityByElement(uint256 Element) returns (Array);
    This function returns liquidity supply information by index.
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _returnSwapByElement(uint256 Element)
        public
        view
        returns (Exchanges memory)
    {
        return _RealizedSwaps[Element];
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_returntotalLiquidity(address Coin) returns (uint256);
    This function returns total liquidity supply information by Coin address (TotalAmount Liquidity + USD Price).
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _returntotalSwapedAssets(address Coin)
        public
        view
        returns (uint256, uint256)
    {
        uint256 latestprice;
        if (Coin == _Controller._getNFM()) {
            latestprice = 0;
        } else {
            latestprice = INfmOracle(_OracleAdr)._getLatestPrice(Coin);
        }
        return (_totalSwaped[Coin], latestprice);
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @getamountOutOnSwap(uint256 amount) returns (uint256);
    This function returns Amount NFM to add.
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function getamountOutOnSwap(uint256 amount) public view returns (uint256) {
        address _UV2Pairs = IUniswapV2Factory(
            IUniswapV2Router02(_uniswapV2Router).factory()
        ).getPair(address(_Controller._getNFM()), _CoinsArray[Index]);
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(_UV2Pairs)
            .getReserves();
        uint256 amountOut = IUniswapV2Router02(_uniswapV2Router).getAmountOut(
            amount,
            reserve1,
            reserve0
        );
        return amountOut;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @checkliquidityAmount() returns (bool);
    This function is executed once at the beginning of the event if the pair was initiated. it calculates whether a swap is possible
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function startSwapLogic() public virtual onlyOwner returns (bool) {
        //Get full NFM balance
        _updateCurrenciesList();
        if (Index >= returnCurrencyArrayLenght()) {
            Index = 0;
        }
        uint256 NFMTotalSupply = IERC20(address(_Controller._getNFM()))
            .balanceOf(_Controller._getUV2Pool());
        if (NFMTotalSupply > 0) {
            if (SafeMath.div(NFMTotalSupply, 2) > _MinNFM) {
                uint256 TAAmount = getamountOutOnSwap(
                    SafeMath.div(NFMTotalSupply, 2)
                );
                uint256 latestprice = INfmOracle(_OracleAdr)._getLatestPrice(
                    _CoinsArray[Index]
                );
                uint256 TAAmount18;
                if (IERC20(address(_CoinsArray[Index])).decimals() < 18) {
                    TAAmount18 = SafeMath.mul(
                        TAAmount,
                        10 **
                            SafeMath.sub(
                                18,
                                IERC20(address(_CoinsArray[Index])).decimals()
                            )
                    );
                } else {
                    TAAmount18 = TAAmount;
                }
                uint256 TAUSDAmount = SafeMath.div(
                    SafeMath.mul(TAAmount18, latestprice),
                    10**6
                );
                //Pricing must be the amount of NFM for 1 Dollar
                NextNFMSwapAmount = SafeMath.div(
                    SafeMath.mul(TAUSDAmount, _NFMPricing),
                    10**18
                );
                if (NextNFMSwapAmount > _MinNFM) {
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
    @getBalances() returns (bool);
    This function gets balances for the upcoming Liquidity event once. 
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function getBalances() public onlyOwner returns (bool) {
        uint256 AmountTA = IERC20(address(_Controller._getNFM())).balanceOf(
            address(_Controller._getUV2Pool())
        );
        if (AmountTA > 0) {
            if (
                INfmUV2Pool(address(_Controller._getUV2Pool()))._getWithdraw(
                    _Controller._getNFM(),
                    address(this),
                    0,
                    false
                ) == true
            ) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @returnfunds() returns (bool);
    This function sends the remaining credits back to the UV2Pool and 10% are sended to the Bonus Extension for upcomming 
    Bonus Events.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function returnfunds() public onlyOwner returns (bool) {
        uint256 AmountTB = IERC20(address(_CoinsArray[Index])).balanceOf(
            address(this)
        );

        uint256 BonusAmount = SafeMath.div(AmountTB, 10);
        (address Bonus, ) = _Controller._getBonusBuyBack();
        if (AmountTB > 0) {
            if (
                IERC20(address(_CoinsArray[Index])).transfer(
                    _Controller._getUV2Pool(),
                    SafeMath.sub(AmountTB, BonusAmount)
                ) ==
                true &&
                IERC20(address(_CoinsArray[Index])).transfer(
                    Bonus,
                    BonusAmount
                ) ==
                true
            ) {
                return true;
            } else {
                return false;
            }
        }
        return false;
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
    @makeSwap() returns (bool);
    This function executes the swap once all previous steps are done.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function makeSwap() public onlyOwner returns (bool) {
        address[] memory path = new address[](2);
        path[0] = address(_Controller._getNFM());
        path[1] = address(_CoinsArray[Index]);

        uint256 OBalA = IERC20(address(_Controller._getNFM())).balanceOf(
            address(this)
        );

        if (OBalA > 0) {
            uint256 OBalB = IERC20(address(_CoinsArray[Index])).balanceOf(
                address(this)
            );
            IERC20(address(_Controller._getNFM())).approve(
                address(_URouter),
                OBalA
            );
            _uniswapV2Router.swapExactTokensForTokens(
                OBalA,
                0,
                path,
                address(this),
                block.timestamp + 1
            );
            uint256 NBalA = IERC20(address(_Controller._getNFM())).balanceOf(
                address(this)
            );
            if (NBalA < OBalA) {
                uint256 NBalB = IERC20(address(_CoinsArray[Index])).balanceOf(
                    address(this)
                );
                uint256 AmountA;
                uint256 AmountB;
                if (NBalA == 0) {
                    AmountA = OBalA;
                } else {
                    AmountA = SafeMath.sub(OBalA, NBalA);
                }
                if (NBalB == 0) {
                    AmountB = OBalB;
                } else {
                    AmountB = SafeMath.sub(NBalB, OBalB);
                }
                _totalSwaped[_Controller._getNFM()] += AmountA;
                _totalSwaped[_CoinsArray[Index]] += AmountB;
                storeSwap(AmountA, AmountB, address(_CoinsArray[Index]));
                emit Swap(
                    address(_CoinsArray[Index]),
                    address(_Controller._getNFM()),
                    AmountB,
                    AmountA
                );
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
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
                ._updateUV2_Swap_event() == true
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
    @_LiquifyAndSwap()  returns (bool);
    This function is responsible for executing the logic in several steps. This is intended to reduce the gas fees per transaction.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _LiquifyAndSwap() public virtual onlyOwner returns (bool) {
        if (
            (INfmTimer(address(_Controller._getTimer()))._getStartTime() +
                (3600 * 24 * 30 * 12 * 11)) > block.timestamp
        ) {
            if (Schalter == 0) {
                if (startSwapLogic() == true) {
                    Schalter = 1;
                    return true;
                } else {
                    updateNext();
                    return true;
                }
            } else if (Schalter == 1) {
                if (getBalances() == true) {
                    Schalter = 2;
                    return true;
                } else {
                    updateNext();
                    return true;
                }
            } else if (Schalter == 2) {
                if (makeSwap() == true) {
                    Schalter = 3;
                    return true;
                } else {
                    updateNext();
                    return true;
                }
            } else if (Schalter == 3) {
                if (returnfunds() == true) {
                    Schalter = 4;
                    return true;
                } else {
                    updateNext();
                    return true;
                }
            } else if (Schalter == 4) {
                if (updateNext() == true) {
                    return true;
                }
                return false;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
}