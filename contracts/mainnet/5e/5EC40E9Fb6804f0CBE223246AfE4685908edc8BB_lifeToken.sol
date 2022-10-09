/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ERC20 interface
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/*
数学lib
*/
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath#mul: OVERFLOW");
        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath#sub: UNDERFLOW");
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath#add: OVERFLOW");
        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}

abstract contract ERC20Token is IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 public targetSupply = 21000000 * (10**18); // 目标发行数量
    uint256 private _totalSupply;

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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function burn(uint256 amount) public virtual returns (bool) {
        _burn(msg.sender, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value)
        public
        virtual
        override
        returns (bool)
    {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount)
        );
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
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
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
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    // function _lock(type name) {

    // }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        if (_totalSupply > targetSupply) {
            if ((_totalSupply - targetSupply) < value) {
                value = _totalSupply - targetSupply;
            }

            _totalSupply = _totalSupply.sub(value);
            _balances[account] = _balances[account].sub(value);
            emit Transfer(account, address(0), value);
        }
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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
        uint256 value
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            msg.sender,
            _allowances[account][msg.sender].sub(amount)
        );
    }
}

contract lifeToken is ERC20Token, ERC20Detailed, Ownable {
    using SafeMath for uint256;

    mapping(address => bool) public whitelist;
    address public operator;
    address public bonusPool;
    address public bottomPool;
    address public exPair;

    uint256 private _buy_bottom = 100;
    uint256 private _transfer_burn = 200;
    uint256 private _sell_burn = 500;
    uint256 private _sell_bottom = 400;
    uint256 private _sell_bonus = 600;

    constructor() ERC20Detailed("Chain Life", "LIFE", 18) {
        _mint(msg.sender, 210000000 * (10**uint256(decimals())));
        operator = msg.sender;
        whitelist[operator] = true;
        whitelist[address(this)] = true;
    }

    modifier isOperator() {
        require(operator == msg.sender, "Is not operator");
        _;
    }

    function setOperator(address addr) public isOperator returns (bool) {
        operator = addr;
        return true;
    }

    function getSlippage()
        public
        view
        returns (
            uint256 buy_bottom,
            uint256 transfer_burn, 
            uint256 sell_burn,
            uint256 sell_bottom, 
            uint256 sell_bonus 
        )
    {
        return (
            _buy_bottom,
            _transfer_burn,
            _sell_burn,
            _sell_bottom,
            _sell_bonus
        );
    }

    function setSlippage(uint256[] memory types, uint256[] memory slippages)
        public
        isOperator
    {
        require(
            types.length > 0 && types.length == slippages.length,
            "input array error"
        );

        for (uint256 i = 0; i < types.length; i++) {
            require(slippages[i] < 10000, "slippage error");
            if (types[i] == 0) {
                _buy_bottom = slippages[i];
            } else if (types[i] == 1) {
                _transfer_burn = slippages[i];
            } else if (types[i] == 2) {
                _sell_burn = slippages[i];
            } else if (types[i] == 3) {
                _sell_bottom = slippages[i];
            } else if (types[i] == 4) {
                _sell_bonus = slippages[i];
            }
        }
    }

    function setWhitelistAddress(address[] memory addrs) public isOperator {
        for (uint256 i; i < addrs.length; i++) {
            address addr = addrs[i];
            whitelist[addr] = true;
        }
    }

    function removeWhitelistAddress(address[] memory addrs) public isOperator {
        for (uint256 i; i < addrs.length; i++) {
            address addr = addrs[i];
            whitelist[addr] = false;
        }
    }

    function setBonusPool(address addr) public isOperator {
        bonusPool = addr;
        whitelist[bonusPool] = true;
    }

    function setBottomPool(address addr) public isOperator {
        bottomPool = addr;
        whitelist[bottomPool] = true;
    }

    function setExPair(address addr) public isOperator {
        exPair = addr;
    }

    function transfer(address to, uint256 value)
        public
        override(ERC20Token, IERC20)
        returns (bool)
    {
        uint256 transferAmount = common(msg.sender, to, value);
        super.transfer(to, transferAmount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override(ERC20Token, IERC20) returns (bool) {
        uint256 transferAmount = common(from, to, value);

        super._transfer(from, to, transferAmount);
        super._approve(
            from,
            msg.sender,
            _allowances[from][msg.sender].sub(value)
        );
        return true;
    }

    function common(
        address addr,
        address to,
        uint256 value
    ) internal returns (uint256) {
        uint256 transferAmount = value;
        if (!whitelist[addr] && !whitelist[to]) {
            uint256 burnAmount = value.mul(_transfer_burn).div(10000);
            uint256 bottomPoolAmount = 0;
            uint256 bonusPoolAmount = 0;
            uint256 holderAmount = 0;

            if ((super.balanceOf(addr) - value) == 0) {
                holderAmount = 1 * (10**12);
            }

            if (to == exPair || addr == exPair) {
                if (addr == exPair) {
                    burnAmount = 0;
                    bottomPoolAmount = value.mul(_buy_bottom).div(10000);
                } else {
                    burnAmount = value.mul(_sell_burn).div(10000);
                    bottomPoolAmount = value.mul(_sell_bottom).div(10000);
                    bonusPoolAmount = value.mul(_sell_bonus).div(10000);
                    if (bonusPoolAmount > 0) {
                        super._transfer(addr, bonusPool, bonusPoolAmount);
                    }
                }

                if (bottomPoolAmount > 0) {
                    super._transfer(addr, bottomPool, bottomPoolAmount);
                }
            }

            if (burnAmount > 0) {
                super._burn(addr, burnAmount);
            }

            transferAmount = value.sub(
                burnAmount.add(bottomPoolAmount).add(bonusPoolAmount).add(
                    holderAmount
                )
            );
        }

        return transferAmount;
    }
}