//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "./SignatureVerifier.sol";
import "./IERC20.sol";
import "./Ownable.sol";

contract Bridge is SignatureVerifier, Ownable {
    mapping(address => uint256) private _userNonce;
    mapping(address => address) private _matchPair;
    event TokenMovedToBridge(
        address indexed from,
        address tokenAddress,
        uint256 amount,
        uint256 nonce,
        bytes signature
    );
    event TokenMovedToUser(
        address indexed to,
        address tokenAddress,
        uint256 amount,
        uint256 nonce,
        bytes signature
    );

    function getUserNonce() public view returns (uint256) {
        return _userNonce[msg.sender];
    }

    function addMatchTokenPair(address _token, address _matchToken)
        public
        onlyOwner
    {
        _matchPair[_token] = _matchToken;
    }

    function getMatchToken(address _token) public view returns (address) {
        return _matchPair[_token];
    }

    function bridgeTransferExactToken(
        address _to,
        address _tokenAddress,
        uint256 _amount,
        uint256 _nonce,
        bytes calldata _signature
    ) external onlyOwner returns (bool) {
        require(_tokenAddress != address(0), "BRIDGE: invalid token address");
        require(_amount > 0, "BRIDGE: invalid amount");
        require(_signature.length == 65, "BRIDGE: invalid signature");
        require(_userNonce[_to] == _nonce, "BRIDGE: mismatch nonce");
        require(
            _verifySignature(_to, _tokenAddress, _amount, _nonce, _signature),
            "BRIDGE: mismatch signature"
        );
        address _matchTokenAddress = getMatchToken(_tokenAddress);
        require(
            _matchTokenAddress != address(0),
            "BRIDGE: non-existent token match"
        );
        _userNonce[_to]++;
        _moveTokenFromBridgeToUser(_to, _matchTokenAddress, _amount);
        emit TokenMovedToUser(
            _to,
            _matchTokenAddress,
            _amount,
            _nonce,
            _signature
        );
        return true;
    }

    function moveTokenThroughBridgeForExactToken(
        address _tokenAddress,
        uint256 _amount,
        uint256 _nonce,
        bytes calldata _signature
    ) external returns (bool) {
        require(_nonce == _userNonce[msg.sender], "BRIDGE: nonce mismatch");
        _userNonce[msg.sender]++;
        _moveTokenFromUserToBridge(msg.sender, _tokenAddress, _amount);
        emit TokenMovedToBridge(
            msg.sender,
            _tokenAddress,
            _amount,
            _nonce,
            _signature
        );
        return true;
    }

    function _moveTokenFromUserToBridge(
        address _from,
        address _tokenAddress,
        uint256 _amount
    ) internal returns (bool) {
        require(_tokenAddress != address(0), "BRIDGE: invalid token address");
        require(_amount > 0, "BRIDGE: invalid amount");
        IERC20 token = IERC20(_tokenAddress);
        return token.transferFrom(_from, address(this), _amount); // transfer from user to bridge
    }

    function _moveTokenFromBridgeToUser(
        address _to,
        address _tokenAddress,
        uint256 _amount
    ) internal returns (bool) {
        require(_tokenAddress != address(0), "BRIDGE: invalid token address");
        require(_amount > 0, "BRIDGE: invalid amount");
        IERC20 token = IERC20(_tokenAddress);
        return token.transfer(address(_to), _amount); // transfer from bridge to user
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

contract SignatureVerifier {
    function getMessageHash(
        address _signer,
        address _tokenAddress,
        uint256 _amount,
        uint256 _nonce
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(_signer, _tokenAddress, _amount, _nonce)
            );
    }

    function _getEthSignedMessageHash(bytes32 _messageHash)
        internal
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function _verifySignature(
        address _signer,
        address _tokenAddress,
        uint256 _amount,
        uint256 _nonce,
        bytes memory signature
    ) internal pure returns (bool) {
        bytes32 messageHash = getMessageHash(
            _signer,
            _tokenAddress,
            _amount,
            _nonce
        );
        bytes32 ethSignedMessageHash = _getEthSignedMessageHash(messageHash);

        return _getSigner(ethSignedMessageHash, signature) == _signer;
    }

    function _getSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        internal
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = _splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
        //returns address of the signer
    }

    function _splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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