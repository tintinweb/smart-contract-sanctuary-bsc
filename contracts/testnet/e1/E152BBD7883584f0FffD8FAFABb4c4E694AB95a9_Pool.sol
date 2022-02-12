/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

//SPDX-License-Identifier: Unlicense
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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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


interface IApeRouter01 {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IApeRouter02 is IApeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

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

contract Pool is ERC20 {
    mapping(address => uint256) public depositBalance;

    struct BlockBalance {
        uint256 depositBalance;
        uint256 valuesP;
        uint256 valuesL;
    }

    mapping(address => BlockBalance[]) public depositBlocks;
    mapping(address => bool) public isAddedAsset;

    uint256 public totalDeposit;
    address[] public assets;
    address public depositToken;
    address public wETH;

    address public pancakeRouter;

    event Deposit(
        address investor,
        uint256 amount,
        uint256 lp,
        uint256 timestamp
    );

    constructor() ERC20("Pool Asset Token", "APOOL") {
        depositToken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
        wETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
        pancakeRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    }

    function deposit(uint256 amount) public {
        require(amount > 0, "INVALID_AMOUNT");
        //depositBalance[msg.sender] = depositBalance[msg.sender] + amount;

        //totalDeposit = totalDeposit + amount;
        // uint256 valuesProfit;
        // uint256 valuesLoss;
        // if (currentPoolValues >= totalDeposit) {
        //     valuesProfit = currentPoolValues - totalDeposit;
        // } else {
        //     valuesLoss = totalDeposit - currentPoolValues;
        // }

        // BlockBalance memory blockBalance;
        // blockBalance.depositBalance = amount;
        // blockBalance.valuesP = valuesProfit;
        // blockBalance.valuesL = valuesLoss;
        // depositBlocks[msg.sender].push(blockBalance);

        uint256 lp;
        uint256 poolValues = _getPoolValues();
        if (poolValues == 0 || totalSupply() == 0) {
            lp = amount + poolValues;
        } else {
            lp = (amount * totalSupply()) / poolValues;
        }

        _mint(msg.sender, lp);

        require(
            IERC20(depositToken).transferFrom(msg.sender, address(this), amount)
        );

        emit Deposit(msg.sender, amount, lp, block.timestamp);
    }

    function swap(address[] calldata path, uint256 amountIn) public {
        uint256[] memory amountsOut = IApeRouter02(pancakeRouter).getAmountsOut(
            amountIn,
            path
        );

        uint256 amountOutMin = (995 * amountsOut[1]) / 1000;

        address token = path[0] == depositToken ? path[1] : path[0];
        if (!isAddedAsset[token]) {
            isAddedAsset[token] = true;
            assets.push(token);
        }
        require(IERC20(path[0]).approve(pancakeRouter, amountIn));
        IApeRouter02(pancakeRouter).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            address(this),
            block.timestamp + 20 minutes
        );
    }

    function exit(uint256 lp) public {
        require(balanceOf(msg.sender) >= lp, "INSUFF_AMOUNT");
        uint256 preDepositReceived = _getAssetBalance(depositToken);
        uint256 myReceived;
        if (preDepositReceived > 0) {
            uint256 ratio = lp * preDepositReceived;
            if (ratio >= totalSupply()) {
                myReceived = ratio / totalSupply();
            }
        }
        _swapToDeposit(lp);
        uint256 postDepositReceived = _getAssetBalance(depositToken);
        uint256 totalReceived = (postDepositReceived + myReceived) -
            preDepositReceived;
        require(IERC20(depositToken).transfer(msg.sender, totalReceived));
        _burn(msg.sender, lp);
    }

    // function exit(uint256 indexWallet) public {
    //     uint256 currentValues = _getPoolValues();
    //     BlockBalance memory blockBalance = depositBlocks[msg.sender][
    //         indexWallet
    //     ];
    //     require(blockBalance.depositBalance > 0, "EMPTY_BALANCE");

    //     uint256 depositTokenBalance = _getAssetBalance(depositToken);
    //     uint256 totalProfit;
    //     uint256 totalCurProfit;
    //     uint256 totalCurLoss;
    //     uint256 totalLoss;
    //     uint256 totalExit;
    //     uint256 myLoss;
    //     uint256 ratio;
    //     uint256 myProfit;

    //     // profit
    //     if (currentValues >= totalDeposit) {
    //         totalProfit = currentValues - totalDeposit;
    //         if (
    //             blockBalance.valuesP > 0 ||
    //             (blockBalance.valuesP == 0 && blockBalance.valuesL == 0)
    //         ) {
    //             if (totalProfit >= blockBalance.valuesP) {
    //                 totalCurProfit = totalProfit - blockBalance.valuesP; //ขาดทุน
    //                 if (totalCurProfit > 0) {
    //                     ratio = blockBalance.depositBalance * totalCurProfit;
    //                     if (ratio >= totalDeposit) {
    //                         myProfit = ratio / totalDeposit;
    //                     }
    //                 }
    //                 totalExit = blockBalance.depositBalance + myProfit;
    //             } else {
    //                 totalLoss = blockBalance.valuesP - totalProfit;
    //                 if (totalLoss > 0) {
    //                     ratio = blockBalance.depositBalance * totalLoss;
    //                     if (ratio >= totalDeposit) {
    //                         myLoss = ratio / totalDeposit;
    //                     }
    //                 }
    //                 totalExit = blockBalance.depositBalance - myLoss;
    //             }
    //         }
    //         if (blockBalance.valuesL > 0) {
    //             totalProfit = totalProfit + blockBalance.valuesP;
    //             if (totalProfit > 0) {
    //                 ratio = blockBalance.depositBalance * totalProfit;
    //                 if (ratio >= totalDeposit) {
    //                     myProfit = ratio / totalDeposit;
    //                 }
    //             }
    //             totalExit = blockBalance.depositBalance + myProfit;
    //         }
    //     } else {
    //         // loss
    //         totalLoss = totalDeposit - currentValues;

