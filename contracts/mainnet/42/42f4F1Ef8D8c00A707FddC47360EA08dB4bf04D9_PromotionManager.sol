//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";
import "./IERC20.sol";

contract PromotionManager is Ownable {

    /**
        Fee Database
     */
    address public immutable feeDatabase;

    // OTC Contract
    address public OTC;

    // min cost to promote an order
    uint256 public minCost = 5 * 10**16;

    // list of promoted order IDs
    uint256[] public promotedOrderIDs;

    // orderID => index in promoted order array
    mapping ( uint256 => uint256 ) public orderIndex;

    // event to fetch
    event OrderPromoted(
        uint256 orderID,
        uint256 cost
    );

    constructor(address OTC_, address feeDatabase_) {
        OTC = OTC_;
        feeDatabase = feeDatabase_;
    }

    function promoteOrder(uint256 orderID) external payable {
        require(
            msg.value >= minCost,
            'Insufficient Value'
        );

        if (isPromotedOrder(orderID)) {
            // remove existing order from array
            _removeOrder(orderID);
        }

        // add to list of orders
        orderIndex[orderID] = promotedOrderIDs.length;
        promotedOrderIDs.push(orderID);

        // emit event
        emit OrderPromoted(orderID, msg.value);

        // send funds
        _send(feeDatabase, address(this).balance);
    }

    function orderFulfilled(uint256 orderID) external {
        if (msg.sender == OTC && isPromotedOrder(orderID)) {        
            _removeOrder(orderID);
        }
    }

    function setOTC(address OTC_) external onlyOwner {
        OTC = OTC_;
    }

    function removeOrder(uint256 orderID) external onlyOwner {
        require(
            isPromotedOrder(orderID),
            'Order ID Not Promoted'
        );
        _removeOrder(orderID);
    }

    function removeOrders(uint256[] calldata orderIDs) external onlyOwner {
        uint len = orderIDs.length;

        for (uint i = 0; i < len;) {
            require(
                isPromotedOrder(orderIDs[i]),
                'Order ID Not Promoted'
            );
            _removeOrder(orderIDs[i]);
            unchecked { ++i; }
        }
    }

    function withdraw() external onlyOwner {
        _send(msg.sender, address(this).balance);
    }

    function withdrawToken(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function setMinCost(uint256 newMin) external onlyOwner {
        minCost = newMin;
    }

    function _removeOrder(uint256 orderID) internal {

        // make function more readable
        uint lastOrder = promotedOrderIDs[promotedOrderIDs.length - 1];
        uint rmIndex = orderIndex[orderID];

        // rearrange array
        orderIndex[lastOrder] = rmIndex;
        promotedOrderIDs[rmIndex] = lastOrder;
        promotedOrderIDs.pop();

        delete orderIndex[orderID];
    }

    function _send(address to, uint256 amount) internal {
        if (to == address(this) || to == address(0)) {
            return;
        }
        (bool s,) = payable(to).call{value: amount}("");
        require(s, 'ETH Transfer Failure');
    }

    function isPromotedOrder(uint256 orderID) public view returns (bool) {
        if (promotedOrderIDs.length == 0 || promotedOrderIDs.length <= orderIndex[orderID]) {
            return false;
        }
        return promotedOrderIDs[orderIndex[orderID]] == orderID;
    }

    function fetchAllPromotedOrders() external view returns (uint256[] memory) {
        return promotedOrderIDs;
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