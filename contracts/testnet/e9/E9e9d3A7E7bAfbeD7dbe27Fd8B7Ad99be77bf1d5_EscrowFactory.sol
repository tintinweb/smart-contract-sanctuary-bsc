/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// File: escrow.sol


pragma solidity >=0.8.0;

contract Escrow {
    address public owner = msg.sender;
    uint256 private minimumEscrowAmount = 10000000000000000;
    uint256 private commissionRate = 2;
    address payable private commissionWallet = payable(0x36abe7844431d3fcd38edea8f1B479eD7898a2Eb);
    enum State {
        INIT,
        FUNDED,
        ACCEPTED,
        RELEASED,
        REFUNDED,
        WITHDRAWED_BY_OWNER
    }
    address payable public buyer;
    address payable public seller;
    State private currentState;
    uint256 public depositTime;

    event Funded(address buyer, uint256 amount, State status);
    event Accepted(address buyer, address seller, State status);
    event ReleaseFund(
        address buyer,
        address seller,
        State status,
        uint256 amount_released
    );
    event Withdraw(address _buyer, uint256 amount, State status);
    event sixMonths(
        address _destAddr,
        uint256 amount_withdrawn
    );

    modifier isAddressValid(address addr) {
        require(addr.code.length == 0, "Invalid address!");
        _;
    }

    modifier buyerOnly() {
        require(msg.sender == buyer, "Only accessible by buyer!");
        _;
    }

    modifier sellerOnly() {
        require(msg.sender == seller, "Only accessible by seller!");
        _;
    }

    modifier ownerOnly() {
        require(owner == msg.sender, "Only accessible by owner!");
        _;
    }

    modifier buyerOrSellerOnly() {
        require(msg.sender == buyer || msg.sender == seller, "Invalid message sender!");
        _;
    }

    modifier initByOwner() {
        require(owner != address(0x0), "Deal not initialized yet!");
        _;
    }

    modifier initCheck() {
        require(owner == address(0x0), "Can't initialize a deal twice!");
        _;
    }

    modifier stateFunded() {
        require(currentState == State.FUNDED, "Deal not funded yet!");
        _;
    }

    modifier stateAccepted() {
        require(currentState == State.ACCEPTED, "Deal not accepted yet!");
        _;
    }

    modifier minimumAmount() {
        require(msg.value >= minimumEscrowAmount, "Value less than minimum amount required!");
        _;
    }    

    modifier partiesDefined() {
        require(buyer != address(0x0) && seller != address(0x0), "Escrow parties not set yet!");
        _;
    }

    modifier dealCommissionRate(uint256 comm_rate){
         require(comm_rate <= 100 && comm_rate > 0, "Invalid commission rate!");
        _;
    }

    modifier differentWalletAddresses(address _buyer, address _seller){
        require(_buyer != _seller && _buyer != commissionWallet && _seller != commissionWallet,
            "Buyer, seller & commission wallets, must all be different!"
        );
        _;
    }

    modifier minimumTimePeriod(){
        require(block.timestamp - depositTime > 26 weeks, "Funds can be withdrawn only after a period of 6 months!");
        _;
    }

    // function initializeDeal(
    //     address payable _commissionWallet,
    //     uint256 _minimumEscrowAmount,
    //     uint256 _commissionRate
    // ) 
    //     public 
    //     isAddressValid (_commissionWallet) 
    //     initCheck 
    // {
    //     commissionWallet = _commissionWallet;
    //     minimumEscrowAmount = _minimumEscrowAmount;
    //     commissionRate = _commissionRate;
    //     owner = msg.sender;
    // }

    function escrowParties(
        address payable _buyer, 
        address payable _seller
    )
        public
        initByOwner
        differentWalletAddresses(_buyer, _seller)
        isAddressValid (_buyer)
        isAddressValid (_seller)
    {
        buyer = _buyer;
        seller = _seller;
    }

    function deposit() 
        public 
        payable 
        partiesDefined 
        minimumAmount 
        buyerOnly
    {
        currentState = State.FUNDED;
        emit Funded(msg.sender, msg.value, State.FUNDED);
        depositTime = block.timestamp;
    }

    function acceptDeal() 
        public 
        stateFunded 
        sellerOnly 
    {
        currentState = State.ACCEPTED;
        emit Accepted(buyer, msg.sender, State.ACCEPTED);
    }

    function releaseFund() 
        public 
        buyerOrSellerOnly 
        stateAccepted 
    {
        uint256 dealAmount = address(this).balance;
        uint256 amountAfterCommission = dealAmount - ((dealAmount * commissionRate) / 100);
        uint256 commissionAmount = dealAmount - amountAfterCommission;
        msg.sender == buyer ? seller.transfer(amountAfterCommission) : buyer.transfer(amountAfterCommission);
        commissionWallet.transfer(commissionAmount);
        currentState = State.RELEASED;
        emit ReleaseFund(
            buyer,
            seller,
            State.RELEASED,
            amountAfterCommission
        );
    }

    function withdrawFund() 
        public 
        stateFunded 
        buyerOnly
    {
        uint256 dealAmount = address(this).balance;
        uint256 amountAfterCommission = dealAmount - ((dealAmount * commissionRate) / 100);
        uint256 commissionAmount = dealAmount - amountAfterCommission;
        buyer.transfer(amountAfterCommission);
        commissionWallet.transfer(commissionAmount);
        currentState = State.REFUNDED;
        emit Withdraw(msg.sender, amountAfterCommission, State.REFUNDED);
    }

    function changeCommissionRate(uint256 _commissionRate)
        public
        initByOwner
        ownerOnly
        dealCommissionRate(_commissionRate)
    {
        commissionRate = _commissionRate;
    }

    function postSixMonths(
        address payable ownerAddress
    )
        public
        payable
        initByOwner
        stateAccepted
        minimumTimePeriod
        ownerOnly
        isAddressValid(ownerAddress)
    {
        ownerAddress.transfer(address(this).balance);
        currentState = State.WITHDRAWED_BY_OWNER;
        emit sixMonths(ownerAddress, msg.value);
    }

    function currentStateOfDeal()
        public 
        view 
        returns (State) 
    {
        return currentState;
    }

    function commissionRateOfDeal() 
        public 
        view 
        returns (uint256) 
    {
        return commissionRate;
    }
}

// File: factory.sol


pragma solidity >=0.8.0;


contract EscrowFactory {
    event NewDeal(address _newContractAddress);

    mapping(string => address) dealIdToContractAddress;

    modifier validString(string memory dealId){
        require(bytes(dealId).length > 0, "Invalid string!");
        _;
    }

    function createEscrow(string memory dealId, address payable seller) public validString(dealId) returns (address) {
        Escrow escrow = new Escrow();
        setdealId(dealId, address(escrow));
        escrow.escrowParties(payable(msg.sender), seller);
        emit NewDeal(address(escrow));
        return address(escrow);
    }

    function setdealId(string memory _dealId, address _escrowAddress) internal {
        dealIdToContractAddress[_dealId] = _escrowAddress;
    }

    function getContractAddress(string memory _dealId) public view returns (address) {
        return dealIdToContractAddress[_dealId];
    }
}