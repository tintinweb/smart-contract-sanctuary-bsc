/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Wallet100k {
     uint256 constant public tokenPriceInitial_ = 0.0075 ether;
     uint256 constant internal tokenPriceIncremental_ = 0.0001 ether;
     
    uint256 constant internal magnitude = 10**19;
    mapping (address => uint256) public _holderBalances;

    mapping (address => uint256) public _holderPaidOUt;
    mapping (address => uint256) public _holderPersonalEth;
    mapping (address => uint256) public _ReferralCommission;
    mapping (address => address) public _referrerMapping;
    mapping (address => uint256) public _DividendMapping;
    mapping (address => uint256) public _IndexMapping;
    uint256 public valueforSale;
    uint256  public tTransferPUblic; 
    uint256  public tfeepublic; 
    uint256  public frDiv;
    address[] public _holderArray;
    uint256 public _existingPrice = tokenPriceInitial_;
    address public owner;
    uint256 public counter =1;
    uint256 public EthStaked;
    mapping(address=>bool) public MonthlyWithdrawMapping;
    mapping (address => uint256) public _MonthDividendMapping;
    uint256 public nextMonthly;
        address public launcher;

    address _admin = 0xf3cB19212D4B2f36D81a343966c5612f6B4FDf57;  //0xf3cB19212D4B2f36D81a343966c5612f6B4FDf57
//    address _admin = 0x582878F1e67E1633aBeF27E0136e03748fCC299d;  //0x582878F1e67E1633aBeF27E0136e03748fCC299d
    uint256 redistribution = 7;
    uint256 direcREferCommission = 3;
    uint256 inDirecREferCommission = 2;
    uint256 monthlyPoolRate = 2;
    uint256 adminFee = 1;
    uint256 SellingDistribution = 5;
    uint256 SellingAdmin = 2;
    uint256 SellingMonthlyBonus = 2;
    uint256 public TotalSupply = 0;
    uint public MonthlyTotalDiv=0;


    event Buy (address buyer, uint256 amount);
    event Sell(address seller,uint256 amount);
    event WithdrawrReferral (address buyer, uint256 amount);    
    event WithDividend (address buyer, uint256 amount);    
   
   
    constructor (){
        owner = msg.sender;
        nextMonthly = block.timestamp + (60*60*24*30);
        launcher = msg.sender;
    }
    
    

    
    function buy(address referrer)public payable {
        
        (
         uint256 tTransfer,
         uint256 dist,
         uint256 drc,
         uint256 Idrc,
         uint256 afee,
         uint _mont) = getTValues(msg.value);
        
         require(msg.value>=0.1 ether,"amount must be greather than 0.001 BNB");
         uint256 price = existingPrice();
         uint256 Purremainder = tTransfer%price;
         uint256 tokenValue = tTransfer - Purremainder;
         uint256 tokenQty = tokenValue / price;
         address indRferrer = _referrerMapping[referrer];
        
        _holderBalances[msg.sender] += tokenQty;
        EthStaked += msg.value;

        if(_IndexMapping[msg.sender]==0){
            _IndexMapping[msg.sender] = counter;
            _holderArray.push(msg.sender);
            counter += 1;
            
        }
            
        
        _ReferralCommission[_admin] += afee;
        
    
        if(referrer != 0x0000000000000000000000000000000000000000)
            {_ReferralCommission[referrer] += drc;
              _referrerMapping[msg.sender] = referrer;
                if(indRferrer != 0x0000000000000000000000000000000000000000){_ReferralCommission[indRferrer] += Idrc;}
                else{_ReferralCommission[_admin]+= Idrc;
                }
            }
        else{_ReferralCommission[_admin]+= drc; 
        
         
        _ReferralCommission[_admin]+= Idrc;}
        

    
        
        TotalSupply += tokenQty;

        processDiv(dist,_mont);

        _existingPrice = _existingPrice + (msg.value*tokenPriceIncremental_/1000000000000000000);
        
        withdrawrReferralAdmin();

        emit Buy(msg.sender,tokenQty);
        
        }
        

    
    function existingPrice() view public returns(uint256){
        if(TotalSupply==0 || _existingPrice < tokenPriceInitial_){return tokenPriceInitial_;}
        else{return _existingPrice;}
    }
    
    function SaleexistingPrice() view public returns(uint256){
        uint256 price1 = tokenPriceInitial_*80/100;
        uint256 price2 = _existingPrice*80/100;
        if(TotalSupply==0 || _existingPrice < tokenPriceInitial_){return price1;}
        else{return price2;}
    }   
    


    function sell(uint256 number) public payable {
        require(_holderBalances[msg.sender]>=number,"amount must be lesser than the balance");
        uint256 valueforPrice = number*existingPrice();
        _existingPrice = _existingPrice -(valueforPrice*tokenPriceIncremental_/1000000000000000000);
        MonthlyWithdrawMapping[msg.sender]=true;
        _holderBalances[msg.sender]-=number;
        TotalSupply -=number;
        valueforSale = number*SaleexistingPrice();
    
        (uint256 tTransfer,uint256 tfee,uint afee,uint mont) = getSValues(valueforSale);
        _ReferralCommission[_admin] += afee;
        tTransferPUblic = tTransfer;
        tfeepublic = tfee;
        payable(msg.sender).transfer(tTransfer);
        EthStaked-=valueforSale;
        processDiv(tfee,mont);


       withdrawrReferralAdmin();        
        emit Sell(msg.sender,number);
    }
    
    

    function processDiv(uint256 tfee,uint256 mont) internal {
        MonthlyTotalDiv+=mont;
        for(uint64 i =0; i<=_holderArray.length-1; i++){
            _DividendMapping[_holderArray[i]] += (tfee*_holderBalances[_holderArray[i]]/TotalSupply);
            _MonthDividendMapping[_holderArray[i]] += (mont*_holderBalances[_holderArray[i]]/TotalSupply);
            
        }
    }

    function withdrawMonthlyDividend(uint256 amount,address _user) internal {
         _MonthDividendMapping[_user]-=amount;
         payable(_user).transfer(amount);
         EthStaked -= amount;
         emit WithDividend(msg.sender,amount);
    }

     function doMonthly() public {
        require(msg.sender==launcher,"You are not authorized");
        nextMonthly = block.timestamp + 60*60*24*30;
        
        for(uint256 i =0; i<_holderArray.length; i++){
            uint256 amo = MonthlyTotalDiv*_holderBalances[_holderArray[i]]/TotalSupply;
            address _user = _holderArray[i];
            if(EthStaked>amo && _MonthDividendMapping[_user]>=amo && !MonthlyWithdrawMapping[_user]){
            withdrawMonthlyDividend(amo,_user);
            MonthlyTotalDiv-=amo;
            MonthlyWithdrawMapping[_user] = false;
            }else{
                MonthlyWithdrawMapping[_user] = false;
            }

         
         }
    }
    
    
    function dividendBalance(address holder) public view returns(uint256) {

        uint256 dividendTopay = _DividendMapping[holder] - _holderPaidOUt[holder];
        return dividendTopay;
    }

    
    function ReferralBalance(address holder) public view returns(uint256) {
        return _ReferralCommission[holder];
    }
    
    function AccountBalance() public view returns(uint256) {
        return EthStaked;
    }
    
 
    function withdrawrReferral(uint256 amount) public payable {
        require(_ReferralCommission[msg.sender] >=amount,"amoutn must not exceed the referral balance");
        _ReferralCommission[msg.sender]-=amount;

        payable(msg.sender).transfer(amount);
        EthStaked -= amount;
        emit WithdrawrReferral(msg.sender,amount);
    }
        
    function withdrawrReferralAdmin() public payable {
        uint256 amount1 = _ReferralCommission[_admin];

        payable(_admin).transfer(amount1);

        EthStaked -= amount1;
        _ReferralCommission[_admin] = 0;

    
    }
    

    function withdrawDividend(uint256 amount) payable public {
        require(dividendBalance(msg.sender)>=amount,"amount is more than the dividend balance");
        _holderPaidOUt[msg.sender] += amount;

         payable(msg.sender).transfer(amount);
         EthStaked -= amount;
         emit WithDividend(msg.sender,amount);
    }
            event WithPersonalEth (address buyer, uint256 amount);


    
    function balanceOf(address holder) public view returns(uint256){
        return _holderBalances[holder];
    }


    function getTValues (uint256 tamount) public view returns (uint256,uint256,uint256,uint256,uint256,uint256){
        uint _mont = tamount * monthlyPoolRate / 100;
        uint256 dist = tamount*redistribution/100;
        uint256 drc = tamount*direcREferCommission/100;
        uint256 Idrc = tamount*inDirecREferCommission/100;
        uint256 afee = tamount*adminFee/100;
        uint256 tTransfer = tamount-(dist+drc+Idrc+afee+_mont);
        return ( tTransfer,dist,drc,Idrc,afee,_mont);
    }
    
    
    function getSValues (uint256 tamount) public view returns (uint256,uint256,uint256,uint256){
        uint256 dist = tamount*SellingDistribution/100;
        uint256 mont = tamount*SellingMonthlyBonus /100;
        uint256 afee = tamount*SellingAdmin/100;
        uint256 tTransfer = tamount-(dist+mont+afee);
        return ( tTransfer,dist,afee,mont);
    }
    

    
    

    
    
}


contract Launcher {

    address public instance;
    constructor(){
    Wallet100k tx1 = new Wallet100k();
    instance = address(tx1);
        
    }

    function doMonthly2()public {
        Wallet100k _inst = Wallet100k(instance);
        _inst.doMonthly();
    }


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
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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