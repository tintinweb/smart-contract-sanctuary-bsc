//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";
import "./IERC20.sol";

interface IListingManager {
    function canTrade(address token) external view returns (bool);
    function getFeeAndRecipient(address token) external view returns (uint256, address);
    function addOrder(uint256 orderID, address token) external;
    function fulfilledOrder(address token, uint256 amount) external;
}

contract OTC is Ownable {

    /**
        Constants
     */
    uint256 public constant FEE_DENOMINATOR = 10**5;

    /**
        Listing Manager
     */
    IListingManager public ListingManager;

    /**
        An OTC Order
     */
    struct Order {
        bool hasBeenFulfilled;
        bool hasBeenCancelled;
        address initiator;
        address sellToken;
        address buyToken;
        uint256 initialSellTokenAmount;
        uint256 initialBuyTokenAmount;
        uint256 sellTokenAmount;
        uint256 buyTokenAmount;
        uint256 expiration;
        uint256 index;
    }

    /**
        Mapping From OrderID => Order
     */
    mapping ( uint256 => Order ) public orders;

    /**
        List Of Orders By Type
     */
    uint256[] public activeOrders;
    uint256[] public fulfilledOrders;
    uint256[] public cancelledOrders;

    /**
        Current Order Nonce
     */
    uint256 public orderNonce;

    /**
        User History
     */
    struct UserHistory {
        uint256[] userCreatedOrders;
        uint256[] userFulfilledOrders;
        uint256[] amountFulfilledInOrders;
    }

    /**
        Mapping From User => userHistory
     */
    mapping ( address => UserHistory ) private userHistory;

    /** 
        Fee For Tokens Being Transferred
     */
    uint256 public tradeFee;

    /**
        Trading Fee Recipient
     */
    address public tradingFeeRecipient;

    /**
        Initialize Initial Values And Listed Tokens
     */
    constructor(
        uint256 tradeFee_,
        address tradingFeeRecipient_
    ) {
        tradeFee = tradeFee_;
        tradingFeeRecipient = tradingFeeRecipient_;
    }


    ///////////////////////////////////////////
    ////////     OWNER FUNCTIONS      /////////
    ///////////////////////////////////////////

    function setListingManager(address newManager) external onlyOwner {
        ListingManager = IListingManager(newManager);
    }

    function setTradingFeeRecipient(address newRecipient) external onlyOwner {
        require(
            newRecipient != address(0),
            'Zero Address'
        );
        tradingFeeRecipient = newRecipient;
    }

    function setTradingFee(uint256 newTradeFee) external onlyOwner {
        require(
            newTradeFee <= FEE_DENOMINATOR / 25,
            'Trade Fee Too High'
        );

        tradeFee = newTradeFee;
    }

    function withdraw() external onlyOwner {
        _send(msg.sender, address(this).balance);
    }

    function withdrawToken(address token, address recipient) external onlyOwner {
        IERC20(token).transfer(recipient, IERC20(token).balanceOf(address(this)));
    }


    ///////////////////////////////////////////
    ////////     PUBLIC FUNCTIONS     /////////
    ///////////////////////////////////////////


    function createOrder(
        address saleToken,
        uint256 saleTokenAmount,
        address buyToken,
        uint256 buyTokenAmount,
        uint256 expiration
    ) external {
        require(
            expiration > block.timestamp,
            'CG: Order Expired'
        );
        require(
            ListingManager.canTrade(saleToken),
            'CG: Invalid Sale Token'
        );
        require(
            ListingManager.canTrade(buyToken),
            'CG: Invalid Buy Token'
        );
        require(
            saleTokenAmount > 0,
            'Zero Sale Amount'
        );
        require(
            buyTokenAmount > 0,
            'Zero Buy Amount'
        );
        require(
            saleToken != buyToken,
            'Buy Token Equals Sell Token'
        );
        require(
            saleToken != address(0),
            'Cannot Create ETH Sell Order'
        );
        require(
            userHasAllowance(saleToken, msg.sender, saleTokenAmount),
            'Allowance Not Given'
        );
        require(
            userHasTokenBalance(saleToken, msg.sender, saleTokenAmount),
            'Insufficient User Balance'
        );

        // Set Order State
        orders[orderNonce] = Order({
            hasBeenFulfilled: false,
            hasBeenCancelled: false,
            initiator: msg.sender,
            sellToken: saleToken,
            buyToken: buyToken,
            initialSellTokenAmount: saleTokenAmount,
            initialBuyTokenAmount: buyTokenAmount,
            sellTokenAmount: saleTokenAmount,
            buyTokenAmount: buyTokenAmount,
            expiration: expiration,
            index: activeOrders.length
        });

        // Add To All Orders List
        userHistory[msg.sender].userCreatedOrders.push(orderNonce);

        // Add To Active Orders List
        activeOrders.push(orderNonce);

        // Add Orders To Token
        ListingManager.addOrder(orderNonce, saleToken);
        ListingManager.addOrder(orderNonce, buyToken);

        // Increment Order Nonce
        orderNonce++;
    }


    function fulfilOrder(
        uint256 orderID,
        uint256 amount
    ) external {
        require(
            isActive(orderID),
            'Order Not Active'
        );
        require(
            orders[orderID].buyToken != address(0),
            'Not ETH Order'
        );
        require(
            userHasAllowance(orders[orderID].buyToken, msg.sender, amount),
            'Buyer Allowance Not Given'
        );
        require(
            amount > 0,
            'Zero Amount'
        );

        // fulfill order
        _fulfill(orderID, amount);
    }

    function fulfilOrderETH(
        uint256 orderID
    ) external payable {
        require(
            isActive(orderID),
            'Order Not Active'
        );
        require(
            orders[orderID].buyToken == address(0),
            'ETH Order'
        );
        require(
            msg.value > 0,
            'Zero Amount'
        );

        // fulfill order
        _fulfill(orderID, msg.value);
    }

    function cancelOrder(
        uint256 orderID
    ) external {
        require(
            orders[orderID].initiator == msg.sender,
            'Only Initiator Can Cancel'
        );
        require(
            orders[orderID].hasBeenCancelled == false && orders[orderID].hasBeenFulfilled == false,
            'Order Already Cancelled Or Fulfilled'
        );

        // cancel order
        _moveToCancelled(orderID);
    }



    ///////////////////////////////////////////
    ////////    INTERNAL FUNCTIONS    /////////
    ///////////////////////////////////////////



    function _transferFrom(address token, address from, address to, uint256 amount) internal {
        uint before = IERC20(token).balanceOf(to);
        require(
            IERC20(token).transferFrom(
                from, to, amount
            ),
            'Failure Transfer From'
        );
        uint After = IERC20(token).balanceOf(to);
        require(
            After > before,
            'Zero Sent'
        );
    }

    function _send(address to, uint256 amount) internal {
        if (to == address(this) || to == address(0)) {
            return;
        }
        (bool s,) = payable(to).call{value: amount, gas: 2300}("");
        require(s, 'ETH Transfer Failure');
    }

    function _fulfill(uint256 orderID, uint256 amount) internal {

        // order state
        (
        address initiator,
        address sellToken,
        address buyToken,
        uint256 sellAmount,
        uint256 buyAmount,
        ) = fetchOrderDetails(orderID);
        
        // update amount if greater than buy amount
        if (amount >= buyAmount) {
            amount = buyAmount;
            _moveToFulfilled(orderID);
        }

        // add to orders user has fulfilled or partially fulfilled
        userHistory[msg.sender].userFulfilledOrders.push(orderID);
        userHistory[msg.sender].amountFulfilledInOrders.push(amount);

        // amount of sellToken to send
        uint256 sellTokenSendAmount = ( sellAmount * amount ) / buyAmount;

        // add order amount to listing manager
        ListingManager.fulfilledOrder(buyToken, amount);
        ListingManager.fulfilledOrder(sellToken, sellTokenSendAmount);

        // fulfill order data
        orders[orderID].sellTokenAmount -= sellTokenSendAmount;
        orders[orderID].buyTokenAmount -= amount;

        // Handle Token Transaction Fees
        amount = amount - _handleTokenFee(buyToken, msg.sender, amount);
        sellTokenSendAmount = sellTokenSendAmount - _handleTokenFee(sellToken, initiator, sellTokenSendAmount);

        // Handle Platform Trading Fee
        amount = amount - _handleTradingFee(buyToken, msg.sender, amount);

        // send tokens from seller to buyer
        _transferFrom(sellToken, initiator, msg.sender, sellTokenSendAmount);

        // send buyer tokens from buyer to seller
        buyToken == address(0) ? _send(initiator, amount) : _transferFrom(buyToken, msg.sender, initiator, amount);
    }

    function _handleTokenFee(
        address token,
        address from,
        uint256 transferAmount
    ) internal returns (uint256 fee) {

        // fetch the transaction fee and recipient from Listing Manager
        (uint256 transactionFee, address transactionFeeRecipient) = ListingManager.getFeeAndRecipient(token);

        // If Fee Is Present, Take Fee
        if (transactionFee > 0) {
            address recipient = transactionFeeRecipient == address(0) ? address(this) : transactionFeeRecipient;
            fee = ( transferAmount * transactionFee ) / FEE_DENOMINATOR;
            token == address(0) ? _send(recipient, fee) : _transferFrom(token, from, recipient, fee);
        }
    }

    function _handleTradingFee(
        address token,
        address from,
        uint256 transferAmount
    ) internal returns (uint256 fee) {

        // if tradeFee is greater than zero, take fee
        if (tradeFee > 0) {
            address recipient = tradingFeeRecipient == address(0) ? address(this) : tradingFeeRecipient;
            fee = ( transferAmount * tradeFee ) / FEE_DENOMINATOR;
            token == address(0) ? _send(recipient, fee) : _transferFrom(token, from, recipient, fee);
        }

    }

    function _moveToFulfilled(uint256 orderID) internal {

        // save state to make code more readable
        uint256 lastListing = activeOrders[activeOrders.length - 1];
        uint256 rmIndex = orders[orderID].index;

        // move element in token array
        activeOrders[rmIndex] = lastListing;
        orders[lastListing].index = rmIndex;
        activeOrders.pop();

        // add to fulfilled orders
        orders[orderID].index = fulfilledOrders.length;
        fulfilledOrders.push(orderID);
        orders[orderID].hasBeenFulfilled = true;
    }

    function _moveToCancelled(uint256 orderID) internal {
        
        // save state to make code more readable
        uint256 lastListing = activeOrders[activeOrders.length - 1];
        uint256 rmIndex = orders[orderID].index;

        // move element in token array
        activeOrders[rmIndex] = lastListing;
        orders[lastListing].index = rmIndex;
        activeOrders.pop();

        // add to fulfilled orders
        orders[orderID].index = cancelledOrders.length;
        cancelledOrders.push(orderID);
        orders[orderID].hasBeenCancelled = true;
    }



    ///////////////////////////////////////////
    ////////      READ FUNCTIONS      /////////
    ///////////////////////////////////////////


    function isActive(uint256 orderId) public view returns (bool) {
        return
            hasAllowance(orderId) && 
            ownsBalance(orderId) &&
            orders[orderId].hasBeenCancelled == false &&
            orders[orderId].hasBeenFulfilled == false &&
            orders[orderId].expiration >= block.timestamp;
    }

    function hasAllowance(uint256 orderId) public view returns (bool) {
        return orderId < orderNonce ? 
            userHasAllowance(orders[orderId].sellToken, orders[orderId].initiator, orders[orderId].sellTokenAmount) :
            false;
    }

    function userHasAllowance(address token, address user, uint256 amount) public view returns (bool) {
        return fetchAllowance(token, user) >= amount;
    }

    function ownsBalance(uint256 orderId) public view returns (bool) {
        return userHasTokenBalance(orders[orderId].sellToken, orders[orderId].initiator, orders[orderId].sellTokenAmount);
    }

    function userHasTokenBalance(address token, address user, uint256 amount) public view returns (bool) {
        return fetchBalance(token, user) >= amount;
    }

    function fetchAllowance(address token, address user) public view returns (uint256) {
        return IERC20(token).allowance(user, address(this));
    }

    function fetchBalance(address token, address user) public view returns (uint256) {
        return IERC20(token).balanceOf(user);
    }

    function batchOrderStatus(uint256[] calldata orderIDs) public view returns (
        bool[] memory, // isActive
        bool[] memory, // is fulfilled
        bool[] memory  // is cancelled
    ) {

        uint len = orderIDs.length;

        bool[] memory active = new bool[](len);
        bool[] memory fulfilled = new bool[](len);
        bool[] memory cancelled = new bool[](len);

        for (uint i = 0; i < len;) {
            
            active[i] = isActive(orderIDs[i]);
            fulfilled[i] = orders[orderIDs[i]].hasBeenFulfilled;
            cancelled[i] = orders[orderIDs[i]].hasBeenCancelled;

            unchecked { ++i; }
        }
        return (active, fulfilled, cancelled);
    }

    function batchFetchOrderDetails(uint256[] calldata orderIDs) public view returns (
        address[] memory,
        address[] memory,
        uint256[] memory,
        uint256[] memory,
        bool[] memory
    ) {

        uint len = orderIDs.length;

        address[] memory sellTokens = new address[](len);
        address[] memory buyTokens = new address[](len);
        uint256[] memory sellAmounts = new uint256[](len);
        uint256[] memory buyAmounts = new uint256[](len);
        bool[] memory isActiveOrders = new bool[](len);

        for (uint i = 0; i < len;) {
            (
                ,
                sellTokens[i],
                buyTokens[i],
                sellAmounts[i],
                buyAmounts[i],
                isActiveOrders[i]
            ) = fetchOrderDetails(orderIDs[i]);
            unchecked { ++i; }
        }
        return (sellTokens, buyTokens, sellAmounts, buyAmounts, isActiveOrders);
    }

    function iterativelyFetchOrderDetails(uint256 orderIDStart, uint256 orderIDEnd) public view returns (
        address[] memory,
        address[] memory,
        uint256[] memory,
        uint256[] memory,
        bool[] memory
    ) {

        uint len = orderIDEnd - orderIDStart;

        address[] memory sellTokens = new address[](len);
        address[] memory buyTokens = new address[](len);
        uint256[] memory sellAmounts = new uint256[](len);
        uint256[] memory buyAmounts = new uint256[](len);
        bool[] memory isActiveOrders = new bool[](len);

        uint count = 0;

        for (uint i = orderIDStart; i < orderIDEnd;) {
            (
                ,
                sellTokens[count],
                buyTokens[count],
                sellAmounts[count],
                buyAmounts[count],
                isActiveOrders[count]
            ) = fetchOrderDetails(i);
            unchecked { ++i; ++count; }
        }
        return (sellTokens, buyTokens, sellAmounts, buyAmounts, isActiveOrders);
    }

    function fetchOrderDetails(uint256 orderID) public view returns (
        address initiator,
        address sellToken,
        address buyToken,
        uint256 sellAmount,
        uint256 buyAmount,
        bool isActiveOrder
    ) {
        initiator  = orders[orderID].initiator;
        sellToken  = orders[orderID].sellToken;
        buyToken   = orders[orderID].buyToken;
        sellAmount = orders[orderID].sellTokenAmount;
        buyAmount  = orders[orderID].buyTokenAmount;
        isActiveOrder = isActive(orderID);
    }

    function fetchAllActiveOrders() external view returns (uint256[] memory) {
        return activeOrders;
    }
    function fetchAllFulfilledOrders() external view returns (uint256[] memory) {
        return fulfilledOrders;
    }
    function fetchAllCancelledOrders() external view returns (uint256[] memory) {
        return cancelledOrders;
    }

    function fetchAllOrdersMadeByUser(address user) external view returns (uint256[] memory) {
        return userHistory[user].userCreatedOrders;
    }
    function fetchAllFulfilledOrdersForUser(address user) external view returns (uint256[] memory) {
        return userHistory[user].userFulfilledOrders;
    }
    function fetchAmountsOfFulfilledOrdersForUser(address user) external view returns (uint256[] memory) {
        return userHistory[user].amountFulfilledInOrders;
    }

    function fetchFulfilledOrdersAndAmountsForUser(address user) external view returns (uint256[] memory, uint256[] memory) {
        return (userHistory[user].userFulfilledOrders, userHistory[user].amountFulfilledInOrders);
    }

    function fetchUserHistory(address user) external view returns (uint256[] memory, uint256[] memory, uint256[] memory) {
        return (userHistory[user].userCreatedOrders, userHistory[user].userFulfilledOrders, userHistory[user].amountFulfilledInOrders);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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