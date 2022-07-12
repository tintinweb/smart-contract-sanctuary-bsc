/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

/** 
 *  SourceUnit: d:\Projects\mymeow\smart-contracts\contracts\utils\NFTAirdrop.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

library Signature {

    function splitSignature(bytes memory _sig) private pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(_sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(_sig, 32))
            // second 32 bytes.
            s := mload(add(_sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(_sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 _message, bytes memory _sig) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(_sig);

        return ecrecover(_message, v, r, s);
    }

    function prefixed(bytes32 _hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
    }

}



/** 
 *  SourceUnit: d:\Projects\mymeow\smart-contracts\contracts\utils\NFTAirdrop.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
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




/** 
 *  SourceUnit: d:\Projects\mymeow\smart-contracts\contracts\utils\NFTAirdrop.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

////import "./../libs/Signature.sol";

abstract contract Signable {

    using Signature for bytes32;

    event SignerUpdated(address signer);

    address public signer;

    function _setSigner(address _signer)
        internal
    {
        require(_signer != address(0), "Signable: address is invalid");

        signer = _signer;

        emit SignerUpdated(_signer);
    }

    function _verifySignature(bytes memory _data, bytes memory _signature)
        internal
        view
        returns(bool)
    {
        bytes32 message = keccak256(_data).prefixed();

        return message.recoverSigner(_signature) == signer;
    }

}



/** 
 *  SourceUnit: d:\Projects\mymeow\smart-contracts\contracts\utils\NFTAirdrop.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
     * by making the `nonReentrant` function external, and making it call a
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
 *  SourceUnit: d:\Projects\mymeow\smart-contracts\contracts\utils\NFTAirdrop.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

////import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}




/** 
 *  SourceUnit: d:\Projects\mymeow\smart-contracts\contracts\utils\NFTAirdrop.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

////import "../utils/Context.sol";

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


/** 
 *  SourceUnit: d:\Projects\mymeow\smart-contracts\contracts\utils\NFTAirdrop.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

////import "@openzeppelin/contracts/access/Ownable.sol";

////import "@openzeppelin/contracts/security/Pausable.sol";
////import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

////import "./../common/Signable.sol";

interface INFT {

    function mint(address _to) external returns(uint256);

}

contract NFTAirdrop is Ownable, Pausable, ReentrancyGuard, Signable {

    event RoundUpdated(uint256 roundId, uint256 totalSupply);
    event NFTClaimed(uint256 roundId, address user, uint256 nftId);

    INFT public nft;

    struct Round {
        uint256 totalSupply;
        uint256 totalClaimed;
    }

    mapping(uint256 => Round) public rounds;

    mapping(uint256 => mapping(address => uint256)) public claimed;

    constructor(INFT _nft)
    {
        nft = _nft;

        _setSigner(_msgSender());
    }

    function setSigner(address _signer)
        public
        onlyOwner
    {
        _setSigner(_signer);
    }

    function pause()
        public
        onlyOwner
    {
        _pause();
    }

    function unpause()
        public
        onlyOwner
    {
        _unpause();
    }

    function setRound(uint256 _roundId, uint256 _totalSupply)
        public
        onlyOwner
    {
        Round storage round = rounds[_roundId];

        require(_totalSupply >= round.totalClaimed, "NFTAirdrop: total supply is invalid");

        round.totalSupply = _totalSupply;

        emit RoundUpdated(_roundId, _totalSupply);
    }

    function claimNFT(uint256 _roundId, bytes memory _signature)
        public
        whenNotPaused
        nonReentrant
    {
        address msgSender = _msgSender();

        require(_verifySignature(abi.encodePacked(_roundId, msgSender, block.chainid, this), _signature), "NFTAirdrop: signature is invalid");

        require(claimed[_roundId][msgSender] == 0, "NFTAirdrop: already claimed");

        Round storage round = rounds[_roundId];

        require(round.totalClaimed + 1 <= round.totalSupply, "NFTAirdrop: airdrop ended");

        claimed[_roundId][msgSender]++;

        round.totalClaimed++;

        uint256 nftId = nft.mint(msgSender);

        emit NFTClaimed(_roundId, msgSender, nftId);
    }

}