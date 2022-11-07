/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

error NotReceiver();
error NotOwner();
error NotActive();
error NotStart();
error HasEnded();

/**
 * @title ERC20
 * @dev Interface for ERC20 tokens
 */
interface ERC20 {
    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

/**
 * @title CrowdfundingFactory
 * @dev Deployer for Crowdfunding contract
 */
contract CrowdfundingFactory {
    address public receiver;
    address public owner;
    address public payment;
    address[] public deployedContracts;

    constructor(address _payment) {
        owner = msg.sender;
        payment = _payment;
    }

    function createContract(uint256 _start, uint256 _ended) public onlyOwner {
        address newContract = address(
            new Crowdfunding(owner, payment, _start, _ended)
        );
        deployedContracts.push(newContract);
    }

    function transferOwnership(address _receiver) public onlyOwner {
        receiver = _receiver;
    }

    function updateOwner() public onlyReceiver {
        owner = receiver;
        receiver = address(0);
    }

    function updatePayment(address _payment) public onlyOwner {
        payment = _payment;
    }

    function getDeployedContractsLength() public view returns (uint256) {
        return deployedContracts.length;
    }

    modifier onlyReceiver() {
        if (msg.sender != receiver) {
            revert NotReceiver();
        }
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }
}

/**
 * @title Crowdfunding
 * @dev Fundraising contract for crypto projects, payment token will be specified by owner on constructor
 */
contract Crowdfunding {
    ERC20 public payment;
    bool public isActive = true;
    address public immutable factory;
    address public immutable owner;
    uint256 public immutable start;
    uint256 public immutable ended;
    uint256 public fundraised;
    address[] public participants;
    mapping(address => uint256) public allocations;

    constructor(
        address _payment,
        address _owner,
        uint256 _start,
        uint256 _ended
    ) {
        payment = ERC20(_payment);
        owner = _owner;
        start = _start;
        ended = _ended;
        factory = msg.sender;
    }

    function deposit(uint256 _amount) public onlyActive isStart isEnded {
        payment.transferFrom(msg.sender, address(this), _amount);
        if (allocations[msg.sender] == 0) participants.push(msg.sender);
        allocations[msg.sender] += _amount;
        fundraised += _amount;
    }

    function withdraw() public onlyOwner {
        uint256 balance = payment.balanceOf(address(this));
        payment.transfer(owner, balance);
    }

    function togglePause() public onlyOwner {
        isActive = !isActive;
    }

    function getParticipantsLength() public view returns (uint256) {
        return participants.length;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    modifier onlyActive() {
        if (!isActive) {
            revert NotActive();
        }
        _;
    }

    modifier isStart() {
        if (block.timestamp < start) {
            revert NotStart();
        }
        _;
    }

    modifier isEnded() {
        if (block.timestamp > ended) {
            revert HasEnded();
        }
        _;
    }
}