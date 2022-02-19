/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// Sources flattened with hardhat v2.8.0 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

// SPDX-License-Identifier: MIT
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


// File @openzeppelin/contracts/security/[email protected]

// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/access/[email protected]

  
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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


// File @openzeppelin/contracts/utils/introspection/[email protected]

  
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


// File @openzeppelin/contracts/token/ERC721/[email protected]

  
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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


// File @openzeppelin/contracts/token/ERC20/[email protected]

  
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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


// File contracts/NFTSale.sol
pragma solidity 0.8.4;

contract NFTSale is Ownable, Pausable {

    address [] public priceTokens;   
    mapping(address => bool) private _blacklist; 
    uint16 public fee; 
    Payee[] public payees; 
    mapping(bytes32 => Sale) private _saleRecordDetail; //keccak256(abi.encodePacked(nftAddress,tokenId))
    mapping(address => bytes32[]) private _saleRecords; //sellerAddress与keccak256(abi.encodePacked(nftAddress,tokenId))


    struct Payee {
        address payable beneficiary; 
        uint16 percentage; 
    }

    struct Sale {
        string orderId;
        address sellerAddress;
        address nftAddress;
        address priceToken;
        uint256 tokenId;
        uint256 tokenPrice;
        uint256 updateAt;
    }

    event CreateSale(address indexed sellerAddress, address indexed nftAddress,uint256 indexed tokenId);
    event UpdateSale(address indexed sellerAddress, address indexed nftAddress,uint256 indexed tokenId);
    event DeleteSale(address indexed sellerAddress, address indexed nftAddress,uint256 indexed tokenId);
    event DeleteAllSale(address indexed sellerAddress);

    /**
     * Verify whether the specified price token is met
     */
    modifier explicitPriceToken(address priceToken) {
        require(priceTokens.length > 0, "price tokens must be specified");
        bool flag;
        for(uint256 i = 0;i < priceTokens.length; i++){
            if(priceTokens[i] == priceToken){
                flag = true;
                break;
            }
        }
        require(flag, "price token not explicitly");
        _;
    }

    /**
     * Check whether the range of fee ratio is correct
     */
    modifier checkFee(uint16 fee_) {
        require(fee_ > 0,"fee ratio must be greater than 0");
        require(fee_ < 10000,"fee ratio must be less than 10000");
        _;
    }

    /**
     * Check whether the transaction address is in the blacklist
     */
    modifier checkBlacklist(address addr){
        require(!isInBlackList(addr),"operation is not allowed in the blacklist");
        _;
    }

    /**
     * Verify whether it is NFT owner
     */
    modifier explicitNFTOwner(address nftOwner, address nftAddress, uint256 tokenId){
        address nftOwner_ = IERC721(nftAddress).ownerOf(tokenId);
        require(nftOwner_ == nftOwner, "not NFT owner");
        _;
    }

    constructor(uint16 fee_, address[] memory priceTokens_, address[] memory beneficiaries, uint16[] memory percentages) checkFee(fee_){
        fee = fee_;
        priceTokens = priceTokens_;
        setFeeSharing(beneficiaries,percentages);
    }

    function setFee(uint16 fee_) public onlyOwner checkFee(fee_){
        fee = fee_;
    }

    function setFeeSharing(address[] memory beneficiaries,uint16[] memory percentages) public onlyOwner {
        require(beneficiaries.length == percentages.length, "SetFeeSharing: beneficiaries.length should equal percentages.length");
        uint256 total = 0;
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            require(percentages[i] <= 100, "SetFeeSharing: percentages must less than 100");
            total += percentages[i];
        }
        require(total == 100, "SetFeeSharing: percentages sum must 100");
        delete payees;
        for(uint256 i = 0; i < beneficiaries.length; i++) {
            payees.push(Payee(payable(beneficiaries[i]), percentages[i]));
        }
    }

    function getFeeSharing(address beneficiary) public view returns (uint32){
        uint32 percentage;
        for(uint256 i = 0;i < payees.length; i++){
            if(payees[i].beneficiary == beneficiary){
                percentage = payees[i].percentage;
                break;
            }
        }
        return percentage;
    }


    function pause() public whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() public whenPaused onlyOwner {
        _unpause();
    }

    function addBlackList(address addr) public onlyOwner{
        _blacklist[addr] = true;
    }
    function removeBlackList(address addr) public onlyOwner{
        delete _blacklist[addr];
    }
    function isInBlackList(address addr) public view returns (bool){
        return _blacklist[addr];
    }

    function forceCancel(address sellerAddress,address nftAddress,uint256 tokenId) public onlyOwner{
        _deleteSale(sellerAddress,nftAddress,tokenId);
    }

    function forceCancelAll(address sellerAddress) public onlyOwner{
        _deleteAllSale(sellerAddress);
    }

    function setPriceToken(address[] memory priceTokens_) public onlyOwner{
        priceTokens = priceTokens_;
    }

    function getPriceTokenLength() public view returns (uint256){
        return priceTokens.length;
    }

    function getPriceToken(uint256 index) public view returns (address){
        return priceTokens[index];
    }

