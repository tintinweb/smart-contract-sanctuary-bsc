// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./IERC20.sol";
import "./Ownable.sol";

contract EPXtoMinerCity is Ownable {
    IERC20 token;
    uint256 public paymentPeriod = 0;
    uint256 private _percent = 4;

    struct UserInfo {
        uint256 id;
        uint256 investment;
        uint256 withdrawn;
        uint256 period;
    }

    mapping(address => UserInfo) public userInfo;

    function Setup(address token_addr) external returns (address) {
        token = IERC20(token_addr);
        return token_addr;
    }

    function withdraw() external {
        UserInfo storage user = userInfo[msg.sender];
        uint256 _payment = available();
        require(_payment > 0, "WAIT FOR LAST PERIOD");
        require(token.transfer(msg.sender, _payment), "TRANSFER FAILED");
        user.withdrawn += _payment;
        user.period = paymentPeriod;
    }

    function available() public view returns (uint256) {
        UserInfo storage user = userInfo[msg.sender];
        uint256 _passPeriod = paymentPeriod - user.period;
        if (_passPeriod > 0) {
            return (user.investment * (_passPeriod * _percent)) / 100;
        } else {
            return 0;
        }
    }

    // Helpers

    function setInvestment(uint256 _id, address _account, uint256 _amount) external onlyOwner returns(bool){
        UserInfo storage user = userInfo[_account];
        user.id = _id;
        user.investment = _amount;
        return true;
    }

    function setPeriod(uint256 period) external onlyOwner returns (bool) {
        paymentPeriod = period;
        return true;
    }

    function setPersentage(uint256 percent) external onlyOwner returns (bool) {
        _percent = percent;
        return true;
    }

    function withdrawToken(uint256 _amount) external onlyOwner returns (bool) {
        require(token.transfer(owner(), _amount), "TRANSFER FAILED");
        return true;
    }

    function withdrawBnb() external onlyOwner returns (bool) {
        if (address(this).balance >= 0) {
            payable(owner()).transfer(address(this).balance);
        }
        return true;
    }
}