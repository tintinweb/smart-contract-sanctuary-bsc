/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the max amount of tokens.
     */
    function maxSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}



interface IDEXFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IDEXPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IDEXRouter {
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
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
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

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
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
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
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
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TestToken4 is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    struct Account {
        uint256 balance;
        uint256 liqBalance;
        uint256 lastDividendPoints;
        uint256 lastLiqDividendPoints;
    }


    mapping(address => Account) private _accounts;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private constant _maxSupply = 5000000000 * 1e18;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    address private _pcsPair;
    uint8 private _buyFee = 0;
    uint8 private _sellFee = 0;
    mapping(address => bool) private _isExcludedFromFee;
    IDEXRouter public _router;
    uint256 _availableBNB = 0;

    uint256 constant pointMultiplier = 10e18;
    uint256 totalDividendPoints;
    uint256 totalLiqDividendPoints;
    // uint256 unclaimedDividends;
    // uint256 unclaimedLiqDividends;
    address _dividendAccount;
    mapping(address => bool) private _isExcludedFromDividends;
    uint256 _totalAmountExcludedFromDividends = 0;
    uint256 _totalLiq = 1; //avoid division by zero

    constructor(address router, address dividendAccount) {
        _name = "Test Token4";
        _symbol = "TT4";
        _decimals = 18;
        _router = IDEXRouter(router);
        _dividendAccount = dividendAccount;
        _mint(address(this), 2500000000 * 1e18);
        _mint(_msgSender(),1000000000 * 1e18);

        addToDividendExclusion(dividendAccount);
        addToDividendExclusion(router);
        addToDividendExclusion(address(this));
        addToDividendExclusion(_msgSender());
        excludeFromFee(address(this));
        excludeFromFee(_msgSender());
    }

    receive() external payable {}

    /**
     * @dev Set exchange pair address.
     */
    function setPairAddress(address pairAddress)
        public
        onlyOwner
        returns (bool)
    {
        _pcsPair = pairAddress;
        return true;
    }

    /**
     * @dev Set exchange fees.
     */
    function setFees(uint8 buyFee, uint8 sellFee)
        public
        onlyOwner
        returns (bool)
    {
        _buyFee = buyFee;
        _sellFee = sellFee;
        return true;
    }

    /**
     * @dev Exclude wallet from fees.
     */
    function excludeFromFee(address targetWallet)
        public
        onlyOwner
        returns (bool)
    {
        _isExcludedFromFee[targetWallet] = true;
        return true;
    }



    function disburse(uint256 amount) external returns (bool) {
        if(_msgSender() != _dividendAccount){
            _updateAccountDividends(_msgSender());
            _accounts[_msgSender()].balance = _accounts[_msgSender()].balance.sub(amount, "Insufficient balance.");
            _accounts[_dividendAccount].balance = _accounts[_dividendAccount].balance.add(amount);
            if(!_isExcludedFromDividends[_msgSender()]) { _totalAmountExcludedFromDividends += amount; }
        }

        _disburse(amount);
        return true;
    }


    function _disburse(uint256 amount) internal {
        uint256 dividendAmount = amount / 2;
        uint256 liqDividendAmount = amount - dividendAmount;
        totalDividendPoints += ((dividendAmount * pointMultiplier) / (_totalSupply - _totalAmountExcludedFromDividends));
        totalLiqDividendPoints +=  ((liqDividendAmount * pointMultiplier) / _totalLiq);
    }


    function _dividendsOwing(address account) internal view returns (uint256 dividendsOwing, uint256 liqDividendsOwing) {
        if(!_isExcludedFromDividends[account]){
            dividendsOwing =  (_accounts[account].balance * (totalDividendPoints - _accounts[account].lastDividendPoints)) / pointMultiplier;
        }else {
            dividendsOwing = 0;
        }
        liqDividendsOwing = ( _accounts[account].liqBalance * (totalLiqDividendPoints - _accounts[account].lastLiqDividendPoints)) / pointMultiplier;
    }


    function _updateAccountDividends(address account) internal {
        (uint256 dividendsOwing, uint256 liqDividendsOwing) = _dividendsOwing(account);
        uint256 totalDividendsOwing = dividendsOwing + liqDividendsOwing;
        if (totalDividendsOwing > 0) {
            if(dividendsOwing > 0) {
                _accounts[account].lastDividendPoints = totalDividendPoints;
            }
            if(liqDividendsOwing > 0) {
                _accounts[account].lastLiqDividendPoints = totalLiqDividendPoints;
                if(_isExcludedFromDividends[account]) {
                    _totalAmountExcludedFromDividends += liqDividendsOwing;
                }
            }
            _totalAmountExcludedFromDividends -= totalDividendsOwing; //Because of _dividendAccount
            _accounts[_dividendAccount].balance -= totalDividendsOwing;
            _accounts[account].balance += totalDividendsOwing;
        }
    }


