/**

Doge Ship Token 1.0

Tokenomics:
- Transaction fees: 12%
    - 3% of each buy goes to BNB reflections
    - 3% of each sell to charity wallet
    - 3% to the liquidity pool
    - 3% to dead wallet (burn)

Website:
http://www.dogeshiptoken.io

Telegram:
http://t.me/DogeShipToken_OFC

Twitter:
https://twitter.com/dogeshiptoken
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./IPancakeFactory.sol";
import "./IPancakePair.sol";
import "./IPancakeRouter02.sol";
import "./DividendTracker.sol";
import "./IDogeshipToken.sol";

contract DogeshipToken is Ownable, IDogeshipToken {
    using SafeMath for uint256;
        
    // Constants
    address constant internal DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant internal CHARITY_WALLET = 0x1054CC60e00CAFEA9B546c5F8a95a2003b24186E;
    address constant internal PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // mainnet
    // address constant internal PANCAKE_ROUTER = address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // testnet
    uint256 internal constant MAX_INT = ~uint256(0);

    // Data
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    mapping (address => bool) internal excludeFee;
    mapping (address => bool) internal excludeMaxTransaction;
    mapping (address => bool) internal excludeDividend;

    // Token settings
    string internal _name = "Doge Ship Token";
    string internal _symbol = "$DST";
    uint8 constant internal DECIMALS = 9;
    uint256 public _totalSupply = 8 * 10**12 * (10 ** DECIMALS); // 8 trillion tokens

    // Limits
    uint256 public _maxWallet = MAX_INT;
    uint256 public _maxTransactionAmount = MAX_INT;

	FeeSet public buyFees;
	FeeSet public sellFees;
    uint256 internal feeDenominator = 1000;
    
    // Wallets
    address internal charityWallet = CHARITY_WALLET;
    address internal liquidityWallet;

    // Pancake Swap variables
    IPancakeRouter02 public router;
    IPancakeFactory internal factory;
    address internal wethAddress;
    address internal pair;

    // Dividend Tracker
    DividendTracker public dividendTracker;

    // Swap variables
    uint256 public lastSwap;
    uint256 public swapInterval = 0; // 5 minutes;
    bool public swapEnabled = true;
    bool public swapIgnoreLimit = true;
    uint256 public swapThreshold = _totalSupply / 5000; // (0.02% => 1.6 billion tokens)
    bool internal inSwap;

    // Is open for trading?
    bool public isOpen = false;

    modifier swapping() { inSwap = true; _; inSwap = false; }
    modifier open(address from, address to) {
        require(isOpen || from == owner() || to == owner(), "Not Open");
        _;
    }

    constructor () {
        address ownerAddress = msg.sender;

        // Set up Pancake Swap
        router = IPancakeRouter02(PANCAKE_ROUTER);
        wethAddress = router.WETH();
        pair = IPancakeFactory(router.factory()).createPair(wethAddress, address(this));
        _allowances[address(this)][address(router)] = MAX_INT;

        // Create Dividend Tracker contract
        dividendTracker = new DividendTracker();

        // Set liquidity wallet to owner
        liquidityWallet = ownerAddress;

        // Exclude from fees
        excludeFee[liquidityWallet] = true;
        excludeFee[ownerAddress] = true;
        excludeFee[address(this)] = true;

        // Exclude max transaction limit
        excludeMaxTransaction[liquidityWallet] = true;
        excludeMaxTransaction[ownerAddress] = true;
        excludeMaxTransaction[address(this)] = true;

        // Exclude from dividends
        excludeDividend[pair] = true;
        excludeDividend[address(this)] = true;
        excludeDividend[DEAD] = true;
        
        // Initialize fees
		setBuyFees(30, 30, 30, 30);
		setSellFees(30, 30, 30, 30);
	
        _balances[ownerAddress] = _totalSupply;
        emit Transfer(address(0), ownerAddress, _totalSupply);
    }

    receive() external payable { }

    function setName(string memory newName, string memory newSymbol) public onlyOwner{
        _name = newName;
        _symbol = newSymbol;
    }
    
    // ERC20 - getter functions
    function totalSupply() external override view returns (uint256) { return _totalSupply; }
    function decimals() external pure returns (uint8) { return DECIMALS; }
    function symbol() external view returns (string memory) { return _symbol; }
    function name() external view returns (string memory) { return _name; }

    // ERC20 - get token balanace
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    // ERC20 - check allowance
    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }
	
    // ERC20 - transfer
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    // ERC20 - transfer from
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != ~uint256(0)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    // ERC20 - approve
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Transfer tokens
    function _transferFrom(address sender, address recipient, uint256 amount) internal open(sender, recipient) returns (bool) {
        // re-entrancy protection
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        
        // check transaction limits
        checkTransactionLimits(sender, recipient, amount);

        // check if swap threshold has been met and enough time has passed since last liquidity event
        if (canSwap()) {
          doSwap();
        }

        // Calculate fees
        (uint256 totalAmountAfterFees, uint256 feesCollected, uint256 burnAmount) = calculateFees(sender, recipient, amount);

        // Subtract amount from sender wallet
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        // Transfer burn fee to burn address
        if (burnAmount > 0) {
            _balances[DEAD] = _balances[DEAD].add(burnAmount);
            emit Transfer(sender, DEAD, burnAmount);
        }

        // Transfer remaining fees to token contract address
        if (feesCollected > 0) {
            _balances[address(this)] = _balances[address(this)].add(feesCollected);
            emit Transfer(sender, address(this), feesCollected);            
        }

        // Add remaning amount to recipient's wallet
        _balances[recipient] = _balances[recipient].add(totalAmountAfterFees);
        emit Transfer(sender, recipient, totalAmountAfterFees);

        // Update sender share allocation
        if (!excludeDividend[sender]) {
            dividendTracker.setShare(sender, _balances[sender]);
        }

        // Update recipient share allocation
        if (!excludeDividend[recipient]) {
            dividendTracker.setShare(recipient, _balances[recipient]);
        }
     
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTransactionLimits(address sender, address recipient, uint256 amount) internal view {
        require(amount <= _maxTransactionAmount || excludeMaxTransaction[sender], "Transaction limit exceeded");
        
        if (sender != owner()
            && recipient != address(this) 
            && recipient != address(DEAD)
            && recipient != pair
            && recipient != charityWallet
            && recipient != liquidityWallet) {
            uint256 currentBalance = balanceOf(recipient);
            require(excludeMaxTransaction[recipient] || (currentBalance + amount <= _maxWallet), "Maximum wallet size exceeded");
        }
    }

    // Calculate fees:
    // Return 1) Total amount after applying fees, 2) fees to distribute 3) fees to burn
    function calculateFees(address sender, address recipient, uint256 amount) public view returns (
        uint256 totalAmountAfterFees, uint256 feesCollected, uint256 burnAmount) {
        
        if (excludeFee[sender] || excludeFee[recipient]) 
            return (amount, 0, 0);
        
        FeeSet memory fee;
        if (sender == pair) // todo, support multiple exchanges
            fee = buyFees;
        else
            fee = sellFees;

        uint256 totalFeeAmount = amount.mul(fee.totalFee).div(feeDenominator);

        burnAmount = 0;
        feesCollected = 0;
        totalAmountAfterFees = amount.sub(totalFeeAmount);
        
        if (fee.burnFee > 0) {
            burnAmount = totalFeeAmount.mul(fee.burnFee).div(fee.totalFee);
        }
        
        feesCollected = totalFeeAmount - burnAmount;
    }

    function canSwap() internal view returns (bool) {
        return msg.sender != pair
            && !inSwap
            && swapEnabled
            && _balances[address(this)] >= swapThreshold
            && (lastSwap + swapInterval <= block.timestamp);
    }

    function doSwap() internal swapping {
        // get fees collected
        uint256 swapAmount = _balances[address(this)];

        // cap swap amount to threshold
        if(!swapIgnoreLimit)
            swapAmount = swapThreshold;

        lastSwap = block.timestamp;

        FeeSet memory fee = sellFees;
        uint256 totalFee = fee.totalFee - fee.burnFee;
        uint256 liquidityFee = fee.liquidityFee;
        uint256 reflectionFee = fee.reflectionFee;
        
        // set aside 1/2 liquidity portion in tokens
        uint256 amountToLiquify = swapAmount.mul(liquidityFee).div(totalFee).div(2);
        
        // swap the rest for ETH balance
        uint256 amountToSwap = swapAmount.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = wethAddress;

        // take a sapshot of current ETH balance
        uint256 balanceBefore = address(this).balance;

        // swap tokens for ETH
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
          amountToSwap,
          0,
          path,
          address(this),
          block.timestamp
        );

        // calculate amount of ETH received
        uint256 amountETH = address(this).balance.sub(balanceBefore);

        // calculate amount of ETH to add to liquidity
        uint256 totalETHFee = totalFee.sub(liquidityFee.div(2));
        uint256 amountETHLiquidity = amountETH.mul(liquidityFee).div(2).div(totalETHFee);

        if (amountToLiquify > 0) {

            // add liquidity to ETH/token liquidity pool
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityWallet,
                block.timestamp
            );
        }

        // deposit reflection fee to dividend tracker
        uint256 amountETHReflection = amountETH.mul(reflectionFee).div(totalETHFee);
        dividendTracker.deposit{value: amountETHReflection}();
        
        // send remaining ETH balance to charity wallet
        uint256 amountETHCharity = address(this).balance;
        payable(charityWallet).transfer(amountETHCharity);

        /*
        tokensSwapped = tokensSwapped.add(amountToSwap);
        ethReceived = ethReceived.add(amountETH);
        tokensAddedToLiquidity = tokensAddedToLiquidity.add(amountToLiquify);
        ethAddedToLiquidity = ethAddedToLiquidity.add(amountETHLiquidity);
        ethAddedToCharity = ethAddedToCharity.add(amountETHCharity);
        ethAddedToRewards = ethAddedToRewards.add(amountETHReflection);
        swapCount = swapCount + 1;
        */
    }

    // Update dividend exclusions
    function setExcludeDividendMultiple(address[] calldata _users, bool exempt) external onlyOwner {
        for(uint8 i = 0; i < _users.length; i++) {
            address holder = _users[i];
            require(holder != address(this) && holder != pair, "Cannot update token or LP pair");

            excludeDividend[holder] = exempt;
            if(exempt) {
                dividendTracker.setShare(holder, 0);
            } else {
                dividendTracker.setShare(holder, _balances[holder]);
            }
        }
    }

    // Update fee exclusions
    function setExcludeFeeMultiple(address[] calldata _users, bool exempt) external onlyOwner {
        for(uint8 i = 0; i < _users.length; i++) {
            excludeFee[_users[i]] = exempt;
        }
    }
    
    // Update max transaction fee exclusions
    function setExcludeTxMultiple(address[] calldata _users, bool exempt) external onlyOwner {
        for(uint8 i = 0; i < _users.length; i++) {
            excludeMaxTransaction[_users[i]] = exempt;
        }
    }
 
    // Withdraw any locked ETH sent to this contract
    function withdrawLockedETH(uint256 _amount) external onlyOwner{
        payable(msg.sender).transfer(_amount);
    }
    
    // Withdraw any locked ERC20 tokens sent to this contract
    function withdrawLockedTokens(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(msg.sender, _amount);
    }

    // Public functions to update contract settings
    function setSwapThreshold(uint256 _amount) external onlyOwner { swapThreshold = _amount; }
    function setSwapIgnoreLimit(bool _ignoreLimit) external onlyOwner { swapIgnoreLimit = _ignoreLimit; }
    function setSwapEnabled(bool _enabled) external onlyOwner { swapEnabled = _enabled; }
    function setSwapInterval(uint256 _interval) external onlyOwner { swapInterval = _interval; }
    function setCharityWallet(address _charityWallet) external onlyOwner { charityWallet = _charityWallet; }
    function setLiquidityWallet(address _liquidityWallet) external onlyOwner { liquidityWallet = _liquidityWallet; }
    
    // Update max transaction limit
    function setTransactionLimit(uint256 amount) external onlyOwner {
        // Hard-coded minimum of 0.05% to prevent owner from disabling trading
        require(amount >= _totalSupply / 2000, "Transaction limit too low");
        _maxTransactionAmount = amount;
    }

    // Update max wallet limit
    function setMaxWalletLimit(uint256 amount) external onlyOwner {
        // Hard-coded minimum of 0.05% to prevent owner from disabling trading
        require(amount >= _totalSupply / 2000, "Max wallet limit too low");
        _maxWallet = amount;
    }

    // Open up for trading
    function openTrade() external onlyOwner {
        isOpen = true;
    }

    // Update buy fees
    function setBuyFees(uint256 _reflectionFee, uint256 _charityFee, uint256 _liquidityFee, uint256 _burnFee) public onlyOwner {
		buyFees = FeeSet({
			reflectionFee: _reflectionFee,
			charityFee: _charityFee,
			liquidityFee: _liquidityFee,
            burnFee: _burnFee,
			totalFee: _reflectionFee + _charityFee + _liquidityFee + _burnFee
		});
	}

    // Update sell fees
	function setSellFees(uint256 _reflectionFee, uint256 _charityFee, uint256 _liquidityFee, uint256 _burnFee) public onlyOwner {
		sellFees = FeeSet({
			reflectionFee: _reflectionFee,
			charityFee: _charityFee,
			liquidityFee: _liquidityFee,
            burnFee: _burnFee,
			totalFee: _reflectionFee + _charityFee + _liquidityFee + _burnFee
		});
	}

    // Public functions to update dividend tracker settings
    function setMinDistributionPeriod(uint256 minPeriod) external onlyOwner {
        dividendTracker.setMinDistributionPeriod(minPeriod);
    }
    function setMinDistributionAmount(uint256 minDistribution) external onlyOwner {
        dividendTracker.setMinDistributionAmount(minDistribution);
    }

    // Get account status
    function getAccountStatus(address account)
        external view returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccountStatus(account);
    }
    
    // Claim dividends
    function claim() public {
        dividendTracker.claimDividend(msg.sender);
    }

    // Manually send dividend
    function manualSendDividend(uint256 amount, address holder) external onlyOwner {
        dividendTracker.manualSendDividend(amount, holder);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IPancakeFactory {
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IPancakePair {
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
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

/**

Doge Ship Dividend Tracker 1.0

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./SafeMath.sol";
import "./IDividendTracker.sol";

contract DividendTracker is IDividendTracker {
    using SafeMath for uint256;

    // Dogeship token contract address
    address internal _token;

    // Shareholder data
    address[] internal shareholders;
    mapping (address => uint256) internal shareholderIndexes;
    mapping (address => uint256) internal shareholderClaims;
    mapping (address => Share) public shares;

    // Share variables
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    // Dividend settings
    uint256 public minPeriod = 1 hours; // wait 1 hour between between dividend payments
    uint256 public minDistribution = 1000000000000000; // 0.001 ETH rewards required for auto payment  

    modifier onlyToken() {
        require(msg.sender == _token, "Sender is not token contract"); _;
    }

    constructor () {
        _token = msg.sender;
    }

    // Functions to update settings
    function setMinDistributionPeriod(uint256 _minPeriod) external onlyToken { minPeriod = _minPeriod; }
    function setMinDistributionAmount(uint256 _minDistribution) external onlyToken { minDistribution = _minDistribution; }

    // Update share allocation
    function setShare(address shareholder, uint256 amount) external override onlyToken {
        // Before updating share allocation, distribute any dividends
        if (shouldDistribute(shareholder)) {
            distributeDividend(shareholder);
        }

        // adjust total shares
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        
        // update share holder amount
        shares[shareholder].amount = amount;

        // exclude all dividends
        shares[shareholder].totalExcluded = calculateDividends(shares[shareholder].amount);
    }

    // Token deposits ETH as part of rewards
    function deposit() external payable override onlyToken {
        uint256 amount = msg.value;
        totalDividends = totalDividends.add(amount);

        // increase dividends per share
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }
    
    // Check if user has minimum amount for distribution and enough time has passed since last payment
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shares[shareholder].amount > 0
            && shareholderClaims[shareholder] + minPeriod < block.timestamp
            && getUnpaidEarnings(shareholder) > minDistribution;
    }

    // Pay dividend to user
    function distributeDividend(address shareholder) internal {
        uint256 amount = getUnpaidEarnings(shareholder);
        
        if (amount > 0) {
            // update shareholder data
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = calculateDividends(shares[shareholder].amount);
            totalDistributed = totalDistributed.add(amount);
            
            // transfer ETH to user
            payable(shareholder).transfer(amount);
        }
    }

    // Calculate unpaid earnings
    function getUnpaidEarnings(address shareholder) internal view returns (uint256) {
        if (shares[shareholder].amount == 0) { return 0; }

        // get total dividends
        uint256 shareholderTotalDividends = calculateDividends(shares[shareholder].amount);
        
        // exclude dividends that were previously distributed or excluded
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) { return 0; }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    // Calculated total dividends based on share amount
    function calculateDividends(uint256 share) internal view returns (uint256) {
        // return cumulative total dividends
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }
    
    // Get rewards & dividend status for an account
    function getAccountStatus(address account) public view returns(
        uint256 pendingRewards,
        uint256 totalRewardsPaid,
        uint256 lastClaimTime,
        uint256 nextClaimTime,
        uint256 secondsUntilAutoClaimAvailable) {
            pendingRewards = getUnpaidEarnings(account);
            totalRewardsPaid = shares[account].totalRealised;
            lastClaimTime = shareholderClaims[account];
            nextClaimTime = lastClaimTime + minPeriod;
            secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0;
    }
    
    // Claim dividends 
    function claimDividend(address holder) external override {
        distributeDividend(holder);
    }

    // Manually send dividend
    function manualSendDividend(uint256 amount, address holder) external override onlyToken {
        uint256 contractETHBalance = address(this).balance;
        payable(holder).transfer(amount > 0 ? amount : contractETHBalance);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IERC20.sol";

interface IDogeshipToken is IERC20 {
    
    // Fee struct
	struct FeeSet {
		uint256 reflectionFee;
		uint256 charityFee;
		uint256 liquidityFee;
        uint256 burnFee;
		uint256 totalFee;
	}
    
    function setName(string memory newName, string memory newSymbol) external;
    
    // ERC20 - getter functions
    function totalSupply() external view returns (uint256);
    function decimals() external pure returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address holder, address spender) external view returns (uint256);
	
    // ERC20 - transfer & approve functions
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    
    // Token - setter functions
    function setExcludeDividendMultiple(address[] calldata _users, bool exempt) external;
    function setExcludeFeeMultiple(address[] calldata _users, bool exempt) external;
    function setExcludeTxMultiple(address[] calldata _users, bool exempt) external;
    function setSwapThreshold(uint256 _amount) external;
    function setSwapIgnoreLimit(bool _ignoreLimit) external;
    function setSwapEnabled(bool _enabled) external;
    function setSwapInterval(uint256 _interval) external;
    function setCharityWallet(address _charityWallet) external;
    function setLiquidityWallet(address _liquidityWallet) external;
    function setTransactionLimit(uint256 amount) external;
    function setMaxWalletLimit(uint256 amount) external;
    function setBuyFees(uint256 _reflectionFee, uint256 _charityFee, uint256 _liquidityFee, uint256 _burnFee) external;
	function setSellFees(uint256 _reflectionFee, uint256 _charityFee, uint256 _liquidityFee, uint256 _burnFee) external;
    function setMinDistributionPeriod(uint256 minPeriod) external;
    function setMinDistributionAmount(uint256 minDistribution) external;

    // Token - getter functions - calculate fees
    function calculateFees(address sender, address recipient, uint256 amount) external view returns (
        uint256 totalAmountAfterFees, uint256 feesCollected, uint256 burnAmount);

    // Token - getter functions - get account status
    function getAccountStatus(address account)
        external view returns (
        uint256 pendingRewards,
        uint256 totalRewardsPaid,
        uint256 lastClaimTime,
        uint256 nextClaimTime,
        uint256 secondsUntilAutoClaimAvailable);

    // Claim dividends
    function claim() external;

    // Open up for trading
    function openTrade() external;

    // Withdraw locked funds
    function withdrawLockedETH(uint256 _amount) external;
    function withdrawLockedTokens(address _token, uint256 _amount) external;
    function manualSendDividend(uint256 amount, address holder) external;
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IPancakeRouter01 {
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

/**

Doge Ship Dividend Tracker 1.0

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./SafeMath.sol";

interface IDividendTracker {

    // Share struct
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    // Setter functions
    function setMinDistributionPeriod(uint256 _minPeriod) external;
    function setMinDistributionAmount(uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;

    // Get account status 
    function getAccountStatus(address account) external view returns(
        uint256 pendingRewards,
        uint256 totalRewardsPaid,
        uint256 lastClaimTime,
        uint256 nextClaimTime,
        uint256 secondsUntilAutoClaimAvailable);
    
    // Deposit dividends
    function deposit() external payable;
    
    // Claim/send dividends
    function claimDividend(address holder) external;
    function manualSendDividend(uint256 amount, address holder) external;
}

// SPDX-License-Identifier: MIT

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