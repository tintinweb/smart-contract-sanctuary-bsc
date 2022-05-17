/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// File: contracts/LoanUtil.sol

pragma solidity ^0.5.0;

/**
 * @title LoanUtil
 * @dev Just create out of learning and experimenting how library can be linked and used in contract.
 */
library LoanUtil {

    /**
     * @notice Simple random ID generator to for loan ID.
     * @dev Not unique proof as it is for project demonstration only.
     * @param addr1 borrower address
     * @param addr2 owner address
     * @return generated integer value
     */
    function generateId(address addr1, address addr2) internal view returns(bytes32) {
        uint256 generatedId = uint256(addr1) - uint256(addr2) + now;
        return bytes32(generatedId);
    }
}
// File: contracts/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Authorized for owner only");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// File: contracts/Loan1.sol

pragma solidity ^0.5.0;



/**
 * @title Loan based contract
 * @notice This is an abstract contract should be derived be purpose loan contract.
 * It provides the basic storage for borrower, lender, and loan information.
 */
contract Loan is Ownable {
    
    // Custom type decalration
    enum Status { Requesting, Funding, Funded, FundWithdrawn, Repaid, Defaulted, Refunded, Cancelled, Closed }

    struct Lender {
        address payable account;
        uint lendingAmount;
        uint repaidAmount;
        uint refundedAmount;
    }

    // state variables
    bytes32 _id;
    address _borrower;
    uint _loanAmount;
    uint _ownedAmount;
    uint _lenderCount;
    uint _creationTime = now;
    uint _fullyFundedTime;
    uint _repaidTime;
    Status internal _status;

    // use for circuit breaker
    bool internal _stopped;

    mapping(address => Lender) internal _lenders;
    mapping(uint => address) internal _lenderAddr;

    /// events for loan lifecycle
    event Requesting(bytes32 indexed loanId, address indexed borrower, address owner);
    event Funding(bytes32 indexed loanId, address indexed lender, uint amount);
    event Funded(bytes32 indexed loanId, uint amount);
    event FundWithdrawn(bytes32 indexed loanId, uint amount);
    event Repaid(bytes32 indexed loanId, uint amount);
    event Defaulted(bytes32 indexed loanId, address indexed borrower, uint defaultedAmt, uint loanAmt);
    event Refunded(bytes32 indexed loanId, address indexed lender, uint amount);
    event Cancelled(bytes32 indexed loanId);
    event Stopped(bytes32 indexed loanId);
    event Resumed(bytes32 indexed loanId);
    event Closed(bytes32 indexed loanId);

    /// internal constructor to make abstract contract.
    constructor() internal { }

    /// modifiers to check loan in the required status.
    modifier isFunding { 
        require(_status == Status.Funding, "Required Status: Funding"); 
        _; 
    }
    
    modifier isFunded { 
        require(_status == Status.Funded, "Required Status: Funded"); 
        _; 
    }
    
    modifier isWithdrawn { 
        require(_status == Status.FundWithdrawn, "Required Status: Withdraw"); 
        _; 
    }
    
    modifier isRepaid { 
        require(_status == Status.Repaid, "Required Status: Repaid"); 
        _; 
    }

    modifier isDefaulted { 
        require(_status == Status.Defaulted, "Required Status: Defaulted"); 
        _; 
    }
    
    modifier isRefunded { 
        require(_status == Status.Refunded, "Required Status: Refunded"); 
        _; 
    }
    
    modifier isCancelled { 
        require(_status == Status.Cancelled, "Required Status: Cancelled"); 
        _; 
    }
    
    modifier isNotStopped { 
        require(_stopped != true, "The state of the contract is stopped by the owner, no operations allow at this time."); 
        _; 
    }
    
    /// Public abtract core loan functions.

    /**
     * @notice Setup the loan amount and borrower
     * @param borrower borrower's address
     * @param amount requested loan amount
     */
    function request(address borrower, uint amount) public;

    /**
     * @notice Lender deposit fund for the loan.
     */
    function depositFund() public payable;

    /**
     * @notice refund the deposited fund to the lender
     */
    function refund() public payable;
    
    /**
     * @notice Withdrawing the fund deposited by the lender to borrower account.
     */
    function withdrawToBorrower() public payable;

    /**
     * @notice borrower repay the loan amount to the contract address
     */
    function repay() public payable;

    /**
     * @notice Widthdraw fund from contract balance back to lender according to the loan amount
     */
    function withdrawToLenders() public payable;
    
    /**
     * @notice default the loan
     */
    function toDefault() public;
    
    /**
     * @notice to cancel the loan
     */
    function cancel() public;

    /**
     * @notice Put the contract in suspend state in the even or ermegency
     * @dev only owner can execute this function.
     */
    function stop() public onlyOwner {
        _stopped = true;
        emit Stopped(_id);
    }

    /**
     * @notice Take the contract out of suspend state.
     * @dev only only can execute this function
     */
    function resume() public onlyOwner {
        _stopped = false;
        emit Resumed(_id);
    }

    // Public property getters

    /**
     * @dev getter function for loan id
     * @return loan ID in string
     */
    function id() public view returns(bytes32) {
        return _id;
    }

    /**
     * @dev helper function to get lender by its address
     * @param addr lender address
     * @return lender's address, lending amount, and repaid amount in tuples.
     */
    function lenderBy(address addr) 
        public 
        view 
        returns(
            address p_lender, 
            uint p_lendingAmount, 
            uint p_repaidAmount, 
            uint p_refundedAmount) 
    {
        if (addr == address(0)) {
            return (address(0), 0, 0, 0);
        } else {
            Lender memory l = _lenders[addr];
            return (l.account, l.lendingAmount, l.repaidAmount, l.refundedAmount);
        }
    }

    /**
     * @dev helper function to get lender address by index
     * @param idx position index
     * @return lender address
     */
    function lenderAddressAt(uint idx) public view returns(address) {
        return _lenderAddr[idx];
    }

    /**
     * @dev helper function to get lender from the mapping
     * @param idx the index position in lender address mapping
     * @return a lender info in tuples
     */
    function lenderAt(uint idx) 
        public 
        view 
        returns( 
            address p_lender, 
            uint p_lendingAmount, 
            uint p_repaidAmount, 
            uint p_refundedAmount) 
    {
        return lenderBy(lenderAddressAt(idx));
    }

    /**
     * @dev getter for contract's balance
     * @return current balance of the contract
     */
    function balance() public view returns(uint) {
        return address(this).balance;
    }

    /**
     * @dev getter for status
     * @return current status according to the loan lifecycle
     */
    function status() public view returns(Status) {
        return _status;
    }

    /**
     * @dev getter for loan amount
     * @return the loan amount requested by the borrower
     */
    function loanAmount() public view returns(uint) {
        return _loanAmount;
    }

    /**
     * @dev getter for owned amount
     * @return the amount withdraw by the borrower
     */
    function ownedAmount() public view returns(uint) {
        return _ownedAmount;
    }

    /**
     * @dev getter for borrower
     * @return borrower address.
     */
    function borrower() public view returns(address) {
        return _borrower;
    }

    /**
     * @dev getter for lender counter
     * @return number of lenders for this contract
     */
    function lenderCount() public view returns(uint) {
        return _lenderCount;
    }

    /**
     * @dev a web helper function get loan properties in one function 
     * instead of calling multiple getter function where the code is now readable.
     * @return tuple with loan property values.
     */
    function info() 
        public 
        view 
        returns(
            bytes32 p_id, 
            Status p_status, 
            uint p_balance, 
            uint p_loanAmount, 
            uint p_ownedAmount, 
            address p_borrower, 
            address p_owner, 
            uint p_lenderCount)
    {
        p_id = id();
        p_status = status();
        p_balance = balance();
        p_loanAmount = loanAmount();
        p_ownedAmount = ownedAmount();
        p_borrower = borrower();
        p_owner = owner();
        p_lenderCount = lenderCount();
    }
}
// File: contracts/SimpleLoan.sol

