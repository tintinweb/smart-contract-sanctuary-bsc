// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Governance is Ownable {
    //  Address of Treasury
    address public treasury;

    //  Address of Verifier
    address public verifier;

    //  Address that has an authority to create Campaigns in Factory721/Factory1155 contracts
    address public manager;

    //  A list of supported ERC-20 Tokens
    mapping(address => bool) public acceptedPayments;

    event Treasury(address indexed oldTreasury, address indexed newTreasury);
    event PaymentAcceptance(
        address indexed _token,
        bool _isRegistered // true = Registered, false = Removed
    );

    constructor(
        address _treasury,
        address _verifier,
        address _manager,
        address[] memory _tokens
    ) Ownable() {
        //  Set Treasury wallet address and verifer
        treasury = _treasury;
        verifier = _verifier;
        manager = _manager;

        //  Set acceptance payments
        for (uint256 i; i < _tokens.length; i++) {
            acceptedPayments[_tokens[i]] = true;
        }
    }

    /**
       @notice Change new address of Treasury
       @dev  Caller must be Owner
       @param _newTreasury    Address of new Treasury
    */
    function updateTreasury(address _newTreasury) external onlyOwner {
        require(_newTreasury != address(0), "Set zero address");

        emit Treasury(treasury, _newTreasury);
        treasury = _newTreasury;
    }

    /**
       @notice Update new address of Vendor contract
       @dev  Caller must be Owner
       @param _newVerifier    Address of new Vendor contract
    */
    function updateVerifier(address _newVerifier) external onlyOwner {
        require(_newVerifier != address(0), "Set zero address");
        verifier = _newVerifier;
    }

    /**
       @notice Change new address of Manager
       @dev  Caller must be Owner
       @param _newManager    Address of new Treasury
    */
    function updateManager(address _newManager) external onlyOwner {
        require(_newManager != address(0), "Set zero address");
        manager = _newManager;
    }

    /**
        @notice Register a new acceptance payment token
            Owner calls this function to register new ERC-20 Token
        @dev Caller must be Owner
        @param _token           Address of ERC-20 Token contract
    */
    function registerToken(address _token) external onlyOwner {
        require(!acceptedPayments[_token], "Token registered");
        require(_token != address(0), "Set zero address");
        acceptedPayments[_token] = true;
        emit PaymentAcceptance(_token, true);
    }

    /**
        @notice Unregister a current acceptance payment token
            Owner calls this function to unregister existing ERC-20 Token
        @dev Caller must be Owner
        @param _token           Address of ERC-20 Token contract to be removed
    */
    function unregisterToken(address _token) external onlyOwner {
        require(acceptedPayments[_token], "Token not registered");
        delete acceptedPayments[_token];
        emit PaymentAcceptance(_token, false);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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