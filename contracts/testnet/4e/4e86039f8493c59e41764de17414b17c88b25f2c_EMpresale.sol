/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256 supply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);

    function decimals() external view returns(uint256 digits);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

contract EMpresale {
    uint256 public TotalPurchase;
    uint256 public IdProvider = 4000;
    uint256 public OneEMofUsdt = 1200000000000000; //  0.0012
    uint256 public OneEMofBnb = 4300000000000; // 0.0000043
    address public owner;
    bool public IsSaleOff;
    uint256 public saleStartingTime;
    uint256 public maximumAmountPurchasewhenSaleStart;
    uint256 public BannedBotBuyForTime = 600;
    uint256 public BannedBotBuyForAmount = 1; // 0.01% * 0.01
    uint256 public saleEndingTime;
    IERC20 public ElomMeta;
    IERC20 public Usdt;

    uint256 percentOfDaily = 100000000313000000000;

    event BuyUsdt(uint256 Amount, address User, string Token);

    struct UserDetail {

        uint256 totalPurchased;
        uint256 timeOfPurchase;
        string CurrencyUsed;
        uint256 stakeTimePeriod;
        uint256 stakedTimePeriodInMonths;
        uint256 lastTimeAmountclaim;
    
    }

    struct UserRefralDetail {
        
        uint256 userId;
        uint256 totalAmountEarnedByRefral;
        uint256 userReferdBy;
    }

    modifier onlyOwner() {
        
        require(msg.sender == owner);
        _;
    }

    mapping(address => UserDetail[]) public UserPackageDetail;
    mapping(address => UserRefralDetail) public UserRefDetails;
    mapping(uint256 => bool) public IsExist;
    mapping(uint256 => address) public IdToAddress;

    constructor(address _owner) {

        owner = _owner;
        ElomMeta = IERC20(0x2a70E7457efC2CED30eFF86De13c5ff020bF3374);
        Usdt = IERC20(0xD107DD797dfFc0e50BFb40965a3B1D211B8a9F95);

        IsExist[3999] = true;
        IdToAddress[3999] = owner;

    }

    function PauseSale(bool _value) public onlyOwner {
        
        IsSaleOff = _value;
        
    }

    function setAmountOfPurchsaingAtSaleStart(uint256 limit) public onlyOwner {
        maximumAmountPurchasewhenSaleStart = limit;
    }


    
    function SetBannedBotBuyForTimeAndAmount(uint256 time, uint256 amount) public  onlyOwner{

        BannedBotBuyForTime = time;
        BannedBotBuyForAmount = amount;

    }


    function checkIfBotBuyHappening(uint256 amount) public view returns (bool) {

        if(saleStartingTime + BannedBotBuyForTime > block.timestamp) {
            uint256 data = ElomMeta.balanceOf(address(this));
            data = ((data * 1) / 100 ) / 100;

            if (amount <= data) {
                return false;
            } else return true;

        } else {
            return false;
        }
    }

    function SetSaleTime(uint256 startTime, uint256 endTime) public onlyOwner {

        require(startTime >= 0, "Sale Starting Time Is Not Valid");
        require(endTime >= block.timestamp, "Sale Ending Time Is Not Valid");
        saleStartingTime = startTime;
        saleEndingTime = endTime;

    }

    function CalculatePriceForUsdt(uint256 _tokenAmount) public view returns (uint256 Price){

        Price = OneEMofUsdt * _tokenAmount;
        return Price / 1e18;
    }


    function CalculatePriceForBnb(uint256 _tokenAmount) public view returns (uint256 Price){

        Price = OneEMofBnb * _tokenAmount;
        return Price / 1e18;

    }

    function buyTokenBuyGivingUsdt(uint256 _amount, uint256 refId, uint256 stakedFor ) public {

        require(IsSaleOff == false, "SALE IS CURRENTLY OFF");

        require( saleStartingTime <= block.timestamp && saleEndingTime >= block.timestamp,"Sale Period Is Off" );
        require(IsExist[refId]== true,"Refral Id Is Invalid");
        require(_amount > 0, "PLEASE CHOOSE PROPER AMOUNT");
        require(Usdt.allowance(msg.sender, address(this)) >= _amount,"Exceed :: allowance" );
        bool checkAmt = checkIfBotBuyHappening(_amount);
        require(checkAmt == false," These kind are activites Probited !! please lower the Amount");

        if(UserRefDetails[msg.sender].userId == 0){
            UserRefDetails[msg.sender].userId = IdProvider;
            IdToAddress[IdProvider] = msg.sender;
            IsExist[IdProvider] = true;
            IdProvider++;
        }

        if(UserRefDetails[msg.sender].userReferdBy == 0){
            UserRefDetails[msg.sender].userReferdBy==refId;
        }

        uint256 price = CalculatePriceForUsdt(_amount);
        Usdt.transferFrom(msg.sender, address(this), price);
        ElomMeta.transfer(msg.sender, _amount);
       
        uint256 storeTimeInsec;

        // if(stakedFor == 6){
        //     storeTimeInsec = 60*60*24*(30*6);
        // }
        // else if( stakedFor == 12){
        //         storeTimeInsec = 60*60*24*(30*12);
        // }else{
        //     storeTimeInsec = 60*60*24*(30*120000);
        // }
          if(stakedFor == 6){
            storeTimeInsec = 60*4;
        }
        else if( stakedFor == 12){
                storeTimeInsec = 60*6;
        }else{
            storeTimeInsec = 60*8;
        }


        UserPackageDetail[msg.sender].push(UserDetail(_amount, block.timestamp, "USDT",storeTimeInsec ,stakedFor,block.timestamp));

        if (UserRefDetails[msg.sender].userReferdBy == 0 && IsExist[refId] == true){
            uint256 amtToRef = ((_amount * 5) / 100);
            ElomMeta.transfer(IdToAddress[refId], amtToRef);
            UserRefDetails[msg.sender].totalAmountEarnedByRefral += amtToRef;

        }else {

             uint256 amtToRef = ((_amount * 5) / 100);
            ElomMeta.transfer(IdToAddress[UserRefDetails[msg.sender].userReferdBy], amtToRef);
            UserRefDetails[msg.sender].totalAmountEarnedByRefral += amtToRef;
        }
        emit BuyUsdt(_amount, msg.sender, "USDT");
        TotalPurchase++;
    }

    function buyTokenBuyGivingBNB(uint256 _amount, uint256 refId, uint256 stakedFor) public payable{
        
        require(IsSaleOff == false, "SALE IS CURRENTLY OFF");
        require(saleStartingTime < block.timestamp && saleEndingTime > block.timestamp,"Sale Period Is Off");
        require(IsExist[refId] == true,"Refral Id Is Invalid");
        bool checkAmt = checkIfBotBuyHappening(_amount);
        require(checkAmt == false,"These kind are activites Probited !! please lower the Amount");
        require(_amount > 0, "PLEASE CHOOSE PROPER AMOUNT");
        uint256 price = CalculatePriceForBnb(_amount);
        require( msg.value >= price , "please Enter Proper Fees");

        if(UserRefDetails[msg.sender].userId == 0){
            UserRefDetails[msg.sender].userId = IdProvider;
            IdToAddress[IdProvider] = msg.sender;
            IsExist[IdProvider] = true;
            IdProvider++;
        }
         if(UserRefDetails[msg.sender].userReferdBy == 0){
            UserRefDetails[msg.sender].userReferdBy==refId;
        }
           
        uint256 storeTimeInsec;

        // if(stakedFor == 6){
        //     storeTimeInsec = 60*60*24*(30*6);
        // }
        // else if( stakedFor == 12){
        //         storeTimeInsec = 60*60*24*(30*12);
        // }else{
        //     storeTimeInsec = 60*60*24*(30*120000);
        // }

             if(stakedFor == 6){
                    storeTimeInsec = 60*4;
                }
                else if( stakedFor == 12){
                        storeTimeInsec = 60*6;
                }else{
                    storeTimeInsec = 60*8;
            }


        ElomMeta.transfer(msg.sender, _amount);
        UserPackageDetail[msg.sender].push(UserDetail(_amount, block.timestamp, "BNB" ,storeTimeInsec ,stakedFor,block.timestamp));

        if(UserRefDetails[msg.sender].userReferdBy == 0 && IsExist[refId] == true){ 
            uint256 amtToRef = ((_amount * 5) / 100);
            ElomMeta.transfer(IdToAddress[refId], amtToRef);
            UserRefDetails[msg.sender].totalAmountEarnedByRefral += amtToRef;
        }else {
            uint256 amtToRef = ((_amount * 5) / 100);
            ElomMeta.transfer(IdToAddress[UserRefDetails[msg.sender].userReferdBy], amtToRef);
            UserRefDetails[msg.sender].totalAmountEarnedByRefral += amtToRef;
        }
  
        emit BuyUsdt(_amount, msg.sender, "BNB");
        TotalPurchase++;
    }

    function withdrawl(uint256 ammt) public onlyOwner {

        require(address(this).balance >= ammt, "insufficient contract balance");
        payable(msg.sender).transfer(ammt);
    
    }

    function RescueElomMetaToAdminWallet(uint256 Amt) public onlyOwner {
        
        ElomMeta.transfer(owner, Amt);
    }

    function RescueUSDTToAdminWallet(uint256 Amt) public onlyOwner {
        Usdt.transfer(owner, Amt);
    }

    function changeOwnerAddress(address _ownerAddress) public onlyOwner { 
        owner = _ownerAddress;
    } 


    function calculateRoi( address useraddress) public view returns(uint256){

            uint256 returnAmount = 0;
        for(uint8 i=0; i < UserPackageDetail[useraddress].length; i++ ){

             if(UserPackageDetail[useraddress][i].totalPurchased !=0 ){
                if(UserPackageDetail[useraddress][i].timeOfPurchase + UserPackageDetail[useraddress][i].stakeTimePeriod >= block.timestamp){
                     uint256 time = block.timestamp - UserPackageDetail[useraddress][i].lastTimeAmountclaim;
                if( UserPackageDetail[useraddress][i].stakedTimePeriodInMonths == 6){
                      uint256 perSecPercent = (((UserPackageDetail[useraddress][i].totalPurchased*25)*1e18)/100)/UserPackageDetail[useraddress][i].stakeTimePeriod;
                                 returnAmount +=  time*perSecPercent;
                }

                else if(UserPackageDetail[useraddress][i].stakedTimePeriodInMonths == 12){
                          uint256 perSecPercent = (((UserPackageDetail[useraddress][i].totalPurchased*30)*1e18)/100)/UserPackageDetail[useraddress][i].stakeTimePeriod;
                                 returnAmount += time*perSecPercent;   
                }
                else if( UserPackageDetail[useraddress][i].stakedTimePeriodInMonths == 120000){
                        uint256 timeleft =  time * percentOfDaily ;                                        
                                returnAmount += timeleft;
                }
           }

        else if(UserPackageDetail[useraddress][i].timeOfPurchase + UserPackageDetail[useraddress][i].stakeTimePeriod < block.timestamp){
                
                uint256 time =  UserPackageDetail[useraddress][i].stakeTimePeriod +  UserPackageDetail[useraddress][i]. timeOfPurchase  -  UserPackageDetail[useraddress][i].lastTimeAmountclaim;

                if( UserPackageDetail[useraddress][i].stakedTimePeriodInMonths== 6){
                uint256 perSecPercent = (((UserPackageDetail[useraddress][i].totalPurchased*125)*1e18)/100)/UserPackageDetail[useraddress][i].stakeTimePeriod;
                                 returnAmount += time*perSecPercent;   
                 }    

               else if( UserPackageDetail[useraddress][i].stakedTimePeriodInMonths== 12){
                 uint256 perSecPercent = (((UserPackageDetail[useraddress][i].totalPurchased*130)*1e18)/100)/UserPackageDetail[useraddress][i].stakeTimePeriod;
                                 returnAmount += time*perSecPercent;   
                }

              else if( UserPackageDetail[useraddress][i].stakedTimePeriodInMonths== 120000){
                                 returnAmount += time*percentOfDaily;   
              }
           }
         }
      }
                    return  returnAmount;

    }

    function claimRoi() public {

    uint256 claimableRoi = calculateRoi(msg.sender);
            claimableRoi = (claimableRoi)/1e18;
            ElomMeta.transfer(owner, (claimableRoi));

             for(uint8 i=0; i < UserPackageDetail[msg.sender].length; i++){
                // ElomMeta.transfer(owner, ( UserPackageDetail[msg.sender][i].totalPurchased)); 
              UserPackageDetail[msg.sender][i].lastTimeAmountclaim = block.timestamp;
            }
                 
    }

    function withdrawPrincipalAmount () public {

          for(uint8 i=0; i < UserPackageDetail[msg.sender].length; i++){
              if( UserPackageDetail[msg.sender][i].stakedTimePeriodInMonths==6){
                  if( UserPackageDetail[msg.sender][i].stakedTimePeriodInMonths > block.timestamp){
                      uint256 userWallet = (UserPackageDetail[msg.sender][i].totalPurchased*10)/100;
                      userWallet = UserPackageDetail[msg.sender][i].totalPurchased-userWallet;
                     ElomMeta.transfer(owner,(userWallet));
                     UserPackageDetail[msg.sender][i].totalPurchased = 0;
               }else{
                     ElomMeta.transfer(owner,(UserPackageDetail[msg.sender][i].totalPurchased));
                     UserPackageDetail[msg.sender][i].totalPurchased = 0;
               }
              }
               else if( UserPackageDetail[msg.sender][i].stakedTimePeriodInMonths==12){
                  if( UserPackageDetail[msg.sender][i].stakedTimePeriodInMonths> block.timestamp){
                      uint256 userWallet = (UserPackageDetail[msg.sender][i].totalPurchased*10)/100;
                      userWallet = UserPackageDetail[msg.sender][i].totalPurchased-userWallet;
                     ElomMeta.transfer(owner,(userWallet));
                     UserPackageDetail[msg.sender][i].totalPurchased = 0;
               }else{
                     ElomMeta.transfer(owner,(UserPackageDetail[msg.sender][i].totalPurchased));
                     UserPackageDetail[msg.sender][i].totalPurchased = 0;
               }
              }
               else if( UserPackageDetail[msg.sender][i].stakedTimePeriodInMonths==120000){
                     ElomMeta.transfer(owner,(UserPackageDetail[msg.sender][i].totalPurchased));
                     UserPackageDetail[msg.sender][i].totalPurchased = 0;
              }
            }       
    }

    receive() external payable {}
}