pragma solidity ^0.5.0;



/**
 * @title Simple loan contract
 * @notice Simple loan contract inherit from the Loan contract that allows a borrower request loan that can be funded by 
 * several lenders. Lender will deposit ether to the contract account, once it matches the loan
 * amount requested by the borrower, the borrower can withdraw the fund to its account. Once ready, 
 * the borrower can repay the loan by deposit the money to the contract account. The lender can withdraw the 
 * fund back from the contract to their wallets account.
 * @dev The simple loan contract is to demonstrate basic deposit and withdrawal of ether between contracts and 
 * wallets
 */
contract SimpleLoan is Loan {
    
    /**
     * @dev Default constructor to setup the initial simple loan contract
     */
    constructor() public {
        _status = Status.Requesting;
        _id = LoanUtil.generateId(_borrower, owner());
        _creationTime = now;
    }

    // Modifier functions
    modifier onlyBorrowerOrOwner { 
        require(msg.sender == _borrower || msg.sender == owner(), "Authorized for borrower or owner only."); 
        _; 
    }
    
    modifier onlyBorrower { 
        require(msg.sender == _borrower, "Authorized for borrower only."); 
        _; 
    }

    modifier canRefund { 
        require(_status == Status.Funding || _status == Status.Funded, "Required Status: Funding or Funded"); 
        _; 
    }

    
    // Public functions

    /**
     * @notice Setup the loan request with the borrower address and the loan amount
     * @dev only the owner (or the loan broker in this case) can setup the borrowing info.
     */
    function request(address borrower, uint amount) public onlyOwner {
        require(borrower != address(0), "Address is empty");
        require(borrower != owner(), "Owner can't be borrower at the same time.");
        require(amount > 0, "0 is not a valid borrowing amount.");
        
        _borrower = borrower;
        _loanAmount = amount;
        _status = Status.Funding;
        emit Requesting(_id, _borrower, owner());
    }
    
    /**
     * @notice Deposit fund to the contract balance
     * @dev Anyone other than the owner and borrower in this case.
     */
    function depositFund() public payable isFunding isNotStopped {
        require(msg.value <= _loanAmount, "Lending amount is more the amount requested.");
        require(msg.value <= _loanAmount - _ownedAmount, "Lending amount is more than remaining fund needed.");
        require(_lenders[msg.sender].account == address(0), "Existing lender.");
        require(msg.sender != owner(), "Owner can't be a lender in the same contract.");
        require(msg.sender != _borrower, "Borrower can't be a lender in the same contract.");

        _lenders[msg.sender] = Lender({account: msg.sender, lendingAmount: msg.value, repaidAmount: 0, refundedAmount: 0});
        _lenderAddr[_lenderCount] = msg.sender;
        _lenderCount++;
        _ownedAmount += msg.value;
        emit Funding(_id, msg.sender, msg.value);

        /// set the status to funded when the fund reach the requested amount.
        if (balance() == _loanAmount) {
            _status = Status.Funded;
            _fullyFundedTime = now;
            emit Funded(_id, _loanAmount);
        }
    }

    /**
     * @notice Return the deposit fund to lender
     * @dev It can only refund when the borrower hasn't withdrawn the fund. Only owner (contract brodker) can
     * execute the refund.
     */
    function refund() public payable canRefund isNotStopped onlyOwner {
        require(_ownedAmount == balance(), "Balance is not enough to refund all lenders.");

        for(uint i = 0; i < _lenderCount; i++) {
            Lender memory lender = _lenders[_lenderAddr[i]];
            if (lender.account != address(0))
            {
                uint refundAmt = lender.lendingAmount;
                lender.refundedAmount = refundAmt;
                _lenders[_lenderAddr[i]] = lender;

                address refundAddr = lender.account;
                _ownedAmount -= refundAmt;

                lender.account.transfer(refundAmt);
                emit Refunded(_id, refundAddr, refundAmt);
            }
        }
        _status = Status.Refunded;
    }
    
    /**
     * @notice Withdrawing the fund deposited by the lender to borrower account.
     */
    function withdrawToBorrower() public payable isFunded isNotStopped onlyBorrower {
        require(balance() > 0, "The balance is 0 currently.");
        _status = Status.FundWithdrawn;
        msg.sender.transfer(balance());
        emit FundWithdrawn(_id, _ownedAmount);
    }

    /**
     * @notice borrower repay the loan amount to the contract address
     */
    function repay() public payable isWithdrawn isNotStopped onlyBorrower {
        require(msg.value == _ownedAmount, "Repaid amount not the same as amount owned.");
        _ownedAmount -= msg.value;
        _status = Status.Repaid;
        _repaidTime = now;
        emit Repaid(_id, msg.value);
    }

    /**
     * @notice Widthdraw fund from contract balance back to lender according to the loan amount
     */
    function withdrawToLenders() public payable isRepaid isNotStopped onlyOwner {
        require(_loanAmount == balance(), "Balance is not enough to refund all lenders.");
        for(uint i = 0; i < _lenderCount; i++) {
            Lender memory lender = _lenders[_lenderAddr[i]];
            if (lender.account != address(0))
            {
                lender.repaidAmount = lender.lendingAmount;
                _lenders[_lenderAddr[i]] = lender;
                lender.account.transfer(lender.repaidAmount);
            }
        }
        _status = Status.Closed;
        emit Closed(_id);
    }
    
    /**
     * @notice default the loan
     */
    function toDefault() public isWithdrawn isNotStopped onlyBorrowerOrOwner {
        _status = Status.Defaulted;
        emit Defaulted(_id, _borrower, _ownedAmount, _loanAmount);
    }
    
    /**
     * @notice to cancel the loan
     */
    function cancel() public isNotStopped onlyBorrowerOrOwner {
        require(_ownedAmount == 0, "Can't cancelled contract when fund is provided. Use refund function.");
        _status = Status.Cancelled;
        emit Cancelled(_id);
    }

}
// File: contracts/TimeSecuredLoan.sol

