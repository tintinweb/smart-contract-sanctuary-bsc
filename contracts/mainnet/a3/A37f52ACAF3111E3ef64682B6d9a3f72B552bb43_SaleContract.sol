/**
 *Submitted for verification at BscScan.com on 2023-01-22
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

interface DAOToken is IERC20{
    function unlockedBalanceOf(address account) external view returns (uint256);
    function lockedTransfer(address recipient, uint256 amount) external returns (bool);
    function unlockAllTokens(bool unlock) external returns(bool);
    function saleApprove(address sender, address spender, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address public _owner;
    address private _previousOwner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }


}

contract SaleContract is Context, Ownable, ReentrancyGuard {

    address public tokenAddress;
    address public multisigAddress;
    address public BUSDaddress;
    DAOToken token;
    IERC20 BUSD;
    uint256 constant public decimals = 10**18;

    bool public purchaseEnabled = false;
    bool public reversePurchaseEnabled = false;
    bool public preSaleOnly = false;
    
    mapping (address => uint256) public whitelist;

    struct Category {
        uint256 bonus;
        uint256 tokencount;
    }

    string public saleRoundName;
    uint256 public startingTokens;
    uint256 public startingTokensWithoutBonus;
    uint256 public salePrice;
    Category[3] public categories;

    string public reverseSaleRoundName;
    uint256 public reverseSalePrice;
    uint256 public tokensToBeBought;

    /**
     * Array for storing all vesting stages with structure defined above.
     */

    event PurchaseEnabled (bool purchaseEnabled);
    event ReversePurchaseEnabled (bool reversePurchaseEnabled);
    event PresaleEnabled (bool presaleEnabled);
    event WithdrawAllEther (uint256 amount, address to);
    event WithdrawAllTokens (uint256 amount, address to);
    event SaleCreated (Category[3] categories, uint256 salePrice, string saleRoundName);
    event ReverseSaleCreated (uint256 reverseSalePrice, string reverseSaleRoundName, uint256 tokensToBeBought);
    event TokensPurchased(uint256 paidBUSD, uint256 receivedtokens, string referralcode, address account);
    event TokensSold(uint256 paidtokens, uint256 receivedBUSD, address account);

    constructor (address _tokenaddress, address _multisigaddress, address _BUSDaddress) payable {
        tokenAddress = _tokenaddress;
        multisigAddress = _multisigaddress;
        BUSDaddress = _BUSDaddress;
        _owner = _msgSender();
        token = DAOToken(tokenAddress);
        BUSD = IERC20(BUSDaddress);
    }

    function addWhitelist(address[] calldata listOfAddresses) external onlyOwner() returns(uint256){
        uint256 count = 0;
        uint256 len = listOfAddresses.length;
        while(count < len){
            whitelist[listOfAddresses[count]] = 1;
            count++;
        }
        return count;
    }

    function removeWhitelist(address[] calldata listOfAddresses) external onlyOwner() returns(uint256){
        uint256 count = 0;
        uint256 len = listOfAddresses.length;
        while(count < len){
            whitelist[listOfAddresses[count]] = 0;
            count++;
        }
        return count;
    }

    function createNewSale(Category[3] calldata newCategories, string calldata roundName, uint256 price) external onlyOwner() {
        require(purchaseEnabled == false, "Close current sale first");
        uint256 currentBalance = token.unlockedBalanceOf(address(this)); //Make sure this is unlocked tokens only
        (uint256 tokensRequired, uint256 tokensListed) = checkParameters(newCategories);
        if(currentBalance < tokensRequired){
            tokensRequired = tokensRequired - currentBalance;
            startingTokens = tokensRequired + currentBalance;
            require(token.saleApprove(_msgSender(), address(this), tokensRequired) == true,"Allowance Approval failed");
            require(token.transferFrom(_owner,address(this),tokensRequired),"Token Transfer Failed");
        }
        else startingTokens = currentBalance;
        uint256 count = 0;
        while(count<3){
            categories[count] = newCategories[count];
            count++;
        }
        saleRoundName = roundName;
        startingTokensWithoutBonus = tokensListed;
        salePrice = price;
        require(token.unlockAllTokens(false) == false, "Could not lock tokens");
        emit SaleCreated(newCategories, price, roundName);
    }

    function checkParameters(Category[3] calldata newCategories) internal pure returns(uint256, uint256){
        uint256 count = 0;
        uint256 total = 0;
        uint256 withoutbonus = 0;
        while(count<3){
            total = total + ((newCategories[count].tokencount * (100 + newCategories[count].bonus))/100);
            withoutbonus = withoutbonus + newCategories[count].tokencount;
            count++;
        }
        return (total, withoutbonus);
    }

