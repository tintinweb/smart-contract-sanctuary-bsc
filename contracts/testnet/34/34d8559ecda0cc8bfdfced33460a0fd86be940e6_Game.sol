/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

pragma solidity ^0.7.0;
// SPDX-License-Identifier: MIT

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
    function transferOwnership(address newOwner) public virtual onlyOwner {
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

contract Game is Ownable{
    using SafeMath for uint256;

    address mainCoin = address(8);
    mapping(address => uint256) coinAmount;

    address public payee; // 项目收款地址
    address payable etherReceiver; // 项目收款地址

    constructor(
        address _payee,
        uint256 _mainCoinAmount,
        address payable _etherReceiver
    ) {
        payee = _payee;
        coinAmount[mainCoin] = _mainCoinAmount;
        etherReceiver = _etherReceiver;
    }

    function updatePayee(address _payee) public onlyOwner {
        require(_payee != address(0), "Payee can not be 0x0!");
        payee = _payee;
    }

    function updateEtherReceiver(address payable _etherReceiver) public onlyOwner {
        require(_etherReceiver != address(0), "Payee can not be 0x0!");
        etherReceiver = _etherReceiver;
    }

    function addFeeCoin(address _coin, uint256 _amount) public onlyOwner {
        coinAmount[_coin] = _amount;
    }

    function addFeeCoinMain(uint256 _amount) public onlyOwner {
        coinAmount[mainCoin] = _amount;
    }

    function getFeeCoin(address _coin) public view returns (uint256) {
        return coinAmount[_coin];
    }

    function buy(address coin) public{
        IERC20 myCoin = IERC20(coin);
        uint256 amount = coinAmount[coin];
        require(myCoin.balanceOf(msg.sender) >= amount,"Insufficient tokens");
        myCoin.transferFrom(msg.sender,payee,amount);
    }

    function buyMain() external payable{
   
    }
}