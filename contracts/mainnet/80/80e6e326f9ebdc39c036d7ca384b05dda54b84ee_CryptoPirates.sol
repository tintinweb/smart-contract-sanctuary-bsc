/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }


    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }


    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor (address initialOwner) {
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}


/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


contract CryptoPirates is Ownable, IERC721Receiver {
    using Address for address;
    using SafeERC20 for IERC20;

    address[] private _nftContracts;

    address private ERC20Contract;

    address private _verifier;

    mapping(address => mapping(uint256 => bool)) private _usedNonces;

    mapping(address => bool) private _activeNFT;

    mapping(address => mapping(address => uint256[])) private _depositedNFT;

    mapping(address => uint256) private _depositedERC20;

    event DepositNFT(address indexed account, address indexed _contract, uint256 tokenId);

    event DepositERC20(address indexed account, uint256 amount);

    event WithdrawNFT(address indexed account, address indexed _contract, uint256 tokenId);

    event WithdrawERC20(address indexed account, uint256 amount, uint256 nonce);


    constructor(address initialOwner_) Ownable(initialOwner_) {
     }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function isActive(address token) public view returns (bool) {
        return _activeNFT[token];
    }

    function isDeposited(address account, address token, uint256 tokenId) public view returns (bool) {
        for (uint i = 0; i < _depositedNFT[account][token].length; i++) {
            if (_depositedNFT[account][token][i] == tokenId) {
                return true;
            }
        }
        return false;
    }

    function getVerifier() public view returns (address) {
        return _verifier;
    }


    function setVerifier(address account) external onlyOwner {
        require(account != address(0), "Zero address is prohibited");
        _verifier = account;
    }



    function depositNFT(address token, uint256 tokenId) external {
        require((token != address(0) && tokenId != 0), "Invalid NFT contract address or token id");
        require(_activeNFT[token], "This NFT contract is not allowed");
        require(IERC721(token).ownerOf(tokenId) == _msgSender(), "You're not an owner of token");
        IERC721(token).safeTransferFrom(_msgSender(), address(this), tokenId);
        _depositedNFT[_msgSender()][token].push(tokenId);
        emit DepositNFT(_msgSender(), token, tokenId);
    }


    function withdrawNFT(address token, uint256 tokenId) external {
        require(isDeposited(_msgSender(), token, tokenId), "This token wasn't deposited by you");
        for (uint256 i = 0; i < _depositedNFT[_msgSender()][token].length; i++) {
            if (_depositedNFT[_msgSender()][token][i] == tokenId) {
                _depositedNFT[_msgSender()][token][i] = _depositedNFT[_msgSender()][token][_depositedNFT[_msgSender()][token].length-1];
                _depositedNFT[_msgSender()][token].pop();
                IERC721(token).safeTransferFrom(address(this), _msgSender(), tokenId);
                break;
            }
        }
        emit WithdrawNFT(_msgSender(), token, tokenId);
    }

    function depositERC20(uint256 amount) external {
        require(ERC20Contract != address(0), "ERC20 contract address is not set");
        IERC20(ERC20Contract).safeTransferFrom(_msgSender(), address(this), amount);
        _depositedERC20[_msgSender()] += amount;
        emit DepositERC20(_msgSender(), amount);
    }

    function getDepositedERC20(address account) public view returns (uint256) {
        return _depositedERC20[account];
    }


    function getDepositedNFTs(address account, address token) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_depositedNFT[account][token].length);
        for (uint i = 0; i < _depositedNFT[account][token].length; i++) {
            result[i] = _depositedNFT[account][token][i];
        }
        return result;
    }

    function getOwnerNFTs(address account) public view returns (address[] memory, uint256[] memory) {
        address[] memory nfts = new address[](_nftContracts.length);
        uint256[] memory balances = new uint256[](_nftContracts.length);
        for (uint i = 0; i < _nftContracts.length; i++) {
            nfts[i] = _nftContracts[i];
            balances[i] = IERC721(_nftContracts[i]).balanceOf(account);
        }
        return(nfts, balances);
    }


    function listNFTContracts() public view returns (address[] memory) {
        address[] memory nfts = new address[](_nftContracts.length);
        for (uint i = 0; i < _nftContracts.length; i++) {
            nfts[i] = _nftContracts[i];
        }
        return nfts;

    }

    function addNFTContract(address token) external onlyOwner {
        require(!_activeNFT[token], "This NFT contract is already active");
        _activeNFT[token] = true;
        _nftContracts.push(token);
    }


    function removeNFTContract(address token) external onlyOwner {
        require(_activeNFT[token], "This NFT contract is not active");
        for (uint256 i = 0; i < _nftContracts.length; i++) {
            if (_nftContracts[i] == token) {
                _nftContracts[i] = _nftContracts[_nftContracts.length-1];
                _nftContracts.pop();
                _activeNFT[token] = false;
                break;
            }
        }
    }

    function setERC20Contract(address token) external onlyOwner {
        require((token != address(0) && token.isContract()),"Invalid ERC20 contract address");
        ERC20Contract = token;
    }


    function withdrawERC20(uint256 amount, uint256 nonce, uint256 timestamp, bytes memory sig) external {
        require(!_usedNonces[_msgSender()][nonce]);
        require(amount > 0, "Zero amount not allowed");
        require((timestamp > 0 && block.timestamp - 600 < timestamp), "Invalid timestamp");
        require(IERC20(ERC20Contract).balanceOf(address(this)) >= amount, "Insufficient ERC20 token amount");
        bytes32 message = prefixed(keccak256(abi.encodePacked(nonce, address(this), _msgSender(), amount, timestamp)));
        address signer = recoverSigner(message, sig);
        require(signer ==_verifier, "Unauthorized transaction");
        _usedNonces[_msgSender()][nonce] = true;
        IERC20(ERC20Contract).safeTransfer(_msgSender(), amount);
        if (amount <= _depositedERC20[_msgSender()]) {
            _depositedERC20[_msgSender()] -= amount;
        } else {
            _depositedERC20[_msgSender()] = 0;
        }
        emit WithdrawERC20(_msgSender(), amount, nonce);
    }


    function ownerWithdrawBNB(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Zero recepient address prohibited");
        uint256 balance = address(this).balance;
        require(amount <= balance, "Insufficient contract balance");
        (bool sent, ) = payable(to).call{value: amount}("");
        require(sent, "Failed to send BNB");
    }


    function ownerWithdrawERC20(address token, address to, uint256 amount) external onlyOwner {
        require(token != address(0), "Zero token address prohibited");
        require(to != address(0), "Zero recepient address prohibited");
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(amount <= balance, "Insufficient contract token balance");
        IERC20(token).safeTransfer(to, amount);
    }


    function ownerWithdrawNFT(address token, uint256 tokenId, address to) external onlyOwner {
        require((token != address(0) && token.isContract()), "Invalid NFT contract address");
        require(to != address(0), "Zero recepient address prohibited");
        require(IERC721(token).ownerOf(tokenId) == address(this), "Token is not stored on contract balance");
        IERC721(token).safeTransferFrom(address(this), to, tokenId);
    }



    function recoverSigner(bytes32 message, bytes memory sig) internal pure
    returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)
    internal
    pure
    returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }





}