/*Purchases tokens using amount BUSD with the option to approve allowance within this function call*/
    function purchaseToken(uint256 amount, string calldata referralCode) external nonReentrant() {
        require(purchaseEnabled == true, "Sale is inactive");
        require(amount > 0 , "You cannot buy 0 tokens -_-");
        address sender = _msgSender();
        if(preSaleOnly){
            Category memory cats = categories[0];
            require(whitelist[sender] != 0, "You are not whitelisted for presale");
            uint256 purchasedtokens = (amount*decimals)/salePrice;
            require(cats.tokencount >= purchasedtokens, "Insufficient tokens in presale");
            categories[0].tokencount = cats.tokencount - purchasedtokens;
            purchasedtokens = (purchasedtokens * (100 + cats.bonus))/100;  //Get total tokens, including bonus tokens
            require(BUSD.transferFrom(sender,multisigAddress,amount), "BUSD Transfer Failed"); //Transfer BUSD using this allowance
            require(token.lockedTransfer(sender, purchasedtokens), "Token Transfer Failed"); // Perform a transfer of locked tokens to senders wallet
            emit TokensPurchased(amount, purchasedtokens, referralCode, sender);  
        }
        else{
            Category[3] storage cats = categories;
            uint256 purchasedtokens = (amount*decimals)/salePrice;
            uint256 tokensToBeTransferred = 0;
            uint256 count = 0;
            do{
                if(cats[count].tokencount == 0){
                    count++;
                }
                else if(cats[count].tokencount >= purchasedtokens){
                    tokensToBeTransferred = tokensToBeTransferred + (purchasedtokens * (100 + cats[count].bonus))/100;
                    categories[count].tokencount = cats[count].tokencount - purchasedtokens;
                    purchasedtokens = 0;
                    break;
                }
                else {
                    tokensToBeTransferred = tokensToBeTransferred + (cats[count].tokencount * (100 + cats[count].bonus))/100;
                    purchasedtokens = purchasedtokens - cats[count].tokencount;
                    categories[count].tokencount = 0;
                }     
            }while(count<3);
            require(purchasedtokens == 0, "Insufficient tokens in contract");
            require(BUSD.transferFrom(msg.sender,multisigAddress,amount), "BUSD Transfer Failed"); //Transfer BUSD using this allowance
            require(token.lockedTransfer(sender, tokensToBeTransferred), "Token Transfer Failed"); // Perform a transfer of locked tokens to senders wallet
            emit TokensPurchased(amount, tokensToBeTransferred, referralCode, sender); 
        }    
    }

