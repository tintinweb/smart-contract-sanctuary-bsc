/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// File: test.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;


contract Escrow{
    
    // list of moderators
    mapping(address => bool) private moderators;
    
    mapping(address => mapping(bytes32 => EscrowStruct)) public buyerDatabase;
    
    address public feeCollector; // Collected taxes will be forwarded here

    enum Status { PENDING, IN_DISPUTE, COMPLETED, REFUNDED }
    
    struct EscrowTax {
        uint256 buyerTax;
        uint256 sellerTax;
    }
    
    struct EscrowStruct {
        address buyer;      //the address of the buyer
        address seller;     //the address of the seller
        uint256 amount;     //the price of the order
        uint256 tax_amount; //the amount in BNB of the tax
        uint256 deliveryTimestamp; //the timestamp of the delivery
        Status status;      //the current status of the order
    }
    
    
    EscrowTax public escrowTax = EscrowTax({
        buyerTax: 2,
        sellerTax: 2
    });
    
    modifier onlyModerators() {
       require(moderators[msg.sender],"Address is not moderator");
       _;
    }
    
    event OrderStarted(address buyer, address seller, bytes32 id, uint256 amount);
    event OrderDelivered(address buyer, bytes32 id, uint256 time);
    event RefundEmitted(address buyer, bytes32 id, uint256 amount);
    event ResolvedToSeller(address seller, bytes32 id, uint256 amount);
    event DeliveryConfirmed(address seller, bytes32 id, uint256 amount);
    
    constructor(address[] memory _moderators, address _feeCollector) {
      for(uint256 i; i< _moderators.length; i++){
          moderators[_moderators[i]] = true;
      }
      
      feeCollector = _feeCollector;
    }
    
    /// @notice Updates taxes for buyer and seller
    /// @dev Total tax must be <= 20%
    function setEscrowTax(uint256 _buyerTax, uint256 _sellerTax) external onlyModerators{
        require(_buyerTax + _sellerTax <= 20, "Total tax must be <= 20");
        escrowTax.buyerTax = _buyerTax;
        escrowTax.sellerTax = _sellerTax;
    }
    
    function setFeeCollector(address newAddress) external onlyModerators{
        feeCollector = newAddress;
    }
    
    function computerHash(address buyer, address seller, uint256 time) internal pure returns(bytes32){
        return keccak256(abi.encode(buyer, seller, time));
    }
    
    /// @notice Starts a new escrow service
    /// @param sellerAddress The address of the seller
    /// @param price The price of the service in BNB
    function startTrade(address sellerAddress, uint256 price) external payable returns(address, address, bytes32, uint256){
        require(price > 0 && msg.value == (price + (price*escrowTax.buyerTax / 100)));
        bytes32 _tx_id = computerHash(msg.sender, sellerAddress, block.timestamp);
        uint256 _tax_amount = price * escrowTax.buyerTax / 100;
        buyerDatabase[msg.sender][_tx_id] = EscrowStruct(msg.sender, sellerAddress, price, _tax_amount, 0, Status.PENDING);
        emit OrderStarted(msg.sender, sellerAddress, _tx_id, price);
        return (msg.sender, sellerAddress, _tx_id, price);
    }
    
    /// @notice Deliver the order and set the delivery timestamp
    /// @param buyerAddress The address of the buyer of the order
    /// @param _tx_id The id of the order
    function deliverOrder(address buyerAddress, bytes32 _tx_id) external{
        require(msg.sender == buyerDatabase[buyerAddress][_tx_id].seller, "Only seller can deliver");
        require(buyerDatabase[buyerAddress][_tx_id].status == Status.PENDING);
        buyerDatabase[buyerAddress][_tx_id].deliveryTimestamp = block.timestamp;
        emit OrderDelivered(buyerAddress, _tx_id, block.timestamp);
    }
    
    /// @notice Open a dispute, if this is done in 48h from delivery
    /// @param buyerAddress The address of the buyer of the order
    /// @param _tx_id The id of the order
    function openDispute(address buyerAddress, bytes32 _tx_id) external {
        require(buyerDatabase[buyerAddress][_tx_id].status == Status.PENDING);
        require(msg.sender == buyerDatabase[buyerAddress][_tx_id].buyer, "Only buyer can deliver");
        require(block.timestamp < buyerDatabase[buyerAddress][_tx_id].deliveryTimestamp + 48 hours, "Dispute must be opened in 48h after delivery");
        buyerDatabase[buyerAddress][_tx_id].status = Status.IN_DISPUTE;
    }
    
    /// @notice Refunds the buyer. Only moderators or seller can call this
    /// @param buyerAddress The address of the buyer to refund
    /// @param _tx_id The id of the order
    function refundBuyer(address buyerAddress, bytes32 _tx_id) external {
        require(msg.sender == buyerDatabase[buyerAddress][_tx_id].seller || moderators[msg.sender], "Only seller or moderator can refund");
        require(buyerDatabase[buyerAddress][_tx_id].status == Status.IN_DISPUTE || buyerDatabase[buyerAddress][_tx_id].status == Status.PENDING);
        uint256 amountToRefund = buyerDatabase[buyerAddress][_tx_id].amount + buyerDatabase[buyerAddress][_tx_id].tax_amount;
        buyerDatabase[buyerAddress][_tx_id].status = Status.REFUNDED;
        payable(buyerAddress).transfer(amountToRefund);
        emit RefundEmitted(buyerAddress, _tx_id, amountToRefund);
    }
    
    /// @notice Resolve the dispute in favor of the seller
    /// @param buyerAddress The address of the buyer of the order
    /// @param _tx_id The id of the order
    function resolveToSeller(address buyerAddress, bytes32 _tx_id) external onlyModerators{
        require(buyerDatabase[buyerAddress][_tx_id].status == Status.IN_DISPUTE);
        uint256 taxAmount = buyerDatabase[buyerAddress][_tx_id].amount * escrowTax.sellerTax / 100;
        uint256 amountToRelease = buyerDatabase[buyerAddress][_tx_id].amount - taxAmount;
        address sellerAdd = buyerDatabase[buyerAddress][_tx_id].seller;
        collectFees(taxAmount);
        payable(sellerAdd).transfer(amountToRelease);
        emit ResolvedToSeller(sellerAdd, _tx_id, amountToRelease);
    }
    
    /// @notice Confirm the delivery and forward funds to seller
    /// @param buyerAddress The address of the buyer
    /// @param _tx_id The id of the order
    function confirmDelivery(address buyerAddress, bytes32 _tx_id) external{
        require(msg.sender == buyerDatabase[buyerAddress][_tx_id].buyer, "Only buyer can confirm delivery");
        require(buyerDatabase[buyerAddress][_tx_id].status == Status.PENDING);
        buyerDatabase[buyerAddress][_tx_id].status = Status.COMPLETED;
        uint256 taxAmount = buyerDatabase[buyerAddress][_tx_id].amount * escrowTax.sellerTax / 100;
        uint256 amountToRelease = buyerDatabase[buyerAddress][_tx_id].amount - taxAmount;
        address sellerAdd = buyerDatabase[buyerAddress][_tx_id].seller;
        collectFees(taxAmount);
        payable(sellerAdd).transfer(amountToRelease);
        emit DeliveryConfirmed(sellerAdd, _tx_id, amountToRelease);
    }
    
    /// @notice Collects fees and forward to feeCollector
    function collectFees(uint256 amount) internal{
        require(amount > 0);
        payable(feeCollector).transfer(amount);
    }

}