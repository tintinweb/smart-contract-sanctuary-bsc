// SPDX-License-Identifier: None
// =======

// Note to the reader: currently the team chooses not to allow reuse and modification of the Emulai source code.
// This might change in the future.
// We love open source philosophy and on the long run that will be our path too.
// As of now the team is heavily invested in development and we prefer to keep working on it until we hit the market and we feel both the project and the organization are ready to become open.
// Should you need our written authorization to perform any of the actions listed in the Notice, or have inquiries on the conditions set out in the Notice, please contact us at [email protected] 

// Definitions:
//  1. “Copyright”: copyright and copyright-like laws that apply to other kinds of works.
//  2. “Copyright holder”: Emulai S.r.l.s. and Emulai Corp.
//  3. “Work”: Emulai source code, the Emulai project and all its elements.
//  4. “Derivative work”: any creation derived from or based on the Work.
//  5. “Propagation”: any action concerning the Work that, without permission, would make you directly or secondarily liable for infringement under applicable copyright law, except executing it on a device or modifying a private copy of the Work. Propagation includes e.g. copying and distribution of the Work (with or without modification) and making the Work available to the public.
//  6. “Conveyance”: any kind of propagation that enables other parties to make or receive copies of the Work. Mere interaction with a user through a computer network, with no transfer of a copy, does not fall under the scope of this definition.
//  7. “Notice”: the present copyright and legal notice.

// THIS WORK IS PROPRIETARY.
// PARTIAL OR TOTAL COPY, MODIFICATION, TRANSFER, DISTRIBUTION, PROPAGATION, CONVEYANCE, LICENSE AND SUBLICENSE, REPRODUCTION, CREATION OF DERIVATIVE WORKS, PRIVATE, COMMERCIAL AND/OR PRODUCTION USE OF THE WORK OR PARTS THEREOF, VIA ANY MEDIUM, IS STRICTLY PROHIBITED WITHOUT WRITTEN AUTHORIZATION OF THE COPYRIGHT HOLDER.

// The receipt or possession of the Work and/or any parts thereof does not convey or imply any right to use them for any purpose other than the purpose for which they were provided to you.
// The Copyright Holder does not grant any copyright, patent rights or any intellectual property rights whatsoever.

// The Work is provided "AS IS", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and non infringement.
// In no event shall the Copyright Holder be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the Work or the use or other dealings in the Work.

// The Notice shall be included in all copies or substantial portions of the Work, unless otherwise agreed in writing with the Copyright Holder.

// =======
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Consumer.sol";

contract Coordinator {
  address private _owner;
  // TODO: Make it can changeable and can only be changed by deployer.
  uint private _feeAmount = 1e16; // 0.01 BNB
  uint private _totalFeeAmount = 0;
  mapping(address => mapping(string => bool)) private _requests; // requests[consumer.address][requestId]

  event Deposited(address, uint, uint);

  receive() external payable {
    emit Deposited(address(0), msg.value, address(this).balance);
  }

  constructor() {
   _owner = msg.sender;
  }

  modifier onlyOwner {
    require(_owner == msg.sender, 'Only owner can proceed!');
    _;
  }

  function queueDataRequest(address consumer, string memory requestId, string memory payload) public {
    require(address(this).balance >= _feeAmount, 'Insufficient funds');
    _totalFeeAmount += _feeAmount;
    // TODO: update token fee
//    ERC20 ERC20Interface = ERC20(tokenAddress);
//    uint balance = ERC20Interface.balanceOf(address(this));
//
//    if (ERC20Interface.allowance(address(this), routerAddress) >= amountIn) {
//      return balance;
//    }
//    ERC20Interface.approve(routerAddress, 115792089237316195423570985008687907853269984665640564039457584007913129639935);
//    ERC20Interface.transferFrom(address(this) , _owner, _amount);
  }

  function depositTokens(address tokenAddress, uint256 _amount) external payable {
    address from = msg.sender;
    address to = address(this);

    ERC20 ERC20Interface = ERC20(tokenAddress);

    ERC20Interface.transferFrom(from, to, _amount);

    emit Deposited(tokenAddress, _amount, ERC20Interface.balanceOf(from));
  }

  function getTotalFeeAmount() external view returns(uint) {
    return _totalFeeAmount;
  }

  function getFeeAmount() external view returns(uint) {
    return _feeAmount;
  }

  function getRequestIdState(address consumerAddress, string memory requestId) external view returns(bool) {
    return _requests[consumerAddress][requestId];
  }

  function fulfillConsumer(address payable consumerAddress, string memory requestId, string memory result) external onlyOwner {
    require(!_requests[consumerAddress][requestId], 'Request already fulfilled');

    Consumer consumer = Consumer(consumerAddress);
    consumer.fulfillRequest(requestId, result);

    _requests[consumerAddress][requestId] = true;
  }
}

