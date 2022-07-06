// SPDX-License-Identifier: MIT
/**
  ∩~~~~∩ 
  ξ ･×･ ξ 
  ξ　~　ξ 
  ξ　　 ξ 
  ξ　　 "~～~～〇 
  ξ　　　　　　 ξ 
  ξ ξ ξ~～~ξ ξ ξ 
　 ξ_ξξ_ξ　ξ_ξξ_ξ
Alpaca Fin Corporation
*/

pragma solidity 0.8.13;

import { OwnableUpgradeable } from "../../../../lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import { ERC20Upgradeable } from "../../../../lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "../../../../lib/openzeppelin-contracts-upgradeable/contracts/security/ReentrancyGuardUpgradeable.sol";
import "../utils/SafeToken.sol";
import "./TrancheMaster.sol";

contract Tranche is
  OwnableUpgradeable,
  ERC20Upgradeable,
  ReentrancyGuardUpgradeable
{
  /// @notice Libraries
  using SafeToken for address;

  /// @dev constants
  address public trancheMaster;

  mapping(uint256 => CycleMeta) public cycleInfos;

  /// @dev Errors
  error Tranche_Unauthorized();

  /// @dev structs
  struct CycleMeta {
    uint256 totalAsset;
  }

  function initialize(
    address _trancheMaster,
    string memory _name,
    string memory _symbol
  ) external initializer {
    OwnableUpgradeable.__Ownable_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
    ERC20Upgradeable.__ERC20_init(_name, _symbol);
    trancheMaster = _trancheMaster;
  }

  modifier onlyTrancheMaster() {
    if (trancheMaster != _msgSender()) {
      revert Tranche_Unauthorized();
    }
    _;
  }

  function deposit(uint256 _tokenAmount)
    external
    onlyTrancheMaster
    nonReentrant
    returns (uint256 _share)
  {
    _share = convertToShares(_tokenAmount);
    TrancheMaster(trancheMaster).stableAddress().safeTransferFrom(
      _msgSender(),
      address(this),
      _tokenAmount
    );
    (uint256 cycle, , , ) = TrancheMaster(trancheMaster).currentCycle();

    cycleInfos[cycle].totalAsset = TrancheMaster(trancheMaster)
      .stableAddress()
      .balanceOf(address(this));
    _mint(_msgSender(), _share);
    return _share;
  }

  function withdraw(uint256 _share)
    external
    onlyTrancheMaster
    nonReentrant
    returns (uint256 _tokenAmount)
  {
    _tokenAmount = convertToAssets(_share);
    _burn(_msgSender(), _share);
    TrancheMaster(trancheMaster).stableAddress().safeTransfer(
      _msgSender(),
      _tokenAmount
    );
    (uint256 cycle, , , ) = TrancheMaster(trancheMaster).currentCycle();
    cycleInfos[cycle].totalAsset = TrancheMaster(trancheMaster)
      .stableAddress()
      .balanceOf(address(this));
    return _tokenAmount;
  }

  function requestFund() external onlyTrancheMaster nonReentrant {
    address _stable = TrancheMaster(trancheMaster).stableAddress();
    _stable.safeTransfer(trancheMaster, _stable.myBalance());
  }

  /// @notice Accounting Logic
  function totalAssets() public view returns (uint256) {
    (uint256 cycle, , , ) = TrancheMaster(trancheMaster).currentCycle();
    return cycleInfos[cycle].totalAsset;
  }

  function convertToShares(uint256 _amount) public view returns (uint256) {
    uint256 _totalSupply = totalSupply();

    return
      _totalSupply == 0 ? _amount : (_amount * totalAssets()) / _totalSupply;
  }

  function convertToAssets(uint256 _share) public view returns (uint256) {
    uint256 _totalAsset = totalAssets();

    return _totalAsset == 0 ? _share : (_share * totalSupply()) / _totalAsset;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
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
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

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
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
/**
  ∩~~~~∩ 
  ξ ･×･ ξ 
  ξ　~　ξ 
  ξ　　 ξ 
  ξ　　 "~～~～〇 
  ξ　　　　　　 ξ 
  ξ ξ ξ~～~ξ ξ ξ 
　 ξ_ξξ_ξ　ξ_ξξ_ξ
Alpaca Fin Corporation
*/

pragma solidity 0.8.13;

interface ERC20Interface {
  function balanceOf(address user) external view returns (uint256);
}

library SafeToken {
  function balanceOf(address token, address user)
    internal
    view
    returns (uint256)
  {
    return ERC20Interface(token).balanceOf(user);
  }

  function myBalance(address token) internal view returns (uint256) {
    return ERC20Interface(token).balanceOf(address(this));
  }

  function safeTransfer(
    address token,
    address to,
    uint256 value
  ) internal {
    // bytes4(keccak256(bytes('transfer(address,uint256)')));
    // solhint-disable-next-line avoid-low-level-calls
    require(isContract(token), "!contract");
    (bool success, bytes memory data) = token.call(
      abi.encodeWithSelector(0xa9059cbb, to, value)
    );
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "!safeTransfer"
    );
  }

  function safeTransferFrom(
    address token,
    address from,
    address to,
    uint256 value
  ) internal {
    // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    // solhint-disable-next-line avoid-low-level-calls
    require(isContract(token), "!not contract");
    (bool success, bytes memory data) = token.call(
      abi.encodeWithSelector(0x23b872dd, from, to, value)
    );
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "!safeTransferFrom"
    );
  }

  function safeApprove(
    address token,
    address to,
    uint256 value
  ) internal {
    // bytes4(keccak256(bytes('approve(address,uint256)')));
    require(isContract(token), "!not contract");
    (bool success, bytes memory data) = token.call(
      abi.encodeWithSelector(0x095ea7b3, to, value)
    );
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "!safeApprove"
    );
  }

  function safeTransferETH(address to, uint256 value) internal {
    // solhint-disable-next-line no-call-value
    (bool success, ) = to.call{ value: value }(new bytes(0));
    require(success, "!safeTransferETH");
  }

  function isContract(address account) internal view returns (bool) {
    // This method relies on extcodesize, which returns 0 for contracts in
    // construction, since the code is only stored at the end of the
    // constructor execution.

    uint256 size;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }
}

