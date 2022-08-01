// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WallDapp {
    address public owner;
    uint private secureAddPercent = 5; // Commission that we will charge to our customers every time they add a product
    address private nullAddress = address(0);
    IERC20 private token;

    struct User {
        string name;
        string contact;
        uint lastUpdated;
        uint total_products;
        Product[] products;
    }

    struct Product {
        string name;
        string description;
        string section;
        uint price;
        address owner;
        address reserved_by;
    }

    Product[] private products;
    mapping(address => User) public users;
    uint private _totalUsers;

    event ProductPurchased(address indexed user, address owner, uint price);
    event ProductAdded(address indexed owner, string name, uint price);

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
        _totalUsers = 0;
    }

    // Get the commision percentage
    function getSecureAddPercent() private isOwner view returns(uint) {
        return secureAddPercent;
    }

    // Modify the commission that we will charge to our customers every time they add a product
    function setSecureAddPercent(uint percent) public isOwner {
        secureAddPercent = percent;
    }

    // Calculate the commision's value
    function __commisionValue(uint _amount) public view returns(uint) {
        return (secureAddPercent / 100) * _amount;
    }

    // Get the wei of an amount
    function __getAmount(uint _amount) private pure returns(uint) {
        return _amount * 10**18;
    }

    // Add a product
    function addProduct(string memory name, string memory description, string memory section, uint price) public {
        transferTokens(msg.sender, address(this), __getAmount(__commisionValue(price)));
        products.push(Product(name, description, section, __getAmount(price), msg.sender, nullAddress));

        // Emit event
        emit ProductAdded(msg.sender, name, __getAmount(price));
    }

    // Buy a product
    function buyProduct(uint product_id) public {
        require(msg.sender != nullAddress);

        // Get the user and the product
        User storage user = users[msg.sender];
        Product storage product = products[product_id];

        // Check if the buyer is not the product's owner
        require(msg.sender != product.owner, 'You cannot buy your own products');

        // Pay for the product
        bool isPaid = transferTokens(msg.sender, product.owner, __getAmount(product.price));

        // Add product to user
        if(isPaid){
            user.products.push(product);
            user.total_products++;
            product.reserved_by = msg.sender;
        }

        // Emit event
        emit ProductPurchased(msg.sender, product.owner, __getAmount(product.price));
    }

    // Update the product's price
    function updateProductPrice(uint product_id, uint newPrice) public {
        require(msg.sender != nullAddress);

        Product storage product = products[product_id];
        require(msg.sender == product.owner); // Check if the caller is the product's owner
        require(product.reserved_by != nullAddress); // Check if the product is not reserved

        // Update the price
        product.price = __getAmount(newPrice);
    }

    // Get all the products
    function getProducts() public view returns(Product[] memory) {
        return products;
    }

    // Get a product
    function getProduct(uint product_id) public view returns(Product memory) {
        return products[product_id];
    }

    // Get the user's total
    function getTotalUsers() public view returns(uint) {
        return _totalUsers;
    }

    // Get an user
    function getUser(address userAddress) public view returns(User memory) {
        return users[userAddress];
    }

    // Update the user's contact
    function UpdateUserContact(string memory newName, string memory newContact) public {
        require(msg.sender != nullAddress);

        // Update the user data
        User storage user = users[msg.sender];
        user.name = newName;
        user.contact = newContact;
        user.lastUpdated = block.timestamp;
    }

    // Transfer tokens
    function transferTokens(address fromAddress, address toAddress, uint _amount) private returns(bool) {
        require(_amount <= token.balanceOf(fromAddress), 'Insuficient tokens to make the transfer'); // Check if they have sufficient tokens to buy
        require(token.allowance(fromAddress, address(this)) >= _amount, 'Insuficient allowence to make reserve');

        // Making the transfer
        require(token.transferFrom(fromAddress, toAddress, _amount), 'Transfer error');
        return true;
    }

    // Get WDT balance
    function getWdtBalance() private view isOwner returns(uint) {
        return address(this).balance;
    }

    // Withdraw WDT
    function withdrawWDT(address toAddress, uint256 amount) external isOwner {
        // Get balance
        uint balance = getWdtBalance();

        // Check if the amount to be withdrawn is less or equal then the total balance
        require(amount <= balance, 'There is not enough balance');

        // Make the transfer
        require(token.transfer(toAddress, amount));
    }

    // Restrictive funtion that checks if the person who is calling the function is really the owner
    modifier isOwner() {
        require(msg.sender == owner);
        _; // Continue
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}