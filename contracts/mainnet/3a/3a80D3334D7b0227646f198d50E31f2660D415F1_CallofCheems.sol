/**
 *Submitted for verification at BscScan.com on 2022-10-26
*/

//SPDX-License-Identifier: MIT

/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(///(@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@                           @@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@,          @@@@@@@@@@@@@@@@&          (@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@(       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@       &@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@.      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      #@@@@@@@@@@@@@
@@@@@@@@@@@     *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@
@@@@@@@@@     @@@@@@@@@@@@@%(@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     @@@@@@@@@
@@@@@@@     @@@@@@@@@@@@@@((#%%%%%%%%%%%%%(%##(/@@@@@@@@@@@@@@@@@@@     @@@@@@@
@@@@@,    @@@@@@@@@@@@@@@(%%%#####/////(*(((*###((((,,@@@@@@@@@@@@@@@    #@@@@@
@@@@    ,@@@@@@@@@@@@@##%%((((((((///*//****((#(//((,,,*@@@@@@@@@@@@@@     @@@@
@@@    @@@@@@@@@@@@@@#%%#(((((((((((((`//////(*((((##(***@@@@@@@@@@@@@@%    @@@
@@    @@@@@@@@@@@@@@..((((((((((((((((((((/,,,,,/`(##((**@@@@@@@@@@@@@@@(    @@
@%    @@@@@@@@@@@@@&*`/(((((/`....../###(##(,,,,,,((((((((*.(#&&&@@@@@@@@    @@
@    @@@@@@@@@&&&&&(((/////((/////////&&&#%///,,,,,#(#((//(/*(,#&&&&@@@@@@    @
@    @@@@@&&@@&%%((//(//#(%#%#/////*&&&&&%%/***,,,/(((###,*(**(((@&&&&@@@@    @
@   ,&%&&&@@@&%.......,,////*(/*`//(&&&&&%#%%%%(((#(((((*****(#&&/***%%%@@    @
@   *%%@@@##%#........,,,*,,,,,,((//&&%&%%%%%%%%((,,*********(&&&&&&&(*.%@    @
@    &#(...(%#&&/***,,,,,,,,,,,///(((#&&%%%%#****(,,,,*,,,(&&&&&&&&&&&&&(/    @
@    .. ..,%#%%&&&((#,,,/##((###(((((#%%%%%#**,,,,,,,,*,,,,,/&&&&&&&&&&&&%    @
@%   /..,/%(,#%(&((,,*##(#%%%%%%%%#%%%%%%%%%(((((**,,,,,/(&&%&&&&&&%#&%#(    @@
@@    *,*%%%,/%%*(,(# .(#%%%%%%%%%###(((((%((((##(,,,.,/..#&&&&&%%%&&&&&%    @@
@@@    ,(,,,,,%(/,,,#.,*((##%%%%((((((((((((((**....,,(,.*,&&&(%&*&&&&&%    @@@
@@@@    (.,,,,,/,,.,,//#((,,%####(((((((((((*... .,,,(/ ,*&&&&#%%&&%##,    @@@@
@@@@@*    ,*,,,,.,,,,*#//,/,***%(((........  ....../(/.. .&&%&&#&&#*#    &@@@@@
@@@@@@@    / ,... ,,(/.,,.,,*****`/,,.   .  .   . .     .,#&&/&%#%&     @@@@@@@
@@@@@@@@@     ,,///((//...,#(//*****,`///, ..   ..,,*,,...(#&(%##     @@@@@@@@@
@@@@@@@@@@@     &&%*.  ..  *.**,,,,,.,...../.......**....(#//&&     @@@@@@@@@@@
@@@@@@@@@@@@@/     %%%    .,(..,,,,.*, . .. ......../(#/..*.     &@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@&       *,,*,,,,,.,., ..(.,.,,........,.      @@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@#         .../,/##/#/,,...,*,         &@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@                           @@@@@@@@@@@@@@@@@@@@@@@@@@

/******************************************************************************\
|  _____         _  _           __   _____  _                                  |
| /  __ \       | || |         / _| /  __ \| |                                 |
| | /  \/  __ _ | || |   ___  | |_  | /  \/| |__    ___   ___  _ __ ___   ___  |
| | |     / _` || || |  / _ \ |  _| | |    | '_ \  / _ \ / _ \| '_ ` _ \ / __| |
| | \__/\| (_| || || | | (_) || |   | \__/\| | | ||  __/|  __/| | | | | |\__ \ |
|  \____/ \__,_||_||_|  \___/ |_|    \____/|_| |_| \___| \___||_| |_| |_||___/ |
\******************************************************************************/    

pragma solidity >=0.8.12 <0.9.0;

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

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

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract CallofCheems is IERC20 {
    using SafeMath for uint256;
    using SafeMath for uint8;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    address public MARKETINGWALLET = 0xf8c80cFf4c49DBfBD2aad7f037B9A07E0e46898E; // CHANGE
    address public OPERATIONSWALLET = 0xB81b0d2796b36f11F21C217B56aA22437d0e9493; // CHANGE
    address public AUTOLPRECEIVERWALLET = 0x000000000000000000000000000000000000dEaD; // CHANGE
    uint256 public THRESHOLD;
    uint256 public MAXWALLET;
    uint256 public MAXTRANSACTION;
    address private oldTokenAddress;

    address private _deployer;
    Tax private _tax;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private isPair;
    mapping(address => bool) private isExempt;
    mapping(address => bool) private isEarlyTrader;

    address private _owner = address(0);

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool inLiquidate;
    bool tradingOpen;
    bool migrationOpen;

    event Liquidate(
        uint256 bnbForMarketing,
        uint256 bnbForOperations,
        uint256 bnbForLiquidity,
        uint256 tokensForLiquidity
    );
    event SetMarketingWallet(address newMarketingWallet);
    event SetOperationsWallet(address newOperationsWallet);
    event SetAutoLpReceiverWallet(address newAutoLpReceiverWallet);
    event SetMaxTx(uint256 maxTxTokens);
    event SetMaxWallet(uint256 maxWalletTokens);
    event TransferOwnership(address _newDev);
    event UpdateExempt(address _address, bool _isExempt);
    event AddPair(address _pair);
    event OpenTrading(bool tradingOpen);
    event RemoveEarlyTrader(address _earlyTrader);
    event Migrate(address receiver, uint256 tokensSent);
    event LunchReady();

    constructor() {
        name = "Call of Cheems";
        symbol = "COC";
        decimals = 8;
        
        _deployer = msg.sender;
        _tax = Tax(40, 40, 20, 10); //4% marketing, 4% operations, 2% liquidity, 10% total tx fee
        _update(address(0), address(this), 1000000 * 10**8);

        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );

        THRESHOLD = totalSupply.div(1000); //0.1% swap threshold
        MAXWALLET = totalSupply.mul(2).div(100); //2% max wallet
        MAXTRANSACTION = totalSupply.div(100); //1% max transaction

        oldTokenAddress = 0xB3dF3b4caCa694825F9220c717f094E1E112Fb65;

        isPair[address(uniswapV2Pair)] = true;
        isExempt[msg.sender] = true;
        isExempt[address(this)] = true;

        allowance[address(this)][address(uniswapV2Pair)] = type(uint256).max;
        allowance[address(this)][address(uniswapV2Router)] = type(uint256).max;

        migrationOpen = true;
    }

    struct Tax {
        uint8 marketingTax;
        uint8 operationsTax;
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

    function tradingIsOpen() external view returns (bool) {
        return tradingOpen;
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
        return _transferFrom(msg.sender, to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        uint256 availableAllowance = allowance[from][msg.sender];
        if (availableAllowance < type(uint256).max) {
            allowance[from][msg.sender] = availableAllowance.sub(amount);
        }

        return _transferFrom(from, to, amount);
    }

    function migrate() external returns(bool){
        require(migrationOpen);    
        IERC20 oldToken = IERC20(oldTokenAddress);

        uint256 tokensSent = oldToken.balanceOf(msg.sender);

        require(tokensSent > 0 && (balanceOf[msg.sender].add(tokensSent) <= MAXWALLET));
        require(oldToken.transferFrom(msg.sender, _deployer, tokensSent));

        require(_update(address(this), msg.sender, tokensSent));
        emit Migrate(msg.sender, tokensSent);
        
        return(true);
    }

    function _transferFrom(
        address from,
        address to,
        uint256 amount
    ) private returns (bool) {
        require(!migrationOpen);

        if (inLiquidate || isExempt[from] || isExempt[to]) {
            return _update(from, to, amount);
        }

        uint256 fee;
        require(!(isEarlyTrader[from] || isEarlyTrader[to]));

        (bool fromPair, bool toPair) = (isPair[from], isPair[to]);
        if (!tradingOpen && fromPair) {
            isEarlyTrader[to] = true;
        }

        if (fromPair || toPair) {
            require((amount <= MAXTRANSACTION));
            fee = amount.mul(_tax.txFee).div(100);
        }

        if (!toPair) {
            require((balanceOf[to].add(amount)) <= MAXWALLET);
        }

        if (balanceOf[address(this)] >= THRESHOLD && !fromPair) {
            _liquidate();
        }

        balanceOf[address(this)] = balanceOf[address(this)].add(fee);
        balanceOf[from] = balanceOf[from].sub(amount);
        balanceOf[to] = balanceOf[to].add(
            amount.sub(fee)
        );

        emit Transfer(from, to, amount);
        return true;
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) private returns (bool) {
        if (from != address(0)) {
            balanceOf[from] = balanceOf[from].sub(amount);
        } else {
            totalSupply = totalSupply.add(amount);
        }
        if (to == address(0)) {
            totalSupply = totalSupply.sub(amount);
        } else {
            balanceOf[to] = balanceOf[to].add(amount);
        }
        emit Transfer(from, to, amount);
        return true;
    }

    function _liquidate() private lockLiquidate {
        uint256 liqTax2 = uint256(_tax.liquidityTax).div(2);
        uint256 tokensForLiquidity = THRESHOLD.mul(liqTax2).div(100);
        uint256 tokensToSwap = THRESHOLD.sub(tokensForLiquidity);

        uint256 availableBeans = 0;
  
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensToSwap,
            0,
            path,
            address(this),
            block.timestamp
            );
        availableBeans = address(this).balance;
        
        uint256 bnbForMarketing = availableBeans.mul(_tax.marketingTax).div(100);
        uint256 bnbForOperations = availableBeans.mul(_tax.operationsTax).div(100);
        uint256 bnbForLiquidity = availableBeans.mul(liqTax2).div(100);

        (bool succ, ) = payable(MARKETINGWALLET).call{value: bnbForMarketing, gas: 30000}("");
        require(succ);

        (succ, ) = payable(OPERATIONSWALLET).call{value: bnbForOperations, gas: 30000}("");
        require(succ);

        if (tokensForLiquidity > 0) {
            (, , uint256 receivedLP) = uniswapV2Router.addLiquidityETH{
                value: bnbForLiquidity
            }(
                address(this),
                tokensForLiquidity,
                0,
                0,
                AUTOLPRECEIVERWALLET,
                block.timestamp + 15
            );
            require(receivedLP > 0);
        }

        emit Liquidate(
            bnbForMarketing,
            bnbForOperations,
            bnbForLiquidity,
            tokensForLiquidity
        );
    }

    function earlyTrader(address add) external view returns (bool) {
        return isEarlyTrader[add];
    }

    function setMarketingWallet(address payable newMarketingWallet)
        external
        protected
    {
        MARKETINGWALLET = newMarketingWallet;
        emit SetMarketingWallet(newMarketingWallet);
    }

    function setOperationsWallet(address payable newOperationsWallet)
        external
        protected
    {
        OPERATIONSWALLET = newOperationsWallet;
        emit SetOperationsWallet(newOperationsWallet);
    }

    function setAutoLpReceiverWallet(address payable newLpReceiver)
        external
        protected
    {
        AUTOLPRECEIVERWALLET = newLpReceiver;
        emit SetAutoLpReceiverWallet(newLpReceiver);
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

    function setLiquidationThreshold(uint256 numberOfTokens)
        external
        protected
    {
        require(numberOfTokens <= totalSupply);
        THRESHOLD = numberOfTokens;
    }

    function setMaxTx(uint256 maxTxTokens) external protected {
        MAXTRANSACTION = maxTxTokens;
        emit SetMaxTx(maxTxTokens);
    }

    function setMaxWallet(uint256 maxWalletTokens) external protected {
        MAXWALLET = maxWalletTokens;
        emit SetMaxWallet(maxWalletTokens);
    }

    function setExempt(address _address, bool _isExempt) external protected {
        isExempt[_address] = _isExempt;
        emit UpdateExempt(_address, _isExempt);
    }

    function addPair(address _address) external protected {
        require(isPair[_address] = false);
        isPair[_address] = true;
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

    function readyLunch() external protected {
        require(migrationOpen == true);
        migrationOpen = false;
        _update(address(this), _deployer, balanceOf[address(this)]);

        emit LunchReady();
    }
}