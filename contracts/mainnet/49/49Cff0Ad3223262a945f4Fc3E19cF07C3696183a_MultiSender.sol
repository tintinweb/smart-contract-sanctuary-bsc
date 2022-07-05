/**
 * @title Multi Sender
 * @dev MultiSender contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

import "./SafeERC20.sol";
import "./Ownable.sol";

pragma solidity 0.6.12;

contract MultiSender is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public Token;

    address[] public receiver;
    uint256[] public percent;
    uint256 public receivedToken;
    uint256 public minSendBal = 100000000000000000000;
    uint256 public maxSendBal = 5000000000000000000000;
    uint256 public timestamp;
    uint256 public Time = 600;

    function harvest() public returns (uint256) {
        uint256 i = 0;
        if (timestamp < block.timestamp) {
        uint256 sendBal = IERC20(Token).balanceOf(address(this));
        if (sendBal > minSendBal) {
            if (sendBal > maxSendBal) {
                sendBal = maxSendBal;
            }
            receivedToken = receivedToken.add(
                IERC20(Token).balanceOf(address(this))
            );
            while (i < receiver.length) {
                uint256 bal = sendBal.div(10000).mul(percent[i]);
                IERC20(Token).safeTransfer(receiver[i], bal);
                i += 1;
            }
            receivedToken = receivedToken.sub(
                IERC20(Token).balanceOf(address(this))
            );
            timestamp = block.timestamp + Time;
            return (i);
        }
      }
    }

    function setReceiver(address[] memory _receiver) external onlyOwner {
        receiver = _receiver;
    }

    function setToken(address _token) external onlyOwner {
        Token = _token;
    }

    function setPercent(uint256[] memory _percent) external onlyOwner {
        percent = _percent;
    }

    function setMinSendBal(uint256 _minSendBal) external onlyOwner {
        minSendBal = _minSendBal;
    }

    function setMAXSendBal(uint256 _maxSendBal) external onlyOwner {
        maxSendBal = _maxSendBal;
    }

    function setTime(uint256 _time) external onlyOwner {
        Time = _time;
    }

    function setReceivedToken(uint256 _receivedToken) external onlyOwner {
        receivedToken = _receivedToken;
    }

    function withdrawTokens(
        address _token,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        IERC20(_token).safeTransfer(_to, _amount);
    }
}