pragma solidity 0.5.8;

import "./ERC20.sol";
import "./SafeERC20.sol";

contract Payment {
    using SafeMath for uint;
    using SafeERC20 for ERC20;

    mapping(uint8 => Config) configMap;
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier OnlyOwner{
        require(msg.sender == owner, 'Only owner operator');
        _;
    }

    struct Config {
        uint8 configId;
        address token;
        bool exist;
    }

    event RechargeEvent(address indexed user, string orderNo, uint amount);
    event WithdrawEvent(address indexed user, string orderNo, uint amount);

    function setConfig(uint8 _configId, address _token) OnlyOwner public {
        configMap[_configId] = Config(_configId, _token, true);
    }

    function recharge(string memory orderNo, uint8 configId, uint amount) public returns (bool) {
        require(amount > 0, "Recharge amount must greater than zero");
        Config storage config = configMap[configId];
        require(configMap[configId].exist, "Recharge config not exist");
        require(ERC20(config.token).balanceOf(msg.sender) >= amount, "Insufficient balance");
        ERC20(config.token).safeTransferFrom(msg.sender, address(this), amount);
        emit RechargeEvent(msg.sender, orderNo, amount);
        return true;
    }

    function withdraw(string memory orderNo, uint8 configId, address user, uint amount) OnlyOwner public returns (bool) {
        Config storage config = configMap[configId];
        require(configMap[configId].exist, "Recharge config not exist");
        require(ERC20(config.token).balanceOf(address(this)) >= amount, "Insufficient balance");
        ERC20(config.token).safeTransfer(user, amount);
        emit WithdrawEvent(user, orderNo, amount);
        return true;
    }

    function extract(uint8 configId, uint amount) OnlyOwner public returns (bool) {
        Config storage config = configMap[configId];
        require(config.exist, "The token doesn't exist");
        require(ERC20(config.token).balanceOf(address(this)) >= amount, "Insufficient balance");
        ERC20(config.token).safeTransferFrom(msg.sender, address(this), amount);
        return true;
    }
}