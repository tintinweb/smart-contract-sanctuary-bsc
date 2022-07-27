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
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// INFMTIMER
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
interface INfmTimer {
    function _updateUV2_Liquidity_event() external returns (bool);

    function _getStartTime() external view returns (uint256);
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
/// @title NFMLiquidity.sol
/// @author Fernando Viktor Seidl E-mail: [email protected]
/// @notice This contract regulates the Liquidity Management for the UniswapV2 Protocol
/// @dev This extension regulates and controls the liquidity management for the Uniswap protocol.
///
///         INFO:
///         -   This process is carried out almost automatically every 7 days by the trading cycle of the NFM. The process runs through an
///             index that contains all permitted currency addresses. With each execution, another currency from the index is funded with
///             liquidity in the UniswapV2 protocol
///         -   The liquidity tokens received will be blocked for a period of 11 years. After 11 years, these are redeemed automatically at
///             monthly intervals through the LP-Extension by the NFM protocol. The profits made are divided as follows:
///                     - NFM Community will receive 20% of all LP-Yields (Yields will be distributed via the Bonus Event in the NFM Protocol.)
///                     - Governance will receive 30% of all LP-Yields (The proceeds are set aside for the BuyBack program and are intended
///                       to generate additional income for greater purchasing power.)
///                     - NFM Treasury will receive 40% of all LP-Yields (The proceeds are set aside for the bonus program and are intended to
///                       generate additional income for larger bonus payments.)
///                     - Developers will receive 10% of all LP-Yields (Is paid out as commission payments)
///         -   The initial credit is drawn from the UniswapPool protocol. This contract manages the NFM deposits and all other permitted
///             currencies and is also responsible for generating income.
///
///           ***All internal smart contracts belonging to the controller are excluded from the PAD check.***
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
contract NFMLiquidity {
    //include SafeMath
    using SafeMath for uint256;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    CONTROLLER
    OWNER = MSG.SENDER ownership will be handed over to dao
    */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    address private _Owner;
    INfmController private _Controller;
    address private _SController;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    _CoinArrLength        => Length of Array 
    _CoinsArray             => Array of accepted coins for bonus payments
    _Index                      => Counter of Swap
    Schalter                    => regulates the execution of the swap for the bonus
    _MinNFM                   => Minimum liquidity amount in NFM
    _MaxNFM                  => Maximum liquidity amount in NFM
    _LiquidityCounter       => counts the liquidity events
    _uniswapV2Router    => Interface for interacting with the UniswapV2 Protocol
    _URouter                    => Uniswap Router Address
    _NFMPricing               => Exchange rate against USD in 18 digit format
    LiquidityAdded            => struct storing all information about an liquidity event
    */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    uint256 public _CoinArrLength;
    address[] public _CoinsArray;
    uint256 public Index = 0;
    uint256 private _MinNFM = 1000 * 10**18;
    uint256 private _MaxNFM = 100000 * 10**18;
    uint256 public Schalter = 0;
    uint256 public _LiquidityCounter = 0;
    uint256 private _locked = 0;
    IUniswapV2Router02 public _uniswapV2Router;
    address private _URouter;
    address private _OracleAdr;
    uint256 public _NFMPricing;
    struct LiquidityAdded {
        uint256 AmountA;
        uint256 AmountB;
        uint256 LP;
        address currency;
        uint256 timer;
    }
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    MAPPINGS
    _AddedLiquidity (counter, Liquidity Information);
    _lastLiquidityDate (Coin address, timestamp);
    _totalLiquidity (Coin address, Amount )   
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    mapping(uint256 => LiquidityAdded) public _AddedLiquidity;
    mapping(address => uint256) public _lastLiquidityDate;
    mapping(address => uint256) public _totalLiquidity;
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    CONTRACT EVENTS
    Liquidity(address Coin, address NFM, uint256 AmountCoin, uint256 AmountNFM);
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    event Liquidity(
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
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    MODIFIER
    reentrancyGuard       => secures the protocol against reentrancy attacks
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    modifier reentrancyGuard() {
        require(_locked == 0);
        _locked = 1;
        _;
        _locked = 0;
    }

    constructor(
        address Controller,
        address UniswapRouter,
        address NfmOracle,
        uint256 NFMPrice
    ) {
        _Owner = msg.sender;
        INfmController Cont = INfmController(Controller);
        _Controller = Cont;
        _SController = Controller;
        _URouter = UniswapRouter;
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(UniswapRouter);
        _uniswapV2Router = uniswapV2Router;
        _OracleAdr = NfmOracle;
        _NFMPricing = NFMPrice;
    }

    function _updateExchangeRate(uint256 NFMPrice)
        public
        onlyOwner
        returns (bool)
    {
        _NFMPricing = NFMPrice;
        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_storeLiquidity(uint256 AmountA, uint256 AmountB, uint256 LP, address currency);
    This function saves the information of the liquidity supply
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _storeLiquidity(
        uint256 AmountA,
        uint256 AmountB,
        uint256 LP,
        address currency
    ) internal virtual onlyOwner {
        _AddedLiquidity[_LiquidityCounter] = LiquidityAdded(
            AmountA,
            AmountB,
            LP,
            currency,
            block.timestamp
        );
        _LiquidityCounter++;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_returnLastLiquidityDate(address Coin) returns (uint256 lastLiquifyDate);
    This function returns the last timestamp when Liquidity was added to the pool on a specific Coin address
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _returnLastLiquidityDate(address Coin)
        public
        view
        returns (uint256 lastLiquifyDate)
    {
        for (uint256 i = 0; i < returnCurrencyArrayLenght(); i++) {
            if (_CoinsArray[i] == Coin) {
                return _lastLiquidityDate[_CoinsArray[i]];
            }
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_returnLPBalanceUV2(address Coin) returns (uint256 LPBalance);
    This function returns the total amount of LP Tokens for a specific Coin locked in the UV2Contract.
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _returnLPBalanceUV2(address Coin)
        public
        view
        returns (uint256 LPBalance)
    {
        for (uint256 i = 0; i < returnCurrencyArrayLenght(); i++) {
            if (_CoinsArray[i] == Coin) {
                address _UV2Pair = IUniswapV2Factory(
                    IUniswapV2Router02(_uniswapV2Router).factory()
                ).getPair(
                        address(_Controller._getNFM()),
                        address(_CoinsArray[i])
                    );
                uint256 LP = IERC20(address(_UV2Pair)).balanceOf(
                    address(_Controller._getUV2Pool())
                );
                return LP;
            }
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_returnFullLiquidityArray(uint256 Elements) returns (Array);
    This function returns all stored liquidity supply information
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _returnFullLiquidityArray()
        public
        view
        returns (LiquidityAdded[] memory)
    {
        LiquidityAdded[] memory lLiquidityAdded = new LiquidityAdded[](
            _LiquidityCounter
        );
        for (uint256 i = 0; i < _LiquidityCounter; i++) {
            LiquidityAdded storage lLiquidityAdd = _AddedLiquidity[i];
            lLiquidityAdded[i] = lLiquidityAdd;
        }
        return lLiquidityAdded;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_returnLiquidityByElement(uint256 Element) returns (Array);
    This function returns liquidity supply information by index.
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _returnLiquidityByElement(uint256 Element)
        public
        view
        returns (LiquidityAdded memory)
    {
        return _AddedLiquidity[Element];
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @_returntotalLiquidity(address Coin) returns (uint256);
    This function returns total liquidity supply information by Coin address (TotalAmount Liquidity + USD Price).
     */
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _returntotalLiquidity(address Coin)
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
        return (_totalLiquidity[Coin], latestprice);
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
    @checkliquidityAmount() returns (bool);
    This function is executed once at the beginning of the event if the pair was initiated. it calculates whether a liquidity supply is possible
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function checkliquidityAmount() public virtual onlyOwner returns (bool) {
        if (Index >= returnCurrencyArrayLenght()) {
            Index = 0;
        }
        if (
            SafeMath.div(
                IERC20(address(_Controller._getNFM())).balanceOf(
                    address(_Controller._getUV2Pool())
                ),
                2
            ) >
            _MinNFM &&
            IERC20(address(_CoinsArray[Index])).balanceOf(
                address(_Controller._getUV2Pool())
            ) >
            0
        ) {
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
    @getBalances() returns (bool);
    This function stores balances for the upcoming Liquidity event once. 
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function getBalances() public onlyOwner returns (bool) {
        if (
            INfmUV2Pool(address(_Controller._getUV2Pool()))._getWithdraw(
                address(_CoinsArray[Index]),
                address(this),
                0,
                false
            ) ==
            true &&
            INfmUV2Pool(address(_Controller._getUV2Pool()))._getWithdraw(
                address(_Controller._getNFM()),
                address(this),
                50,
                true
            ) ==
            true
        ) {
            return true;
        } else {
            return false;
        }
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @putLiquidity() returns (bool);
    This function adds the Liquidity to the different pools. 
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function putLiquidity() public onlyOwner returns (bool) {
        uint256 AmountTB = IERC20(address(_CoinsArray[Index])).balanceOf(
            address(this)
        );
        uint256 AmountTA = IERC20(address(_Controller._getNFM())).balanceOf(
            address(this)
        );
        if (_lastLiquidityDate[_CoinsArray[Index]] > 0) {} else {
            //First Liquidity calculation needed
            uint256 latestprice = INfmOracle(_OracleAdr)._getLatestPrice(
                _CoinsArray[Index]
            );
            //create 18 digit price format on coin for calculations
            uint256 TAAmount18;
            if (IERC20(address(_CoinsArray[Index])).decimals() < 18) {
                TAAmount18 = SafeMath.mul(
                    AmountTB,
                    10 **
                        SafeMath.sub(
                            18,
                            IERC20(address(_CoinsArray[Index])).decimals()
                        )
                );
            } else {
                TAAmount18 = AmountTB;
            }
            //Returns Amount Coin in Dollar
            uint256 TAUSDAmount = SafeMath.div(
                SafeMath.mul(TAAmount18, latestprice),
                10**6
            );
            //Pricing must be the amount of NFM for 1 Dollar like 1 Dollar = 1,33^ NFM in 18 digit format
            TAAmount18 = SafeMath.div(
                SafeMath.mul(TAUSDAmount, _NFMPricing),
                10**18
            );
            if (TAAmount18 < AmountTA) {
                AmountTA = TAAmount18;
            }
        }

        (uint256 amountA, uint256 amountB, uint256 liquidity) = _uniswapV2Router
            .addLiquidity(
                address(_Controller._getNFM()),
                address(_CoinsArray[Index]),
                AmountTA,
                AmountTB,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                address(this),
                block.timestamp + 1
            );
        _totalLiquidity[_Controller._getNFM()] += amountA;
        _totalLiquidity[_CoinsArray[Index]] += amountB;
        _lastLiquidityDate[_CoinsArray[Index]] = block.timestamp;
        _storeLiquidity(
            amountA,
            amountB,
            liquidity,
            address(_CoinsArray[Index])
        );
        emit Liquidity(
            address(_CoinsArray[Index]),
            address(_Controller._getNFM()),
            amountB,
            amountA
        );
        return true;
    }

    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    @updateNext() returns (bool);
    This function updates the timer.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function updateNext() public onlyOwner returns (bool) {
        if (
            INfmTimer(address(_Controller._getTimer()))
                ._updateUV2_Liquidity_event() == true
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
    @_addLiquidity() returns (bool);
    This function is responsible for executing the logic in several steps. This is intended to reduce the gas fees per transaction.
     */
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function _addLiquidity() public virtual reentrancyGuard returns (bool) {
        require(
            _Controller._checkWLSC(_SController, msg.sender) == true ||
                _Owner == msg.sender,
            "oO"
        );
        require(msg.sender != address(0), "0A");
        if (Schalter == 0) {
            if (_updateCurrenciesList() == true) {
                if (checkliquidityAmount() == true) {
                    Schalter = 1;
                    return true;
                } else {
                    updateNext();
                    return false;
                }
            } else {
                return false;
            }
        } else if (Schalter == 1) {
            if (getBalances() == true) {
                Schalter = 2;
                return true;
            } else {
                return false;
            }
        } else if (Schalter == 2) {
            if (
                IERC20(address(_Controller._getNFM())).approve(
                    _URouter,
                    IERC20(address(_Controller._getNFM())).balanceOf(
                        address(this)
                    )
                ) ==
                true &&
                IERC20(address(_CoinsArray[Index])).approve(
                    _URouter,
                    IERC20(address(_CoinsArray[Index])).balanceOf(address(this))
                ) ==
                true &&
                putLiquidity() == true
            ) {
                Schalter = 3;
                return true;
            } else {
                return false;
            }
        } else if (Schalter == 3) {
            uint256 AmountTA = IERC20(address(_Controller._getNFM())).balanceOf(
                address(this)
            );
            if (AmountTA > 0) {
                IERC20(address(_Controller._getNFM())).transfer(
                    _Controller._getUV2Pool(),
                    AmountTA
                );
            }
            uint256 AmountTB = IERC20(address(_CoinsArray[Index])).balanceOf(
                address(this)
            );
            if (AmountTB > 0) {
                IERC20(address(_CoinsArray[Index])).transfer(
                    _Controller._getUV2Pool(),
                    AmountTB
                );
            }
            address _UV2Pair = IUniswapV2Factory(
                IUniswapV2Router02(_uniswapV2Router).factory()
            ).getPair(
                    address(_Controller._getNFM()),
                    address(_CoinsArray[Index])
                );
            uint256 LP = IERC20(address(_UV2Pair)).balanceOf(address(this));
            if (LP > 0) {
                IERC20(address(_UV2Pair)).transfer(
                    _Controller._getUV2Pool(),
                    LP
                );
            }
            Schalter = 4;
            return true;
        } else if (Schalter == 4) {
            if (updateNext() == true) {
                return true;
            }
            return false;
        } else {
            return false;
        }
    }
}