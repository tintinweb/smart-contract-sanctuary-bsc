/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT

/**
 *  Program Name: ReflectorDex
 *  Website     : https://reflectordex.com/
 *  Telegram    : https://t.me/ReflectorDex
 * */

pragma solidity >=0.8.0 <0.8.17;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract ReflectorDex is Ownable, ReentrancyGuard {
    
    struct TokenMaster {
        uint256 supply;
        uint256 dividend;
        address[] walletAddressSet;
        mapping(address => bool) walletAddressList;
    }
    
    struct BalanceMaster {
        uint256 tokenBalance;
        uint256 referralBalance;
        int payOut;
    }
    
    mapping(address => bool) tokenAddressList;

    address[] tokenAddressSet;
    
    
    uint256 constant magnitude = 1e18 ;
    uint256 constant initialPrice = 100000000000;
    uint256 constant incrementPrice = 10000000000;
    uint256 constant dividendFee = 10;

    address constant addZero = address(0);
    
    mapping (address => mapping(address => BalanceMaster)) balanceMaster;
    mapping(address => TokenMaster) tokenMaster;

    event onPurchase(address walletAddress, address tokenAddress, uint256 incomingTokenAmount, uint256 collateralMinted, address referredBy);
    event onSell(address walletAddress, address tokenAddress, uint256 tokenAmountToReceiver, uint256 collateralBurned);
    event onReinvest(address walletAddress, address tokenAddress, uint256 reInvestTokenAmount, uint256 collateralMinted);
    event onWithdraw(address walletAddress, address tokenAddress, uint256 amountToWithdraw);
    event onTokenList(address tokenAddress);
    event onTokenMigrate(address oldtokenAddress, address newtokenAddress, uint256 totalwalletAddress);
    event onUserMigrate(address oldtokenAddress, address newtokenAddress, address walletAddress, uint256 walletIndex);

    function buy(address _referredBy) public nonReentrant payable returns(uint256)
    {
        require(msg.value > 0, "Send coin while creating transaction for investment");
        require(tokenAddressList[addZero] == true, "Coin is not enabled for trading");
        
        if(tokenMaster[addZero].walletAddressList[msg.sender] == false){
            tokenMaster[addZero].walletAddressList[msg.sender] = true;
            tokenMaster[addZero].walletAddressSet.push(msg.sender);
        }
        
        uint256 collateAmount = purchaseCollate(addZero, msg.value, _referredBy);
        return collateAmount;
    }
    
    function buy(address tokenAddress, uint256 tokenAmount, address _referredBy) public nonReentrant returns(uint256)
    {    
        require(tokenAddressList[tokenAddress] == true, "Token is not enabled for trading");
        require(ERC20(tokenAddress).allowance(msg.sender, address(this)) >= tokenAmount, "Please allow this contract to spend sufficent tokens");
        require(ERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenAmount),"Unable to transfer tokens");
        
        if(tokenMaster[tokenAddress].walletAddressList[msg.sender] == false){
            tokenMaster[tokenAddress].walletAddressList[msg.sender] = true;
            tokenMaster[tokenAddress].walletAddressSet.push(msg.sender);
        }
        
        uint256 collateAmount = purchaseCollate(tokenAddress,tokenAmount, _referredBy);
        return collateAmount;
    }
    
    fallback() nonReentrant payable external
    {
        require(msg.value > 0, "Send coin while creating transaction for investment");
        require(tokenAddressList[addZero] == true, "Coin is not enabled for trading");
            
        if(tokenMaster[addZero].walletAddressList[msg.sender] == false){
            tokenMaster[addZero].walletAddressList[msg.sender] = true;
            tokenMaster[addZero].walletAddressSet.push(msg.sender);
        }
        purchaseCollate(addZero, msg.value, addZero);
    }
    
    function reinvest(address tokenAddress) public nonReentrant returns (bool)
    {
        uint256 _dividends = myDividends(tokenAddress, false);
        address _customerAddress = msg.sender;
        balanceMaster[_customerAddress][tokenAddress].payOut +=  (int256) (_dividends * magnitude);
        _dividends += balanceMaster[_customerAddress][tokenAddress].referralBalance;
        balanceMaster[_customerAddress][tokenAddress].referralBalance = 0;
        uint256 _collate = purchaseCollate(tokenAddress, _dividends, addZero);
        
        emit onReinvest(_customerAddress, tokenAddress, _dividends, _collate);
        return true;
    }
    
    function sellAndwithdraw(address tokenAddress) public nonReentrant returns(bool)
    {
        address _customerAddress = msg.sender;
        uint256 _tokens = balanceMaster[_customerAddress][tokenAddress].tokenBalance;
        if(_tokens > 0) sell_(tokenAddress, _tokens);
    
        withdraw_(tokenAddress);
        return true;
    }

    function withdraw(address tokenAddress) public nonReentrant returns(bool)
    {
        withdraw_(tokenAddress);
        return true;
    }
    
    function withdraw_(address tokenAddress) internal returns(bool)
    {
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(tokenAddress, false); // get ref. bonus later in the code
        
        balanceMaster[_customerAddress][tokenAddress].payOut +=  (int256) (_dividends * magnitude);
        _dividends += balanceMaster[_customerAddress][tokenAddress].referralBalance;
        balanceMaster[_customerAddress][tokenAddress].referralBalance = 0;
        
        if (tokenAddress == addZero){
            payable(address(_customerAddress)).transfer(_dividends);
        }
        else{
            ERC20(tokenAddress).transfer(_customerAddress,_dividends);
        }
    
        emit onWithdraw(_customerAddress, tokenAddress, _dividends);
        return true;
    }

    function sell_(address tokenAddress, uint256 _amountOfCollate) internal returns(bool)
    {  
        address _customerAddress = msg.sender;
       
        require(_amountOfCollate <= balanceMaster[_customerAddress][tokenAddress].tokenBalance, "Insufficient collateral balance");
        
        uint256 _collates = _amountOfCollate;
        uint256 _tokens = collateralToToken_(tokenAddress, _collates);
        uint256 _dividends = SafeMath.div(_tokens, dividendFee);
        uint256 _taxedToken = SafeMath.sub(_tokens, _dividends);
        
        tokenMaster[tokenAddress].supply = SafeMath.sub(tokenMaster[tokenAddress].supply, _collates);
        balanceMaster[_customerAddress][tokenAddress].tokenBalance = SafeMath.sub(balanceMaster[_customerAddress][tokenAddress].tokenBalance, _collates);
        
        int256 _updatedPayouts = (int256) (tokenMaster[tokenAddress].dividend * _collates + (_taxedToken * magnitude));
        balanceMaster[_customerAddress][tokenAddress].payOut -= _updatedPayouts;       
        
        if (tokenMaster[tokenAddress].supply > 0) {
            tokenMaster[tokenAddress].dividend = SafeMath.add(tokenMaster[tokenAddress].dividend, (_dividends * magnitude) / tokenMaster[tokenAddress].supply);
        }
        
        emit onSell(_customerAddress, tokenAddress, _taxedToken, _collates);
        return true;
    }

    function sell(address tokenAddress, uint256 _amountOfCollate) public nonReentrant returns(bool)
    {  
        sell_(tokenAddress, _amountOfCollate);
        return true;
    }
        
    function buyPrice(address tokenAddress) public view returns(uint256) {
        if (tokenAddressList[tokenAddress] == false){
            return 0;
        }
        else if(tokenMaster[tokenAddress].supply == 0){
            return initialPrice + incrementPrice;
        }
        else{
            uint256 _token = collateralToToken_(tokenAddress, 1e18);
            uint256 _dividends = SafeMath.div(_token, dividendFee);
            uint256 _taxedToken = SafeMath.add(_token, _dividends);
            return _taxedToken;
        }
    }
    
    function sellPrice(address tokenAddress) public view returns(uint256) {
        if (tokenAddressList[tokenAddress] == false){
            return 0;
        }
        else if(tokenMaster[tokenAddress].supply == 0){
            return initialPrice - incrementPrice;
        }
        else {
            uint256 _token = collateralToToken_(tokenAddress, 1e18);
            uint256 _dividends = SafeMath.div(_token, dividendFee);
            uint256 _taxedToken = SafeMath.sub(_token, _dividends);
            return _taxedToken;
        }
    }

    function tokentoCollateral_(address tokenAddress, uint256 amount) internal view returns(uint256)
    {
        uint256 _tokenPriceInitial = initialPrice * 1e18;
        uint256 tokenSupply_ = tokenMaster[tokenAddress].supply;
        uint256 tokenPriceIncremental_ = incrementPrice;
        
        uint256 _tokensReceived = 
         (
            (
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial**2)
                            +
                            (2*(tokenPriceIncremental_ * 1e18)*(amount * 1e18))
                            +
                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
                            +
                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
                        )
                    ), _tokenPriceInitial
                )
            )/(tokenPriceIncremental_)
        )-(tokenSupply_)
        ;
  
        return _tokensReceived;
    }
    
    function collateralToToken_(address tokenAddress, uint256 _tokens) internal view returns(uint256)
    {
        uint256 tokens_ = _tokens + 1e18 ;
        uint256 _tokenSupply = tokenMaster[tokenAddress].supply + 1e18;
        uint256 tokenPriceInitial_ = initialPrice;
        uint256 tokenPriceIncremental_ = incrementPrice;
        
        uint256 _etherReceived =
        (
            SafeMath.sub(
                (
                    (
                        (
                            tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
                        )-tokenPriceIncremental_
                    )*(tokens_ - 1e18)
                ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
            )
        /1e18);
        
        return _etherReceived;
    }
    
    function calculateCollateReceived(address tokenAddress, uint256 _tokenAmount) public view returns(uint256)
    {
        uint256 _dividends = SafeMath.div(_tokenAmount, dividendFee);
        uint256 _taxedToken = SafeMath.sub(_tokenAmount, _dividends);
        uint256 _amountOfCollatral = tokentoCollateral_(tokenAddress, _taxedToken);
        
        return _amountOfCollatral;
    }
     
    function calculateTokenReceived(address tokenAddress, uint256 _collateToSell) public view returns(uint256)
    {
        require(_collateToSell <= tokenMaster[tokenAddress].supply, "Sell tokens quantity must be less that total supply");
        uint256 _token = collateralToToken_(tokenAddress, _collateToSell);
        uint256 _dividends = SafeMath.div(_token, dividendFee);
        uint256 _taxedToken = SafeMath.sub(_token, _dividends);
        return _taxedToken;
    }  
    
    function purchaseCollate(address tokenAddress, uint256 _incomingToken, address _referredBy) internal returns(uint256)
    {
        address _customerAddress = msg.sender;
        uint256 _undividedDividends = SafeMath.div(_incomingToken, dividendFee);
        uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint256 _taxedToken = SafeMath.sub(_incomingToken, _undividedDividends);
        uint256 _amountOfCollate = tokentoCollateral_(tokenAddress,_taxedToken);
        uint256 _fee = _dividends * magnitude;
      
        require(_amountOfCollate > 0 && (SafeMath.add(_amountOfCollate,tokenMaster[tokenAddress].supply) > tokenMaster[tokenAddress].supply));
        
        if(
            _referredBy != addZero &&
            _referredBy != _customerAddress &&       
            tokenMaster[tokenAddress].walletAddressList[_referredBy] == true
        ){
            balanceMaster[_referredBy][tokenAddress].referralBalance = SafeMath.add(balanceMaster[_referredBy][tokenAddress].referralBalance, _referralBonus);
        } else {
            _dividends = SafeMath.add(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }
        
        if(tokenMaster[tokenAddress].supply > 0){
            tokenMaster[tokenAddress].supply = SafeMath.add(tokenMaster[tokenAddress].supply, _amountOfCollate);
            tokenMaster[tokenAddress].dividend += (_dividends * magnitude / (tokenMaster[tokenAddress].supply));
            _fee = _fee - (_fee-(_amountOfCollate * (_dividends * magnitude / (tokenMaster[tokenAddress].supply))));
        
        } else {
            tokenMaster[tokenAddress].supply = _amountOfCollate;
            tokenMaster[tokenAddress].dividend += (_dividends * magnitude / (tokenMaster[tokenAddress].supply));
            _fee = _fee - (_fee-(_amountOfCollate * (_dividends * magnitude / (tokenMaster[tokenAddress].supply))));
        }
        
        balanceMaster[_customerAddress][tokenAddress].tokenBalance = SafeMath.add(balanceMaster[_customerAddress][tokenAddress].tokenBalance, _amountOfCollate);
        int256 _updatedPayouts = (int256) ((tokenMaster[tokenAddress].dividend * _amountOfCollate) - _fee);
        balanceMaster[_customerAddress][tokenAddress].payOut += _updatedPayouts;
        
        emit onPurchase(_customerAddress, tokenAddress, _incomingToken, _amountOfCollate, _referredBy);
        return _amountOfCollate;
    }
    
    function totalTokenBalance(address tokenAddress) public view returns(uint256)
    {   
        if (tokenAddress == addZero){
            return address(this).balance;
        }
        else{
            return ERC20(tokenAddress).balanceOf(address(this));
        }
    }
    
    function totalSupply(address tokenAddress) public view returns(uint256)
    {
        return tokenMaster[tokenAddress].supply;
    }
    
    function myTokens(address tokenAddress) public view returns(uint256)
    {
        address _customerAddress = msg.sender;
        return balanceOf(tokenAddress, _customerAddress);
    }
    
    function myDividends(address tokenAddress, bool _includeReferralBonus) public view returns(uint256)
    {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(tokenAddress,_customerAddress) + balanceMaster[_customerAddress][tokenAddress].referralBalance : dividendsOf(tokenAddress, _customerAddress) ;
    }
    
    function balanceOf(address tokenAddress, address _customerAddress) view public returns(uint256)
    {
        return balanceMaster[_customerAddress][tokenAddress].tokenBalance;
    }
    
    function dividendsOf(address tokenAddress, address _customerAddress) view public returns(uint256)
    {
        return (uint256) ((int256)(tokenMaster[tokenAddress].dividend * balanceMaster[_customerAddress][tokenAddress].tokenBalance) - balanceMaster[_customerAddress][tokenAddress].payOut) / magnitude;
    }
    
    function tokenList() public view returns (address [] memory){
        return tokenAddressSet;
    }
    
    function walletList(address tokenAddress) public view returns (address [] memory){
        return tokenMaster[tokenAddress].walletAddressSet;
    }
    
    function listToken(address tokenAddress) public onlyOwner returns(bool){
        if(tokenAddressList[tokenAddress]==false){
            tokenAddressList[tokenAddress]=true ;
            tokenMaster[tokenAddress].supply = 0;
            tokenMaster[tokenAddress].dividend = 0;   
 
            tokenAddressSet.push(tokenAddress);
        }
        
        emit onTokenList(tokenAddress);
        return true;
    }

    function migrateTokens(address tokenAddress, address newtokenAddress, uint startIndex, uint endIndex) public onlyOwner returns(bool)
    {
        require(tokenAddressList[tokenAddress] == true, "Tokens must be listed on exchange");
        if (endIndex > tokenMaster[tokenAddress].walletAddressSet.length){
            endIndex = tokenMaster[tokenAddress].walletAddressSet.length;
        }
        require(startIndex < tokenMaster[tokenAddress].walletAddressSet.length && endIndex <= tokenMaster[tokenAddress].walletAddressSet.length && startIndex< endIndex);
        
        if(tokenAddressList[newtokenAddress]==false)
        {
            tokenAddressList[newtokenAddress]=true ;
            tokenMaster[newtokenAddress].supply = tokenMaster[tokenAddress].supply;
            tokenMaster[newtokenAddress].dividend = tokenMaster[tokenAddress].dividend;

            tokenAddressSet.push(newtokenAddress);
            emit onTokenMigrate(tokenAddress, newtokenAddress, tokenMaster[tokenAddress].walletAddressSet.length);
        }

        for(uint256 i = startIndex; i < endIndex; i++)
        {
                if(tokenMaster[newtokenAddress].walletAddressList[tokenMaster[tokenAddress].walletAddressSet[i]] == false){
                    tokenMaster[newtokenAddress].walletAddressList[tokenMaster[tokenAddress].walletAddressSet[i]] = true;
                    tokenMaster[newtokenAddress].walletAddressSet.push(tokenMaster[tokenAddress].walletAddressSet[i]);
                }
                balanceMaster[tokenMaster[tokenAddress].walletAddressSet[i]][newtokenAddress].tokenBalance = balanceMaster[tokenMaster[tokenAddress].walletAddressSet[i]][tokenAddress].tokenBalance;
                balanceMaster[tokenMaster[tokenAddress].walletAddressSet[i]][newtokenAddress].referralBalance = balanceMaster[tokenMaster[tokenAddress].walletAddressSet[i]][tokenAddress].referralBalance;
                balanceMaster[tokenMaster[tokenAddress].walletAddressSet[i]][newtokenAddress].payOut = balanceMaster[tokenMaster[tokenAddress].walletAddressSet[i]][tokenAddress].payOut;

                emit onUserMigrate(tokenAddress,newtokenAddress, tokenMaster[tokenAddress].walletAddressSet[i], i);
        }
        
        return true;
    }
    
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint256 supply);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}