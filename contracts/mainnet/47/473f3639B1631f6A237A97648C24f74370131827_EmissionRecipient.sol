//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";

contract EmissionRecipient is Ownable {

    address public ePTX = 0x1Ba1f63b773511b704082C5bf19C1b58775c56e5;

    address public PTX = 0x2b5ae797Ec415ccBCd22310B1047c1A4c938b13a;

    uint256 public dailyReturn = 614583333 * 10**3; // 0.000000614583333% per block;

    uint256 public lastReward;

    constructor() {
        lastReward = block.number;
    }

    function resetRewards() external onlyOwner {
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

    function trigger() external {

        // amount to reward
        uint amount = amountToDistribute();

        // reset timer
        lastReward = block.number;

        // give reward
        uint bal = IERC20(PTX).balanceOf(address(this));
        if (amount > bal) {
            amount = bal;
        }
        if (amount == 0) {
            return;
        }

        // give reward to vault
        IERC20(PTX).transfer(ePTX, amount);
    }

    function amountInEPTX() public view returns (uint256) {
        return IERC20(PTX).balanceOf(ePTX);
    }

    function timeSince() public view returns (uint256) {
        return lastReward < block.number ? block.number - lastReward : 0;
    }

    function amountToDistribute() public view returns (uint256) {
        uint bal = amountInEPTX();
        uint qtyPerBlock = ( bal * dailyReturn ) / 10**18;
        return qtyPerBlock * timeSince();
    }
}