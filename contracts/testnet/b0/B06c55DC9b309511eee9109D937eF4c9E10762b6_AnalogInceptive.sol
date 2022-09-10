/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }


    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }


    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function burn(uint256 value) external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}

contract AnalogInceptive  {

   using SafeMath for uint256;
    address  public owner;

    struct Phase {
        string name;
        uint256 startBlock;
        uint256 endBlock;
        uint256 HCAmount;
        uint256 basePrice;
        uint256 totalTokenRealesed;
    }

    struct History {
        uint8 phaseId;
        uint256 amount;
        uint256 price;
        uint256 blockNumber;
    }

    struct User {
        History[] history;
        uint256 ttlPurchasedAmt;
        uint256 setreferalId;
        address refralAddress;
    }

    struct user {
       bool refered; 
       address refered_by;
       uint256 tokenpurchased;
       uint256 totalPayment;
       address level_1 ;
       uint256 lvl1ReferalCommisioned;
       address level_2 ;
       uint256 lvl2ReferalCommisioned;
       address level_3 ;
       uint256 lvl3ReferalCommisioned;
    }  
    
      struct Links {
       
        string [] links;
    }


    mapping(address => Links) private  usersLink;
    mapping(address => user) public setUser;
    mapping(uint8 => Phase) public phases;
    mapping(address =>User) public users;
    IERC20 public inrXToken;
    uint256 public totalNode =10; 
    uint256  TotalDistributionToken = 200000000;
    uint256  public TotalNodeSold ;
    uint256  public TotalNodeRemaining = 10;
    uint256 public tokenInOneNode =20000000;
    uint256 public TotalTokenSoldLimit;
    uint256  public TotalDistribution = 150000000;
    uint256 setId = 400000;


    struct validator{
            uint256   ValidatorTotalPurchased;
            uint256   ValidatorTotalPayed;
    }
    struct UserBuyed {
        uint256  UserTotalPrivateToken;
        uint256  UserTotalAmountPaid;
       
    }
        struct UserGifted{

        uint256 AmountGifted;
        address UserAddreess;
        uint256 UserReveneGenrated;
        bool IsUserWithdrwalAmount; 
        uint256 UserTokenRelasingTIme;
        uint256 UserClaimedToken;
        uint256 userMontlyLimit;
    }
        struct refralUserDetail{
        uint256 Lvl1Income;
        uint256 Lvl2Income;
        uint256 Lvl3Income;

    }
     mapping(uint256 => address) public idToAddress;   
    mapping (address => refralUserDetail) public SetRefralAmountDetail;
    mapping(address  => UserGifted)  public  UserSetAmount ;
    mapping(address => validator)public  validatorDetail;
    mapping(address => UserBuyed) public UserRecord;

    constructor(IERC20 _inrX, address payable ownerAddress) {
        owner = ownerAddress;  
        inrXToken = _inrX;

        phases[1].name="Gensis";
        phases[1].HCAmount=300 ;     
        phases[1].basePrice=1 * 1e18; 


        phases[2].name="Escaled";
        phases[2].HCAmount=400  ;     
        phases[2].basePrice=2 * 1e18; 


        phases[3].name="Revolt";
        phases[3].HCAmount=500  ;     
        phases[3].basePrice=4 * 1e18; 

        phases[4].name="Momentum";
        phases[4].HCAmount=300 ;     
        phases[4].basePrice=8 * 1e18; 

        phases[5].name="Markle";
        phases[5].HCAmount=400  ;     
        phases[5].basePrice=16 * 1e18; 
            
        phases[6].name="Exos";
        phases[6].HCAmount=500 ;     
        phases[6].basePrice=32 *1e18;


        phases[7].name="Integration";
        phases[7].HCAmount=600;     
        phases[7].basePrice=64 * 1e18; 
    }

    modifier onlyOwner {
      require(msg.sender == owner , "Only Owner Can Perform This Action");
      _;
    }

    function buyAna(uint256 _amount) public  returns(bool) {
        uint8 phaseId = getCurrentPhase();
        uint256 crntPrice = currentPrice();
        uint256 _inrxAmount = crntPrice.mul(_amount).div(1e18);
        require(phases[phaseId].totalTokenRealesed.add(_amount)<=phases[phaseId].HCAmount,"phase Ana sold out!");
        require(inrXToken.allowance(msg.sender,address(this))>=_inrxAmount,"allowance Exceed!");
        require(inrXToken.balanceOf(msg.sender)>=_inrxAmount,"allowance Exceed!");
        inrXToken.transferFrom(msg.sender,address(this),_inrxAmount);
        phases[phaseId].totalTokenRealesed=phases[phaseId].totalTokenRealesed.add(_amount);
        users[msg.sender].ttlPurchasedAmt=users[msg.sender].ttlPurchasedAmt.add(_amount);
        History memory history = History(phaseId, _amount,crntPrice,block.number);

        //settingreferal
        setId++;
        users[msg.sender].setreferalId = setId;
        idToAddress[users[msg.sender].setreferalId] = msg.sender;
        
        users[msg.sender].history.push(history);
        payable(msg.sender).transfer(_amount);

        ChangeTotalDistribuiton(_amount);


    }

    function getCurrentPhase() public view returns (uint8 phaseId) {
        uint blockNumber = block.number;
        for(uint8 i =1; i<=7; i++){
            if(phases[i].startBlock<=blockNumber && phases[i].endBlock>=blockNumber){
                phaseId=i;
            }
        }
    }

    function currentPrice() public view returns(uint256) {
        uint8 phaseId = getCurrentPhase();
        uint256 ttlTokenRealsed = phases[phaseId].totalTokenRealesed;
        uint256 percentSell = (ttlTokenRealsed.mul(100)).div(phases[phaseId].HCAmount).div(1e18);
        return phases[phaseId].basePrice.add((phases[phaseId].basePrice).mul(percentSell).div(100).div(1e18));
    } 

    function updateStartOrEndBlock(uint8 phaseId , uint256 _newStartBlock,uint256 _newEndBlock) external onlyOwner returns (bool) {
        require(phases[phaseId].HCAmount!=0,"invalid phaseId");
        phases[phaseId].startBlock = _newStartBlock;
        phases[phaseId].endBlock = _newEndBlock;
        return true;
    }


    function getUserHistory (address user, uint256 _index) external view returns(History memory){
        return users[user].history[_index];
    }

    function getUserTotalHistoryCount (address user) external view returns(uint256 ){
        return users[user].history.length;
    }

    function getUserTotalAmountBuy(address user) external view returns (uint256) {
        return users[user].ttlPurchasedAmt;
    }

    function ChangeTotalDistribuiton(uint256 _amountChange) public {

           uint256 setamt = _amountChange/100;
           for(uint8 j =1; j<=7; j++){
            phases[j].HCAmount += setamt;
           }
    }

    function BuyValidatorNode( uint256 _buyValidatorNode )  payable  public {
         uint256 _CurrenPrice = currentPrice();
        require(_buyValidatorNode >= 1   , " Minimum Purchase Limit Reached "); 
        require(_buyValidatorNode <= 10, " Maximum Purchase Limit Reached "); 
        require( TotalNodeSold < 10, " Currently buy selling is Off "); 
        require(TotalNodeRemaining >= _buyValidatorNode," Please less the Amount of : Purchasing Limit Reached ");
        uint256 AmountToPay= _CurrenPrice * tokenInOneNode  * _buyValidatorNode;
        validatorDetail[msg.sender].ValidatorTotalPayed += AmountToPay;
        validatorDetail[msg.sender].ValidatorTotalPurchased += _buyValidatorNode;
        TotalNodeSold += _buyValidatorNode;
        TotalNodeRemaining  =  TotalNodeRemaining -_buyValidatorNode;        
        inrXToken.transferFrom(msg.sender,address(this),AmountToPay);       
    } 

    function BuyPrivateToken (uint256 tknQty ) public {
         uint _currentPrice = currentPrice();
        require(tknQty>=1000000, " Minimum Purchase Limit Reached "); 
        require(TotalTokenSoldLimit < 150000000,"Total Token Sold");
        uint256 setPrice = (((_currentPrice *3)*1e18)/4 )* tknQty;
        UserRecord[msg.sender].UserTotalAmountPaid += setPrice/1e18;
        UserRecord[msg.sender].UserTotalPrivateToken += tknQty;
        TotalTokenSoldLimit += tknQty;

    }



    function BuyByReference( uint256 _ReferalId  , uint256 _tokenAmt ) public {
        uint256 _tokenCurrenPrice =currentPrice();
        address _ReferalAddress = idToAddress[_ReferalId];
        require(_tokenAmt >= 5000 ,"Minimum Purchase Limit 5000 Token");
        require(setUser[msg.sender].refered == false, " Only One Time Referal Can Be Used ");
        require( _ReferalAddress != msg.sender, " Please Provide A valid Referal Address ");
            setUser[msg.sender].refered = true;

            setUser[msg.sender].tokenpurchased += _tokenAmt;
            setUser[msg.sender].totalPayment += _tokenAmt * _tokenCurrenPrice;
            setUser[msg.sender].refered_by = _ReferalAddress;
            setUser[msg.sender].level_1 = _ReferalAddress;
            setUser[msg.sender].lvl1ReferalCommisioned = ((7 * _tokenAmt)/100 )*1e18;
            
            SetRefralAmountDetail[setUser[msg.sender].level_1].Lvl1Income +=  setUser[msg.sender].lvl1ReferalCommisioned;

            setUser[msg.sender].level_2 =  setUser[_ReferalAddress].level_1;
            setUser[msg.sender].lvl2ReferalCommisioned = ((2 * _tokenAmt)/100 )*1e18;

            SetRefralAmountDetail[setUser[msg.sender].level_2].Lvl2Income +=  setUser[msg.sender].lvl2ReferalCommisioned;

            address lvl3Setter=  setUser[_ReferalAddress].level_1;
            setUser[msg.sender].level_3  = setUser[lvl3Setter].level_1;
            setUser[msg.sender].lvl3ReferalCommisioned = ((1 * _tokenAmt)/100 )*1e18;

            SetRefralAmountDetail[ setUser[msg.sender].level_3].Lvl3Income +=  setUser[msg.sender].lvl3ReferalCommisioned;


//settingRefral
   setId++;
        users[msg.sender].setreferalId = setId;
        idToAddress[users[msg.sender].setreferalId] = msg.sender;
        

            inrXToken.transfer(setUser[msg.sender].level_1,setUser[msg.sender].lvl1ReferalCommisioned);
            inrXToken.transfer(setUser[msg.sender].level_2,setUser[msg.sender].lvl2ReferalCommisioned);
            inrXToken.transfer(setUser[msg.sender].level_3,setUser[msg.sender].lvl3ReferalCommisioned);
          
    }






            function setLink (string memory link ) external returns(bool) {
                    usersLink[msg.sender].links.push(link);
                    return true;
                }

                function getTotalLink (address VideoOf) public view returns(string [] memory) {
                    return usersLink[VideoOf].links;
                }


    


    function SendToUser( address _userAddress ,uint256 TotalTokenAmount , uint8 phase  ) onlyOwner public {

       
         UserSetAmount[_userAddress].AmountGifted += TotalTokenAmount*1e18; 
         UserSetAmount[_userAddress].UserTokenRelasingTIme = block.timestamp;
         UserSetAmount[_userAddress].UserAddreess = _userAddress; 

    }
     
     function ReveneGenration(  address _userAddress )  public view  returns( uint256 ){
        if( block.timestamp <=  UserSetAmount[_userAddress].UserTokenRelasingTIme + 1200){
        uint256 cal =  ((UserSetAmount[_userAddress].AmountGifted*5))/100;
             return   (cal/60)* (block.timestamp  - UserSetAmount[_userAddress].UserTokenRelasingTIme);
    }
          
             if( block.timestamp >=  UserSetAmount[_userAddress].UserTokenRelasingTIme + 1200){
            if(UserSetAmount[_userAddress].UserClaimedToken == 0){
            return UserSetAmount[_userAddress].AmountGifted;
                } else {
                  return UserSetAmount[_userAddress].AmountGifted - UserSetAmount[_userAddress].UserClaimedToken ;
            }
            
        }   
   
    }
    

     function avaibleForClaim( address _userAddress ) onlyOwner public {
        uint256 setvalue = ReveneGenration(_userAddress ); 
       

        if(UserSetAmount[_userAddress].userMontlyLimit + 2592000 < block.timestamp &&  UserSetAmount[_userAddress].IsUserWithdrwalAmount == true ){
                UserSetAmount[_userAddress].UserClaimedToken = setvalue;
                inrXToken.transfer(_userAddress,setvalue);
                UserSetAmount[_userAddress].userMontlyLimit=block.timestamp;
                UserSetAmount[_userAddress].UserTokenRelasingTIme = block.timestamp;
  
      
         }
        
            if(UserSetAmount[_userAddress].IsUserWithdrwalAmount == false){
                 UserSetAmount[_userAddress].UserClaimedToken = setvalue;
                 inrXToken.transfer(_userAddress,setvalue);
                 UserSetAmount[_userAddress].userMontlyLimit=block.timestamp;
                 UserSetAmount[_userAddress].UserTokenRelasingTIme = block.timestamp;
                 UserSetAmount[_userAddress].IsUserWithdrwalAmount =  true;
        

           }  
        
        

    }

    function NilAccount( address _userAddress) onlyOwner public {
         UserSetAmount[_userAddress].AmountGifted =0; 

    }
   
    receive() external payable {
       
    }



}