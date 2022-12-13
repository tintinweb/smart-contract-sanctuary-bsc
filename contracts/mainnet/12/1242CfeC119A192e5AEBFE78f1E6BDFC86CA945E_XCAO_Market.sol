/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) external isOwner { // ===
        require(newOwner != address(0), "ERC20: changeOwner newOwner the zero address"); // ===
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() public view returns (address) {
        return owner;
    }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract XCAO_Market is Owner, ReentrancyGuard {
    address public tokenForSale;
    uint256 public salePrice; // set salePrice with 6 decimals (USDT TOKEN)
    uint256 public totalOrders;
    bool public lockNewOrders;

    event SetTokensContract(
        address tokenForSale
    );

    event SetSalePrice(
        uint256 salePrice
    );

    event ExecuteOrder(
        uint256 orderId,
        address buyer,
        uint256 amount,
        uint256 paidAmount
    );

    event SetLockNewOrders(
        bool newValue
    );

    constructor(address _tokenForSaleAddress, uint256 _salePrice) {
        setTokenContract(_tokenForSaleAddress);
        setSalePrice(_salePrice);
    }

    function setTokenAndPrice(address _tokenForSaleAddress, uint256 _salePrice) public isOwner {
        setTokenContract(_tokenForSaleAddress);
        setSalePrice(_salePrice);
    }

    function setTokenContract(address _tokenForSaleAddress) public isOwner {
        tokenForSale = _tokenForSaleAddress;
        emit SetTokensContract(_tokenForSaleAddress);
    }

    function setSalePrice(uint256 _salePrice) public isOwner {
        salePrice = _salePrice;
        emit SetSalePrice(_salePrice);
    }

    function setLockNewOrders(bool _newValue) external isOwner{
        lockNewOrders = _newValue;
        emit SetLockNewOrders(_newValue);
    }

    function calculateCost(uint amount) public view returns (uint) {
        return amount * salePrice;
    }

    function buy(uint256 _amount) external payable nonReentrant {
        require(!lockNewOrders, "cannot currently create new buy orders");
        uint tokensAvailable = countTokensAvailable();
        require(_amount <= tokensAvailable, "amount to buy must be less than tokens availables for sale");
        uint256 amountToPay = calculateCost(_amount);
        require (msg.value >= amountToPay, "Insufficient balance for purchase");
        payable(getOwner()).transfer(msg.value);
        IERC20(tokenForSale).transfer(msg.sender, _amount * 10**9);
        totalOrders++;
        emit ExecuteOrder(totalOrders, msg.sender, _amount* 10**9, msg.value);
    }

    function withdraw() external isOwner {
        uint tokensAvailable = countTokensAvailable();
        if (tokensAvailable > 0) {
            IERC20(tokenForSale).transfer(getOwner(), tokensAvailable);
        }

        uint balance = address(this).balance;
        if (balance > 0) {
            payable(getOwner()).transfer(balance);
        }
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function countTokensAvailable() public view returns (uint256) {
        return IERC20(tokenForSale).balanceOf(address(this));
    }

    receive() external payable{}

}