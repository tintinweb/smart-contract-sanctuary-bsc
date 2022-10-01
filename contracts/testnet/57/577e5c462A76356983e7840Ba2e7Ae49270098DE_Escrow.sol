/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
contract Escrow{
    address payable public owner;
    uint256 private minimumEscrowAmount;
    uint256 private commissionRate;
    address payable private commissionWallet;
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
    uint256 private depositTime;

    event Funded(address buyer, uint256 amount, State status);
    event Accepted(address buyer, address seller, State status);
    event ReleaseFund(
        address buyer,
        address seller,
        State status,
        uint256 amount_released
    );
    event Withdraw(address _buyer, uint256 amount, State status);
    event SixMonths(
        address _destAddr,
        uint256 amount_withdrawn
    );

    modifier isAddressValid(address addr) {
        require(addr.code.length == 0 && addr != address(0x0), "Invalid address!");
        _;
    }

    modifier buyerOnly(address _buyer) {
        require(_buyer == buyer, "Only accessible by buyer!");
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

    modifier stateInit(){
        require(currentState == State.INIT, "State's not INIT!");
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
        require(block.timestamp - depositTime > 3 minutes, "Funds can be withdrawn only after a period of 6 months!");
        _;
    }

    function initializeDeal(
        address payable _commissionWallet,
        uint256 _minimumEscrowAmount,
        uint256 _commissionRate,
        address payable _owner
    ) 
        public 
        initCheck
        isAddressValid (_commissionWallet)
    {
        commissionWallet = _commissionWallet;
        minimumEscrowAmount = _minimumEscrowAmount;
        commissionRate = _commissionRate;
        owner = _owner;
    }

    function escrowParties(
        // address payable _buyer, 
        address payable _seller
    )
        public
        initByOwner
        differentWalletAddresses(tx.origin, _seller)
        isAddressValid (tx.origin)
        isAddressValid (_seller)
    {
        buyer = payable(tx.origin);
        seller = _seller;
    }

    function deposit() 
        public 
        payable 
        buyerOnly(tx.origin)
        stateInit
        partiesDefined
        minimumAmount 
    {
        currentState = State.FUNDED;
        emit Funded(tx.origin, msg.value, State.FUNDED);
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
        stateAccepted
        buyerOrSellerOnly 
    {
        (uint256 amountAfterCommission, uint256 commissionAmount) = calculateAmountToTransfer();
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

    function withdrawFund(address payable _buyer) 
        public 
        stateFunded 
        buyerOnly(_buyer)
    {
        (uint256 amountAfterCommission, uint256 commissionAmount) = calculateAmountToTransfer();
        buyer.transfer(amountAfterCommission);
        commissionWallet.transfer(commissionAmount);
        currentState = State.REFUNDED;
        emit Withdraw(msg.sender, amountAfterCommission, State.REFUNDED);
    }

    function calculateAmountToTransfer() internal view returns (uint256, uint256){
        uint256 dealAmount = address(this).balance;
        uint256 amountAfterCommission = dealAmount - ((dealAmount * commissionRate) / 100);
        uint256 commissionAmount = dealAmount - amountAfterCommission;
        return (amountAfterCommission, commissionAmount); 
    }

    function changeCommissionRate(uint256 _commissionRate)
        public
        initByOwner
        ownerOnly
        dealCommissionRate(_commissionRate)
    {
        commissionRate = _commissionRate;
    }

    function postSixMonths()
        public
        payable
        // stateAccepted
        minimumTimePeriod
        ownerOnly
        // isAddressValid(ownerAddress)
    {
        owner.transfer(address(this).balance);
        currentState = State.WITHDRAWED_BY_OWNER;
        emit SixMonths(owner, msg.value);
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

    receive() external payable{
        deposit();
    }
}