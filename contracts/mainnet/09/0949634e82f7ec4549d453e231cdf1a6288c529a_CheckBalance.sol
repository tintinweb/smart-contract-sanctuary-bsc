/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC1155 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

interface IERC721 {
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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

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
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

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
    function transferFrom(address from, address to, uint256 tokenId) external;

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
    function setApprovalForAll(address operator, bool approved) external;

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

contract CheckBalance {

    address tokenContract;
    address nftContract;
    address owner;

    constructor() {
        tokenContract = 0xe6DF05CE8C8301223373CF5B969AFCb1498c5528;
        nftContract = 0x6f282fc910CD6eCdCcC9E0f06e6EA3e5602A24d5;
        owner = msg.sender;
    }


    function transferOwner(address _addr)public{
        require(msg.sender == owner,"not owner");
        owner = _addr;
    }

    function setContract(address _tokenContract, address _nftContract)public{
        require(msg.sender == owner,"not owner");
        tokenContract = _tokenContract;
        nftContract = _nftContract;
    }

    function getContract()public view returns(address ca1,address ca2){
        ca1 = tokenContract;
        ca2 = nftContract;
    }

    function OwnerIs()public view returns(address own){
        own = owner;
    }

    function checkTokenBalance(address _addr) public view returns(uint256 tokenBalance){
        tokenBalance = IERC20(tokenContract).balanceOf(_addr);
    }

    function check721Balance(address _addr) public view returns(uint256 nftBalance){
        nftBalance = IERC721(nftContract).balanceOf(_addr);
    }

    function check1155Balance(address _addr, uint256 _tokenId) public view returns(uint256 nftBalance){
        nftBalance = IERC1155(nftContract).balanceOf(_addr,_tokenId);
    }

    function multiCheck(string memory _type, address[] memory _addr, uint256 _tokenId ) public view returns(uint256[] memory bnbBalance, uint256[] memory tokenBalance, uint256[] memory nftBalance ){
        uint len = _addr.length;
        bnbBalance = new uint[](len);
        tokenBalance = new uint[](len);
        nftBalance = new uint[](len);

        for (uint i; i < len; i++){
            bnbBalance[i] = _addr[i].balance;
            tokenBalance[i] = IERC20(tokenContract).balanceOf(_addr[i]);
            if(keccak256(bytes(_type)) == keccak256("721")){
                nftBalance[i] = IERC721(nftContract).balanceOf(_addr[i]);
            }
            if(keccak256(bytes(_type)) == keccak256("1155")){
                nftBalance[i] = IERC1155(nftContract).balanceOf(_addr[i],_tokenId);
            }
        }
    }

    function multiCheckContract(string memory _type, address[] memory _addr,address _tokenContract,address _nftContract, uint256 _tokenId ) public view returns(uint256[] memory bnbBalance, uint256[] memory tokenBalance, uint256[] memory nftBalance ){
        uint len = _addr.length;
        bnbBalance = new uint[](len);
        tokenBalance = new uint[](len);
        nftBalance = new uint[](len);

        for (uint i; i < len; i++){
            bnbBalance[i] = _addr[i].balance;
            tokenBalance[i] = IERC20(_tokenContract).balanceOf(_addr[i]);
            if(keccak256(bytes(_type)) == keccak256("721")){
                nftBalance[i] = IERC721(_nftContract).balanceOf(_addr[i]);
            }
            if(keccak256(bytes(_type)) == keccak256("1155")){
                nftBalance[i] = IERC1155(_nftContract).balanceOf(_addr[i],_tokenId);
            }
        }
    }

    function multiCheckBalance(address[] memory _addr) public view returns(uint256[] memory bnbBalance){
        uint len = _addr.length;
        bnbBalance = new uint[](len);
        for (uint i; i < len; i++){
            bnbBalance[i] = _addr[i].balance;
        }
    }

    function multiCheckToken(address[] memory _addr,address _contract) public view returns(uint256[] memory tokenBalance){
        uint len = _addr.length;
        tokenBalance = new uint[](len);
        for (uint i; i < len; i++){
            tokenBalance[i] = IERC20(_contract).balanceOf(_addr[i]);
        }
    }

    function multiCheck721(address[] memory _addr,address _contract) public view returns(uint256[] memory nftBalance ){
        uint len = _addr.length;
        nftBalance = new uint[](len);
        for (uint i; i < len; i++){
            nftBalance[i] = IERC721(_contract).balanceOf(_addr[i]);
        }
    }

    function multiCheck1155(address[] memory _addr,uint256 _tokenId, address _contract) public view returns(uint256[] memory nftBalance ){
        uint len = _addr.length;
        nftBalance = new uint[](len);
        for (uint i; i < len; i++){
            nftBalance[i] = IERC1155(_contract).balanceOf(_addr[i],_tokenId);
        }
    }

}