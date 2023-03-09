// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./preEVCToken.sol";

contract preEVCDream is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    // Burn address
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    preEVCToken public immutable preevcToken;
    IERC20 public immutable EVCToken;

    address evcAddress;

    bool hasBurnedUnsoldPresale;

    uint256 public startBlock;

    event preEVCToEVC(address sender, uint256 amount);
    event burnUnclaimedEVC(uint256 amount);
    event startBlockChanged(uint256 newStartBlock);

    constructor(uint256 _startBlock, address _preevcAddress, address _evcAddress) {
        require(_preevcAddress != _evcAddress, "preevc cannot be equal to evc");
        startBlock = _startBlock;
        preevcToken = preEVCToken(_preevcAddress);
        EVCToken = IERC20(_evcAddress);
    }

    function swappreEVCForEVC() external nonReentrant {
        require(block.number >= startBlock, "preevc still awake.");
        uint256 swapAmount = preevcToken.balanceOf(msg.sender);
        require(EVCToken.balanceOf(address(this)) >= swapAmount, "Not Enough tokens in contract for swap");
        require(preevcToken.transferFrom(msg.sender, BURN_ADDRESS, swapAmount), "failed sending preevc");
        EVCToken.safeTransfer(msg.sender, swapAmount);
        emit preEVCToEVC(msg.sender, swapAmount);
    }

    function sendUnclaimedEVCToDeadAddress() external onlyOwner {
        require(block.number > preevcToken.endBlock(), "can only send excess preevc to dead address after presale has ended");
        require(!hasBurnedUnsoldPresale, "can only burn unsold presale once!");
        require(preevcToken.preevcRemaining() <= EVCToken.balanceOf(address(this)), "burning too much evc, check again please");
        if (preevcToken.preevcRemaining() > 0)
            EVCToken.safeTransfer(BURN_ADDRESS, preevcToken.preevcRemaining());
        hasBurnedUnsoldPresale = true;
        emit burnUnclaimedEVC(preevcToken.preevcRemaining());
    }

    function setStartBlock(uint256 _newStartBlock) external onlyOwner {
        require(block.number < startBlock, "cannot change start block if presale has already commenced");
        require(block.number < _newStartBlock, "cannot set start block in the past");
        startBlock = _newStartBlock;
        emit startBlockChanged(_newStartBlock);
    }

}