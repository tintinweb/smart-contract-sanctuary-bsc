// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.10;

import "./AirdropSetting.sol";
import "./Ownable.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./TransferHelper.sol";

contract Airdrop is Ownable {
    using SafeMath for uint256;

    IAirdropSetting public AIRDROP_SETTING;
    address public operatorAddress;

    event AirdropToken(address userAddress, string tokenType, uint256 numberAddress, uint256 totalAmount, uint256 feeAmount);

    constructor(address _airdropSettingAddress) {
        AIRDROP_SETTING = IAirdropSetting(_airdropSettingAddress);
        operatorAddress = msg.sender;
    }

    function airdropMain(
        address[] memory listAddress,
        uint256[] memory listAmount
    ) public payable {

        require(listAddress.length > 0, 'AIRDROP: INVALID LIST ADDRESS');
        require(listAddress.length == listAmount.length, 'AIRDROP: INVALID DATA LENGTH');

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < listAmount.length; i++) {
            totalAmount = totalAmount.add(listAmount[i]);
        }
        uint256 amountWithFee = totalAmount.add(AIRDROP_SETTING.getFeeAmount());
        require(msg.value >= amountWithFee, 'AIRDROP: INVALID AMOUNT');
        payable(AIRDROP_SETTING.getFeeAddress()).transfer(msg.value);

        for (uint256 i = 0; i < listAddress.length; i++) {
            payable(listAddress[i]).transfer(listAmount[i]);
        }
        emit AirdropToken(msg.sender, "main", listAddress.length, totalAmount, msg.value);
    }

    function airdropToken(
        address tokenAddress,
        address[] memory listAddress,
        uint256[] memory listAmount
    ) public payable {

        require(listAddress.length > 0, 'AIRDROP: INVALID LIST ADDRESS');
        require(listAddress.length == listAmount.length, 'AIRDROP: INVALID DATA LENGTH');
        require(msg.value >= AIRDROP_SETTING.getFeeAmount(), 'AIRDROP: INVALID FEE AMOUNT');
        payable(AIRDROP_SETTING.getFeeAddress()).transfer(msg.value);

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < listAmount.length; i++) {
            totalAmount = totalAmount.add(listAmount[i]);
        }
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(msg.sender);
        require(tokenBalance >= totalAmount, "AIRDROP: INVALID SENDER BALANCE");
        for (uint256 i = 0; i < listAddress.length; i++) {
            TransferHelper.safeTransferFrom(tokenAddress, address(msg.sender), listAddress[i], listAmount[i]);
        }
        emit AirdropToken(msg.sender, "erc20", listAddress.length, totalAmount, msg.value);
    }

    fallback() payable external {}

    receive() payable external {}

    modifier onlyOwnerOrOperator() {
        require((msg.sender == owner()) || (msg.sender == operatorAddress), "Not owner or operator");
        _;
    }

    function retrieveToken(address tokenAddress, uint256 amount, address userAddress) external onlyOwnerOrOperator returns (bool) {
        return IERC20(tokenAddress).transfer(userAddress, amount);
    }

    function retrieveBalance(uint256 amount, address userAddress) external onlyOwnerOrOperator {
        payable(userAddress).transfer(amount);
    }

}