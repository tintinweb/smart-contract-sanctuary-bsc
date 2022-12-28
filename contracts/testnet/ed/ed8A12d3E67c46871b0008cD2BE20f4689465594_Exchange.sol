// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.4;
pragma abicoder v2;

import "./sendAssembly.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// 
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
    constructor()  {
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
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

contract Exchange is Ownable,SendAsset{

    using ECDSA for address;
    address public signer;

    struct userDetails {
        uint256[] amount;
        uint256[] timestamp;
    }

    address public releseWallet;

    event SetSigner(address indexed user,address indexed signer);
    event Register(address indexed user,uint256 amount,uint256 time);
    event PayFees(address indexed user,uint256 amount,uint256 time);
    event ReleseAmount(address indexed user,uint256 amount,address source,uint256 time);

    constructor (address _releseWallet) {releseWallet = _releseWallet;}

    mapping (address => userDetails) internal users;
    mapping (bytes32 => bool)public msgHash;

    receive() external payable {}

    function register (uint256 amount,bytes calldata sig,uint256 expiry) external {
        address user = _msgSender();
        bytes32 messageHash = message(user,amount,expiry);
        require(!msgHash[messageHash],'signature duplicate');
        verifySignature(messageHash,sig);
        users[user].amount.push(amount);
        users[user].timestamp.push(block.timestamp);
        msgHash[messageHash] = true;
        emit Register (user,amount,block.timestamp);
    }

    function payFees (bytes calldata sig,uint256 expiry) external payable {
        uint256 len = users[_msgSender()].amount.length;
        uint256 amount = users[_msgSender()].amount[len - 1];
        bytes32 messageHash = message(_msgSender(),amount,expiry);
        require(!msgHash[messageHash],'signature duplicate');
        verifySignature(messageHash,sig);
        require (len > 0,'Not yet registered');
        require (msg.value == amount,'Amount insufficient');
        msgHash[messageHash] = true;
        emit PayFees(_msgSender(), amount, block.timestamp);
    }

    function tokenDeposit (IBEP20 token,uint256 amount) external onlyOwner {
        tokenSafeTransferFrom(token,_msgSender(),address(this),amount);
    }

    function viewBalance() external view returns(uint256) {
        return address(this).balance;
    }

    function releseAmount (address source,address user, uint256 amount) external {
        require (_msgSender() == releseWallet,'Only releseWallet');
        fundTransfer(source, user, amount);
        emit ReleseAmount(user, amount, source, block.timestamp);
    }

    function fundTransfer (address source,address user, uint256 amount) private {
        if (source == address(0))
        sendEth(user,amount);
        else tokenSafeTransfer(IBEP20(source), user, amount);
    }

    function emergencyWithdraw (address source,address user, uint256 amount) external onlyOwner {
        fundTransfer(source, user, amount);
    }

    function updateReleseWallet (address _wallet) external onlyOwner {
        releseWallet = _wallet;
    }

    /**
    * @dev Returns hash for given data
    */
    function message(address  _receiver ,uint amount,uint time)
        public pure returns(bytes32 messageHash)
    {
        messageHash = keccak256(abi.encodePacked(_receiver,amount,time));
    }

    /**
    * @dev Ethereum Signed Message, created from `hash`
    * @dev Returns the address that signed a hashed message (`hash`) with `signature`.
    */
    function verifySignature(bytes32 _messageHash, bytes memory _signature) public pure returns (address signatureAddress)
    {
        bytes32 hash = ECDSA.toEthSignedMessageHash(_messageHash);
        signatureAddress = ECDSA.recover(hash, _signature);
    }

    function setSigner(address _signer)external onlyOwner{
        signer = _signer;
        emit SetSigner(msg.sender, _signer);
    }

    function viewUser (address _user) external view returns (userDetails memory) {
        return users[_user];
    }

}