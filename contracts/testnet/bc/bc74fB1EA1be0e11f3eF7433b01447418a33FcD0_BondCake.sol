/**
 * @notice Allow BondCake to be compatible with latest EVM version.
 */
pragma solidity >=0.8.16;

/**
 * @notice Import openzeppelin libraries.
 */
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @notice Import BondCake libraries.
 */
import "./BondWorker.sol";

/**
 * @notice Define BondCake smart contract.
 */
contract BondCake is
	Initializable,
	ERC20Upgradeable,
	ERC20BurnableUpgradeable,
	PausableUpgradeable,
	OwnableUpgradeable,
	ReentrancyGuardUpgradeable
{
	/**
	 * @notice Enable SafeMath for uint256
	 */
	using SafeMathUpgradeable for uint256;

	/**
	 * @notice BondLedger.
	 */
	struct BondLedger {
		uint256 shortTermBond;
		uint256 midTermBond;
		uint256 longTermBond;
	}

	/**
	 * @notice Bond configs data type.
	 */
	struct BondConfig {
		uint256 BOND_DURATION;
		uint256 SCHEDULED_NEXT_BOND_START;
		uint256 SCHEDULED_NEXT_LOCK_START;
	}

	/**
	 * @notice Declare events
	 */
	event DepositBond(address indexed depositor, uint256 amount);
	event ConfigureBond(
		address indexed actor,
		uint256 bondDuration,
		uint256 scheduledNextLockStart,
		uint256 scheduledNextBondStart
	);
	event StartBonding();
	event WithdrawStakedCake();

	/**
	 * @notice Declare bond ledger.
	 */
	mapping(address => BondLedger) public bondLedger;

	/*
	 * @notice Declare epochs bond configs.
	 */
	mapping(uint256 => BondConfig) public bondConfig;

	/*
	 * @notice Binding Cake address.
	 */
	IERC20 public Cake;

	/**
	 * @notice Binding Cake compound staking pool address.
	 */
	address public CompoundCakePoolAddress;

	/**
	 * @dev Declare current bond index. This index will be linearly increase once new bond epoch is activated.
	 */
	uint256 public currentBondIndex;

	/**
	 * @dev Declare current bond worker instance.
	 */
	BondWorker public currentBondWorker;

	/**
	 * @notice Public constructor to disable default initializers.
	 */
	/// @custom:oz-upgrades-unsafe-allow constructor
	constructor() {
		_disableInitializers();
	}

	/**
	 * @notice Initializer function.
	 */
	function initialize(address cakeAddress, address cakePoolAddress)
		public
		initializer
	{
		/**
		 * @dev Initialize.
		 */
		__ERC20_init("BondCake", "BCAKE");
		__ERC20Burnable_init();
		__Pausable_init();
		__Ownable_init();

		/**
		 * @dev Binding addresses.
		 */
		CompoundCakePoolAddress = cakePoolAddress;
		Cake = IERC20(cakeAddress);

		/**
		 * @dev Initialize BondWorker.
		 */
		currentBondIndex = 0;
		currentBondWorker = new BondWorker(cakeAddress, cakePoolAddress);

		/**
		 * @dev Scheduling phases timestamps.
		 */
		configureNextBond(
			365 days, // bond duration
			block.timestamp.add(30 days), // next lock start timestamp
			block.timestamp.add(30 days).add(30 days) // next bond start timestamp
		);
	}

	/**
	 * @notice Pause BondCake smart contract.
	 * @dev Only owner can pause the contract when the contract is not paused.
	 */
	function pause() public onlyOwner whenNotPaused {
		_pause();
	}

	/**
	 * @notice Unpause BondCake smart contract.
	 * @dev Only owner can unpause the contract when the contract is paused.
	 */
	function unpause() public onlyOwner whenPaused {
		_unpause();
	}

	/**
	 * @notice Inject Pausable modifier to make sure the token transfers comply with Pausable handler.
	 */
	function _beforeTokenTransfer(
		address from,
		address to,
		uint256 amount
	) internal override whenNotPaused {
		super._beforeTokenTransfer(from, to, amount);
	}

	/**
	 * @notice Configure next bond.
	 * @dev Only owner can configure.
	 */
	function configureNextBond(
		uint256 bondDuration,
		uint256 scheduledNextLockStart,
		uint256 scheduledNextBondStart
	) public onlyOwner {
		/**
		 * @dev Increase bond index.
		 */
		currentBondIndex = currentBondIndex.add(1);

		/**
		 * @dev Configure bond epoch.
		 */
		bondConfig[currentBondIndex].BOND_DURATION = bondDuration;
		bondConfig[currentBondIndex]
			.SCHEDULED_NEXT_LOCK_START = scheduledNextLockStart;
		bondConfig[currentBondIndex]
			.SCHEDULED_NEXT_BOND_START = scheduledNextBondStart;

		/**
		 * @dev Validate timestamps.
		 */
		require(
			bondConfig[currentBondIndex].SCHEDULED_NEXT_BOND_START >
				bondConfig[currentBondIndex].SCHEDULED_NEXT_LOCK_START,
			"Error: bond timestamp must be greater than lock timestamp."
		);

		require(
			block.timestamp <
				bondConfig[currentBondIndex].SCHEDULED_NEXT_LOCK_START,
			"Error: lock timestamp must be greater than block timestamp."
		);

		/**
		 * @dev Emit event
		 */
		emit ConfigureBond(
			owner(),
			bondDuration,
			scheduledNextLockStart,
			scheduledNextBondStart
		);
	}

	/**
	 * @notice Deposit native Cake and receive back BondCake which is 1:1 ratio backed.
	 * @param depositedAmount {uint256} - the amount user wants to deposit and receive the same amount in BondCake.
	 */
	function deposit(uint256 depositedAmount)
		public
		nonReentrant
		whenNotPaused
	{
		/**
		 * @dev Make sure the long term bond locking phase is activated.
		 */
		require(
			block.timestamp <
				bondConfig[currentBondIndex].SCHEDULED_NEXT_BOND_START,
			"Error: Depositing phase isn't locked"
		);

		/**
		 * @dev Record bond ledger with current sender.
		 */
		address sender = msg.sender;

		/**
		 * @dev Transfer Cake to the pool.
		 */
		Cake.transferFrom(msg.sender, address(this), depositedAmount);

		/**
		 * @dev Record bond amount into ledger.
		 */
		bondLedger[sender].longTermBond = bondLedger[sender].longTermBond.add(
			depositedAmount
		);

		/**
		 * @dev Mint CakeBond.
		 */
		_mint(msg.sender, depositedAmount);

		/**
		 * @dev Emit event
		 */
		emit DepositBond(sender, depositedAmount);
	}

	/**
	 * @notice Everyone can trigger bonding.
	 * @dev If the locking phase for short term bond is passed, start staking.
	 */
	function startBonding() external nonReentrant whenNotPaused {
		/**
		 * @dev Make sure the long term bond locking phase is activated.
		 */
		require(
			block.timestamp >=
				bondConfig[currentBondIndex].SCHEDULED_NEXT_BOND_START,
			"Error: must wait until bond timestamp."
		);

		/**
		 * @dev Calculate total bond.
		 */
		uint256 totalBond = Cake.balanceOf(address(this));

		/**
		 * @dev Deposit to CakePool.
		 */
		currentBondWorker.deposit(
			totalBond,
			bondConfig[currentBondIndex].BOND_DURATION
		);

		/**
		 * @dev Emit event
		 */
		emit StartBonding();
	}

	/*
	 * @notice Claim Cake payouts from Cake pool.
	 * @dev Everyone can call bond withdrawal.
	 */
	function withdrawStakedCake() external nonReentrant whenNotPaused {
		/**
		 * @dev Make sure locking period is still activated.
		 */
		require(
			block.timestamp >=
				bondConfig[currentBondIndex].SCHEDULED_NEXT_BOND_START.add(
					bondConfig[currentBondIndex].BOND_DURATION
				),
			"Error: must wait until bond epoch is expired."
		);

		/**
		 * @dev Start asking withdrawing native cake with bond worker.
		 */
		currentBondWorker.withdraw();

		/**
		 * @dev Emit event
		 */
		emit WithdrawStakedCake();
	}

	/*
	 * @notice Withdraw native CAKE by burning BondCake and receive native CAKE with 1:1 ratio.
	 * @dev Everyone can call bond withdrawal.
	 */
	function exchangeBond() external nonReentrant whenNotPaused {}
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20Upgradeable.sol";
import "../../../utils/ContextUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20BurnableUpgradeable is Initializable, ContextUpgradeable, ERC20Upgradeable {
    function __ERC20Burnable_init() internal onlyInitializing {
    }

    function __ERC20Burnable_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
library SafeMathUpgradeable {
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

pragma solidity >=0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./CompoundCakePool/CakePool.sol";

/*
 * @dev BondWorker smart contract.
 */
contract BondWorker is Ownable, ReentrancyGuard {
	/**
	 * @notice Enable SafeMath for uint256
	 */
	using SafeMath for uint256;

	/*
	 * @notice Binding Cake address.
	 */
	IERC20 public Cake;

	/**
	 * @notice Binding Cake compound staking pool address.
	 */
	CakePool public CompoundCakePool;

	/**
	 * @notice MasterChef address.
	 */
	address public masterChef;

	/**
	 * @notice Initialize contract with native Cake address and CakePool address.
	 */
	constructor(address nativeCakeAddress, address cakePoolAddress) {
		/**
		 * @dev Binding Cake address.
		 */
		Cake = IERC20(nativeCakeAddress);

		/**
		 * @dev Binding CakePool address.
		 */
		CompoundCakePool = CakePool(cakePoolAddress);

		/**
		 * @dev Binding MasterChef address.
		 */
		masterChef = owner();

		/*
		 * @dev Approve Cake transfer.
		 */
		approveCakeTransfer();
	}

	/**
	 * @notice Allow publicly approving transfer for native Cake token.
	 */
	function approveCakeTransfer() public {
		/**
		 * @dev Approve CompoundCakePool to transfer Cake to the pool in the deposit func.
		 */
		bool result = Cake.approve(address(CompoundCakePool), 2**256 - 1);
		require(
			result,
			"Error: Cannot approve Cake transfer for CompoundCakePool"
		);
	}

	/**
	 * @notice Deposit native Cake.
	 * @param depositedAmount {uint256} - the amount user wants to deposit.
	 * @param lockDuration {uint256} - the lock duration in seconds.
	 */
	function deposit(uint256 depositedAmount, uint256 lockDuration) external {
		/**
		 * @dev Transfer Cake from MasterChef to this.
		 */
		Cake.transferFrom(masterChef, address(this), depositedAmount);

		/**
		 * @dev Deposit to CakePool
		 */
		CompoundCakePool.deposit(depositedAmount, lockDuration);
	}

	/*
	 * @notice Withdraw native CAKE.
	 */
	function withdraw() external returns (uint256) {
		/**
		 * @dev Calculate balance before withdrawing Cake.
		 */
		uint256 beforeBalance = Cake.balanceOf(address(this));

		/**
		 * @dev Withdraw 100% Cake from CakePool.
		 */
		CompoundCakePool.withdraw(100);

		/**
		 * @dev Calculate balance after withdrawing Cake.
		 */
		uint256 afterBalance = Cake.balanceOf(address(this));

		/**
		 * @dev Calculate total payouts and return to MasterChef.
		 */
		uint256 totalPayouts = afterBalance.sub(beforeBalance);

		/**
		 * @dev Transfer Cake back to masterChef.
		 */
		Cake.transfer(masterChef, totalPayouts);

		/**
		 * @dev Return payouts amount.
		 */
		return totalPayouts;
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./IMasterChefV2.sol";
import "./IBoostContract.sol";

contract CakePool is Ownable, Pausable {
	using SafeERC20 for IERC20;

	struct UserInfo {
		uint256 shares; // number of shares for a user.
		uint256 lastDepositedTime; // keep track of deposited time for potential penalty.
		uint256 cakeAtLastUserAction; // keep track of cake deposited at the last user action.
		uint256 lastUserActionTime; // keep track of the last user action time.
		uint256 lockStartTime; // lock start time.
		uint256 lockEndTime; // lock end time.
		uint256 userBoostedShare; // boost share, in order to give the user higher reward. The user only enjoys the reward, so the principal needs to be recorded as a debt.
		bool locked; //lock status.
		uint256 lockedAmount; // amount deposited during lock period.
	}

	IERC20 public immutable token; // cake token.

	IMasterChefV2 public immutable masterchefV2;

	address public boostContract; // boost contract used in Masterchef.

	mapping(address => UserInfo) public userInfo;
	mapping(address => bool) public freeFeeUsers; // free fee users.

	uint256 public totalShares;
	uint256 public lastHarvestedTime;
	address public admin;
	address public treasury;
	address public operator;
	uint256 public cakePoolPID;
	uint256 public totalBoostDebt; // total boost debt.
	uint256 public totalLockedAmount; // total lock amount.

	uint256 public constant MAX_PERFORMANCE_FEE = 2000; // 20%
	uint256 public constant MAX_CALL_FEE = 100; // 1%
	uint256 public constant MAX_WITHDRAW_FEE = 500; // 5%
	uint256 public constant MAX_WITHDRAW_FEE_PERIOD = 1 weeks; // 1 week
	uint256 public constant MIN_LOCK_DURATION = 1 weeks; // 1 week
	uint256 public constant MAX_LOCK_DURATION_LIMIT = 1000 days; // 1000 days
	uint256 public constant BOOST_WEIGHT_LIMIT = 500 * 1e10; // 500%
	uint256 public constant PRECISION_FACTOR = 1e12; // precision factor.
	uint256 public constant PRECISION_FACTOR_SHARE = 1e28; // precision factor for share.
	uint256 public constant MIN_DEPOSIT_AMOUNT = 0.00001 ether;
	uint256 public constant MIN_WITHDRAW_AMOUNT = 0.00001 ether;
	uint256 public UNLOCK_FREE_DURATION = 1 weeks; // 1 week
	uint256 public MAX_LOCK_DURATION = 365 days; // 365 days
	uint256 public DURATION_FACTOR = 365 days; // 365 days, in order to calculate user additional boost.
	uint256 public DURATION_FACTOR_OVERDUE = 180 days; // 180 days, in order to calculate overdue fee.
	uint256 public BOOST_WEIGHT = 100 * 1e10; // 100%

	uint256 public performanceFee = 200; // 2%
	uint256 public performanceFeeContract = 200; // 2%
	uint256 public withdrawFee = 10; // 0.1%
	uint256 public withdrawFeeContract = 10; // 0.1%
	uint256 public overdueFee = 100 * 1e10; // 100%
	uint256 public withdrawFeePeriod = 72 hours; // 3 days

	event Deposit(
		address indexed sender,
		uint256 amount,
		uint256 shares,
		uint256 duration,
		uint256 lastDepositedTime
	);
	event Withdraw(address indexed sender, uint256 amount, uint256 shares);
	event Harvest(address indexed sender, uint256 amount);
	event Pause();
	event Unpause();
	event Init();
	event Lock(
		address indexed sender,
		uint256 lockedAmount,
		uint256 shares,
		uint256 lockedDuration,
		uint256 blockTimestamp
	);
	event Unlock(
		address indexed sender,
		uint256 amount,
		uint256 blockTimestamp
	);

	/**
	 * @notice Constructor
	 * @param _token: Cake token contract
	 * @param _masterchefV2: MasterChefV2 contract
	 * @param _admin: address of the admin
	 * @param _treasury: address of the treasury (collects fees)
	 * @param _operator: address of operator
	 * @param _pid: cake pool ID in MasterChefV2
	 */
	constructor(
		IERC20 _token,
		IMasterChefV2 _masterchefV2,
		address _admin,
		address _treasury,
		address _operator,
		uint256 _pid
	) {
		token = _token;
		masterchefV2 = _masterchefV2;
		admin = _admin;
		treasury = _treasury;
		operator = _operator;
		cakePoolPID = _pid;
	}

	/**
	 * @notice Deposits a dummy token to `MASTER_CHEF` MCV2.
	 * It will transfer all the `dummyToken` in the tx sender address.
	 * @param dummyToken The address of the token to be deposited into MCV2.
	 */
	function init(IERC20 dummyToken) external {
		uint256 balance = dummyToken.balanceOf(msg.sender);
		require(balance != 0, "Balance must exceed 0");
		dummyToken.safeTransferFrom(msg.sender, address(this), balance);
		dummyToken.approve(address(masterchefV2), balance);
		masterchefV2.deposit(cakePoolPID, balance);
		emit Init();
	}

	/**
	 * @notice Checks if the msg.sender is the admin address.
	 */
	modifier onlyAdmin() {
		require(msg.sender == admin, "admin: wut?");
		_;
	}

	/**
	 * @notice Checks if the msg.sender is either the cake owner address or the operator address.
	 */
	modifier onlyOperatorOrCakeOwner(address _user) {
		require(
			msg.sender == _user || msg.sender == operator,
			"Not operator or cake owner"
		);
		_;
	}

	/**
	 * @notice Update user info in Boost Contract.
	 * @param _user: User address
	 */
	function updateBoostContractInfo(address _user) internal {
		if (boostContract != address(0)) {
			UserInfo storage user = userInfo[_user];
			uint256 lockDuration = user.lockEndTime - user.lockStartTime;
			IBoostContract(boostContract).onCakePoolUpdate(
				_user,
				user.lockedAmount,
				lockDuration,
				totalLockedAmount,
				DURATION_FACTOR
			);
		}
	}

	/**
	 * @notice Update user share When need to unlock or charges a fee.
	 * @param _user: User address
	 */
	function updateUserShare(address _user) internal {
		UserInfo storage user = userInfo[_user];
		if (user.shares > 0) {
			if (user.locked) {
				// Calculate the user's current token amount and update related parameters.
				uint256 currentAmount = (balanceOf() * (user.shares)) /
					totalShares -
					user.userBoostedShare;
				totalBoostDebt -= user.userBoostedShare;
				user.userBoostedShare = 0;
				totalShares -= user.shares;
				//Charge a overdue fee after the free duration has expired.
				if (
					!freeFeeUsers[_user] &&
					((user.lockEndTime + UNLOCK_FREE_DURATION) <
						block.timestamp)
				) {
					uint256 earnAmount = currentAmount - user.lockedAmount;
					uint256 overdueDuration = block.timestamp -
						user.lockEndTime -
						UNLOCK_FREE_DURATION;
					if (overdueDuration > DURATION_FACTOR_OVERDUE) {
						overdueDuration = DURATION_FACTOR_OVERDUE;
					}
					// Rates are calculated based on the user's overdue duration.
					uint256 overdueWeight = (overdueDuration * overdueFee) /
						DURATION_FACTOR_OVERDUE;
					uint256 currentOverdueFee = (earnAmount * overdueWeight) /
						PRECISION_FACTOR;
					token.safeTransfer(treasury, currentOverdueFee);
					currentAmount -= currentOverdueFee;
				}
				// Recalculate the user's share.
				uint256 pool = balanceOf();
				uint256 currentShares;
				if (totalShares != 0) {
					currentShares =
						(currentAmount * totalShares) /
						(pool - currentAmount);
				} else {
					currentShares = currentAmount;
				}
				user.shares = currentShares;
				totalShares += currentShares;
				// After the lock duration, update related parameters.
				if (user.lockEndTime < block.timestamp) {
					user.locked = false;
					user.lockStartTime = 0;
					user.lockEndTime = 0;
					totalLockedAmount -= user.lockedAmount;
					user.lockedAmount = 0;
					emit Unlock(_user, currentAmount, block.timestamp);
				}
			} else if (!freeFeeUsers[_user]) {
				// Calculate Performance fee.
				uint256 totalAmount = (user.shares * balanceOf()) / totalShares;
				totalShares -= user.shares;
				user.shares = 0;
				uint256 earnAmount = totalAmount - user.cakeAtLastUserAction;
				uint256 feeRate = performanceFee;
				if (_isContract(_user)) {
					feeRate = performanceFeeContract;
				}
				uint256 currentPerformanceFee = (earnAmount * feeRate) / 10000;
				if (currentPerformanceFee > 0) {
					token.safeTransfer(treasury, currentPerformanceFee);
					totalAmount -= currentPerformanceFee;
				}
				// Recalculate the user's share.
				uint256 pool = balanceOf();
				uint256 newShares;
				if (totalShares != 0) {
					newShares =
						(totalAmount * totalShares) /
						(pool - totalAmount);
				} else {
					newShares = totalAmount;
				}
				user.shares = newShares;
				totalShares += newShares;
			}
		}
	}

	/**
	 * @notice Unlock user cake funds.
	 * @dev Only possible when contract not paused.
	 * @param _user: User address
	 */
	function unlock(address _user)
		external
		onlyOperatorOrCakeOwner(_user)
		whenNotPaused
	{
		UserInfo storage user = userInfo[_user];
		require(
			user.locked && user.lockEndTime < block.timestamp,
			"Cannot unlock yet"
		);
		depositOperation(0, 0, _user);
	}

	/**
	 * @notice Deposit funds into the Cake Pool.
	 * @dev Only possible when contract not paused.
	 * @param _amount: number of tokens to deposit (in CAKE)
	 * @param _lockDuration: Token lock duration
	 */
	function deposit(uint256 _amount, uint256 _lockDuration)
		external
		whenNotPaused
	{
		require(_amount > 0 || _lockDuration > 0, "Nothing to deposit");
		depositOperation(_amount, _lockDuration, msg.sender);
	}

	/**
	 * @notice The operation of deposite.
	 * @param _amount: number of tokens to deposit (in CAKE)
	 * @param _lockDuration: Token lock duration
	 * @param _user: User address
	 */
	function depositOperation(
		uint256 _amount,
		uint256 _lockDuration,
		address _user
	) internal {
		UserInfo storage user = userInfo[_user];
		if (user.shares == 0 || _amount > 0) {
			require(
				_amount > MIN_DEPOSIT_AMOUNT,
				"Deposit amount must be greater than MIN_DEPOSIT_AMOUNT"
			);
		}
		// Calculate the total lock duration and check whether the lock duration meets the conditions.
		uint256 totalLockDuration = _lockDuration;
		if (user.lockEndTime >= block.timestamp) {
			// Adding funds during the lock duration is equivalent to re-locking the position, needs to update some variables.
			if (_amount > 0) {
				user.lockStartTime = block.timestamp;
				totalLockedAmount -= user.lockedAmount;
				user.lockedAmount = 0;
			}
			totalLockDuration += user.lockEndTime - user.lockStartTime;
		}
		require(
			_lockDuration == 0 || totalLockDuration >= MIN_LOCK_DURATION,
			"Minimum lock period is one week"
		);
		require(
			totalLockDuration <= MAX_LOCK_DURATION,
			"Maximum lock period exceeded"
		);

		// Harvest tokens from Masterchef.
		harvest();

		// Handle stock funds.
		if (totalShares == 0) {
			uint256 stockAmount = available();
			token.safeTransfer(treasury, stockAmount);
		}
		// Update user share.
		updateUserShare(_user);

		// Update lock duration.
		if (_lockDuration > 0) {
			if (user.lockEndTime < block.timestamp) {
				user.lockStartTime = block.timestamp;
				user.lockEndTime = block.timestamp + _lockDuration;
			} else {
				user.lockEndTime += _lockDuration;
			}
			user.locked = true;
		}

		uint256 currentShares;
		uint256 currentAmount;
		uint256 userCurrentLockedBalance;
		uint256 pool = balanceOf();
		if (_amount > 0) {
			token.safeTransferFrom(_user, address(this), _amount);
			currentAmount = _amount;
		}

		// Calculate lock funds
		if (user.shares > 0 && user.locked) {
			userCurrentLockedBalance = (pool * user.shares) / totalShares;
			currentAmount += userCurrentLockedBalance;
			totalShares -= user.shares;
			user.shares = 0;

			// Update lock amount
			if (user.lockStartTime == block.timestamp) {
				user.lockedAmount = userCurrentLockedBalance;
				totalLockedAmount += user.lockedAmount;
			}
		}
		if (totalShares != 0) {
			currentShares =
				(currentAmount * totalShares) /
				(pool - userCurrentLockedBalance);
		} else {
			currentShares = currentAmount;
		}

		// Calculate the boost weight share.
		if (user.lockEndTime > user.lockStartTime) {
			// Calculate boost share.
			uint256 boostWeight = ((user.lockEndTime - user.lockStartTime) *
				BOOST_WEIGHT) / DURATION_FACTOR;
			uint256 boostShares = (boostWeight * currentShares) /
				PRECISION_FACTOR;
			currentShares += boostShares;
			user.shares += currentShares;

			// Calculate boost share , the user only enjoys the reward, so the principal needs to be recorded as a debt.
			uint256 userBoostedShare = (boostWeight * currentAmount) /
				PRECISION_FACTOR;
			user.userBoostedShare += userBoostedShare;
			totalBoostDebt += userBoostedShare;

			// Update lock amount.
			user.lockedAmount += _amount;
			totalLockedAmount += _amount;

			emit Lock(
				_user,
				user.lockedAmount,
				user.shares,
				(user.lockEndTime - user.lockStartTime),
				block.timestamp
			);
		} else {
			user.shares += currentShares;
		}

		if (_amount > 0 || _lockDuration > 0) {
			user.lastDepositedTime = block.timestamp;
		}
		totalShares += currentShares;

		user.cakeAtLastUserAction =
			(user.shares * balanceOf()) /
			totalShares -
			user.userBoostedShare;
		user.lastUserActionTime = block.timestamp;

		// Update user info in Boost Contract.
		updateBoostContractInfo(_user);

		emit Deposit(
			_user,
			_amount,
			currentShares,
			_lockDuration,
			block.timestamp
		);
	}

	/**
	 * @notice Withdraw funds from the Cake Pool.
	 * @param _amount: Number of amount to withdraw
	 */
	function withdrawByAmount(uint256 _amount) public {
		require(
			_amount > MIN_WITHDRAW_AMOUNT,
			"Withdraw amount must be greater than MIN_WITHDRAW_AMOUNT"
		);
		withdrawOperation(0, _amount);
	}

	/**
	 * @notice Withdraw funds from the Cake Pool.
	 * @param _shares: Number of shares to withdraw
	 */
	function withdraw(uint256 _shares) public {
		require(_shares > 0, "Nothing to withdraw");
		withdrawOperation(_shares, 0);
	}

	/**
	 * @notice The operation of withdraw.
	 * @param _shares: Number of shares to withdraw
	 * @param _amount: Number of amount to withdraw
	 */
	function withdrawOperation(uint256 _shares, uint256 _amount) internal {
		UserInfo storage user = userInfo[msg.sender];
		require(_shares <= user.shares, "Withdraw amount exceeds balance");
		require(user.lockEndTime < block.timestamp, "Still in lock");

		// Calculate the percent of withdraw shares, when unlocking or calculating the Performance fee, the shares will be updated.
		uint256 currentShare = _shares;
		uint256 sharesPercent = (_shares * PRECISION_FACTOR_SHARE) /
			user.shares;

		// Harvest token from MasterchefV2.
		harvest();

		// Update user share.
		updateUserShare(msg.sender);

		if (_shares == 0 && _amount > 0) {
			uint256 pool = balanceOf();
			currentShare = (_amount * totalShares) / pool; // Calculate equivalent shares
			if (currentShare > user.shares) {
				currentShare = user.shares;
			}
		} else {
			currentShare =
				(sharesPercent * user.shares) /
				PRECISION_FACTOR_SHARE;
		}
		uint256 currentAmount = (balanceOf() * currentShare) / totalShares;
		user.shares -= currentShare;
		totalShares -= currentShare;

		// Calculate withdraw fee
		if (
			!freeFeeUsers[msg.sender] &&
			(block.timestamp < user.lastDepositedTime + withdrawFeePeriod)
		) {
			uint256 feeRate = withdrawFee;
			if (_isContract(msg.sender)) {
				feeRate = withdrawFeeContract;
			}
			uint256 currentWithdrawFee = (currentAmount * feeRate) / 10000;
			token.safeTransfer(treasury, currentWithdrawFee);
			currentAmount -= currentWithdrawFee;
		}

		token.safeTransfer(msg.sender, currentAmount);

		if (user.shares > 0) {
			user.cakeAtLastUserAction =
				(user.shares * balanceOf()) /
				totalShares;
		} else {
			user.cakeAtLastUserAction = 0;
		}

		user.lastUserActionTime = block.timestamp;

		// Update user info in Boost Contract.
		updateBoostContractInfo(msg.sender);

		emit Withdraw(msg.sender, currentAmount, currentShare);
	}

	/**
	 * @notice Withdraw all funds for a user
	 */
	function withdrawAll() external {
		withdraw(userInfo[msg.sender].shares);
	}

	/**
	 * @notice Harvest pending CAKE tokens from MasterChef
	 */
	function harvest() internal {
		uint256 pendingCake = masterchefV2.pendingCake(
			cakePoolPID,
			address(this)
		);
		if (pendingCake > 0) {
			uint256 balBefore = available();
			masterchefV2.withdraw(cakePoolPID, 0);
			uint256 balAfter = available();
			emit Harvest(msg.sender, (balAfter - balBefore));
		}
	}

	/**
	 * @notice Set admin address
	 * @dev Only callable by the contract owner.
	 */
	function setAdmin(address _admin) external onlyOwner {
		require(_admin != address(0), "Cannot be zero address");
		admin = _admin;
	}

	/**
	 * @notice Set treasury address
	 * @dev Only callable by the contract owner.
	 */
	function setTreasury(address _treasury) external onlyOwner {
		require(_treasury != address(0), "Cannot be zero address");
		treasury = _treasury;
	}

	/**
	 * @notice Set operator address
	 * @dev Callable by the contract owner.
	 */
	function setOperator(address _operator) external onlyOwner {
		require(_operator != address(0), "Cannot be zero address");
		operator = _operator;
	}

	/**
	 * @notice Set Boost Contract address
	 * @dev Callable by the contract admin.
	 */
	function setBoostContract(address _boostContract) external onlyAdmin {
		require(_boostContract != address(0), "Cannot be zero address");
		boostContract = _boostContract;
	}

	/**
	 * @notice Set free fee address
	 * @dev Only callable by the contract admin.
	 * @param _user: User address
	 * @param _free: true:free false:not free
	 */
	function setFreeFeeUser(address _user, bool _free) external onlyAdmin {
		require(_user != address(0), "Cannot be zero address");
		freeFeeUsers[_user] = _free;
	}

	/**
	 * @notice Set performance fee
	 * @dev Only callable by the contract admin.
	 */
	function setPerformanceFee(uint256 _performanceFee) external onlyAdmin {
		require(
			_performanceFee <= MAX_PERFORMANCE_FEE,
			"performanceFee cannot be more than MAX_PERFORMANCE_FEE"
		);
		performanceFee = _performanceFee;
	}

	/**
	 * @notice Set performance fee for contract
	 * @dev Only callable by the contract admin.
	 */
	function setPerformanceFeeContract(uint256 _performanceFeeContract)
		external
		onlyAdmin
	{
		require(
			_performanceFeeContract <= MAX_PERFORMANCE_FEE,
			"performanceFee cannot be more than MAX_PERFORMANCE_FEE"
		);
		performanceFeeContract = _performanceFeeContract;
	}

	/**
	 * @notice Set withdraw fee
	 * @dev Only callable by the contract admin.
	 */
	function setWithdrawFee(uint256 _withdrawFee) external onlyAdmin {
		require(
			_withdrawFee <= MAX_WITHDRAW_FEE,
			"withdrawFee cannot be more than MAX_WITHDRAW_FEE"
		);
		withdrawFee = _withdrawFee;
	}

	/**
	 * @notice Set withdraw fee for contract
	 * @dev Only callable by the contract admin.
	 */
	function setWithdrawFeeContract(uint256 _withdrawFeeContract)
		external
		onlyAdmin
	{
		require(
			_withdrawFeeContract <= MAX_WITHDRAW_FEE,
			"withdrawFee cannot be more than MAX_WITHDRAW_FEE"
		);
		withdrawFeeContract = _withdrawFeeContract;
	}

	/**
	 * @notice Set withdraw fee period
	 * @dev Only callable by the contract admin.
	 */
	function setWithdrawFeePeriod(uint256 _withdrawFeePeriod)
		external
		onlyAdmin
	{
		require(
			_withdrawFeePeriod <= MAX_WITHDRAW_FEE_PERIOD,
			"withdrawFeePeriod cannot be more than MAX_WITHDRAW_FEE_PERIOD"
		);
		withdrawFeePeriod = _withdrawFeePeriod;
	}

	/**
	 * @notice Set MAX_LOCK_DURATION
	 * @dev Only callable by the contract admin.
	 */
	function setMaxLockDuration(uint256 _maxLockDuration) external onlyAdmin {
		require(
			_maxLockDuration <= MAX_LOCK_DURATION_LIMIT,
			"MAX_LOCK_DURATION cannot be more than MAX_LOCK_DURATION_LIMIT"
		);
		MAX_LOCK_DURATION = _maxLockDuration;
	}

	/**
	 * @notice Set DURATION_FACTOR
	 * @dev Only callable by the contract admin.
	 */
	function setDurationFactor(uint256 _durationFactor) external onlyAdmin {
		require(_durationFactor > 0, "DURATION_FACTOR cannot be zero");
		DURATION_FACTOR = _durationFactor;
	}

	/**
	 * @notice Set DURATION_FACTOR_OVERDUE
	 * @dev Only callable by the contract admin.
	 */
	function setDurationFactorOverdue(uint256 _durationFactorOverdue)
		external
		onlyAdmin
	{
		require(
			_durationFactorOverdue > 0,
			"DURATION_FACTOR_OVERDUE cannot be zero"
		);
		DURATION_FACTOR_OVERDUE = _durationFactorOverdue;
	}

	/**
	 * @notice Set UNLOCK_FREE_DURATION
	 * @dev Only callable by the contract admin.
	 */
	function setUnlockFreeDuration(uint256 _unlockFreeDuration)
		external
		onlyAdmin
	{
		require(_unlockFreeDuration > 0, "UNLOCK_FREE_DURATION cannot be zero");
		UNLOCK_FREE_DURATION = _unlockFreeDuration;
	}

	/**
	 * @notice Set BOOST_WEIGHT
	 * @dev Only callable by the contract admin.
	 */
	function setBoostWeight(uint256 _boostWeight) external onlyAdmin {
		require(
			_boostWeight <= BOOST_WEIGHT_LIMIT,
			"BOOST_WEIGHT cannot be more than BOOST_WEIGHT_LIMIT"
		);
		BOOST_WEIGHT = _boostWeight;
	}

	/**
	 * @notice Withdraw unexpected tokens sent to the Cake Pool
	 */
	function inCaseTokensGetStuck(address _token) external onlyAdmin {
		require(
			_token != address(token),
			"Token cannot be same as deposit token"
		);

		uint256 amount = IERC20(_token).balanceOf(address(this));
		IERC20(_token).safeTransfer(msg.sender, amount);
	}

	/**
	 * @notice Trigger stopped state
	 * @dev Only possible when contract not paused.
	 */
	function pause() external onlyAdmin whenNotPaused {
		_pause();
		emit Pause();
	}

	/**
	 * @notice Return to normal state
	 * @dev Only possible when contract is paused.
	 */
	function unpause() external onlyAdmin whenPaused {
		_unpause();
		emit Unpause();
	}

	/**
	 * @notice Calculate Performance fee.
	 * @param _user: User address
	 * @return Returns Performance fee.
	 */
	function calculatePerformanceFee(address _user)
		public
		view
		returns (uint256)
	{
		UserInfo storage user = userInfo[_user];
		if (user.shares > 0 && !user.locked && !freeFeeUsers[_user]) {
			uint256 pool = balanceOf() + calculateTotalPendingCakeRewards();
			uint256 totalAmount = (user.shares * pool) / totalShares;
			uint256 earnAmount = totalAmount - user.cakeAtLastUserAction;
			uint256 feeRate = performanceFee;
			if (_isContract(_user)) {
				feeRate = performanceFeeContract;
			}
			uint256 currentPerformanceFee = (earnAmount * feeRate) / 10000;
			return currentPerformanceFee;
		}
		return 0;
	}

	/**
	 * @notice Calculate overdue fee.
	 * @param _user: User address
	 * @return Returns Overdue fee.
	 */
	function calculateOverdueFee(address _user) public view returns (uint256) {
		UserInfo storage user = userInfo[_user];
		if (
			user.shares > 0 &&
			user.locked &&
			!freeFeeUsers[_user] &&
			((user.lockEndTime + UNLOCK_FREE_DURATION) < block.timestamp)
		) {
			uint256 pool = balanceOf() + calculateTotalPendingCakeRewards();
			uint256 currentAmount = (pool * (user.shares)) /
				totalShares -
				user.userBoostedShare;
			uint256 earnAmount = currentAmount - user.lockedAmount;
			uint256 overdueDuration = block.timestamp -
				user.lockEndTime -
				UNLOCK_FREE_DURATION;
			if (overdueDuration > DURATION_FACTOR_OVERDUE) {
				overdueDuration = DURATION_FACTOR_OVERDUE;
			}
			// Rates are calculated based on the user's overdue duration.
			uint256 overdueWeight = (overdueDuration * overdueFee) /
				DURATION_FACTOR_OVERDUE;
			uint256 currentOverdueFee = (earnAmount * overdueWeight) /
				PRECISION_FACTOR;
			return currentOverdueFee;
		}
		return 0;
	}

	/**
	 * @notice Calculate Performance Fee Or Overdue Fee
	 * @param _user: User address
	 * @return Returns  Performance Fee Or Overdue Fee.
	 */
	function calculatePerformanceFeeOrOverdueFee(address _user)
		internal
		view
		returns (uint256)
	{
		return calculatePerformanceFee(_user) + calculateOverdueFee(_user);
	}

	/**
	 * @notice Calculate withdraw fee.
	 * @param _user: User address
	 * @param _shares: Number of shares to withdraw
	 * @return Returns Withdraw fee.
	 */
	function calculateWithdrawFee(address _user, uint256 _shares)
		public
		view
		returns (uint256)
	{
		UserInfo storage user = userInfo[_user];
		if (user.shares < _shares) {
			_shares = user.shares;
		}
		if (
			!freeFeeUsers[msg.sender] &&
			(block.timestamp < user.lastDepositedTime + withdrawFeePeriod)
		) {
			uint256 pool = balanceOf() + calculateTotalPendingCakeRewards();
			uint256 sharesPercent = (_shares * PRECISION_FACTOR) / user.shares;
			uint256 currentTotalAmount = (pool * (user.shares)) /
				totalShares -
				user.userBoostedShare -
				calculatePerformanceFeeOrOverdueFee(_user);
			uint256 currentAmount = (currentTotalAmount * sharesPercent) /
				PRECISION_FACTOR;
			uint256 feeRate = withdrawFee;
			if (_isContract(msg.sender)) {
				feeRate = withdrawFeeContract;
			}
			uint256 currentWithdrawFee = (currentAmount * feeRate) / 10000;
			return currentWithdrawFee;
		}
		return 0;
	}

	/**
	 * @notice Calculates the total pending rewards that can be harvested
	 * @return Returns total pending cake rewards
	 */
	function calculateTotalPendingCakeRewards() public view returns (uint256) {
		uint256 amount = masterchefV2.pendingCake(cakePoolPID, address(this));
		return amount;
	}

	function getPricePerFullShare() external view returns (uint256) {
		return
			totalShares == 0
				? 1e18
				: (((balanceOf() + calculateTotalPendingCakeRewards()) *
					(1e18)) / totalShares);
	}

	/**
	 * @notice Current pool available balance
	 * @dev The contract puts 100% of the tokens to work.
	 */
	function available() public view returns (uint256) {
		return token.balanceOf(address(this));
	}

	/**
	 * @notice Calculates the total underlying tokens
	 * @dev It includes tokens held by the contract and the boost debt amount.
	 */
	function balanceOf() public view returns (uint256) {
		return token.balanceOf(address(this)) + totalBoostDebt;
	}

	/**
	 * @notice Checks if address is a contract
	 */
	function _isContract(address addr) internal view returns (bool) {
		uint256 size;
		assembly {
			size := extcodesize(addr)
		}
		return size > 0;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

pragma solidity ^0.8.0;

interface IMasterChefV2 {
	function deposit(uint256 _pid, uint256 _amount) external;

	function withdraw(uint256 _pid, uint256 _amount) external;

	function pendingCake(uint256 _pid, address _user)
		external
		view
		returns (uint256);

	function userInfo(uint256 _pid, address _user)
		external
		view
		returns (uint256, uint256);

	function emergencyWithdraw(uint256 _pid) external;
}

pragma solidity ^0.8.0;

interface IBoostContract {
	function onCakePoolUpdate(
		address _user,
		uint256 _lockedAmount,
		uint256 _lockedDuration,
		uint256 _totalLockedAmount,
		uint256 _maxLockDuration
	) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
}