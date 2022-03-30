/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//import "hardhat/console.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
interface IBEP20 {
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
    function _msgSender() internal view virtual returns (address) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/* @dev Contract module which provides a basic access control mechanism, where
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract stakingContract is Ownable {
    IBEP20  public token;
    uint public dt;
    mapping (address => uint) public deposited;
    mapping (address => uint) public rewardStored;
    mapping (address => uint) public lastClaim;

    modifier hasStaked(address _user) {
        if (deposited[_user]>0) {
            uint rewards = getReward(_user);
            rewardStored[_user] += rewards;
        }
        _;
    }

    function stakeTokens(uint _amount) external hasStaked(msg.sender) {
        token.transferFrom(msg.sender,address(this), _amount);
        deposited[msg.sender] = _amount;
        lastClaim[msg.sender] = block.timestamp;
    }

    function withdrawRewards () external {
        uint totalRewards = getReward(msg.sender);
        rewardStored[msg.sender] = 0;
        token.transfer (msg.sender, totalRewards);
    }

    function withdrawStakedTokens (uint _amount) external {
        deposited[msg.sender] -= _amount;
        token.transfer (msg.sender, _amount);
    }


    function getT () public view returns (uint) {
        uint ct = block.timestamp;
        uint val = (ct-dt)/ 60;
        //console.log(val);
        val = val / 365;
       // console.log(val);
        return val;

    }

    function getReward(address _user) public view returns (uint) {
        uint t = getT();
        uint amount;
        for (uint i;i<t;i++) {
            uint depositedAmont = deposited[_user];
            amount += depositedAmont * 1 * 30;
            //console.log('In for loop',amount);
        }
        amount = amount / 100;
        //console.log('/100',amount);
        amount = amount / 365;
       // console.log('/365', amount);

        uint totalDays = (block.timestamp - lastClaim[_user])/ 60;
        //console.log('totalDays',totalDays);
        uint finalAmount = rewardStored[_user]+amount * totalDays;
        return finalAmount;
    }

    function setToken(address _token) external onlyOwner{
        token=IBEP20(_token);
    }


    function setDT (uint _time) external onlyOwner{
        dt = _time;
    }

}