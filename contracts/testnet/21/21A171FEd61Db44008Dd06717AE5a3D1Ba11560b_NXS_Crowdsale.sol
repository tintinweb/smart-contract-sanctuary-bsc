// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Ownable.sol";
import "./IUniswapV2Router02.sol";

contract NXS_Crowdsale is Ownable {
    IERC20 nexusToken;
    IERC20 public feeToken;
    IUniswapV2Router02 router;

    address tokenSender;
    address payable public crowdsaleReceiver;

    uint256 public minimumAmountPaid;
    uint256 public minimumTokensToBePurchased;
    uint256 public tokenPrice;
    uint256 public totalCrowdsaleTarget;
    uint256 public currentRaised;
    uint256 public participantsCount;
    uint256 public extraTokens;

    constructor() {
        crowdsaleReceiver = payable(msg.sender);
        tokenSender = msg.sender; // could be contract or EOA address

        nexusToken = IERC20(0x180CF168232D768370Fb854dd4Dfe6Dca9e1B094); // nexus token on BSC
        feeToken = IERC20(0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814); // BUSD on Pancake
        router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

        extraTokens = 25;
        tokenPrice = 100000000000000000; // 1NXS = 0.10USDT: 10^18NXS = 0.10^18USDT
        minimumAmountPaid = 0 ether; // 5 USDT minimum
        minimumTokensToBePurchased = 10 * 10 ** 18;
        totalCrowdsaleTarget = 25000 ether; // 25000 USDT target
    }

    function buyToken() public payable {
        require(
            msg.value != 0 && msg.value >= minimumAmountPaid,
            "invalid amount for purchase"
        );

        uint256 paidAmount = bnbToFeeToken(msg.value);
        require(paidAmount > 0, "not enough amount");

        uint256 final_amount = (paidAmount * 10 ** 18) / tokenPrice;
        require(
            final_amount >= minimumTokensToBePurchased,
            "token amount should be greater than minimum amount"
        );
        final_amount = final_amount + ((final_amount * extraTokens) / 100);
        nexusToken.transferFrom(tokenSender, msg.sender, final_amount);

        participantsCount++;
        currentRaised += msg.value;

        (bool ms, ) = crowdsaleReceiver.call{value: msg.value}("sending bnb");
        require(ms, "ETH transfer failed.");
    }

    function bnbToFeeToken(uint _amount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(router.WETH());
        path[1] = address(feeToken);
        uint256 outputAmount = router.getAmountsOut(_amount, path)[1];

        return outputAmount;
    }

    function UsdtToNxs(uint256 bnbAmount) public view returns (uint256) {
        uint256 paidAmount = bnbToFeeToken(bnbAmount);
        uint256 final_amount = (paidAmount * 10 ** 18) / tokenPrice;
        final_amount = final_amount + ((final_amount * extraTokens) / 100);
        return final_amount;
    }

    function setNexusToken(address _nexusToken) external onlyOwner {
        nexusToken = IERC20(_nexusToken);
    }

    function setminimumAmountPaid(uint256 _minimumAmount) external onlyOwner {
        require(_minimumAmount != 0, "invalid minimum amount");
        minimumAmountPaid = _minimumAmount;
    }

    function setTokenPrice(uint256 _newPrice) external onlyOwner {
        require(_newPrice != 0, "invalid price");
        tokenPrice = _newPrice;
    }

    function setCrowdsaleReceiver(address _newReceiver) external onlyOwner {
        require(_newReceiver != address(0), "invalid address");
        crowdsaleReceiver = payable(_newReceiver);
    }

    function setFeeToken(address addr) external onlyOwner {
        require(addr != address(0), "invalid address");
        feeToken = IERC20(addr);
    }

    function setTokenSender(address _tokenSender) external onlyOwner {
        require(_tokenSender != address(0), "invalid address");
        tokenSender = _tokenSender;
    }

    function setRouter(address _address) external onlyOwner {
        require(_address != address(0), "invalid address");
        router = IUniswapV2Router02(_address);
    }

    function setTotalTargetInUSDT(uint256 _newTarget) external onlyOwner {
        totalCrowdsaleTarget = _newTarget;
    }

    function setExtraTokens(uint256 percentage) public onlyOwner {
        extraTokens = percentage;
    }

    function setMinimumTokensToBePurchased(uint256 amount) public onlyOwner {
        minimumTokensToBePurchased = amount;
    }
}