/**
 * @title STABLE MINTER
 * @dev STABLE_MINTER contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

import "./SafeERC20.sol";
import "./ISTABLE.sol";
import "./Pausable.sol";
import "./IStabilityCheck.sol";
import "./ReentrancyGuard.sol";

pragma solidity 0.6.12;

contract STABLE_MINTER is Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IStabilityCheck public stabilityCheck;

    address[] public receiver;
    uint256[] public percent;
    address[] public receiverPanic;
    uint256[] public percentPanic;

    address public Token = 0xE7Df6907120684add86f686E103282Ee5CD17b02;

    // Statistic
    uint256 public createdTokens;
    uint256 public miningPerSecond = 1157407407407410; // 100 Tokens per 24h
    uint256 public lastTriggerTime;

    constructor() public {
        lastTriggerTime = block.timestamp;
    }

    // Create new STABLE Tokens.
    function createNewUSDFI() public whenNotPaused {
        _mintTokens();
    }

    // Pre-Check the sender has enough tokens and has given enough permission.
    function checkTime() public view returns (uint256) {
        return block.timestamp.sub(lastTriggerTime);
    }

    // Pre-Check how many tokens can be created.
    function checkMining() public view returns (uint256) {
        return checkTime().mul(miningPerSecond);
    }

    // Send Tokens from msg.Sender to receiver Address.
    function setLastTriggerTimeToNow() public onlyOwner {
        lastTriggerTime = block.timestamp;
    }

    // Mint new USDFI Tokens to receiver.
    function _mintTokens() internal nonReentrant {
        if (lastTriggerTime < block.timestamp.add(600)) {
            if (stabilityCheck.isStabilityOK() == true) {
                uint256 i = 0;
                while (i < receiver.length) {
                    uint256 bal = checkMining().div(10000).mul(percent[i]);
                    createdTokens = createdTokens.add(bal);
                    STABLE(Token).mint(receiver[i], bal);
                    i += 1;
                }
            } else {
                uint256 i = 0;
                while (i < receiverPanic.length) {
                    uint256 bal = checkMining().div(10000).mul(percentPanic[i]);
                    createdTokens = createdTokens.add(bal);
                    STABLE(Token).mint(receiverPanic[i], bal);
                    i += 1;
                }
            }
            lastTriggerTime = block.timestamp;
        }
    }

    // Set the new Token per Second rate.
    function setMiningPerSecond(uint256 _miningPerSecond) external onlyOwner {
        require(
            _miningPerSecond < 1157407407407410,
            "must be smaller than the start value"
        );
        miningPerSecond = _miningPerSecond;
    }

    // Set the Addresses who receives the new Coins in Regular Mode.
    function setReceiverRegular(address[] memory _receiverAddress)
        external
        onlyOwner
    {
        receiver = _receiverAddress;
    }

    // Set the Addresses who receives the new Coins in Panic Mode.
    function setReceiverPanic(address[] memory _receiverAddress)
        external
        onlyOwner
    {
        receiverPanic = _receiverAddress;
    }

    // Set the percentage of who receives the new Coins in Regular Mode.
    function setPercentRegular(uint256[] memory _percent) external onlyOwner {
        uint256 i = 0;
        uint256 requestedPercent = 0;
        while (i < _percent.length) {
            requestedPercent = requestedPercent.add(_percent[i]);
            i += 1;
        }

        require(requestedPercent == 10000, "must be 100%");
        percent = _percent;
    }

    // Set the percentage of who receives the new Coins in Panic Mode.
    function setPercentPanic(uint256[] memory _percent) external onlyOwner {
        uint256 i = 0;
        uint256 requestedPercent = 0;
        while (i < _percent.length) {
            requestedPercent = requestedPercent.add(_percent[i]);
            i += 1;
        }

        require(requestedPercent == 10000, "must be 100%");
        percentPanic = _percent;
    }

    // Update the Stability Check Contract.
    function UpdateStableCheckContract(address _stableCheckContract)
        public
        onlyOwner
    {
        stabilityCheck = IStabilityCheck(_stableCheckContract);
    }
}