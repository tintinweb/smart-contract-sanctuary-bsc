/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

pragma solidity ^0.8.0;


// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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

contract Ownable is Context {
    address internal _owner;

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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

contract AirDropToken is Ownable {

    uint256 public buyAmount;
    uint256 public sellAmount;

    bool public isActive;

    address public sellToken;

    address payable public feeOwner;

    event Claim(address indexed user, uint256 amount);

    constructor(uint256 buyAmount_, uint256 sellAmount_, address sellToken_, address payable feeOwner_) {
        buyAmount = buyAmount_;
        sellAmount = sellAmount_;
        sellToken = sellToken_;
        feeOwner = feeOwner_;

        _owner = msg.sender;
    }


    function claim() external payable returns (bool) {
        require(isActive, "Claim is not active");
        uint256 payAmount = msg.value;
        require(payAmount >= buyAmount, "Insufficient balance");
        feeOwner.transfer(payAmount);

        uint256 amount = payAmount / buyAmount;
        IERC20(sellToken).transfer(msg.sender, amount * sellAmount);

        emit Claim(msg.sender, amount * sellAmount);
        return true;
    }

    function setActive(bool _bol) public onlyOwner {
        isActive = _bol;
    }

    function OwnerWithdraw(address _to, uint256 _amount) public onlyOwner {
        IERC20(sellToken).transfer(_to, _amount);
    }

    function OwnerAllWithdraw(address _to) public onlyOwner {
        IERC20(sellToken).transfer(_to, IERC20(sellToken).balanceOf(address(this)));
    }
}