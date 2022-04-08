/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

//TODO
/*
[X] - Pausable
[ ] - Whitelist/Blacklist
[ ] - Bloquear los BNBs que reciba hasta pasado el tiempo establecido
[ ] - Cambiar la fecha lockDate y lockEndsDate: De block.timestamp a fecha UNIX manual
[X] - Establecer un sistema de tasas para 3/4 cuentas diferentes
[ ] - Establecer sistema de tasas para liquidity de PancakeSwap
[ ] - Establecer sistema de recompensa por holdear ¿? Hacerlo a través de web3 y que el owner haga un approve?
[ ] - Valorar SafeERC20?¿
[ ] - Quemar tokens para ver cuanto sube el valor
[ ] - Probar a añadir liquidez desde el codigo
*/

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
    constructor() public {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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

abstract contract ERC20 is IERC20, IERC20Metadata, Context {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    //address public _presaleContractAddress;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) public {
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
    /*function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }*/

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
    /*function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }*/

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
        // unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        // }

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
        // unchecked {
            _balances[from] = fromBalance - amount;
        // }
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
        // unchecked {
            _balances[account] = accountBalance - amount;
        // }
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
            // unchecked {
                _approve(owner, spender, currentAllowance - amount);
            // }
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

    function setPresaleContractAddress() public virtual returns (address) {}

    function setLockedBalance(uint256 _amount) public virtual {}
}

library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            // solhint-disable-next-line no-inline-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            // solhint-disable-next-line no-inline-assembly
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() public {
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

contract TokenSimple is ERC20, Ownable, Pausable {

    // CONFIG START

    uint256 private denominator = 100;

    uint256 private swapThreshold = 0.0000005 ether; // The contract will only swap to ETH, once the fee tokens reach the specified threshold

    // Prevent Bots - If true, limits transactions to 1 transfer per block (whitelisted can execute multiple transactions).
    bool public limitTransactions;

    // uint256 public devTaxBuy;
    // uint256 public marketingTaxBuy;
    // uint256 public liquidityTaxBuy;
    // uint256 public administrationTaxBuy;
    
    // uint256 public devTaxSell;
    // uint256 public marketingTaxSell;
    // uint256 public liquidityTaxSell;
    // uint256 public administrationTaxSell;
    
    //Please set any address for taxes
    address public devTaxWallet = 0xba48e82Fa5586DF0C35f45b18287490bCA0AE6f3;
    address public marketingTaxWallet = 0xba48e82Fa5586DF0C35f45b18287490bCA0AE6f3;
    address public administrationTaxWallet = 0xba48e82Fa5586DF0C35f45b18287490bCA0AE6f3;
    address public liquidityTaxWallet = 0xba48e82Fa5586DF0C35f45b18287490bCA0AE6f3;

    address private uniSwapLiquidityAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //TESTNET

    uint256 public devTokens;
    uint256 public marketingTokens;
    uint256 public administrationTokens;
    uint256 public liquidityTokens;

    uint256 public lockEndsDate = 548 days; // Lock time is 1 year and a half.
    uint256 public lockDate;

    //address public presaleContractAddress;
    address private _presaleContractAddress;

    mapping (address => bool) public contractsWhiteList;
    mapping (address => uint) public lastTXBlock;

    mapping (uint8 => address) public managers;
    mapping (bytes32 => bool) public executedTask;
    uint16 public taskIndex;

    mapping (address => bool) private excludeList;

    mapping (string => uint256) public buyTaxes;
    mapping (string => uint256) public sellTaxes;
    
    bool public taxStatus = true;
    
    IUniswapV2Router02 private uniswapV2Router02;
    IUniswapV2Factory private uniswapV2Factory;
    IUniswapV2Pair private uniswapV2Pair;

    // Time lock for progressive release of team, marketing and platform balances
    struct TimeLock {
        uint256 totalAmount;
        uint256 lockedBalance;
    }
    mapping (address => TimeLock) public timeLocks; 

    //CONFIG END

    modifier isManager() {
        require(managers[0] == msg.sender || managers[1] == msg.sender || managers[2] == msg.sender, "Not manager");
        _;
    }

    modifier isWhitelisted(address _beneficiary) {
        require(contractsWhiteList[_beneficiary]);
        _;
    }

    // event Received(address, uint);

    constructor () ERC20("TokenSimple4", "TKNS4") public {
        mint(msg.sender, 50000000000 * (10 ** uint256(decimals())));
        mint(address(this), 50000000000 * (10 ** uint256(decimals())));

        _transferOwnership(msg.sender);

        uniswapV2Router02 = IUniswapV2Router02(uniSwapLiquidityAddress); //TESTNET
        
        
        //uniswapV2Router02 = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //PRO
        uniswapV2Factory = IUniswapV2Factory(uniswapV2Router02.factory());
        uniswapV2Pair = IUniswapV2Pair(uniswapV2Factory.createPair(address(this), uniswapV2Router02.WETH()));

        managers[0] = msg.sender;
        managers[1] = devTaxWallet;
        managers[2] = administrationTaxWallet;

        setBuyTax(1, 1, 1, 1, 1);
        setSellTax(1, 1, 1, 1, 1);

        exclude(msg.sender);
        exclude(address(this));

        lockDate = block.timestamp + lockEndsDate; // Date when BNBs will be unlocked for the owner
    }

    function mint(address _to, uint256 _amount) private onlyOwner {
        _mint(_to, _amount);
    }

    /*function burn(uint256 _value) public returns (bool) {
        _burn(_msgSender(), _value);
        return true;
    }*/

    function burn(uint256 _value) public returns (address) {
        _burn(_msgSender(), _value);
        return _msgSender();
    }

    /**
     * @dev Calculates the tax, transfer it to the contract. If the user is selling, and the swap threshold is met, it executes the tax.
     */
    function handleTax(address from, address to, uint256 amount) private returns (uint256) {
        address[] memory sellPath = new address[](2);
        sellPath[0] = address(this);
        sellPath[1] = uniswapV2Router02.WETH();
        
        if(!isExcluded(from) && !isExcluded(to)) {
            uint256 tax;
            uint256 baseUnit = amount / denominator;
            if(from == address(uniswapV2Pair)) {
                tax += baseUnit * buyTaxes["marketing"];
                tax += baseUnit * buyTaxes["dev"];
                tax += baseUnit * buyTaxes["liquidity"];
                tax += baseUnit * buyTaxes["administration"];
                
                if(tax > 0) {
                    _transfer(from, address(this), tax);   
                }
                
                marketingTokens += baseUnit * buyTaxes["marketing"];
                devTokens += baseUnit * buyTaxes["dev"];
                liquidityTokens += baseUnit * buyTaxes["liquidity"];
                administrationTokens += baseUnit * buyTaxes["administration"];
            } else if(to == address(uniswapV2Pair)) {
                tax += baseUnit * sellTaxes["marketing"];
                tax += baseUnit * sellTaxes["dev"];
                tax += baseUnit * sellTaxes["liquidity"];
                tax += baseUnit * sellTaxes["administration"];
                
                if(tax > 0) {
                    _transfer(from, address(this), tax);   
                }
                
                marketingTokens += baseUnit * sellTaxes["marketing"];
                devTokens += baseUnit * sellTaxes["dev"];
                liquidityTokens += baseUnit * sellTaxes["liquidity"];
                administrationTokens += baseUnit * sellTaxes["administration"];
                
                uint256 taxSum = marketingTokens + devTokens + liquidityTokens + administrationTokens;
                
                if(taxSum == 0) return amount;
                
                uint256 ethValue = uniswapV2Router02.getAmountsOut(marketingTokens + devTokens + liquidityTokens + administrationTokens, sellPath)[1];
                
                if(ethValue >= swapThreshold) {
                    uint256 startBalance = address(this).balance;

                    uint256 toSell = marketingTokens + devTokens + liquidityTokens / 2 + administrationTokens;
                    
                    _approve(address(this), address(uniswapV2Router02), toSell);
            
                    uniswapV2Router02.swapExactTokensForETH(
                        toSell,
                        0,
                        sellPath,
                        address(this),
                        block.timestamp
                    );
                    
                    uint256 ethGained = address(this).balance - startBalance;
                    
                    uint256 liquidityToken = liquidityTokens / 2;
                    uint256 liquidityETH = (ethGained * ((liquidityTokens / 2 * 10**18) / taxSum)) / 10**18;
                    
                    uint256 marketingETH = (ethGained * ((marketingTokens * 10**18) / taxSum)) / 10**18;
                    uint256 devETH = (ethGained * ((devTokens * 10**18) / taxSum)) / 10**18;
                    uint256 administrationETH = (ethGained * ((administrationTokens * 10**18) / taxSum)) / 10**18;
                    
                    _approve(address(this), address(uniswapV2Router02), liquidityToken);
                    
                    (uint amountToken, ,) = uniswapV2Router02.addLiquidityETH{value: liquidityETH}(
                        address(this),
                        liquidityToken,
                        0,
                        0,
                        liquidityTaxWallet,
                        block.timestamp
                    );
                    
                    uint256 remainingTokens = (marketingTokens + devTokens + liquidityTokens + administrationTokens) - (toSell + amountToken);
                    
                    if(remainingTokens > 0) {
                        _transfer(address(this), devTaxWallet, remainingTokens);
                    }
                    
                    (bool sent1,) = marketingTaxWallet.call{value: marketingETH}("");
                    require(sent1, "Failed to send ETH");
                    (bool sent2,) = devTaxWallet.call{value: devETH}("");
                    require(sent2, "Failed to send ETH");
                    (bool sent3,) = administrationTaxWallet.call{value: administrationETH}("");
                    require(sent3, "Failed to send ETH");
                    
                    if(ethGained - (marketingETH + devETH + liquidityETH + administrationETH) > 0) {
                        (bool sent4,) = marketingTaxWallet.call{value: ethGained - (marketingETH + devETH + liquidityETH + administrationETH)}("");
                        require(sent4, "Failed to send ETH");
                    }
                    
                    marketingTokens = 0;
                    devTokens = 0;
                    liquidityTokens = 0;
                    administrationTokens = 0;
                }
                
            }
            
            amount -= tax;
        }
        
        return amount;
    }

    /**
     * @dev Triggers the tax handling functionality
     */
    function triggerTax() public onlyOwner {
        handleTax(address(0), address(uniswapV2Pair), 0);
    }

    function triggerTax(uint256 _amount) public onlyOwner {
        handleTax(address(0), address(uniswapV2Pair), _amount);
    }

    /*function addLiquidityToPS(uint256 amountToken) external payable onlyOwner {
        require(msg.value > 0, "Add more BNB liquidity");
        require(amountToken > 0, "Add more Token liquidity");
        approve(address(uniswapV2Router02), amountToken);

        uniswapV2Router02.addLiquidityETH{value: msg.value}(
            address(this),
            amountToken,
            0,
            0,
            owner(),
            block.timestamp
        );
    }*/

    function addLiquidityToPS(uint256 amountToken) external payable onlyOwner {
        //uint256 ethGained = 100000000000000000;
        //uint256 baseUnit = amountTokens / denominator;
        //uint256 taxSum = baseUnit * buyTaxes["liquidity"];
        //liquidityTokens += baseUnit * buyTaxes["liquidity"];

        //uint256 liquidityToken = liquidityTokens / 2;
        //uint256 liquidityETH = (ethGained * ((liquidityTokens / 2 * 10**18) / taxSum)) / 10**18;
        // require(msg.value > 0, "Add more BNB liquidity");
        // require(amountToken > 0, "Add more Token liquidity");
        _approve(address(this), address(uniswapV2Router02), amountToken);
        //_spendAllowance(msg.sender, address(uniswapV2Pair), amountToken);
        //approve(address(uniswapV2Router02), amountToken);
                    
        uniswapV2Router02.addLiquidityETH{value: msg.value}(
            address(this),
            amountToken,
            0,
            0,
            owner(),
            block.timestamp+10000
        );
        
    }

    function pause() public isManager {
        _pause();
    }

    function unpause() public isManager {
        _unpause();
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    /*function releaseTokens(address _address) public {
        require(block.timestamp > lockDate, "Unlock date not reached yet");
        if (unlockableAmount >=  timeLocks[_account].totalAmount) {
            timeLocks[_account].lockedBalance = 0;
        }
    }*/

    
    function setPresaleContractAddress() public override returns (address) {
        require(_presaleContractAddress == address(0), "Address already initialized");
        _presaleContractAddress = msg.sender;
        return _presaleContractAddress;
    }

    function presaleContractAddress() public view returns (address) {
        return _presaleContractAddress;
    }

    function setLockedBalance() public payable returns (bool) {
        require(msg.sender == presaleContractAddress(), "You are not allowed to call this function");
        timeLocks[owner()].lockedBalance = msg.value;
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override whenNotPaused virtual {
        //require(whenNotPaused(), "Token transfer while paused");
        /*require(!isBlacklisted(msg.sender), "CoinToken: sender blacklisted");
        require(!isBlacklisted(recipient), "CoinToken: recipient blacklisted");
        require(!isBlacklisted(tx.origin), "CoinToken: sender blacklisted");*/
        
        if(taxStatus) {
            amount = handleTax(sender, recipient, amount);   
        }
        
        super._transfer(sender, recipient, amount);
    }

    /*function transfer(address to, uint256 amount) public virtual override whenNotPaused returns (bool) {
        address owner = _msgSender();
        require(checkTransferLimit(), "Transfers are limited to 1 per block");
        require(amount <= (balanceOf(owner) - getLockedBalance(owner)));
        _transfer(owner, to, amount);
        return true;
    }*/

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(checkTransferLimit(), "Transfers are limited to 1 per block"); //SI ESTO FUNCIONA, PASARLO A _transfer
        //require(amount <= (balanceOf(_msgSender()) - getLockedBalance(_msgSender())));
        _transfer(_msgSender(), to, amount);
        return true;
    }

    /*function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override whenNotPaused returns (bool) {
        address spender = _msgSender();
        require(checkTransferLimit(), "Transfers are limited to 1 per block");
        require(amount <= (balanceOf(owner()) - getLockedBalance(owner())));
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }*/

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        require(checkTransferLimit(), "Transfers are limited to 1 per block");
        //require(amount <= (balanceOf(_msgSender()) - getLockedBalance(_msgSender())));
        _spendAllowance(from, _msgSender(), amount);
        _transfer(from, to, amount);
        return true;
    }

    receive() external payable {
        //setLockedBalance();
    }

    //fallback() external payable {}

    function checkTransferLimit() internal returns (bool) {
        address _caller = msg.sender;
        if (limitTransactions == true && contractsWhiteList[_caller] != true) {
            if (lastTXBlock[_caller] == block.number) {
                return false;
            } else {
                lastTXBlock[_caller] = block.number;
                return true;
            }
        } else {
            return true;
        }
    }

    function enableTXLimit(bytes memory _sig) public isManager {
        uint8 mId = 1;
        bytes32 taskHash = keccak256(abi.encode(taskIndex, mId));
        verifyApproval(taskHash, _sig);
        limitTransactions = true;
    }
    
    function disableTXLimit(bytes memory _sig) public isManager {
        uint8 mId = 2;
        bytes32 taskHash = keccak256(abi.encode(taskIndex, mId));
        verifyApproval(taskHash, _sig);
        limitTransactions = false;
    }

    function verifyApproval(bytes32 _taskHash, bytes memory _sig) private {
        require(executedTask[_taskHash] == false, "Task already executed");
        address mSigner = ECDSA.recover(ECDSA.toEthSignedMessageHash(_taskHash), _sig);
        require(mSigner == managers[0] || mSigner == managers[1] || mSigner == managers[2], "Invalid signature"  );
        require(mSigner != msg.sender, "Signature from different managers required");
        executedTask[_taskHash] = true;
        taskIndex += 1;
    }

    /*function includeWhiteList(address _contractAddress, bytes memory _sig) public isManager {
        uint8 mId = 3;
        bytes32 taskHash = keccak256(abi.encode(_contractAddress, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        contractsWhiteList[_contractAddress] = true;
    }
    
    function removeWhiteList(address _contractAddress, bytes memory _sig) public isManager {
        uint8 mId = 4;
        bytes32 taskHash = keccak256(abi.encode(_contractAddress, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        contractsWhiteList[_contractAddress] = false;
    }*/

    //FUNCIONES PARA LA ICO
    /*function addToWhiteList(address _contractAddress) public isManager {
        contractsWhiteList[_contractAddress] = true;
    }

    function removeFromWhiteList(address _contractAddress) public isManager {
        contractsWhiteList[_contractAddress] = false;
    }

    function addManyToWhitelist(address[] memory _contractAddresses) public isManager {
        for (uint256 i = 0; i < _contractAddresses.length; i++) {
        contractsWhiteList[_contractAddresses[i]] = true;
        }
    }*/

    /*function addToBlacklist(address _contractAddress) public isManager {
        require(!blacklist[_contractAddress], "CoinToken: Account is already blacklisted");
        blacklist[_contractAddress] = true;
    }*/

    /**
     * @dev Sets tax for buys.
     */
     //COMPROBAR SI PASO ALGUN PARAMETRO VACIO QUE VALOR COGE, PARA QUE NO SE GUARDE COMO 0
    function setBuyTax(uint256 owner, uint256 dev, uint256 marketing, uint256 liquidity, uint256 administration) public onlyOwner {
        buyTaxes["owner"] = owner;
        buyTaxes["dev"] = dev;
        buyTaxes["marketing"] = marketing;
        buyTaxes["liquidity"] = liquidity;
        buyTaxes["administration"] = administration;
    }
    
    /**
     * @dev Sets tax for sells.
     */
     //COMPROBAR SI PASO ALGUN PARAMETRO VACIO QUE VALOR COGE, PARA QUE NO SE GUARDE COMO 0
    function setSellTax(uint256 owner, uint256 dev, uint256 marketing, uint256 liquidity, uint256 administration) public onlyOwner {
        sellTaxes["owner"] = owner;
        sellTaxes["dev"] = dev;
        sellTaxes["marketing"] = marketing;
        sellTaxes["liquidity"] = liquidity;
        sellTaxes["administration"] = administration;
    }

    /**
     * @dev Sets wallets for taxes.
     */
     //COMPROBAR SI ALGUN PARAMETRO ESTA VACIO
    function setTaxWallets(address dev, address marketing, address administration, address liquidity) public onlyOwner {
        devTaxWallet = dev;
        marketingTaxWallet = marketing;
        administrationTaxWallet = administration;
        liquidityTaxWallet = liquidity;
    }
    
    /**
     * @dev Enables tax globally.
     */
    function enableTax() public onlyOwner {
        require(!taxStatus, "Tax is already enabled");
        taxStatus = true;
    }
    
    /**
     * @dev Disables tax globally.
     */
    function disableTax() public onlyOwner {
        require(taxStatus, "Tax is already disabled");
        taxStatus = false;
    }

    /**
     * @dev Excludes the specified account from tax.
     */
    function exclude(address account) public onlyOwner {
        require(!isExcluded(account), "Account is already excluded");
        excludeList[account] = true;
    }

    /**
     * @dev Re-enables tax on the specified account.
     */
    function removeExclude(address account) public onlyOwner {
        require(isExcluded(account), "Account is not excluded");
        excludeList[account] = false;
    }

    /**
     * @dev Returns true if the account is excluded, and false otherwise.
     */
    function isExcluded(address account) public view returns (bool) {
        return excludeList[account];
    }

    function changeManager(address _manager, uint8 _index, bytes memory _sig) public isManager {
        require(_index >= 0 && _index <= 2, "Invalid index");
        uint8 mId = 100;
        bytes32 taskHash = keccak256(abi.encode(_manager, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        managers[_index] = _manager;
    }

    function getLockedBalance(address _wallet) public view returns (uint256 lockedBalance) {
        return timeLocks[_wallet].lockedBalance;
    }

    /*function setLockedBalance() public returns (bool) {

        return true;
    }*/

}