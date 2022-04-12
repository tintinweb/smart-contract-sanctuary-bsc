// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";
import "./IBEP20.sol";
import "./SafeMath.sol";

/**
    ______             ______            _      _   _
    |  ___|            | ___ \          | |    | | | |
    | |_ ___  ___  ___ | |_/ /___  _   _| | ___| |_| |_ ___
    |  _/ _ \/ _ \/ __||    // _ \| | | | |/ _ \ __| __/ _ \
    | ||  __/  __/\__ \| |\ \ (_) | |_| | |  __/ |_| ||  __/
    \_| \___|\___||___/\_| \_\___/ \__,_|_|\___|\__|\__\___|

 */

contract FeesRoulette is Ownable, IBEP20 {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _tokenTotal;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    address private _ownerAddress;
    address private _taxAddress;
    uint256 private _tax;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _dec,
        uint256 _totalSupply,
        uint256 _initialTax
    ) {
        _tokenTotal = _totalSupply;
        _name = _tokenName;
        _symbol = _tokenSymbol;
        _decimals = _dec;

        _balances[msg.sender] = _tokenTotal;
        _ownerAddress = msg.sender;
        _taxAddress = msg.sender;
        _tax = _initialTax;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function getOwner() external view override returns (address) {
        return _ownerAddress;
    }

    function totalSupply() external view override returns (uint256) {
        return _tokenTotal;
    }

    function balanceOf(address owner)
        public
        view
        override
        returns (uint256 balance)
    {
        return _balances[owner];
    }

    function transfer(address to, uint256 value)
        public
        override
        returns (bool)
    {
        require(to != address(0), "ERC20: to address is not valid");
        require(value <= _balances[msg.sender], "ERC20: insufficient balance");

        if (SafeMath.mul(_tax, 10) < value) {
            _balances[_taxAddress] = SafeMath.add(_balances[_taxAddress], _tax);
            _balances[to] = SafeMath.add(
                _balances[to],
                (SafeMath.sub(value, _tax))
            );
        } else {
            _balances[to] = SafeMath.add(_balances[to], value);
        }

        _balances[msg.sender] = SafeMath.sub(_balances[msg.sender], value);

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        require(from != address(0), "ERC20: from address is not valid");
        require(to != address(0), "ERC20: to address is not valid");
        require(value <= _balances[from], "ERC20: insufficient balance");
        require(
            value <= _allowances[from][msg.sender],
            "ERC20: from not allowed"
        );

        if (SafeMath.mul(_tax, 10) < value) {
            _balances[_taxAddress] = SafeMath.add(_balances[_taxAddress], _tax);
            _balances[to] = SafeMath.add(
                _balances[to],
                (SafeMath.sub(value, _tax))
            );
        } else {
            _balances[to] = SafeMath.add(_balances[to], value);
        }

        _balances[from] = SafeMath.sub(_balances[msg.sender], value);

        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function changeTaxAddress(address newTaxAddress) public onlyOwner {
        _taxAddress = newTaxAddress;
    }

    function changeTaxValue(uint256 newTax) public onlyOwner {
        _tax = newTax;
    }

    function getCurrentTaxAddress() external view returns (address) {
        return _taxAddress;
    }

    function getCurrentTax() external view returns (uint256) {
        return _tax;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IBEP20 {
    /**
     * @dev Emitted when `value` tokens are moved
     * from one account (`from`) to another account (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
}