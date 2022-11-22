// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./BEP20.sol";


contract Kvoltz is BEP20{

    mapping(address => bool) private isLiquidityPool;
    mapping(address => bool) private isTaxWallet;   

    uint8 private buyTaxPercentage;
    uint8 private sellTaxPercentage;
    uint8 private transferTaxPercentage;
    address private taxWallet;
    address private kvoltzVestingContract;

    address constant IDO_WALLET = 0x043a25e730C64e3D93b6D6ADce88D0bC06ba1bCc;
    address constant TEAM_WALLET = 0x928bb80267FfC88a3EfE6BC81B226D97Dd1Fcb89;
    address constant ECOSYSTEM_WALLET = 0x01399a8F0F4aA025af68E6a56ce5bD5883EEa503;
    address constant MARKETING_WALLET = 0xD387ce9e89Ab1d1B2c7c596902711b771565B639;
    address constant STRATEGICRESERVE_WALLET = 0x4c6Cb05FD4D5C6dEb6838240Cdb3611b551473A8;
    address constant EXCHANGE_WALLET = 0xfE84C0d87aA631b1E3e6bD0F9F1c80EEdBC0B15C;

    event updateTax(uint8 _buyTaxPercentage, uint8 _sellTaxPercentage, uint8 _transferTaxPercentage);
    event updateLiquidityPool(address _liquidityPoolAddress, bool _isLiquidityPool);
    event updateTaxWallet(address _walletAddress, bool _isTaxWallet);
    event updateTaxWallet(address _walletAddress);

    constructor(address _kvoltzVestingContract) BEP20("KVOLTZ", "KVZ") {
        _mint(_kvoltzVestingContract, 22000000 * 1 ether);
        _mint(IDO_WALLET, 4000000 * 1 ether);
        _mint(TEAM_WALLET, 10000000 * 1 ether);
        _mint(ECOSYSTEM_WALLET, 20000000 * 1 ether);
        _mint(MARKETING_WALLET, 5000000 * 1 ether);
        _mint(STRATEGICRESERVE_WALLET, 10000000 * 1 ether);
        _mint(EXCHANGE_WALLET, 29000000 * 1 ether);
        taxWallet = 0xBA5E907668F99836e22b632d666a41a1640e8Fb3;
        buyTaxPercentage = 0;
        sellTaxPercentage = 0;
        transferTaxPercentage = 0;
        kvoltzVestingContract = _kvoltzVestingContract;
    }

    function setTax(uint8 _buyTaxPercentage, uint8 _sellTaxPercentage, uint8 _transferTaxPercentage) external onlyOwner {
        require(_buyTaxPercentage <= 25 && _sellTaxPercentage <= 25 && _transferTaxPercentage <= 25, "KvoltzToken: Taxes cannot be greater than 25 percent.");
        buyTaxPercentage = _buyTaxPercentage;
        sellTaxPercentage = _sellTaxPercentage;
        transferTaxPercentage = _transferTaxPercentage;
        emit updateTax(_buyTaxPercentage,_sellTaxPercentage,_transferTaxPercentage);
    }

    function getTax() external pure returns (uint8 _buyTaxPercentage, uint8 _sellTaxPercentage, uint8 _transferTaxPercentage) {
        return (_buyTaxPercentage, _sellTaxPercentage, _transferTaxPercentage);
    }

    function setLiquidityPool(address _liquidityPoolAddress, bool _isLiquidityPool) external onlyOwner {
        isLiquidityPool[_liquidityPoolAddress] = _isLiquidityPool;
        emit updateLiquidityPool(_liquidityPoolAddress, _isLiquidityPool);
    }

    function setTaxWallet(address _walletAddress, bool _isTaxWallet) external onlyOwner {
        require(_walletAddress != address(0), "KvoltzToken: Wallet address is the zero address.");
        isTaxWallet[_walletAddress] = _isTaxWallet;
        emit updateTaxWallet(_walletAddress, _isTaxWallet);
    }

    function setTaxWallet(address _walletAddress) external onlyOwner {
        require(_walletAddress != address(0), "KvoltzToken: Wallet address is the zero address.");
        taxWallet = _walletAddress;
        isTaxWallet[_walletAddress] = true;
        emit updateTaxWallet(_walletAddress);
    }

    function _transfer(address _from, address _to, uint256 _amount) internal virtual override {
        uint currentTax;
        if(isLiquidityPool[_from] == true) {
            currentTax = _amount * buyTaxPercentage / 100;
        } else if(isLiquidityPool[_to] == true){
            currentTax = _amount * sellTaxPercentage / 100;
        } else if(isTaxWallet[_from] || isTaxWallet[_to]){
            currentTax = 0;
        } else{
            currentTax = _amount * transferTaxPercentage / 100;
        }
        if(currentTax > 0) {
            super._transfer(_from, taxWallet, currentTax);
        }
        super._transfer(_from, _to, _amount - currentTax);

    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override {
        require(_to != address(this), "Transfer to contract.");    
        super._beforeTokenTransfer(_from, _to, _amount);
    }

}