/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// Sources flattened with hardhat v2.9.1 https://hardhat.org

// File contracts/Guild.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Guild
{
    address adminAddress;
    address public receiveAddress;
    address immutable public moneyToken;
    uint256 [] upgrateAmounts = [ 0, 100, 100, 100, 200, 300, 400, 500, 600, 1200 ];
    // uint256 [] upgrateAmounts = [ 100, 100, 100, 100, 200, 300, 400, 500, 600, 1200 ];

    event CreateGuild(string id, string orderId, address account, uint256 amount, uint256 timestamp);
    event UpgrateGuild(string id, string orderId, address account, uint256 amount, uint256 level, uint256 timestamp);

    constructor(address _moneyToken, uint256 decimals, address _receiveAddress)
    {
        moneyToken = _moneyToken;
        adminAddress = msg.sender;
        receiveAddress = _receiveAddress;
        for (uint256 i = 0; i < upgrateAmounts.length; ++i) {
            upgrateAmounts[i] = upgrateAmounts[i] * 10**decimals;
        }
    }
    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "only admin");
        _;
    }
    function transferReceiver(address receiver) external onlyAdmin {
        receiveAddress = receiver;
    }
    function setUpgrateAmounts(uint256[] calldata amounts) external onlyAdmin {
        for (uint256 i = 0; i < amounts.length; i++) {
            upgrateAmounts[i] = amounts[i];
        }
    }
    function getUpgrateAmounts() public view returns(uint256[] memory amounts) {
        uint256[] memory _amounts = new uint256[](upgrateAmounts.length);
        for (uint256 i = 0; i < upgrateAmounts.length; i++) {
            _amounts[i] = upgrateAmounts[i];
        }
        return _amounts;
    }

    function createGuild(string memory id, string memory orderId) external {
        require(IERC20(moneyToken).balanceOf(msg.sender) >= upgrateAmounts[0], "Not enough payment funds");
        IERC20(moneyToken).transferFrom(msg.sender, receiveAddress, upgrateAmounts[0]);
        emit CreateGuild(id, orderId, msg.sender, upgrateAmounts[0], block.timestamp);
    }
    function upgrateGuild(string memory id, string memory orderId, uint256 level) external {
        require(level <= 10, "max level");
        require(IERC20(moneyToken).balanceOf(msg.sender) >= upgrateAmounts[level-1], "Not enough payment funds");
        IERC20(moneyToken).transferFrom(msg.sender, receiveAddress, upgrateAmounts[level-1]);
        emit UpgrateGuild(id, orderId, msg.sender, upgrateAmounts[level-1], level, block.timestamp);
    }

    function adminWithdraw() external onlyAdmin {
        IERC20(moneyToken).transfer(msg.sender, IERC20(moneyToken).balanceOf(address(this)));
    }
}