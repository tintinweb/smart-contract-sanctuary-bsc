// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.4;

import "./sendAssembly.sol";

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

contract PeerToPeer is Ownable,Pausable,SendAsset{

    using ECDSA for address;
    address public signer;
    uint256 public orderId;
    uint256 public importTokenFee = 0.1e18;

    struct Proposals {
        address seller;
        address buyer;
        uint256 givenAmt;
        uint8 tradeType;
        address given;
        bool tradeConfirm;
        bool sellerConfirm;
    }

    struct importTokendetails {
        string name;
        string symbol;
        uint256 listingPrice;
        bool approval;
    }

    mapping (uint256 => Proposals) public orderDetails;
    mapping (bytes32 => bool)public msgHash;
    mapping (address => importTokendetails)public importToken;
    mapping (address => bool)public approvalToken;

    event MakeOrder(address indexed from,address buyer,uint256 amount,uint256 id,uint8 tradeType);
    event SellerConfirm(address indexed from,address buyer,uint256 amount,uint256 id,uint8 tradeType);
    event Dispute(address indexed from,address to,uint256 id,uint8 tradeType,uint256 amount);
    event FundTransfer(address indexed from,address source,address to,uint256 amount);
    event ImportToken(address token,uint256 price,uint256 time);

    receive() external payable {}

    function addToken (address _token,string memory _name,string memory _symbol,uint256 _listingPrice) external payable {
        require(msg.value == importTokenFee,'Fee not provided');
        importTokendetails storage token = importToken[_token];
        token.name = _name;
        token.symbol = _symbol;
        token.listingPrice = _listingPrice;
        emit ImportToken(_token, _listingPrice, block.timestamp);
    }

    function approveToken (address[] memory token,bool status) external onlyOwner {
        for (uint8 i; i < token.length; i++) {
        approvalToken[token[i]] = status;
        }
    }

    function makeOrder(Proposals memory proposal, bytes memory _signature,uint256 _expiry) external whenNotPaused payable  {
        require(!proposal.sellerConfirm && proposal.tradeConfirm,'incorrect confirmation');
        require(proposal.tradeType == 1 || proposal.tradeType == 2,'Invalid trade types');
        orderId++;

        sigVerify(proposal.seller,proposal.buyer,proposal.givenAmt,_expiry,_signature);

        if (proposal.tradeType == 1){
        require(msg.value > 0 && proposal.givenAmt == msg.value,'Incorrect type1 amount');
        }
        else {
        require(approvalToken[proposal.given],'NOT_AUTHORIZED_TOKEN');
        require(msg.value == 0 && proposal.givenAmt > 0,'Incorrect type2 amount');
        tokenSafeTransferFrom(IBEP20(proposal.given),proposal.seller,address(this),proposal.givenAmt);
        }

        updateProposal(proposal);
        emit MakeOrder(_msgSender(),proposal.buyer,proposal.givenAmt,orderId,proposal.tradeType);
    }

    function updateProposal(Proposals memory proposal) private {
        Proposals storage _proposal = orderDetails[orderId];
        _proposal.seller = proposal.seller;
        _proposal.buyer = proposal.buyer;
        _proposal.givenAmt = proposal.givenAmt;
        _proposal.given = proposal.given;
        _proposal.tradeType = proposal.tradeType;
        _proposal.tradeConfirm = proposal.tradeConfirm;
    }

    function sigVerify(address seller,address buyer,uint256 amount,uint256 _expiry,bytes memory sig) private view {
        bytes32 messageHash = message(seller,buyer,amount,_expiry);
        require(!msgHash[messageHash], "claim: signature duplicate");
        
           //Verifes signature    
        address src = verifySignature(messageHash, sig);
        require(signer == src, " claim: unauthorized");
    }

    function sellerConfirmation (uint256 _id,bytes memory _signature,uint256 _expiry) external whenNotPaused {
        Proposals storage _proposal = orderDetails[_id];
        require(_msgSender() == _proposal.seller,'caller must be order creator');
        sigVerify(_proposal.seller,_proposal.buyer,_proposal.givenAmt,_expiry,_signature);
        _proposal.sellerConfirm = true;
        fundTransfer(_proposal.given, _proposal.buyer, _proposal.givenAmt);
        emit SellerConfirm(_msgSender(),_proposal.buyer,_proposal.givenAmt,_id,_proposal.tradeType);
    }

    function dispute (uint256 _id,address _user) external onlyOwner {
        Proposals storage _proposal = orderDetails[_id];
        require(_proposal.seller != address(0),'Invalid order');
        require(_user == _proposal.seller || _user == _proposal.buyer,'Invalid user');
        require(!_proposal.sellerConfirm,'Order confirmed');
        fundTransfer(_proposal.given, _user, _proposal.givenAmt);
        _proposal.sellerConfirm = true;
        emit Dispute(_msgSender(), _user, _id, _proposal.tradeType, _proposal.givenAmt);
    }

    function fundTransfer(address source,address user,uint256 amount) private {
        if (source == address(0))
        sendEth(user,amount);
        else tokenSafeTransfer(IBEP20(source),user,amount);
        emit FundTransfer(address(this),source,user,amount);
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
    
    /**
    * @dev Returns hash for given data
    */
    function message(address seller,address buyer ,uint256 amount,uint256 time)
        public pure returns(bytes32 messageHash)
    {
        messageHash = keccak256(abi.encodePacked(seller,buyer,amount,time));
    }
    
    // updaate signer address
    function setSigner(address _signer)public onlyOwner{
        signer = _signer;
    }

    function updateTokenFee (uint256 _fee) external onlyOwner {
        importTokenFee = _fee;
    }

    function emergencyWithdraw (address source,address user,uint256 amount) external onlyOwner {
        fundTransfer(source,user,amount);
    }

}