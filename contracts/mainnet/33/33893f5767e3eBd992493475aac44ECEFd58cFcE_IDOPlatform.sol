//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC20.sol";
import "./Ownable.sol";

    struct CommissionRecord {
        uint totalCommission;
        uint totalInvitees;
    }

    error ZeroBalance();
    error InvalidPercent();

contract IDOPlatform is Ownable {

    IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    address constant defaultCommisonAddress = 0xEE0f26Aaabf15aFc10DF94EDA481C8C3CA1ccaD8;
    uint constant commisonBase = 100;

    uint public commisonPercent = 20;
    address[] public depositAddresses;
    mapping(address => CommissionRecord) public commissionRecord;
    mapping(address => uint) public depositRecord;

    event Deposit(address indexed caller, address indexed referral, uint indexed amount);
    event CommisonSend(address indexed referral, uint indexed amount);

    function deposit(address referral, uint amount) external {
        if(referral == address(0) || depositRecord[referral] == 0 || tx.origin == referral) {
            referral = defaultCommisonAddress;
        }

        if(depositRecord[msg.sender] == 0) {
            depositAddresses.push(msg.sender);
        }

        depositRecord[msg.sender] += amount;
        USDT.transferFrom(msg.sender, address(this), amount);

        commisonSend(referral, amount);

        emit Deposit(msg.sender, referral, amount);
    }

    function commisonSend(address commisonAddress, uint depositAmount) internal {
        uint commision = depositAmount * commisonPercent / commisonBase;
        commissionRecord[commisonAddress].totalCommission += commision;
        commissionRecord[commisonAddress].totalInvitees++;

        USDT.transfer(commisonAddress, commision);

        emit CommisonSend(commisonAddress, commision);
    }

    function fixCommisonPercent(uint _commisonPercent) external onlyOwner {
        if(_commisonPercent >= 100)
            revert InvalidPercent();

        commisonPercent = _commisonPercent;
    }

    function withdrawFunds() external onlyOwner {
        uint balance = USDT.balanceOf(address(this));
        if(balance == 0)
            revert ZeroBalance();

        USDT.transfer(owner, balance);
    }

}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);

    // ======================================================
    //                        OPTIONAL                       
    // ======================================================
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Ownable {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "invalid address");
        require(_newOwner != owner, "same address");
        owner = _newOwner;
    }

}