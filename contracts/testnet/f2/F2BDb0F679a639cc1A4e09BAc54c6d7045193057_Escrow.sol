/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract Escrow {
    uint256 private minimumEscrowAmount;
    uint256 public commission;

    enum State {
        INIT,
        FUNDED,
        ACCEPT_DEAL,
        RELEASE_FUND,
        REFUND,
        WITHDRAWED_BY_OWNER
    }

    address public OWNER;
    address payable public buyer;
    address payable public seller;
    address payable private commissionWallet;
    uint256 amount;
    State public currState;
    uint256 public depositedAmount;
    uint256 public depositTime;

    event Funded(address buyer, uint256 amount, State status);
    event Accepted(address buyer, address seller, State status);
    event ReleaseFund(
        address buyer,
        address seller,
        State status,
        uint256 amnount_released
    );
    event Withdraw(address _from, address _destAddr);
    event ItsBeen6Months(
        address _from,
        address _destAddr,
        uint256 amount_withdrawn
    );

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this method");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only Seller can call this method");
        _;
    }

    modifier init_by_owner() {
        require(
            OWNER != address(0x0),
            "The deal has not been initialised by the owner yet"
        );
        _;
    }

    modifier initialising_Deal() {
        require(OWNER == address(0x0), "You cannot initialize a deal twice!");
        _;
    }

    modifier buyerOrSeller() {
        require(msg.sender == buyer || msg.sender == seller);
        _;
    }

    modifier onlyOwner() {
        require(
            OWNER == msg.sender,
            "Only contract owner can call this method!"
        );
        _;
    }

    modifier stateFunded() {
        require(currState == State.FUNDED, "Escrow has not been funded yet");
        _;
    }

    modifier stateAccepted() {
        require(
            currState == State.ACCEPT_DEAL,
            "Seller has not accepted the deal yet"
        );
        _;
    }

    modifier minimumAmount() {
        require(
            msg.value >= minimumEscrowAmount,
            "Minimum amount to escrow is 0.001 BNB"
        );
        _;
    }

    modifier isValidAddress(address addr) {
        require(addr.code.length == 0, "The wallet address is not valid");
        _;
    }

    modifier deal_INIT() {
        require(
            buyer != address(0x0) && seller != address(0x0),
            "The deal has not been initialised yet!"
        );
        _;
    }

    function initialiser(
        address payable _commissionWallet,
        uint256 _minimumEscrowAmount,
        uint256 _commission
    ) public isValidAddress(_commissionWallet) initialising_Deal {
        commissionWallet = _commissionWallet;
        minimumEscrowAmount = _minimumEscrowAmount;
        commission = _commission;
        OWNER = msg.sender;
    }

    function escrowParties(address payable _buyer, address payable _seller)
        external
        init_by_owner
        isValidAddress(_buyer)
        isValidAddress(_seller)
    {
        buyer = _buyer;
        seller = _seller;
    }

    function deposit() external payable deal_INIT minimumAmount onlyBuyer {
        currState = State.FUNDED;
        depositedAmount = msg.value;
        emit Funded(msg.sender, depositedAmount, State.FUNDED);
        depositTime = block.timestamp;
    }

    function acceptDeal() external stateFunded onlySeller {
        currState = State.ACCEPT_DEAL;
        emit Accepted(buyer, msg.sender, State.ACCEPT_DEAL);
    }

    function releaseFund() external buyerOrSeller stateAccepted {
        uint256 amount_after_commission = depositedAmount -
            ((depositedAmount * commission) / 100);
        uint256 commissionAmount = (depositedAmount * commission) / 100;

        if (msg.sender == buyer) {
            seller.transfer(amount_after_commission);
        } else if (msg.sender == seller) {
            buyer.transfer(amount_after_commission);
        }
        commissionWallet.transfer(commissionAmount);
        currState = State.RELEASE_FUND;
        emit ReleaseFund(
            buyer,
            seller,
            State.RELEASE_FUND,
            amount_after_commission
        );
    }

    function refund() external stateFunded onlyBuyer {
        uint256 amount_after_commission = depositedAmount -
            ((depositedAmount * commission) / 100);
        uint256 commAmount = (depositedAmount * commission) / 100;
        buyer.transfer(amount_after_commission);
        commissionWallet.transfer(commAmount);
        currState = State.REFUND;
    }

    function changeCommissionRate(uint256 comm_rate)
        public
        init_by_owner
        onlyOwner
    {
        require(
            comm_rate <= 100 && comm_rate > 0,
            "commission rate cannot be more than 100"
        );
        commission = comm_rate;
    }

    function itsbeen6Months(address payable ownerAccount)
        external
        payable
        init_by_owner
        stateAccepted
        onlyOwner
        isValidAddress(msg.sender)
        isValidAddress(ownerAccount)
    {
        require(
            block.timestamp - depositTime > 26 weeks,
            "The money can only be withdrawn after 6 months"
        );
        ownerAccount.transfer(address(this).balance);
        currState = State.WITHDRAWED_BY_OWNER;
        emit ItsBeen6Months(msg.sender, ownerAccount, msg.value);
    }

    function getCurrentState() public view returns (State) {
        return currState;
    }

    function getCommission() public view returns (uint256) {
        return commission;
    }
}