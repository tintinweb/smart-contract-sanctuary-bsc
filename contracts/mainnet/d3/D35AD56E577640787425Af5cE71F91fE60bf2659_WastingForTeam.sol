// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract WastingForTeam {

    IBEP20 public tokenContract;  // the token being sold
    address public owner; // owner (ceo Narfex)
    uint256 public percantageUnlock; // point in time for unlock

    event ClaimNRFX(address owner, uint256 amount);

    constructor (
        IBEP20  tokenContract_, 
        address owner_
        ) {
        tokenContract = tokenContract_;
        owner = owner_;
        percantageUnlock = block.timestamp;
    }

    /// @notice this function withdrawal every half of year 10% of Narffex tokens from all suuply for team
    function claimNRFX() public {
        require(msg.sender == owner, "Not owner");
        require(block.timestamp - percantageUnlock >= 183 days, "Wait half an year");
        
        percantageUnlock += 183 days;
        uint256 _amount = tokenContract.balanceOf(address(this)) * 10 / 100;
        tokenContract.transfer(owner, _amount);

        emit ClaimNRFX(owner, _amount);
    }

}