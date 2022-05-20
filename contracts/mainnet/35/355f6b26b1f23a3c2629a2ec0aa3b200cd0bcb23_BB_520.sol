// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./BEP20Detailed.sol";
import "./BEP20.sol";

contract BB_520 is BEP20Detailed, BEP20 {
    mapping(address => bool) private isBlacklist;
    mapping(address => bool) private liquidityPool;
    mapping(address => uint256) private lastTrade;

    uint8 private buyTax;
    uint8 private sellTax;
    uint8 private tradeCooldown;
    uint8 private transferTax;
    uint256 private taxAmount;

    address private ProjectAddLiquidity;
    address private NFTBonusesPool;

    event changeBlacklist(address _wallet, bool status);
    event changeCooldown(uint8 tradeCooldown);
    event changeTax(uint8 _sellTax, uint8 _buyTax, uint8 _transferTax);
    event changeLiquidityPoolStatus(address lpAddress, bool status);

    event changeProjectAddLiquidity(address NFTBonusesPool);
    event changeNFTBonusesPool(address NFTBonusesPool);

    constructor() BEP20Detailed("520 Blind Box Token", "520BB", 18) {
        uint256 totalTokens = 52000000000 * 10**uint256(decimals());
        _mint(msg.sender, totalTokens);
        sellTax = 4;
        buyTax = 0;
        transferTax = 4;
        tradeCooldown = 40;

        ProjectAddLiquidity = 0x42F9F64548C7e044e964943f75253B104f0F2266;
        NFTBonusesPool = 0xcA9e6571556067470AAAD53019E2f7f5bC4188BB;
    }

    function setBlacklist(address _wallet, bool _status) external onlyOwner {
        isBlacklist[_wallet] = _status;
        emit changeBlacklist(_wallet, _status);
    }

    function setCooldownForTrades(uint8 _tradeCooldown) external onlyOwner {
        tradeCooldown = _tradeCooldown;
        emit changeCooldown(_tradeCooldown);
    }

    function setLiquidityPoolStatus(address _lpAddress, bool _status)
        external
        onlyOwner
    {
        liquidityPool[_lpAddress] = _status;
        emit changeLiquidityPoolStatus(_lpAddress, _status);
    }

    function setProjectAddLiquidity(address _ProjectAddLiquidity)
        external
        onlyOwner
    {
        ProjectAddLiquidity = _ProjectAddLiquidity;
        emit changeProjectAddLiquidity(_ProjectAddLiquidity);
    }

    function setNFTBonusesPool(address _NFTBonusesPool) external onlyOwner {
        NFTBonusesPool = _NFTBonusesPool;
        emit changeNFTBonusesPool(_NFTBonusesPool);
    }

    function setTaxes(
        uint8 _sellTax,
        uint8 _buyTax,
        uint8 _transferTax
    ) external onlyOwner {
        require(_sellTax < 101);
        require(_buyTax < 101);
        require(_transferTax < 101);
        sellTax = _sellTax;
        buyTax = _buyTax;
        transferTax = _transferTax;
        emit changeTax(_sellTax, _buyTax, _transferTax);
    }

    function getTaxes()
        external
        view
        returns (
            uint8 _sellTax,
            uint8 _buyTax,
            uint8 _transferTax
        )
    {
        return (sellTax, buyTax, transferTax);
    }

    function _transfer(
        address sender,
        address receiver,
        uint256 amount
    ) internal virtual override {
        require(
            receiver != address(this),
            string("No transfers to contract allowed.")
        );
        require(!isBlacklist[sender], "User blacklisted");
        if (liquidityPool[sender] == true) {
            //It's an LP Pair and it's a buy
            taxAmount = (amount * buyTax) / 100;
        } else if (liquidityPool[receiver] == true) {
            //It's an LP Pair and it's a sell
            taxAmount = (amount * sellTax) / 100;

            require(
                lastTrade[sender] < (block.timestamp - tradeCooldown),
                string("No consecutive sells allowed. Please wait.")
            );
            lastTrade[sender] = block.timestamp;
        } else if (
            sender == ProjectAddLiquidity ||
            receiver == ProjectAddLiquidity ||
            sender == NFTBonusesPool ||
            receiver == NFTBonusesPool
        ) {
            taxAmount = 0;
        } else {
            taxAmount = (amount * transferTax) / 100;
        }

        if (taxAmount > 0) {
            super._transfer(sender, NFTBonusesPool, taxAmount);
        }
        super._transfer(sender, receiver, amount - taxAmount);
    }
}