/*    function withdraw20(address to) public onlyOwner{

    }
    function withdraw721(address to) public onlyOwner{

    }
    function withdraw1155(address to) public onlyOwner{

    }*/

    function createSale(string memory orderId,address nftAddress,address priceToken,uint256 tokenId,uint256 tokenPrice)
    public whenNotPaused checkBlacklist(_msgSender()) explicitNFTOwner(_msgSender(),nftAddress,tokenId) explicitPriceToken(priceToken){
        address sellerAddress = _msgSender();
        require(!isSale(nftAddress,tokenId), "CreateSale: existing sale record");
        bytes32 recordHash = _saleRecordHash(nftAddress,tokenId);
        _saleRecords[sellerAddress].push(recordHash);
        _saleRecordDetail[recordHash] = Sale(orderId, sellerAddress,nftAddress,priceToken,tokenId,tokenPrice,block.timestamp);
        emit CreateSale(sellerAddress,nftAddress,tokenId);
    }

    function updateSale(address nftAddress,address priceToken,uint256 tokenId,uint256 tokenPrice)
    public whenNotPaused checkBlacklist(_msgSender()) explicitNFTOwner(_msgSender(),nftAddress,tokenId) explicitPriceToken(priceToken){
        Sale storage sale = _saleRecordDetail[_saleRecordHash(nftAddress,tokenId)];
        require(sale.sellerAddress != address(0), "UpdateSale: not existing nft sale record");
        sale.priceToken = priceToken;
        sale.tokenPrice = tokenPrice;
        sale.updateAt = block.timestamp;
        emit UpdateSale(sale.sellerAddress,nftAddress,tokenId);
    }

    function getSale(address nftAddress,uint256 tokenId) public view returns (Sale memory){
        return _saleRecordDetail[_saleRecordHash(nftAddress,tokenId)];
    }
    function isSale(address nftAddress,uint256 tokenId) public view returns (bool){
        return getSale(nftAddress,tokenId).sellerAddress != address(0);
    }
    function isSeller(address sellerAddress,address nftAddress,uint256 tokenId) public view returns (bool){
        return getSale(nftAddress,tokenId).sellerAddress == sellerAddress;
    }
    function getPriceTokenAndPrice(address nftAddress,uint256 tokenId) public view returns (address priceToken, uint256 tokenPrice){
        Sale memory sale = getSale(nftAddress,tokenId);
        return (sale.priceToken, sale.tokenPrice);
    }

    function cancelSale(address nftAddress,uint256 tokenId) public{
        require(isSale(nftAddress,tokenId), "CancelSale: not existing sale record");
        _deleteSale(_msgSender(),nftAddress,tokenId);
    }

    function cancelAllSale() public{
        _deleteAllSale(_msgSender());
    }

    function _deleteSale(address sellerAddress,address nftAddress,uint256 tokenId) private {
        bytes32 recordHash = _saleRecordHash(nftAddress,tokenId);
        delete _saleRecordDetail[recordHash];

        bytes32[] storage recordHashes = _saleRecords[sellerAddress];
        bool flag;
        for(uint256 i = 0; i < recordHashes.length; i++){
            if(recordHashes[i] == recordHash){
                flag = true;
            }
            if(flag && i < recordHashes.length-1){
                recordHashes[i] = recordHashes[i+1];
            }
        }
        if(flag){
            delete recordHashes[recordHashes.length-1];
        }
        emit DeleteSale(sellerAddress,nftAddress,tokenId);
    }

    function _deleteAllSale(address sellerAddress) private {
        bytes32[] memory recordHashes = _saleRecords[sellerAddress];
        for(uint256 i = 0; i < recordHashes.length; i++){
            delete _saleRecordDetail[recordHashes[i]];
        }
        delete _saleRecords[sellerAddress];
        emit DeleteAllSale(sellerAddress);
    }

    function _saleRecordHash(address nftAddress, uint256 tokenId) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(nftAddress,tokenId));
    }

    function bidSale(address payable sellerAddress,address nftAddress,uint256 tokenId)
    public whenNotPaused checkBlacklist(_msgSender()) explicitNFTOwner(sellerAddress,nftAddress,tokenId) {
        require(isSale(nftAddress,tokenId), "BidSale: not existing sale record");
        Sale memory sale = getSale(nftAddress,tokenId);
        
        IERC721(nftAddress).transferFrom(sellerAddress,msg.sender, tokenId);
       
        _deleteSale(sellerAddress,nftAddress,tokenId);
      
        uint256 actualAmount = sale.tokenPrice * (10000 - fee) / 10000;
       
        uint256 feeAmount = sale.tokenPrice - actualAmount;
      
        if(sale.priceToken == address(0)){
            payable(sellerAddress).transfer(actualAmount);
        }else{
            IERC20(sale.priceToken).transferFrom(_msgSender(), sellerAddress, actualAmount);
        }
        uint256 curSum = 0;
        for (uint256 i = 0; i < payees.length; i++) {
            uint256 curAmount = (i == payees.length - 1) ? (feeAmount - curSum) : ((feeAmount * payees[i].percentage) / 100);
            curSum += curAmount;
            if(sale.priceToken == address(0)){
                payees[i].beneficiary.transfer(curAmount);
            }else{
                IERC20(sale.priceToken).transferFrom(_msgSender(),payees[i].beneficiary,curAmount);
            }
        }

    }
}