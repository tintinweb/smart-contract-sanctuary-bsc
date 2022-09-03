// SPDX-License-Identifier: MIT



pragma solidity ^0.8.0;

import "./Receipt.sol";



/**
 * @dev Contract module which provides a basic access control mechanism, where
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

    constructor() {
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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        //   require(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        //   require(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}


contract RedeemProgram is Ownable, ReentrancyGuard, NFT {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256  counter = 0;
    uint256 public product_count = 0;
    uint256 public redeemed_count = 0;
    uint256[] product_counter;

    struct AddProduct{
        uint256 product_id;
        uint256 product_token;
        uint256 product_price;
        uint256 product_stocks;
        string product_name;
        string product_image;
        string token_name;
        string token_URI;
        IERC20 token_address;
        bool availability;
    }

    struct RedeemProduct {
        uint256 redeem_id;
        uint256 redeem_product;
        uint256 redeem_amount;
        uint256 redeem_quantity;
    }

    mapping(address => bool) public admin;
    mapping(uint256 => AddProduct) public product_info;
    mapping(uint256 => mapping(address => RedeemProduct)) public redeemed;
    mapping(address => uint256[]) public agentRedeem;

    event NewAdmin(address admin, bool state);
    event AddNewToken(uint256 indexed token_id, IERC20 token_address, string token_name);
    event AddNewProduct(
        uint256 indexed product_id,
        IERC20 token_address,
        uint256 product_price,
        uint256 product_stocks,
        string product_name,
        string product_image,
        string token_name,
        bool availability
    );
    event RedeemNewProduct(
        uint256 indexed redeem_id,
        uint256 redeem_product,
        uint256 redeem_amount,
        uint256 redeem_quantity
    );
    event ProductAvailability(uint256 product_id, bool product_status);

    /**
     * @notice Constructor
     */
    constructor ()  {
        admin[msg.sender] = true;
   }
    /**
     * @notice add new admin6
     * @dev Callable by contract owner
     */
    function setNewAdmin(address admin_address, bool state) external onlyOwner {
        admin[admin_address] = state;

        emit NewAdmin(admin_address, state);
    }
    
     /**
     * @notice add new product
     * @dev Callable by contract admin
     */
    function addProduct(
        IERC20 token_need,
        uint256 _product_price,
        uint256 _product_stocks,
        string memory _product_name,
        string memory _product_image,
        string memory token_name,
        string memory _tokenURI
    ) external onlyAdmin {
        require(product_count != product_info[product_count].product_id || product_count == 0, "Product already added");

        AddProduct storage productAdd = product_info[product_count];
        bool status = true;

        productAdd.product_id = product_count;
        productAdd.product_price = _product_price;
        productAdd.product_stocks = _product_stocks;
        productAdd.product_name = _product_name;
        productAdd.product_image = _product_image;
        productAdd.token_name = token_name;
        productAdd.token_URI = _tokenURI;
        productAdd.token_address = token_need;
        productAdd.availability = status;

        product_counter.push(product_count);
        counter += 1;

        emit AddNewProduct(
            product_count,
            token_need,
            _product_price,
            _product_stocks,
            _product_name,
            _product_image,
            token_name,
            status
        );

        product_count += 1;
    }

    function redeemProduct(
        uint256 _redeem_product,
        uint256 _redeem_quantity
    ) external nonReentrant {
        require(_redeem_product == product_info[_redeem_product].product_id, "Product is not on the list");
        require(product_info[_redeem_product].availability == true, "Product an available");
        require(product_info[_redeem_product].product_stocks >= 1, "Out of stocks");
        require(_redeem_quantity <= product_info[_redeem_product].product_stocks, "Out of stocks");

        IERC20 token_to_pay;
        uint256 token_number = 0;
        string memory useURI;
        
        RedeemProduct storage productRedeem = redeemed[redeemed_count][msg.sender];
        AddProduct storage productAdd = product_info[_redeem_product];

        uint256 toPay = (productAdd.product_price * _redeem_quantity);

        productRedeem.redeem_id = redeemed_count;
        productRedeem.redeem_product = _redeem_product;
        productRedeem.redeem_amount = toPay;
        productRedeem.redeem_quantity = _redeem_quantity;

        token_number = productAdd.product_token;
        token_to_pay = productAdd.token_address;

        token_to_pay.safeTransferFrom(msg.sender, address(this), toPay);

        productAdd.product_stocks -= _redeem_quantity;

        agentRedeem[msg.sender].push(redeemed_count);

        useURI = productAdd.token_URI;
        mintNFT(useURI);

        emit RedeemNewProduct(
            redeemed_count,
            _redeem_product,
            toPay,
            _redeem_quantity
        );

        redeemed_count += 1;
    }

    function setProductAvailability(uint256 id_product, bool product_status) external onlyAdmin {
        AddProduct storage productAdd = product_info[id_product];

        productAdd.availability = product_status;

        emit ProductAvailability(id_product, product_status);
    }
    
    function removeProduct(uint256 id_product) external onlyAdmin {
        for(uint256 i = id_product; i < product_counter.length - 1; i++){
            product_counter[i] = product_counter[i +1];
        }
        product_counter.pop();
    }

    function deleteProduct(uint256 id_product) external onlyAdmin {
        delete product_info[id_product];
    }

    function editProduct(uint256 id_product, uint256 value) external onlyAdmin {
        AddProduct storage productAdd = product_info[id_product];

        productAdd.product_stocks = value;
    }
   
    function getProductBySize (
        uint256 start,
        uint256 size
    )
        external
        view
        returns (
            uint256[] memory,
            AddProduct[] memory,
            uint256
        )
    {
        uint256 length = size;

        if (length > product_counter.length - start) {
            length = product_counter.length - start;
        }

        uint256[] memory values = new uint256[](length);
        AddProduct[] memory prod_info = new AddProduct[](length);

        for (uint256 i = 0; i < length; i++) {
            values[i] = product_counter[start + i];
            prod_info[i] = product_info[values[i]];
        }

        return (values, prod_info, start + length);
    }

    function getAgentRedeemed(
            address redeemer_address
        )
            external
            view
            returns (
                uint256[] memory,
                RedeemProduct[] memory,
                uint256
            )
        {
           uint256 length = redeemed_count;
            uint256 cursor = 0;

            if (length > agentRedeem[redeemer_address].length - cursor) {
                length = agentRedeem[redeemer_address].length - cursor;
            }

            uint256[] memory values = new uint256[](length);
            RedeemProduct[] memory red_info = new RedeemProduct[](length);

            for (uint256 i = 0; i < length; i++) {
                values[i] = agentRedeem[redeemer_address][cursor + i];
                red_info[i] = redeemed[values[i]][redeemer_address];
            }

            return (values, red_info, cursor + length);
    }

        function getProductCreatedLength() external view returns (uint256) {
        return product_counter.length;
    }
    

    modifier onlyAdmin() {
        require(admin[msg.sender], "Not Admin");
         _;
        
    }
    
}