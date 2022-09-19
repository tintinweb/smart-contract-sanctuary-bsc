//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "./Ownable.sol";
import "./ERC20.sol";
import "./SafeMath.sol";

contract CyberSale is Ownable {

    using SafeMath for uint256;

    ERC20 public CyberLink = ERC20(0xF9Db826A7cC30FEd210cC554A390ecE796A645b4);
    ERC20 public Busd = ERC20(0xE82E23c77171ACd005d73C07866b9ba379c2b4E5);
    bool private withdrawn = false;
    address[] public joinList;

    uint256 SaleS = 1663506000;
    uint256 SaleE = 1663507800;

    // sale 0 (price: 0.00185, min. buy: 200, tokens: 16000000, unlock/month: 33%)
    uint256 Sale0TokensPerBusd = 540540540540540540500;
    uint256 Sale0MinBuy = 200 * 10 ** 18;
    uint256 Sale0TokenAlloc = 16000000 * 10 ** 18;
    uint256 Sale0LockMonths = 3;
    struct sale0Data {
        uint256 totalBought;
        uint256 currentBalance;
        uint256 lastClaim;
    }
    mapping (address => sale0Data) public sale0DataMap;

    //sale 1 (price: 0.0017, min. buy: 150, tokens: 24000000, unlock/month: 16.5%)
    uint256 Sale1TokensPerBusd = 588235294117647100000;
    uint256 Sale1MinBuy = 150 * 10 ** 18;
    uint256 Sale1TokenAlloc = 24000000 * 10 ** 18;
    uint256 Sale1LockMonths = 6;
    struct sale1Data {
        uint256 totalBought;
        uint256 currentBalance;
        uint256 lastClaim;
    }
    mapping (address => sale1Data) public sale1DataMap;

    constructor(){}

    function deposit(uint8 saleID, uint256 amount) public {
        require(block.timestamp > SaleS && block.timestamp < SaleE);
        if(saleID == 0){
            require(amount >= Sale0MinBuy && amount.mul(Sale0TokensPerBusd) <= Sale0TokenAlloc.sub(totalBoughtIn(0)));
            Busd.transferFrom(msg.sender, address(this), amount);
            sale0DataMap[msg.sender] = sale0Data(sale0DataMap[msg.sender].totalBought.add(amount.mul(Sale0TokensPerBusd)), sale0DataMap[msg.sender].currentBalance.add(amount.mul(Sale0TokensPerBusd)), 0);

        } else {
            require(amount >= Sale1MinBuy && amount.mul(Sale1TokensPerBusd) <= Sale1TokenAlloc.sub(totalBoughtIn(1)));
            Busd.transferFrom(msg.sender, address(this), amount);
            sale1DataMap[msg.sender] = sale1Data(sale1DataMap[msg.sender].totalBought.add(amount.mul(Sale1TokensPerBusd)), sale1DataMap[msg.sender].currentBalance.add(amount.mul(Sale1TokensPerBusd)), 0);
        }
        if(!(isPresaler(msg.sender))){ joinList.push(msg.sender); }

    }

    function claimBatch(uint8 saleID) public {
        require(block.timestamp >= SaleE + 300 && isPresaler(msg.sender));
        uint256 batch;
        if(saleID == 0){
            require(sale0DataMap[msg.sender].lastClaim + 300 <= block.timestamp && sale0DataMap[msg.sender].currentBalance > 0);
            batch = sale0DataMap[msg.sender].totalBought.div(Sale0LockMonths);
            if(sale0DataMap[msg.sender].currentBalance > batch){
                sale0DataMap[msg.sender].currentBalance = sale0DataMap[msg.sender].currentBalance.sub(batch);
                sale0DataMap[msg.sender].lastClaim = block.timestamp;
                CyberLink.transfer(msg.sender, batch);
            } else {
                sale0DataMap[msg.sender].currentBalance = 0;
                sale0DataMap[msg.sender].lastClaim = block.timestamp;
                CyberLink.transfer(msg.sender, sale0DataMap[msg.sender].currentBalance);
            }

        } else {
            require(sale1DataMap[msg.sender].lastClaim + 300 <= block.timestamp && sale1DataMap[msg.sender].currentBalance > 0);
            batch = sale1DataMap[msg.sender].totalBought.div(Sale1LockMonths);
            if(sale1DataMap[msg.sender].currentBalance > batch){
                sale1DataMap[msg.sender].currentBalance = sale1DataMap[msg.sender].currentBalance.sub(batch);
                sale1DataMap[msg.sender].lastClaim = block.timestamp;
                CyberLink.transfer(msg.sender, batch);
            } else {
                sale1DataMap[msg.sender].currentBalance = 0;
                sale1DataMap[msg.sender].lastClaim = block.timestamp;
                CyberLink.transfer(msg.sender, sale1DataMap[msg.sender].currentBalance);
            }
        }
    }

    function totalBoughtIn(uint8 saleID) public view returns(uint256){
        uint256 total;
        for(uint256 i=0; i < joinList.length; i++){
            if(saleID == 0){
                total = total.add(sale0DataMap[joinList[i]].totalBought);
            }
            else {
                total = total.add(sale1DataMap[joinList[i]].totalBought);
            }
        }
        return total;
    }

    function isPresaler(address guy) public view returns(bool){
        for (uint256 i = 0; i < joinList.length; i++){
            if (guy == joinList[i]) return (true);
        }
        return (false);
    }

    function getData(address guy) external view returns(uint256, uint256, uint256, uint256, uint256, uint256) {
        return (sale0DataMap[guy].totalBought, sale0DataMap[guy].currentBalance, sale0DataMap[guy].lastClaim, sale1DataMap[guy].totalBought, sale1DataMap[guy].currentBalance, sale1DataMap[guy].lastClaim);
    }
    function withdrawUnsold() external onlyOwner {
        require(block.timestamp > SaleE && !withdrawn);
        CyberLink.transfer(msg.sender, CyberLink.balanceOf(address(this)) - (totalBoughtIn(0) + totalBoughtIn(1)));
        withdrawn = true;
    }

    function getLiquidityFunds() external onlyOwner {
        require(block.timestamp > SaleE);
        Busd.transfer(msg.sender, Busd.balanceOf(address(this)));
    }
}