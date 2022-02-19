/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// SPDX-License-Identifier: none

pragma solidity ^0.8.4;

interface BEP20 {

    function totalSupply() external view returns (uint256 theTotalSupply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

contract SecurityBase {
    /////////////// Rentrancy //////////////////

    bool private __________1 = false;

    modifier nonReentrant() {
        require(!__________1, "Try again");
        __________1 = true;
        _;
        __________1 = false;
    }

    /////////////// Not Contract //////////////////

    modifier notContract() {
        require(
            !_isContract(msg.sender) || _________________,
            "Contract not allowed"
        );
        require(
            msg.sender == tx.origin || _________________,
            "Proxy contract not allowed"
        );
        _;
    }

    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    bool private _________________ = false;

    function _endCheckIsContract() public virtual onlyOwner {
        _________________ = true;
    }

    function _startCheckIsContract() public virtual onlyOwner {
        _________________ = false;
    }

    /////////////// Owner //////////////////

    address private ____o;

    constructor() {
        ____o = msg.sender;
    }

    function owner() public view returns (address) {
        return ____o;
    }

    modifier onlyOwner() {
        require(isOwner(), "Function accessible only by the owner !!");
        _;
    }

    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    function transferOwnership(address newOwner)
        public
        virtual
        onlyOwner
        validAddress(newOwner)
    {
        ____o = newOwner;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == ____o;
    }
}

contract PrivateSaleBoss is SecurityBase {
    uint256 TokenPricePerBNB = 200000;

    uint256 sum_paid = 0;

    uint256 max_paid = 600 * (10**18);

    uint256 max_paid_per_address = 5 * (10**18);

    struct Buyer { 
        uint256 paid;
        uint256 tokensBought;
        uint256[] tokenAmount;
        uint256[] buyDate;
        ////////////////

        uint256 remaining_claim;
        uint256 sum_claimed;
        bool is_change;
    }

    address private contractAddr = address(this);

    uint256 startTime = 0;
    uint256 endTime = 0;

    uint256 count_pay = 0;
    uint256 count_address = 0;

    mapping(address => Buyer) buyer;
    mapping(uint256 => address) adrsBuyer;

    event Received(address, uint256);
    event TokensBought(address, uint256);
    event OwnershipTransferred(address);
    event Airdrop(address[], uint256);

    // Set Start Time
    function setStartTime(uint256 time_) public onlyOwner {
        startTime = time_;
    }

    // Set End Time
    function setEndTime(uint256 time_) public onlyOwner {
        endTime = time_;
    }

    function viewStartTime() public view returns (uint256) {
        return startTime;
    }

    function viewEndTime() public view returns (uint256) {
        return endTime;
    }

    function viewCountAddress() public view returns (uint256) {
        return count_address;
    }

    function viewCount() public view returns (uint256) {
        return count_pay;
    }

    function viewSumPaid() public view returns (uint256) {
        return sum_paid;
    }

    // BUY TOKEN
    function buyToken() public payable notContract returns (bool) {
        require(startTime > 0, "Start time not defined");
        require(endTime > 0, "End time not defined");

        require(block.timestamp > startTime, "Private Sale not started yet");

        require(block.timestamp <= endTime, "Private Sale is end (time)");

        require(msg.value > 0, "Zero value");

        require(sum_paid < max_paid, "Private Sale is end (complete)");

        require(
            sum_paid + msg.value <= max_paid,
            "Excessive purchases (max 600 bnb)"
        );

        ///////////////////////////////

        require(
            buyer[msg.sender].paid + msg.value <= max_paid_per_address,
            "Excessive purchases (max 5 bnb)"
        );

        count_pay += 1;

        if (buyer[msg.sender].paid == 0) {
            
            /// is first time

            adrsBuyer[count_address] = msg.sender;
            buyer[msg.sender].is_change = false;
            count_address += 1;

        }

        sum_paid += msg.value;

        buyer[msg.sender].paid += msg.value;

        uint256 amount = msg.value * TokenPricePerBNB;

        buyer[msg.sender].tokensBought += amount;
 
        buyer[msg.sender].tokenAmount.push(amount);

        buyer[msg.sender].buyDate.push(block.timestamp);

        emit TokensBought(msg.sender, amount);

        return true;
    }

    address __tokenAddress;
    bool __isClaimStart = false;

    // Set Token Address Claim
    function setTokenAddressClaim(uint256 time_) public onlyOwner {
        startTime = time_;
    }

    uint256 percent_sum = 0;

    function raising_claim(uint256 percent) public onlyOwner returns (bool) {
        require(percent_sum + percent <= 100, "Excess percent");

        __isClaimStart = true;

        for (uint256 i = 0; i < count_address; i++) {
            address temp = adrsBuyer[i];

            if (buyer[temp].paid > 0) {
                buyer[temp].remaining_claim += ((percent *
                    buyer[temp].tokensBought) / 100);
            }
        }

        percent_sum += percent;

        return true;
    }

    function viewRemainingClaim() public view returns (uint256) {
        return buyer[msg.sender].remaining_claim;
    }

    function claim() public notContract nonReentrant returns (bool) {
        require(__isClaimStart == true, "Claim not started");

        require(buyer[msg.sender].paid > 0, "Claim Wrong");

        require(buyer[msg.sender].remaining_claim > 0, "You have no claim");

        BEP20 token = BEP20(__tokenAddress);

        token.transfer(msg.sender, buyer[msg.sender].remaining_claim);

        buyer[msg.sender].sum_claimed += buyer[msg.sender].remaining_claim;

        buyer[msg.sender].remaining_claim = 0;

        return true;
    }

    // Update buyer Details

    function updateBuyerDetails(
        address adrs,
        uint256 _tokensBought,
        uint256 _paid,
        uint256 _remaining_claim,
        uint256 _sum_claimed,
        uint256[] memory _tokenBuy,
        uint256[] memory _buyTime
    ) public onlyOwner returns (bool) {
        buyer[adrs].is_change = true;

        buyer[adrs].tokensBought = _tokensBought;

        buyer[adrs].paid = _paid;
        buyer[adrs].sum_claimed = _sum_claimed;
        buyer[adrs].remaining_claim = _remaining_claim;

        for (uint256 j = 0; j < _tokenBuy.length; j++) {
            buyer[adrs].tokenAmount.push(_tokenBuy[j]);
            buyer[adrs].buyDate.push(_buyTime[j]);
        }

        return true;
    }

 

    function buyerDetails(address user)
        public
        view
        onlyOwner
        returns (Buyer memory)
    {
        return buyer[user];
    }

    // Owner Token Withdraw

    function withdrawToken(
        address tokenAddress,
        address to,
        uint256 amount
    ) public onlyOwner returns (bool) {
        BEP20 token = BEP20(tokenAddress);

        token.transfer(to, amount);

        return true;
    }

    // Owner BNB Withdraw
    function withdrawBNB(address payable to, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        to.transfer(amount);
        return true;
    }

    // Fallback
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}