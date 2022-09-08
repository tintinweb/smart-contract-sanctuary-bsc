//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";
import "./IERC20.sol";

interface IRoyaltyDatabase {
    function getRoyaltyRecipient() external view returns (address);
    function getPlatformRecipient() external view returns (address);
}

contract PromotionManager is Ownable {

    /**
        Royalty Database
     */
    IRoyaltyDatabase public constant royaltyDatabase = IRoyaltyDatabase(0x12EF041Ef3a504463AE25ACAFC0C1288aCb1Cf4b);

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

    constructor(address OTC_) {
        OTC = OTC_;
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
        _send(royaltyDatabase.getRoyaltyRecipient(), address(this).balance / 10);
        _send(royaltyDatabase.getPlatformRecipient(), address(this).balance);
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