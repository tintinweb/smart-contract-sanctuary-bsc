/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: Unlicensed
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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
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

// File: MetolandGameBalances.sol


pragma solidity ^0.8.4;




contract MetolandGameBalances is Ownable {
    IERC20 private _token;
    IERC721 private _tokenNFT;
    address private signer;

    mapping(address => uint256) adrToInputMoney;
    mapping(address => uint256[]) adrToInputNFTIds;
    mapping(address => mapping(uint256 => bool)) usedNonce;
    mapping(uint256 => uint256) tokenIdToTime;

    event deposited(address from, address to, uint256 payment);
    event depositedNFT(address from, address to, uint256[] NFTIds);
    event tokenWithdrawn(address user, uint256 amount, uint256 nonce);
    event nftWithdrawn(address user, uint256[] tokens);
    event Received();

    constructor(address metoContract, address nftContract) {
        _token = IERC20(metoContract);
        _tokenNFT = IERC721(nftContract);
        signer = msg.sender;
    }

    function deposit(uint256 amount) external {
        _token.transferFrom(msg.sender, address(this), amount);
        adrToInputMoney[msg.sender] += amount;
        emit deposited(msg.sender, msg.sender, amount);
    }

    function depositFor(address user, uint256 amount) external {
        _token.transferFrom(msg.sender, address(this), amount);
        adrToInputMoney[user] += amount;
        emit deposited(msg.sender, user, amount);
    }

    function depositNFT(uint256[] memory tokens) external {
        for (uint256 i; i < tokens.length; i++) {
            _tokenNFT.transferFrom(msg.sender, address(this), tokens[i]);
            adrToInputNFTIds[msg.sender].push(tokens[i]);
            tokenIdToTime[tokens[i]] = block.timestamp;
        }

        emit depositedNFT(msg.sender, msg.sender, adrToInputNFTIds[msg.sender]);
    }

    function getBalance(address user) external view returns (uint256) {
        return adrToInputMoney[user];
    }

    function getBalanceNFT(address user)
        external
        view
        returns (uint256[] memory)
    {
        return adrToInputNFTIds[user];
    }

    function changeSigner(address newSigner) external onlyOwner {
        signer = newSigner;
    }

    function withdraw(
        uint256 amount,
        address user,
        uint256 nonce,
        uint256 timestamp,
        bytes memory _sig
    ) external {
        require(msg.sender == user, "Only user can withdraw own money");
        require(
            block.timestamp - timestamp <= 1 days,
            "Deadline 1 day is over"
        );
        require(usedNonce[user][nonce] == false, "Nonce is already used");
        bytes32 message = getMessageHash(
            user,
            address(this),
            amount,
            nonce,
            timestamp
        );
        require(verify(message, _sig), "It's not a signer");
        require(amount <= adrToInputMoney[user], "Not enough tokens");
        address adr = msg.sender;
        _token.transfer(user, amount);
        adrToInputMoney[adr] -= amount;
        usedNonce[user][nonce] = true;
        emit tokenWithdrawn(user, amount, nonce);
    }

    function removeNFT(uint256[] memory tokens) external {
        for (uint256 i; i < tokens.length; i++) {
            require(
                isInArray(adrToInputNFTIds[msg.sender], tokens[i]),
                "You didn't deposit these nfts"
            );
            require(
                block.timestamp - tokenIdToTime[tokens[i]] > 1 minutes,
                "You cannot withdraw the nft before 1 minute after depositing"
            );
            _tokenNFT.transferFrom(address(this), msg.sender, tokens[i]);
            adrToInputNFTIds[msg.sender].push(tokens[i]);
            for (uint256 j; j < adrToInputNFTIds[msg.sender].length; j++) {
                if (adrToInputNFTIds[msg.sender][j] == tokens[i]) {
                    remove(j, msg.sender);
                }
            }
        }
        emit nftWithdrawn(msg.sender, tokens);
    }

    function isInArray(uint256[] memory Ids, uint256 id)
        internal
        pure
        returns (bool)
    {
        for (uint256 i; i < Ids.length; i++) {
            if (Ids[i] == id) {
                return true;
            }
        }
        return false;
    }

    function remove(uint256 index, address user)
        internal
        returns (uint256[] memory)
    {
        //if (index >= adrToIds[msg.sender].length) return ;

        for (uint256 i = index; i < adrToInputNFTIds[user].length - 1; i++) {
            adrToInputNFTIds[user][i] = adrToInputNFTIds[user][i + 1];
        }
        delete adrToInputNFTIds[user][adrToInputNFTIds[user].length - 1];
        adrToInputNFTIds[user].pop();
        return adrToInputNFTIds[user];
    }

    function changeNFTAndMetoAddresses(address newMeto, address newNFT)
        external
        onlyOwner
    {
        _token = IERC20(newMeto);
        _tokenNFT = IERC721(newNFT);
    }

    function ownerWithdrawBNB(address to, uint256 amount) external onlyOwner {
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "Transfer failed");
    }

    function ownerWithdrawERC20(address to, uint256 amount) external onlyOwner {
        _token.transfer(to, amount);
    }

    function ownerWithdrawNFT(address to, uint256 tokenId) external onlyOwner {
        _tokenNFT.transferFrom(address(this), to, tokenId);
    }

    // Проверка
    function verify(bytes32 message, bytes memory _sig)
        public
        view
        returns (
            bool /*, address adr1, address adr2*/
        )
    {
        //bytes32 messageHash = getMessageHash(msg.sender, address(this), amount, nonce, timestamp);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(message);

        return (recover(ethSignedMessageHash, _sig) == signer); /*, recover(ethSignedMessageHash, _sig), signer*/
    }

    function getMessageHash(
        address from,
        address to,
        uint256 amount,
        uint256 nonce,
        uint256 timestamp
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(from, to, amount, nonce, timestamp));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _split(bytes memory _sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(_sig.length == 65, "invalid signature name");

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4) {
        _operator;
        _from;
        _tokenId;
        _data;
        emit Received();
        return 0x150b7a02;
    }
}