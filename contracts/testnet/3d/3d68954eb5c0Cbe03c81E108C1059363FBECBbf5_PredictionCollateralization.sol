pragma solidity ^0.7.4;
// "SPDX-License-Identifier: Apache License 2.0"

import "./Common/IERC20.sol";
import "./TokenTemplate.sol";
import "./iPredictionCollateralization.sol";

contract PredictionCollateralization is iPredictionCollateralization {
    address public _poolAddress;
    address public _governanceAddress;

    TokenTemplate public _whiteToken;
    TokenTemplate public _blackToken;
    IERC20 public _collateralToken;

    event PoolAddressChanged(address previousAddress, address poolAddress);
    event GovernanceAddressChanged(
        address previousAddress,
        address governanceAddress
    );
    event WithdrawCollateral(uint256 amount);

    constructor(
        address governanceAddress,
        address collateralTokenAddress,
        string memory whiteName,
        string memory whiteSymbol,
        string memory blackName,
        string memory blackSymbol
    ) {
        require(
            collateralTokenAddress != address(0),
            "Collateral token address should not be null"
        );

        _poolAddress = msg.sender;
        _governanceAddress = governanceAddress == address(0)
            ? msg.sender
            : governanceAddress;

        _whiteToken = new TokenTemplate(
            whiteName,
            whiteSymbol,
            18,
            address(this),
            0
        );
        _blackToken = new TokenTemplate(
            blackName,
            blackSymbol,
            18,
            address(this),
            0
        );
        _collateralToken = IERC20(collateralTokenAddress);
    }

    modifier onlyPool() {
        require(_poolAddress == msg.sender, "Caller should be pool");
        _;
    }

    modifier onlyGovernance() {
        require(
            _governanceAddress == msg.sender,
            "Caller should be governance"
        );
        _;
    }

    function withdrawCollateral(address destination, uint256 tokensAmount)
        external
        override
        onlyPool
    {
        require(
            destination != address(0),
            "Destination address shouold be not null"
        );
        require(
            _collateralToken.balanceOf(address(this)) >= tokensAmount,
            "Not enough Collateral tokens on Collateralization contract balance"
        );

        if (tokensAmount > 0) {
            _collateralToken.transfer(destination, tokensAmount);
        }
        emit WithdrawCollateral(tokensAmount);
    }

    function buySeparately(
        address destination,
        uint256 tokensAmount,
        address tokenAddress,
        uint256 payment,
        address paymentTokenAddress
    ) public override onlyPool {
        IERC20 paymentToken = IERC20(paymentTokenAddress);
        require(
            destination != address(0),
            "DESTINATION ADDRESS should not be null"
        );
        require(
            paymentToken.allowance(destination, address(this)) >= payment,
            "Not enough delegated tokens"
        );
        paymentToken.transferFrom(destination, address(this), payment);
        TokenTemplate token = TokenTemplate(tokenAddress);

        token.mintTokens(destination, tokensAmount);
    }

    function buyBackSeparately(
        address destination,
        uint256 tokensAmount,
        address tokenAddress,
        uint256 payment
    ) public override onlyPool {
        require(
            destination != address(0),
            "DESTINATION ADDRESS should not be null"
        );
        require(
            _collateralToken.balanceOf(address(this)) >= payment,
            "NOT ENOUGH COLLATERALIZATION ON THE CONTRACT"
        );

        TokenTemplate token = TokenTemplate(tokenAddress);

        require(
            token.allowance(destination, address(this)) >= tokensAmount,
            "NOT ENOUGH DELEGATED TOKENS ON DESTINATION BALANCE"
        );
        token.burnFrom(destination, tokensAmount);

        _collateralToken.transfer(destination, payment);
    }

    /*
    Function changes the pool address
    */
    function changePoolAddress(address poolAddress)
        public
        override
        onlyGovernance
    {
        require(
            poolAddress != address(0),
            "NEW POOL ADDRESS should not be null"
        );

        address previousAddress = _poolAddress;
        _poolAddress = poolAddress;

        emit PoolAddressChanged(previousAddress, poolAddress);
    }

    function changeGovernanceAddress(address governanceAddress)
        public
        override
        onlyGovernance
    {
        require(
            governanceAddress != address(0),
            "NEW GOVERNANCE ADDRESS should not be null"
        );

        address previousAddress = _governanceAddress;
        _governanceAddress = governanceAddress;

        emit GovernanceAddressChanged(previousAddress, governanceAddress);
    }

    function getCollateralization() public view override returns (uint256) {
        return _collateralToken.balanceOf(address(this));
    }

    function whiteToken() public view override returns (address) {
        return address(_whiteToken);
    }

    function blackToken() public view override returns (address) {
        return address(_blackToken);
    }
}

pragma solidity ^0.7.4;

// "SPDX-License-Identifier: MIT"

// solhint-disable-next-line contract-name-camelcase
interface iPredictionCollateralization {
    function buySeparately(
        address destination,
        uint256 tokensAmount,
        address tokenAddress,
        uint256 payment,
        address paymentTokenAddress
    ) external;

    function buyBackSeparately(
        address destination,
        uint256 tokensAmount,
        address tokenAddress,
        uint256 payment
    ) external;

    function withdrawCollateral(address destination, uint256 tokensAmount)
        external;

    function changePoolAddress(address poolAddress) external;

    function changeGovernanceAddress(address governanceAddress) external;

    function getCollateralization() external view returns (uint256);

    function whiteToken() external returns (address);

    function blackToken() external returns (address);
}

pragma solidity ^0.7.4;
// "SPDX-License-Identifier: Apache License 2.0"

import "./ERC20Detailed.sol";
import "./ERC20Burnable.sol";
import "./Common/Ownable.sol";

contract TokenTemplate is ERC20Burnable, ERC20Detailed, Ownable {
    /**
     * @dev Constructor that gives the specified address all of existing tokens.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        address beneficiary,
        uint256 supply
    ) ERC20Detailed(name, symbol, decimals) {
        _mint(beneficiary, supply);
    }

    fallback() external {
        // solhint-disable-next-line reason-string
        revert();
    }

    function mintTokens(address beneficiary, uint256 amount) public onlyOwner {
        _mint(beneficiary, amount);
    }
}

pragma solidity >=0.5.16;
// "SPDX-License-Identifier: Apache License 2.0"


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.7.4;
// "SPDX-License-Identifier: Apache License 2.0"

import "./Common/IERC20.sol";

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (
        string memory name_, 
        string memory symbol_, 
        uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    } 

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

pragma solidity ^0.7.4;
// "SPDX-License-Identifier: Apache License 2.0"

import "./ERC20.sol";

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract ERC20Burnable is ERC20 {
    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance
     * @param from address The address which you want to send tokens from
     * @param value uint256 The amount of token to be burned
     */
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
}

pragma solidity ^0.7.4;
// "SPDX-License-Identifier: Apache License 2.0"

import "./Common/IERC20.sol";
import "./SafeMath.sol";

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view override returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}

pragma solidity ^0.7.4;
// "SPDX-License-Identifier: Apache License 2.0"

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.7.4;
// "SPDX-License-Identifier: MIT"

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}