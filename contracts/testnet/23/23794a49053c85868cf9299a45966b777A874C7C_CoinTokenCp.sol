/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender() || owner() == tx.origin, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract CoinTokenCp is ERC20, Ownable, Pausable {
    
    IERC20 public tradeToken;
    uint256 private initialSupply;
   
    uint256 private denominator = 100;
    uint8 private precision = 4;
    
    uint256 private devTaxBuy;
    uint256 private marketingTaxBuy;
    uint256 private liquidityTaxBuy;
    uint256 private charityTaxBuy;
    
    uint256 private devTaxSell;
    uint256 private marketingTaxSell;
    uint256 private liquidityTaxSell;
    uint256 private charityTaxSell;
    
    address private devTaxWallet;
    address private marketingTaxWallet;
    address private liquidityTaxWallet;
    address private charityTaxWallet;
    
    mapping (address => bool) private blacklist;
    mapping (address => bool) private excludeList;

    mapping (string => uint256) private buyTaxes;
    mapping (string => uint256) private sellTaxes;
    mapping (string => address) private taxWallets;
    orderData[] public orderBuy;
    orderData[] public orderSell;
    uint256 public marketQuotation;
    bool public taxStatus = true;

    struct orderData{
        uint256 timestamp;
        uint256 tokenPrice;
        uint256 quantity;
        uint256 filledQuantity;
        uint256 filledAmount;
        uint256 quotation;
        uint256 tax;
        address owner;
        bool fullFilled;
    }
    
    constructor()ERC20("Tokename", "TKN")
    {
        tradeToken = IERC20(0x7FF13360a12c64286a359E95ec79368B21571E67);
        initialSupply =  1000000 * (10**18);
        address owner = 0xf73eaEEAd16Ba9689085ff744a7db099deE37131;
        _setOwner(owner);
        exclude(owner);
        exclude(address(this));
        _mint(owner, initialSupply);
        taxWallets["liquidity"] = 0x07eaC1E864F9b3E7cadeF0dEeC3dAd0cF4c641e0;
        taxWallets["dev"] = 0x10365e8f2B40cA8bA15fF150Bf7A33bA1061173B;
        taxWallets["marketing"] = 0xeaF4b5ceD6Eab06506DafDeC6F94Ca65Ffe23AfF;
        taxWallets["charity"] = 0xf8EC2dD5aAb3b9da62128823F8bFf64F134719Bb;
        taxWallets["repurchase"] = 0xAF118fd1402e40f28B1aEfb5E7Ac5f173DDA02D5;
        sellTaxes["liquidity"] = 4;
        sellTaxes["dev"] = 2;
        sellTaxes["marketing"] = 1;
        sellTaxes["charity"] = 3;
        sellTaxes["repurchase"] = 5;
        buyTaxes["liquidity"] = 4;
        buyTaxes["dev"] = 2;
        buyTaxes["marketing"] = 1;
        buyTaxes["charity"] = 3;
        buyTaxes["repurchase"] = 5;
    }
    
    uint256 private marketingTokens;
    uint256 private devTokens;
    uint256 private liquidityTokens;
    uint256 private charityTokens;

    function sendBuyOrder(uint256 tokenPrice,uint256 quantity) public returns(bool){
        tradeToken.transferFrom(msg.sender,taxWallets["liquidity"],tokenPrice*quantity*10**(decimals()-precision*2));
        orderBuy.push(orderData(0,0,0,0,0,0,0,address(0),false));
        uint256 insertIndex = orderBuy.length - 1;
        for(uint256 i = 0; i < orderBuy.length - 1; i++){
            if(tokenPrice > orderBuy[i].tokenPrice){
                insertIndex = i;
                break;
            }
        }
        if(insertIndex == orderBuy.length - 1){
            orderBuy[insertIndex] = orderData(block.timestamp,tokenPrice,quantity,0,0,tokenPrice/quantity,0,msg.sender,false);
        }else{
            orderData[] memory tempBuy = orderBuy;
            for(uint256 i = insertIndex+1; i < orderBuy.length; i++){
                orderBuy[i] = tempBuy[i-1];
            }
            orderBuy[insertIndex] = orderData(block.timestamp,tokenPrice,quantity,0,0,tokenPrice/quantity,0,msg.sender,false);
        }
        synchronizeOrders();
        return true;
    }

    function sendBuyMarket(uint256 amount) public returns(bool){
        return sendBuyOrder(marketQuotation,amount);
    }

    function sendSellOrder(uint256 tokenPrice,uint256 quantity) public returns(bool){
        super._transfer(msg.sender,taxWallets["liquidity"],quantity*10**(decimals()-precision));
        orderSell.push(orderData(0,0,0,0,0,0,0,address(0),false));
        uint256 insertIndex = orderSell.length - 1;
        for(uint256 i = 0; i < orderSell.length - 1; i++){
            if(tokenPrice < orderSell[i].tokenPrice){
                insertIndex = i;
                break;
            }
        }
        if(insertIndex == orderSell.length - 1){
            orderSell[insertIndex] = orderData(block.timestamp,tokenPrice,quantity,0,0,tokenPrice/quantity,0,msg.sender,false);
        }else{
            orderData[] memory tempSell = orderSell;
            for(uint256 i = insertIndex+1; i < orderSell.length; i++){
                orderSell[i] = tempSell[i-1];
            }
            orderSell[insertIndex] = orderData(block.timestamp,tokenPrice,quantity,0,0,tokenPrice/quantity,0,msg.sender,false);
        }
        synchronizeOrders();
        return true;
    }
    function sendSellMarket(uint256 amount) public returns(bool){
        return sendSellOrder(marketQuotation,amount);
    }

    function synchronizeOrders() public{
        for(uint256 i = 0; i < orderBuy.length; i++){
            if(orderBuy[i].fullFilled == false){
                for(uint256 j = 0; j < orderSell.length; j++){
                    if(orderBuy[i].tokenPrice >= orderSell[j].tokenPrice){
                        uint256 remainingQuantityBuy = 0;
                        uint256 remainingQuantitySell = 0;
                        if(orderBuy[i].quantity > orderBuy[i].filledQuantity){
                            remainingQuantityBuy = orderBuy[i].quantity - orderBuy[i].filledQuantity;
                        }else{
                            orderBuy[i].fullFilled = true;
                            break;
                        }
                        if(orderSell[j].quantity > orderSell[j].filledQuantity){
                            remainingQuantitySell = orderSell[j].quantity - orderSell[j].filledQuantity;
                        }else{
                            orderSell[j].fullFilled = true;
                        }
                        if(orderSell[j].fullFilled == false){
                            if(remainingQuantityBuy > remainingQuantitySell){
                                _payOrder(remainingQuantitySell,
                                remainingQuantitySell*orderSell[j].tokenPrice*10**(decimals()-precision*2),
                                remainingQuantitySell*10**(decimals()-precision),i,j);
                            }else{
                                _payOrder(remainingQuantityBuy,
                                remainingQuantityBuy*orderSell[j].tokenPrice*10**(decimals()-precision*2),
                                remainingQuantityBuy*10**(decimals()-precision),i,j);
                            }
                        }
                    }
                }
            }
        }
    }
    function _payOrder(uint256 orderQuantity, uint256 orderTradeValue,uint256 orderTokenValue,uint256 ibuy,uint256 isell) private{
        uint256 boughtTax = 0;
        uint256 sellTax = 0;
        if(!isExcluded(msg.sender)) {
            boughtTax = (orderTokenValue / denominator) * buyTaxes["repurchase"];
            sellTax = (orderTradeValue / denominator) * sellTaxes["repurchase"];
        }
        orderBuy[ibuy].filledAmount += orderTokenValue;
        orderBuy[ibuy].filledQuantity += orderQuantity;
        orderBuy[ibuy].tax += boughtTax;
        super._transfer(taxWallets["liquidity"],orderBuy[ibuy].owner,orderTokenValue-boughtTax);
        orderSell[isell].filledAmount += orderTradeValue;
        orderSell[isell].filledQuantity += orderQuantity;
        orderSell[isell].tax += sellTax;
        tradeToken.transferFrom(taxWallets["liquidity"],orderSell[isell].owner,orderTradeValue-sellTax);
        marketQuotation = orderSell[isell].tokenPrice;
        if(!isExcluded(msg.sender)) {
            super._transfer(orderBuy[ibuy].owner,taxWallets["repurchase"],boughtTax);
            tradeToken.transferFrom(orderSell[isell].owner,taxWallets["repurchase"],sellTax);
        }
        if(orderBuy[ibuy].filledQuantity >= orderBuy[ibuy].quantity){
            orderBuy[ibuy].fullFilled = true;
        }
        if(orderSell[isell].filledQuantity >= orderSell[isell].quantity){
            orderSell[isell].fullFilled = true;
        }
    }
    function setPrecisionFactor(uint8 precisionFactor) public{
        precision = precisionFactor;
    }
    
    function handleTax(address from, address to, uint256 amount) private returns (uint256) {
        if(!isExcluded(from) && !isExcluded(to)) {
            uint256 tax;
            uint256 baseUnit = amount / denominator;
            
            uint256 taxMarketing = baseUnit * buyTaxes["marketing"];
            uint256 taxDev = baseUnit * buyTaxes["dev"];
            uint256 taxLiquidity = baseUnit * buyTaxes["liquidity"];
            uint256 taxCharity = baseUnit * buyTaxes["charity"];

            tax += taxMarketing;
            tax += taxDev;
            tax += taxLiquidity;
            tax += taxCharity;

            super._transfer(msg.sender,taxWallets["marketing"],taxMarketing);
            super._transfer(msg.sender,taxWallets["dev"],taxDev);
            super._transfer(msg.sender,taxWallets["liquidity"],taxLiquidity);
            super._transfer(msg.sender,taxWallets["charity"],taxCharity);
            amount -= tax;
        }
        
        return amount;
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override virtual {
        require(!paused(), "CoinToken: token transfer while paused");
        require(!isBlacklisted(msg.sender), "CoinToken: sender blacklisted");
        require(!isBlacklisted(recipient), "CoinToken: recipient blacklisted");
        require(!isBlacklisted(tx.origin), "CoinToken: sender blacklisted");
        
        if(taxStatus) {
            amount = handleTax(sender, recipient, amount);   
        }
        
        super._transfer(sender, recipient, amount);
    }
    
    
    function pause() public onlyOwner {
        require(!paused(), "CoinToken: Contract is already paused");
        _pause();
    }

    function unpause() public onlyOwner {
        require(paused(), "CoinToken: Contract is not paused");
        _unpause();
    }
    
    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }
    
    function enableBlacklist(address account) public onlyOwner {
        require(!blacklist[account], "CoinToken: Account is already blacklisted");
        blacklist[account] = true;
    }
    
    function disableBlacklist(address account) public onlyOwner {
        require(blacklist[account], "CoinToken: Account is not blacklisted");
        blacklist[account] = false;
    }
    

    function exclude(address account) public onlyOwner {
        require(!isExcluded(account), "CoinToken: Account is already excluded");
        excludeList[account] = true;
    }
    
    function removeExclude(address account) public onlyOwner {
        require(isExcluded(account), "CoinToken: Account is not excluded");
        excludeList[account] = false;
    }
    
    function setBuyTax(uint256 dev, uint256 marketing, uint256 liquidity, uint256 charity,uint256 repurchase) public onlyOwner {
        buyTaxes["dev"] = dev;
        buyTaxes["marketing"] = marketing;
        buyTaxes["liquidity"] = liquidity;
        buyTaxes["charity"] = charity;
        buyTaxes["repurchase"] = repurchase;
    }
    
    function setSellTax(uint256 dev, uint256 marketing, uint256 liquidity, uint256 charity,uint256 repurchase) public onlyOwner {

        sellTaxes["dev"] = dev;
        sellTaxes["marketing"] = marketing;
        sellTaxes["liquidity"] = liquidity;
        sellTaxes["charity"] = charity;
        sellTaxes["repurchase"] = repurchase;
    }
    
    function setTaxWallets(address liquidity,address dev, address marketing, address charity, address repurchase) public onlyOwner {
        taxWallets["liquidity"] = liquidity;
        taxWallets["dev"] = dev;
        taxWallets["marketing"] = marketing;
        taxWallets["charity"] = charity;
        taxWallets["repurchase"] = repurchase;
    }
    
    function enableTax() public onlyOwner {
        require(!taxStatus, "CoinToken: Tax is already enabled");
        taxStatus = true;
    }
    
    function disableTax() public onlyOwner {
        require(taxStatus, "CoinToken: Tax is already disabled");
        taxStatus = false;
    }
    
    function isBlacklisted(address account) public view returns (bool) {
        return blacklist[account];
    }
    
    function isExcluded(address account) public view returns (bool) {
        return excludeList[account];
    }
    
    receive() external payable {}
}