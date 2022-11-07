// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Coupon is Ownable {

    // UNE == unlimitted no expiry, UBE == unlimitted but expires, LNE == limited no expiry, LAE == limited and expires
    enum CouponType {UNE, UBE, LNE, LAE}

    struct CouponInfo {
        CouponType coupon_type;
        address couponUser;
        uint256 couponDiscount;
        uint256 couponStart;
        uint256 couponEnd;
        uint256 couponUses;
        uint couponActive;
    }

    //Map the user address to the coupon info
    mapping(address => mapping(uint256 => CouponInfo)) public _couponInfo;
    mapping(address => uint256) public _couponCount;
    mapping(uint256 => address) public _tokens;
    mapping(address => uint256) public _verifiedUsage;
    mapping(uint256 => uint256) public _buyDiscountRates;

    address constant public deadaddr = 0x000000000000000000000000000000000000dEaD;

    event _setCoupon(address _address, uint256 _couponType, uint256 _expiry, uint256 _discount, uint256 _useCount);
    event _changeEnd(address _address, uint256 _couponNumber, uint256 _newExpiry);
    event _changeDiscount(address _address, uint256 _couponNumber, uint256 _newDiscount);
    event _changeUses(address _address, uint256 _couponNumber, uint256 _newUses);
    event _setVerifiedContract(address _contract);
    event _removeVerifiedContract(address _contract);
    event _setTokenContract(uint256 _tokenNumber, address _token);
    event _removeTokenContract(uint256 _tokenNumber);
    event _useCoupon(address _user, address _address, uint256 _couponNumber);
    event _buyCoupon(address _purchaser, uint256 _discountRate, uint256 _tokenNumber);

    constructor() {
        _buyDiscountRates[5] = 750000000 gwei;
        _buyDiscountRates[10] = 1500000000 gwei;
        _buyDiscountRates[15] = 2250000000 gwei;
        _buyDiscountRates[20] = 3000000000 gwei;
        _buyDiscountRates[25] = 3750000000 gwei;
        _buyDiscountRates[30] = 4500000000 gwei;
        _buyDiscountRates[35] = 5000000000 gwei;
        _buyDiscountRates[40] = 5500000000 gwei;
        _buyDiscountRates[45] = 6000000000 gwei;
        _buyDiscountRates[50] = 6500000000 gwei;
    }

    function setCoupon(address _address, uint256 _couponType, uint256 _expiry, uint256 _discount, uint256 _useCount) public onlyOwner {
        require(_address != msg.sender, "Owner can not make their own coupons");
        uint256 coupon_number = _couponCount[_address] + 1;
        CouponInfo storage coupon = _couponInfo[_address][coupon_number];
        coupon.couponUser = _address;
        coupon.couponDiscount = _discount;

        uint256 _couponStart = block.timestamp;
        coupon.couponStart = block.timestamp;

        if(_couponType == 1) {
            coupon.coupon_type = CouponType.UNE;
            coupon.couponEnd = (_expiry * 9125 days)+_couponStart;
            coupon.couponUses = (_useCount*10000);
            coupon.couponActive = 1;
        }
        if(_couponType == 2) {
            coupon.coupon_type = CouponType.UBE;
            coupon.couponEnd = (_expiry * 1 days)+_couponStart;
            coupon.couponUses = _useCount;
            coupon.couponActive = 1;
        }
        if(_couponType == 3) {
            coupon.coupon_type = CouponType.LNE;
            coupon.couponEnd = (_expiry * 9125 days)+_couponStart;
            coupon.couponUses = (_useCount*10000);
            coupon.couponActive = 1;
        }
        if(_couponType == 4) {
            coupon.coupon_type = CouponType.LAE;
            coupon.couponEnd = (_expiry * 1 days)+_couponStart;
            coupon.couponUses = _useCount;
            coupon.couponActive = 1;
        }

        _couponCount[_address] = coupon_number;

        emit _setCoupon(_address, _couponType, _expiry, _discount, _useCount);
    }

    function changeEnd (address _address, uint256 _couponNumber, uint256 _newExpiry) public onlyOwner {
        CouponInfo storage coupon = _couponInfo[_address][_couponNumber];
        if(coupon.coupon_type == CouponType.UNE || coupon.coupon_type == CouponType.LNE) {
            coupon.couponEnd = (_newExpiry * 9125 days)+coupon.couponStart;
        } else {
            coupon.couponEnd = (_newExpiry * 1 days)+coupon.couponStart;
        }

        if (coupon.couponEnd > 0) {
            coupon.couponActive = 1;
        }

        emit _changeEnd(_address, _couponNumber, _newExpiry);
    }

    function changeDiscount (address _address, uint256 _couponNumber, uint256 _newDiscount) public onlyOwner {
        CouponInfo storage coupon = _couponInfo[_address][_couponNumber];
        coupon.couponDiscount = _newDiscount;

        emit _changeDiscount(_address, _couponNumber, _newDiscount);
    }

    function changeUses (address _address, uint256 _couponNumber, uint256 _newUses) public onlyOwner {
        CouponInfo storage coupon = _couponInfo[_address][_couponNumber];
        if(coupon.coupon_type == CouponType.UNE || coupon.coupon_type == CouponType.LNE) {
            coupon.couponUses = (_newUses*10000);
        } else {
            coupon.couponUses = _newUses;
        }

        if (coupon.couponUses > 0) {
            coupon.couponActive = 1;
        }

        emit _changeUses(_address, _couponNumber, _newUses);
    }

    function couponTimeLeft(address _address, uint256 _couponNumber) public view returns(uint256) {
        CouponInfo memory coupon = _couponInfo[_address][_couponNumber];
        uint256 remainTime = coupon.couponEnd > block.timestamp ? coupon.couponEnd-block.timestamp : 0;

        if ((coupon.couponEnd == 0)||(coupon.couponUses == 0)) {
            coupon.couponActive = 0;
        }
        return remainTime;
    }

    function getCoupon(address _address, uint256 _couponNumber) public view returns (uint256 _couponDiscount, uint _couponActive) {
        CouponInfo storage coupon = _couponInfo[_address][_couponNumber];

        if(coupon.couponActive == 1 && coupon.couponStart <= block.timestamp && coupon.couponEnd > block.timestamp && coupon.couponUses >= 0) {
            _couponDiscount = coupon.couponDiscount;
            _couponActive = coupon.couponActive;
        } else {
            _couponDiscount = 0;
            _couponActive = 0;
        }

        return(_couponDiscount, _couponActive);
    }

    function getCouponDetails(address _address, uint256 _couponNumber) external view returns (CouponType _coupon_type,address _couponUser, uint256 _couponDiscount, uint256 _couponStart, uint256 _couponEnd, uint256 _couponUses, uint _couponActive) {
        CouponInfo memory coupon = _couponInfo[_address][_couponNumber];
        coupon.couponUses = coupon.couponUses - 1;

        return(coupon.coupon_type, coupon.couponUser, coupon.couponDiscount, coupon.couponStart, coupon.couponEnd, coupon.couponUses, coupon.couponActive);
    }

    function getCouponDiscount(address _address, uint256 _couponNumber) external view returns (uint256 _couponDiscount) {
        CouponInfo memory coupon = _couponInfo[_address][_couponNumber];

        if (coupon.couponActive == 1) {
            _couponDiscount = coupon.couponDiscount;
        } else {
            _couponDiscount == 0;
        }
    }

    function getCouponActive(address _address, uint256 _couponNumber) external view returns (uint _couponActive) {
        CouponInfo memory coupon = _couponInfo[_address][_couponNumber];
        return(coupon.couponActive);
    }

    function getCouponCount(address _address) public view returns(uint256 _count) {
        return(_couponCount[_address]);
    }

    function setVerifiedContract(address _contract) public onlyOwner {
        _verifiedUsage[_contract] = 1;

        emit _setVerifiedContract(_contract);
    }

    function removeVerifiedContract(address _contract) public onlyOwner {
        _verifiedUsage[_contract] = 0;

        emit _removeVerifiedContract(_contract);
    }

    function setTokenContract(uint256 _tokenNumber, address _token) public onlyOwner {
        _tokens[_tokenNumber] = _token;

        emit _setTokenContract(_tokenNumber, _token);
    }

    function removeTokenContract(uint256 _tokenNumber) public onlyOwner {
        _tokens[_tokenNumber] = deadaddr;

        emit _removeTokenContract(_tokenNumber);
    }

    function useCoupon(address _address, uint256 _couponNumber) external {
        require(_verifiedUsage[msg.sender] == 1, "You are not authorized");
        require((_couponInfo[_address][_couponNumber].couponActive == 1), "Your coupon has not been activated!");
        require((_couponInfo[_address][_couponNumber].couponStart <= block.timestamp), "Your coupon has not started yet!");
        require((_couponInfo[_address][_couponNumber].couponEnd > block.timestamp), "Your coupon is expired!");

        CouponInfo storage coupon = _couponInfo[_address][_couponNumber];
        coupon.couponUses = coupon.couponUses - 1;

        if (coupon.couponUses == 0) {
            coupon.couponActive = 0;
        }

        emit _useCoupon(msg.sender, _address, _couponNumber);
    }

    function buyCoupon(uint256 _discountRate, uint256 _tokenNumber) external {
        require(_discountRate % 5 == 0, "Invalid rate");
        require(_discountRate <= 50, "Rate too high");
        require(ERC20(_tokens[_tokenNumber]).balanceOf(msg.sender) >= _buyDiscountRates[_discountRate], "Insufficient funds");

        uint256 coupon_number = _couponCount[msg.sender] + 1;
        CouponInfo storage coupon = _couponInfo[msg.sender][coupon_number];
        coupon.couponUser = msg.sender;
        coupon.couponDiscount = _discountRate;

        uint256 _couponStart = block.timestamp;
        coupon.couponStart = _couponStart;
        coupon.coupon_type = CouponType.LNE;
        coupon.couponEnd = (9125 days) +_couponStart;
        coupon.couponUses = 1;
        coupon.couponActive = 1;

        _couponCount[msg.sender] = _couponCount[msg.sender] + 1;

        ERC20(_tokens[_tokenNumber]).transferFrom(msg.sender, address(deadaddr), _buyDiscountRates[_discountRate]);

        emit _buyCoupon(msg.sender, _discountRate, _tokenNumber);

    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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