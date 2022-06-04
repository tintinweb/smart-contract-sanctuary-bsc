// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;


import "./ERC20.sol";
import "./onw.sol";

contract SUNTIME is ERC20, Ownable {
    event SetLpAddress(address newLpAddress);
    uint8 constant rewardsFee = 5;
    uint8 constant taxFee = 5;
    uint8 constant liquidityFee = 0;
    uint8 constant extraFeeOnSell = 15;
    uint8 constant marketingFee = 5;
    uint8 constant extraSellFee = 15;
    address private marketingWallet = payable(0xD1ec9d129D75d06026aA94d273b87a899Bcb14B7);
    address private liqWallet = payable(0xD1ec9d129D75d06026aA94d273b87a899Bcb14B7);
    address private taxFeeWallet = payable(0xD1ec9d129D75d06026aA94d273b87a899Bcb14B7);
    address private lpAddress;   // bsc-testnet
    uint maxWalletSize;
    uint maxTransactionSize;

    struct manageFees{
        bool isRewardsFee; bool isMarketingFee; bool isTaxFee;
    }

    mapping (address => manageFees) public whiteList;

    constructor() ERC20("SUN TIME", "SUNTIME") {
        _mint(msg.sender, 750000000 * 1e9);
        maxWalletSize = 15000000 * 1e9;
        maxTransactionSize = 500000 * 1e9;
    }

    function setFees(address account, bool isReward, bool isMarketing, bool isTax) external onlyOwner {
        whiteList[account].isRewardsFee = isReward;
        whiteList[account].isMarketingFee = isMarketing;
        whiteList[account].isTaxFee = isTax;
    }

    function setLpAddress (address newLpAddress) external onlyOwner {
        lpAddress = newLpAddress;
        emit SetLpAddress(newLpAddress);
    } 

    function _transfer(address sender, address recipient, uint256 amount) internal override(ERC20) {
        uint feeAmount;
        require(amount <= maxTransactionSize, "amount is bigger than maxTransactionSize!!!");
        if(recipient != lpAddress) {
            if(whiteList[recipient].isRewardsFee == false) {
             super._transfer(sender, marketingWallet, amount * marketingFee / 100);
             feeAmount += amount * marketingFee / 100;
            }   
            if(whiteList[recipient].isMarketingFee == false) {
             super._transfer(sender, liqWallet, amount * rewardsFee / 100);
             feeAmount += amount * rewardsFee / 100;
            }
            if(whiteList[recipient].isTaxFee == false) {
                super._transfer(sender, taxFeeWallet, amount * taxFee / 100);
                feeAmount += amount * taxFee / 100;
            }
        } else {
            super._transfer(sender, marketingWallet, amount * extraSellFee / 100);
            super._transfer(sender, liqWallet, amount * extraSellFee / 100);
            feeAmount += amount * extraSellFee / 100 + amount * extraSellFee / 100;
        }
        super._transfer(sender, recipient, amount - feeAmount);
        require(balanceOf(recipient) <= maxWalletSize, "walletSize is overflowed!!!");
    }

    function mint(address account, uint256 amount) external onlyOwner {
        super._mint(account, amount);
    }

    function withdraw(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);        
    }

    function maxWalletSizeF (uint _walletSize) external onlyOwner {
        maxWalletSize = _walletSize;
    }

    function maxTransactionSizeF (uint _transactionSize) external onlyOwner {
        maxTransactionSize = _transactionSize;
    }
}