// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IVestingFactory {
    function getVestingAddress(address beneficiary)
    external
    view
    returns (address vestingAddress);

    function deployVesting(
        address beneficiary,
        uint256 start,
        uint256 cliffDuration,
        uint256 duration,
        bool revocable,
        uint256 amount,
        IERC20 token,
        bytes32 salt,
        address owner,
        address tokenHolder
    ) external returns (address vestingAddress);
}

contract DemyToken is ERC20, Ownable {
    using SafeMath for uint256;
    struct LockedBalance {
        address _address;
        uint256 _cliff;
        uint256 _start;
        uint256 _duration;
        uint256 _balance;
        uint256 _initDate;
    }

    mapping(uint8 => LockedBalance) public lockedAccounts;
    mapping(address => uint256) private _released;

    address public immutable liquidityAddress;
    address public immutable ecosystemAddress;
    address public immutable partnershipsAddress;
    address public immutable advisorsAddress;
    address public immutable teamAddress;
    uint256 public immutable maxSupply;
    uint256 private constant PERCENTAGE_FOR_SEED_MAX = 310;
    uint256 private constant PERCENTAGE_FOR_PRESALE_MAX = 640;
    uint256 private constant PERCENTAGE_FOR_LP = 630;
    uint256 private constant PERCENTAGE_FOR_ECOSYSTEM = 600;
    uint256 private constant PERCENTAGE_FOR_PARTNERSHIPS = 900;
    uint256 private constant PERCENTAGE_FOR_ADVISORS = 200;
    uint256 private constant PERCENTAGE_FOR_TEAM = 960;
    uint256 private constant TGE_FOR_PRESALE = 2000;
    uint256 private constant LOCKED_FOR_PRESALE = 8000;
    uint256 private constant TGE_FOR_PARTNERSHIPS = 1000;
    uint256 private constant TGE_FOR_ADVISORS = 1000;
    uint256 private constant PERCENTS_DIVIDER = 10000;
    uint256 public constant PRESALE_RATE = 38000;
    uint256 public constant PRESALE_MIN_AMOUNT = 0.5 ether;
    uint256 public constant PRESALE_MAX_AMOUNT = 2.5 ether;
    uint256 public constant PRESALE_START = 1648648000;
    uint256 public constant PRESALE_CLOSE = 1648735200;
    uint256 public constant PINKSALE_AMOUNT = 9600000 ether;
    uint256 private preSaleAvailableAmount;
    uint256 private seederAvailableAmount;
    uint256 private liquidityAvailableAmount;
    address public immutable vestingFactoryAddress;
    address public stakeContractAddress;
    bool public seedersInitialized = false;

    event TokensReleased(address beneficiary, uint256 amount);
    event TokensPresold(address buyer, uint256 amount);
    event MintedForLiquidity(uint256 amount);
    modifier onlyStakeContract() {
        require(
            msg.sender == stakeContractAddress,
            "Only stake contract can call this"
        );
        _;
    }

    constructor(
        uint256 _maxSupply,
        address _liquidityAddress,
        address _ecosystemAddress,
        address _partnershipsAddress,
        address _advisorsAddress,
        address _teamAddress,
        address _vestingFactoryAddress
    ) ERC20("Demy Games Token", "DEMY") {
        maxSupply = _maxSupply;
        preSaleAvailableAmount = maxSupply.div(PERCENTS_DIVIDER).mul(
            PERCENTAGE_FOR_PRESALE_MAX
        );
        seederAvailableAmount = maxSupply.div(PERCENTS_DIVIDER).mul(
            PERCENTAGE_FOR_SEED_MAX
        );
        liquidityAvailableAmount = maxSupply.div(PERCENTS_DIVIDER).mul(
            PERCENTAGE_FOR_LP
        );
        liquidityAddress = _liquidityAddress;
        ecosystemAddress = _ecosystemAddress;
        partnershipsAddress = _partnershipsAddress;
        advisorsAddress = _advisorsAddress;
        teamAddress = _teamAddress;
        vestingFactoryAddress = _vestingFactoryAddress;
        uint256 mintForLiq = liquidityAvailableAmount.div(100).mul(2);
        liquidityAvailableAmount = liquidityAvailableAmount.sub(mintForLiq);
        _mint(liquidityAddress, mintForLiq);
        _approve(
            address(this),
            vestingFactoryAddress,
            preSaleAvailableAmount.add(seederAvailableAmount)
        );
        uint256 advisorsMax = maxSupply.div(PERCENTS_DIVIDER).mul(
            PERCENTAGE_FOR_ADVISORS
        );
        uint256 advisorsTGE = advisorsMax.mul(TGE_FOR_ADVISORS).div(
            PERCENTS_DIVIDER
        );
        _mint(advisorsAddress, advisorsTGE);
        advisorsMax = advisorsMax.sub(advisorsTGE);
        // ecosystem
        lockedAccounts[0] = LockedBalance(
            ecosystemAddress,
            0,
            72 weeks,
            80 weeks,
            maxSupply.div(PERCENTS_DIVIDER).mul(PERCENTAGE_FOR_ECOSYSTEM),
            getCurrentTime()
        );
        // partnerships
        lockedAccounts[1] = LockedBalance(
            partnershipsAddress,
            0,
            48 weeks,
            80 weeks,
            maxSupply.div(PERCENTS_DIVIDER).mul(PERCENTAGE_FOR_PARTNERSHIPS),
            getCurrentTime()
        );
        // team
        lockedAccounts[2] = LockedBalance(
            teamAddress,
            0,
            48 weeks,
            40 weeks,
            maxSupply.div(PERCENTS_DIVIDER).mul(PERCENTAGE_FOR_TEAM),
            getCurrentTime()
        );
        // advisors
        lockedAccounts[3] = LockedBalance(
            advisorsAddress,
            0,
            0,
            40 weeks,
            advisorsMax,
            getCurrentTime()
        );
        _mint(msg.sender, PINKSALE_AMOUNT);
    }

    function setStakeContract(address _address) public onlyOwner {
        stakeContractAddress = _address;
    }

    function mintForStakeContract(uint256 _amount)
    public
    onlyStakeContract
    returns (bool status)
    {
        require(totalSupply().add(_amount) <= maxSupply, "MAX SUPPLY");
        _mint(stakeContractAddress, _amount);
        return true;
    }

    function _calculateReleasableBalances(uint8 i)
    internal
    view
    returns (uint256 _amount)
    {
        uint256 amount;
        LockedBalance memory lockedAccount = lockedAccounts[i];
        lockedAccount._start = lockedAccount._start.add(
            lockedAccount._initDate
        );
        uint256 totalBalance = lockedAccount._balance +
        _released[lockedAccount._address];
        if (getCurrentTime() <= lockedAccount._start + lockedAccount._cliff) {
            amount = 0;
        } else if (
            getCurrentTime() >=
            lockedAccount._start.add(lockedAccount._duration)
        ) {
            amount = lockedAccount._balance;
        } else {
            amount =
            ((totalBalance * (getCurrentTime().sub(lockedAccount._start))) /
            lockedAccount._duration) -
            _released[lockedAccount._address];
        }
        return amount;
    }

    function getLockedBalances(uint8 i)
    public
    view
    returns (
        address _address,
        uint256 _cliff,
        uint256 _start,
        uint256 _duration,
        uint256 _balance,
        uint256 released,
        uint256 releasable,
        uint256 _initDate
    )
    {
        LockedBalance memory lockedAccount = lockedAccounts[i];
        uint256 released_ = _released[lockedAccount._address];
        uint256 releasable_ = _calculateReleasableBalances(i);

        return (
        lockedAccount._address,
        lockedAccount._cliff,
        lockedAccount._start,
        lockedAccount._duration,
        lockedAccount._balance,
        released_,
        releasable_,
        lockedAccount._initDate
        );
    }

    function releaseLockedBalances() external onlyOwner {
        uint8 i = 0;
        while (i < 4) {
            uint256 amount = _calculateReleasableBalances(i);
            if (amount > 0) {
                LockedBalance memory lockedAccount = lockedAccounts[i];
                require(lockedAccount._balance >= amount, "Release error!");
                lockedAccounts[i]._balance = lockedAccount._balance.sub(amount);
                _mint(lockedAccount._address, amount);
                _released[lockedAccount._address] = _released[
                lockedAccount._address
                ].add(amount);
                emit TokensReleased(lockedAccount._address, amount);
            }
            i += 1;
        }
    }

    function mintForLiquidity(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater then 0");
        require(
            amount <= liquidityAvailableAmount,
            "Not enough tokens in the reserve"
        );
        liquidityAvailableAmount = liquidityAvailableAmount.sub(amount);
        _mint(liquidityAddress, amount);
        emit MintedForLiquidity(amount);
    }

    function initSeeders(
        address[] memory seeders,
        uint256[] memory valuesOfSeeders
    ) external onlyOwner {
        require(
            seeders.length == valuesOfSeeders.length,
            "Lengths must be same!"
        );
        require(!seedersInitialized, "Already Initialized!");
        uint256 i = 0;
        while (i < seeders.length) {
            addSeeder(seeders[i], valuesOfSeeders[i]);
            i += 1;
        }
        seedersInitialized = true;
    }

    function addSeeder(address _seederAddress, uint256 amount)
    internal
    returns (address vestingAddress)
    {
        require(
            seederAvailableAmount >= amount,
            "Not enough tokens in the reserve"
        );
        seederAvailableAmount = seederAvailableAmount.sub(amount);
        _mint(address(this), amount);
        bytes32 salt = keccak256(
            abi.encodePacked(_seederAddress, address(this))
        );
        return
        IVestingFactory(vestingFactoryAddress).deployVesting(
            _seederAddress,
            getCurrentTime(),
            24 weeks,
            80 weeks,
            false,
            amount,
            this,
            salt,
            address(this),
            address(this)
        );
    }

    function buy() public payable returns (address vestingAddress) {
        require(getCurrentTime() >= PRESALE_START, "Pre-sale not yet started!");
        require(getCurrentTime() < PRESALE_CLOSE, "Pre-sale closed!");
        uint256 value = msg.value;
        require(value >= PRESALE_MIN_AMOUNT, "PRESALE MIN AMOUNT");
        require(value <= PRESALE_MAX_AMOUNT, "PRESALE MAX AMOUNT");
        uint256 amount = value.mul(PRESALE_RATE);
        require(amount > 0, "Amount must be greater then 0");
        require(
            amount <= preSaleAvailableAmount,
            "Not enough tokens in the reserve"
        );

        preSaleAvailableAmount = preSaleAvailableAmount.sub(amount);
        uint256 lockedAmount = amount.div(PERCENTS_DIVIDER).mul(
            LOCKED_FOR_PRESALE
        );
        uint256 releasedAmount = amount.div(PERCENTS_DIVIDER).mul(
            TGE_FOR_PRESALE
        );
        _mint(msg.sender, releasedAmount);
        emit TokensPresold(msg.sender, amount);
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, address(this)));
        address _vestingAddress = IVestingFactory(vestingFactoryAddress)
        .getVestingAddress(msg.sender);
        if (_vestingAddress == address(0)) {
            _mint(address(this), lockedAmount);
            return
            IVestingFactory(vestingFactoryAddress).deployVesting(
                msg.sender,
                getCurrentTime(),
                0,
                40 weeks,
                false,
                lockedAmount,
                this,
                salt,
                address(this),
                address(this)
            );
        } else {
            _mint(_vestingAddress, lockedAmount);
            return _vestingAddress;
        }
    }

    function getCurrentTime() public view virtual returns (uint256) {
        return block.timestamp;
    }

    function _safeTransferFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint256 amount
    ) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }

    function withdrawToken(IERC20 _token, uint256 _amount) public onlyOwner {
        _token.transfer(msg.sender, _amount);
    }

    function withdrawWithAmount(uint256 _amount) public onlyOwner {
        payable(msg.sender).transfer(_amount);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function getBalance() public view returns (uint256) {
        uint256 balance = address(this).balance;
        return balance;
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
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
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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