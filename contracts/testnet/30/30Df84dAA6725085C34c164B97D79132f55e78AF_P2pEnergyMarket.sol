pragma solidity ^0.8.17;

/**
 * 
 * 
 */

contract P2pEnergyMarket { 
    enum ContractState {NotCreated, Created, HasOffer, Established, ReadyForPayement, ReportNotOk, Closed}
    enum AuctionState {Created, Closed, RevealEnd}
    
    struct Payment {
        uint bidId;
        uint256 date;
        uint energyAmount;
        bool toPay; //or toReceive
        uint total;
    }

    struct Account { // User account
        // int256 balance;
        uint energyAmount;
        Payment[] payments;
        bool isActive;
    }
    
   
    struct Auction {
        uint nbBid;
        AuctionState state;
    }

    struct Contract {
        address buyer; 
        address  seller; 
        uint  amount;
        uint  buyerMaxPrice;
        uint  currentPrice;
        uint secondLowestPrice;
        bool  buyerMeterReport;
        bool  sellerMeterReport; 
        uint256  deliveryTime;
        uint256  auctionTimeOut;
        uint  deliveryLocation;
        ContractState state;       
    }

    modifier auctionNotClosed(uint _aucId) {
        require(auctions[_aucId].state  == AuctionState.Created, "auction is not created");
        _;
    }
    
    modifier auctionClosed(uint _aucId) {
        require(auctions[_aucId].state == AuctionState.Closed, "auction is not closed");
        _;
    }
    
    modifier revealNotEnded(uint _aucId) {
        require(auctions[_aucId].state != AuctionState.RevealEnd, "auction is reveal end");
        _;
    }
    
    modifier auctionExisit(uint _aucId) {
        require(contracts[_aucId].state != ContractState.NotCreated, "contract not created");
        _;
    }

    modifier auctionTimeOut(uint _aucId) {
        require(contracts[_aucId].auctionTimeOut > block.timestamp, "timeout");
        _;
    }

    modifier contractEstablished(uint _aucId) {
        require(contracts[_aucId].state == ContractState.Established, "not established");
        _;
    }

    modifier reportsOk(uint _aucId) {
        require(contracts[_aucId].sellerMeterReport, "seller not agreed");
        require(contracts[_aucId].buyerMeterReport, "buyer not agreed");
        _;
    }

    modifier buyerOnly(uint _aucId) {
        require(contracts[_aucId].buyer == msg.sender, "it is not buyer");
        _;
    }

    modifier buyerNot(uint _aucId) {
        require(contracts[_aucId].buyer != msg.sender, "it is buyer");
        _;
    }

    modifier sellerOnly(uint _aucId) {
        require(contracts[_aucId].seller == msg.sender, "it is not seller");
        _;
    }

    modifier accountExist(address _user) {
        require(accounts[_user].isActive, "account is not exist");
        _;
    }

    uint public totalAuction;

    mapping (uint => Contract) public contracts;
    mapping (uint => Auction)  auctions;
    mapping (address => Account) public accounts;

    event LogReqCreated(address buyer, uint _aucId, uint _maxPrice, uint _amount, uint256 _time, uint256 _auctionTime, uint _location);
    event LowestBidDecreased (address _seller, uint _aucId, uint _price, uint _amount);
    event FirstOfferAccepted (address _seller, uint _aucId, uint _price, uint _amount);
    event ContractEstablished (uint _aucId, address _buyer, address _seller);
    event ReportOk(uint _aucId);
    event ReportNotOk(uint _aucId);
    // event SealedBidReceived(address seller, uint _aucId, bytes32 _sealedBid, uint _bidId);
    // event BidNotCorrectelyRevealed(address bidder, uint _price, bytes32 _sealedBid);

    function createReq(uint _amount, uint _price, uint256 _time, uint256 _auctionTime, uint _location) public 
    {
        uint aucId = totalAuction++;
        storeAndLogNewReq(msg.sender, aucId, _amount, _price, _time, _auctionTime, _location);
    } 

    function createAccount(uint energyAmount) public {
        accounts[msg.sender].energyAmount = energyAmount;
        accounts[msg.sender].isActive = true;
    }
        
    function closeAuction(uint _aucId) public
        auctionExisit(_aucId) 
        buyerOnly(_aucId)
        //to do: conractNotEstablished(_aucId)
        //auctionTimeOut(_aucId)
    {
        auctions[_aucId].state = AuctionState.Closed;
    }
    
    function endReveal(uint _aucId) public
        auctionExisit(_aucId) 
        buyerOnly(_aucId)
        //to do: conractNotEstablished(_aucId)
        //auctionTimeOut(_aucId)
    {
        auctions[_aucId].state = AuctionState.RevealEnd;
        contracts[_aucId].state= ContractState.Established;
    }
    
    function revealOffer (uint _aucId, uint _price) public 
        auctionExisit(_aucId)
        auctionNotClosed(_aucId) 
        revealNotEnded(_aucId)
        buyerNot(_aucId)
    {        
        if (contracts[_aucId].state == ContractState.HasOffer) {
            if(_price < contracts[_aucId].currentPrice) {        
                contracts[_aucId].secondLowestPrice = contracts[_aucId].currentPrice;
                contracts[_aucId].currentPrice = _price;
                contracts[_aucId].seller = msg.sender;
                emit LowestBidDecreased(msg.sender, _aucId, _price, 0);
            } else {
                if (_price < contracts[_aucId].secondLowestPrice) {
                    contracts[_aucId].secondLowestPrice = _price;
                }
            }
        } else { // first offer
            require(_price <= contracts[_aucId].buyerMaxPrice);         
            contracts[_aucId].currentPrice = _price; 
            contracts[_aucId].secondLowestPrice = _price;
            contracts[_aucId].seller = msg.sender;
            contracts[_aucId].state = ContractState.HasOffer;  
            emit FirstOfferAccepted(msg.sender, _aucId, _price, 0); 
        } 
    }

    function setBuyerMeterReport (uint _aucId, bool _state) public 
        auctionExisit(_aucId)
        contractEstablished(_aucId)
    {
        if (!_state) {
            emit ReportNotOk(_aucId);
        }
        contracts[_aucId].buyerMeterReport = _state;
        contracts[_aucId].sellerMeterReport = _state;
        // if (contracts[_aucId].sellerMeterReport) {
            updateBalance(_aucId, contracts[_aucId].buyer, contracts[_aucId].seller);
            emit ReportOk(_aucId);
        // }
    }

    function setSellerMeterReport (uint _aucId, bool _state) public 
        auctionExisit(_aucId)
        contractEstablished(_aucId)
    {
        if (!_state) {
            emit ReportNotOk(_aucId);
        }
        // contracts[_aucId].sellerMeterReport = _state;
        // if (contracts[_aucId].buyerMeterReport) {
        //     updateBalance(_aucId, contracts[_aucId].buyer, contracts[_aucId].seller);
        //     emit ReportOk(_aucId);
        // }
    }

    function updateBalance(uint _aucId, address _buyer, address _seller) public payable
        reportsOk(_aucId)   
    {
        uint256 date = contracts[_aucId].deliveryTime;
        uint amount = contracts[_aucId].amount;
        // uint amounToPay = amount * contracts[_aucId].secondLowestPrice;
        uint amounToPay = amount * contracts[_aucId].currentPrice;
        require(msg.value >= amounToPay, "Balance is not enough");
        require(accounts[_seller].energyAmount >= amount, "Amount is not enough");
        accounts[_buyer].payments.push(Payment(_aucId, date, amount, true, amounToPay));
        accounts[_buyer].energyAmount += amount;
        // accounts[_buyer].balance -= int256(amounToPay);
        (bool sent, ) = payable(_seller).call{value: amounToPay}("");
        require(sent, "Failed to send");
        accounts[_seller].payments.push(Payment(_aucId, date, amount, false, amounToPay));
        accounts[_seller].energyAmount -= amount;
        // accounts[_seller].balance += int256(amounToPay);
        contracts[_aucId].state = ContractState.Closed;
    }

    // function registerNewUser(address _user) public {
    //     //should be added by the utility only
    //     //later add a modifier: utilityOnly()
    //     accounts[_user].isActive = true;
    // }

    function getAccount(address _user) public view returns(Account memory _account) {
        return accounts[_user];
    }

    function getReq(uint _index) public view returns(Contract memory _contract) {
        return (contracts[_index]);
    }

    function getReqState(uint _index) public view returns(ContractState) {
        return (contracts[_index].state);
    }

    function getNumberOfReq() public view returns (uint) {
        return totalAuction;
    }

    function storeAndLogNewReq(address _buyer, uint _id, uint _amount, uint _price, uint256 _time, uint256 _auctionTime, uint _location) private {
        contracts[_id].buyer = _buyer;
        contracts[_id].amount = _amount;
        contracts[_id].buyerMaxPrice = _price;
        contracts[_id].deliveryTime = _time;
        contracts[_id].auctionTimeOut = block.timestamp + _auctionTime;
        contracts[_id].deliveryLocation = _location;
        contracts[_id].state = ContractState.Created;
        auctions[_id].state = AuctionState.Created;
        auctions[_id].nbBid = 0;
        emit LogReqCreated(_buyer, _id, _price, _amount, _time, _auctionTime, _location);
    }

}