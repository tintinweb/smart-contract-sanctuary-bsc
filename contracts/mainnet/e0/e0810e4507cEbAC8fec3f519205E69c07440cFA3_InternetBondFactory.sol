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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

import "./interfaces/IERC20.sol";
import "./interfaces/IInternetBondRatioFeed.sol";
import "./SimpleToken.sol";
import "./libraries/Utils.sol";

contract InternetBond is SimpleToken, IERC20InternetBond {

    IInternetBondRatioFeed public ratioFeed;
    bool internal _rebasing;

    function ratio() public view override returns (uint256) {
        return ratioFeed.getRatioFor(_originAddress);
    }

    function isRebasing() public view override returns (bool) {
        return _rebasing;
    }

    function totalSupply() public view override returns (uint256) {
        return _sharesToBonds(super.totalSupply());
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _sharesToBonds(super.balanceOf(account));
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 shares = _bondsToShares(amount);
        _transfer(_msgSender(), recipient, shares, false);
        emit Transfer(_msgSender(), recipient, _sharesToBonds(shares));
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _sharesToBonds(super.allowance(owner, spender));
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        uint256 shares = _bondsToShares(amount);
        _approve(_msgSender(), spender, shares, false);
        emit Approval(_msgSender(), spender, allowance(_msgSender(), spender));
        return true;
    }

    function increaseAllowance(address spender, uint256 amount) public override returns (bool) {
        uint256 shares = _bondsToShares(amount);
        _increaseAllowance(_msgSender(), spender, shares, false);
        emit Approval(_msgSender(), spender, allowance(_msgSender(), spender));
        return true;
    }

    function decreaseAllowance(address spender, uint256 amount) public override returns (bool) {
        uint256 shares = _bondsToShares(amount);
        _decreaseAllowance(_msgSender(), spender, shares, false);
        emit Approval(_msgSender(), spender, allowance(_msgSender(), spender));
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 shares = _bondsToShares(amount);
        _transfer(sender, recipient, shares, false);
        emit Transfer(sender, recipient, _sharesToBonds(shares));
        _decreaseAllowance(sender, _msgSender(), shares, false);
        emit Approval(sender, _msgSender(), allowance(sender, _msgSender()));
        return true;
    }

    // NB: mint accepts amount in shares
    function mint(address account, uint256 shares) public onlyOwner override {
        require(account != address(0));
        _totalSupply += shares;
        _balances[account] += shares;
        emit Transfer(address(0), account, _sharesToBonds(shares));
    }

    // NB: burn accepts amount in shares
    function burn(address account, uint256 shares) public onlyOwner override {
        require(account != address(0));
        _balances[account] -= shares;
        _totalSupply -= shares;
        emit Transfer(account, address(0), _sharesToBonds(shares));
    }

    function _sharesToBonds(uint256 amount) internal view returns (uint256) {
        if (_rebasing) {
            uint256 currentRatio = ratio();
            require(currentRatio > 0, "ratio not available");
            return Utils.multiplyAndDivideCeil(amount, 10 ** decimals(), currentRatio);
        } else {
            return amount;
        }
    }

    function _bondsToShares(uint256 amount) internal view returns (uint256) {
        if (_rebasing) {
            uint256 currentRatio = ratio();
            require(currentRatio > 0, "ratio not available");
            return Utils.multiplyAndDivideFloor(amount, currentRatio, 10 ** decimals());
        } else {
            return amount;
        }
    }

    function initAndObtainOwnership(bytes32 symbol, bytes32 name, uint256 originChain, address originAddress, address ratioFeedAddress, bool rebasing) external emptyOwner {
        super.initAndObtainOwnership(symbol, name, originChain, originAddress);
        require(ratioFeedAddress != address(0x0), "no ratio feed");
        ratioFeed = IInternetBondRatioFeed(ratioFeedAddress);
        _rebasing = rebasing;
    }
}

contract InternetBondFactory {
    address private _template;
    constructor() {
        _template = InternetBondFactoryUtils.deployInternetBondTemplate(this);
    }

    function getImplementation() public view returns (address) {
        return _template;
    }
}

