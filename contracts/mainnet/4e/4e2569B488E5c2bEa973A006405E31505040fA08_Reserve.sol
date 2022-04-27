// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IrVault.sol";
import "@routerprotocol/router-sdk/contracts/nonupgradeable/RouterCrossTalk.sol";

// @note remove ownable if not required
contract Reserve is ERC20, Ownable, RouterCrossTalk {
    using SafeMath for uint256;

    address public vault;
    IERC20 public immutable token;
    uint8 public immutable chainId;

    uint256 private crossChainGas;
    constructor(address _vault, uint8 _chainId,address _handler) RouterCrossTalk(_handler) ERC20("",""
            // string(abi.encodePacked("rVault ", ERC20(IrVault(_vault).token()).name())),
            // string(abi.encodePacked("r", ERC20(IrVault(_vault).token()).symbol()))
        )
    {
        vault = _vault;
        token = IrVault(_vault).token();
        chainId = _chainId;
         setLink(msg.sender);
    }

    modifier onlyVault() {
        require(msg.sender == vault, "!Vault");
        _;
    }

    function deposit(uint256 _amount) external onlyVault {
        uint256 shares = 0;
        if (totalSupply() == 0) {
            shares = _amount;
            _mint(tx.origin, shares);
        } else {
            _routerCrossTalkSendDeposit(
                _amount,
                token.balanceOf(address(this)),
                tx.origin);//tx.origin dangerous so verify the security of the contract
            }
    }

    function setCrossChainGas(uint256 _gas) external onlyOwner {
        crossChainGas = _gas;
    }

    function setVault(address _vault) external {
        vault = _vault;
    }

    //todo: only set by admin
    function setFeesToken(address _addr) public {
        setFeeToken(_addr);
    }

    function _routerCrossTalkSendDeposit(uint256 _amount, uint256 balance, address user) internal {
        bytes4 _selector = bytes4(keccak256("balance(_amount)"));
        bytes memory _data = abi.encode(_amount, balance, user);
        bool success = routerSend(chainId, _selector , _data , crossChainGas);
        // return success;
    }

    function _routerCrossTalkSendStake(uint8 _chainId) external {
        bytes4 _selector = bytes4(keccak256("stake(_amount)"));
        bytes memory _data = abi.encode();
        bool success = routerSend(_chainId, _selector , _data , crossChainGas);
        // return success;
    }

    function _routerSyncHandler(bytes4 _interface, bytes memory _data)
        internal
        virtual
        override
        returns (bool, bytes memory) {
        // (uint256 _v1, uint256 _v2, address _v3) = abi.decode(_data, (uint256, uint256, address)); //pool and amount
        if(bytes4(keccak256("balance(_amount)")) == _interface) {
            (uint256 _v1, uint256 _v2, address _v3) = abi.decode(_data, (uint256, uint256, address)); //pool and amount
            // (bool success, bytes memory returnData) = address(this).call(abi.encodeWithSelector(_interface, _v));
            //calling an internal function here
            _receiveMintRequest(_v1, _v2, _v3);
            return (true, "");
        // } else if (bytes4(keccak256("withdraw(_asset)")) == _interface) {
        //     (bool success, bytes memory returnData) = address(this).call(abi.encodeWithSelector(_interface, _v1));
        //     return (success, returnData);
        } else if (bytes4(keccak256("burn(_shares)")) == _interface) {
            (address _v1, uint256 _v2) = abi.decode(_data, (address, uint256));
            //(bool success, bytes memory returnData) = address(this).call(abi.encodeWithSelector(_interface, _v1));
            burnShares(_v1,_v2);
        }
    }

    function _receiveMintRequest(uint256 _pool, uint256 _amount, address _user) internal {
        uint256 shares = (_amount.mul(totalSupply())).div(_pool);
        _mint(_user, shares);
    }
    function withdraw(
        uint256 _shares,
        bytes32 resourceId,
        bytes calldata data,
        // uint256[] memory distribution,
        // uint256[] memory flags,
        // address[] memory path,//@TODO leaving it for vdfyn demo
        address feeTokenAddress
    ) external onlyVault {
        uint256 reserveBalance = token.balanceOf(address(this));

        bytes4 _selector = bytes4(keccak256("unstake(_amount)"));
        bytes memory _data = abi.encode(
            _shares,
            reserveBalance,
            totalSupply(),
            tx.origin,
            resourceId,
            data,
            // distribution,
            // flags,
            // path,@TODO leaving it for vdfyn demo
            feeTokenAddress
        );
        bool success = routerSend(chainId, _selector , _data , crossChainGas);

          // @note the below goes inside withdraw of Reserve
        // uint256 r = (IrVault(vault).balance(chainId).mul(_shares)).div(totalSupply());
        // _burn(msg.sender, _shares);

        // // Check balance
        // uint256 b = token.balanceOf(address(this));
        // if (b < r) {
        //     uint256 _withdraw = r.sub(b);
        //     IController(controller).withdraw(address(token), _withdraw);
        //     uint256 _after = token.balanceOf(address(this));
        //     uint256 _diff = _after.sub(b);
        //     if (_diff < _withdraw) {
        //         r = b.add(_diff);
        //     }
        // }

        // token.safeTransfer(msg.sender, r);
    }

    function burnShares(address user, uint256 _shares) internal {
        _burn(user, _shares);
    }

    function getFunds(uint256 amount, address recipient) external {
        token.transfer(recipient, amount);
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

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
interface IrVault {
    function token() external view returns (IERC20);

    function deposit(uint256) external;

    function balance(uint8) external view returns (uint256);

    function depositAll() external;

    function withdraw(uint256) external;

    function withdrawAll() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "../interfaces/iGenericHandler.sol";
import "./iRouterCrossTalk.sol";

abstract contract RouterCrossTalk is Context , iRouterCrossTalk, ERC165 {

    iGenericHandler handler;

    address private linkSetter;

    address private feeToken;

    mapping ( uint8 => address ) private Chain2Addr; // CHain ID to Address

    modifier isHandler(){
        require(_msgSender() == address(handler) , "RouterCrossTalk : Only GenericHandler can call this function" );
        _;
    }

    modifier isLinkSet(uint8 _chainID){
        require(Chain2Addr[_chainID] == address(0) , "RouterCrossTalk : Cross Chain Contract to Chain ID set" );
        _;
    }

    modifier isLinkUnSet(uint8 _chainID){
        require(Chain2Addr[_chainID] != address(0) , "RouterCrossTalk : Cross Chain Contract to Chain ID is not set" );
        _;
    }

    modifier isLinkSync( uint8 _srcChainID, address _srcAddress ){
        require(Chain2Addr[_srcChainID] == _srcAddress , "RouterCrossTalk : Source Address Not linked" );
        _;
    }

    modifier isSelf(){
        require(_msgSender() == address(this) , "RouterCrossTalk : Can only be called by Current Contract" );
        _;
    }

    constructor( address _handler ) {
        handler = iGenericHandler(_handler);
    }

    /*
    * @notice Used to set linker address, this function is internal and can only be set by contract owner or admins
    * @param _addr Address of linker.
    */
    function setLink( address _addr ) internal {
        linkSetter = _addr;
    }

    /*
    * @notice Used to set fee Token address, this function is internal and can only be set by contract owner or admins
    * @param _addr Address of linker.
    */
    function setFeeToken( address _addr ) internal {
        feeToken = _addr;
    }

    function fetchHandler( ) external override view returns ( address ) {
        return address(handler);
    }

    function fetchLinkSetter( ) external override view returns( address) {
        return linkSetter;
    }

    function fetchLink( uint8 _chainID ) external override view returns( address) {
        return Chain2Addr[_chainID];
    }

    function fetchFeetToken(  ) external override view returns( address) {
        return feeToken;
    }


    /*
    * @notice routerSend This is internal function to generate a cross chain communication request.
    * @param _destChainId Destination ChainID.
    * @param _selector Selector to interface on destination side.
    * @param _data Data to be sent on Destination side.
    */
    function routerSend( uint8 destChainId , bytes4 _selector , bytes memory _data , uint256 _gas) internal isLinkUnSet( destChainId ) returns (bool success) {
        uint8 cid = handler.fetch_chainID();
        bytes32 hash = _hash(address(this),Chain2Addr[destChainId],destChainId, _selector, _data);
        handler.genericDeposit(destChainId , _selector , _data, hash , _gas , feeToken );
        emit CrossTalkSend( cid , destChainId , address(this), Chain2Addr[destChainId] ,_selector, _data , hash );
        return true;
    }

    function routerSync(uint8 srcChainID , address srcAddress , bytes4 _selector , bytes memory _data , bytes32 hash ) external override isLinkSync( srcChainID , srcAddress ) isHandler returns ( bool , bytes memory ) {
        uint8 cid = handler.fetch_chainID();
        bytes32 Dhash = _hash(Chain2Addr[srcChainID],address(this),cid, _selector, _data);
        require( Dhash == hash , "RouterSync : Valid Hash" );
        ( bool success , bytes memory _returnData ) = _routerSyncHandler( _selector , _data );
        emit CrossTalkReceive( srcChainID , cid , srcAddress , address(this), _selector, _data , hash );
        return ( success , _returnData );
    }

    /*
    * @notice _hash This is internal function to generate the hash of all data sent or received by the contract.
    * @param _srcAddres Source Address.
    * @param _destAddress Destination Address.
    * @param _destChainId Destination ChainID.
    * @param _selector Selector to interface on destination side.
    * @param _data Data to interface on Destination side.
    */
    function _hash(address _srcAddres , address _destAddress , uint8 _destChainId , bytes4 _selector , bytes memory _data) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            _srcAddres,
            _destAddress,
            _destChainId,
            _selector,
            keccak256(_data)
        ));
    }

    function Link(uint8 _chainID , address _linkedContract) external override isHandler isLinkSet(_chainID) {
        Chain2Addr[_chainID] = _linkedContract;
        emit Linkevent( _chainID , _linkedContract );
    }

    function Unlink(uint8 _chainID ) external override isHandler {
        emit Unlinkevent( _chainID , Chain2Addr[_chainID] );
        Chain2Addr[_chainID] = address(0);
    }

    function approveFees(address _feeToken , uint256 _value) external {
        IERC20 token = IERC20(_feeToken);
        token.approve( address(handler) , _value );
    }

    /*
    * @notice _routerSyncHandler This is internal function to control the handling of various selectors and its corresponding .
    * @param _selector Selector to interface.
    * @param _data Data to be handled.
    */
    function _routerSyncHandler( bytes4 _selector , bytes memory _data ) internal virtual returns ( bool ,bytes memory );
    uint256[100] private __gap;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface iGenericHandler {

    struct RouterLinker {
        address _rSyncContract;
        uint8 _chainID;
        address _linkedContract;
        uint8 linkerType;
    }

    /*
    * @notic UnMapContract Unmaps the contract from the RouterCrossTalk Contract
    * @param linker The Data object consisting of target Contract , CHainid , Contract to be Mapped and linker type.
    * @param _sign Signature of Linker data object signed by linkerSetter address.
    */
    function MapContract( RouterLinker calldata linker , bytes memory _sign ) external;

    /*
    * @notic UnMapContract Unmaps the contract from the RouterCrossTalk Contract
    * @param linker The Data object consisting of target Contract , CHainid , Contract to be unMapped and linker type.
    * @param _sign Signature of Linker data object signed by linkerSetter address.
    */
    function UnMapContract(RouterLinker calldata linker , bytes memory _sign ) external;

    /*
    * @notic generic deposit on generic handler contract
    * @param _chainid Chain id to be transacted
    * @param _selector Selector for the crosschain interface
    * @param _data Data to be transferred
    * @param _hash Hash of the data sent to the contract
    * @param _gas Gas Specified for the contract function
    * @param _feeToken Fee Token Specified for the contract function
    */
    function genericDeposit( uint8 _destChainID, bytes4 _selector, bytes memory _data, bytes32 _hash, uint256 _gas, address _feeToken) external;

    /*
    * @notic fetches ChainID for the native chain
    */
    function fetch_chainID( ) external view returns ( uint8 );

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface iRouterCrossTalk is IERC165 {

    /*
    * @notice Link event is emitted when a new link is created.
    * @param _chainid Chain id the contract is linked to.
    * @param linkedContract Contract address linked to.
    */
    event Linkevent( uint8 indexed ChainID , address indexed linkedContract );

    /*
    * @notice UnLink event is emitted when a link is removed.
    * @param _chainid Chain id the contract is unlinked to.
    * @param linkedContract Contract address unlinked to.
    */
    event Unlinkevent( uint8 indexed ChainID , address indexed linkedContract );

    /*
    * @notice CrossTalkSend Event is emited when a request is generated in soruce side when cross chain request is generated.
    * @param sourceChain Source ChainID.
    * @param destChain Destination ChainID.
    * @param sourceAddress Source Address.
    * @param destinationAddress Destination Address.
    * @param _selector Selector to interface on destination side.
    * @param _data Data to interface on Destination side.
    * @param _hash Hash of the data sent.
    */
    event CrossTalkSend(uint8 indexed sourceChain , uint8 indexed destChain , address sourceAddress , address destinationAddress ,bytes4 indexed _selector, bytes _data , bytes32 _hash );

    /*
    * @notice CrossTalkReceive Event is emited when a request is recived in destination side when cross chain request accepted by contract.
    * @param sourceChain Source ChainID.
    * @param destChain Destination ChainID.
    * @param sourceAddress Source Address.
    * @param destinationAddress Destination Address.
    * @param _selector Selector to interface on destination side.
    * @param _data Data to interface on Destination side.
    * @param _hash Hash of the data sent.
    */
    event CrossTalkReceive(uint8 indexed sourceChain , uint8 indexed destChain , address sourceAddress , address destinationAddress ,bytes4 indexed _selector, bytes _data , bytes32 _hash );

    /*
    * @notice routerSync This is a public function and can only be called by Generic Handler of router infrastructure
    * @param srcChainID Source ChainID.
    * @param srcAddress Destination ChainID.
    * @param _selector Selector to interface on destination side.
    * @param _data Data to interface on Destination side.
    * @param _hash Hash of the data sent.
    */
    function routerSync(uint8 srcChainID , address srcAddress , bytes4 _selector , bytes calldata _data , bytes32 hash ) external returns ( bool , bytes memory );

    /*
    * @notice Link This is a public function and can only be called by Generic Handler of router infrastructure
    * @notice This function links contract on other chain ID's.
    * @notice This is an administrative function and can only be initiated by linkSetter address.
    * @param _chainID network Chain ID linked Contract linked to.
    * @param _linkedContract Linked Contract address.
    */
    function Link(uint8 _chainID , address _linkedContract) external;

    /*
    * @notice UnLink This is a public function and can only be called by Generic Handler of router infrastructure
    * @notice This function unLinks contract on other chain ID's.
    * @notice This is an administrative function and can only be initiated by linkSetter address.
    * @param _chainID network Chain ID linked Contract linked to.
    */
    function Unlink(uint8 _chainID ) external;

    /*
    * @notice fetchLinkSetter This is a public function and fetches the linksetter address.
    */
    function fetchLinkSetter( ) external view returns( address);

    /*
    * @notice fetchLinkSetter This is a public function and fetches the address the contract is linked to.
    * @param _chainID Chain ID information.
    */
    function fetchLink( uint8 _chainID ) external view returns( address);

    /*
    * @notice fetchLinkSetter This is a public function and fetches the generic handler address.
    */
    function fetchHandler( ) external view returns ( address );


    /*
    * @notice fetchFeetToken This is a public function and fetches the fee token set by admin.
    */
    function fetchFeetToken(  ) external view returns( address);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}