pragma solidity ^0.5.0;


/**
 * @title Time Secured Simple Loan
 * @notice Time secured loan inherit simple loan but with time protected modifier on the withdrawToBorrower
 * and withdrawToLenders so the fund can't transfer out from the contract account until the waiting period reached.
 * @dev This contract is created out of demonstrate one of the security best practices of writing solidty contract 
 * and also a different test cases is written specifically for it.
 */
contract TimeSecuredLoan is SimpleLoan {

    // Modifiers
    modifier onlyFullyFundedAfterOneDay { 
        require(onlyAfter(_fullyFundedTime + 1 days), "Authorized only after 1 day of fully funded"); 
        _; 
    
    }
    
    modifier onlyRepayAfterTwoDay { 
        require(_status == Status.Repaid, "Status should be in Repaid");
        require(onlyAfter(_repaidTime + 2 days), "Authorized only after 2 day of repay"); 
        _; 
    }

    modifier onlyCreatedAfterFiveDay { 
        require(onlyAfter(_creationTime + 5 days), "Authorized only after contract created 5 days"); 
        _; 
    }

    /**
     * @notice Setup the loan request with the borrower address and the loan amount
     * @dev only the owner (or the loan broker in this case) can setup the borrowing info.
     */
    function request(address borrower, uint amount) public {
        super.request(borrower, amount);
    }

    /**
     * @notice Deposit fund to the contract balance
     * @dev Anyone other than the owner and borrower in this case.
     */
    function depositFund() public payable {
        super.depositFund();
    }

    /**
     * @notice Return the deposit fund to lender
     * @dev It can only refund when the borrower hasn't withdrawn the fund. Only owner (contract brodker) can
     * execute the refund.
     */
    function refund() public payable {
        super.refund();
    }
    
    /**
     * @notice Withdrawing the fund deposited by the lender to borrower account.
     * @dev The withdraw only allow after 1 day of the loan is fully funded.
     */
    function withdrawToBorrower() public payable onlyFullyFundedAfterOneDay {
        super.withdrawToBorrower();
    }

    /**
     * @notice borrower repay the loan amount to the contract address
     */
    function repay() public payable {
        super.repay();
    }

    /**
     * @notice Widthdraw fund from contract balance back to lender according to the loan amount
     * @dev The withdraw only allow after 2 day of the loan is fully repaid.
     */
    function withdrawToLenders() public payable onlyRepayAfterTwoDay {
        super.withdrawToLenders();
    }
    
    /**
     * @notice default the loan
     */
    function toDefault() public onlyCreatedAfterFiveDay {
        super.toDefault();
    }
    
    /**
     * @notice to cancel the loan
     */
    function cancel() public {
        super.cancel();
    }

    /// Internal functions

    /**
     * @notice validate current time is greater or equal to given time.
     * @param _time  time in unix epock
     * @return true if now is greater or equal to given time
     */
    function onlyAfter(uint _time) internal view returns(bool) { 
        return now >= _time; 
    }
}