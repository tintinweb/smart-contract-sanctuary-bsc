/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: smartcontract.sol


pragma solidity ^0.8.2;



contract Blockchaincert is Ownable{

    struct BuyCOURSEStruct {
        uint256 price;
        address tokenAddress;
        address refAddress;
        address refAddress1;
        address refAddress2;
     }

     event BuyEvent(
        address indexed user,
        address tokenAddress,
        uint256 price,
        uint64 timestamp
     );  
     address public owner1;
     address public owner2;
     address public token1;
     address public token2;
    uint public constant mintPrice = 0;
    uint256 total_value;

    constructor(address secondOwner,address token11, address token22)   {
        owner1= msg.sender;
        owner2=secondOwner;
        token1=token11;
        token2=token22;
    }
    function buyCOURSE(BuyCOURSEStruct calldata data) public payable {
        uint256 price1=0; 
        uint256 price2=0;
        uint256 price3 =0;
        uint256 price = data.price / 2;
        uint256 owner2Price=price;
        uint256 Percent= data.price /100;

        if(data.refAddress2!=address(0)){
            price3=Percent + Percent / 2;
            owner2Price= owner2Price-price3;
            
        }
        if(data.refAddress1!=address(0)){
            price2=Percent * 2 + Percent / 2;
            owner2Price=owner2Price-price2;
            
        }
        if(data.refAddress!=address(0)){
            price1=Percent * 5;
            owner2Price=owner2Price-price1;
            
        }      
        
        if (data.tokenAddress == token1 || data.tokenAddress == token2) {
            
            IERC20(data.tokenAddress).transferFrom(
                msg.sender,
                owner1,
                price
            );
            if (owner2Price != 0) {
                IERC20(data.tokenAddress).transferFrom(msg.sender, owner2, owner2Price);
            }
            if (price1 != 0) {
                IERC20(data.tokenAddress).transferFrom(msg.sender, data.refAddress, price1);
            }
            if (price2 != 0) {
                IERC20(data.tokenAddress).transferFrom(msg.sender, data.refAddress1, price2);
            }
            if (price3 != 0) {
                IERC20(data.tokenAddress).transferFrom(msg.sender, data.refAddress2, price3);
            }
            emit BuyEvent(
            msg.sender,
            data.tokenAddress,
            data.price,
            uint64(block.timestamp)
        );
            
            
        }
        else 
        {
            require(msg.value >= data.price, "Not enough money");
            payable(owner1).transfer(price);
            
            if (owner2Price != 0) {
                payable(owner2).transfer(owner2Price);
            }
            if (price1 != 0) {
                payable(data.refAddress).transfer(price1);
            }
            if (price2 != 0) {
                payable(data.refAddress1).transfer(price2);
            }
            if (price3 != 0) {
                payable(data.refAddress2).transfer(price3);
            }
            emit BuyEvent(
            msg.sender,
            address(0),
            data.price,
            uint64(block.timestamp)
        );
            
        }

        
    }
    
    function setFundAddress(address _fundAddress,address _fundaddress2) external onlyOwner {
        owner1 = _fundAddress;
        owner2 = _fundaddress2;
    }
}