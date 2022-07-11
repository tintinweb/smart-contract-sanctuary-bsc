/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    function burn(uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
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
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract ARKNode is Ownable {
    using SafeMath for uint256;

    struct Order {
        address addr;
        uint256 price;
        uint256 piece;
        uint256 timestamp;
    }

    struct User {
        address referrer;
        uint256 directNum;
        uint256 balance;
        uint256 directAmount;
        bool isBuy;
    }

    IBEP20 public usdt = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    IBEP20 public ark = IBEP20(0xc0cF58f56BA5eE247B0616B1E4c418EBE23e0962);
    address public funder = address(0x44eEAEB98a8F262eFB85Eb76aa4196345a02eA0C);
    uint256[] public prices = [1 ether, 2 ether, 5 ether, 10 ether, 20 ether];
    // TODO
//    uint256[] public prices = [100 ether, 200 ether, 500 ether, 1000 ether, 2000 ether];
    uint256[] public pieces = [1000, 500 ,200, 100, 50];

    uint256 public referrerRate = 50;
    uint256 public percent = 1000;

    Order[] public orders;
    mapping(address=>Order[]) public userOrders;
    mapping(address=>User) public users;

    event Contribute(address indexed user, uint256 price, uint256 piece);
    event BindReferrer(address indexed user, address indexed referrer);
    event ReferrerReward(address indexed user, address indexed referrer, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(address rootAddr) public {
        users[rootAddr].isBuy = true;
        users[rootAddr].referrer = address(this);
    }

    function bindReferrer(address _address) public {
        require(_address != msg.sender, 'must not yourself');
        require(users[msg.sender].referrer == address(0), 'already set Referrer');
        require(users[_address].isBuy == true, 'Referrer not buy');
        require(users[_address].referrer != address(0), 'Referrer not valid');

        users[msg.sender].referrer = _address;
        users[_address].directNum =  users[_address].directNum.add(1);

        emit BindReferrer(msg.sender, _address);
    }

    function contribute(uint256 index, uint256 piece) public {
        require(users[msg.sender].referrer != address(0), 'must bind');
        require(piece > 0, 'at least 1');
        require(pieces[index] >= piece, 'not enough');

        uint256 amount = prices[index].mul(piece);

        usdt.transferFrom(msg.sender, funder, amount);
        pieces[index] = pieces[index].sub(piece);

        orders.push(Order(
                msg.sender,
                prices[index],
                piece,
                block.timestamp
            ));

        userOrders[msg.sender].push(Order(
                msg.sender,
                prices[index],
                piece,
                block.timestamp
            ));

        if (users[msg.sender].isBuy == false) {
            users[msg.sender].isBuy = true;
        }

        users[users[msg.sender].referrer].directAmount =  users[users[msg.sender].referrer].directAmount.add(amount);
        emit Contribute(msg.sender, prices[index], piece);

        uint256 referrerAmount = amount.mul(referrerRate).div(percent);

        users[users[msg.sender].referrer].balance =  users[users[msg.sender].referrer].balance.add(referrerAmount);

        emit ReferrerReward(msg.sender, users[msg.sender].referrer, referrerAmount);
    }

    function withdraw() public {
        require(users[msg.sender].balance > 0, 'no balance');

        uint256 amount  = users[msg.sender].balance;

        users[msg.sender].balance = 0;
        ark.transfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount);
    }

    function updateFunder(address _funder) public onlyOwner {
        funder = _funder;
    }

    function updatePrices(uint256 _index, uint256 _price) public onlyOwner {
        prices[_index] = _price;
    }

    function updatePieces(uint256 _index, uint256 _piece) public onlyOwner {
        pieces[_index] = _piece;
    }
}