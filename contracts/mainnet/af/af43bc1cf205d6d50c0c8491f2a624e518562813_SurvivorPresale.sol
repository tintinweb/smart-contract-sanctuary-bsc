/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: Unlicensed

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

contract SurvivorPresale {
    IERC20 public constant BUSD =
        IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // mainnet
    // IERC20(0xF2F8bAe892812ddbBcb4FF6b7085618450e321ca); // localhost

    IERC20 public constant HP =
        IERC20(0x79EEe7769c731bCF5f215B0C1E14f4a52be00D52); // mainnet
    // IERC20(0xAf43BC1CF205D6d50c0C8491f2a624E518562813); // localhost

    address public owner;

    mapping(address => uint256) public user_deposits; // How much each user has deposited in to the presale contract
    mapping(address => uint256) public user_promo_tokens; // Tokens earned via contests and other marketing before presale

    mapping(string => uint256) public referralTotals; // How much was purchased under each referral code

    uint256 public startTime;
    uint256 public endTime;
    uint256 public total_deposited;
    uint256 public minDepositPerPerson = 20 ether;
    uint256 public maxDepositPerPerson = 20000 ether;
    uint256 public maxDepositGlobal = 2000000 ether;

    bool public enabled = true;
    bool public sale_finalized = false;

    // CUSTOM ERRORS

    error SaleIsNotActive();
    error MinimumNotReached();
    error IndividualMaximumExceeded();
    error GlobalMaximumExceeded();
    error ZeroAddress();
    error SaleIsNotFinalizedYet();
    error DidNotParticipate();

    constructor(uint256 _startTime) {
        startTime = _startTime;
        endTime = startTime + 2 days;
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

    function depositBUSD(uint256 _amount, string memory _referer) external {
        if (
            !enabled ||
            sale_finalized ||
            block.timestamp < startTime ||
            block.timestamp >= endTime
        ) revert SaleIsNotActive();

        if (_amount + user_deposits[msg.sender] < minDepositPerPerson)
            revert MinimumNotReached();

        if (_amount + user_deposits[msg.sender] > maxDepositPerPerson)
            revert IndividualMaximumExceeded();

        if (_amount + total_deposited > maxDepositGlobal)
            revert GlobalMaximumExceeded();

        user_deposits[msg.sender] += _amount;
        total_deposited += _amount;
        referralTotals[_referer] += _amount;

        BUSD.transferFrom(msg.sender, address(this), _amount);
    }

    function withdrawHP() external {
        if (!sale_finalized) revert SaleIsNotFinalizedYet();

        uint256 total_to_send = user_promo_tokens[msg.sender] +
            ((user_deposits[msg.sender] * 327500) / 2000000);

        if (total_to_send == 0) revert DidNotParticipate();

        user_deposits[msg.sender] = 0;
        user_promo_tokens[msg.sender] = 0;

        HP.transfer(msg.sender, total_to_send);
    }

    function setStart(uint256 _time) external onlyOwner {
        startTime = _time;
    }

    function setEnd(uint256 _time) external onlyOwner {
        endTime = _time;
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

    function addPromoTokens(address _address, uint256 _amount)
        external
        onlyOwner
    {
        if (_address == address(0)) revert ZeroAddress();
        user_promo_tokens[_address] += _amount;
    }
}