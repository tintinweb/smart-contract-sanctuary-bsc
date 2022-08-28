/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

// import "hardhat/console.sol";

interface IErc20Contract { // External ERC20 contract
    function transfer(address recipient, uint amount) external returns (bool);
    function balanceOf(address tokenOwner) external view returns (uint256);
}

contract PrivateSaleVesting {
    address public _admin;  // Admin address
    IErc20Contract public _erc20Contract;   // External ERC20 contract

    uint public _dateFrom;  // Start date
    uint public _dayToPay;  // How many days start from dateFrom to dateTo
    uint public  sum;
    mapping(address => uint) public _recipientAddressTotalAmount;   // Total amount of a recipient address
    mapping(address => uint) public _recipientAddressLeftAmount;    // Left amount of a recipient address
    mapping(address => uint) public _dailyAddressIndex;

    bool public _hasAddressNotYetConfirmed = true; // Has address not yet confirmed? Default = true

    constructor(
        uint dateFrom,
        uint dateTo,
        address erc20Contract
    ) {
        require(dateTo >= dateFrom, "Date to must be greater or equal to date from");
        require(erc20Contract != address(0), "Zero address");
        _admin = msg.sender;
        _dateFrom = dateFrom;
        _dayToPay = (dateTo - dateFrom) / 86400 + 1;
        _erc20Contract = IErc20Contract(erc20Contract);
    }

    // Modifier
    modifier onlyAdmin() {
        require(_admin == msg.sender);
        _;
    }

    // Set the recipient addresses and amounts
    function setRecipientAddressesAmounts(address[] calldata recipientAddressArr, uint[] calldata amountArr) external onlyAdmin {
        require(_hasAddressNotYetConfirmed,
            "Unable to set recipient address amounts as all addresses have already been confirmed");
        require(recipientAddressArr.length == amountArr.length, "The size of recipient address array must be same as amount array");
        for (uint i = 0; i < recipientAddressArr.length; i++) {
            require(recipientAddressArr[i] != address(0), "Zero address");
            require(amountArr[i] > 0, "Amount cannot be 0");
            require(!_isContract(recipientAddressArr[i]), "Contracts are not allowed");
            _recipientAddressTotalAmount[recipientAddressArr[i]] = amountArr[i];
            _recipientAddressLeftAmount[recipientAddressArr[i]] = amountArr[i];
            sum = sum + amountArr[i];
        }
    }

    // Confirm the address and transfer ownership to this contract
    // Once confirmed, no more address is allowed to be added
    function confirmAddressAndTransferOwnership() external onlyAdmin {
        require(_hasAddressNotYetConfirmed, "All addresses have already been confirmed");
        _admin = address(this);
        _hasAddressNotYetConfirmed = false;
    }

    // Daily transfer
    function dailyTransfer() external {
        // console.log('***');
        require(!_hasAddressNotYetConfirmed, "Unable to perform daily transfer as the address has not yet been confirmed");
        require(block.timestamp >= _dateFrom, "Unable to perform daily transfer as current time is less than date from");
        uint amountLeft = _recipientAddressLeftAmount[msg.sender];
        require (amountLeft > 0, "All amount was paid");
        uint dailyAmount = _recipientAddressTotalAmount[msg.sender] / _dayToPay;
        // console.log("dailyAmount = %s", dailyAmount);
        uint maxDayToPay = amountLeft / dailyAmount; // number of days that may be paid with dailyDistribution amount
        // console.log("maxDayToPay = %s", maxDayToPay);
        uint day = (block.timestamp - _dateFrom) / 86400 + 1;     // number of days to pay
        // console.log("day = %s", day);
        if(day > _dayToPay) day = _dayToPay;
        uint unpaidDays = day - _dailyAddressIndex[msg.sender];   // number of days to pay - already paid days
        if (unpaidDays > maxDayToPay + 1) unpaidDays = maxDayToPay + 1;
        uint amount = unpaidDays * dailyAmount;  // total amount to pay for passed days
        if (amount > 0) {
            bool canTransfer = _transfer(msg.sender, amount);
            if(canTransfer) {
                _dailyAddressIndex[msg.sender] = day;    // store last paid day
            }
        }
    }

    function _transfer(address recipient, uint amount) private returns (bool){
        // There is no validation on input parameters as this is a private function
        _recipientAddressLeftAmount[recipient] = _recipientAddressLeftAmount[recipient] - amount;
        return _erc20Contract.transfer(recipient, amount);
    }

    // Check if the address is a contract
    function _isContract(address addr) internal view returns (bool) { uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    // Reject all direct deposit to this contract
    receive() external payable {
        revert();
    }
}