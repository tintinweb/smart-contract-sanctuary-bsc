/**
 *Submitted for verification at BscScan.com on 2022-07-04
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: contracts/TokenSending.sol


pragma solidity ^0.8.0;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract TokenSending is Ownable{
    IERC20 private _token;
    IERC20Metadata private _tokenMetadata;
    
    struct Person {
        uint256 amount;
        uint256 index;
        bool registered;
    }

    struct Send {
        address account;
        uint256 amount;
    }

    mapping(address => Person) private _isSendList;
    address[] private _sendList;
    
    constructor() {
    }


    /**
     * @notice Function for adding an address to the sendlist.
     *
     * Requirements:
     *
     * - the caller must be the owner.
     */
    function addSendList(address account, uint256 amount) external onlyOwner {
        require(_isSendList[account].registered != true, "Token Sending: address already registered.");
        _isSendList[account].index = _sendList.length;
        _isSendList[account].amount = amount * 10 ** _tokenMetadata.decimals();
        _isSendList[account].registered = true;
        _sendList.push(account);

    }


    /**
     * @notice Function to remove an address from the sendlist.
     *
     * Requirements:
     *
     * - the caller must be the owner.
     */
    function removeSendList(address account) public onlyOwner {
        uint indexToDelete = _isSendList[account].index;
        address keyToMove = _sendList[_sendList.length-1];
        _sendList[indexToDelete] = keyToMove;
        _isSendList[keyToMove].index = indexToDelete;
        
        delete _isSendList[account];
        _sendList.pop();
    }


    /** 
     * @notice External function returning a list of addresses in the sendlist.
     * @return Send struct array.
     */
    function getSendList(bool _check) external view returns (Send[] memory) {
        Send[] memory _send = new Send[](_sendList.length);
        
        for (uint i = 0; i < _sendList.length; i++) {
            Send memory _lSend;
            _lSend.account = _sendList[i];
            _lSend.amount = _isSendList[_lSend.account].amount;
            _send[i] = _lSend;
        }
        return _send;
    }


    /** 
     * @notice External function for the owner set token address.
     *
     * Requirements:
     *
     * - the caller must be the owner.
     */
    function setTokenAddress(address _tokenAddress) external onlyOwner {
        _token = IERC20(_tokenAddress);
        _tokenMetadata = IERC20Metadata(_tokenAddress);
    }


    /** 
     * @notice External function for the owner for start send tokens.
     *
     * Requirements:
     *
     * - the caller must be the owner.
     */
    function sendTokens() external onlyOwner {
        for (uint i = _sendList.length; i > 0; i--) {
            _token.transfer(_sendList[i-1], _isSendList[_sendList[i-1]].amount);
            removeSendList(_sendList[i-1]);
        }
    }


    /** 
     * @notice External function for the owner for change amount sending tokens for address.
     *
     * Requirements:
     *
     * - the caller must be the owner.
     */
    function changeAmountForAddr(address _addr, uint256 _newAmount) external onlyOwner {
        uint256 newAmount = _newAmount * 10 ** _tokenMetadata.decimals();
        require(_isSendList[_addr].amount != newAmount, "Token Sending: The specified number of tokens has already been set.");
        _isSendList[_addr].amount = newAmount;
    }


    /** 
     * @notice External function for the owner for return tokens on owner balance.
     *
     * Requirements:
     *
     * - the caller must be the owner.
     */
    function returnTokens() external onlyOwner {
        _token.transfer(owner(), _token.balanceOf(address(this)));
    }
}