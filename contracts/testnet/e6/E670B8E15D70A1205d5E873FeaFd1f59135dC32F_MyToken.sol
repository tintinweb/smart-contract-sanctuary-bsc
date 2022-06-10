// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./interface/IBEP20.sol";
import "./libs/SafeMath.sol";

contract MyToken is IBEP20 {
    using SafeMath for uint256;
    string private _name = "DIFINES";
    string private _symbol = "DFS";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 10000000000 * 1e18;

    address private _operator;
    address public constant BURN_ADDRESS =
        0x000000000000000000000000000000000000dEaD;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event Burn(address indexed from, uint256 value);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() {
        _balances[msg.sender] = _totalSupply;
        _operator = msg.sender;
        emit OwnershipTransferred(address(0), _operator);
    }

    function transfer(address _to, uint256 _value)
        public
        override
        returns (bool success)
    {
        require(_balances[msg.sender] >= _value, "Not enough tokens");

        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _to, uint256 _value)
        public
        override
        returns (bool success)
    {
        _allowances[msg.sender][_to] = _value;

        emit Approval(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        require(_value <= _balances[_from]);
        require(_value <= _allowances[_from][msg.sender]);

        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(_value);

        _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(
            _value
        );

        emit Transfer(_from, _to, _value);
        return true;
    }

    function getOwner() public view override returns (address) {
        return _operator;
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

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function allowance(address _self, address _to)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[_self][_to];
    }

    // function burn(uint256 _value) public onlyOperator returns (bool success) {
    //     // Requires that the message sender has enough tokens to burn
    //     require(_value <= _balances[msg.sender]);

    //     // Subtracts _value from callers balance and total supply
    //     _balances[msg.sender] = _balances[msg.sender].sub(_value);
    //     _totalSupply = _totalSupply.sub(_value);

    //     transfer(burn, _value);

    //     // Emits burn and transfer events, make sure you have them in your contracts
    //     emit Burn(msg.sender, _value);
    //     emit Transfer(msg.sender, address(0), _value);

    //     // Since you cant actually burn tokens on the blockchain, sending to address 0, which none has the private keys to, removes them from the circulating supply
    //     return true;
    // }

    function burn(uint256 _value) public onlyOperator returns (bool success) {
        transfer(BURN_ADDRESS, _value);
        _totalSupply = _totalSupply.sub(_value);

        emit Burn(msg.sender, _value);
        return true;
    }

    modifier onlyOperator() {
        require(
            _operator == msg.sender || msg.sender == getOwner(),
            "SMT: caller is not the operator"
        );
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOperator {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_operator, newOwner);
        _operator = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IBEP20 {
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
    function allowance(address _owner, address spender)
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x / y;
    }

    function mod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x % y;
    }
}