/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


interface IEscrowGig{
    function seller() external view returns (address);
}

contract EscrowGig is Ownable, ReentrancyGuard {

	address public administrator; 
    IERC20 public BUSD;
    EscrowFactory private factoryInternal;
    uint256 public currentGigId;

    address public seller; 
    uint256 public price;
    uint256 public currentOrder = 0;
    string public title;
    string public category;
    string public description;
    string public ipfs; 
    mapping(address => string) public reviews;
    mapping(address => uint256) public reviewRating;
    bool public listingValid = true;
    bool public unlisted = false;

    struct Order{
        address buyer;
        uint256 timeOfOrder;
        bool approvedPayment;
        uint256 remainderPayment;
        bool paidDeposit;
    }

    constructor(IERC20 _busd, EscrowFactory _factory, uint256 _price, string memory _title, string memory _category, string memory _ipfs, string memory _description) {
        administrator = _factory.owner();
        BUSD = _busd;
        factoryInternal = _factory;
        seller = tx.origin;
        price = _price; 
        title = _title; 
        category = _category;
        ipfs = _ipfs;
        description = _description;
    }

    modifier onlyAdmins() {
        require(factoryInternal.owner() == msg.sender, "Admins: caller is not in list of Admins");
        _;
    }


    function listDelistItem() public onlyAdmins{
        unlisted = !unlisted;
    }

    mapping(uint256 => Order) public orders;
    mapping(address => bool) public activeOrders;
    mapping(address => uint256) public orderId;

    uint256[] public ordersReviewedList;

    function getOrderInfo(uint256 _id) public view returns(Order memory){
        return orders[_id];
    }

    function enableDisabled(bool _status) public {
        require(msg.sender == seller, 'invalid');
        listingValid = _status;
    }

    function requireService() nonReentrant public {
        require(listingValid == true, 'listing is disabled');
        require(factoryInternal.profileCreation(msg.sender) == true, 'you must create a profile before buying');
        require(msg.sender != seller, 'you cannot buy from yourself');
        require(activeOrders[msg.sender] == false,'you have an active order already');
        // create escrow order
        // LOGIC => transfer busd amount to contract
        // increase purchase time 
        // set an order list with buyer, timeOfOrder and approvedPayment status (approved payment used to track finalized orders)
        BUSD.transferFrom(msg.sender, address(this), price);
        activeOrders[msg.sender] = true;
        orders[currentOrder].buyer = msg.sender;
        orders[currentOrder].timeOfOrder = block.timestamp;
        orders[currentOrder].remainderPayment = price; 
        orderId[msg.sender] = currentOrder;
        currentOrder = currentOrder + 1;
        
    }
    
    function releaseAmountEarly(uint256 _amount) nonReentrant public {
        require(activeOrders[msg.sender] == true, 'you do not have an active order');
        require(_amount > 0 && _amount <=50, 'too large payment');
        uint256 orderIdLocal = orderId[msg.sender];
        require(orders[orderIdLocal].paidDeposit == false, 'you have already released a deposit');
        uint256 amountToReleaseTotal = orders[orderIdLocal].remainderPayment;
        uint256 toRelease = amountToReleaseTotal*_amount/100; 
        orders[orderIdLocal].remainderPayment = amountToReleaseTotal-toRelease;
        orders[orderIdLocal].paidDeposit = true;
        BUSD.transfer(seller, toRelease);
    }

    // finalize delivery
    function satisfyRequest(string memory _review, uint256 _rating) nonReentrant public {
        require(_rating <= 5, 'invalid rating');
        require(activeOrders[msg.sender] == true, 'you do not have an active order');
        uint256 orderIdLocal = orderId[msg.sender];
        uint256 amountRemaining = orders[orderIdLocal].remainderPayment; 
        orders[orderIdLocal].remainderPayment = 0;
        activeOrders[msg.sender] = false;
        BUSD.transfer(seller, amountRemaining);
        reviews[msg.sender] = _review;
        reviewRating[msg.sender] = _rating;
        ordersReviewedList.push(orderIdLocal);
    }

    // id of item
    // decision can be '0' to refund or '1' to pay
    function adminFinalize(uint256 _id, uint256 _decision) public onlyAdmins{
        Order memory isOrderActive = orders[_id];
        require(isOrderActive.remainderPayment > 0, 'trade already settled');
        require(activeOrders[isOrderActive.buyer] == true, 'not an active order');
        require(_decision == 1 || _decision == 0, 'invalid decision');
        if(_decision == 0){
            // refund whatever is left here 
            orders[_id].remainderPayment = 0;
            activeOrders[isOrderActive.buyer] = false;
            BUSD.transfer(isOrderActive.buyer, isOrderActive.remainderPayment);
        } else {
            orders[_id].remainderPayment = 0;
            activeOrders[isOrderActive.buyer] = false;
            BUSD.transfer(seller, isOrderActive.remainderPayment);
        }
    }


}



