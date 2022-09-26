// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "IERC20.sol";
import "Ownable.sol";

contract SwinkICO is Ownable {
    IERC20 public SWINK;
    IERC20 public BUSD;

    bool private enableWithdraw;

    address public treasuryWallet;
    uint256 public price;

    mapping (address => mapping (address=>uint256)) public bought;

    constructor() {
        // BUSD contract on bsc mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
        // BUSD contract on bsc testnet: 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    }

    function setBUSD(address _busd) public onlyOwner {
        BUSD = IERC20(_busd);
    }

    function setSwink(address _swink, uint256 _price) public onlyOwner {
        SWINK = IERC20(_swink);
        price = _price;
    }

    function buySwink(uint256 BUSDAmount) public {
        uint256 BUSDBalanceOfUser = BUSD.balanceOf(msg.sender);
        require(BUSDBalanceOfUser >= BUSDAmount, "You dont have enough balance");
        
        uint256 allowance = BUSD.allowance(msg.sender, address(this));
        require(allowance >= BUSDAmount, "Check allowance");
        
        uint256 swinkAmount = BUSDAmount * 100 / price; // /*/ 10 ** (BUSD.decimals() - SWINK.decimals())*/ / price;
        require(SWINK.balanceOf(address(this)) >= swinkAmount, "Not enough swink avaible");

        BUSD.transferFrom(msg.sender, address(this), BUSDAmount);
        SWINK.transfer(msg.sender, swinkAmount);

        bought[msg.sender][address(SWINK)] += swinkAmount;
    }

    // Used to set the amounts of already made payments
    function setBoughtBy(address _wallet, address _tokenAddress, uint256 _amount) public onlyOwner {
        bought[_wallet][_tokenAddress] = _amount;
    }

    // Withdraw tokens from the current SWINK contract
    function withdrawSwink(uint256 _amount) public onlyOwner {
        require(enableWithdraw, "Withdraw is not enabled");
        withdrawSwink(address(SWINK), _amount);
    }

    // Withdraw tokens from a specific SWINK contract
    function withdrawSwink(address _tokenAddress, uint256 _amount) public onlyOwner {
        require(enableWithdraw, "Withdraw is not enabled");
        
        uint256 swinkBalance = IERC20(_tokenAddress).balanceOf(address(this));
        require(swinkBalance >= _amount, "Not enough swink avaible");
        
        IERC20(_tokenAddress).transfer(treasuryWallet, _amount);
    }

    function withdrawBUSD() public onlyOwner {
        uint256 BUSDBalance = BUSD.balanceOf(address(this));
        BUSD.transfer(treasuryWallet, BUSDBalance);
    }

    function setTreasuryWallet(address _treasuryAddress) public onlyOwner {
        treasuryWallet = _treasuryAddress;
    }

    function toggleEnable() public onlyOwner {
        enableWithdraw = !enableWithdraw;
    }
}