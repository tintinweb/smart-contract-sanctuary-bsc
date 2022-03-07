/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

pragma solidity ^0.8.0;
contract simpleAuction {
    //varisable
    address payable public beneficiary;
    uint256 public auctionEndTime;
    uint256 public highestBid;
    address public highestBidder;
    bool ended = false;
    mapping(address => uint256) public pendingReturns;
    //event
    event highestBidIncrease(address bidder, uint256 amount);
    event auctionEnded(address winner, uint256 amount);

    constructor(uint256 _biddingTime, address payable _beneficiary){
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    //Function
    function bid() public payable {
        if (block.timestamp > auctionEndTime)
        {
            revert("Phien dau gia da ket thuc");
        }
        if (msg.value <= highestBid)
        {
            revert("Gia tri cua ban thap hon gia tri cao nhat");
        }
        if (highestBid != 0)
        {
            pendingReturns[highestBidder] + highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit highestBidIncrease(msg.sender, msg.value);
    }
    function withDraw() public returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0){
            pendingReturns[msg.sender] = 0;
            if(!payable(msg.sender).send(amount)){
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }
    function auctionEnd() public{
        if(ended){
            revert("Phien dau gia da co the ket thuc ");
        }
        if(block.timestamp < auctionEndTime){
            revert("Phien dau gia chua ket thuc");
        }
        ended = true;
        emit auctionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid);
    }
}