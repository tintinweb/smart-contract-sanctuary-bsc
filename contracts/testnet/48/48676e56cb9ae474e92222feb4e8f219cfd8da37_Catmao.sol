/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// File: contracts/Utils/Owned.sol



pragma solidity ^0.8.0;

// https://docs.synthetix.io/contracts/source/contracts/owned
abstract contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor(address _owner) {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {
        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}

// File: contracts/Token/IDEXFactory.sol


pragma solidity ^0.8.0;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}
// File: contracts/Token/IDEXRouter.sol


pragma solidity ^0.8.0;

interface IDEXRouter {
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
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: contracts/Token/DividendDistributor.sol

pragma solidity ^0.8.0;




contract DividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    // IERC20 BUSDReward = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // Mainnet
    // address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // Mainnet
    IERC20 BUSDReward = IERC20(0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47); // Testnet
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // Testnet

    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 45 * 60;
    uint256 public minDistribution = 1 * (10 ** 8);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        router = IDEXRouter(_router);
        _token = msg.sender;
    }

    function setNewRouter(address newRouter) external onlyToken {
        require(newRouter != address(router));
        router = IDEXRouter(newRouter);
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable onlyToken {
        uint256 balanceBefore = BUSDReward.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(BUSDReward);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = BUSDReward.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            BUSDReward.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}
// File: contracts/Token/Tradable.sol



/**
    Tradable.sol

    A contract designed to simplify creating a DEX-tradable token,
    with an adjustable max wallet and max transaction amount.
*/

pragma solidity ^0.8.0;







abstract contract Tradable is IERC20, Owned {
    using SafeMath for uint256;

    struct TokenDistribution {
        uint256 totalSupply;
        uint8 decimals;
        uint256 maxBalance;
        uint256 maxTx;
    }

    uint256 public _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;
    uint256 public _maxBalance;
    uint256 public _maxTx;
    //
    IDEXRouter public router;
    address public pair;
    //
    DividendDistributor public distributor;
    uint256 distributorGas = 500000;
    //
    mapping (address => uint256) public _balances;
    //
    mapping (address => mapping (address => uint256)) public _allowances;
    //
    mapping (address => bool) public _isDividendExempt;
    //
    mapping (address => bool) public _isExcludedFromMaxBalance;
    //
    mapping (address => bool) public _isExcludedFromMaxTx;

    constructor(string memory tokenSymbol, string memory tokenName, TokenDistribution memory tokenDistribution) {
        _totalSupply = tokenDistribution.totalSupply;
        _decimals = tokenDistribution.decimals;
        _symbol = tokenSymbol;
        _name = tokenName;
        _maxBalance = tokenDistribution.maxBalance;
        _maxTx = tokenDistribution.maxTx;

        // router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); //Mainnet
        router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //Testnet 
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this)); // Create a uniswap pair for this new token

        distributor = new DividendDistributor(address(router));

        _isDividendExempt[pair] = true;
        _isDividendExempt[address(this)] = true;

        _isExcludedFromMaxBalance[owner] = true;
        _isExcludedFromMaxBalance[address(this)] = true;
        _isExcludedFromMaxBalance[pair] = true;

        _isExcludedFromMaxTx[owner] = true;
        _isExcludedFromMaxTx[address(this)] = true;
    }

    // To recieve BNB from anyone, including the router when swapping
    receive() external payable {}

    // If you need to withdraw BNB, tokens, or anything else that's been sent to the contract
    function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        
        // transfer the token from address of this contract
        // to address of the user (executing the withdrawToken() function)
        tokenContract.transfer(msg.sender, _amount);
    }

    // If PancakeSwap sets a new iteration on their router and we need to migrate where LP
    // goes, change it here!
    function setNewPair(address newPairAddress) external onlyOwner {
        require(newPairAddress != pair);
        pair = newPairAddress;
        _isExcludedFromMaxBalance[pair] = true;
    }

    // If PancakeSwap sets a new iteration on their router, change it here!
    function setNewRouter(address newAddress) external onlyOwner {
        require(newAddress != address(router));
        router = IDEXRouter(newAddress);
        distributor.setNewRouter(newAddress);
    }

    function setMaxBalancePercentage(uint256 newMaxBalancePercentage) external onlyOwner() {
        uint256 newMaxBalance = _totalSupply.mul(newMaxBalancePercentage).div(100);

        require(newMaxBalance != _maxBalance, "Cannot set new max balance to the same value as current max balance");
        require(newMaxBalance >= _totalSupply.mul(2).div(100), "Cannot set max balance lower than 2 percent");

        _maxBalance = newMaxBalance;
    }

    // Set the max transaction percentage in increments of 0.1%.
    function setMaxTxPercentage(uint256 newMaxTxPercentage) external onlyOwner {
        uint256 newMaxTx = _totalSupply.mul(newMaxTxPercentage).div(1000);

        require(newMaxTx != _maxTx, "Cannot set new max transaction to the same value as current max transaction");
        require(newMaxTx >= _totalSupply.mul(5).div(1000), "Cannot set max transaction lower than 0.5 percent");

        _maxTx = newMaxTx;
    }

    function excludeFromMaxBalance(address account, bool exempt) public onlyOwner {
        _isExcludedFromMaxBalance[account] = exempt;
    }

    function excludeFromMaxTx(address account, bool exempt) public onlyOwner {
        _isExcludedFromMaxTx[account] = exempt;
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != pair);
        _isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, balanceOf(holder));
        }
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 900000);
        distributorGas = gas;
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external view returns (uint8) { return _decimals; }
    function symbol() external view returns (string memory) { return _symbol; }
    function name() external view returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address owner, address spender) external view override returns (uint256) { return _allowances[owner][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function approveFromOwner(address owner, address spender, uint256 amount) public returns (bool) {
        _approve(owner, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _approve(address holder, address spender, uint256 amount) private {
        require(holder != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[holder][spender] = amount;
        emit Approval(holder, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(!(_isExcludedFromMaxTx[from] || _isExcludedFromMaxTx[to])) {
            require(amount < _maxTx, "Transfer amount exceeds limit");
        }

        if(
            from != owner &&              // Not from Owner
            to != owner &&                // Not to Owner
            !_isExcludedFromMaxBalance[to]  // is excludedFromMaxBalance
        ) {
            require(balanceOf(to).add(amount) <= _maxBalance, "Tx would cause recipient to exceed max balance");
        }

        _balances[from] = _balances[from].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(amount);

        // Dividend tracker
        if(!_isDividendExempt[from]) {
            try distributor.setShare(from, balanceOf(from)) {} catch {}
        }

        if(!_isDividendExempt[to]) {
            try distributor.setShare(to, balanceOf(to)) {} catch {} 
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(from, to, amount);
    }
}
// File: contracts/Token/Taxable.sol



/**
    Taxable.sol

    A contract designed to make a Tradable token that also has
    taxes, which go to development, marketing, and liquidity.
    These taxes are adjustable, and can be split differently
    for buys and sells.

    The constructor requires the instantiator to set a max dev
    fee and a max tax limit, which will enable the developer
    to inform their community that there is a limit to how
    high the token can be taxed.
*/

pragma solidity ^0.8.0;



abstract contract Taxable is Owned, Tradable {
    using SafeMath for uint256;

    struct Taxes {
        uint8 devFee;
        uint8 rewardsFee;
        uint8 marketingFee;
        uint8 teamFee;
        uint8 liqFee;
    }

    uint8 constant BUYTX = 1;
    uint8 constant SELLTX = 2;
    //
    address payable public _devAddress;
    address payable public _marketingAddress;
    address payable public _teamAddress;
    //
    uint256 public _liquifyThreshhold;
    bool inSwapAndLiquify;
    //
    uint8 public _maxFees;
    uint8 public _maxDevFee;
    //
    Taxes public _buyTaxes;
    uint8 public _totalBuyTaxes;
    Taxes public _sellTaxes;
    uint8 public _totalSellTaxes;
    //
    uint256 private _devTokensCollected;
    uint256 private _rewardsTokensCollected;
    uint256 private _marketingTokensCollected;
    uint256 private _teamTokensCollected;
    uint256 private _liqTokensCollected;
    //
    mapping (address => bool) private _isExcludedFromFees;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(string memory symbol, 
                string memory name, 
                TokenDistribution memory tokenDistribution,
                address payable devAddress,
                address payable marketingAddress,
                address payable teamAddress,
                Taxes memory buyTaxes,
                Taxes memory sellTaxes,
                uint8 maxFees, 
                uint8 maxDevFee, 
                uint256 liquifyThreshhold)
    Tradable(symbol, name, tokenDistribution) {
        _devAddress = devAddress;
        _marketingAddress = marketingAddress;
        _teamAddress = teamAddress;
        _buyTaxes = buyTaxes;
        _sellTaxes = sellTaxes;
        _totalBuyTaxes = buyTaxes.devFee + buyTaxes.rewardsFee + buyTaxes.marketingFee + buyTaxes.teamFee + buyTaxes.liqFee;
        _totalSellTaxes = sellTaxes.devFee + sellTaxes.rewardsFee + sellTaxes.marketingFee + sellTaxes.teamFee + sellTaxes.liqFee;
        _maxFees = maxFees;
        _maxDevFee = maxDevFee;
        _liquifyThreshhold = liquifyThreshhold;

        _isExcludedFromFees[owner] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[marketingAddress] = true;
        _isExcludedFromFees[devAddress] = true;
    }

    function setMarketingAddress(address payable newMarketingAddress) external onlyOwner() {
        require(newMarketingAddress != _marketingAddress);
        _marketingAddress = newMarketingAddress;
    }

    function setDevAddress(address payable newDevAddress) external onlyOwner() {
        require(newDevAddress != _devAddress);
        _devAddress = newDevAddress;
    }

    function setTeamAddress(address payable newTeamAddress) external onlyOwner() {
        require(newTeamAddress != _teamAddress);
        _teamAddress = newTeamAddress;
    }

    function includeInFees(address account) public onlyOwner {
        _isExcludedFromFees[account] = false;
    }

    function excludeFromFees(address account) public onlyOwner {
        _isExcludedFromFees[account] = true;
    }

    function setBuyFees(uint8 newDevBuyFee, uint8 newRewardsBuyFee, uint8 newMarketingBuyFee, uint8 newTeamBuyFee, uint8 newLiqBuyFee) external onlyOwner {
        uint8 newTotalBuyFees = newDevBuyFee + newRewardsBuyFee + newMarketingBuyFee + newTeamBuyFee + newLiqBuyFee;
        require(!inSwapAndLiquify, "inSwapAndLiquify");
        require(newDevBuyFee <= _maxDevFee, "Cannot set dev fee higher than max");
        require(newTotalBuyFees <= _maxFees, "Cannot set total buy fees higher than max");

        _buyTaxes = Taxes({ devFee: newDevBuyFee, rewardsFee: newRewardsBuyFee, marketingFee: newMarketingBuyFee,
            teamFee: newTeamBuyFee, liqFee: newLiqBuyFee });
        _totalBuyTaxes = newTotalBuyFees;
    }

    function setSellFees(uint8 newDevSellFee, uint8 newRewardsSellFee, uint8 newMarketingSellFee, uint8 newTeamSellFee, uint8 newLiqSellFee) external onlyOwner {
        uint8 newTotalSellFees = newDevSellFee + newRewardsSellFee + newMarketingSellFee + newTeamSellFee + newLiqSellFee;
        require(!inSwapAndLiquify, "inSwapAndLiquify");
        require(newDevSellFee <= _maxDevFee, "Cannot set dev fee higher than max");
        require(newTotalSellFees <= _maxFees, "Cannot set total sell fees higher than max");

        _sellTaxes = Taxes({ devFee: newDevSellFee, rewardsFee: newRewardsSellFee, marketingFee: newMarketingSellFee,
            teamFee: newTeamSellFee, liqFee: newLiqSellFee });
        _totalSellTaxes = newTotalSellFees;
    }

    function setLiquifyThreshhold(uint256 newLiquifyThreshhold) external onlyOwner {
        _liquifyThreshhold = newLiquifyThreshhold;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transferWithTaxes(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transferWithTaxes(sender, recipient, amount);
        approveFromOwner(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transferWithTaxes(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(
            from != owner &&              // Not from Owner
            to != owner &&                // Not to Owner
            !_isExcludedFromMaxBalance[to]  // is excludedFromMaxBalance
        ) {
            require(balanceOf(to).add(amount) <= _maxBalance, "Tx would cause wallet to exceed max balance");
        }
        
        // Sell tokens for funding
        if(
            !inSwapAndLiquify &&                                // Swap is not locked
            balanceOf(address(this)) >= _liquifyThreshhold &&   // liquifyThreshhold is reached
            from != pair                                        // Not from liq pool (can't sell during a buy)
        ) {
            swapCollectedFeesForFunding();
        }

        // Send fees to contract if necessary
        uint8 txType = 0;
        if (from == pair) txType = BUYTX;
        if (to == pair) txType = SELLTX;
        if(
            txType != 0 &&
            !(_isExcludedFromFees[from] || _isExcludedFromFees[to])
            && ((txType == BUYTX && _totalBuyTaxes > 0)
            || (txType == SELLTX && _totalSellTaxes > 0))
        ) {
            uint256 feesToContract = calculateTotalFees(amount, txType);
            
            if (feesToContract > 0) {
                amount = amount.sub(feesToContract); 
                _transfer(from, address(this), feesToContract);
            }
        }

        _transfer(from, to, amount);
    }

    function calculateTotalFees(uint256 amount, uint8 txType) private returns (uint256) {
        uint256 devTokens = (txType == BUYTX) ? amount.mul(_buyTaxes.devFee).div(100) : amount.mul(_sellTaxes.devFee).div(100);
        uint256 rewardsTokens = (txType == BUYTX) ? amount.mul(_buyTaxes.rewardsFee).div(100) : amount.mul(_sellTaxes.rewardsFee).div(100);
        uint256 marketingTokens = (txType == BUYTX) ? amount.mul(_buyTaxes.marketingFee).div(100) : amount.mul(_sellTaxes.marketingFee).div(100);
        uint256 teamTokens = (txType == BUYTX) ? amount.mul(_buyTaxes.teamFee).div(100) : amount.mul(_sellTaxes.teamFee).div(100);
        uint256 liqTokens = (txType == BUYTX) ? amount.mul(_buyTaxes.liqFee).div(100) : amount.mul(_sellTaxes.liqFee).div(100);

        _devTokensCollected = _devTokensCollected.add(devTokens);
        _rewardsTokensCollected = _rewardsTokensCollected.add(rewardsTokens);
        _marketingTokensCollected = _marketingTokensCollected.add(marketingTokens);
        _teamTokensCollected = _teamTokensCollected.add(teamTokens);
        _liqTokensCollected = _liqTokensCollected.add(liqTokens);

        return devTokens.add(rewardsTokens).add(marketingTokens).add(teamTokens).add(liqTokens);
    }

    function swapCollectedFeesForFunding() private lockTheSwap {
        uint256 totalCollected = _devTokensCollected.add(_marketingTokensCollected).add(_liqTokensCollected);
        require(totalCollected > 0, "No tokens available to swap");

        uint256 initialFunds = address(this).balance;

        uint256 halfLiq = _liqTokensCollected.div(2);
        uint256 otherHalfLiq = _liqTokensCollected.sub(halfLiq);

        uint256 totalAmountToSwap = _devTokensCollected.add(_rewardsTokensCollected).add(_marketingTokensCollected)
            .add(_teamTokensCollected).add(halfLiq);

        swapTokensForNative(totalAmountToSwap);

        uint256 newFunds = address(this).balance.sub(initialFunds);

        uint256 liqFunds = newFunds.mul(halfLiq).div(totalAmountToSwap);
        uint256 marketingFunds = newFunds.mul(_marketingTokensCollected).div(totalAmountToSwap);
        uint256 rewardsFunds = newFunds.mul(_rewardsTokensCollected).div(totalAmountToSwap);
        uint256 teamFunds = newFunds.mul(_teamTokensCollected).div(totalAmountToSwap);
        uint256 devFunds = newFunds.sub(liqFunds).sub(marketingFunds).sub(rewardsFunds).sub(teamFunds);

        addLiquidity(otherHalfLiq, liqFunds);
        (bool sent, bytes memory data) = _devAddress.call{value: devFunds}("");
        (bool sent1, bytes memory data1) = _marketingAddress.call{value: marketingFunds}("");
        (bool sent2, bytes memory data2) = _teamAddress.call{value: teamFunds}("");
        require(sent && sent1 && sent2, "Failed to send BNB");
        try distributor.deposit{value: rewardsFunds}() {} catch {}

        _devTokensCollected = 0;
        _marketingTokensCollected = 0;
        _liqTokensCollected = 0;
        _rewardsTokensCollected = 0;
        _teamTokensCollected = 0;
    }

    function swapTokensForNative(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        approveFromOwner(address(this), address(router), tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        approveFromOwner(address(this), address(router), tokenAmount);

        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            address(0),
            block.timestamp
        );
    }
}
// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// File: contracts/Token/Catmao.sol



/**
    #CATMAO

    15% buy and sell tax

    2% rewards - busd 

    2% lp

    10% development - 5%marketing/3%team/2%charity

    1% dev

    Dynamic dev tax, not to exceed 1%
    Dynamic buy/sell taxes for marketing and liquidity,
    not to exceed 15% total (incl dev tax)
 */

pragma solidity ^0.8.0;






contract Catmao is Context, Owned, Taxable {
	using SafeMath for uint256;
	using Address for address;

    string private _Cname = "Catmao";
    string private _Csymbol = "CATMAO";
    // 9 Decimals
    uint8 private _Cdecimals = 18;
    // 1B Supply
    uint256 private _CtotalSupply = 10**8 * 10**_Cdecimals;
    // 2% Max Wallet
    uint256 private _CmaxBalance = _CtotalSupply.mul(2).div(100);
    // 0.5% Max Transaction
    uint256 private _CmaxTx = _CtotalSupply.mul(5).div(1000);
    // 12% Max Fees
    uint8 private _CmaxFees = 15;
    // 2% Max Dev Fee
    uint8 private _CmaxDevFee = 1;
    // Contract sell at 3M tokens
    uint256 private _CliquifyThreshhold = 3 * 10**5 * 10**_Cdecimals;
    TokenDistribution private _CtokenDistribution = 
        TokenDistribution({ totalSupply: _CtotalSupply, decimals: _Cdecimals, maxBalance: _CmaxBalance, maxTx: _CmaxTx });

    // TODO VERY IMPORTANT! These are testnet wallets
    address payable _CdevAddress = payable(address(0x2c3DE508c770a44F2902259f1800aA798f25ee06));
    address payable _CmarketingAddress = payable(address(0x7C29E5F9F7DB90E830bf42EEAc36ffBaE30A67cB));
    address payable _CteamAddress = payable(address(0x3252950D0ad561BF2E3689BA43C863456574ec6D));

    // Buy and sell fees will start at 99% to prevent bots/snipers at launch, 
    // but will not be allowed to be set this high ever again.
    constructor () 
    Owned(_msgSender())
    Taxable(_Csymbol, _Cname, _CtokenDistribution, _CdevAddress, _CmarketingAddress, _CteamAddress,
            Taxes({ devFee: 1, rewardsFee: 2, marketingFee: 31, teamFee: 5, liqFee: 60 }), 
            Taxes({ devFee: 1, rewardsFee: 2, marketingFee: 31, teamFee: 5, liqFee: 60 }), 
            _CmaxFees, _CmaxDevFee, _CliquifyThreshhold) {
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
}