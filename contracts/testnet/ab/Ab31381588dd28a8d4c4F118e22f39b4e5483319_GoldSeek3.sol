/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT



pragma solidity ^0.8.0;


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view  returns (uint8);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract GoldSeek3 {
     uint256 constant public tokenPriceInitial_ = 0.00002 ether;
     uint256 constant internal tokenPriceIncremental_ = 0.000001 ether;
     IERC20 BUSD = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
     //IERC20 BUSD = IERC20(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);
     uint256 constant internal magnitude = 10**19;
    mapping (address => uint256) public _holderBalances;
    uint256 public nextMonthly;
    mapping (address => uint256) public _holderPaidOUt;
    mapping (address => address[]) public userDirectReferral;

    mapping (address => uint256) public _holderPersonalEth;
    mapping (address => uint256) public _ReferralCommission;
    mapping (address => address) public _referrerMapping;
    mapping (address => uint256) public _DividendMapping;
    mapping (address => uint256) public _MonthDividendMapping;
    mapping (address => uint256) public _IndexMapping;
    address[] public _holderArray;
    uint256 public _existingPrice = tokenPriceInitial_;
    address public owner;
    uint256 public counter =1;
    uint256 public EthStaked;
    mapping(address=>bool) public MonthlyWithdrawMapping;
    

    address _admin = 0xf3cB19212D4B2f36D81a343966c5612f6B4FDf57;  //0xf3cB19212D4B2f36D81a343966c5612f6B4FDf57
//    address _admin2 = 0x582878F1e67E1633aBeF27E0136e03748fCC299d;  //0x582878F1e67E1633aBeF27E0136e03748fCC299d
//    uint256 commission = 25;
    uint256 redistribution = 7;
    uint256 direcREferCommission = 5;
    uint256 inDirecREferCommission = 2;
    uint256 monthlyPoolRate = 3;
    uint256 adminFee = 1;
    uint256 SellingDistribution = 5;
    uint256 SellingAdmin = 2;
    uint256 SellingMonthlyBonus = 2;
    uint256 public TotalSupply = 0;

    
    constructor (){
        owner = msg.sender;
        nextMonthly = block.timestamp + (60*3);
    }
    
    
    event Buy (address buyer, uint256 amount);


    function buy(address referrer,uint _busd)public  {
        BUSD.transferFrom(msg.sender,address(this),_busd);
        (
          uint256 tTransfer,
          uint256 dist,
         uint256 drc,
         uint256 Idrc,
         uint256 afee,uint256 mont) = getTValues(_busd);
        
         require(_busd>=0.1 ether,"amount must be greather than 0.1 BUSD");
         uint256 price = existingPrice();
         uint256 Purremainder = tTransfer%price;
         uint256 tokenValue = tTransfer - Purremainder;
         uint256 tokenQty = tokenValue / price;
         address indRferrer = _referrerMapping[referrer];
        
        _holderBalances[msg.sender] += tokenQty;
        EthStaked += _busd;
        userDirectReferral[referrer].push(msg.sender);

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

        processDiv(dist,mont);

        _existingPrice = _existingPrice + (_busd*tokenPriceIncremental_/1000000000000000000);
        
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
    
    uint256 public valueforSale;
    uint256  public tTransferPUblic; 
    uint256  public tfeepublic; 
    uint256  public frDiv;
    event Sell(address seller,uint256 amount);


    function getRefarray(address _user) public view returns (address[] memory){
        return userDirectReferral[_user];
    }


    function sell(uint256 number) public  {
        require(_holderBalances[msg.sender]>=number,"amount must be lesser than the balance");
         _holderBalances[msg.sender]-=number;
         MonthlyWithdrawMapping[msg.sender]=true;
         TotalSupply -=number;
         valueforSale = number*SaleexistingPrice();
         uint256 valueforPrice = number*existingPrice();    
        
         (
           uint tTransfer, uint dist,uint afee,uint mont) = getSValues(valueforSale);
          _ReferralCommission[_admin] += afee;
//        tTransferPUblic = tTransfer;
//        tfeepublic = tfee;
         
//        _holderPersonalEth[msg.sender] += tTransfer;
//        _holderEthStaked[msg.sender] -= valueforSale;
        BUSD.transfer(msg.sender,tTransfer);
        EthStaked -= number;
        processDiv(dist,mont);
        _existingPrice = _existingPrice -(valueforPrice*tokenPriceIncremental_/1000000000000000000);
       withdrawrReferralAdmin();
        
        emit Sell(msg.sender,number);
    }
    
    uint public MonthlyTotalDiv=0;

    function processDiv(uint256 tfee,uint256 mont) internal {
        MonthlyTotalDiv+=mont;
        for(uint64 i =0; i<=_holderArray.length-1; i++){
            _DividendMapping[_holderArray[i]] += (tfee*_holderBalances[_holderArray[i]]/TotalSupply);
            _MonthDividendMapping[_holderArray[i]] += (mont*_holderBalances[_holderArray[i]]/TotalSupply);
            
        }
    }
    
    
    function dividendBalance(address holder) public view returns(uint256) {

        uint256 dividendTopay = _DividendMapping[holder] - _holderPaidOUt[holder];
        return dividendTopay;
    }


   
    
    //0xb27A5715DeE0B91CC60da06c1bb860aBa44DB804
    
    function ReferralBalance(address holder) public view returns(uint256) {
        return _ReferralCommission[holder];
    }
    
    function AccountBalance() public view returns(uint256) {
        return EthStaked;
    }
    
    event WithdrawrReferral (address buyer, uint256 amount);
    
    
    function withdrawrReferral(uint256 amount) public  {
    require(_ReferralCommission[msg.sender] >=amount,"amoutn must not exceed the referral balance");
    _ReferralCommission[msg.sender]-=amount;

    //(msg.sender).transfer(amount);
    BUSD.transfer(msg.sender,amount);
    EthStaked -= amount;
    emit WithdrawrReferral(msg.sender,amount);
    }
    
    function withdrawrReferralAdmin() public  {
    uint256 amount1 = _ReferralCommission[_admin] / 2;
    uint256 amount2 = _ReferralCommission[_admin] / 2;
    // (_admin).transfer(amount1);
    // (_admin2).transfer(amount2);
    BUSD.transfer(_admin,amount1);
    BUSD.transfer(_admin,amount2);
    EthStaked -= (amount1+amount2);
    _ReferralCommission[_admin] = 0;

    
    }
    
        event WithDividend (address buyer, uint256 amount);

    function withdrawDividend(uint256 amount) public {
        require(dividendBalance(msg.sender)>=amount,"amount is more than the dividend balance");
        _holderPaidOUt[msg.sender] += amount;

         //(msg.sender).transfer(amount);
         BUSD.transfer(msg.sender,amount);
         EthStaked -= amount;
         emit WithDividend(msg.sender,amount);
    }

    function withdrawMonthlyDividend(uint256 amount,address _user) public {
//        require(dividendBalance(_user)>=amount,"amount is more than the dividend balance");
//        _holderPaidOUt[] += amount;

         //(msg.sender).transfer(amount);
         _MonthDividendMapping[_user]-=amount;
         BUSD.transfer(_user,amount);
         EthStaked -= amount;
         emit WithDividend(msg.sender,amount);
    }
            event WithPersonalEth (address buyer, uint256 amount);
    


    function doMonthly() public {
        nextMonthly = block.timestamp + 60*3;
        
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

    function withdrawPersonalEth(uint256 amount) public {
        require(_holderPersonalEth[msg.sender]>=amount,"amount is more than the personal balance");
        _holderPersonalEth[msg.sender] -= amount;
        BUSD.transfer(msg.sender,amount);
//         (msg.sender).transfer(amount);
         EthStaked -= amount;
         emit WithPersonalEth(msg.sender,amount);
    }
    
    
function balanceOf(address holder) public view returns(uint256){
        return _holderBalances[holder];
    }


function getTValues (uint256 tamount) public view returns (uint256,uint256,uint256,uint256,uint256,uint256){
        //uint256 tfee = tamount*commission/100;
        uint256 dist = tamount*redistribution/100;
        uint256 drc = tamount*direcREferCommission/100;
        uint256 Idrc = tamount*inDirecREferCommission/100;
        uint256 mont = tamount*monthlyPoolRate /100;
        uint256 afee = tamount*adminFee/100;
        uint256 tTransfer = tamount-(dist+drc+Idrc+mont+afee);
        return ( tTransfer,dist,drc,Idrc,afee,mont);
    }
    
    
    function getSValues (uint256 tamount) public view returns (uint256,uint256,uint256,uint256){
        uint256 dist = tamount*SellingDistribution/100;
        uint256 mont = tamount*SellingMonthlyBonus /100;
        uint256 afee = tamount*SellingAdmin/100;
        uint256 tTransfer = tamount-(dist+mont+afee);
        return ( tTransfer,dist,afee,mont);
    }
    

   function withdrawBUSD() public {
       BUSD.transfer(msg.sender,BUSD.balanceOf(address(this)));
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

/**
* Also in memory of JPK, miss you Dad.
*/
    
}