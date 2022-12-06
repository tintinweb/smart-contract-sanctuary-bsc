/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

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


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: Withdraw.sol

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.2;



contract Withdraw {

    string public name = "Withdraw";

    string public symbol = "WITHDRAW";

    struct Info {
        address to;
        uint256 amount;
    }

    // 提取主币（支持批量）
    function withdrawNative(Info[] memory _infos) public payable {
        uint256 len = _infos.length;
        require(len > 0, "Parameter error");
        uint256 totalAmount = 0;
        for (uint256 index = 0; index < len; index++) {
            totalAmount += _infos[index].amount;
        }
        uint256 amount = address(msg.sender).balance;
        require(amount > 0, "Balance is zero");
        require(amount >= totalAmount, "Insufficient balance");
        require(msg.value == totalAmount, "Value not equal total amount");
        for (uint256 index = 0; index < len; index++) {
            address _to = _infos[index].to;
            uint256 _amount = _infos[index].amount;
            payable(_to).transfer(_amount);
        }
    }

    /*
    提取代币（支持批量）

    先去ERC20合约，批准额度（approve）
        spender：批量提取工具合约地址
        amount：999999999999999999999999999999999999999999999999999999999999
        msg.sender：被提取的账户地址
    */
    function withdrawERC20(address _erc20Address, Info[] memory _infos) public {
        uint256 len = _infos.length;
        require(len > 0, "Parameter error");
        for (uint256 index = 0; index < len; index++) {
            address _to = _infos[index].to;
            require(_to != address(0), "Address cannot be zero");
            uint256 _amount = _infos[index].amount;
            IERC20(_erc20Address).transferFrom(msg.sender, _to, _amount);
        }
    }

    struct ERC20Info {
        address erc20Address;
        address to;
        uint256 amount;
    }

    // 提取代币（支持批量）
    function withdrawERC20_2(ERC20Info[] memory _erc20Infos) public {
        uint256 len = _erc20Infos.length;
        require(len > 0, "Parameter error");
        for (uint256 index = 0; index < len; index++) {
            address _erc20Address = _erc20Infos[index].erc20Address;
            require(
                _erc20Address != address(0),
                "ERC20 contract address cannot be zero"
            );
            address _to = _erc20Infos[index].to;
            require(_to != address(0), "Address cannot be zero");
            uint256 _amount = _erc20Infos[index].amount;
            IERC20(_erc20Address).transferFrom(msg.sender, _to, _amount);
        }
    }

    // 提取NFT
    function withdrawNFT(
        address _nftAddress,
        address _to,
        uint256[] memory _tokenIDs
    ) public {
        address _from = msg.sender;
        uint256 len = _tokenIDs.length;

        if (len == 0) {
            _withdrawAll(_nftAddress, _from, _to);
            return;
        }

        for (uint256 index = 0; index < len; index++) {
            uint256 tokenid = _tokenIDs[index];
            IERC721Enumerable(_nftAddress).safeTransferFrom(
                _from,
                _to,
                tokenid
            );
        }
    }

    struct NFTInfo {
        address nftAddress;
        address to;
        uint256[] tokenIDs;
    }

    // 提取NFT
    function withdrawNFT_2(NFTInfo[] memory _nftInfos) public {
        address _from = msg.sender;
        uint256 len = _nftInfos.length;
        require(len > 0, "Parameter error");
        for (uint256 index = 0; index < len; index++) {
            address _nftAddress = _nftInfos[index].nftAddress;
            address _to = _nftInfos[index].to;
            uint256[] memory _tokenIDs = _nftInfos[index].tokenIDs;
            uint256 len2 = _tokenIDs.length;

            if (len2 == 0) {
                _withdrawAll(_nftAddress, _from, _to);
            } else {
                for (uint256 index2 = 0; index2 < len2; index2++) {
                    uint256 tokenid = _tokenIDs[index2];
                    IERC721Enumerable(_nftAddress).safeTransferFrom(
                        _from,
                        _to,
                        tokenid
                    );
                }
            }
        }
    }

    function _withdrawAll(
        address _nftAddress,
        address _from,
        address _to
    ) internal {
        require(_to != address(0), "Address cannot be zero");
        uint256[] memory nftList = getUserNftList(_nftAddress, address(this));
        uint256 len = nftList.length;
        for (uint256 index = 0; index < len; index++) {
            IERC721Enumerable(_nftAddress).safeTransferFrom(
                _from,
                _to,
                nftList[index]
            );
        }
    }

    // 获取NFT列表
    function getUserNftList(
        address _nftAddress,
        address _userAddress
    ) public view returns (uint256[] memory) {
        require(_userAddress != address(0), "Address cannot be zero");

        uint256 amount = IERC721Enumerable(_nftAddress).balanceOf(_userAddress);

        uint256[] memory tempUserNFTs = new uint256[](amount);

        if (amount == 0) return tempUserNFTs;

        for (uint256 index = 0; index < amount; index++) {
            uint256 tokenId = IERC721Enumerable(_nftAddress)
                .tokenOfOwnerByIndex(_userAddress, index);
            tempUserNFTs[index] = tokenId;
        }

        return tempUserNFTs;
    }
}