/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// SPDX-License-Identifier: MIT
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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// File: contracts/Coinex_Marketplace.sol


pragma solidity ^0.8.0;



contract Metaz_Marketplace{

    address public owner;
    address public addressToken; 
    IERC20 public token;

    uint tax_market = 3; //  
    uint tax_royal = 2;  // Tax transfer cho collection owner
    address public addressReceiveTax;

    address[] public currenciesAddress = [address(0)];  // 0: CET, 1: _tokenFGC

    ItemOnSell[] public itemsOnSell;
    struct ItemOnSell{
        uint collectionPos;         // pos in Collections
        uint tokenId;
        uint currencyPos;           // pos in currenciesAddress
        uint price;
        address seller;
        uint256 start_to_sell;
        address buyer;
        uint256 start_to_buy;
        uint status;                // 0 waiting for buyer, 1 sold, 2 cancel
    }

    Collection[] public Collections;
    struct Collection{
        address Address;
        uint Status;    // 1 active, 0 disable
    }

    //Event
    event event_sell_Item(uint collectionPos, uint _tokenId_Item, uint _currencyPos, uint price);
    event event_update_price_sell_Item(uint pos_itemsOnSell, uint _currencyPos, uint price);
    event event_cancel_sell_Item(uint pos_itemsOnSell);

    constructor(address _token){
        owner = msg.sender;
        token = IERC20(_token);
        currenciesAddress.push(_token);
    }

    modifier checkOwner{
        require(msg.sender==owner, "Sorry, you're not allowed");
        _;
    }

    function sell_Item(uint collectionPos, uint _tokenId_Item, uint _currencyPos, uint price) public{
        require(collectionPos<Collections.length, "Wrong collection position.");
        require(_currencyPos<currenciesAddress.length, "Wrong currency position");
        require(price>0, "Wrong currency price");
        IERC721 currentCollection = IERC721(Collections[collectionPos].Address);
        require(Collections[collectionPos].Status==1, "Collection is not allowed to sell at this moment");

        // check item onsell
        require(checkItemIsOnSell(collectionPos, _tokenId_Item)==false, "Item has been on sell already");

        //check owner item
        require(currentCollection.ownerOf(_tokenId_Item)==msg.sender, "You are not item owner");

        currentCollection.approve(address(this), _tokenId_Item);
        ItemOnSell memory item = ItemOnSell(collectionPos, _tokenId_Item, _currencyPos, price, msg.sender, block.timestamp, address(0), 0, 0);
        itemsOnSell.push(item);

        emit event_sell_Item(collectionPos, _tokenId_Item, _currencyPos, price);
    }

    function update_price_sell_Item(uint pos_itemsOnSell, uint _currencyPos, uint price) public{
        require(itemsOnSell[pos_itemsOnSell].status!=1, "Item is sold");
        require(pos_itemsOnSell<itemsOnSell.length, "Wrong item on sell position");
        require(_currencyPos<currenciesAddress.length, "Wrong currency position");
        require(price>0, "Wrong currency price");

        IERC721 currentCollection = IERC721(Collections[itemsOnSell[pos_itemsOnSell].collectionPos].Address);
        require(Collections[itemsOnSell[pos_itemsOnSell].collectionPos].Status==1, "Collection is not allowed to sell at this moment");

        // check item onsell
        require(checkItemIsOnSell(itemsOnSell[pos_itemsOnSell].collectionPos, itemsOnSell[pos_itemsOnSell].tokenId)==true, "Item has been not on sell already");

        //check owner item
        require(currentCollection.ownerOf(itemsOnSell[pos_itemsOnSell].tokenId)==msg.sender, "You are not item owner");

        itemsOnSell[pos_itemsOnSell].currencyPos = _currencyPos;
        itemsOnSell[pos_itemsOnSell].price = price;

        emit event_update_price_sell_Item(pos_itemsOnSell, _currencyPos, price);
    }

    function cancel_sell_Item(uint pos_itemsOnSell) public{
        require(pos_itemsOnSell<itemsOnSell.length, "Wrong item on sell position");

        IERC721 currentCollection = IERC721(Collections[itemsOnSell[pos_itemsOnSell].collectionPos].Address);
        require(Collections[itemsOnSell[pos_itemsOnSell].collectionPos].Status==1, "Collection is not allowed to sell at this moment");

        // check item onsell
        require(checkItemIsOnSell(itemsOnSell[pos_itemsOnSell].collectionPos, itemsOnSell[pos_itemsOnSell].tokenId)==true, "Item has been not on sell already");

        //check owner item
        require(currentCollection.ownerOf(itemsOnSell[pos_itemsOnSell].tokenId)==msg.sender, "You are not item owner");

        itemsOnSell[pos_itemsOnSell].status = 2;

        emit event_cancel_sell_Item(pos_itemsOnSell);
    }

    function checkItemIsOnSell(uint collectionPos, uint tokenId) public view returns(bool){
        bool check = false;
        if(itemsOnSell.length>0){
            for(uint count=0; count<itemsOnSell.length; count++){
                if(itemsOnSell[count].collectionPos==collectionPos && itemsOnSell[count].tokenId==tokenId){
                    check = true;
                    break;
                }
            }
        }
        return check;
    }

    // get data
    function get_Item_onSell_total() public view returns(uint){
        return itemsOnSell.length;
    }

    function get_Item_onSell_detail(uint ordering) public view returns(uint, uint, uint, uint, address, uint256,  uint ){
        require(ordering<itemsOnSell.length, "Wrong items on sell ordering.");
        return(
            itemsOnSell[ordering].collectionPos, itemsOnSell[ordering].tokenId, itemsOnSell[ordering].currencyPos, 
            itemsOnSell[ordering].price, itemsOnSell[ordering].seller, itemsOnSell[ordering].start_to_sell,
            itemsOnSell[ordering].status
        );
    }

    function get_collection_total() public view returns(uint){
        return Collections.length;
    }

    function get_collection_detail(uint ordering) public view returns(address, uint){
        require(ordering<Collections.length, "Wrong ordering.");
        return(Collections[ordering].Address, Collections[ordering].Status);
    }


    /*
    function buy_Item(uint _posItemsOnSell, uint _poscurrenciesAddress, uint amountToken) public{
        // check tokenId is onSell
        require(ItemsOnSell[_posItemsOnSell].status==0, "Item is not on sell");
        require(currenciesAddress.length>=2 && _poscurrenciesAddress>0 && _poscurrenciesAddress<currenciesAddress.length, "Currency is not valid");
        IERC20 currenToken = IERC20(currenciesAddress[_poscurrenciesAddress]);
        require(ItemsOnSell[_posItemsOnSell].price<=amountToken, "Token is not enought for item price");
        require(currenToken.balanceOf(msg.sender)>=ItemsOnSell[_posItemsOnSell].price, "You don't have enough token");
        require(currenToken.allowance(msg.sender, address(this))>=ItemsOnSell[_posItemsOnSell].price, "You haven't approved token yet");
        require(ItemNFT.getApproved(ItemsOnSell[_posItemsOnSell].tokenId)==address(this), "This item is not approved for market to sell");
        
        if(tax>0){ 
            currenToken.transferFrom(msg.sender, addressReceiveTax, amountToken*tax/100);
            currenToken.transferFrom(msg.sender, addressReceiveTax, amountToken*(100-tax)/100);
        }else{
            currenToken.transferFrom(msg.sender, address(this), amountToken);
        }
        
        ItemsOnSell[_posItemsOnSell].buyer = msg.sender;
        ItemNFT.transferFrom(ItemsOnSell[_posItemsOnSell].seller, msg.sender, ItemsOnSell[_posItemsOnSell].tokenId);
        ItemsOnSell[_posItemsOnSell].start_to_buy = block.timestamp;
        ItemsOnSell[_posItemsOnSell].buyer = msg.sender;
        ItemsOnSell[_posItemsOnSell].status = 1;  // sold
    }
    */


    function update_Tax(uint _tax_market, uint _tax_royal) public checkOwner{
        require(_tax_market<=25, "Tax market can not larger than 25%");
        require(_tax_royal<=25, "Tax royal can not larger than 25%");
        tax_market = _tax_market;
        tax_royal = _tax_royal;
    }

    function update_tax_receive_Address(address _newAddress) public checkOwner{
        require(_newAddress != address(0), "Addres must not be Zero address");
        addressReceiveTax = _newAddress;
    }

    function withdraw_token(uint _posInCurrency) public checkOwner{
        require(_posInCurrency<currenciesAddress.length, "Wrong currency addresses position");
        IERC20 __token = IERC20(currenciesAddress[_posInCurrency]);
        require(__token.balanceOf(address(this))>0, "Token balance is zero");
        __token.transfer(addressReceiveTax, __token.balanceOf(address(this)));
    }

    // should not withdraw all BNB, need amount of BNB for gas
    function withdraw__(uint amount) public checkOwner{
        require(address(this).balance>amount && amount>0, "BNB balance is zero");
        payable(addressReceiveTax).transfer(amount);
    }

}