//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IToken {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
}

contract EmissionRecipient {

    address public ePTX = 0x1AF84149ADf4F5F85886E0C0247fCB4bBe11ac04;

    address public PTX = 0x988ce53ca8d210430d4a9af0DF4b7dD107A50Db6;

    uint256 public dailyReturn = 614583333 * 10**3; // 0.000000614583333% per block;

    uint256 public lastReward;

    uint256 public bountyPercent = 8;
    uint256 private constant bountyDenom = 10_000;

    mapping ( address => bool ) public noBounty;

    modifier onlyOwner() {
        require(
            msg.sender == IToken(PTX).getOwner(),
            'Only Owner'
        );
        _;
    }

    constructor() {
        lastReward = block.number;
        noBounty[0x988ce53ca8d210430d4a9af0DF4b7dD107A50Db6] = true;
        noBounty[0xfbf458f90291534390FAe3F0DA404EeBc17392Db] = true;
        noBounty[0x36905ee68Cd5dF14a2c93Ec3c0511b42C5C7ce37] = true;
    }

    function resetEmissions() external onlyOwner {
        lastReward = block.number;
    }

    function setEPTX(address newEPTX) external onlyOwner {
        require(newEPTX != address(0), 'Zero Address');
        ePTX = newEPTX;
    }

    function setPTX(address newPTX) external onlyOwner {
        require(newPTX != address(0), 'Zero Address');
        PTX = newPTX;
    }

    function setDailyReturn(uint newDaily) external onlyOwner {
        dailyReturn = newDaily;
    }

    function decreaseByTenPercent() external onlyOwner {
        dailyReturn -= dailyReturn / 10;
    }

    function withdraw(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function withdrawAmount(address token, uint amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    function burnRemainder() external onlyOwner {
        uint amount = amountToDistribute();
        uint bal = IERC20(PTX).balanceOf(address(this));
        if (amount >= bal) {
            return;
        }
        IToken(PTX).burn(bal - amount);
    }

    function setBountyPercent(uint newPercent) external onlyOwner {
        require(newPercent <= bountyDenom / 3, 'Bounty Too High');
        bountyPercent = newPercent;
    }

    function setNoBounty(address account, bool noBounty_) external onlyOwner {
        noBounty[account] = noBounty_;
    }

    function trigger() external {

        // amount to reward
        uint amount = amountToDistribute();
        uint bounty = 0;

        if (!noBounty[msg.sender]) {
            bounty = ( amount * bountyPercent ) / bountyDenom;
        }

        // reset timer
        lastReward = block.number;

        // send reward to the vault
        _send(ePTX, amount);

        // send bounty if applicable
        if (bounty > 0) {
            _send(msg.sender, bounty);
        }
    }

    function amountInEPTX() public view returns (uint256) {
        return IERC20(PTX).balanceOf(ePTX);
    }

    function timeSince() public view returns (uint256) {
        return lastReward < block.number ? block.number - lastReward : 0;
    }

    function qtyPerBlock() public view returns (uint256) {
        return ( amountInEPTX() * dailyReturn ) / 10**18;
    }

    function amountToDistribute() public view returns (uint256) {
        return qtyPerBlock() * timeSince();
    }

    function currentBounty() public view returns (uint256) {
        return ( amountToDistribute() * bountyPercent ) / bountyDenom;
    }

    function _send(address to, uint amount) internal {
        uint bal = IERC20(PTX).balanceOf(address(this));
        if (amount > bal) {
            amount = bal;
        }
        if (amount == 0) {
            return;
        }
        IERC20(PTX).transfer(to, amount); 
    }
}