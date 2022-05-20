/**
 *Submitted for verification at BscScan.com on 2022-05-19
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

contract Shop_AAA{
    IERC20 public _token_USDT;
    IERC20 public _token_AAA;
    uint ratio_USDT_AAA = 100; // 1 USDT = 100 AAA
    address owner;

    constructor(){
        _token_USDT = IERC20(0xF9E6A2BAdEAfe0F6750A8Ce0F7BAEb79b227846F);
        _token_AAA = IERC20(0x930A6FD6314F7A2871e8CfE4Bf1E68982cEeb658);
        owner = msg.sender;
    }

    

    function buy_AAA_by_USDT(uint amount_USDT) public{
        require(_token_USDT.allowance(msg.sender, address(this))>= amount_USDT*10**18, "Allowwant to trasfer USDT is not enough");
        require(_token_USDT.balanceOf(msg.sender)>=amount_USDT*10**18, "You dont have USDT enough");
        uint amount_AAA = amount_USDT * ratio_USDT_AAA;
        require(_token_AAA.balanceOf(address(this))>=amount_AAA*10**18, "We dont have AAA enought to sell");
        
        _token_USDT.transferFrom(msg.sender, address(this), amount_USDT*10**18);
        _token_AAA.transfer(msg.sender, amount_AAA*10**18);
    }

    modifier checkOwner(){
        require(msg.sender==owner, "You are not allowed to process.");
        _;
    }

    function withdraw_USDT() public checkOwner{
        require(_token_USDT.balanceOf(address(this))>0, "Sorry, dont have USDT now");
        _token_USDT.transfer(owner, _token_USDT.balanceOf(address(this)));
    }
    
}
// File: contracts/MarketPlace.sol


pragma solidity ^0.8.0;



contract FGC_Marketplace{

    address public owner;
    address public addressToken; IERC20 public token;
    address public addressGun; IERC721 public gunNFT;
    address public addressFactory; IERC721 public factoryNFT;
    ItemOnSell[] public GunsOnSell;
    ItemOnSell[] public FactoryOnSell;
    uint tax = 3;
    address public addressReceiveTax;

    struct ItemOnSell{
        address CollectionAddress;
        uint tokenId;
        uint currencyPos;
        uint price;
        address seller;
        uint256 start_to_sell;
        address buyer;
        uint256 start_to_buy;
        uint status;  // 0 waiting for buyer, 1 sold, 2 cancel
    }

    struct Currency{
        uint typeCurrency;       // 0 BNB, 1 FGC,  ... position in currencyAddresses (addressp[])
        uint price;
    }

    address[] public currencyAddresses = [address(0)];  // 0: BNB, 1: _tokenFGC
    address[] public collectionAddresses;

    //Event
    event newItemSell();
    event newItemSold();
    event updateItemInSell();

    constructor(address _token, address _gunNFT, address _factoryNFT){
        owner = msg.sender;
        token = IERC20(_token);
        addressGun = _gunNFT;
        gunNFT = IERC721(addressGun);
        addressFactory = _factoryNFT;
        factoryNFT = IERC721(addressFactory);
        collectionAddresses.push(_gunNFT);
        collectionAddresses.push(_factoryNFT);
        currencyAddresses.push(_gunNFT);
    }

    modifier checkOwner{
        require(msg.sender==owner, "Sorry, you're not allowed");
        _;
    }

    function sell_Gun(uint _tokenId_Gun, uint _currencyPos, uint _token_Price) public returns(uint){
        require(gunNFT.ownerOf(_tokenId_Gun)==msg.sender, "Sorry, you are not token owner.");
        require(_token_Price>0, "Token price must larger than 0.");
        require(checkItemIsOnSell(addressGun, _tokenId_Gun)==false, "Sorry, this item is on sell already.");
        ItemOnSell memory item = ItemOnSell(addressGun, _tokenId_Gun, _currencyPos, _token_Price, msg.sender, block.timestamp, address(0), 0, 0);
        GunsOnSell.push(item);
        return GunsOnSell.length-1; // pos item vua sell
    }

    function buy_Gun(uint _posGunsOnSell, uint _poscurrencyAddresses, uint amountToken) public{
        // check tokenId is onSell
        require(GunsOnSell[_posGunsOnSell].status==0, "Item is not on sell");
        require(currencyAddresses.length>=2 && _poscurrencyAddresses>0 && _poscurrencyAddresses<currencyAddresses.length, "Currency is not valid");
        IERC20 currenToken = IERC20(currencyAddresses[_poscurrencyAddresses]);
        require(GunsOnSell[_posGunsOnSell].price<=amountToken, "Token is not enought for item price");
        require(currenToken.balanceOf(msg.sender)>=GunsOnSell[_posGunsOnSell].price, "You don't have enough token");
        require(currenToken.allowance(msg.sender, address(this))>=GunsOnSell[_posGunsOnSell].price, "You haven't approved token yet");
        require(gunNFT.getApproved(GunsOnSell[_posGunsOnSell].tokenId)==address(this), "This item is not approved for market to sell");
        
        if(tax>0){ 
            currenToken.transferFrom(msg.sender, addressReceiveTax, amountToken*tax/100);
            currenToken.transferFrom(msg.sender, addressReceiveTax, amountToken*(100-tax)/100);
        }else{
            currenToken.transferFrom(msg.sender, address(this), amountToken);
        }
        
        GunsOnSell[_posGunsOnSell].buyer = msg.sender;
        gunNFT.transferFrom(GunsOnSell[_posGunsOnSell].seller, msg.sender, GunsOnSell[_posGunsOnSell].tokenId);
        GunsOnSell[_posGunsOnSell].start_to_buy = block.timestamp;
        GunsOnSell[_posGunsOnSell].buyer = msg.sender;
        GunsOnSell[_posGunsOnSell].status = 1;  // sold
    }

    function update_item_selling_price__in_GunNFT(uint _posGun,uint _newCurrencyPos, uint _newToken_Price) public{
        require(gunNFT.ownerOf(GunsOnSell[_posGun].tokenId)==msg.sender, "Sorry, you are not token owner.");
        require(_newToken_Price>0, "Token price must larger than 0.");
        //require(checkItemIsOnSell(addressGun, ItemOnSell[_posGun].tokenId)==true, "Sorry, this item is not on sell already.");
        require(GunsOnSell[_posGun].status==0, "Sorry, this item is not on sell already.");
        GunsOnSell[_posGun].currencyPos = _newCurrencyPos;
        GunsOnSell[_posGun].price = _newToken_Price;
    }

    function cancel_selling_item_in_GunNFT(uint _posGun) public{
        require(gunNFT.ownerOf(GunsOnSell[_posGun].tokenId)==msg.sender, "Sorry, you are not token owner.");
        require(GunsOnSell[_posGun].seller==msg.sender, "You are not seller of this item.");
        require(GunsOnSell[_posGun].status==0, "Sorry, this item is not on sell already.");
        GunsOnSell[_posGun].status = 2; // cancel selling
    }

    function buy_Gun_via_BNB(uint _posGunsOnSell) public payable{
        // check currenciu iten = address(0)
        require(GunsOnSell[_posGunsOnSell].currencyPos==0, "Just accept BNB");
        require(GunsOnSell[_posGunsOnSell].status==0, "Item is not on sell");
        require(GunsOnSell[_posGunsOnSell].price<=msg.value, "BNB is not enought for item price");
        require(gunNFT.getApproved(GunsOnSell[_posGunsOnSell].tokenId)==address(this), "This item is not approved for market to sell");
        
        if(tax>0){ 
            payable(addressReceiveTax).transfer(msg.value*tax/100);
        }
        
        GunsOnSell[_posGunsOnSell].buyer = msg.sender;
        gunNFT.transferFrom(GunsOnSell[_posGunsOnSell].seller, msg.sender, GunsOnSell[_posGunsOnSell].tokenId);
        GunsOnSell[_posGunsOnSell].start_to_buy = block.timestamp;
        GunsOnSell[_posGunsOnSell].buyer = msg.sender;
        GunsOnSell[_posGunsOnSell].status = 1;  // sold
    }

    // check tokenId is available inside selling items.
    function checkItemIsOnSell(address collection, uint tokenId) public view returns(bool){
        bool check = false;
        if(collection==addressGun){
            if(GunsOnSell.length>0){
                for(uint count=0; count<GunsOnSell.length; count++){
                    if(GunsOnSell[count].tokenId==tokenId && GunsOnSell[count].status==1){
                        check = true;
                    }
                }
            }
        }
        if(collection==addressFactory){
            if(FactoryOnSell.length>0){
                for(uint count=0; count<FactoryOnSell.length; count++){
                    if(FactoryOnSell[count].tokenId==tokenId && FactoryOnSell[count].status==1){
                        check = true;
                    }
                }
            }
        }
        return check;
    }

    function checkAddressIsInCollection(address _addressCheck) public view returns(bool){
        bool check = false;
        for(uint count=0; count<=collectionAddresses.length; count++){
            if(collectionAddresses[count]==_addressCheck){
                check = true;
                return check;
            }
        }
        return check;
    }

    // Factory
    function sell_Factory(uint _tokenId_Gun, uint _currencyPos, uint _token_Price) public returns(uint){
        require(gunNFT.ownerOf(_tokenId_Gun)==msg.sender, "Sorry, you are not token owner.");
        require(_token_Price>0, "Token price must larger than 0.");
        require(checkItemIsOnSell(addressGun, _tokenId_Gun)==false, "Sorry, this item is on sell already.");
        ItemOnSell memory item = ItemOnSell(addressGun, _tokenId_Gun, _currencyPos, _token_Price, msg.sender, block.timestamp, address(0), 0, 0);
        FactoryOnSell.push(item);
        return FactoryOnSell.length-1; // pos item vua sell
    }

    function buy_Factory(uint _posFactoryOnSell, uint _poscurrencyAddresses, uint amountToken) public{
        // check tokenId is onSell
        require(FactoryOnSell[_posFactoryOnSell].status==0, "Item is not on sell");
        require(currencyAddresses.length>=2 && _poscurrencyAddresses>0 && _poscurrencyAddresses<currencyAddresses.length, "Currency is not valid");
        IERC20 currenToken = IERC20(currencyAddresses[_poscurrencyAddresses]);
        require(FactoryOnSell[_posFactoryOnSell].price<=amountToken, "Token is not enought for item price");
        require(currenToken.balanceOf(msg.sender)>=FactoryOnSell[_posFactoryOnSell].price, "You don't have enough token");
        require(currenToken.allowance(msg.sender, address(this))>=FactoryOnSell[_posFactoryOnSell].price, "You haven't approved token yet");
        require(gunNFT.getApproved(FactoryOnSell[_posFactoryOnSell].tokenId)==address(this), "This item is not approved for market to sell");
        
        if(tax>0){ 
            currenToken.transferFrom(msg.sender, addressReceiveTax, amountToken*tax/100);
            currenToken.transferFrom(msg.sender, addressReceiveTax, amountToken*(100-tax)/100);
        }else{
            currenToken.transferFrom(msg.sender, address(this), amountToken);
        }
        
        FactoryOnSell[_posFactoryOnSell].buyer = msg.sender;
        gunNFT.transferFrom(FactoryOnSell[_posFactoryOnSell].seller, msg.sender, FactoryOnSell[_posFactoryOnSell].tokenId);
        FactoryOnSell[_posFactoryOnSell].start_to_buy = block.timestamp;
        FactoryOnSell[_posFactoryOnSell].buyer = msg.sender;
        FactoryOnSell[_posFactoryOnSell].status = 1;  // sold
    }

    function update_item_selling_price__in_FactoryNFT(uint _posGun,uint _newCurrencyPos, uint _newToken_Price) public{
        require(gunNFT.ownerOf(FactoryOnSell[_posGun].tokenId)==msg.sender, "Sorry, you are not token owner.");
        require(_newToken_Price>0, "Token price must larger than 0.");
        //require(checkItemIsOnSell(addressGun, ItemOnSell[_posGun].tokenId)==true, "Sorry, this item is not on sell already.");
        require(FactoryOnSell[_posGun].status==0, "Sorry, this item is not on sell already.");
        FactoryOnSell[_posGun].currencyPos = _newCurrencyPos;
        FactoryOnSell[_posGun].price = _newToken_Price;
    }

    function cancel_selling_item_in_FactoryNFT(uint _posGun) public{
        require(gunNFT.ownerOf(FactoryOnSell[_posGun].tokenId)==msg.sender, "Sorry, you are not token owner.");
        require(FactoryOnSell[_posGun].seller==msg.sender, "You are not seller of this item.");
        require(FactoryOnSell[_posGun].status==0, "Sorry, this item is not on sell already.");
        FactoryOnSell[_posGun].status = 2; // cancel selling
    }

    function buy_Factory_via_BNB(uint _posFactoryOnSell) public payable{
        // check currenciu iten = address(0)
        require(FactoryOnSell[_posFactoryOnSell].currencyPos==0, "Just accept BNB");
        require(FactoryOnSell[_posFactoryOnSell].status==0, "Item is not on sell");
        require(FactoryOnSell[_posFactoryOnSell].price<=msg.value, "BNB is not enought for item price");
        require(gunNFT.getApproved(FactoryOnSell[_posFactoryOnSell].tokenId)==address(this), "This item is not approved for market to sell");
        
        if(tax>0){ 
            payable(addressReceiveTax).transfer(msg.value*tax/100);
        }
        
        FactoryOnSell[_posFactoryOnSell].buyer = msg.sender;
        gunNFT.transferFrom(FactoryOnSell[_posFactoryOnSell].seller, msg.sender, FactoryOnSell[_posFactoryOnSell].tokenId);
        FactoryOnSell[_posFactoryOnSell].start_to_buy = block.timestamp;
        FactoryOnSell[_posFactoryOnSell].buyer = msg.sender;
        FactoryOnSell[_posFactoryOnSell].status = 1;  // sold
    }
    

    // Feed data
    function get_gun_onSell_total() public view returns(uint){
        return GunsOnSell.length;
    }

    function get_factory_onSell_total() public view returns(uint){
        return FactoryOnSell.length;
    }

    function get_item_detail(uint ordering) public view returns(address, uint, uint, uint, address, address,  uint ){
        require(ordering<GunsOnSell.length, "Wrong ordering.");
        return(
            GunsOnSell[ordering].CollectionAddress, GunsOnSell[ordering].tokenId, GunsOnSell[ordering].currencyPos, GunsOnSell[ordering].price, GunsOnSell[ordering].seller, GunsOnSell[ordering].buyer, GunsOnSell[ordering].status
        );
    }

    function get_collection_total() public view returns(uint){
        return collectionAddresses.length;
    }

    function get_ollection_detail(uint ordering) public view returns(address){
        require(ordering<collectionAddresses.length, "Wrong ordering.");
        return(collectionAddresses[ordering]);
    }

    function checkToken_exist_in_currencyAddresses(address _newAddress) public view returns(bool){
        bool check = false;
        for(uint count=0; count<currencyAddresses.length; count++){
            if(currencyAddresses[count]==_newAddress) check = true;
        }
        return check;
    }

    function add_new_token_Whitelist(address _newAddress) public checkOwner{
        require(checkToken_exist_in_currencyAddresses(_newAddress)==false, "Token has been in whitelist already.");
        currencyAddresses.push(_newAddress);
    }

    function update_Tax(uint _newTax) public checkOwner{
        require(_newTax<=10, "Tax can not larger than 10%");
        tax = _newTax;
    }

    function update_tax_receive_Address(address _newAddress) public checkOwner{
        require(_newAddress != address(0), "Addres must not be Zero address");
        addressReceiveTax = _newAddress;
    }

    function withdraw_token(uint _posInCurrency) public checkOwner{
        require(_posInCurrency<currencyAddresses.length, "Wrong currency addresses position");
        IERC20 __token = IERC20(currencyAddresses[_posInCurrency]);
        require(__token.balanceOf(address(this))>0, "Token balance is zero");
        __token.transfer(addressReceiveTax, __token.balanceOf(address(this)));
    }

    // should not withdraw all BNB, need amount of BNB for gas
    function withdraw_BNB(uint amount) public checkOwner{
        require(address(this).balance>amount && amount>0, "BNB balance is zero");
        payable(addressReceiveTax).transfer(amount);
    }

}