library InternetBondFactoryUtils {

    bytes32 constant internal INTERNET_BOND_TEMPLATE_SALT = keccak256("InternetBondTemplateV1");

    bytes constant internal INTERNET_BOND_TEMPLATE_BYTECODE = hex"608060405234801561001057600080fd5b506110c0806100206000396000f3fe608060405234801561001057600080fd5b506004361061012c5760003560e01c806371ca337d116100ad5780639dc29fac116100715780639dc29fac1461026b578063a457c2d71461027e578063a9059cbb14610291578063dd62ed3e146102a4578063df1f29ee146102b757600080fd5b806371ca337d1461020a5780638da5cb5b146102125780638e29ebb51461023d57806394bfed881461025057806395d89b411461026357600080fd5b8063313ce567116100f4578063313ce567146101b057806339509351146101bf57806340c10f19146101d25780635dfba115146101e557806370a08231146101f757600080fd5b806306fdde0314610131578063095ea7b31461014f57806318160ddd1461017257806323b872dd14610188578063265535671461019b575b600080fd5b6101396102da565b6040516101469190610e14565b60405180910390f35b61016261015d366004610d2a565b6102ec565b6040519015158152602001610146565b61017a610348565b604051908152602001610146565b610162610196366004610cee565b61035b565b6101ae6101a9366004610d93565b610400565b005b60405160128152602001610146565b6101626101cd366004610d2a565b61049e565b6101ae6101e0366004610d2a565b6104b9565b600854600160a01b900460ff16610162565b61017a610205366004610ca0565b610560565b61017a610582565b600254610225906001600160a01b031681565b6040516001600160a01b039091168152602001610146565b600854610225906001600160a01b031681565b6101ae61025e366004610d54565b610606565b610139610657565b6101ae610279366004610d2a565b610664565b61016261028c366004610d2a565b6106f9565b61016261029f366004610d2a565b610714565b61017a6102b2366004610cbb565b610752565b600654600754604080519283526001600160a01b03909116602083015201610146565b60606102e760015461078a565b905090565b6000806102f883610860565b905061030733858360006108e6565b6001600160a01b0384163360008051602061106b83398151915261032b8288610752565b60405190815260200160405180910390a360019150505b92915050565b60006102e761035660055490565b61097c565b60008061036783610860565b905061037685858360006109f9565b836001600160a01b0316856001600160a01b031660008051602061104b8339815191526103a28461097c565b60405190815260200160405180910390a36103c08533836000610ab2565b336001600160a01b03861660008051602061106b8339815191526103e48884610752565b60405190815260200160405180910390a3506001949350505050565b6002546001600160a01b03161561041657600080fd5b61042286868686610606565b6001600160a01b03821661046d5760405162461bcd60e51b815260206004820152600d60248201526c1b9bc81c985d1a5bc819995959609a1b60448201526064015b60405180910390fd5b60088054911515600160a01b026001600160a81b03199092166001600160a01b039093169290921717905550505050565b6000806104aa83610860565b90506103073385836000610b5f565b6002546001600160a01b031633146104d057600080fd5b6001600160a01b0382166104e357600080fd5b80600560008282546104f59190610e69565b90915550506001600160a01b03821660009081526003602052604081208054839290610522908490610e69565b90915550506001600160a01b038216600060008051602061104b83398151915261054b8461097c565b60405190815260200160405180910390a35050565b6001600160a01b0381166000908152600360205260408120546103429061097c565b60085460075460405163a1f1d48d60e01b81526001600160a01b039182166004820152600092919091169063a1f1d48d9060240160206040518083038186803b1580156105ce57600080fd5b505afa1580156105e2573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906102e79190610dfb565b6002546001600160a01b03161561061c57600080fd5b60028054336001600160a01b031991821617909155600094909455600192909255600655600780549092166001600160a01b03909116179055565b60606102e760005461078a565b6002546001600160a01b0316331461067b57600080fd5b6001600160a01b03821661068e57600080fd5b6001600160a01b038216600090815260036020526040812080548392906106b6908490610fc7565b9250508190555080600560008282546106cf9190610fc7565b90915550600090506001600160a01b03831660008051602061104b83398151915261054b8461097c565b60008061070583610860565b90506103073385836000610ab2565b60008061072083610860565b905061072f33858360006109f9565b6001600160a01b0384163360008051602061104b83398151915261032b8461097c565b6001600160a01b0380831660009081526004602090815260408083209385168352929052908120546107839061097c565b9392505050565b6060816107a557505060408051600081526020810190915290565b600060105b60ff8116156107fc57836107be8284610e81565b60ff16602081106107d1576107d161101e565b1a60f81b6001600160f81b031916156107f1576107ee8183610e81565b91505b60011c607f166107aa565b50600061080a826001610e81565b60ff1667ffffffffffffffff81111561082557610825611034565b6040519080825280601f01601f19166020018201604052801561084f576020820181803683370190505b506020810194909452509192915050565b600854600090600160a01b900460ff16156108dd57600061087f610582565b9050600081116108c75760405162461bcd60e51b8152602060048201526013602482015272726174696f206e6f7420617661696c61626c6560681b6044820152606401610464565b61078383826108d86012600a610efd565b610bbc565b5090565b919050565b6001600160a01b0384166108f957600080fd5b6001600160a01b03831661090c57600080fd5b6001600160a01b038085166000908152600460209081526040808320938716835292905220829055801561097657826001600160a01b0316846001600160a01b031660008051602061106b8339815191528460405161096d91815260200190565b60405180910390a35b50505050565b600854600090600160a01b900460ff16156108dd57600061099b610582565b9050600081116109e35760405162461bcd60e51b8152602060048201526013602482015272726174696f206e6f7420617661696c61626c6560681b6044820152606401610464565b610783836109f36012600a610efd565b83610c01565b6001600160a01b038416610a0c57600080fd5b6001600160a01b038316610a1f57600080fd5b6001600160a01b03841660009081526003602052604081208054849290610a47908490610fc7565b90915550506001600160a01b03831660009081526003602052604081208054849290610a74908490610e69565b9091555050801561097657826001600160a01b0316846001600160a01b031660008051602061104b8339815191528460405161096d91815260200190565b6001600160a01b038416610ac557600080fd5b6001600160a01b038316610ad857600080fd5b6001600160a01b03808516600090815260046020908152604080832093871683529290529081208054849290610b0f908490610fc7565b90915550508015610976576001600160a01b0384811660008181526004602090815260408083209488168084529482529182902054915191825260008051602061106b833981519152910161096d565b6001600160a01b038416610b7257600080fd5b6001600160a01b038316610b8557600080fd5b6001600160a01b03808516600090815260046020908152604080832093871683529290529081208054849290610b0f908490610e69565b6000610bf9610bd4610bce8487610ea6565b85610c3e565b8385610be08289610fde565b610bea9190610fa8565b610bf49190610ea6565b610c71565b949350505050565b6000610bf9610c13610bce8487610ea6565b83610c1f600182610fc7565b86610c2a878a610fde565b610c349190610fa8565b610bea9190610e69565b600082610c4d57506000610342565b82820282848281610c6057610c60611008565b041461078357600019915050610342565b60008282018381101561078357600019915050610342565b80356001600160a01b03811681146108e157600080fd5b600060208284031215610cb257600080fd5b61078382610c89565b60008060408385031215610cce57600080fd5b610cd783610c89565b9150610ce560208401610c89565b90509250929050565b600080600060608486031215610d0357600080fd5b610d0c84610c89565b9250610d1a60208501610c89565b9150604084013590509250925092565b60008060408385031215610d3d57600080fd5b610d4683610c89565b946020939093013593505050565b60008060008060808587031215610d6a57600080fd5b843593506020850135925060408501359150610d8860608601610c89565b905092959194509250565b60008060008060008060c08789031215610dac57600080fd5b863595506020870135945060408701359350610dca60608801610c89565b9250610dd860808801610c89565b915060a08701358015158114610ded57600080fd5b809150509295509295509295565b600060208284031215610e0d57600080fd5b5051919050565b600060208083528351808285015260005b81811015610e4157858101830151858201604001528201610e25565b81811115610e53576000604083870101525b50601f01601f1916929092016040019392505050565b60008219821115610e7c57610e7c610ff2565b500190565b600060ff821660ff84168060ff03821115610e9e57610e9e610ff2565b019392505050565b600082610eb557610eb5611008565b500490565b600181815b80851115610ef5578160001904821115610edb57610edb610ff2565b80851615610ee857918102915b93841c9390800290610ebf565b509250929050565b600061078360ff841683600082610f1657506001610342565b81610f2357506000610342565b8160018114610f395760028114610f4357610f5f565b6001915050610342565b60ff841115610f5457610f54610ff2565b50506001821b610342565b5060208310610133831016604e8410600b8410161715610f82575081810a610342565b610f8c8383610eba565b8060001904821115610fa057610fa0610ff2565b029392505050565b6000816000190483118215151615610fc257610fc2610ff2565b500290565b600082821015610fd957610fd9610ff2565b500390565b600082610fed57610fed611008565b500690565b634e487b7160e01b600052601160045260246000fd5b634e487b7160e01b600052601260045260246000fd5b634e487b7160e01b600052603260045260246000fd5b634e487b7160e01b600052604160045260246000fdfeddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925a26469706673582212202704c0c85a7ffefb8570f6c29df5c6522044694561363ba9c4f84b992471d3fb64736f6c63430008060033";

    bytes32 constant internal INTERNET_BOND_TEMPLATE_HASH = keccak256(INTERNET_BOND_TEMPLATE_BYTECODE);

    function deployInternetBondTemplate(InternetBondFactory templateFactory) internal returns (address) {
        /* we can use any deterministic salt here, since we don't care about it */
        bytes32 salt = INTERNET_BOND_TEMPLATE_SALT;
        /* concat bytecode with constructor */
        bytes memory bytecode = INTERNET_BOND_TEMPLATE_BYTECODE;
        /* deploy contract and store result in result variable */
        address result;
        assembly {
            result := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(result != address(0x00), "deploy failed");
        /* check that generated contract address is correct */
        require(result == internetBondTemplateAddress(templateFactory), "address mismatched");
        return result;
    }

    function internetBondTemplateAddress(InternetBondFactory templateFactory) internal pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(uint8(0xff), address(templateFactory), INTERNET_BOND_TEMPLATE_SALT, INTERNET_BOND_TEMPLATE_HASH));
        return address(bytes20(hash << 96));
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IERC20.sol";

contract SimpleToken is Context, IERC20, IERC20Mintable, IERC20Pegged {

    // pre-defined state
    bytes32 internal _symbol; // 0
    bytes32 internal _name; // 1
    address public owner; // 2

    // internal state
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 internal _totalSupply;
    uint256 internal _originChain;
    address internal _originAddress;

    function name() public view returns (string memory) {
        return bytes32ToString(_name);
    }

    function symbol() public view returns (string memory) {
        return bytes32ToString(_symbol);
    }

    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        if (_bytes32 == 0) {
            return new string(0);
        }
        uint8 cntNonZero = 0;
        for (uint8 i = 16; i > 0; i >>= 1) {
            if (_bytes32[cntNonZero + i] != 0) cntNonZero += i;
        }
        string memory result = new string(cntNonZero + 1);
        assembly {
            mstore(add(result, 0x20), _bytes32)
        }
        return result;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount, true);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount, true);
        return true;
    }

    function increaseAllowance(address spender, uint256 amount) public virtual returns (bool) {
        _increaseAllowance(_msgSender(), spender, amount, true);
        return true;
    }

    function decreaseAllowance(address spender, uint256 amount) public virtual returns (bool) {
        _decreaseAllowance(_msgSender(), spender, amount, true);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount, true);
        _decreaseAllowance(sender, _msgSender(), amount, true);
        return true;
    }

    function _increaseAllowance(address owner, address spender, uint256 amount, bool emitEvent) internal {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] += amount;
        if (emitEvent) {
            emit Approval(owner, spender, _allowances[owner][spender]);
        }
    }

    function _decreaseAllowance(address owner, address spender, uint256 amount, bool emitEvent) internal {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] -= amount;
        if (emitEvent) {
            emit Approval(owner, spender, _allowances[owner][spender]);
        }
    }

    function _approve(address owner, address spender, uint256 amount, bool emitEvent) internal {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        if (emitEvent) {
            emit Approval(owner, spender, amount);
        }
    }

    function _transfer(address sender, address recipient, uint256 amount, bool emitEvent) internal {
        require(sender != address(0));
        require(recipient != address(0));
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        if (emitEvent) {
            emit Transfer(sender, recipient, amount);
        }
    }

    function mint(address account, uint256 amount) public onlyOwner virtual override {
        require(account != address(0));
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner virtual override {
        require(account != address(0));
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    modifier emptyOwner() {
        require(owner == address(0x00));
        _;
    }

    function initAndObtainOwnership(bytes32 symbol, bytes32 name, uint256 originChain, address originAddress) public emptyOwner {
        owner = msg.sender;
        _symbol = symbol;
        _name = name;
        _originChain = originChain;
        _originAddress = originAddress;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function getOrigin() public view override returns (uint256, address) {
        return (_originChain, _originAddress);
    }
}

contract SimpleTokenFactory {
    address private _template;
    constructor() {
        _template = SimpleTokenFactoryUtils.deploySimpleTokenTemplate(this);
    }

    function getImplementation() public view returns (address) {
        return _template;
    }
}

library SimpleTokenFactoryUtils {

    bytes32 constant internal SIMPLE_TOKEN_TEMPLATE_SALT = keccak256("SimpleTokenTemplateV1");

    bytes constant internal SIMPLE_TOKEN_TEMPLATE_BYTECODE = hex"608060405234801561001057600080fd5b50610a7f806100206000396000f3fe608060405234801561001057600080fd5b50600436106101005760003560e01c80638da5cb5b11610097578063a457c2d711610066578063a457c2d714610224578063a9059cbb14610237578063dd62ed3e1461024a578063df1f29ee1461028357600080fd5b80638da5cb5b146101cb57806394bfed88146101f657806395d89b41146102095780639dc29fac1461021157600080fd5b8063313ce567116100d3578063313ce5671461016b578063395093511461017a57806340c10f191461018d57806370a08231146101a257600080fd5b806306fdde0314610105578063095ea7b31461012357806318160ddd1461014657806323b872dd14610158575b600080fd5b61010d6102a6565b60405161011a919061095e565b60405180910390f35b6101366101313660046108f5565b6102b8565b604051901515815260200161011a565b6005545b60405190815260200161011a565b6101366101663660046108b9565b6102d0565b6040516012815260200161011a565b6101366101883660046108f5565b6102f6565b6101a061019b3660046108f5565b610305565b005b61014a6101b0366004610864565b6001600160a01b031660009081526003602052604090205490565b6002546101de906001600160a01b031681565b6040516001600160a01b03909116815260200161011a565b6101a061020436600461091f565b6103b9565b61010d61040a565b6101a061021f3660046108f5565b610417565b6101366102323660046108f5565b6104c5565b6101366102453660046108f5565b6104d4565b61014a610258366004610886565b6001600160a01b03918216600090815260046020908152604080832093909416825291909152205490565b600654600754604080519283526001600160a01b0390911660208301520161011a565b60606102b36001546104e3565b905090565b60006102c733848460016105b9565b50600192915050565b60006102df8484846001610661565b6102ec843384600161072c565b5060019392505050565b60006102c733848460016107eb565b6002546001600160a01b0316331461031c57600080fd5b6001600160a01b03821661032f57600080fd5b806005600082825461034191906109b3565b90915550506001600160a01b0382166000908152600360205260408120805483929061036e9084906109b3565b90915550506040518181526001600160a01b038316906000907fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef906020015b60405180910390a35050565b6002546001600160a01b0316156103cf57600080fd5b60028054336001600160a01b031991821617909155600094909455600192909255600655600780549092166001600160a01b03909116179055565b60606102b36000546104e3565b6002546001600160a01b0316331461042e57600080fd5b6001600160a01b03821661044157600080fd5b6001600160a01b038216600090815260036020526040812080548392906104699084906109f0565b92505081905550806005600082825461048291906109f0565b90915550506040518181526000906001600160a01b038416907fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef906020016103ad565b60006102c7338484600161072c565b60006102c73384846001610661565b6060816104fe57505060408051600081526020810190915290565b600060105b60ff811615610555578361051782846109cb565b60ff166020811061052a5761052a610a1d565b1a60f81b6001600160f81b0319161561054a5761054781836109cb565b91505b60011c607f16610503565b5060006105638260016109cb565b60ff1667ffffffffffffffff81111561057e5761057e610a33565b6040519080825280601f01601f1916602001820160405280156105a8576020820181803683370190505b506020810194909452509192915050565b6001600160a01b0384166105cc57600080fd5b6001600160a01b0383166105df57600080fd5b6001600160a01b038085166000908152600460209081526040808320938716835292905220829055801561065b57826001600160a01b0316846001600160a01b03167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b9258460405161065291815260200190565b60405180910390a35b50505050565b6001600160a01b03841661067457600080fd5b6001600160a01b03831661068757600080fd5b6001600160a01b038416600090815260036020526040812080548492906106af9084906109f0565b90915550506001600160a01b038316600090815260036020526040812080548492906106dc9084906109b3565b9091555050801561065b57826001600160a01b0316846001600160a01b03167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef8460405161065291815260200190565b6001600160a01b03841661073f57600080fd5b6001600160a01b03831661075257600080fd5b6001600160a01b038085166000908152600460209081526040808320938716835292905290812080548492906107899084906109f0565b9091555050801561065b576001600160a01b038481166000818152600460209081526040808320948816808452948252918290205491519182527f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b9259101610652565b6001600160a01b0384166107fe57600080fd5b6001600160a01b03831661081157600080fd5b6001600160a01b038085166000908152600460209081526040808320938716835292905290812080548492906107899084906109b3565b80356001600160a01b038116811461085f57600080fd5b919050565b60006020828403121561087657600080fd5b61087f82610848565b9392505050565b6000806040838503121561089957600080fd5b6108a283610848565b91506108b060208401610848565b90509250929050565b6000806000606084860312156108ce57600080fd5b6108d784610848565b92506108e560208501610848565b9150604084013590509250925092565b6000806040838503121561090857600080fd5b61091183610848565b946020939093013593505050565b6000806000806080858703121561093557600080fd5b84359350602085013592506040850135915061095360608601610848565b905092959194509250565b600060208083528351808285015260005b8181101561098b5785810183015185820160400152820161096f565b8181111561099d576000604083870101525b50601f01601f1916929092016040019392505050565b600082198211156109c6576109c6610a07565b500190565b600060ff821660ff84168060ff038211156109e8576109e8610a07565b019392505050565b600082821015610a0257610a02610a07565b500390565b634e487b7160e01b600052601160045260246000fd5b634e487b7160e01b600052603260045260246000fd5b634e487b7160e01b600052604160045260246000fdfea2646970667358221220fe9609dd4d099f8ee61d515b2ebf66a53d24e78cf669be48b69b627acefde71564736f6c63430008060033";

    bytes32 constant internal SIMPLE_TOKEN_TEMPLATE_HASH = keccak256(SIMPLE_TOKEN_TEMPLATE_BYTECODE);

    bytes4 constant internal SET_META_DATA_SIG = bytes4(keccak256("obtainOwnership(bytes32,bytes32)"));

    function deploySimpleTokenTemplate(SimpleTokenFactory templateFactory) internal returns (address) {
        /* we can use any deterministic salt here, since we don't care about it */
        bytes32 salt = SIMPLE_TOKEN_TEMPLATE_SALT;
        /* concat bytecode with constructor */
        bytes memory bytecode = SIMPLE_TOKEN_TEMPLATE_BYTECODE;
        /* deploy contract and store result in result variable */
        address result;
        assembly {
            result := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(result != address(0x00), "deploy failed");
        /* check that generated contract address is correct */
        require(result == simpleTokenTemplateAddress(templateFactory), "address mismatched");
        return result;
    }

    function simpleTokenTemplateAddress(SimpleTokenFactory templateFactory) internal pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(uint8(0xff), address(templateFactory), SIMPLE_TOKEN_TEMPLATE_SALT, SIMPLE_TOKEN_TEMPLATE_HASH));
        return address(bytes20(hash << 96));
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Mintable {

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}

interface IERC20Pegged {

    function getOrigin() external view returns (uint256, address);
}

interface IERC20Extra {

    function name() external returns (string memory);

    function decimals() external returns (uint8);

    function symbol() external returns (string memory);
}

interface IERC20InternetBond {

    function ratio() external view returns (uint256);

    function isRebasing() external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

interface IInternetBondRatioFeed {

    function updateRatioBatch(address[] calldata addresses, uint256[] calldata ratios) external;

    function getRatioFor(address) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.6;

import "../SimpleToken.sol";

library Utils {

    function currentChain() internal view returns (uint256) {
        uint256 chain;
        assembly {
            chain := chainid()
        }
        return chain;
    }

    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }

    function saturatingMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            if (a == 0) return 0;
            uint256 c = a * b;
            if (c / a != b) return type(uint256).max;
            return c;
        }
    }

    function saturatingAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return type(uint256).max;
            return c;
        }
    }

    // Preconditions:
    //  1. a may be arbitrary (up to 2 ** 256 - 1)
    //  2. b * c < 2 ** 256
    // Returned value: min(floor((a * b) / c), 2 ** 256 - 1)
    function multiplyAndDivideFloor(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
        return saturatingAdd(
            saturatingMultiply(a / c, b),
            ((a % c) * b) / c // can't fail because of assumption 2.
        );
    }

    // Preconditions:
    //  1. a may be arbitrary (up to 2 ** 256 - 1)
    //  2. b * c < 2 ** 256
    // Returned value: min(ceil((a * b) / c), 2 ** 256 - 1)
    function multiplyAndDivideCeil(uint256 a, uint256 b, uint256 c) internal pure returns (uint256) {
        return saturatingAdd(
            saturatingMultiply(a / c, b),
            ((a % c) * b + (c - 1)) / c // can't fail because of assumption 2.
        );
    }
}