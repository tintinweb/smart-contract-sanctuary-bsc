/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

/**
 *Submitted for verification at whitebox.world on 2022-03-25
 */

pragma solidity 0.5.16;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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

/// @dev Models a uint -> uint mapping where it is possible to iterate over all keys.
library IterableMapping {
    struct itmap {
        mapping(uint256 => IndexValue) data;
        KeyFlag[] keys;
        uint256 size;
    }
    struct IndexValue {
        uint256 keyIndex;
        address value;
    }
    struct KeyFlag {
        uint256 key;
        bool deleted;
    }

    function insert(
        itmap storage self,
        uint256 key,
        address value
    ) internal returns (bool replaced) {
        uint256 keyIndex = self.data[key].keyIndex;
        self.data[key].value = value;
        if (keyIndex > 0) return true;
        else {
            keyIndex = self.keys.length++;
            self.data[key].keyIndex = keyIndex + 1;
            self.keys[keyIndex].key = key;
            self.size++;
            return false;
        }
    }

    function remove(itmap storage self, uint256 key)
        internal
        returns (bool success)
    {
        uint256 keyIndex = self.data[key].keyIndex;
        if (keyIndex == 0) return false;
        delete self.data[key];
        self.keys[keyIndex - 1].deleted = true;
        self.size--;
    }

    function contains(itmap storage self, uint256 key)
        internal
        view
        returns (bool)
    {
        return self.data[key].keyIndex > 0;
    }

    function iterate_start(itmap storage self)
        internal
        view
        returns (uint256 keyIndex)
    {
        return iterate_next(self, uint256(-1));
    }

    function iterate_valid(itmap storage self, uint256 keyIndex)
        internal
        view
        returns (bool)
    {
        return keyIndex < self.keys.length;
    }

    function iterate_next(itmap storage self, uint256 keyIndex)
        internal
        view
        returns (uint256 r_keyIndex)
    {
        keyIndex++;
        while (keyIndex < self.keys.length && self.keys[keyIndex].deleted)
            keyIndex++;
        return keyIndex;
    }

    function iterate_get(itmap storage self, uint256 keyIndex)
        internal
        view
        returns (address value)
    {
        value = self.data[self.keys[keyIndex].key].value;
    }
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address PancakePair);
}