    // function setFirst100LiqProviders(address[] TargetAccounts) external onlyOwner returns (bool){

    // }


    function addToDividendExclusion(address account) public onlyOwner returns (bool) {
        _updateAccountDividends(account);
        _isExcludedFromDividends[account] = true;
        _totalAmountExcludedFromDividends += _accounts[account].balance;
        return true;
    }

    function removeFromDividendExclusion(address account) external onlyOwner returns (bool){
        _accounts[account].lastDividendPoints = totalDividendPoints;
        _isExcludedFromDividends[account] = false;
        _totalAmountExcludedFromDividends -= _accounts[account].balance;
        return true;
    }


    function _getPair() internal view returns(address pairAddress) {
        address factory = _router.factory();
        address WETH = _router.WETH();
        pairAddress = IDEXFactory(factory).getPair(address(this), WETH);
    }

    function _getReserves() internal view returns(uint TokenReserve, uint BNBReserve) {
        (uint reserve0, uint reserve1,) = IDEXPair(_pcsPair).getReserves();
        (TokenReserve, BNBReserve) = address(this) < _router.WETH() ? (reserve0 , reserve1) : (reserve1, reserve0);
    }

    function addInitialLiquidity(uint256 amountTokenDesired)external payable onlyOwner returns(uint256 amountToken,uint256 amountETH,uint256 liquidity) {
        _approve(address(this), address(_router), amountTokenDesired);
        (amountToken,amountETH,liquidity) = _router.addLiquidityETH{value:msg.value}(address(this), amountTokenDesired, 0, 0, address(this), block.timestamp);
        _pcsPair = _getPair();
        addToDividendExclusion(_pcsPair);
        IBEP20(_pcsPair).transfer(msg.sender, liquidity);

    }

    function addLiquidity(bool keepLiquidityInContract)external payable returns(uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        uint256 sentETH = msg.value / 2;
        _availableBNB = msg.value - sentETH;
        //Use reserves to determine amount of tokens to match with BNB supplied
        (uint TokenReserve, uint ETHReserve) = _getReserves();
        uint LiquidityTokens = (sentETH * TokenReserve) / ETHReserve;
        _approve(address(this), address(_router), LiquidityTokens);
        (amountToken, amountETH, liquidity) = _router.addLiquidityETH{ value: sentETH} (address(this), LiquidityTokens, 0, 0, address(this), block.timestamp);
        //refunding dust
        if(sentETH > amountETH){
            (bool success, ) = address(_msgSender()).call{value: sentETH - amountETH}(new bytes(0));
            require(success, "BNB RELAY FAILED");
        }
        //Keep lp tokens in contract or send them to provider
        if(keepLiquidityInContract) {
            _updateAccountDividends(_msgSender());
            _accounts[_msgSender()].liqBalance = _accounts[_msgSender()].liqBalance.add(liquidity);
            _totalLiq += liquidity;
        } else {
            IBEP20(_pcsPair).transfer(_msgSender(), liquidity);
        }

        // uint256 sentETH = msg.value;
        // //Use reserves to determine amount of tokens to match with BNB supplied
        // (uint TokenReserve, uint ETHReserve) = _getReserves();
        // uint LiquidityTokens = (sentETH * TokenReserve) / ETHReserve;
        // _approve(address(this), address(_router), LiquidityTokens);
        // (amountToken,amountETH,liquidity) = _router.addLiquidityETH{value:sentETH}(address(this), LiquidityTokens, 0, 0, address(this), block.timestamp);
        // //refunding dust
        // if(sentETH > amountETH){
        //     (bool success, ) = address(_msgSender()).call{value: sentETH - amountETH}(new bytes(0));
        //     require(success, 'BNB RELAY FAILED');
        // }
        // //Send half of liquidity tokens to liquidity provider and burn the rest
        // uint256 providerLiquidity = liquidity / 2;
        // uint256 burnLiquidity = liquidity - providerLiquidity;

        // IBEP20 pairContract = IBEP20(_pcsPair);
        // pairContract.transfer(address(0), burnLiquidity);
        // if(!keepLiquidityInContract) {
        //     pairContract.transfer(_msgSender(), providerLiquidity);
        // } else {
        //     _updateAccountDividends(_msgSender());
        //     _accounts[_msgSender()].liqBalance = _accounts[_msgSender()].liqBalance.add(providerLiquidity);
        //     _totalLiq += providerLiquidity;
        // }
    }