/*Calculates current expected tokens that would be received by spending amount BUSD. Actual tokens received are subject to availability of tokens in the contract*/
    function calculateExpectedTokens(uint256 amount) external view returns(uint256){
        if(preSaleOnly){
            Category memory cats = categories[0];
            require(whitelist[_msgSender()] != 0, "You are not whitelisted for presale");
            uint256 purchasedtokens = (amount*decimals)/salePrice;
            require(cats.tokencount >= purchasedtokens, "Insufficient tokens in presale");
            return (purchasedtokens * (100 + cats.bonus))/100;  //Get total tokens, including bonus tokens
        }
        else{
            Category[3] memory cats = categories;
            uint256 purchasedtokens = (amount*decimals)/salePrice;
            uint256 tokensToBeTransferred = 0;
            uint256 count = 0;
            while(count<3){
                if(cats[count].tokencount == 0){
                    count++;
                }
                else if(cats[count].tokencount >= purchasedtokens){
                    tokensToBeTransferred = tokensToBeTransferred + (purchasedtokens * (100 + cats[count].bonus))/100;
                    cats[count].tokencount = cats[count].tokencount - purchasedtokens;
                    purchasedtokens = 0;
                    break;
                }
                else {
                    tokensToBeTransferred = tokensToBeTransferred + (cats[count].tokencount * (100 + cats[count].bonus))/100;
                    purchasedtokens = purchasedtokens - cats[count].tokencount;
                    cats[count].tokencount = 0;
                }     
            }
            require(purchasedtokens == 0, "Insufficient tokens in contract");
            return tokensToBeTransferred;
        }       
    }

    function createNewReverseSale(string calldata _roundName, uint256 _price, uint256 _tokens) external onlyOwner(){
        require(reversePurchaseEnabled == false, "Disable current reverse sale");
        reverseSaleRoundName = _roundName;
        reverseSalePrice = _price;
        tokensToBeBought = _tokens;
        uint256 requiredBUSD = (_tokens * _price)/decimals;
        require(BUSD.transferFrom(msg.sender,address(this),requiredBUSD),"BUSD Transfer Failed");
        emit ReverseSaleCreated(reverseSalePrice, reverseSaleRoundName, tokensToBeBought);
    }

    function sellTokensForBUSD(uint256 amount) external nonReentrant(){
        address sender = _msgSender();
        require(reversePurchaseEnabled == true, "Reverse Sale is inactive");
        require(amount <= tokensToBeBought, "Insufficient tokens for reverse sale");
        uint256 requiredBUSD = (amount * reverseSalePrice)/decimals;
        tokensToBeBought = tokensToBeBought - amount;
        require(token.saleApprove(sender, address(this), amount) == true,"Allowance Approval failed");
        require(token.transferFrom(sender,address(0),amount),"Token Transfer Failed");
        require(BUSD.transfer(sender, requiredBUSD),"BUSD Transfer Failed");
        emit TokensSold(amount, requiredBUSD, sender);
    }

    function setReversePurchaseEnabled(bool _enabled) external onlyOwner() {
        if(_enabled == false){
            reverseSaleRoundName = "No Reverse Sale Ongoing";
            tokensToBeBought = 0;
            reversePurchaseEnabled = _enabled;
            withdrawAllBUSD();
        }
        else{
            require(tokensToBeBought != 0, "Sale already cancelled. Start new sale");
        reversePurchaseEnabled = _enabled;
        }
        emit ReversePurchaseEnabled(reversePurchaseEnabled);
    }

    function setPurchaseEnabled(bool _enabled) external onlyOwner() { //Open up sale or close existing sale permanently
        if(_enabled == false){
            saleRoundName = "No Sale Ongoing";
            startingTokens = 0;
            startingTokensWithoutBonus = 0;
        }
        if(_enabled == true){
            require(startingTokensWithoutBonus != 0, "Sale already cancelled. Start new sale");
        }
        purchaseEnabled = _enabled;
        emit PurchaseEnabled(purchaseEnabled);
    }

    function setPresaleEnabled(bool _enabled) external onlyOwner() {
        preSaleOnly = _enabled;
        emit PresaleEnabled(preSaleOnly);
    }

    //to receive BNB
    
    receive() external payable {}

    function withdrawAllEth() public onlyOwner returns (uint256 amount){
        uint256 funds = address(this).balance;
        payable(_owner).transfer(funds);
        emit WithdrawAllEther(funds, _owner);
        return funds;
    }

    function withdrawAllTokens() public onlyOwner returns (uint256){
        require(purchaseEnabled == false, "Cannot withdraw tokens during sale");
        uint256 funds = token.balanceOf(address(this));
        token.transfer(_owner, funds);
        emit WithdrawAllTokens(funds, _owner);
        return funds;
    }

    function withdrawAllBUSD() public onlyOwner returns (uint256){
        require(reversePurchaseEnabled == false, "Cannot withdraw tokens during sale");
        uint256 funds = BUSD.balanceOf(address(this));
        BUSD.transfer(_owner, funds);
        emit WithdrawAllTokens(funds, _owner);
        return funds;
    }

    function rescueBEP20Token(address tokencontract, address to) external onlyOwner() returns(bool returned) {
        require(tokencontract != tokenAddress, "Use withdrawAllTokens Function");
        require(tokencontract != BUSDaddress, "Use withdrawAllTokens Function");
        IERC20 rescuedContract = IERC20(tokencontract);
        require(rescuedContract.transfer(to, rescuedContract.balanceOf(address(this))), "Token Address is incorrect or not ERC20");
        return true;
    }

}