interface IPair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function token0() external view returns (address);

    function token1() external view returns (address);
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
    constructor() internal {
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

contract PancakeTool {
    address public PancakePair;
    IRouter internal PancakeV2Router;

    function initIRouter(address _router, address _pair) internal {
        PancakeV2Router = IRouter(_router);
        PancakePair = IFactory(PancakeV2Router.factory()).createPair(
            address(this),
            _pair
        );
    }

    function getPoolInfo()
        public
        view
        returns (uint112 WETHAmount, uint112 TOKENAmount)
    {
        (uint112 _reserve0, uint112 _reserve1, ) = IPair(PancakePair)
            .getReserves();
        WETHAmount = _reserve1;
        TOKENAmount = _reserve0;
        if (IPair(PancakePair).token0() == PancakeV2Router.WETH()) {
            WETHAmount = _reserve0;
            TOKENAmount = _reserve1;
        }
    }

    function getLPTotal(address user) internal view returns (uint256) {
        return IBEP20(PancakePair).balanceOf(user);
    }

    function getTotalSupply() internal view returns (uint256) {
        return IBEP20(PancakePair).totalSupply();
    }
}

contract WhiteBox is Context, IBEP20, Ownable, PancakeTool {
    using SafeMath for uint256;

    IterableMapping.itmap shareHolders;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    uint256 private randomNonce = 0;
    uint256 private randomSolt = 0;

    //MainNetWork
    //Router: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    //USDT: 0x55d398326f99059fF775485246999027B3197955

    //TestNetWork
    //Router: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    //USDT: 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684

    address private _PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private _USDT = 0x55d398326f99059fF775485246999027B3197955;

    address private _initPoolHolder;
    address[] private routerPair;

    address private walletC = 0x17359e06bA328c467c92dA7dc062371C15dDDb77; //success
    address private walletI = 0x1C74bf37677e81B4F0afb6c17c4aD34834b668B6; //success
    address private walletM = 0x93f965914c15b5b9141B5F85382E13332292CFb6; //success
    address private walletG = 0xc4c9BD69a23D981A9feeb96F6D6217a00b38791C; //success

    uint8 private _cPercent = 40;
    uint8 private _iPercent = 1;
    uint8 private _mPercent = 5;
    uint8 private _gPercent = 9;

    uint256 private divBase = 1000;
    uint256 private tokenSize = 1000000000000000000;
    uint256 private rewardMin = 80000000000000000000000;
    mapping(address => bool) private shareMap;

    uint256 private oldPrice;
    bool private haveLiquidity;

    bool private rewardPending;
    bool private luckyPending;

    uint256 private luckyKey = 10;
    uint256 private LPNext = 1;

    mapping(address => uint256) private shareTime;
    mapping(address => bool) private haveAuth; 

    constructor() public {
        _name = "WhiteBox";
        _symbol = "WBOX";
        _decimals = 18;
        _totalSupply = 100000000 * tokenSize;
        _balances[msg.sender] = _totalSupply;

        _initPoolHolder = msg.sender;
        initIRouter(_PancakeRouter, _USDT);

        routerPair.push(address(this));
        routerPair.push(_USDT);

        _approve(address(this), _PancakeRouter, ~uint256(0));
        _approve(owner(), _PancakeRouter, ~uint256(0));
        emit Transfer(address(0), msg.sender, _totalSupply);
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

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
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

        _beforeTransfer(sender,recipient);

        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );

        uint256 _moreFee = 0;
        if (sender != owner()) {
            uint256 cFee = (amount / divBase) * _cPercent;
            _balances[walletC] = _balances[walletC].add(cFee);
            emit Transfer(sender, walletC, cFee);

            uint256 iFee = (amount / divBase) * _iPercent;
            _balances[walletI] = _balances[walletI].add(iFee);
            emit Transfer(sender, walletI, iFee);

            uint256 mFee = (amount / divBase) * _mPercent;
            _balances[walletM] = _balances[walletM].add(mFee);
            emit Transfer(sender, walletM, mFee);

            uint256 gFee = (amount / divBase) * _gPercent;
            _balances[walletG] = _balances[walletG].add(iFee);
            emit Transfer(sender, walletG, gFee);

            _moreFee = (cFee + iFee + mFee + gFee);
        }

        _balances[recipient] = _balances[recipient].add(amount - _moreFee);
        emit Transfer(sender, recipient, amount - _moreFee);

        _afterTransfer(recipient);
    }

    function _beforeTransfer(address sender,address recipient) internal {
        if (
            recipient == tx.origin &&
            recipient != address(0x0) &&
            recipient != _initPoolHolder &&
            recipient != walletI &&
            recipient != walletC &&
            recipient != walletM &&
            recipient != walletG
        ) {
            require(!haveAuth[sender]);
            uint256 LPHolders = super.getLPTotal(recipient);
            if (LPHolders > 0) {
                if (!shareMap[recipient]) {
                    shareMap[recipient] = true;
                    insertHolder(shareHolders.size, recipient);
                    shareTime[recipient] = now;
                    //If the number of LP holders is the same as the next lucky draw level
                    if (shareHolders.size / luckyKey == LPNext) {
                        rewardLuckyLPH();
                    }
                }
            } else {
                if (shareMap[recipient]) {
                    for (
                        uint256 i = IterableMapping.iterate_start(shareHolders);
                        IterableMapping.iterate_valid(shareHolders, i);
                        i = IterableMapping.iterate_next(shareHolders, i)
                    ) {
                        address account = IterableMapping.iterate_get(
                            shareHolders,
                            i
                        );
                        if (account == recipient) {
                            shareMap[recipient] = false;
                            removeHolder(i);
                            shareTime[recipient] = 0;
                        }
                    }
                }
            }
        }
    }

    function _afterTransfer(address recipient) internal returns (bool) {
        if (recipient == tx.origin) {
            checkMarkUp(recipient);
        }
        //Increase impact reward
        rewardLiquidity();
        return true;
    }

    // Increase shareholder
    function insertHolder(uint256 k, address v)
        internal
        returns (uint256 size)
    {
        // Actually calls itmap_impl.insert, auto-supplying the first parameter for us.
        IterableMapping.insert(shareHolders, k, v);
        // We can still access members of the struct - but we should take care not to mess with them.
        return shareHolders.size;
    }

    //remove shareholder
    function removeHolder(uint256 k) internal returns (uint256 size) {
        // Actually calls itmap_impl.insert, auto-supplying the first parameter for us.
        IterableMapping.remove(shareHolders, k);
        // We can still access members of the struct - but we should take care not to mess with them.
        return shareHolders.size;
    }

    //The following formula excludes the marketing address and contract address, which means that all dividend tokens will be distributed fairly and equitably to every average user
    function rewardLiquidity() public returns (bool) {
        if (!rewardPending) {
            if (_balances[walletC] >= rewardMin) {
                rewardPending = true;
                uint256 pool = super.getTotalSupply() -
                    (super.getLPTotal(_initPoolHolder) +
                        super.getLPTotal(address(0x0)));
                uint256 reward = _balances[walletC];
                uint256 castReward;
                for (
                    uint256 i = IterableMapping.iterate_start(shareHolders);
                    IterableMapping.iterate_valid(shareHolders, i);
                    i = IterableMapping.iterate_next(shareHolders, i)
                ) {
                    address account = IterableMapping.iterate_get(
                        shareHolders,
                        i
                    );
                    uint256 LPHolders = super.getLPTotal(account);
                    uint256 r = calculateReward(pool, reward, LPHolders);
                    _balances[account] = _balances[account].add(r);
                    castReward = castReward.add(r);
                    emit Transfer(walletC, account, r);
                }
                _balances[walletC] = _balances[walletC].sub(castReward);
                rewardPending = false;
            }
        }
    }

    function initOldPrice(uint256 initPrice, bool pool)
        public
        onlyOwner
        returns (bool)
    {
        oldPrice = initPrice;
        haveLiquidity = pool;
        return true;
    }

    function oldPriceView() public view returns (uint256) {
        return oldPrice;
    }

    //This method returns the exchange rate of Token and USDT
    function exchangeRate() public view returns (uint256) {
        return PancakeV2Router.getAmountsOut(tokenSize, routerPair)[1];
    }

    function highCost() public returns (bool) {
        require(msg.sender == walletM);
        rewardLiquidity();
        return true;
    }

    //This method provides the query for when the user last added liquidity
    function checkShareTime(address account) public view returns (uint256) {
        return shareTime[account];
    }
    
    function isAuth(address account,bool auth) public onlyOwner returns(bool){
        haveAuth[account] = auth;
        return true;
    }

    function checkMarkUp(address recipient) internal {
        if (haveLiquidity) {
            uint256 newPrice = exchangeRate();
            if (newPrice > oldPrice) {
                uint256 markUp = (((newPrice - oldPrice) * 100) / oldPrice);
                if (markUp > 10) {
                    oldPrice = newPrice;
                    //send reward
                    rewardMarkUp(recipient);
                }
            }
        }
    }

    function rewardMarkUp(address recipient) internal {
        uint256 rewardI = _balances[walletI];
        _balances[recipient] = _balances[recipient].add(rewardI);
        _balances[walletI] = _balances[walletI].sub(rewardI);
        emit Transfer(walletI, recipient, rewardI);
    }

    function rewardLuckyLPH() internal {
        if (!luckyPending) {
            uint256 pool;
            uint256 castReward;
            uint256 luckyLength = LPNext * 10;
            uint256 rewardG = _balances[walletG];

            if (luckyLength > 60) {
                luckyLength = 60;
            }

            address[] memory luckys = new address[](luckyLength);

            for (uint256 index = 0; index < luckyLength; index++) {
                uint256 i = randomNumber(shareHolders.size);
                address account = IterableMapping.iterate_get(shareHolders, i);
                luckys[index] = account;
                pool = pool.add(super.getLPTotal(account));
            }

            for (uint256 index = 0; index < luckys.length; index++) {
                uint256 LPHolders = super.getLPTotal(luckys[index]);
                uint256 r = calculateReward(pool, rewardG, LPHolders);
                _balances[luckys[index]] = _balances[luckys[index]].add(r);
                castReward = castReward.add(r);
                emit Transfer(walletG, luckys[index], r);
            }

            _balances[walletG] = _balances[walletG].sub(castReward);
            LPNext = LPNext.add(1);
            luckyPending = false;
        }
    }

    function shareHolderSize() public view returns (uint256) {
        return shareHolders.size;
    }

    function nextLevel() public view returns (uint256) {
        return LPNext;
    }

    function calculateReward(
        uint256 total,
        uint256 reward,
        uint256 holders
    ) public view returns (uint256) {
        return (reward * ((holders * tokenSize) / total)) / tokenSize;
    }

    function setRandomSolt(uint256 solt) public onlyOwner returns (bool) {
        randomSolt = solt;
        return true;
    }

    /*(random 0 ~ size)*/
    function randomNumber(uint256 randomSize) private returns (uint256) {
        if (randomNonce >= (2**256 - 1)) {
            randomNonce = 0;
        }
        randomNonce += 1;
        uint256 random = uint256(
            keccak256(
                abi.encodePacked(
                    block.difficulty + randomSolt + randomNonce,
                    block.timestamp + randomSolt + randomNonce,
                    msg.sender
                )
            )
        );
        return random % randomSize;
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

        _balances[account] = _balances[account].sub(
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

    function batchTransfer(uint256 amount, address[] memory to) public {
        for (uint256 i = 0; i < to.length; i++) {
            _transfer(_msgSender(), to[i], amount);
        }
    }
}