contract EscrowFactory is Ownable, ReentrancyGuard {

    event ServiceCreated(address _address, address _seller);

    struct User{
        string avatar;
        string name;
        string email;
        string telegram;
        string website;
        string twitter;
    }

    mapping(address => User) public userInfo; 
    mapping(address => bool) public profileCreation; 
    mapping(address => uint256) public tier2; 
    mapping(address => uint256) public tier3; 
    mapping(address => address[]) public escrowsByUser;
    mapping(address => address[]) public viewList; 

    address[] public allEscrows;
    mapping(uint256 => address) public escrowAddress;
    uint256 public currentGigId;
    uint256 public weeklyPrice1 = 20000000000000000000;
    uint256 public weeklyPrice2 = 35000000000000000000;
    uint256 public creationPrice = 5000000000000000000;
    uint256 public ownerViewReceive = 8000000000000000000;
    uint256 public sellerViewReceive = 2000000000000000000;


    function getMyIdsWithPagination(uint256 cursor, uint256 howMany) public view returns(address[] memory values, uint256 newCursor){
        uint256 length = howMany;
        if (length > allEscrows.length - cursor) {
            length = allEscrows.length - cursor;
        }

        values = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = allEscrows[cursor + i];
        }
        return (values, cursor + length);
    }

    IERC20 private BUSD;

    constructor(IERC20 _busd) {
        BUSD = _busd;
    }

    function updateOwnerViewReceive(uint256 _newAmount) onlyOwner public {
        ownerViewReceive = _newAmount;
    }

    function updateSellerViewReceive(uint256 _newAmount) onlyOwner public {
        sellerViewReceive = _newAmount;
    }

    function updateWeeklyPrice1(uint256 _amount) onlyOwner public {
        weeklyPrice1 = _amount;
    }

    function updateWeeklyPrice2(uint256 _amount) onlyOwner public {
        weeklyPrice2 = _amount;
    }

    function updateCreationPrice(uint256 _amount) onlyOwner public {
        creationPrice = _amount;
    }

    function getAllEscrows() public view returns (address[] memory){
        return allEscrows;
    }

    function setName(string memory _name) public {
        require(profileCreation[msg.sender] == true, 'you must purchase profile creation for 5 busd');
        userInfo[msg.sender].name = _name;
    }
    function setAvatar(string memory _avatar) public {
        require(profileCreation[msg.sender] == true, 'you must purchase profile creation for 5 busd');
        userInfo[msg.sender].avatar = _avatar;
    }
    function setWebsite(string memory _website) public {
        require(profileCreation[msg.sender] == true, 'you must purchase profile creation for 5 busd');
        userInfo[msg.sender].website = _website;
    }
    function setEmail(string memory _email) public {
        require(profileCreation[msg.sender] == true, 'you must purchase profile creation for 5 busd');
        userInfo[msg.sender].email = _email;
    }
    function setTelegram(string memory _telegram) public {
        require(profileCreation[msg.sender] == true, 'you must purchase profile creation for 5 busd');
        userInfo[msg.sender].telegram = _telegram;
    }
    function setTwitter(string memory _twitter) public {
        require(profileCreation[msg.sender] == true, 'you must purchase profile creation for 5 busd');
        userInfo[msg.sender].twitter = _twitter;
    }
    function setNameAndAvatar(string memory _avatar, string memory _name) public {
        require(profileCreation[msg.sender] == true, 'you must purchase profile creation for 5 busd');
        userInfo[msg.sender].avatar = _avatar;
        userInfo[msg.sender].name = _name;
    }
    function setAllDetails(string memory _website, string memory _email, string memory _telegram, string memory _twitter, string memory _name, string memory _avatar) public {
        require(profileCreation[msg.sender] == true, 'you must purchase profile creation for 5 busd');
        userInfo[msg.sender].email = _email;
        userInfo[msg.sender].website = _website;
        userInfo[msg.sender].telegram = _telegram;
        userInfo[msg.sender].twitter = _twitter;
        userInfo[msg.sender].avatar = _avatar;
        userInfo[msg.sender].name = _name;

    }

    function purchaseViewList(address _list) public {
        require(profileCreation[msg.sender] == true, 'invalid profile');
        // twenty percent requirement
        address receiver = IEscrowGig(_list).seller();
        BUSD.transferFrom(msg.sender, owner(),  ownerViewReceive);
        BUSD.transferFrom(msg.sender, receiver, sellerViewReceive);
        viewList[msg.sender].push(_list);
    }

    function getAllViewList(address _user) public view returns (address[] memory) {
        return viewList[_user];
    }

    function getUserAvatar(address _user) public view returns(string memory){
        return userInfo[_user].avatar;
    }

    function getUserName(address _user) public view returns(string memory){
        return userInfo[_user].name;
    }

    function getUserNameAndAvatar(address _user) public view returns(User memory)
    {
        return userInfo[_user];
    }

        
    function purchaseProfileCreation() public {
        require(profileCreation[msg.sender] == false, 'you have already purchased');
        BUSD.transferFrom(msg.sender, owner(), creationPrice);
        profileCreation[msg.sender] = true;
    }

    function purchaseTier2(uint256 _weeks) public {
        require(profileCreation[msg.sender] == true, 'you must buy plan 1 first');
        require(_weeks >= 1, 'invalid number of weeks');
        uint256 toTransfer = _weeks * weeklyPrice1;
        uint256 timeStamp = _weeks * 604800;
        BUSD.transferFrom(msg.sender, owner(), toTransfer);
        if(tier2[msg.sender] >= block.timestamp){
            tier2[msg.sender] = tier2[msg.sender] + timeStamp;
        } else {
            tier2[msg.sender] = block.timestamp + timeStamp;
        }
    }

    function purchaseTier2AndProfileCreation(uint256 _weeks) nonReentrant public {
        require(profileCreation[msg.sender] == false, 'you have already purchased basic subscription');
        require(_weeks >= 1, 'invalid number of weeks');
        uint256 toTransfer = _weeks * weeklyPrice1;
        uint256 timeStamp = _weeks * 604800;
        BUSD.transferFrom(msg.sender, owner(), toTransfer+creationPrice);
        if(tier2[msg.sender] >= block.timestamp){
            tier2[msg.sender] = tier2[msg.sender] + timeStamp;
        } else {
            tier2[msg.sender] = block.timestamp + timeStamp;
        }
        profileCreation[msg.sender] = true;
    }

    function purchaseTier3(uint256 _weeks) public {
        require(profileCreation[msg.sender] == true, 'you must buy plan 1 first');
        require(_weeks >= 1, 'invalid number of weeks');
        uint256 toTransfer = _weeks * weeklyPrice2;
        uint256 timeStamp = _weeks * 604800;
        BUSD.transferFrom(msg.sender, owner(), toTransfer);
        if(tier3[msg.sender] >= block.timestamp){
            tier3[msg.sender] = tier3[msg.sender] + timeStamp;
        } else {
            tier3[msg.sender] = block.timestamp + timeStamp;
        }    
    }

    function purchaseTier3AndProfileCreation(uint256 _weeks) public {
        require(profileCreation[msg.sender] == false, 'you have already purchased basic subscription');
        require(_weeks >= 1, 'invalid number of weeks');
        uint256 toTransfer = _weeks * weeklyPrice2;
        uint256 timeStamp = _weeks * 604800;
        BUSD.transferFrom(msg.sender, owner(), toTransfer+creationPrice);
        if(tier3[msg.sender] >= block.timestamp){
            tier3[msg.sender] = tier3[msg.sender] + timeStamp;
        } else {
            tier3[msg.sender] = block.timestamp + timeStamp;
        }    
        profileCreation[msg.sender] = true;
    }

    function checkLatestTier(address _usr) public view returns(uint256){
        uint256 currentTime = block.timestamp;

        if(tier3[_usr] >= currentTime){
            return 3;
        } else {
            if(tier2[_usr] >= currentTime){
                return 2;
            } else {
                if(profileCreation[_usr] == true){
                    return 1;
                } else {
                    return 0;
                }
            }
        }

    }

    function createGig(uint256 _price, string memory _title, string memory _category, string memory _ipfs, string memory _description) public returns(address) {
        require(profileCreation[msg.sender] == true,'you must create a profile first');
        EscrowGig newEscrow = new EscrowGig(BUSD, EscrowFactory(address(this)), _price, _title, _category, _ipfs, _description);
        allEscrows.push(address(newEscrow));
        escrowAddress[currentGigId] = address(newEscrow);
        currentGigId = currentGigId+1;
        escrowsByUser[msg.sender].push(address(newEscrow));
        emit ServiceCreated(address(newEscrow), msg.sender);
        return(address(newEscrow));
    }
}