    function swapAvailableBNB() external returns(bool) {
        require(_availableBNB > 0);
        address[] memory path = new address[](2);
        path[0] = _router.WETH();
        path[1] = address(this);
        _router.swapExactETHForTokensSupportingFeeOnTransferTokens { value: _availableBNB } ( 0, path, address(this), block.timestamp );
        _availableBNB = 0;
        return true;
    }

    function depositLiquidity(uint256 amount)external returns(uint256) {
        _updateAccountDividends(_msgSender());
        IBEP20(_pcsPair).transferFrom(_msgSender(), address(this), amount);
        _accounts[_msgSender()].liqBalance = _accounts[_msgSender()].liqBalance.add(amount);
        _totalLiq += amount;
        return amount;
    }

    function withdrawLiquidity(uint256 amount)external returns(uint256) {
        _updateAccountDividends(_msgSender());
        IBEP20(_pcsPair).transfer(_msgSender(), amount); 
        _accounts[_msgSender()].liqBalance = _accounts[_msgSender()].liqBalance.sub(amount, "Withdrawal exceeds account balance.");
        _totalLiq -= amount;
        return amount;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function liqTotalSupply() external view returns (uint256) {
        return _totalLiq;
    }

    /**
     * @dev See {BEP20-maxSupply}.
     */
    function maxSupply() external pure returns (uint256) {
        return _maxSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
        (uint256 dividendsOwing, uint256 liqDividendsOwing) = _dividendsOwing(account);
        return _accounts[account].balance + dividendsOwing + liqDividendsOwing;
    }

    function liqBalanceOf(address account) external view returns (uint256) {
        return _accounts[account].liqBalance;
    }


    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Burn `amount` tokens and decreasing the total supply.
     */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */


    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        uint256 currentFee = 0;
        if (sender == _pcsPair && _buyFee > 0 && !_isExcludedFromFee[recipient]) currentFee = _buyFee;
        else if (recipient == _pcsPair && _sellFee > 0 && !_isExcludedFromFee[sender]) currentFee = _sellFee;

        uint256 dividendAmount = 0;
        uint256 tAmount = 0;
        if (currentFee > 0) {
            dividendAmount = (amount * currentFee) / 100;
            tAmount = amount.sub(dividendAmount);
        } else {
            tAmount = amount;
        }

        _updateAccountDividends(sender);
        _updateAccountDividends(recipient);

        _accounts[sender].balance = _accounts[sender].balance.sub(amount,"BEP20: transfer amount exceeds balance");
        if(_isExcludedFromDividends[sender]){ _totalAmountExcludedFromDividends -= amount; }
        _accounts[recipient].balance = _accounts[recipient].balance.add(tAmount);
        if(_isExcludedFromDividends[recipient]){ _totalAmountExcludedFromDividends += amount; }

        if (dividendAmount > 0) {
            // _updateAccountDividends(_dividendAccount);
            // if(_isExcludedFromDividends[_dividendAccount]) _totalAmountExcludedFromDividends += dividendAmount;
            _totalAmountExcludedFromDividends += dividendAmount;
            _accounts[_dividendAccount].balance = _accounts[_dividendAccount].balance.add(dividendAmount);
            _disburse(dividendAmount);
            // _swapAvailableBNB();
        }

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal returns (bool) {
        require(account != address(0), "BEP20: mint to the zero address");
        if (amount.add(_totalSupply) > _maxSupply) {
            return false;
        }

        _totalSupply = _totalSupply.add(amount);
        _updateAccountDividends(account);
        if(_isExcludedFromDividends[account]) { _totalAmountExcludedFromDividends += amount; }
        _accounts[account].balance = _accounts[account].balance.add(amount);
        emit Transfer(address(0), account, amount);
        return true;
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _updateAccountDividends(account);
        if(_isExcludedFromDividends[account]) { _totalAmountExcludedFromDividends -= amount; }
        _accounts[account].balance = _accounts[account].balance.sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(
                amount,
                "BEP20: burn amount exceeds allowance"
            )
        );
    }
}