// SPDX-License-Identifier: MIT
/**
  ∩~~~~∩ 
  ξ ･×･ ξ 
  ξ　~　ξ 
  ξ　　 ξ 
  ξ　　 "~～~～〇 
  ξ　　　　　　 ξ 
  ξ ξ ξ~～~ξ ξ ξ 
　 ξ_ξξ_ξ　ξ_ξξ_ξ
Alpaca Fin Corporation
*/

pragma solidity 0.8.13;

import { OwnableUpgradeable } from "../../../../lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "../../../../lib/openzeppelin-contracts-upgradeable/contracts/security/ReentrancyGuardUpgradeable.sol";
import "../utils/SafeToken.sol";
import "./TrancheConstant.sol";
import "./TrancheConfig.sol";
import "./Tranche.sol";
import "./TrancheProportionModel.sol";
import "./interfaces/IPriceOracle.sol";
import "./interfaces/ITrancheStrategy.sol";
import "../utils/SafeToken.sol";

contract TrancheMaster is OwnableUpgradeable, ReentrancyGuardUpgradeable {
  /// @notice Libraries
  using SafeToken for address;

  /// @dev constants
  address[] public tranches;
  address public config;
  address public stableAddress;
  address public oracle;
  uint256 public volatilityFactor;
  mapping(uint256 => CycleSnapshot) public cycleSnapshots;
  PhaseMeta public currentPhase;
  CycleMeta public currentCycle; // The first cycle after setup phase is 1. Write Preview

  /// @dev Errors
  error TrancheMaster_BadPhase();
  error TrancheMaster_BadPhaseDuration();
  error TrancheMaster_BadTrancheLength();
  error TrancheMaster_BadStrategy();
  error TrancheMaster_BadOracle();
  error TrancheMaster_BadAmount();
  error TrancheMaster_BadShareAmount();
  error TrancheMaster_BadExchangeRate();
  error TrancheMaster_BadVolatilityAmount();
  error TrancheMaster_PriceStale();
  error TrancheMaster_FundDeploymentInProgress();

  /// @dev structs
  struct PhaseMeta {
    uint256 phase;
    uint256 startBlock;
    uint256 startTime;
  }

  struct CycleMeta {
    uint256 cycle;
    uint256 stableTokenPrice;
    uint256 startBlock;
    uint256 startTime;
  }

  struct CycleSnapshot {
    uint256 startExchangeRate;
    uint256 endExchangeRate;
  }

  /// @dev events
  event LogUpdateCurrentPhase(
    uint256 _phase,
    uint256 _startBlock,
    uint256 _startTime
  );
  event LogUpdateCurrentCycle(
    uint256 _cycle,
    uint256 _startBlock,
    uint256 _startTime
  );
  event LogStartInvestmentPhase();
  event LogStartSettlementPhase();
  event LogStartPreparationPhase();
  event LogForceStartSettlementPhase();
  event LogStartDeadPhase();
  event LogSetParames(
    address[] _tranches, 
    address _oracle,
    uint256 _volatilityFactor
  );
  event LogDeposit(
    uint256 _trancheIndex,
    uint256 _amount,
    address _shareReceiver,
    uint256 _minShareReceived
  );
  event LogWithdraw(
    uint256 _trancheIndex,
    uint256 _amount,
    address _assetReceiver
  );
  event LogUpdateStartExchangeRate(uint256 cycle, uint256 startExchangeRate);
  event LogUpdateEndExchangeRate(uint256 cycle, uint256 endExchangeRate);
  event LogUpdateVolatilityFactor(uint256 volatilityFactor);

  function initialize(
    address _config, 
    address _stableAddress
    ) external initializer {
    OwnableUpgradeable.__Ownable_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();

    config = _config;
    stableAddress = _stableAddress;

    // set the phase
    _updateCurrentPhase(TrancheConstant.SETUP_PHASE);
  }

  /// @notice Progess from SETTLEMENT_PHASE to PREPARATION_PHASE (3->1), and start a new cycle
  function startPreparationPhase() external onlyOwner {
    if (currentCycle.cycle == 0) {
      _validatePhase(TrancheConstant.SETUP_PHASE);
      _validateTranchesLength(tranches);
      _validateStrategy(TrancheConfig(config).trancheStrategy());
    } else {
      _validateFundDeploymentProgress();
      _validatePhase(TrancheConstant.SETTLEMENT_PHASE);
      _validatePhaseTime(
        TrancheConfig(config).phaseDurations(TrancheConstant.SETTLEMENT_PHASE)
      );
      ITrancheStrategy(TrancheConfig(config).trancheStrategy()).withdrawFund();
      uint256[] memory _settleEarnings = _calculateSettleEarning();

      _settleEarning(
        TrancheConstant.SENIOR_TRANCHE_INDEX,
        _settleEarnings[TrancheConstant.SENIOR_TRANCHE_INDEX]
      );
      _settleEarning(
        TrancheConstant.MEZZANINE_TRANCHE_INDEX,
        _settleEarnings[TrancheConstant.MEZZANINE_TRANCHE_INDEX]
      );
      _settleEarning(
        TrancheConstant.JUNIOR_TRANCHE_INDEX,
        _settleEarnings[TrancheConstant.JUNIOR_TRANCHE_INDEX]
      );
    }

    _updateCurrentPhase(TrancheConstant.PREPARATION_PHASE);
    _updateCurrentCycle();

    emit LogStartPreparationPhase();
  }

  /// @notice Progess from PREPARATION_PHASE to INVESTMENT_PHASE (1->2)
  function startInvestmentPhase() external onlyOwner {
    _validatePhase(TrancheConstant.PREPARATION_PHASE);

    _validatePhaseTime(
      TrancheConfig(config).phaseDurations(TrancheConstant.PREPARATION_PHASE)
    );

    _updateCurrentPhase(TrancheConstant.INVESTMENT_PHASE);
    _updateTranchestableTokenPrice();
    _updateStartExchangeRate(currentCycle.cycle);

    // request fund from tranche
    Tranche(tranches[TrancheConstant.SENIOR_TRANCHE_INDEX]).requestFund();
    Tranche(tranches[TrancheConstant.MEZZANINE_TRANCHE_INDEX]).requestFund();
    Tranche(tranches[TrancheConstant.JUNIOR_TRANCHE_INDEX]).requestFund();

    // transfer fund to strategy
    stableAddress.safeTransfer(
      TrancheConfig(config).trancheStrategy(),
      stableAddress.myBalance()
    );

    emit LogStartInvestmentPhase();
  }

  /// @notice Progess from INVESTMENT_PHASE to SETTLEMENT_PHASE (2->3)
  function startSettlementPhase() external onlyOwner {
    _validatePhase(TrancheConstant.INVESTMENT_PHASE);

    _validatePhaseTime(
      TrancheConfig(config).phaseDurations(TrancheConstant.INVESTMENT_PHASE)
    );

    _updateCurrentPhase(TrancheConstant.SETTLEMENT_PHASE);
    _updateEndExchangeRate(currentCycle.cycle);

    emit LogStartInvestmentPhase();
  }

  /// @notice Force to progess from SETTLEMENT_PHASE to PREPARATION_PHASE (3->1) without phase duration check
  function forceStartSettlementPhase() external onlyOwner {
    _validatePhase(TrancheConstant.INVESTMENT_PHASE);
    _updateCurrentPhase(TrancheConstant.SETTLEMENT_PHASE);
    _updateEndExchangeRate(currentCycle.cycle);

    emit LogForceStartSettlementPhase();
  }

  /// @notice Progess from PREPARATION_PHASE to DEAD_PHASE (1->4) which would end the life cycle of this fund
  function startDeadPhase() external onlyOwner {
    _validatePhase(TrancheConstant.PREPARATION_PHASE);
    _updateCurrentPhase(TrancheConstant.DEAD_PHASE);

    emit LogStartDeadPhase();
  }

  /// @notice Set tranches from SETUP_PHASE
  function setParams(
    address[] memory _tranches, 
    address _oracle,
    uint256 _volatilityFactor
  )
    external
    onlyOwner
  {
    _validatePhase(TrancheConstant.SETUP_PHASE);
    _validateTranchesLength(_tranches);
    _validateOracle(_oracle);
    _validateVolatilityFactor(_volatilityFactor);

    tranches = _tranches;
    oracle = _oracle;
    volatilityFactor = _volatilityFactor;

    uint256 MAX_INT = 2**256 - 1;
    stableAddress.safeApprove(
      tranches[TrancheConstant.SENIOR_TRANCHE_INDEX],
      MAX_INT
    );
    stableAddress.safeApprove(
      tranches[TrancheConstant.MEZZANINE_TRANCHE_INDEX],
      MAX_INT
    );
    stableAddress.safeApprove(
      tranches[TrancheConstant.JUNIOR_TRANCHE_INDEX],
      MAX_INT
    );

    emit LogSetParames(tranches, oracle, volatilityFactor);
  }

  /// @notice deposit amount
  function deposit(
    uint256 _trancheIndex,
    uint256 _amount,
    address _shareReceiver
  ) external {
    _validatePhase(TrancheConstant.PREPARATION_PHASE);
    TrancheConfig trancheConfig = TrancheConfig(config);

    uint256[] memory _trancheTVLs = _getTrancheTVLs();

    _validateCapacity(
      _amount,
      TrancheProportionModel(trancheConfig.trancheProportionModel())
        .maxDepositableValue(
          _trancheIndex,
          _trancheTVLs,
          trancheConfig.maxAssetValue()
        )
    );

    stableAddress.safeTransferFrom(_msgSender(), address(this), _amount);
    uint256 _share = Tranche(tranches[_trancheIndex]).deposit(_amount);
    tranches[_trancheIndex].safeTransfer(_shareReceiver, _share);
    // TODO:TrancheMaster calc
  }

  /// @notice withdraw amount
  function withdraw(
    uint256 _trancheIndex,
    uint256 _amount,
    address _assetReceiver
  ) external {
    if (
      currentPhase.phase != TrancheConstant.PREPARATION_PHASE &&
      currentPhase.phase != TrancheConstant.DEAD_PHASE
    ) {
      revert TrancheMaster_BadPhase();
    }

    TrancheConfig trancheConfig = TrancheConfig(config);

    uint256[] memory _trancheTVLs = _getTrancheTVLs();

    _validateCapacity(
      _amount,
      TrancheProportionModel(trancheConfig.trancheProportionModel())
        .maxWithdrawableValue(_trancheIndex, _trancheTVLs)
    );

    tranches[_trancheIndex].safeTransferFrom(
      _msgSender(),
      address(this),
      _amount
    );

    uint256 _tokenAmount = Tranche(tranches[_trancheIndex]).withdraw(_amount);
    stableAddress.safeTransfer(_assetReceiver, _tokenAmount);

    // TODO:TrancheMaster calc
  }

  function deployFund(bytes calldata _data) external nonReentrant onlyOwner {
    _validatePhase(TrancheConstant.INVESTMENT_PHASE);
    ITrancheStrategy(TrancheConfig(config).trancheStrategy()).deployFund(_data);
  }

  function undeployFund(bytes calldata _data) external nonReentrant onlyOwner {
    _validatePhase(TrancheConstant.SETTLEMENT_PHASE);
    ITrancheStrategy(TrancheConfig(config).trancheStrategy()).undeployFund(
      _data
    );
  }

  function emergencyUndeploy(bytes calldata _data)
    external
    nonReentrant
    onlyOwner
  {
    _validatePhase(TrancheConstant.SETTLEMENT_PHASE);
    ITrancheStrategy(TrancheConfig(config).trancheStrategy()).emergencyUndeploy(
        _data
      );
  }

  function _calculateSettleEarning() internal view returns (uint256[] memory) {
    uint256[] memory _settleEarnings = new uint256[](3);
    uint256 totalAssetAmount = stableAddress.balanceOf(address(this));

    if (_isDepeg(currentCycle.cycle)) {
      _settleEarnings[TrancheConstant.SENIOR_TRANCHE_INDEX] = _min(
        totalAssetAmount,
        _calculateDepegProtectedReturn(
          TrancheConstant.SENIOR_TRANCHE_INDEX
        )
      );

      _settleEarnings[TrancheConstant.MEZZANINE_TRANCHE_INDEX] = _min(
        totalAssetAmount -
          _settleEarnings[TrancheConstant.SENIOR_TRANCHE_INDEX],
        _calculateDepegProtectedReturn(
          TrancheConstant.MEZZANINE_TRANCHE_INDEX
        )
      );
    } else {
      _settleEarnings[TrancheConstant.SENIOR_TRANCHE_INDEX] = _min(
        totalAssetAmount,
        _calculateExpectedReturn(
          TrancheConstant.SENIOR_TRANCHE_INDEX
        )
      );

      _settleEarnings[TrancheConstant.MEZZANINE_TRANCHE_INDEX] = _min(
        totalAssetAmount -
          _settleEarnings[TrancheConstant.SENIOR_TRANCHE_INDEX],
        _calculateExpectedReturn(
          TrancheConstant.MEZZANINE_TRANCHE_INDEX
        )
      );
    }

    _settleEarnings[TrancheConstant.JUNIOR_TRANCHE_INDEX] =
      totalAssetAmount -
      (_settleEarnings[TrancheConstant.SENIOR_TRANCHE_INDEX] +
        _settleEarnings[TrancheConstant.MEZZANINE_TRANCHE_INDEX]);

    return _settleEarnings;
  }

  function _calculateExpectedReturn(
    uint256 _trancheIndex
  ) internal view returns (uint256) {
    return
      Tranche(tranches[_trancheIndex]).totalAssets() +
      (Tranche(tranches[_trancheIndex]).totalAssets() *
        TrancheConfig(config).guaranteedBps(_trancheIndex) *
        TrancheConfig(config).phaseDurations(
          TrancheConstant.INVESTMENT_PHASE
        )) /
      365 days /
      10000;
  }

  function _calculateDepegProtectedReturn(
    uint256 _trancheIndex
  ) internal view returns (uint256) {
    uint256 startExchangeRate = cycleSnapshots[currentCycle.cycle].startExchangeRate;
    uint256 endExchangeRate = cycleSnapshots[currentCycle.cycle].endExchangeRate;
    uint256 totalAssetValue = ((Tranche(tranches[_trancheIndex]).totalAssets() * 
                              startExchangeRate) / 1e18);
    uint256 totalAssetValueWithYield = totalAssetValue + (totalAssetValue *
        TrancheConfig(config).guaranteedBps(_trancheIndex) *
        TrancheConfig(config).phaseDurations(
          TrancheConstant.INVESTMENT_PHASE
        )) /
        365 days /
        10000;

    return (totalAssetValueWithYield * 1e18) / endExchangeRate;
  }

  /// @notice Settle earning to each tranche
  function _settleEarning(uint256 _trancheIndex, uint256 _amount)
    internal
    onlyOwner
  {
    if (_amount > 0)
      stableAddress.safeTransfer(tranches[_trancheIndex], _amount);
  }

  function _updateCurrentPhase(uint256 phase) internal {
    currentPhase.phase = phase;
    currentPhase.startBlock = block.number;
    currentPhase.startTime = block.timestamp;

    emit LogUpdateCurrentPhase(
      currentPhase.phase,
      currentPhase.startBlock,
      currentPhase.startTime
    );
  }

  function _updateCurrentCycle() internal {
    currentCycle.cycle++;
    currentCycle.startBlock = block.number;
    currentCycle.startTime = block.timestamp;

    emit LogUpdateCurrentCycle(
      currentPhase.phase,
      currentPhase.startBlock,
      currentPhase.startTime
    );
  }

  function _updateStartExchangeRate(uint256 cycle) internal {
    uint256 _stableTokenPrice = _getStableTokenPrice();
    _validateExchangeRate(_stableTokenPrice);
    cycleSnapshots[cycle].startExchangeRate = _stableTokenPrice;
        
    emit LogUpdateStartExchangeRate(cycle, _stableTokenPrice);
  }

  function _updateEndExchangeRate(uint256 cycle) internal {
    uint256 _stableTokenPrice = _getStableTokenPrice();
    _validateExchangeRate(_stableTokenPrice);
    cycleSnapshots[cycle].endExchangeRate = _stableTokenPrice;
        
    emit LogUpdateEndExchangeRate(cycle, _stableTokenPrice);
  }

  function updateVolatilityFactor(uint256 _volatilityFactor) external onlyOwner {
    _validateVolatilityFactor(_volatilityFactor);
    volatilityFactor = _volatilityFactor;

    emit LogUpdateVolatilityFactor(volatilityFactor);
  }

  function _validatePhase(uint256 _expectedPhase) internal view {
    if (currentPhase.phase != _expectedPhase) {
      revert TrancheMaster_BadPhase();
    }
  }

  function _validatePhaseTime(uint256 _phaseDuration) internal view {
    // if end phase time > now
    if (currentPhase.startTime + _phaseDuration > block.timestamp) {
      revert TrancheMaster_BadPhaseDuration();
    }
  }

  function _validateTranchesLength(address[] memory _tranches) internal pure {
    if (_tranches.length != 3) {
      revert TrancheMaster_BadTrancheLength();
    }
  }

  function _validateStrategy(address _strategy) internal pure {
    if (_strategy == address(0)) {
      revert TrancheMaster_BadStrategy();
    }
  }

  function _validateOracle(address _oracle) internal pure {
    if (_oracle == address(0)) {
      revert TrancheMaster_BadOracle();
    }
  }

  function _validateCapacity(uint256 _amount, uint256 _capacity) internal pure {
    if (_amount > _capacity) {
      revert TrancheMaster_BadAmount();
    }
  }

  function _validateExchangeRate(uint256 _amount) internal pure {
    if (_amount == 0) {
        revert TrancheMaster_BadExchangeRate();
    }
  }

  function _validateVolatilityFactor(uint256 _volatilityFactor) 
    internal pure 
  {
    if (_volatilityFactor == 0) {
      revert TrancheMaster_BadVolatilityAmount();
    }
  }

  function _getStableTokenPrice() internal view returns (uint256) {
    (uint256 _stableTokenPrice, uint256 _lastUpdate) = IPriceOracle(oracle)
      .getPrice(stableAddress, TrancheConstant.USD_ADDRESS);

    if (_lastUpdate < block.timestamp - TrancheConfig(config).priceLife())
      revert TrancheMaster_PriceStale();
    return _stableTokenPrice;
  }

  function _validateFundDeploymentProgress() internal {
    if (
      ITrancheStrategy(TrancheConfig(config).trancheStrategy())
        .deploymentInProgress()
    ) {
      revert TrancheMaster_FundDeploymentInProgress();
    }
  }

  function _updateTranchestableTokenPrice() internal {
    currentCycle.stableTokenPrice = _getStableTokenPrice();
  }

  function _getTrancheTVLs() internal view returns (uint256[] memory) {
    uint256 _stableTokenPrice = _getStableTokenPrice();
    uint256[] memory _trancheTVLs = new uint256[](3);

    _trancheTVLs[TrancheConstant.SENIOR_TRANCHE_INDEX] = ((Tranche(
      tranches[TrancheConstant.SENIOR_TRANCHE_INDEX]
    ).totalAssets() * _stableTokenPrice) / 1e18);

    _trancheTVLs[TrancheConstant.MEZZANINE_TRANCHE_INDEX] = ((Tranche(
      tranches[TrancheConstant.MEZZANINE_TRANCHE_INDEX]
    ).totalAssets() * _stableTokenPrice) / 1e18);

    _trancheTVLs[TrancheConstant.JUNIOR_TRANCHE_INDEX] = ((Tranche(
      tranches[TrancheConstant.JUNIOR_TRANCHE_INDEX]
    ).totalAssets() * _stableTokenPrice) / 1e18);

    return _trancheTVLs;
  }

  function _getVolatilityThreshold(uint256 _startExchangeRate) 
    internal view returns (uint256) 
  {
    _validateExchangeRate(_startExchangeRate);
    return (_min(1e18, _startExchangeRate) * 
                volatilityFactor) / 
                1e18;
  }

  function _isDepeg(uint256 _cycle) internal view returns (bool) {
    uint256 startExchangeRate = cycleSnapshots[_cycle].startExchangeRate;
    uint256 endExchangeRate = cycleSnapshots[_cycle].endExchangeRate;
    uint256 threshold = _getVolatilityThreshold(startExchangeRate);
    return endExchangeRate < threshold;
  }

  function _min(uint256 _x, uint256 _y) internal pure returns (uint256) {
    return _x < _y ? _x : _y;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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

pragma solidity 0.8.13;

library TrancheConstant {
  /// @dev enum
  uint8 public constant SETUP_PHASE = 0;
  uint8 public constant PREPARATION_PHASE = 1;
  uint8 public constant INVESTMENT_PHASE = 2;
  uint8 public constant SETTLEMENT_PHASE = 3;
  uint8 public constant DEAD_PHASE = 4;

  uint8 public constant SENIOR_TRANCHE_INDEX = 0;
  uint8 public constant MEZZANINE_TRANCHE_INDEX = 1;
  uint8 public constant JUNIOR_TRANCHE_INDEX = 2;

  address public constant USD_ADDRESS =
    0x115dffFFfffffffffFFFffffFFffFfFfFFFFfFff;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import { OwnableUpgradeable } from "../../../../lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

contract TrancheConfig is OwnableUpgradeable {
  event LogSetInitialize(
    address trancheStrategy,
    uint256[] phaseDurations,
    uint256 depositFeeBps,
    uint256 withdrawFeeBps,
    address treasuryAddress,
    uint256 maxAssetValue,
    address trancheProportionModel,
    address priceOracle,
    uint256[] guaranteedBps
  );

  event LogSetPriceOracle(address priceOracle);
  event LogSetPriceLife(uint256 priceLife);
  event LogSetTrancheStrategy(address trancheStrategy);
  event LogSetTreasuryAddress(address treasuryAddress);
  event LogSetTrancheProportionModel(address trancheProportionModel);
  event LogSetPhaseDurations(uint256[] phaseDurations);
  event LogSetFees(uint256 depositFeeBps, uint256 withdrawFeeBps);
  event LogSetGuaranteedBpses(uint256[] guaranteedBps);
  event LogSetMaxAssetValue(uint256 maxAssetValue);

  address public trancheStrategy;
  uint256[] public phaseDurations;
  uint256 public depositFeeBps;
  uint256 public withdrawFeeBps;
  address public treasuryAddress;
  uint256 public maxAssetValue;
  address public trancheProportionModel;
  address public priceOracle;
  uint256 public priceLife;
  uint256[] public guaranteedBps;

  function initialize(
    address _trancheStrategy,
    uint256[] calldata _phaseDurations,
    uint256 _depositFeeBps,
    uint256 _withdrawFeeBps,
    address _treasuryAddress,
    uint256 _maxAssetValue,
    address _trancheProportionModel,
    address _priceOracle,
    uint256 _priceLife,
    uint256[] calldata _guaranteedBps
  ) external initializer {
    OwnableUpgradeable.__Ownable_init();
    trancheStrategy = _trancheStrategy;
    phaseDurations = _phaseDurations;
    depositFeeBps = _depositFeeBps;
    withdrawFeeBps = _withdrawFeeBps;
    treasuryAddress = _treasuryAddress;

    maxAssetValue = _maxAssetValue;
    trancheProportionModel = _trancheProportionModel;
    priceOracle = _priceOracle;
    priceLife = _priceLife;
    guaranteedBps = _guaranteedBps;

    emit LogSetInitialize(
      trancheStrategy,
      phaseDurations,
      depositFeeBps,
      withdrawFeeBps,
      treasuryAddress,
      maxAssetValue,
      trancheProportionModel,
      priceOracle,
      guaranteedBps
    );
  }

  function setTrancheStrategy(address _trancheStrategy) external onlyOwner {
    trancheStrategy = _trancheStrategy;

    emit LogSetTrancheStrategy(trancheStrategy);
  }

  function setTreasuryAddress(address _treasuryAddress) external onlyOwner {
    treasuryAddress = _treasuryAddress;

    emit LogSetTreasuryAddress(treasuryAddress);
  }

  function setTrancheProportionModel(address _trancheProportionModel)
    external
    onlyOwner
  {
    trancheProportionModel = _trancheProportionModel;

    emit LogSetTrancheProportionModel(trancheProportionModel);
  }

  function setPriceOracle(address _priceOracle) external onlyOwner {
    priceOracle = _priceOracle;

    emit LogSetPriceOracle(priceOracle);
  }

  function setPriceLife(uint256 _priceLife) external onlyOwner {
    priceLife = _priceLife;

    emit LogSetPriceLife(priceLife);
  }

  function setPhaseDurations(uint256[] calldata _phaseDurations)
    external
    onlyOwner
  {
    phaseDurations = _phaseDurations;

    emit LogSetPhaseDurations(phaseDurations);
  }

  function setFees(uint256 _depositFeeBps, uint256 _withdrawFeeBps)
    external
    onlyOwner
  {
    depositFeeBps = _depositFeeBps;
    withdrawFeeBps = _withdrawFeeBps;

    emit LogSetFees(depositFeeBps, withdrawFeeBps);
  }

  function setGuaranteedBpses(uint256[] calldata _guaranteedBps)
    external
    onlyOwner
  {
    guaranteedBps = _guaranteedBps;

    emit LogSetGuaranteedBpses(guaranteedBps);
  }

  function setMaxAssetValue(uint256 _maxAssetValue) external onlyOwner {
    maxAssetValue = _maxAssetValue;
    emit LogSetMaxAssetValue(maxAssetValue);
  }

  function cycleDuration(uint256[] calldata _phaseDurations)
    external
    pure
    returns (uint256)
  {
    return _phaseDurations[0] + _phaseDurations[1] + _phaseDurations[2];
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./TrancheConstant.sol";

contract TrancheProportionModel {
  function maxDepositableValue(
    uint256 _trancheIndex,
    uint256[] memory _trancheTvls,
    uint256 _maxAssetValue
  ) external pure returns (uint256) {
    uint256 seniorTvl = _trancheTvls[TrancheConstant.SENIOR_TRANCHE_INDEX];
    uint256 mezzanineTvl = _trancheTvls[
      TrancheConstant.MEZZANINE_TRANCHE_INDEX
    ];
    uint256 juniorTvl = _trancheTvls[TrancheConstant.JUNIOR_TRANCHE_INDEX];

    uint256 capLeft = _subFloor0(
      _maxAssetValue,
      (seniorTvl + mezzanineTvl + juniorTvl)
    );

    if (_trancheIndex == TrancheConstant.JUNIOR_TRANCHE_INDEX) {
      return capLeft;
    }

    if (_trancheIndex == TrancheConstant.MEZZANINE_TRANCHE_INDEX) {
      return _min(_subFloor0(juniorTvl * 2, mezzanineTvl), capLeft);
    }

    if (_trancheIndex == TrancheConstant.SENIOR_TRANCHE_INDEX) {
      return _min(_subFloor0(juniorTvl + mezzanineTvl, seniorTvl), capLeft);
    }

    return 0;
  }

  function maxWithdrawableValue(
    uint256 _trancheIndex,
    uint256[] memory _trancheTvls
  ) external pure returns (uint256) {
    uint256 seniorTvl = _trancheTvls[TrancheConstant.SENIOR_TRANCHE_INDEX];
    uint256 mezzanineTvl = _trancheTvls[
      TrancheConstant.MEZZANINE_TRANCHE_INDEX
    ];
    uint256 juniorTvl = _trancheTvls[TrancheConstant.JUNIOR_TRANCHE_INDEX];

    if (_trancheIndex == TrancheConstant.JUNIOR_TRANCHE_INDEX) {
      return
        _min(
          _subFloor0(juniorTvl, (mezzanineTvl / 2)),
          _subFloor0(juniorTvl + mezzanineTvl, seniorTvl)
        );
    }

    if (_trancheIndex == TrancheConstant.MEZZANINE_TRANCHE_INDEX) {
      return
        _min(_subFloor0(juniorTvl + mezzanineTvl, seniorTvl), mezzanineTvl);
    }

    if (_trancheIndex == TrancheConstant.SENIOR_TRANCHE_INDEX) {
      return seniorTvl;
    }

    return 0;
  }

  function _subFloor0(uint256 _x, uint256 _y) internal pure returns (uint256) {
    return _x >= _y ? _x - _y : 0;
  }

  function _min(uint256 _x, uint256 _y) internal pure returns (uint256) {
    return _x < _y ? _x : _y;
  }
}

// SPDX-License-Identifier: MIT
/**
  ∩~~~~∩ 
  ξ ･×･ ξ 
  ξ　~　ξ 
  ξ　　 ξ 
  ξ　　 “~～~～〇 
  ξ　　　　　　 ξ 
  ξ ξ ξ~～~ξ ξ ξ 
　 ξ_ξξ_ξ　ξ_ξξ_ξ
Alpaca Fin Corporation
*/

pragma solidity 0.8.13;

interface IPriceOracle {
  /// @dev Return the wad price of token0/token1, multiplied by 1e18
  /// NOTE: (if you have 1 token0 how much you can sell it for token1)
  function getPrice(address token0, address token1) external view returns (uint256 price, uint256 lastUpdate);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface ITrancheStrategy {
  function trancheMaster() external returns (address);

  function deployFund(bytes calldata _data) external;

  function undeployFund(bytes calldata _data) external;

  function withdrawFund() external;

  function emergencyUndeploy(bytes calldata _data) external;

  function deploymentInProgress() external returns (bool);
}