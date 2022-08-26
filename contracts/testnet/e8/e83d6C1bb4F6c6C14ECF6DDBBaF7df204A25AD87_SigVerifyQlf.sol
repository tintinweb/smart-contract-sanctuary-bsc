// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "./interfaces/ISigVerify.sol";
import "./OpenZepplin/access/Ownable.sol";

contract SigVerifyQlf is ISigVerify, Ownable {

    function verify (
        address _signer, 
        address _sender,
        uint256 _boxId,
        uint256 _quantity,
        address _verifier,
        string calldata _key,
        bytes calldata _sig
    ) external override pure returns(bool) {
        bytes32 _messageHash = messageHashing(
            keccak256(
                abi.encodePacked(
                    _key,
                    _sender,
                    _boxId,
                    _quantity,
                    _verifier
                )
            )
        );

        require(_signer != address(0), "Invalid signer");
        return recover(_messageHash, _sig) == _signer;
    }

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) private pure returns(address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _split (bytes memory _sig) internal pure returns(bytes32 r, bytes32 s, uint8 v) {
        require(_sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }

    function messageHashing(bytes32 _messageHash) private pure returns(bytes32) {
        return keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            _messageHash
        ));
    }

    function getMessageHash(
        string memory _key,
        address _sender,
        uint256 _boxId,
        uint256 _quantity,
        address _verifier
    ) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(
            _key,
            _sender,
            _boxId,
            _quantity,
            _verifier
        ));
    }
}

pragma solidity >=0.6.2;

interface ISigVerify {

    function verify (
        address _signer, 
        address _sender,
        uint256 _boxId,
        uint256 _quantity,
        address _verifier,
        string calldata _key,
        bytes calldata _sig
    ) external pure returns(bool);
}

pragma solidity ^0.6.6;

import "../GSN/Context.sol";
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.6.6;
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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}