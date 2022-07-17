// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MetaDapp {

    address public owner;
    uint private secureAddPercent = 5;
    address private noOne = address(0);
    IERC20 private token;

    struct User {
        string name;
        string contact;
        bool updated;
        uint total_products;
        uint[] products;
    }

    struct Product {
        string name;
        string desc;
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

    constructor(address _token){
        owner = msg.sender;
        token = IERC20(_token);
        _totalUsers = 0;
    }

    function setSecureAddPercent(uint percent) public isOwner {
        secureAddPercent = percent;
    }

    function getSecureAddPercent() private isOwner view returns(uint){
        return secureAddPercent;
    }

    function __percentValue(uint _amount) public view returns(uint){
        return (secureAddPercent * _amount) / 100;
    }

    function __amount(uint _amount) private pure returns(uint){
        return _amount * (10 ** 18);
    }

    function addProduct(string memory name, 
                        string memory desc, 
                        string memory section, uint price) public {

        transferTokens(address(this), __amount(__percentValue(price)), msg.sender);

        products.push(Product(name, desc, section, __amount(price), msg.sender, noOne));
        emit ProductAdded(msg.sender, name, __amount(price));
    }

    function transferTokens(address _owner, uint _price, address _buyer) private {
        require(_price <= token.balanceOf(_buyer), 'Insuficent tokens to make transfer');
        require(token.allowance(_buyer, address(this)) >= _price, 'Insuficent allowence to make reserve');

        bool sent = token.transferFrom(_buyer, _owner, _price);
        require(sent, 'Not sent');
    }

    function updateProductPrice(uint product_id, uint price) public {
        require(msg.sender != noOne);
        Product storage product = products[product_id];
        require(msg.sender == product.owner);
        require(product.reserved_by == noOne);
        product.price = __amount(price);
    }

    function updateUserContact(string memory contact, string memory name) public {
        require(msg.sender != noOne);
        User storage user = users[msg.sender];
        user.contact = contact;
        user.name = name;

        if(!user.updated)
            _totalUsers++;

        user.updated = true;
    }

    function buyProduct(uint product_id) public {
        Product storage product = products[product_id];
        require(msg.sender != product.owner, 'You cannot buy your own products');
        transferTokens(product.owner, product.price, msg.sender);
        User storage buyer = users[msg.sender];
        buyer.total_products += 1;
        buyer.products.push(product_id);
        product.reserved_by = msg.sender;

        emit ProductPurchased(msg.sender, product.owner, product.price);
    }

    function totalUsers() public view returns (uint){
        return _totalUsers;
    }

    function getProducts() public view returns(Product[] memory){
      return products;
    }

    function getProduct(uint product_id) public view returns(Product memory){
      return products[product_id];
    }

    function getUser(address userAddress) public view returns(User memory){
      return users[userAddress];
    }

    function withdrawBNB(address payable account) external isOwner {
        (bool success, ) = account.call{value: address(this).balance}("");
        require(success);
    }

    function withdraw(address to, uint256 amount) external isOwner{
        require(token.transfer(to, amount));
    }

    modifier isOwner(){
        require(msg.sender == owner);
        _;
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