/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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

//import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
    , * - `tokenId` token must exist and be owned by `from`.
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


contract Ownable {
    address private _owner;
    
    event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
    );
    
    constructor()  {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
    }
    
    function owner() public view returns (address) {
    return _owner;
    }
    
    modifier onlyOwner() {
    require(isOwner(), "Ownable: caller is not the owner");
    _;
    }
    
    function isOwner() public view returns (bool) {
    return msg.sender == _owner;
    }
    
    function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
    }
    
    function _transferOwnership(address newOwner) internal {
    require(
    newOwner != address(0), 
    "Ownable: new owner is the zero address"
    );
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
    }
}


interface stakePool{
    function totalTicket(address _address) external view returns(uint256);
}



/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

contract mysterybox is Ownable{
    
    using Address for address;

    uint256 public mysteryboxCounter=0;
    uint256 public boxesCounter =0;
    uint256 public itemcounter =0;
    uint256 private randomNumcounter = 0;

     mapping(address => mapping(uint256 => uint256[])) private UsersBoxes;         
    //nested mapping from user address and mysterybox id which gives us boxes user has opened particular mysterybox

    struct MysteryBox {
        uint256 mysteryBoxId;           //particular mysterybox id
        string Name;
        uint256 itemCount;              //totalitems offered in mysterybox
        uint256[] itemArr;              //stores the value which represent item structure
        uint256 totalTreasureBoxes;     // how many boxes available
        uint256 claimTime;              //to set time for claimimg the treaurybox
        uint256 availableBoxes;         //to maintain count of how many boxes left in particular mysterybox
        uint256[] openBoxList;          //list of boxes user has opened
        uint256[] claimedBoxList;      //list of treasury boxes which user has get
        uint256 startTime;
        uint256 endTime;
        uint256[] poolItems; 
    }

    struct Items{
        uint256 itemId;                 //unique id represent each item
        uint256 mysteryboxId;
        bool isERC20;                //itemtype is ERC20 or not
        bool isERC721;              //itemtype is ERC721 or not
        bool isAirdrop;
        string itemName;                //name of particular item
        uint256 itemAmountERC20;                 //actual ERC20 token offering in item
        uint256 itemValue;                 //item value which we get by offer particular item to user
        uint256 count;                  //total items available in pool
        IERC20 tokenAddERC20;
        IERC721 tokenAddERC721;
        uint256[] NFTIdarr;
        uint256 NFTIdclaimedcounter;
        address[] airDropUserArray;

    }

    struct Box{
        uint256 boxid;              //unique id for box 
        address userAddress;        //user address which shows the particular user who has opened that box
        uint256 mysteryBoxId;       //to map with particular mysterybox 
        uint256 offereditemId;                //item offered to that particular box
        string offereditemName;
        uint256 startTimestamp;     //timestamp when that particular box is allocated
        uint256 endTimestamp;       //timestamp when the duration of claiming this box is over
        bool isclaimed;             //to check that opened box is claimed by user or not
        bool boxDiscardedFrompool;
    }

    mapping (uint256 => Items) public ItemList;

    mapping (uint256 => MysteryBox) public mysteryBoxes;

    mapping (uint256 => Box) public boxes;

    address public holdWallet;
    
    function setHoldingadd(address _holdWallet) external onlyOwner{
        holdWallet = _holdWallet;
    }

    IERC20 public USDC;
    function setPaymentToken(address _tokencontract) external onlyOwner{
        USDC=IERC20(_tokencontract);
    }

    address public stakePoolAddr;

    function setstakepool(address _stakepooladdr) external onlyOwner{
        stakePoolAddr= _stakepooladdr;
    }
    
    event createMysteryBox(string mysteryBoxName,
    uint256 mysteryBoxId,
    uint256 startTime,
    uint256 endTime);

    event setitem(uint256 mysteryboxId, uint256 itemId,string itemName);
    event openBox(uint256 mysteryboxId,uint256 boxid,address userAddress);
    event claimBox(uint256 mysteryboxId,uint256 boxid,address userAddress);

    function createmysterybox(string memory _mysteryBoxName,
    uint256 _boxclaimTime,
    uint256 _startTime,
    uint256 _endTime) 
    external onlyOwner returns(uint256)
    {
        mysteryboxCounter++;
        emit createMysteryBox(_mysteryBoxName,mysteryboxCounter,_startTime,_endTime);
        mysteryBoxes[mysteryboxCounter].mysteryBoxId = mysteryboxCounter;
        mysteryBoxes[mysteryboxCounter].Name = _mysteryBoxName;
        mysteryBoxes[mysteryboxCounter].claimTime = _boxclaimTime;
        mysteryBoxes[mysteryboxCounter].startTime = _startTime;
        mysteryBoxes[mysteryboxCounter].endTime = _endTime;
        return mysteryboxCounter;
    }

    function setItem(
        uint256 _mysteryid,
        string[] memory _itemName,
        bool[] memory _itemisERC20,
        bool[] memory _itemisERC721,
        bool[] memory _isAirdrop, 
        uint256[] memory _itemAmount,
        uint256[] memory _itemValue,
        uint256[] memory _itemCount,
        IERC20[] memory _tokenaddERC20,
        IERC721[] memory _tokenAddERC721,
        uint256[][] memory _NFTtokenArr)
     
     external onlyOwner {
        require(mysteryBoxes[_mysteryid].startTime>block.timestamp,"you can not enter value after start time");
        uint256 i;
        for(i=0;i<_itemName.length;i++){
            ItemList[itemcounter].mysteryboxId = _mysteryid;
            ItemList[itemcounter].itemId = itemcounter;
            ItemList[itemcounter].isERC20 = _itemisERC20[i];
            ItemList[itemcounter].isERC721 = _itemisERC721[i];
            ItemList[itemcounter].isAirdrop = _isAirdrop[i];
            ItemList[itemcounter].itemName = _itemName[i];
            ItemList[itemcounter].itemAmountERC20 = _itemAmount[i];
            ItemList[itemcounter].count = _itemCount[i];
            ItemList[itemcounter].itemValue = _itemValue[i];
            ItemList[itemcounter].tokenAddERC20 = _tokenaddERC20[i];
            ItemList[itemcounter].tokenAddERC721 = _tokenAddERC721[i];
            ItemList[itemcounter].NFTIdarr = _NFTtokenArr[i];
            emit setitem(_mysteryid,itemcounter,_itemName[i]);
            mysteryBoxes[_mysteryid].itemArr.push(itemcounter);
            mysteryBoxes[_mysteryid].poolItems.push(itemcounter);
            mysteryBoxes[_mysteryid].itemCount += 1;
            mysteryBoxes[_mysteryid].totalTreasureBoxes =mysteryBoxes[_mysteryid].totalTreasureBoxes + _itemCount[i];
            mysteryBoxes[_mysteryid].availableBoxes =mysteryBoxes[_mysteryid].availableBoxes + _itemCount[i];
            itemcounter++;        
        }

    }
    
    function buyTreasurybox(uint256 _mysteryBoxId) external returns (uint256) {    
        address _addr =msg.sender;
        require(msg.sender == tx.origin,"address is not wallet address");         //audit 1 issue
        require(mysteryBoxes[_mysteryBoxId].startTime<block.timestamp,"mysterybox is not started yet");
        require(mysteryBoxes[_mysteryBoxId].endTime>block.timestamp,"mysterybox is ended");
        require(totalticket(_addr) > (UsersBoxes[msg.sender][_mysteryBoxId]).length,"user is not having enough ticket");
        if(mysteryBoxes[_mysteryBoxId].availableBoxes==0 && 
        (mysteryBoxes[_mysteryBoxId].claimedBoxList.length != mysteryBoxes[_mysteryBoxId].totalTreasureBoxes))
        {
            isBoxClaimed(_mysteryBoxId);
        }       
        require( mysteryBoxes[_mysteryBoxId].availableBoxes > 0,"boxes not available");
        require(mysteryBoxes[_mysteryBoxId].claimedBoxList.length != mysteryBoxes[_mysteryBoxId].totalTreasureBoxes, "all boxes are claimed" );
        
        
        boxesCounter++;
        uint256 _item = randomItem(_mysteryBoxId);
        boxes[boxesCounter].boxid = boxesCounter;
        boxes[boxesCounter].mysteryBoxId = _mysteryBoxId;
        boxes[boxesCounter].offereditemId = _item;
        boxes[boxesCounter].offereditemName = ItemList[_item].itemName;
        boxes[boxesCounter].userAddress = msg.sender;
        boxes[boxesCounter].startTimestamp = block.timestamp;
        boxes[boxesCounter].endTimestamp = block.timestamp + mysteryBoxes[_mysteryBoxId].claimTime ;
        mysteryBoxes[_mysteryBoxId].openBoxList.push(boxesCounter);
        mysteryBoxes[_mysteryBoxId].availableBoxes =  mysteryBoxes[_mysteryBoxId].availableBoxes - 1;
        ItemList[_item].count = ItemList[_item].count - 1;
        UsersBoxes[msg.sender][_mysteryBoxId].push(boxesCounter);
        emit openBox(_mysteryBoxId,boxesCounter,msg.sender);
        return boxesCounter;
        
     }


    function claimTreasuryBox(uint256 _boxId) external{        
        require(boxes[_boxId].userAddress == msg.sender,"you are not owner of this box");
        require(boxes[_boxId].endTimestamp > block.timestamp,"claiming time is over");
        require(boxes[_boxId].isclaimed == false,"box is already claimed");
        uint256 _itemTemp = boxes[_boxId].offereditemId;
        uint256 counter;

        if(ItemList[_itemTemp].isAirdrop){
            
            ItemList[_itemTemp].airDropUserArray.push(msg.sender);
            boxes[_boxId].isclaimed = true;
            mysteryBoxes[boxes[_boxId].mysteryBoxId].claimedBoxList.push(_boxId);
        }
        else
        {
            if(ItemList[_itemTemp].itemValue == 0){
                
                if(ItemList[_itemTemp].isERC20 && ItemList[_itemTemp].isERC721){
                    IERC20(ItemList[_itemTemp].tokenAddERC20).transferFrom(holdWallet,msg.sender,(ItemList[_itemTemp].itemAmountERC20)* 1e18);
                    counter = ItemList[_itemTemp].NFTIdclaimedcounter;
                    IERC721(ItemList[_itemTemp].tokenAddERC721).safeTransferFrom(holdWallet,msg.sender,ItemList[_itemTemp].NFTIdarr[counter]);
                    ItemList[_itemTemp].NFTIdclaimedcounter = counter++;
                    boxes[_boxId].isclaimed = true;
                    mysteryBoxes[boxes[_boxId].mysteryBoxId].claimedBoxList.push(_boxId);
                }
                else{
                    if(ItemList[_itemTemp].isERC20){
                        IERC20(ItemList[_itemTemp].tokenAddERC20).transferFrom(holdWallet,msg.sender,(ItemList[_itemTemp].itemAmountERC20)* 1e18);
                        boxes[_boxId].isclaimed = true;
                        mysteryBoxes[boxes[_boxId].mysteryBoxId].claimedBoxList.push(_boxId);
                        
                    }
                    else{
                        counter = ItemList[_itemTemp].NFTIdclaimedcounter;
                        IERC721(ItemList[_itemTemp].tokenAddERC721).safeTransferFrom(holdWallet,msg.sender,ItemList[_itemTemp].NFTIdarr[counter]);
                        ItemList[_itemTemp].NFTIdclaimedcounter = counter++;
                        boxes[_boxId].isclaimed = true;
                        mysteryBoxes[boxes[_boxId].mysteryBoxId].claimedBoxList.push(_boxId);  
                    }
                }

            }
            else{

                if(ItemList[_itemTemp].isERC20 && ItemList[_itemTemp].isERC721){

                    IERC20(USDC).transferFrom(msg.sender,holdWallet,(ItemList[_itemTemp].itemValue)* 1e6);
                    IERC20(ItemList[_itemTemp].tokenAddERC20).transferFrom(holdWallet,msg.sender,(ItemList[_itemTemp].itemAmountERC20)* 1e18);
                    counter = ItemList[_itemTemp].NFTIdclaimedcounter;
                    IERC721(ItemList[_itemTemp].tokenAddERC721).safeTransferFrom(holdWallet,msg.sender,ItemList[_itemTemp].NFTIdarr[counter]);
                    ItemList[_itemTemp].NFTIdclaimedcounter = counter++;
                    boxes[_boxId].isclaimed = true;
                    mysteryBoxes[boxes[_boxId].mysteryBoxId].claimedBoxList.push(_boxId);
                }
                else{
                    if(ItemList[_itemTemp].isERC20){

                        IERC20(USDC).transferFrom(msg.sender,holdWallet,(ItemList[_itemTemp].itemValue)* 1e6);
                        IERC20(ItemList[_itemTemp].tokenAddERC20).transferFrom(holdWallet,msg.sender,(ItemList[_itemTemp].itemAmountERC20)* 1e18);
                        boxes[_boxId].isclaimed = true;
                        mysteryBoxes[boxes[_boxId].mysteryBoxId].claimedBoxList.push(_boxId);
                        
                    }
                    else{
                        IERC20(USDC).transferFrom(msg.sender,holdWallet,(ItemList[_itemTemp].itemValue)* 1e6);
                        counter = ItemList[_itemTemp].NFTIdclaimedcounter;
                        IERC721(ItemList[_itemTemp].tokenAddERC721).safeTransferFrom(holdWallet,msg.sender,ItemList[_itemTemp].NFTIdarr[counter]);
                        ItemList[_itemTemp].NFTIdclaimedcounter = counter++;
                        boxes[_boxId].isclaimed = true;
                        mysteryBoxes[boxes[_boxId].mysteryBoxId].claimedBoxList.push(_boxId);  
                    }
                }

            }
        }

        emit claimBox(boxes[_boxId].mysteryBoxId,_boxId,msg.sender);
    }

    function isBoxClaimed(uint256 _mysteryBoxId) private{
        uint256 i;
        for(i=0;i<mysteryBoxes[_mysteryBoxId].openBoxList.length;i++){
            uint256 _boxId =mysteryBoxes[_mysteryBoxId].openBoxList[i];
            if(boxes[_boxId].boxDiscardedFrompool == false && boxes[_boxId].isclaimed==false){
                if( boxes[_boxId].endTimestamp<block.timestamp){
                    mysteryBoxes[boxes[_boxId].mysteryBoxId].availableBoxes = mysteryBoxes[boxes[_boxId].mysteryBoxId].availableBoxes + 1;
                    if(ItemList[boxes[_boxId].offereditemId].count == 0){
                        mysteryBoxes[_mysteryBoxId].poolItems.push(boxes[_boxId].offereditemId);
                    }
                    ItemList[boxes[_boxId].offereditemId].count = ItemList[boxes[_boxId].offereditemId].count + 1;
                    boxes[_boxId].boxDiscardedFrompool = true; 
                }
            }
        }    
    }

    function randomItem(uint256 _mysteryBoxId) internal returns(uint256){
        bool itemAvailable = false;
        uint256 randomNum;
        uint256 availableItemCount;
        uint256 itemOffer;
        do{
            availableItemCount = mysteryBoxes[_mysteryBoxId].poolItems.length;
            randomNum = (uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty))) + randomNumcounter) % availableItemCount;
            itemOffer = mysteryBoxes[_mysteryBoxId].poolItems[randomNum];
            if( ItemList[itemOffer].count > 0)
            {
                itemAvailable = true;
                return itemOffer;
            }
            if(ItemList[itemOffer].count == 0){
                mysteryBoxes[_mysteryBoxId].poolItems[randomNum] = mysteryBoxes[_mysteryBoxId].poolItems[availableItemCount - 1];
                mysteryBoxes[_mysteryBoxId].poolItems.pop();
            }
        }while(itemAvailable == false);
        randomNumcounter++;
    }

    function allItems(uint256 _mysteryid) external view returns (uint256[] memory){
            return mysteryBoxes[_mysteryid].itemArr;
    }

    function openBoxCount(uint256 _mysteryid) external view returns (uint256){
            return mysteryBoxes[_mysteryid].openBoxList.length;
    }

    function claimBoxCount(uint256 _mysteryid) external view returns (uint256){
            return mysteryBoxes[_mysteryid].claimedBoxList.length;
    }

    function airdropList(uint256 itemID) external onlyOwner view returns (address[] memory){
        require(ItemList[itemID].isAirdrop,"this item is not airdrop");
        return ItemList[itemID].airDropUserArray;
    }

    function totalticket(address _address) public view returns(uint256){
        return stakePool(stakePoolAddr).totalTicket(_address);
    }

    function UserTreasuryBoxes(address _address, uint256 _mystryId) external view returns(uint256[] memory){
        return UsersBoxes[_address][_mystryId];
    }
    
}