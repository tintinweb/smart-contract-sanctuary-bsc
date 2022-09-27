// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "IERC20.sol";
import "Ownable.sol";

contract SwinkICO is Ownable {
    IERC20 public activePresale;
    IERC20 public BUSD;

    bool private enableWithdraw;

    address public treasuryWallet;

    struct PresaleContract {
        uint256 price;
        mapping(address => uint256) bought;
    }

    mapping (address => PresaleContract) public presaleContracts;

    constructor() {
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    }

    function addPresaleContract(address _address, uint256 _price) public onlyOwner {
        presaleContracts[_address].price = _price;
    }

    function setBUSD(address _busd) public onlyOwner {
        BUSD = IERC20(_busd);
    }

    function setActivePresaleContract(address _address) public onlyOwner {
        require(presaleContracts[_address].price > 0, "Cotract not set");

        activePresale = IERC20(_address);
    }

    function buySwink(uint256 BUSDAmount) public {
        require(address(activePresale) != address(0), "Active presale not set");
        
        uint256 swinkAmount = BUSDAmount * 100 / presaleContracts[address(activePresale)].price;
        require(activePresale.balanceOf(address(this)) >= swinkAmount, "Not enough swink avaible");

        BUSDAmount = swinkAmount * presaleContracts[address(activePresale)].price / 100;

        uint256 BUSDBalanceOfUser = BUSD.balanceOf(msg.sender);
        require(BUSDBalanceOfUser >= BUSDAmount, "You dont have enough balance");
        
        uint256 allowance = BUSD.allowance(msg.sender, address(this));
        require(allowance >= BUSDAmount, "Check allowance");

        BUSD.transferFrom(msg.sender, address(this), BUSDAmount);
        activePresale.transfer(msg.sender, swinkAmount);

        presaleContracts[address(activePresale)].bought[msg.sender] += swinkAmount;
    }

    function getPrice(address _tokenAddress) public view returns (uint256) {
        return presaleContracts[_tokenAddress].price;
    }

    function getBoughtBy(address _tokenAddress, address _wallet) public view returns (uint256) {
        return presaleContracts[_tokenAddress].bought[_wallet];
    }

    function setBoughtBy(address _tokenAddress, address _wallet, uint256 _amount) public onlyOwner {
        require(presaleContracts[_tokenAddress].price > 0, "Cotract not set");

        presaleContracts[_tokenAddress].bought[_wallet] = _amount;
    }

    function withdrawSwink(uint256 _amount) public onlyOwner {
        require(enableWithdraw, "Withdraw is not enabled");
        withdrawSwink(address(activePresale), _amount);
    }

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