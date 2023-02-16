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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Capped.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";

/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
abstract contract ERC20Capped is ERC20 {
    uint256 private immutable _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor(uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20-_mint}.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
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

pragma solidity ^0.8.11;

import "./OriginOwner.sol";
import "./libs/LDex.sol";

contract DexListing is OriginOwner {
    address public immutable uniswapV2Router;
    address public immutable wbnbPair;
    address public immutable busdPair;

    uint256 private _listingFeePercent = 0;
    uint256 private _listingDuration;
    uint256 private _listingStartAt;

    bool internal _listingFinished;

    constructor(uint256 listingDuration_) {
        _listingDuration = listingDuration_;
        // address router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address router = address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // Test net
        uniswapV2Router = router;

        wbnbPair = LDex._createPair(router, LDex._wbnb);
        busdPair = LDex._createPair(router, LDex._busd);
    }

    function _startListing() private onlyOriginOwner {
        _listingStartAt = block.timestamp;
        _listingFeePercent = 100;

        // originOwner removed, once listing started
        _removeOriginOwner();
    }

    function _finishListing() private {
        _listingFinished = true;
    }

    function _updateListingFee() private {
        uint256 pastTime = block.timestamp - _listingStartAt;
        if (pastTime > _listingDuration) {
            _listingFeePercent = 0;
        } else {
            // pastTime == 0 => fee = 100
            // pastTime == _listingDuration => fee = 0
            _listingFeePercent =
                (100 * (_listingDuration - pastTime)) /
                _listingDuration;
        }
    }

    function _updateAndGetListingFee(
        address sender_,
        address recipient_,
        uint256 amount_
    ) internal returns (uint256) {
        if (_listingStartAt == 0) {
            // first addLiquidity
            if (LDex._isPair(recipient_) && amount_ > 0) {
                _startListing();
            }
            return 0;
        } else {
            _updateListingFee();
            if (_listingStartAt + _listingDuration <= block.timestamp) {
                _finishListing();
            }

            if (!LDex._isPair(sender_) && !LDex._isPair(recipient_)) {
                // normal transfer
                return 0;
            } else {
                // swap
                return (amount_ * _listingFeePercent) / 100;
            }
        }
    }

    function listingDuration() public view returns (uint256) {
        return _listingDuration;
    }

    function listingFinished() public view returns (bool) {
        return _listingFinished;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract GasPriceController {
    event SetMaxGasPrice(uint256 maxGasPrice);

    modifier onlyValidGasPrice() {
        require(
            tx.gasprice <= _maxGasPrice,
            "GasPriceController: gasPrice too high"
        );
        _;
    }

    uint256 public constant MIN_GASPRICE = 5 gwei;

    uint256 private _maxGasPrice = MIN_GASPRICE;

    function _setMaxGasPrice(uint256 maxGasPrice_) internal {
        require(maxGasPrice_ >= MIN_GASPRICE, "GasPriceController: too low");
        _maxGasPrice = maxGasPrice_;
        emit SetMaxGasPrice(maxGasPrice_);
    }

    function maxGasPrice() external view returns (uint256) {
        return _maxGasPrice;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./GasPriceController.sol";
import "./DexListing.sol";
import "./TransferFee.sol";
import "../../interfaces/IGenomicDAOFairLaunchToken.sol";

contract GenomicDAOFairLaunchToken is
    IGenomicDAOFairLaunchToken,
    GasPriceController,
    DexListing,
    TransferFee,
    Ownable,
    ERC20Capped
{
    constructor(
        address owner,
        string memory name,
        string memory symbol,
        uint256 duration,
        uint256 cap
    ) ERC20(name, symbol) ERC20Capped(cap) DexListing(duration) {
        transferOwnership(owner);
        _setTransferFee(_msgSender(), 0, 0, 0);
    }

    function mint(address account, uint256 amount) public override onlyOwner {
        _mint(account, amount);
    }

    function burn(uint256 amount) public override {
        _burn(_msgSender(), amount);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function _transfer(
        address sender_,
        address recipient_,
        uint256 amount_
    ) internal override onlyValidGasPrice {
        if (!_listingFinished) {
            uint256 fee = _updateAndGetListingFee(sender_, recipient_, amount_);
            require(fee <= amount_, "Token: listing fee too high");
            uint256 transferA = amount_ - fee;
            if (fee > 0) {
                super._transfer(sender_, _getTransferFeeTo(), fee);
            }
            super._transfer(sender_, recipient_, transferA);
        } else {
            uint256 transferFee = _getTransferFee(sender_, recipient_, amount_);
            require(transferFee <= amount_, "transferFee too high");

            uint256 transferA = amount_ - transferFee;
            if (transferFee > 0) {
                super._transfer(sender_, _getTransferFeeTo(), transferFee);
            }
            if (transferA > 0) {
                super._transfer(sender_, recipient_, transferA);
            }
        }
    }

    /*
    Settings
    */
    function setMaxGasPrice(uint256 maxGasPrice_) external override onlyOwner {
        _setMaxGasPrice(maxGasPrice_);
    }

    function setTransferFee(
        address to_,
        uint256 buyFee_,
        uint256 sellFee_,
        uint256 normalFee_
    ) external override onlyOwner {
        _setTransferFee(to_, buyFee_, sellFee_, normalFee_);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {}

library LDex {
    bytes4 private constant FACTORY_SELECTOR =
    bytes4(keccak256(bytes("factory()")));

    // address internal constant _wbnb =
    //     address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address internal constant _wbnb =
    address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd); // testnet

    // address internal constant _busd =
    //     address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address internal constant _busd =
    address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // testnet

    function _isPair(address pair_) internal returns (bool) {
        (bool success, bytes memory data) = pair_.call(
            (abi.encodeWithSelector(FACTORY_SELECTOR))
        );
        return success && data.length > 0;
    }

    function _createPair(address router_, address pairedToken_)
    internal
    returns (address)
    {
        return
        IUniswapV2Factory(IUniswapV2Router02(router_).factory()).createPair(
            address(this),
            pairedToken_
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract OriginOwner {
    event ChangeOriginOwner(address originOwner);

    modifier onlyOriginOwner() {
        require(tx.origin == _originOwner, "OriginOwner: access denied");
        _;
    }

    address private _originOwner;

    constructor() {
        _originOwner = tx.origin;
    }

    function _changeOriginOwner(address originOwner_) internal {
        _originOwner = originOwner_;
        emit ChangeOriginOwner(originOwner_);
    }

    function _removeOriginOwner() internal {
        _changeOriginOwner(address(0x0));
    }

    function changeOriginOwner(address payable originOwner_)
    external
    onlyOriginOwner
    {
        _changeOriginOwner(originOwner_);
    }

    function removeOriginOwner() external onlyOriginOwner {
        _removeOriginOwner();
    }

    function originOwner() external view returns (address) {
        return _originOwner;
    }

    function isOriginOwner() public view returns (bool) {
        return _originOwner == tx.origin;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "./libs/LDex.sol";

contract TransferFee {
    bytes4 private constant FACTORY_SELECTOR =
    bytes4(keccak256(bytes("factory()")));

    event SetTransferFee(STransferFee transferFee);

    struct STransferFee {
        address to;
        uint256 buy;
        uint256 sell;
        uint256 normal;
    }

    STransferFee private _transferFee;
    uint256 private constant DEMI = 100;

    function _setTransferFee(
        address to_,
        uint256 buyFee_,
        uint256 sellFee_,
        uint256 normalFee_
    ) internal {
        require(buyFee_ <= DEMI, "TransferFee: fee must be less or equal 100%");
        require(
            sellFee_ <= DEMI,
            "TransferFee: fee must be less or equal 100%"
        );
        require(
            normalFee_ <= DEMI,
            "TransferFee: fee must be less or equal 100%"
        );
        _transferFee.to = to_;
        _transferFee.buy = buyFee_;
        _transferFee.sell = sellFee_;
        _transferFee.normal = normalFee_;
        emit SetTransferFee(_transferFee);
    }

    function _getTransferFee(
        address sender_,
        address recipient_,
        uint256 amount_
    ) internal returns (uint256) {
        if (LDex._isPair(recipient_)) {
            return (amount_ * _transferFee.sell) / DEMI;
        } else {
            if (LDex._isPair(sender_)) {
                return (amount_ * _transferFee.buy) / DEMI;
            } else {
                return (amount_ * _transferFee.normal) / DEMI;
            }
        }
    }

    function _getTransferFeeTo() internal view returns (address) {
        return _transferFee.to;
    }

    function transferFee() public view returns (STransferFee memory) {
        return _transferFee;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IGenomicDAOFairLaunchToken is IERC20 {
    function mint(address account, uint256 amount) external;

    function burn(uint256 amount) external;

    function setMaxGasPrice(uint256 maxGasPrice_) external;

    function setTransferFee(
        address to_,
        uint256 buyFee_,
        uint256 sellFee_,
        uint256 normalFee_
    ) external;
}