// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract DuesPresale {
    IERC20 public constant BUSD =
        IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); // testnet
    // IERC20(); // localhost

    IERC20 public DUES = IERC20(0x65DEf77Ec221132021a5D89Ce9c695A9b73A7eA7); // mainnet    to be adjusted
    // IERC20(); // localhost

    address public owner;

    mapping(address => uint256) public user_deposits; // How much each user has deposited in to the presale contract

    uint256 public total_deposited;
    uint256 public minDepositPerPerson = 0 ether; //to be adjusted
    uint256 public maxDepositPerPerson = 20000 ether; //to be adjusted
    uint256 public maxDepositGlobal = 2000000 ether; //to be adjusted

    bool public enabled = false;
    bool public sale_finalized = false;

    // CUSTOM ERRORS

    error SaleIsNotActive();
    error MinimumNotReached();
    error IndividualMaximumExceeded();
    error GlobalMaximumExceeded();
    error ZeroAddress();
    error SaleIsNotFinalizedYet();
    error DidNotParticipate();

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        revert("Do not send tokens or BNB directly to the contract!");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the Owner!");
        _;
    }

    function getUserDeposits(address user) external view returns (uint256) {
        return user_deposits[user];
    }

    function getTotalRaised() external view returns (uint256) {
        return total_deposited;
    }

    function depositBUSD(uint256 _amount) external {
        /*if (!enabled || sale_finalized) revert SaleIsNotActive();

        if (_amount + user_deposits[msg.sender] < minDepositPerPerson)
            revert MinimumNotReached();

        if (_amount + user_deposits[msg.sender] > maxDepositPerPerson)
            revert IndividualMaximumExceeded();

        if (_amount + total_deposited > maxDepositGlobal)
            revert GlobalMaximumExceeded();
        */
        user_deposits[msg.sender] += _amount;
        total_deposited += _amount;

        BUSD.transferFrom(msg.sender, address(this), _amount);
    }

    function withdrawDUES() external {
        if (!sale_finalized) revert SaleIsNotFinalizedYet();

        uint256 total_to_send = (user_deposits[msg.sender] / 100);

        if (total_to_send == 0) revert DidNotParticipate();

        user_deposits[msg.sender] = 0;

        DUES.transfer(msg.sender, total_to_send);
    }

    function setEnabled(bool _enabled) external onlyOwner {
        enabled = _enabled;
    }

    function finalizeSale() external onlyOwner {
        sale_finalized = true;
    }

    function withdrawPresaleFunds(address _address) external onlyOwner {
        if (_address == address(0)) revert ZeroAddress();

        BUSD.transfer(_address, BUSD.balanceOf(address(this)));
    }

    function changeOwner(address _address) external onlyOwner {
        if (_address == address(0)) revert ZeroAddress();
        owner = _address;
    }

    function setDuesAddress(IERC20 _dues) public onlyOwner {
        DUES = _dues;
    }

    function getDuesAddress() public view returns (address) {
        return address(DUES);
    }
}