// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.4;

import "./dependencies/Controller.sol";

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IEmpireFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IEmpireRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

/* https://ecc.capital */

/// @title EMPIREv2: A contract for the EMPIREv2 token
/// @author Empire Capital (Splnty, Tranquil Flow)
/// @dev This contract defines the core logic of the EMPIREv2 token on the base chain
contract EmpireV2 is Controller {
    string  private _name = "Empire";
    string  private _symbol = "EMPIRE";
    uint256 private _totalSupply;
    uint8   private _decimals = 18;

    address public pair;
    uint256 public launchTime;
    uint256 public yearsInflated;
    uint256 public yearlyInflationPercent;
    uint256 public nextInflationTime;
    uint256 public addLiquidityAmount;
    uint256 public buyLiquidityFee;
    uint256 public buyBurnFee;
    uint256 public sellLiquidityFee;
    uint256 public sellBurnFee;
    uint256 public blockCooldownAmount;
    
    address private _owner;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    bool private _inSwap;
    bool public tradingActive = false;
    bool public antiBotsActive = true;

    IEmpireRouter private router;
    
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    mapping (address => bool) public _excludedFees;
    mapping (address => bool) public _excludedTradeLimits;
    mapping (address => bool) public _excludedAntiMev;
    mapping (address => uint256) public antiMevBlock;
    mapping (address => bool) public automatedMarketMakerPairs;
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event YearlyInflation(uint256 inflation);
    event LiquidityAdded(uint256 tokens, uint256 nativeCoin, uint256 lpAdded);
    event NewLimit(uint256 newAddLiqAmount);
    event NewFees(uint256 newBuyLiqFee, uint256 newBuyBurnFee, uint256 newSellLiqFee, uint256 newSellBurnFee);
    event SetExcludedFees(address addr, bool status);
    event SetExcludedTradeLimits(address addr, bool status);
    event SetTradingActive(bool status);
    event YearlyInflationPercentChanged(uint256 newYearlyInflationPercent);
    
    /// @param eRouter The address of the EmpireDEX router
    constructor (address eRouter) {
        emit OwnershipTransferred(_owner, msg.sender);
        _owner = msg.sender;
        launchTime = block.timestamp;
        nextInflationTime = launchTime + 365 days;

        uint256 totalMint = 100_000 * 10**_decimals;
        _totalSupply += totalMint;
        _balances[_owner] += totalMint;
        emit Transfer(address(0), _owner, totalMint);

        router = IEmpireRouter(eRouter);        

        pair = IEmpireFactory(router.factory())
            .createPair(address(this), router.WETH());

        setAutomatedMarketMakerPair(pair, true);

        addLiquidityAmount = 1000 * 10**_decimals;
        
        buyLiquidityFee = 1000;         // 1%
        buyBurnFee = 100;               // 0.1%
        sellLiquidityFee = 1000;        // 1%
        sellBurnFee = 100;              // 0.1%
        blockCooldownAmount = 3;
        yearlyInflationPercent = 2000;  // 2%
        
        setExcludedFees(address(this), true);
        setExcludedFees(_owner, true);
        setExcludedFees(pair, true);
        setExcludedFees(address(router), true);

        setExcludedAntiMev(address(this), true);
        setExcludedAntiMev(_owner, true);
    }
    
    receive() payable external {}

    /*//////////////////////////////////////////////////////////////
                            USER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function getOwner() public view returns (address) {
        return _owner;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "Wallet address can not be the zero address!");
        require(spender != address(0), "Spender can not be the zero address!");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero!");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    /// @notice High level function to move `amount` of tokens from `msg.sender` to `recipient` and applying fees
    /// @dev Transfers amount of tokens from the msg.sender to recipient
    /// @param recipient The address that is receiving tokens
    /// @param amount The initial amount of tokens being sent, before fees on transfer
    /// @return True if transfer is successful, else false
    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    /// @notice High level function to move `amount` of tokens from `sender` to `recipient` and applying fees
    /// @dev Transfers amount of tokens from sender to recipient
    /// @param sender The address that is sending tokens
    /// @param recipient The address that is receiving tokens
    /// @param amount The initial amount of tokens being sent, before fees on transfer
    /// @return True if transfer is succesful, else false
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Amount exceeds allowance!");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, currentAllowance - amount);    
        return true;
    }

    /// @notice Low level function that sends `amount` from `sender` to `recipient`, checking limitations & apply fees
    /// @dev Transfers amount of tokens from sender to recipient
    /// @param sender The address that is sending tokens
    /// @param recipient The address that is receiving tokens
    /// @param amount The initial amount of tokens being sent, before fees on transfer
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        //anti mev
        if(antiBotsActive) {
            if(!_excludedAntiMev[sender] && !_excludedAntiMev[recipient])
            {
                address actor = antiMevCheck(sender, recipient);
                antiMevFreq(actor);
                antiMevBlock[actor] = block.number;
            }
        }
        
        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= amount, "Amount exceeds senders balance!");
        _balances[sender] = senderBalance - amount;

        uint256 liquidityAmount;
        uint256 burnAmount;
        
        //if buy
        if(automatedMarketMakerPairs[sender] && !_excludedFees[recipient]) {

            //trading active or excluded
            require(_excludedTradeLimits[recipient] || tradingActive, "Trading not active");

            liquidityAmount = amount * buyLiquidityFee / 100000;
            burnAmount = amount * buyBurnFee / 100000;
        }

        //if sell
        else if (automatedMarketMakerPairs[recipient] && !_excludedFees[sender]) {

            //trading active or excluded
            require(_excludedTradeLimits[sender] || tradingActive, "Trading not active");

            liquidityAmount = amount * sellLiquidityFee / 100000;
            burnAmount = amount * sellBurnFee / 100000;
            
            swapAddLiquidity();
        }

        amount -= liquidityAmount;
        _balances[address(this)] += liquidityAmount;
        emit Transfer(sender, address(this), liquidityAmount);

        amount -= burnAmount;
        _totalSupply -= burnAmount;
        
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    /// @dev Adds liquidity on the EMPIRE/Native Coin pair
    /// @param tokenAmount The amount of tokens for adding to liquidity
    /// @param amount The amount of native coin for adding to liquidity
    function addLiquidity(uint256 tokenAmount, uint256 amount) internal virtual {
        _approve(address(this), address(router), tokenAmount);
        (uint256 tokens, uint256 eth, uint256 lpCreated) = 
        router.addLiquidityETH{value: amount}(address(this), tokenAmount, 0, 0, address(this), block.timestamp);
        emit LiquidityAdded(tokens, eth, lpCreated);
    }

    /// @dev Swaps `amount` EMPIRE for native coin
    /// @param amount The amount of EMPIRE to swap
    function swapTokensForEth(uint256 amount) internal virtual {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), amount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, address(this), block.timestamp);
    }

    /// @notice Sells EMPIRE for native coin and uses both to add liquidity
    /// @dev Checks if the amount of EMPIRE on the contract is > addLiquidityAmount
    function swapAddLiquidity() internal virtual {
        uint256 tokenBalance = balanceOf(address(this));
        if(!_inSwap && tokenBalance >= addLiquidityAmount) {
            _inSwap = true;
            
            uint256 sellAmount = tokenBalance;
            
            uint256 sellHalf = sellAmount / 2;

            uint256 initialEth = address(this).balance;
            swapTokensForEth(sellHalf);
            
            uint256 receivedEth = address(this).balance - initialEth;
            addLiquidity(sellAmount - sellHalf, (receivedEth));

            _inSwap = false;
        }
    }

    /// @notice Burns `amount` EMPIRE tokens
    /// @dev Used to manually burn EMPIRE
    /// @param amount The amount of EMPIRE to burn
    function manualBurn(uint256 amount) external {
        address account = msg.sender;
        require(amount <= _balances[account], "Burn amount exceeds balance");
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    /*//////////////////////////////////////////////////////////////
                            ANTI BOT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function antiMevCheck(address _to, address _from) internal virtual returns (address) {
        require(!isContract(_to) || !isContract(_from), "No bots allowed!");
        if (isContract(_to)) return _from;
        else return _to;
    }

    function antiMevFreq(address addr) internal virtual {
        bool isAllowed = antiMevBlock[addr] == 0 ||
            ((antiMevBlock[addr] + blockCooldownAmount) < (block.number + 1));
        require(isAllowed, "Max tx frequency exceeded!");
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Withdraws `amount` of native coin from the contract
    /// @dev Withdraws native coin from contract if some gets stuck on the contract
    /// @param amount The amount of native coin to withdraw 
    /// @return True if withdraw is successful, else false
    function withdraw(uint256 amount) public payable onlyOwner returns (bool) {
        require(amount <= address(this).balance, "Withdrawal amount exceeds balance!");
        payable(msg.sender).transfer(amount);
        return true;
    }

    /// @notice Withdraws `amount` of token (`tokenContract`) from the contract
    /// @dev Withdraws token from contract if somee gets stuck on the contract
    /// @param tokenContract The address of the token to withdraw
    /// @param amount The amount of tokens to withdraw 
    function withdrawToken(address tokenContract, uint256 amount) public virtual onlyOwner {
        IERC20 _tokenContract = IERC20(tokenContract);
        _tokenContract.transfer(msg.sender, amount);
    }

    /// @notice Changes antiBotsActive to `value`
    /// @dev Determines if anti-MEV checks are conducted on transfers
    /// @param value Determines the new value for antiBotsActive
    function setAntiBotsActive(bool value) external onlyOwner {
        antiBotsActive = value;
    }

    /// @notice Defines the new value for addLiquidityAmount (`_addLiquidityAmount`)
    /// @dev addLiquidityAmount = how many tokens to hold on contract before selling for liquidity
    /// @param _addLiquidityAmount Determines the new value for addLiquidityAmount
    function setLimit(uint256 _addLiquidityAmount) public virtual onlyOwner {
        addLiquidityAmount = _addLiquidityAmount * 10**_decimals;
        emit NewLimit(_addLiquidityAmount);
    }

    /// @dev Defines the fees on transfer for buys and sells separately
    /// @param _buyLiquidityFee Determines the new value for buyLiquidityFee
    /// @param _buyBurnFee Determines the new value for buyBurnFee
    /// @param _sellLiquidityFee Determines the new value for sellLiquidityFee
    /// @param _sellBurnFee Determines the new value for sellBurnFee
    function setFees(
        uint256 _buyLiquidityFee,
        uint256 _buyBurnFee,
        uint256 _sellLiquidityFee,
        uint256 _sellBurnFee
        ) public virtual onlyOwner {
        require(
            _buyLiquidityFee <= 5000
            && _buyBurnFee <= 5000
            && _sellLiquidityFee <= 5000
            && _sellBurnFee <= 5000
            , "Fees cannot be more than 5 percent"); 
        buyLiquidityFee = _buyLiquidityFee;
        buyBurnFee = _buyBurnFee;
        sellLiquidityFee = _sellLiquidityFee;
        sellBurnFee = _sellBurnFee;
        emit NewFees(_buyLiquidityFee, _buyBurnFee, _sellLiquidityFee, _sellBurnFee);
    }

    /// @notice Defines if an address (`addy`) is exempt from fees on transfer
    /// @param addy Determines the address to be excluded from fees on transfer
    /// @param status Determines if `addy` is excluded from fees on transfer
    function setExcludedFees(address addy, bool status) public virtual onlyOwner {
        _excludedFees[addy] = status;
        emit SetExcludedFees(addy, status);
    }

    /// @notice Defines if an address (`addy`) is exempt from anti-MEV checks
    /// @param addy Determines the address to be excluded from anti-MEV checks
    /// @param status Determines if `addy` is excluded from anti-MEV checks
    function setExcludedAntiMev(address addy, bool status) public virtual onlyOwner {
        _excludedAntiMev[addy] = status;
    }

    /// @notice Defines if `addy` is a DEX trading pair for the EMPIRE token
    /// @dev Specifies 
    /// @param addy Determines the address of the market maker pair
    /// @param status Determines if `addy` is a market maker pair
    function setAutomatedMarketMakerPair(address addy, bool status) public virtual onlyOwner {
        automatedMarketMakerPairs[addy] = status;
    }

    /// @notice Defines if `addy` is allowed to transfer/trade, bypassing other locks on transfers/trades
    /// @dev Function allows to define an address that cantrade even if tradingActive is false
    /// @param addy Determines the address to be excluded from limits
    /// @param status Determines if addy is excluded or not
    function setExcludedTradeLimits(address addy, bool status) public virtual onlyOwner {
        _excludedTradeLimits[addy] = status;
        emit SetExcludedTradeLimits(addy, status);
    }

    /// @notice Changes the tradingActive to `status`
    /// @dev tradingActive determines if trading on a DEX is enabled 
    /// @param status Determines the new status for tradingActive
    function setTradingActive(bool status) external onlyOwner {
        tradingActive = status;
        emit SetTradingActive(status);
    }

    /// @notice Changes the setBlockCooldown variable to `value`
    /// @dev Used to determine anti-MEV logic, setting how many blocks can elapse between transfers
    /// @param value Determines the new value for setBlockCooldown
    function setBlockCooldown(uint value) external onlyOwner {
        blockCooldownAmount = value;
    }

    /// @notice Distributes tokens to multiple recipients with differing values amount
    /// @param recipients An array that defines the addresses that are being distributed tokens
    /// @param values An array that defines the amount of tokens to be distributed to the recipients
    function airdrop(address[] calldata recipients, uint256[] calldata values) external onlyOwner {
        require(recipients.length < 501,"Max airdrop limit is 500 addresses per tx");
        require(values.length == recipients.length,"Mismatch between length of recipients and values");
        
        _approve(owner(), owner(), totalSupply());
        for (uint256 i = 0; i < recipients.length; i++) {
            transferFrom(msg.sender, recipients[i], values[i] * 10 ** decimals());
        }
    }

    /*//////////////////////////////////////////////////////////////
                          GOVERNANCE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Sets the yearlyInflationPercent to `value`
    /// @dev Changes the yearlyInflationPercent to a value between 0-5%. Value of 1000 = 1%
    function setYearlyInflationPercent(uint256 value) external onlyGovernance {
        require(value <= 5000, "Inflation percent can only be between 0-5 percent");
        yearlyInflationPercent = value;

        emit YearlyInflationPercentChanged(value);
    }

    /// @notice Allows for new tokens to be created every year based on yearlyInflationPercent + totalSupply
    /// @dev Newly created tokens are transferred to governance address, not owner
    function yearlyInflation() external onlyGovernance {
        require(block.timestamp > nextInflationTime, "Cannot inflate yet, has not been a year");

        yearsInflated++;
        nextInflationTime = launchTime + (365 days * (yearsInflated + 1));

        uint256 inflationAmount = _totalSupply * yearlyInflationPercent / 100000;
        _totalSupply += inflationAmount;
        _balances[governance] += inflationAmount;

        emit YearlyInflation(inflationAmount);
    }

    /*//////////////////////////////////////////////////////////////
                          BRIDGING FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // BRIDGE OPERATOR ONLY REQUIRES 2BA - TWO BLOCKCHAIN AUTHENTICATION //

    /// @dev Receives `amount` EMPIRE from a cross chain transfer
    /// @param account The address that is receiving a cross chain transfer
    /// @param amount The amount of EMPIRE tokens being received cross chain
    function unlock(address account, uint256 amount) external onlyOperator {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    /// @notice Called by bridge when user has calls function lock() on LockBurnBridge
    /// @dev Initiates cross chain transfer of `amount` EMPIRE to another chain
    /// @param account The address that is doing a cross chain transfer
    /// @param amount The amount of EMPIRE tokens being transferred cross chain
    function lock(address account, uint256 amount) external onlyOperator {
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Controller is Ownable {
    mapping(address => bool) public operator;
    address public governance;
    event OperatorCreated(address _operator, bool _whiteList);
    event GovernanceTransfered(address oldGovernance, address newGovernance);

    modifier onlyOperator() {
        require(operator[msg.sender], "Only-Operator");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "Only-Governance");
        _;
    }

    constructor() {
        operator[msg.sender] = true;
        governance = msg.sender;
    }

    function setOperator(address _operator, bool _whiteList) public onlyOwner {
        operator[_operator] = _whiteList;
        emit OperatorCreated(_operator, _whiteList);
    }

    function transferGovernance(address _governance) public onlyGovernance {
        governance = _governance;
        emit GovernanceTransfered(msg.sender, governance);
    }

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