    //         if (
    //             blockBalance.valuesP > 0 ||
    //             (blockBalance.valuesP == 0 && blockBalance.valuesL == 0)
    //         ) {
    //             if (totalLoss > blockBalance.valuesP) {
    //                 totalCurLoss = totalLoss - blockBalance.valuesP; // เสียน้อยลง
    //                 if (totalCurLoss > 0) {
    //                     ratio = blockBalance.depositBalance * totalCurLoss;
    //                     if (ratio >= totalDeposit) {
    //                         myLoss = ratio / totalDeposit;
    //                     }
    //                 }
    //                 totalExit = blockBalance.depositBalance - myLoss;
    //             } else {
    //                 totalLoss = blockBalance.valuesP - totalLoss; // ไม่เสียแต่กำไรน้อยลง
    //                 if (totalLoss > 0) {
    //                     ratio = blockBalance.depositBalance * totalLoss;
    //                     if (ratio >= totalDeposit) {
    //                         myProfit = ratio / totalDeposit;
    //                     }
    //                 }
    //                 totalExit = blockBalance.depositBalance + myProfit;
    //             }
    //         }

    //         if (blockBalance.valuesL > 0) {
    //             totalLoss = totalLoss + blockBalance.valuesL; // คิดลบแล้วลบไปอีก
    //             if (totalLoss > 0) {
    //                 ratio = blockBalance.depositBalance * totalLoss;
    //                 if (ratio >= totalDeposit) {
    //                     myLoss = ratio / totalDeposit;
    //                 }
    //             }
    //             totalExit = blockBalance.depositBalance - myLoss;
    //         }
    //     }

    //     if (depositTokenBalance >= totalExit) {
    //         require(IERC20(depositToken).transfer(msg.sender, totalExit));
    //     } else {
    //         uint256 amountNeed = totalExit - depositTokenBalance;
    //         _swapToDeposit(amountNeed, currentValues);
    //         require(IERC20(depositToken).transfer(msg.sender, totalExit));
    //     }

    //     totalDeposit = totalDeposit - blockBalance.depositBalance;
    //     _burn(
    //         msg.sender,
    //         depositBlocks[msg.sender][indexWallet].depositBalance
    //     );
    //     depositBlocks[msg.sender][indexWallet].depositBalance = 0;
    // }

    function getPoolValues() public view returns (uint256) {
        return _getPoolValues();
    }

    // internal
    function _swapToDeposit(uint256 lp) internal {
        uint256 tokenBalance;
        uint256 tokenReceived;
        uint256 ratio;

        for (uint256 i = 0; i < assets.length; i++) {
            tokenBalance = _getAssetBalance(assets[i]);
            ratio = lp * tokenBalance;
            if (ratio < totalSupply()) {
                continue;
            }

            tokenReceived = ratio / totalSupply();

            _swap(assets[i], depositToken, tokenReceived);
        }
    }

    function _swap(
        address token0,
        address token1,
        uint256 amountIn
    ) internal {
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        uint256[] memory amountsOut = IApeRouter02(pancakeRouter).getAmountsOut(
            amountIn,
            path
        );

        uint256 amountOutMin = (995 * amountsOut[1]) / 1000;
        require(IERC20(path[0]).approve(pancakeRouter, amountIn));
        IApeRouter02(pancakeRouter).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            address(this),
            block.timestamp + 20 minutes
        );
    }

    function _swapExact(
        address token0,
        address token1,
        uint256 amountNeed
    ) internal {
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        uint256[] memory amountsIn = IApeRouter02(pancakeRouter).getAmountsIn(
            amountNeed,
            path
        );

        uint256 amountInMax = (1005 * amountsIn[0]) / 1000;
        require(IERC20(path[0]).approve(pancakeRouter, amountInMax));
        IApeRouter02(pancakeRouter).swapTokensForExactTokens(
            amountNeed,
            amountInMax,
            path,
            address(this),
            block.timestamp + 20 minutes
        );
    }

    function _getPoolValues() internal view returns (uint256) {
        uint256 totalValues = _getAssetBalance(depositToken);
        for (uint256 i = 0; i < assets.length; i++) {
            totalValues = totalValues + _getValueInDepositToken(assets[i]);
        }

        return totalValues;
    }

    function _getValueInDepositToken(address token)
        internal
        view
        returns (uint256)
    {
        uint256 assetBalance = _getAssetBalance(token);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = depositToken;

        uint256[] memory amountsOut = IApeRouter02(pancakeRouter).getAmountsOut(
            assetBalance,
            path
        );

        return amountsOut[1];
    }

    function _getAssetBalance(address token) internal view returns (uint256) {
        if (token == wETH) {
            return address(this).balance;
        } else {
            return IERC20(token).balanceOf(address(this));
        }
    }
}