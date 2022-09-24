// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./Auth.sol";
import "./Context.sol";
import "./IFactory.sol";
import "./IRouter.sol";
import "./IERC20.sol";
import "./IERC20Metadata.sol";

contract Toptalentlauncpad is Context, IERC20, IERC20Metadata, Auth {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    uint256 public constant feeDenominator = 100;

    uint256 public constant burnFee = 2;
    uint256 public constant marketingFee = 2;
    uint256 public constant liquidityFee = 3;

    address public burnWallet;
    address public marketingWallet;
    address public liquidityWallet;

    address public router;

    uint256 public minAmountToAdd;
    bool public isTradingEnabled;

    bool private inSwapAndLiquify;

    event LogFallback(address indexed from, uint256 indexed amount);
    event LogReceive(address indexed from, uint256 indexed amount);

    event LogSetLiquidityWallet(address indexed liquidityWallet);
    event LogSetMarketingWallet(address indexed marketingWallet);
    event LogSetBurnWallet(address indexed burnWallet);
    event LogSetMinAmountToAdd(uint256 indexed minAmountToAdd);
    event LogSetIsTradingEnabled(bool isTradingEnabled);
    event LogSetRouter(address indexed router);

    event LogSwapAndLiquidity(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );
    event LogMint(address indexed account, uint256 indexed amount);
    event LogBurn(address indexed account, uint256 indexed amount);

    constructor(
        string memory name_,
        string memory symbol_,
        address _router,
        address _marketingWallet,
        address _liquidityWallet,
        uint256 _minAmountToAdd,
        bool _isTradingEnabled
    ) {
        _name = name_;
        _symbol = symbol_;
        _mint(msg.sender, 333444555 * 10**18);

        IFactory(IRouter(_router).factory()).createPair(
            address(this),
            IRouter(_router).WETH()
        );

        setBurnWallet(address(0xdead));
        setMarketingWallet(_marketingWallet);
        setLiquidityWallet(_liquidityWallet);
        setMinAmountToAdd(_minAmountToAdd);
        setIsTradingEnabled(_isTradingEnabled);
        setRouter(_router);
    }

    modifier lockSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
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
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual authorized {
        unchecked {
            _balances[from] -= amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        if (!isTradingEnabled) {
            return _basicTransfer(from, to, amount);
        }

        bool canAddLiquidity = _balances[address(this)] >= minAmountToAdd;

        if (canAddLiquidity && !inSwapAndLiquify) {
            swapAndAddLiquidity(minAmountToAdd);
        }

        uint256 burnFeeAmount = (amount * burnFee) / feeDenominator;
        uint256 marketingFeeAmount = (amount * marketingFee) / feeDenominator;
        uint256 liquidityFeeAmount = (amount * liquidityFee) / feeDenominator;

        uint256 transferAmount = amount -
            (burnFeeAmount + marketingFeeAmount + liquidityFeeAmount);
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += transferAmount;

            _balances[burnWallet] += burnFeeAmount;
            _balances[marketingWallet] += marketingFeeAmount;
            _balances[address(this)] += liquidityFeeAmount;
        }

        emit Transfer(from, burnWallet, burnFeeAmount);
        emit Transfer(from, marketingWallet, marketingFeeAmount);
        emit Transfer(from, address(this), liquidityFeeAmount);

        emit Transfer(from, to, transferAmount);

        _afterTokenTransfer(from, to, amount);
    }

    function swapAndAddLiquidity(uint256 amounts) private lockSwap {
        uint256 half = amounts / 2;
        uint256 otherHalf = amounts - half;

        uint256 initialBalance = address(this).balance;

        swapTokensForETH(half);

        uint256 newBalance = address(this).balance - initialBalance;

        addLiquidity(otherHalf, newBalance);

        emit LogSwapAndLiquidity(half, newBalance, otherHalf);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = IRouter(router).WETH();

        _approve(address(this), router, tokenAmount);

        IRouter(router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // slippage is unavoidable
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), router, tokenAmount);

        // Skip `Return value check`
        IRouter(router).addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityWallet,
            block.timestamp
        );
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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
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

    // Receive and Fallback functions
    receive() external payable {
        emit LogReceive(msg.sender, msg.value);
    }

    fallback() external payable {
        emit LogFallback(msg.sender, msg.value);
    }

    function setLiquidityWallet(address _liquidityWallet) public authorized {
        require(
            address(_liquidityWallet) != address(0),
            "Toptalentlauncpad: ZERO_ADDRESS"
        );
        require(
            address(_liquidityWallet) != address(liquidityWallet),
            "Toptalentlauncpad: SAME_ADDRESS"
        );

        liquidityWallet = _liquidityWallet;

        emit LogSetLiquidityWallet(liquidityWallet);
    }

    function setMarketingWallet(address _marketingWallet) public authorized {
        require(
            address(_marketingWallet) != address(0),
            "Toptalentlauncpad: ZERO_ADDRESS"
        );
        require(
            address(_marketingWallet) != address(marketingWallet),
            "Toptalentlauncpad: SAME_ADDRESS"
        );

        marketingWallet = _marketingWallet;

        emit LogSetMarketingWallet(marketingWallet);
    }

    function setBurnWallet(address _burnWallet) public authorized {
        require(
            address(_burnWallet) != address(0),
            "Toptalentlauncpad: ZERO_ADDRESS"
        );
        require(
            address(_burnWallet) != address(burnWallet),
            "Toptalentlauncpad: SAME_ADDRESS"
        );

        burnWallet = _burnWallet;

        emit LogSetBurnWallet(burnWallet);
    }

    function setMinAmountToAdd(uint256 _minAmountToAdd) public authorized {
        require(_minAmountToAdd > 0, "Toptalentlauncpad: ZERO_AMOUNT");
        require(
            _minAmountToAdd != minAmountToAdd,
            "Toptalentlauncpad: SAME_AMOUNT"
        );

        minAmountToAdd = _minAmountToAdd;

        emit LogSetMinAmountToAdd(minAmountToAdd);
    }

    function setIsTradingEnabled(bool _isTradingEnabled) public authorized {
        require(
            isTradingEnabled != _isTradingEnabled,
            "Toptalentlauncpad: SAME_VALUE"
        );
        isTradingEnabled = _isTradingEnabled;

        emit LogSetIsTradingEnabled(isTradingEnabled);
    }

    function setRouter(address _router) public authorized {
        require(
            address(_router) != address(0),
            "Toptalentlauncpad: ZERO_ADDRESS"
        );
        require(
            address(_router) != address(router),
            "Toptalentlauncpad: SAME_ADDRESS"
        );

        router = _router;

        emit LogSetRouter(router);
    }

    function mint(address account, uint256 amount) external authorized {
        _mint(account, amount);

        emit LogMint(account, amount);
    }

    function burn(address account, uint256 amount) external authorized {
        _burn(account, amount);

        emit LogBurn(account, amount);
    }

    function withdrawFakeAsset(
        IERC20 _token,
        address _recipient,
        uint256 _amount
    ) external authorized {
        if ((address(this)).balance > 0) {
            payable(_recipient).transfer((address(this)).balance);
        }

        require(
            address(_token) != address(this),
            "Toptalentlauncpad: CANNOT_WITHDRAW_STAKING_TOKEN"
        );
        require(
            _amount <= _token.balanceOf(address(this)),
            "Toptalentlauncpad: INSUFFICIENT_FUNDS"
        );
        require(
            _token.transfer(_recipient, _amount),
            "Toptalentlauncpad: FAIL_TRANSFER"
        );
    }
}

//SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

abstract contract Auth {
	address public owner;
	mapping(address => bool) internal authorizations;

	constructor() {
		owner = msg.sender;
		authorizations[msg.sender] = true;
	}

	modifier onlyOwner() {
		require(isOwner(msg.sender), "!OWNER");
		_;
	}

	modifier authorized() {
		require(isAuthorized(msg.sender), "!AUTHORIZED");
		_;
	}

	function authorize(address adr) public authorized {
		authorizations[adr] = true;
	}

	function unauthorize(address adr) public authorized {
		authorizations[adr] = false;
	}

	function isOwner(address account) public view returns (bool) {
		return account == owner;
	}

	function isAuthorized(address adr) public view returns (bool) {
		return authorizations[adr];
	}

	function transferOwnership(address payable adr) public authorized {
		owner = adr;
		authorizations[adr] = true;
		emit OwnershipTransferred(adr);
	}

	function renounceOwnership() public authorized {
		address dead = 0x000000000000000000000000000000000000dEaD;
		owner = dead;
		emit OwnershipTransferred(dead);
	}

	event OwnershipTransferred(address owner);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.4;

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

pragma solidity 0.8.4;

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

pragma solidity 0.8.4;

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity 0.8.4;

import "./IERC20.sol";

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