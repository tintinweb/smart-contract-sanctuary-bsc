/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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


interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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


// File: contracts/Billion_cash.sol



pragma solidity >=0.4.22 <0.9.0;



contract BillionCash is Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) public _BCTokenBalances;
    mapping(address => mapping(address => uint256)) public _allowed;
    string constant tokenName = "Billion Cash";
    string constant tokenSymbol = "BC";
    uint8 constant tokenDecimals = 18;
    uint256 _totalSupply = 50000 * 10**uint256(tokenDecimals);
    uint256 _burnSupply = 40000 * 10**uint256(tokenDecimals);
    address marketingwallet;
    address developmentWallet;
    address adminWallet;
    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 public constant MARKETING_FEE_PERCENT = 30;
    uint256 public constant DEVELOPMENT_FEE_PERCENT = 10;
    uint256 public constant LP_PERCENT = 100;

    mapping (address => bool) public isTransferFeeExempt; 

    IDEXRouter public uniswapV2Router;
    address pancakeV2BNBPair;
    address[] public pairs;


    uint256 private numTokensSellToAddToLiquidity = 10 * 10**18;

    // BNB mainnet: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    // BNB testnet: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;


    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event SwapBackFailed(string message);
    event BuybackTransfer(bool status);

    event Transfer(address indexed from, address indexed to, uint256 value);
    

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(
        // address _adminWallet,
        // address _developmentWallet,
        // address _marketingWallet
    ) {
        address _adminWallet = 0x2bf8429B81947D18Fc2e8A4D5E3eB3c3e5400183;
        address _developmentWallet = 0x30580573240cf9530424DbFCf8F9687f218223eC;
        address _marketingwallet = 0x30580573240cf9530424DbFCf8F9687f218223eC;
        adminWallet = _adminWallet;
        developmentWallet = _developmentWallet;
        marketingwallet = _marketingwallet;
        _mint(adminWallet, _totalSupply.sub(_burnSupply));
        _mint(address(0), _burnSupply);
        transferOwnership(adminWallet);
        isTransferFeeExempt[adminWallet] = true;
        isTransferFeeExempt[developmentWallet] = true;

        // CHANGE BEFORE DEPLOYING
        // Router mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // Router testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        address dexRouter_ = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        uniswapV2Router = IDEXRouter(dexRouter_);
        
        pancakeV2BNBPair = IDEXFactory(uniswapV2Router.factory()).createPair(WBNB, address(this));
        _allowed[address(this)][address(uniswapV2Router)] = ~uint256(0);
        pairs.push(pancakeV2BNBPair);

    }

    function name() public pure returns (string memory) {
        return tokenName;
    }

    function symbol() public pure returns (string memory) {
        return tokenSymbol;
    }

    function decimals() public pure returns (uint8) {
        return tokenDecimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _BCTokenBalances[owner];
    }
    function _transfer(address from, address to, uint256 value) private{
        require(value <= _BCTokenBalances[from]);
        // require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        if (isTransferFeeExempt[from]){
            _generalTransfer(from, to, value);
        }
        else{

            _BCTokenBalances[from] = _BCTokenBalances[from].sub(value);

            uint256 BCTokenForMarketingFee = value.mul(MARKETING_FEE_PERCENT).div(PERCENTS_DIVIDER);
            uint256 BCTokenForDevelopmentFee = value.mul(DEVELOPMENT_FEE_PERCENT).div(PERCENTS_DIVIDER);
            uint256 BCTokenForLPFee = value.mul(LP_PERCENT).div(PERCENTS_DIVIDER);
            uint256 tokensToTransfer = value
                .sub(BCTokenForMarketingFee)
                .sub(BCTokenForDevelopmentFee)
                .sub(BCTokenForLPFee);

            _BCTokenBalances[to] = _BCTokenBalances[to].add(tokensToTransfer);
            _BCTokenBalances[developmentWallet] = _BCTokenBalances[developmentWallet].add(
                BCTokenForDevelopmentFee
            );
            _BCTokenBalances[marketingwallet] = _BCTokenBalances[marketingwallet].add(
                BCTokenForMarketingFee
            );
            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
            if (
                overMinTokenBalance &&
                !inSwapAndLiquify &&
                from != pancakeV2BNBPair &&
                swapAndLiquifyEnabled
            ){
                emit SwapAndLiquify(0, BCTokenForLPFee, _BCTokenBalances[address(this)]);
                contractTokenBalance = numTokensSellToAddToLiquidity;
                swapAndLiquify(contractTokenBalance);
                emit SwapAndLiquify(0, BCTokenForLPFee, _BCTokenBalances[address(this)]);
                _BCTokenBalances[address(this)] = _BCTokenBalances[address(this)].add(BCTokenForLPFee);
                emit Transfer(from, pancakeV2BNBPair, BCTokenForLPFee);  
            }
            else{
                _BCTokenBalances[address(this)] = _BCTokenBalances[address(this)].add(
                    BCTokenForLPFee
                );
                emit Transfer(from, address(this), BCTokenForLPFee);  
            }
            emit Transfer(msg.sender, developmentWallet, BCTokenForDevelopmentFee);
            emit Transfer(msg.sender, marketingwallet, BCTokenForMarketingFee);
        }
    }
    function transfer(address to, uint256 value) public returns (bool) {
        emit Transfer(msg.sender, to, value);
        _transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowed[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _generalTransfer(address from, address to, uint256 value) internal returns (bool) {
        _BCTokenBalances[from] = _BCTokenBalances[from].sub(value);
        _BCTokenBalances[to] = _BCTokenBalances[to].add(value);
        // _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return true;
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        try uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        ){
            emit AutoLiquify(tokenAmount, ethAmount);
        } catch {
            emit AutoLiquify(0, 0);
        }
    }

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        emit SwapAndLiquify(0, 0, contractTokenBalance);
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        // path[1] = uniswapV2Router.WETH();
        path[1] = WBNB;

        emit SwapAndLiquify(tokenAmount, tokenAmount, 0);
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        emit SwapAndLiquify(tokenAmount, tokenAmount, 1);
        // make the swap
        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        ){
        } catch Error(string memory e) {
            emit SwapBackFailed(string(abi.encodePacked("SwapBack failed with error ", e)));
        } catch {
            emit SwapBackFailed("SwapBack failed without an error message from pancakeSwap");
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool){
        _transfer(from, to, value);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (
            _allowed[msg.sender][spender].add(addedValue)
        );
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (
            _allowed[msg.sender][spender].sub(subtractedValue)
        );
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(amount != 0);
        _BCTokenBalances[account] = _BCTokenBalances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function setDevelopmentAddress(address  _developmentAddress) external onlyOwner {
        developmentWallet = _developmentAddress;
    }
    function setMarketAddress(address  _marketAddress) external onlyOwner {
        marketingwallet = _marketAddress;
    }
    function setIsTransferFeeExempt(address holder, bool exempt) external onlyOwner{
        isTransferFeeExempt[holder] = exempt;
    }
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
}