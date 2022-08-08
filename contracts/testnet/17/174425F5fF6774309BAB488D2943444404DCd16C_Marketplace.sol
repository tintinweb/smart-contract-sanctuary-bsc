/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

pragma solidity >=0.4.22 <0.9.0;

// SPDX-License-Identifier: MIT
interface IBEP1155 {
    function getOwner() external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
    function getPriceTicket(uint256 _id) external view returns (uint256);
}

contract Marketplace {
    enum Status {
        SELLING,
        CLOSE,
        CANCEL
    }

    struct Auction {
        address _owner;
        address _ticketAddress;
        uint256 _ticketId;
        uint256 _amount;
        uint256 _price;
        Status status;
    }

    uint256 public constant OWNER_RATE = 6;
    uint256 public constant OWNER_TICKET_RATE = 6;
    uint256 public constant PRICE_RANGE = 15;
    address public owner;
    address[] public listSellingEvent;
    mapping(address => Auction[]) private _auctionData;

    event sellTicketEventStore (address ticketAddress, uint256 ticketId, uint256 amount, uint256 price);
    event sellTicketEvent (address ticketAddress, uint256 ticketId, uint256 amount, uint256 price);
    event cancelTicketEvent (uint256 auctionIndex);
    event buyTicketEvent (uint256 auctionIndex, address buyer, uint256 amount);

    constructor() public {
        owner = msg.sender;
    }

    function getLengthSellingEvent () external view returns (uint256) {
        return listSellingEvent.length;
    }

    function sellTicket(address ticketAddress, uint256 ticketId, uint256 amount, uint256 price) public {
        require(amount > 0, "Invalid amount");
        require(_checkValidTicketPrice(ticketAddress, ticketId, price), "Price is not valid!");

        if (_auctionData[ticketAddress].length == 0) listSellingEvent.push(ticketAddress);
        _auctionData[ticketAddress].push(Auction(msg.sender, ticketAddress, ticketId, amount, price, Status.SELLING));
        IBEP1155(ticketAddress).safeTransferFrom(msg.sender, address(this), ticketId, amount, "0x");
        emit sellTicketEvent(ticketAddress, ticketId, amount, price);
    }

    function cancelTicket(address ticketAddress, uint256 auctionIndex) public {
        require(msg.sender == _auctionData[ticketAddress][auctionIndex]._owner, "Caller is not owner!");
        require (_auctionData[ticketAddress][auctionIndex].status == Status.SELLING, "Error, this auction is not in sale");
        _auctionData[ticketAddress][auctionIndex].status = Status.CANCEL;
        IBEP1155(ticketAddress).safeTransferFrom(address(this), msg.sender, _auctionData[ticketAddress][auctionIndex]._ticketId, _auctionData[ticketAddress][auctionIndex]._amount, "0x");
        emit cancelTicketEvent(auctionIndex);
    }

    function buyTicket(address ticketAddress, uint256 ticketId,  uint256 auctionIndex, uint256 amount) public payable {
        require(
            msg.value >= _auctionData[ticketAddress][auctionIndex]._price,
            "Error, Token costs more"
        );
        require (_auctionData[ticketAddress][auctionIndex]._amount >= amount, "Error, Not enough ticket");
        require (_auctionData[ticketAddress][auctionIndex]._amount > 0, "Error, Not enough ticket");
        require (_auctionData[ticketAddress][auctionIndex].status == Status.SELLING, "Error, this auction is currently unavailable!");

        _auctionData[ticketAddress][auctionIndex]._amount -= amount;
        if(_auctionData[ticketAddress][auctionIndex]._amount == 0)
            _auctionData[ticketAddress][auctionIndex].status = Status.CLOSE;

        IBEP1155(ticketAddress).safeTransferFrom(address(this), msg.sender, ticketId, amount, "0x");
        payable(owner).transfer(msg.value*OWNER_RATE/100);
        payable(IBEP1155(_auctionData[ticketAddress][auctionIndex]._ticketAddress).getOwner()).transfer(msg.value*OWNER_TICKET_RATE/100);
        payable(_auctionData[ticketAddress][auctionIndex]._owner).transfer(msg.value*(100-OWNER_RATE-OWNER_TICKET_RATE)/100);
        emit buyTicketEvent(auctionIndex, msg.sender, amount);
    }

    function getTicket1155Data (address ticketAddress) external view returns (Auction[] memory) {
        return _auctionData[ticketAddress];
    }

    function getAuctionData (address ticketAddress, uint256 auctionIndex) external view returns (Auction memory) {
        return _auctionData[ticketAddress][auctionIndex];
    }

    function _checkValidTicketPrice (
        address ticketAddress,
        uint256 _ticketId,
        uint256 _price
    ) internal view returns (bool){
        if (
            _price > _getTicketPricebyId(ticketAddress, _ticketId)*(100+PRICE_RANGE)/100 ||
            _price < _getTicketPricebyId(ticketAddress, _ticketId)*(100-PRICE_RANGE)/100
        ) return false;
        return true;
    }

    function _getTicketPricebyId(address ticketAddress, uint256 ticketId) internal view returns (uint256) {
        return IBEP1155(ticketAddress).getPriceTicket(ticketId);
    }


    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns (bytes4){
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns (bytes4){
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }
}