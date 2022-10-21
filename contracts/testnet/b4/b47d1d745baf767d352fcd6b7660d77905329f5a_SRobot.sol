/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
//import "https://github.com/Arachnid/solidity-stringutils/blob/master/src/strings.sol";

contract SRobot
{
    
   
        
    address public ownerAddress;
   // uint256 public count  = 0;
    
    struct Entry
    {
        address myaddress;
        bytes32 password;
        address sponsorId; 

        uint topupAmount;
        uint currentROICycle;   

        bool starA;
        bool starB;
        bool starC;

        uint directCount;
        uint teamBusiness;
        uint teamCount;
        uint topupCount;
        
       
    }


    struct starTopup
    {

        bool starATopup;
        bool starBTopup;
        bool starCTopup;
        uint timeStamp;
    }
    
    struct Topup
    {
           uint topupAmount;
           uint currentROICycle;
           uint timeStamp;
           bytes32 hashId;
           uint maturityDate;
           uint maturityAmount;
           uint prevTopuptimeStamp;
           uint currentIndex;
           bool maturityRetopupFlag;
           bool withdrawalFlag;
           uint prevIndex;
    }
    
    
    struct Incentive
    {
        uint incentive;
        address fromMemb;
        uint timeStamp;
        uint daysCount;
        uint topupTimeStamp;
        
    }

    struct Wallet
    {
        uint256 mainWallet;
        uint256 topupWallet;
    }
        
    
    mapping(address => Wallet ) public WalletMaster;
    mapping(address => starTopup ) public starTopupFlag;
    mapping(address => Incentive []) public IncentiveMemb;
    mapping(address => Entry) public RegisterM;
    mapping(address => Topup []) public Retopup;
    mapping(address => address  [] ) public addressToMany;
        
   
    
   
       
    
    
   // mapping(address => directDetails) public directMapping;
    
    constructor()  
    {
        ownerAddress = msg.sender;
        RegisterM[msg.sender] = Entry
                                (
                                    msg.sender,
                                   sha256(abi.encodePacked("wrongpassord")), 
                                    msg.sender,
                                    50,
                                    0,                                   
                                    true,
                                    true,
                                    true,
                                    0,
                                    0,
                                    0,                                    
                                    1
                                    
                                );
                                
                                
        Retopup[ownerAddress].push(Topup
                                (
                                    50,  
                                    RegisterM[msg.sender].currentROICycle+1,
                                    block.timestamp, 
                                    blockhash(block.number),
                                    (block.timestamp+ (86400 * 10)), 
                                    57,
                                    0,
                                    0,
                                    false,
                                    false,
                                    0
                                ));
                                
        
    }
    
    function returnAddress(address _address, uint _index) public view returns(address )// working
    {
       return addressToMany[_address][_index];
    }


    function memWithdrawal(uint _amount, string memory _password) public returns(string memory)
    { 
        string memory strWithdrawalMsg = "Withdrawal Successfull";
         
        require(RegisterM[msg.sender].password == sha256(abi.encodePacked(_password)), "Transaction password did not match" );
        require(_amount >= 10, "Minimum withdrawal amount is 10 USDT");
        require(WalletMaster[msg.sender].mainWallet >= _amount, "Withdrawal amount should be less than or equal to Main wallet");

        WalletMaster[msg.sender].mainWallet -= _amount;
        //payable(msg.sender).transfer(_amount);
        return strWithdrawalMsg;

    }
    

    function idUpgrade(address _address, uint _amount, string memory _password) public returns(string memory)
    {
        uint _timeStamp = block.timestamp;
        string memory strUpgradeMsg = "";
        require(RegisterM[msg.sender].password == sha256(abi.encodePacked(_password)), "Transaction password did not match" );
        require(RegisterM[_address].myaddress == _address, "Invalid user address" );
        require(RegisterM[_address].topupAmount == 0, "User should be Inactive" );        
        require(WalletMaster[msg.sender].topupWallet >= _amount, "Insufficient  fund" );
        require( _amount >= 50, "Minimum upgrade amount id 50 USDT" );
        require( _amount % 50 == 0, "Upgrade amount should be in multiples of 50" );


        WalletMaster[msg.sender].topupWallet -= _amount;

        RegisterM[_address].topupAmount += _amount;
        RegisterM[_address].topupCount += 1;
        address _sponsorId = RegisterM[_address].sponsorId;

        RegisterM[_sponsorId].directCount +=1;

        addressToMany[_sponsorId].push(_address);


        Retopup[_address].push( Topup
                                (
                                    _amount,
                                    RegisterM[_address].currentROICycle + 1,
                                    block.timestamp,
                                    blockhash(block.number),
                                    (block.timestamp+ (86400 * 10)),
                                    ((_amount*15)/100 ),
                                    block.timestamp,
                                    0,
                                    false,
                                    false,
                                    0
                                ));

         if(_amount >= 500 && _amount < 1000)   
         {
             starTopupFlag[_address].starATopup = true;

         }

          if(_amount >= 1000 && _amount < 2000)   
         {
             starTopupFlag[_address].starATopup = true;
             starTopupFlag[_address].starBTopup = true;

         }
          if(_amount >= 2000)   
         {
             starTopupFlag[_address].starATopup = true;
             starTopupFlag[_address].starBTopup = true;
             starTopupFlag[_address].starCTopup = true;

         }

         bool  i = true;
        
        while(i == true)
        {
            
            if(RegisterM[_sponsorId].myaddress == ownerAddress)
            {
                i = false;
            }
            
            RegisterM[_sponsorId].teamBusiness += _amount;
            RegisterM[_sponsorId].teamCount += 1;
            _sponsorId = RegisterM[_sponsorId].sponsorId;
           // RegisterM[_sponsorId].myaddress != ownerAddress
        }

    levelMemb(_address, _timeStamp, _amount) ;

    return strUpgradeMsg;


    }


    //function getTopupAmount
    function Register( string memory  _password, address _sponsorId) public payable //returns (uint256)
    {
        //count += 1;
        require(RegisterM[msg.sender].myaddress != msg.sender, "Already Registered" );
        require(RegisterM[_sponsorId].myaddress == _sponsorId, "Sponsor Id not exists" );
        //require(RegisterM[_sponsorId].myaddress == _sponsorId, "Sponsor Id not exists" );
        require(msg.value >= 50, "Topup amount should greater than 50 and should be in multiple of 50");
        require(msg.value % 50 == 0, "Topup amount should greater than 50 and should be in multiple of 50");
        
        uint _timeStamp = block.timestamp;
        
        RegisterM[msg.sender] = Entry
                                (
                                    msg.sender,                                    
                                    sha256(abi.encodePacked(_password)),
                                    _sponsorId,
                                    msg.value,
                                    1,                                   
                                    false,
                                    false,
                                    false,
                                    0,
                                    0,
                                    0, 
                                    1                                   
                                    
                                    //[msg.sender]
                                );
        Retopup[msg.sender].push( Topup
                                (
                                    msg.value,
                                    RegisterM[msg.sender].currentROICycle,
                                    block.timestamp,
                                    blockhash(block.number),
                                    (block.timestamp+ (86400 * 10)),
                                    ((msg.value*15)/100 ),
                                    block.timestamp,
                                    0,
                                    false,
                                    false,
                                    0
                                ));


         
         starTopupFlag[msg.sender] = starTopup
                                (
                                    false,
                                    false,
                                    false,
                                    block.timestamp

                                );

         if(msg.value>=500 && msg.value < 1000)   
         {
             starTopupFlag[msg.sender].starATopup = true;

         }

          if(msg.value>=1000 && msg.value < 2000)   
         {
             starTopupFlag[msg.sender].starATopup = true;
             starTopupFlag[msg.sender].starBTopup = true;

         }
          if(msg.value >= 2000)   
         {
             starTopupFlag[msg.sender].starATopup = true;
             starTopupFlag[msg.sender].starBTopup = true;
             starTopupFlag[msg.sender].starCTopup = true;

         }
          //  if (Retopup[msg.sender].timestamp == _timestamp]  )                   
          //  uint directCount;
          //  uint teamBusiness;                      
       
       
       
       
        
        
        RegisterM[_sponsorId].directCount += 1;

        WalletMaster[msg.sender] = Wallet
                                (
                                        0,
                                        0
                                );
        
        addressToMany[_sponsorId].push(msg.sender);
        
        bool  i = true;
        
        while(i == true)
        {
            
            if(RegisterM[_sponsorId].myaddress == ownerAddress)
            {
                i = false;
            }
            
            RegisterM[_sponsorId].teamBusiness += msg.value;
            RegisterM[_sponsorId].teamCount += 1;
            _sponsorId = RegisterM[_sponsorId].sponsorId;
           // RegisterM[_sponsorId].myaddress != ownerAddress
        }
            
        levelMemb(msg.sender, _timeStamp, msg.value) ;
    }
    

 
    
    function userRetopup(uint _prevtimestamp, uint _prevIndex) public payable
    {
        require(msg.value >= 50, "Topup amount should greater than 50 and should be in multiple of 50");
        require(msg.value % 50 == 0, "Topup amount should be in multiples of 50");
        require(Retopup[msg.sender][_prevIndex].maturityDate < block.timestamp, "ReTopup can only be done after maturity of previous topup");
        require(Retopup[msg.sender][_prevIndex].topupAmount >= msg.value, "ReTopup amount should be equal or greater then previous topup amount");


        
        uint _timeStamp = block.timestamp;
        RegisterM[msg.sender].topupAmount =RegisterM[msg.sender].topupAmount += msg.value;
        
        RegisterM[msg.sender].topupCount += 1;
        Retopup[msg.sender].push( 
                                Topup
                                    (
                                        msg.value,
                                        RegisterM[msg.sender].currentROICycle + 1,
                                        _timeStamp,
                                        blockhash(block.number),
                                       (block.timestamp+ (86400 * 10)),  // (block.timestamp+ 10) tested on 10 sec
                                        ((msg.value*15)/100 ),
                                        0,
                                        RegisterM[msg.sender].topupCount - 1,
                                        false,
                                        false,
                                        0
                                    )
                                );


         if((msg.value>=500) && ( starTopupFlag[msg.sender].starATopup == false))   
         {
             starTopupFlag[msg.sender].starATopup = true;

         }

         if((msg.value>=1000) && ( starTopupFlag[msg.sender].starBTopup == false))   
         {
            // starTopupFlag[msg.sender].starATopup = true;
             starTopupFlag[msg.sender].starBTopup = true;

         }
         if((msg.value >= 2000) && (starTopupFlag[msg.sender].starCTopup == false))   
         {
            
             starTopupFlag[msg.sender].starCTopup = true;

         }



        if(
            (Retopup[msg.sender][_prevIndex].timeStamp == _prevtimestamp) 
            && (Retopup[msg.sender][_prevIndex].maturityDate < block.timestamp)
            && (Retopup[msg.sender][_prevIndex].maturityRetopupFlag == false)
            && (Retopup[msg.sender][_prevIndex].withdrawalFlag == false)
            && (Retopup[msg.sender][_prevIndex].topupAmount <= msg.value)
            && (Retopup[msg.sender][_prevIndex].currentIndex == _prevIndex)
          )
        {
            Retopup[msg.sender][_prevIndex].maturityRetopupFlag = true;
            Retopup[msg.sender][RegisterM[msg.sender].topupCount - 1].prevIndex = _prevIndex;
            Retopup[msg.sender][RegisterM[msg.sender].topupCount - 1].prevTopuptimeStamp = _prevtimestamp;
        }
                                
        address _sponsorId =  RegisterM[msg.sender].sponsorId;                       
        bool  i = true;
        
        while(i == true)
        {
            
            if(RegisterM[_sponsorId].myaddress == ownerAddress)
            {
                i = false;
            }
            RegisterM[_sponsorId].teamBusiness += msg.value;
            //RegisterM[_sponsorId].teamCount += 1;
            _sponsorId = RegisterM[_sponsorId].sponsorId;
        }

        levelMemb(msg.sender, _timeStamp, msg.value) ;
        //RegisterM[RegisterM[msg.sender].sponsorId].teamBusiness += msg.value;
        
       
        
        
    }
    
    function levelMemb(address _user, uint _timeStamp, uint _amount) public payable
    { 

        uint _count = 0;
        uint levelPercent = 0;

        address _sponsorId = _user;

        bool  i = true;
        bool starFlag = false;
        
        while(i == true)
        {
            
            _count +=1;
            _sponsorId = RegisterM[_sponsorId].sponsorId;

            starFlag = false;
            if(_count == 1)
            {
                levelPercent = 25;
                starFlag = true;
            }
            
            if(_count > 1 && _count < 6 )  
            {
                levelPercent = 10;
                starFlag = checkStarA(_sponsorId);
            }            
            if(_count > 5 && _count < 16 ) 
            {
                levelPercent = 20;
                starFlag = checkStarB(_sponsorId);
            }
            if(_count > 15 && _count < 26 )
            {
                levelPercent = 30;
                starFlag = checkStarC(_sponsorId);                
            } 
            if(_count >= 25)
            {
                i = false;
            }

            if(RegisterM[_sponsorId].myaddress == ownerAddress)
            {
                i = false;
            }

            if(starFlag == true)
            {

                IncentiveMemb[_sponsorId].push(
                                            Incentive
                                            (
                                                ((_amount * levelPercent)/100),                                                
                                                _user,                         
                                                _timeStamp,

                                                0,
                                                _timeStamp
                                            )
                                        );
            } 
           // RegisterM[_sponsorId].myaddress != ownerAddress;
        }   
     
    }
    
    
    
    function checkStarA(address _user) public returns (bool)
    {
        
        if (
            (RegisterM[_user].teamCount > 24) 
            && (starTopupFlag[_user].starATopup == true) 
            && (RegisterM[_user].topupAmount >= 500) 
            && (RegisterM[_user].directCount > 4)
            && (RegisterM[_user].starA == false)

           )
        {
           
            address[] memory directList;
            //uint[] memory completeTeamList;
           // uint[] memory businessLegwise;
          
            uint highestLeg = 0;
            uint otherLeg = 0;
            
            for(uint i = 0; i < RegisterM[_user].directCount - 1; i++ )
            {
              directList[i] = returnAddress(_user, i);
              //businessLegwise[i] = RegisterM[directList[i]].teamBusiness;
              
              otherLeg += (RegisterM[directList[i]].teamBusiness + RegisterM[directList[i]].topupAmount);
              if(highestLeg < (RegisterM[directList[i]].teamBusiness + RegisterM[directList[i]].topupAmount))
              {
                  highestLeg = (RegisterM[directList[i]].teamBusiness + RegisterM[directList[i]].topupAmount);
              }
                  
              
            }
              
            if((highestLeg >= 5000) && (otherLeg -  highestLeg) >= 10000)
            {
                  RegisterM[_user].starA = true;
                   if (
                       (RegisterM[_user].teamCount > 50)
                       && (starTopupFlag[_user].starBTopup == true)
                       && (RegisterM[_user].topupAmount >= 1000)
                       && (RegisterM[_user].directCount >= 10)
                       && (RegisterM[_user].starB == false)
                       && (highestLeg >= 10000)
                       && ((otherLeg -  highestLeg) >= 20000)
                       ) // conditions for starB
                   {
                       RegisterM[_user].starB= true;
                       
                       
                       
                       if (
                       (RegisterM[_user].teamCount > 100)
                       && (starTopupFlag[_user].starCTopup == true)
                       && (RegisterM[_user].topupAmount >= 2000)
                       && (RegisterM[_user].directCount >= 25)
                       && (RegisterM[_user].starC == false)
                       && (highestLeg >= 20000)
                       && ((otherLeg -  highestLeg) >= 50000)
                       ) // conditions for starC
                       {
                           RegisterM[_user].starC= true;
                       }    
                   }
                       
                   
        
            }
           
            
        }
      
        //bool  starA =  RegisterM[_user].starA;
        return RegisterM[_user].starA; // starA;
    }
    
    
    function checkStarB(address _user) public returns (bool)
    {
        
        if (
               (RegisterM[_user].teamCount > 50)
               && (RegisterM[_user].starB == false)
               && (starTopupFlag[_user].starBTopup == true) 
               && (RegisterM[_user].topupAmount >= 1000)
               && (RegisterM[_user].directCount >= 10)
              
               
            )
        {
           
            address[] memory directList;
            //uint[] memory completeTeamList;
           // uint[] memory businessLegwise;
          
            uint highestLeg = 0;
            uint otherLeg = 0;
            
            for(uint i = 0; i < RegisterM[_user].directCount - 1; i++ )
            {
              directList[i] = returnAddress(_user, i);
             // businessLegwise[i] = RegisterM[directList[i]].teamBusiness;
              
               otherLeg += (RegisterM[directList[i]].teamBusiness + RegisterM[directList[i]].topupAmount);
              if(highestLeg < (RegisterM[directList[i]].teamBusiness + RegisterM[directList[i]].topupAmount))
              {
                  highestLeg = (RegisterM[directList[i]].teamBusiness + RegisterM[directList[i]].topupAmount);
              }
                  
              
            }
              
            if((highestLeg >= 10000) && (otherLeg -  highestLeg) >= 20000)
            {
                  RegisterM[_user].starB = true;
                       
                   if 
                   (
                       (RegisterM[_user].teamCount > 100)
                       && (RegisterM[_user].starC == false)
                       && (starTopupFlag[_user].starCTopup == true) 
                       && (RegisterM[_user].topupAmount >= 2000)
                       && (RegisterM[_user].directCount >= 25)
                       && (highestLeg >= 20000)
                       && ((otherLeg -  highestLeg) >= 50000)
                   ) // conditions for starC
                   {
                       RegisterM[_user].starC= true;
                   }    
        
            }
           
            
        }
      
        //bool  starA =  RegisterM[_user].starA;
        return RegisterM[_user].starB; // starA;
    }
    
    
    function checkStarC(address _user) public returns (bool)
    {
        
        if (
              (RegisterM[_user].teamCount > 100)
               && (RegisterM[_user].starC == false)
               && (starTopupFlag[_user].starCTopup == true) 
               && (RegisterM[_user].topupAmount >= 2000)
               && (RegisterM[_user].directCount >= 25)
              
              
               
            )
        {
           
            address[] memory directList;
            //uint[] memory completeTeamList;
           // uint[] memory businessLegwise;
          
            uint highestLeg = 0;
            uint otherLeg = 0;
            
            for(uint i = 0; i < RegisterM[_user].directCount - 1; i++ )
            {
              directList[i] = returnAddress(_user, i);
              //businessLegwise[i] = RegisterM[directList[i]].teamBusiness;
              
              otherLeg += (RegisterM[directList[i]].teamBusiness + RegisterM[directList[i]].topupAmount);
              if(highestLeg < (RegisterM[directList[i]].teamBusiness + RegisterM[directList[i]].topupAmount))
              {
                  highestLeg = (RegisterM[directList[i]].teamBusiness + RegisterM[directList[i]].topupAmount);
              }
                  
              
            }
              
            if((highestLeg >= 20000) && (otherLeg -  highestLeg) >= 50000)
            {
                RegisterM[_user].starC = true;
                
            }
           
            
        }
      
        //bool  starA =  RegisterM[_user].starA;
        return RegisterM[_user].starC; // starA;
    }
    
    
    
    function getBalanace() public view returns(uint)
    {
        //require(manager == msg.sender, "You are not the manager");
        return address(this).balance;


    }
    
    
   

        
    
}