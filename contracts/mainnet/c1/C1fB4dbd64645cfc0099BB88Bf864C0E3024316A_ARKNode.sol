/**
 *Submitted for verification at BscScan.com on 2022-07-15
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
        uint256 amount;
    }

    IBEP20 public usdt = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    IBEP20 public ark = IBEP20(0x72bd8EE718001C3A1f46758001AcA7c1B38Bbee8);
    address public funder = address(0xA47007ccf4942615174FA38003B3E9718a219d2c);
    uint256[] public prices = [100 ether, 200 ether, 500 ether, 1000 ether, 2000 ether];
    uint256[] public pieces = [1000, 500 ,200, 100, 50];

    uint256 public exchangeRate = 1 ether;
    uint256 public FEE = 0.002 ether;

    Order[] public orders;
    mapping(address=>Order[]) public userOrders;
    mapping(address=>User) public users;

    event Contribute(address indexed user, uint256 price, uint256 tokenAmount);
    event Withdraw(address indexed user);
    event Reward(address indexed user, uint256 amount);

    constructor() public {

    }

    function contribute(uint256 index) public {
        require(pieces[index] >= 1, 'not enough');

        uint256 price = prices[index];
        uint256 tokenAmount = price.mul(exchangeRate).div(1e18);

        usdt.transferFrom(msg.sender, funder, price);
        ark.transfer(msg.sender, tokenAmount);

        pieces[index] = pieces[index].sub(1);
        users[msg.sender].amount = users[msg.sender].amount.add(price);
        orders.push(Order(
                msg.sender,
                prices[index],
                1,
                block.timestamp
            ));

        userOrders[msg.sender].push(Order(
                msg.sender,
                prices[index],
                1,
                block.timestamp
            ));


        emit Contribute(msg.sender, price, tokenAmount);
    }

    function withdraw() public payable {
        require(msg.value >= FEE, 'fee not enough');
        emit Withdraw(msg.sender);
    }

    function reward(address _addr, uint256 _amount) public onlyOwner {
        require(_amount > 0, 'no amount');
        require(ark.balanceOf(address(this)) >= _amount, 'no balance');
        ark.transfer(_addr, _amount);
        emit Reward(_addr, _amount);
    }

    function updateFunder(address _funder) public onlyOwner {
        funder = _funder;
    }

    function updateExchangeRate(uint256 _rate) public onlyOwner {
        exchangeRate = _rate;
    }

    function updatePrices(uint256 _index, uint256 _price) public onlyOwner {
        prices[_index] = _price;
    }

    function updatePieces(uint256 _index, uint256 _piece) public onlyOwner {
        pieces[_index] = _piece;
    }

    function drawToken(address _token, address _addr, uint256 _amount) public onlyOwner {
        require(_addr != address(0), 'no zero addr');
        IBEP20(_token).transfer(_addr, _amount);
    }

    function drawFee(address payable _addr) public onlyOwner {
        _addr.transfer(address(this).balance);
    }

    function updateFee(uint256 _fee) public onlyOwner {
        FEE = _fee;
    }

    function updateTokenAddr(address _addr) public onlyOwner {
        ark = IBEP20(_addr);
    }
}