/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
//import "https://github.com/Arachnid/solidity-stringutils/blob/master/src/strings.sol";


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract SRobot 
{
    
    using SafeMath for uint256; 
    IBEP20 busd = IBEP20(address(0x77CEa5C1Ca7F87cD174B061180241fA26F650814));
        
    address public ownerAddress;


    uint256 private constant minDeposit = 50e18;
    uint256 private constant maxDeposit = 2000e18; 

    uint256 private constant baseDivider = 10000;
    uint256 private constant directPercents = 700;
    

    uint256[5] private level4Percents = [200, 300, 400, 200,200];
    uint256[1] private level5Percents = [100];

    uint256 private constant timeStep = 1 days;
    uint256 private constant dayPerCycle = 7 days; 
    
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

       
        uint256 maxDeposit;
        uint starLevel;
        uint directCountstarA;
        uint directCountstarB;
        uint directCountstarC;
        uint boosterGain;
        uint256 roiPercent;
        uint256 directPercent;
        uint256 cycleDays;
       
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
        
   

    event Registerevent(address indexed user, address indexed referral);
    event Deposit(address indexed user, uint256 amount);   
    event Withdraw(address indexed user, uint256 withdrawable);

    
   
       
    address feeReceivers;
    
   // mapping(address => directDetails) public directMapping;
    
    constructor()  
    {
       // busd = _busdAddr;
        ownerAddress = msg.sender;

        
    }
    
    function returnAddress(address _address, uint _index) public view returns(address )// working
    {
       return addressToMany[_address][_index];
    }

//     function transferAmount () private
//     {
        
//     }

//     functio receivebusd()

// {
// busd.approve()

// }    

 //function _deposit(address )

function memWithdrawal(uint _amount, string memory _password) public returns(string memory)
    { 
        string memory strWithdrawalMsg = "Withdrawal Successfull";
         
        require(RegisterM[msg.sender].password == sha256(abi.encodePacked(_password)), "Wrong Pwd" );
        require(_amount >= 10e18, "Min Withdrawal 10 BUSD");
        require(WalletMaster[msg.sender].mainWallet >= _amount, "low fund");

        WalletMaster[msg.sender].mainWallet -= _amount;
        //payable(msg.sender).transfer(_amount);
        return strWithdrawalMsg;

    }
    

    function idUpgrade(address _address, uint _amount, string memory _password) public returns(string memory)
    {
        uint _timeStamp = block.timestamp;
        string memory strUpgradeMsg = "";
        Entry storage  user = RegisterM[msg.sender];
        require(user.password == sha256(abi.encodePacked(_password)), "Pwd Wrong" );
        require(user.myaddress == _address, "Not User" );
        require(user.topupAmount == 0, "Active user" );        
        require(WalletMaster[msg.sender].topupWallet >= _amount, "low  Bal" );
        require( _amount >= minDeposit && _amount.mod(minDeposit) == 0, "50 min & 50 X" );
        

        WalletMaster[msg.sender].topupWallet -= _amount;

        user.topupAmount += _amount;
        user.topupCount += 1;
        address _sponsorId = user.sponsorId;

        RegisterM[_sponsorId].directCount +=1;

        addressToMany[_sponsorId].push(_address);


        Retopup[_address].push( Topup
                                ( _amount, RegisterM[_address].currentROICycle + 1, block.timestamp, 
                                  blockhash(block.number), (block.timestamp+ (86400 * 7)),((_amount*12)/100 ),
                                  block.timestamp, 0, false, false,0 ));


    
    bool _register = true;
    _updateStar(_address, _amount, _register);   

    levelMemb(_address, _timeStamp, _amount) ;

    return strUpgradeMsg;


    }


    //function getTopupAmount
    function Register( string memory  _password, address _sponsorId) public payable //returns (uint256)
    {
        //count += 1;
        
        require(RegisterM[msg.sender].myaddress != msg.sender, "Registered" );
        require(RegisterM[_sponsorId].myaddress == _sponsorId || _sponsorId == ownerAddress, "Not a Sponsor Id" );
         require(RegisterM[_sponsorId].topupAmount > 0 || _sponsorId == ownerAddress, "Not a Sponsor Id" );
        require(msg.value >= minDeposit && msg.value.mod(minDeposit) == 0, "min 50 & 50 X");
        
        uint _amountw = 500 ;
        busd.approve(msg.sender, 500);
        busd.transferFrom(msg.sender, address(this), _amountw);
        
        uint _timeStamp = block.timestamp;
        
        RegisterM[msg.sender] = Entry
                                ( msg.sender, sha256(abi.encodePacked(_password)), _sponsorId, msg.value,
                                    1, false, false, false, 0, 0, 0, 1);
        Retopup[msg.sender].push( Topup
                                (msg.value, RegisterM[msg.sender].currentROICycle,block.timestamp,
                                    blockhash(block.number), block.timestamp+ (86400 * 7),
                                    ((msg.value*12)/100 ), block.timestamp, 0, false, false,0));

       
         
        starTopupFlag[msg.sender] = starTopup
                                (msg.value, 0,0,0,0,0,1200, 700,7 );

        
        bool _register = true;
        _updateStar(msg.sender, msg.value, _register);    
        levelMemb(msg.sender, _timeStamp, msg.value) ;

         emit Registerevent(msg.sender, RegisterM[msg.sender].sponsorId);
         emit Deposit(msg.sender, msg.value);         
    }
    

    function _updateStar(address _address, uint256 _amount, bool _register) private
    {
        starTopup storage suser = starTopupFlag[_address];

         if(suser.maxDeposit == 0 || suser.maxDeposit < _amount)
         {
             suser.maxDeposit = _amount;

         }
        //  if(_amount >= 500e18 && _amount < 1000e18)   
        //  {
        //      suser.level = 1;
        //      suser.starATopup = true;
        //  }

        //  if(_amount >= 1000e18 && _amount < 2000e18)   
        //  {
        //      suser.level = 2;
        //      suser.starATopup = true;
        //      suser.starBTopup = true;

        //  }
        //  if(_amount >= 2000e18)   
        //  {
        //      suser.level = 3;
        //      suser.starATopup = true;
        //      suser.starBTopup = true;
        //      suser.starCTopup = true;
        //  }

        bool  i = true;    
        address _sponsorId = RegisterM[_address].sponsorId;
        while(i == true)
        {            
            if(RegisterM[_sponsorId].myaddress == ownerAddress)
            { i = false;}
            
            RegisterM[_sponsorId].teamBusiness += _amount;

            if(_register == true)
            {RegisterM[_sponsorId].teamCount += 1;}
            
            _sponsorId = RegisterM[_sponsorId].sponsorId;
        }





		
    }
    
    function userRetopup(uint _prevtimestamp, uint _prevIndex) public payable
    {   
        starTopup storage suser = starTopupFlag[msg.sender];
        

        require(msg.value >= minDeposit && msg.value.mod(minDeposit) == 0, "min 50 & 50 X");
        require(Retopup[msg.sender][_prevIndex].maturityDate < block.timestamp, "Topup after maturity ");
        require(suser.maxDeposit >= msg.value, "Topup should be greater or equal to max topup");
        
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
                                       (block.timestamp+ (86400 * suser.cycleDays)),  // (block.timestamp+ 10) tested on 10 sec
                                        ((msg.value * suser.roiPercent  )/100 ),
                                        0,
                                        RegisterM[msg.sender].topupCount - 1,
                                        false,
                                        false,
                                        0
                                    )
                                );

       

        


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
                                
       

         bool   _register = false;
        _updateStar(msg.sender, msg.value, _register);   
        levelMemb(msg.sender, _timeStamp, msg.value) ;
        emit Deposit(msg.sender, msg.value);         
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

                starFlag = checkStarA(_sponsorId);

                levelPercent = starTopupFlag[_sponsorId].directPercent;
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
    

  
   function _updateBooster(address _user) public 
  {
      starTopup storage buser = starTopupFlag[_user];

      if(buser.starLevel > 0  && buser.directCountstarA > 2 && buser.boosterGain == 0)
      {
          buser.boosterGain = 1;
          buser.roiPercent = 1800;
          buser.directPercent = 800;

      }

      if(buser.starLevel >1  && buser.directCountstarB >= 5 && buser.boosterGain < 2)
      {
          buser.boosterGain = 2;
          buser.roiPercent = 2000;
          buser.directPercent = 900;

      }
      if(buser.starLevel >2  && buser.directCountstarC >= 7 && buser.boosterGain < 3)
      {
          buser.boosterGain = 3;
          buser.roiPercent = 2500;
          buser.directPercent = 1000;

      }

   }
    
    
    function checkStarA(address _user) public returns (bool)
    {

         Entry storage user  =  RegisterM[_user];
         starTopup  storage staruser = starTopupFlag[_user];
        if (
            (RegisterM[_user].teamCount > 24) 
            && (staruser.maxDeposit >= 500e18)            
            && (user.directCount > 4)
            && (user.starA == false)

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
              
            if((highestLeg >= 5000e18) && (otherLeg -  highestLeg) >= 10000e18)
            {
                 user.starA = true;
                 starTopupFlag[user.myaddress].starLevel += 1;
                 starTopupFlag[user.sponsorId].directCountstarA += 1;
                 _updateBooster(user.sponsorId) ;
                 _updateBooster(user.myaddress) ;


                   if (
                       (user.teamCount >= 100) && (staruser.maxDeposit >= 1000e18) && (user.directCount >= 10)
                       && (user.starB == false) && (highestLeg >= 10000e18) && ((otherLeg -  highestLeg) >= 20000e18)
                       ) // conditions for starB
                   {
                       user.starB= true;

                       starTopupFlag[user.sponsorId].directCountstarB += 1;
                       starTopupFlag[user.myaddress].starLevel += 1;

                       _updateBooster(user.sponsorId) ;
                       _updateBooster(user.myaddress) ;
                       
                       if (
                       (user.teamCount > 100)
                       && (staruser.maxDeposit >= 2000e18)
                       && (user.directCount >= 25)
                       && (user.starC == false)
                       && (highestLeg >= 20000e18)
                       && ((otherLeg -  highestLeg) >= 50000e18)
                       ) // conditions for starC
                       {
                           user.starC= true;
                           starTopupFlag[user.sponsorId].directCountstarC += 1;

                           starTopupFlag[user.myaddress].starLevel += 1;
                           _updateBooster(user.sponsorId) ;
                           _updateBooster(user.myaddress) ;
                       }    
                   }
                       
                   
        
            }
           
            
        }
      
        //bool  starA =  RegisterM[_user].starA;
        return user.starA; // starA;
    }
    
    
    function checkStarB(address _user) public returns (bool)
    {

         Entry storage user  =  RegisterM[_user];
         starTopup storage staruser = starTopupFlag[_user];
        
        if (
               (user.teamCount > 50)
               && (user.starB == false)
               && (staruser.maxDeposit >= 1000e18)                
               && (user.directCount >= 10)
              
               
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
              
            if((highestLeg >= 10000e18) && (otherLeg -  highestLeg) >= 20000e18)
            {
                  user.starB = true;
                  starTopupFlag[user.myaddress].starLevel += 1;
                  starTopupFlag[user.sponsorId].directCountstarB += 1;

                  _updateBooster(user.sponsorId) ;
                  _updateBooster(user.myaddress) ;
                       
                   if 
                   (
                       (user.teamCount > 150)
                       && (user.starC == false)
                       && (staruser.maxDeposit >= 2000e18) 
                       && (user.directCount >= 25)
                       && (highestLeg >= 20000e18)
                       && ((otherLeg -  highestLeg) >= 50000e18)
                   ) // conditions for starC
                   {
                       user.starC= true;
                       starTopupFlag[user.myaddress].starLevel += 1;
                       starTopupFlag[user.sponsorId].directCountstarC += 1;
                       _updateBooster(user.sponsorId) ;
                      _updateBooster(user.myaddress) ;
                   }    
        
            }
           
            
        }
      
        //bool  starA =  RegisterM[_user].starA;
        return RegisterM[_user].starB; // starA;
    }
    
    
    function checkStarC(address _user) public returns (bool)
    {

        Entry storage user  =  RegisterM[_user];
        // starTopup storage staruser = starTopupFlag[_user];
        
        if (
              (user.teamCount > 100)
               && (user.starC == false)
               && (starTopupFlag[_user].maxDeposit >= 2000e18) 
               && (user.directCount >= 25)
              
              
               
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
              
            if((highestLeg >= 20000e18) && (otherLeg -  highestLeg) >= 50000e18)
            {
                user.starC = true;
                starTopupFlag[user.myaddress].starLevel += 1;
                starTopupFlag[user.sponsorId].directCountstarC += 1;
                _updateBooster(user.sponsorId) ;
                _updateBooster(user.myaddress) ;
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