// SPDX-License-Identifier: None
// =======

// Note to the reader: currently the team chooses not to allow reuse and modification of the Emulai source code.
// This might change in the future.
// We love open source philosophy and on the long run that will be our path too.
// As of now the team is heavily invested in development and we prefer to keep working on it until we hit the market and we feel both the project and the organization are ready to become open.
// Should you need our written authorization to perform any of the actions listed in the Notice, or have inquiries on the conditions set out in the Notice, please contact us at [email protected] 

// Definitions:
//  1. “Copyright”: copyright and copyright-like laws that apply to other kinds of works.
//  2. “Copyright holder”: Emulai S.r.l.s. and Emulai Corp.
//  3. “Work”: Emulai source code, the Emulai project and all its elements.
//  4. “Derivative work”: any creation derived from or based on the Work.
//  5. “Propagation”: any action concerning the Work that, without permission, would make you directly or secondarily liable for infringement under applicable copyright law, except executing it on a device or modifying a private copy of the Work. Propagation includes e.g. copying and distribution of the Work (with or without modification) and making the Work available to the public.
//  6. “Conveyance”: any kind of propagation that enables other parties to make or receive copies of the Work. Mere interaction with a user through a computer network, with no transfer of a copy, does not fall under the scope of this definition.
//  7. “Notice”: the present copyright and legal notice.

// THIS WORK IS PROPRIETARY.
// PARTIAL OR TOTAL COPY, MODIFICATION, TRANSFER, DISTRIBUTION, PROPAGATION, CONVEYANCE, LICENSE AND SUBLICENSE, REPRODUCTION, CREATION OF DERIVATIVE WORKS, PRIVATE, COMMERCIAL AND/OR PRODUCTION USE OF THE WORK OR PARTS THEREOF, VIA ANY MEDIUM, IS STRICTLY PROHIBITED WITHOUT WRITTEN AUTHORIZATION OF THE COPYRIGHT HOLDER.

// The receipt or possession of the Work and/or any parts thereof does not convey or imply any right to use them for any purpose other than the purpose for which they were provided to you.
// The Copyright Holder does not grant any copyright, patent rights or any intellectual property rights whatsoever.

// The Work is provided "AS IS", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and non infringement.
// In no event shall the Copyright Holder be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the Work or the use or other dealings in the Work.

// The Notice shall be included in all copies or substantial portions of the Work, unless otherwise agreed in writing with the Copyright Holder.

// =======
pragma solidity ^0.8.0;

import "./Coordinator.sol";

contract Consumer {
  address payable private _queuerAddress;
  mapping(string => string) private _results;

  constructor(
    address payable queuerAddress
  ) public {
    _queuerAddress = queuerAddress;
  }

  function requestData(string memory requestId, string memory payload) external {
    Coordinator queuer = Coordinator(_queuerAddress);
    queuer.queueDataRequest(msg.sender, requestId, payload);
  }

  function fulfillRequest(string memory requestId, string memory result) external {
    _results[requestId] = result;
  }

  function getQueuerAddress() external view returns (address) {
    return _queuerAddress;
  }

  function getResultByRequestId(string memory requestId) external view returns (string memory) {
    return _results[requestId];
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