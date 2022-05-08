//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./IERC20.sol";

interface IToken {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
}

contract TaxReceiver {

    // Token
    address public immutable token;

    // Recipients Of Fees
    address public ops;

    /**
        Minimum Amount Of Tokens In Contract To Trigger `trigger` Unless `approved`
            If Set To A Very High Number, Only Approved May Call Trigger Function
            If Set To A Very Low Number, Anybody May Call At Their Leasure
     */
    uint256 public minimumTokensRequiredToTrigger;

    // Allocation Percentage
    uint256 public opsPercentage;

    // Address => Can Call Trigger
    mapping ( address => bool ) public approved;

    // Events
    event Approved(address caller, bool isApproved);

    modifier onlyOwner(){
        require(
            msg.sender == IToken(token).getOwner(),
            'Only Token Owner'
        );
        _;
    }

    constructor(address token_, address ops_) {
        require(
            token_ != address(0) &&
            ops_ != address(0),
            'Zero Address'
        );

        // Initialize Addresses
        token = token_;
        ops = ops_;

        // set initial approved
        approved[msg.sender] = true;

        // ops percentage
        opsPercentage = 75;
    }

    function trigger() external {

        // Token Balance In Contract
        uint balance = IERC20(token).balanceOf(address(this));

        if (balance < minimumTokensRequiredToTrigger && !approved[msg.sender]) {
            return;
        }

        if (balance > 0) {
            // fraction out tokens received
            uint part1 = balance * opsPercentage / 100;
            uint part2 = balance - part1;

            // send to destinations
            if (part1 > 0) {
                IERC20(token).transfer(ops, part1);
            }
            if (part2 > 0) {
                IToken(token).burn(part2);
            }
        }
    }

    function setOps(address opsAddr) external onlyOwner {
        require(opsAddr != address(0));
        ops = opsAddr;
    }
    function setOpsPercentage(uint256 newPercent) external onlyOwner {
        opsPercentage = newPercent;
    }

    function setApproved(address caller, bool isApproved) external onlyOwner {
        approved[caller] = isApproved;
        emit Approved(caller, isApproved);
    }
    function setMinTriggerAmount(uint256 minTriggerAmount) external onlyOwner {
        minimumTokensRequiredToTrigger = minTriggerAmount;
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }
    function withdraw(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }
}