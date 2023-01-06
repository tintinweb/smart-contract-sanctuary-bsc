/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

    interface BEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

 contract Exam {

    address public owner;
    uint256 public passMarks;

    mapping (uint256 => uint256) qAns;
    uint256 public totalQulifiedUser;
    uint256 public totalQuestions;
    struct User{
        uint256 obtainMarks;
        uint256 lastAttain;
        uint256 totalMarks;
        string  status;
        uint256 percentage;
    }
    mapping(address => User) user;

    constructor () public{
        owner = msg.sender;
    }
    // OnlyOwner Modifier
    modifier onlyOwner {
        require(msg.sender == owner,"ONLY_OWNER_ALLOWED");
        _;
        
    }
// Set Question and Thier Choice
function setQuestion(uint256[] memory questions, uint256[] memory corr_choices) public onlyOwner{
    require(questions.length == corr_choices.length,"NOT_EQUAL_Q_A");
    for(uint256 i=0;i< questions.length; i++){
      qAns[questions[i]] = corr_choices[i];
    }
    totalQuestions = questions.length;
}
// Submit Answer By USER
function subAnswer(uint256[] memory setQuest , uint256[] memory answer) public {
   require(setQuest.length == answer.length,"NOT_EQUAL_Q_A");
   uint256 obtainMarks;
   for(uint256 i=0;i< setQuest.length; i++){
    if(qAns[setQuest[i]] == answer[i]){
        obtainMarks++;
    }
   }
   uint256 percent = (obtainMarks * 100)/totalQuestions;
   user[msg.sender].totalMarks = totalQuestions;
   user[msg.sender].obtainMarks = obtainMarks;
   user[msg.sender].percentage = percent;
   if(percent>passMarks){
      user[msg.sender].status ="pass";
      totalQulifiedUser +=1;
   }else {
    user[msg.sender].status = "fail";
   }
}
// Set Qualifying Marks by Qualifying Marks
function qualifyingMarks(uint256 _qMarks) public onlyOwner {
    require(_qMarks>0,"Should_be_valid");
     passMarks = _qMarks;
}
function isQualified(address _student) public view returns(bool){
    return user[_student].percentage >= passMarks;   
}

}



contract Autoppol_Crowdfunding {
      BEP20 public busd = BEP20(0x0EB11261F9F778fEfd688e2dfAdB77862E96605b);
     address public ownerWallet;
      uint public currUserID = 0;
      uint public pool1currUserID = 0;
      uint public pool2currUserID = 0;
      uint public pool3currUserID = 0;
      uint public pool4currUserID = 0;
      uint public pool5currUserID = 0;
      uint public pool6currUserID = 0;
      uint public pool7currUserID = 0;
      uint public pool8currUserID = 0;
      uint public pool9currUserID = 0;
      uint public pool10currUserID = 0;
      uint public pool11currUserID = 0;
      uint public pool12currUserID = 0;
      uint public pool13currUserID = 0;
      uint public pool14currUserID = 0;
      uint public pool15currUserID = 0;
      uint public pool16currUserID = 0;
      uint public pool17currUserID = 0;
      uint public pool18currUserID = 0;
      
      
        uint public pool1activeUserID = 0;
      uint public pool2activeUserID = 0;
      uint public pool3activeUserID = 0;
      uint public pool4activeUserID = 0;
      uint public pool5activeUserID = 0;
      uint public pool6activeUserID = 0;
      uint public pool7activeUserID = 0;
      uint public pool8activeUserID = 0;
      uint public pool9activeUserID = 0;
      uint public pool10activeUserID = 0;
      uint public pool11activeUserID = 0;
      uint public pool12activeUserID = 0;
      uint public pool13activeUserID = 0;
      uint public pool14activeUserID = 0;
      uint public pool15activeUserID = 0;
      uint public pool16activeUserID = 0;
      uint public pool17activeUserID = 0;
      uint public pool18activeUserID = 0;
      
      
      
      uint public unlimited_level_price=0;
     
      struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        uint coreferrerID;
       uint referredUsers;
       uint coreferredUsers;
       uint income;
        mapping(uint => uint) levelExpired;
    }
    
     struct PoolUserStruct {
        bool isExist;
        uint id;
       uint payment_received; 
    }
    
    mapping (address => UserStruct) public users;
     mapping (uint => address) public userList;
     
     mapping (address => PoolUserStruct) public pool1users;
     mapping (uint => address) public pool1userList;
     
     mapping (address => PoolUserStruct) public pool2users;
     mapping (uint => address) public pool2userList;
     
     mapping (address => PoolUserStruct) public pool3users;
     mapping (uint => address) public pool3userList;
     
     mapping (address => PoolUserStruct) public pool4users;
     mapping (uint => address) public pool4userList;
     
     mapping (address => PoolUserStruct) public pool5users;
     mapping (uint => address) public pool5userList;
     
     mapping (address => PoolUserStruct) public pool6users;
     mapping (uint => address) public pool6userList;
     
     mapping (address => PoolUserStruct) public pool7users;
     mapping (uint => address) public pool7userList;
     
     mapping (address => PoolUserStruct) public pool8users;
     mapping (uint => address) public pool8userList;
     
     mapping (address => PoolUserStruct) public pool9users;
     mapping (uint => address) public pool9userList;
     
     mapping (address => PoolUserStruct) public pool10users;
     mapping (uint => address) public pool10userList;
     
     mapping (address => PoolUserStruct) public pool11users;
     mapping (uint => address) public pool11userList;
     
     mapping (address => PoolUserStruct) public pool12users;
     mapping (uint => address) public pool12userList;

      mapping (address => PoolUserStruct) public pool13users;
     mapping (uint => address) public pool13userList;
     
     mapping (address => PoolUserStruct) public pool14users;
     mapping (uint => address) public pool14userList;
     
     mapping (address => PoolUserStruct) public pool15users;
     mapping (uint => address) public pool15userList;
     
     mapping (address => PoolUserStruct) public pool16users;
     mapping (uint => address) public pool16userList;
     
     mapping (address => PoolUserStruct) public pool17users;
     mapping (uint => address) public pool17userList;
     
     mapping (address => PoolUserStruct) public pool18users;
     mapping (uint => address) public pool18userList;
    


    mapping(uint => uint) public LEVEL_PRICE;
    
    Exam exam;

   uint public REGESTRATION_FESS;
   uint public pool1_price;
   uint public pool2_price;
   uint public pool3_price;
   uint public pool4_price;
   uint public pool5_price;
   uint public pool6_price;
   uint public pool7_price;
   uint public pool8_price;
   uint public pool9_price;
   uint public pool10_price;
   uint public pool11_price;
   uint public pool12_price;
   uint public pool13_price;
   uint public pool14_price;
   uint public pool15_price;
   uint public pool16_price;
   uint public pool17_price;
   uint public pool18_price;
   
   
      event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
      event referrerIncome(address indexed _user, address indexed _referral, uint _level, uint _time);
      event coreferrerIncome(address indexed _user, address indexed _referral, uint _level, uint _time);
      event regPoolEntry(address indexed _user,uint _level,   uint _time);
      event SponsorPool1Payment(address indexed _user,address indexed _receiver);
      event IntroducerPool1Payment(address indexed _user,address indexed _receiver); 
      event getPoolPayment(address indexed _user,address indexed _receiver, uint _level, uint _time);
   
    UserStruct[] public requests;
     
      constructor(address exam_) public {
          ownerWallet = msg.sender;
        REGESTRATION_FESS = 1000000000000000000;
        LEVEL_PRICE[1] = REGESTRATION_FESS/5;
        LEVEL_PRICE[2] = REGESTRATION_FESS/100;
      unlimited_level_price=REGESTRATION_FESS/100;
        pool1_price = REGESTRATION_FESS * 2;
        pool2_price = REGESTRATION_FESS*4;
        pool3_price=REGESTRATION_FESS*8;
        pool4_price=REGESTRATION_FESS*16;
        pool5_price=REGESTRATION_FESS*32;
        pool6_price=REGESTRATION_FESS*64;
        pool7_price=REGESTRATION_FESS*128;
        pool8_price=REGESTRATION_FESS*256;
        pool9_price=REGESTRATION_FESS*512;
        pool10_price=REGESTRATION_FESS*1024;
        pool11_price=REGESTRATION_FESS*2048;
        pool12_price=REGESTRATION_FESS*4096;
        pool13_price=REGESTRATION_FESS*8192;
        pool14_price=REGESTRATION_FESS*16384;
        pool15_price=REGESTRATION_FESS*32768;
        pool16_price=REGESTRATION_FESS*65536;
        pool17_price=REGESTRATION_FESS*131072;
        pool18_price=REGESTRATION_FESS*262144;

        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: 0,
            coreferrerID:0,
            referredUsers:0,
            coreferredUsers:0,
            income:0
           
        });
        
        users[ownerWallet] = userStruct;
       userList[currUserID] = ownerWallet;
        exam = Exam(exam_);
       
         PoolUserStruct memory pooluserStruct;
        
        pool1currUserID++;

        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool1currUserID,
            payment_received:0
        });
    pool1activeUserID=pool1currUserID;
       pool1users[msg.sender] = pooluserStruct;
       pool1userList[pool1currUserID]=msg.sender;
      
        
        pool2currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool2currUserID,
            payment_received:0
        });
    pool2activeUserID=pool2currUserID;
       pool2users[msg.sender] = pooluserStruct;
       pool2userList[pool2currUserID]=msg.sender;
       
       
        pool3currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool3currUserID,
            payment_received:0
        });
    pool3activeUserID=pool3currUserID;
       pool3users[msg.sender] = pooluserStruct;
       pool3userList[pool3currUserID]=msg.sender;
       
       
         pool4currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool4currUserID,
            payment_received:0
        });
    pool4activeUserID=pool4currUserID;
       pool4users[msg.sender] = pooluserStruct;
       pool4userList[pool4currUserID]=msg.sender;

        
          pool5currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool5currUserID,
            payment_received:0
        });
    pool5activeUserID=pool5currUserID;
       pool5users[msg.sender] = pooluserStruct;
       pool5userList[pool5currUserID]=msg.sender;
       
       
         pool6currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool6currUserID,
            payment_received:0
        });
    pool6activeUserID=pool6currUserID;
       pool6users[msg.sender] = pooluserStruct;
       pool6userList[pool6currUserID]=msg.sender;
       
         pool7currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool7currUserID,
            payment_received:0
        });
    pool7activeUserID=pool7currUserID;
       pool7users[msg.sender] = pooluserStruct;
       pool7userList[pool7currUserID]=msg.sender;
       
       pool8currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool8currUserID,
            payment_received:0
        });
    pool8activeUserID=pool8currUserID;
       pool8users[msg.sender] = pooluserStruct;
       pool8userList[pool8currUserID]=msg.sender;
       
        pool9currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool9currUserID,
            payment_received:0
        });
    pool9activeUserID=pool9currUserID;
       pool9users[msg.sender] = pooluserStruct;
       pool9userList[pool9currUserID]=msg.sender;
       
       
        pool10currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool10currUserID,
            payment_received:0
        });
    pool10activeUserID=pool10currUserID;
       pool10users[msg.sender] = pooluserStruct;
       pool10userList[pool10currUserID]=msg.sender;
       
       
       pool11currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool11currUserID,
            payment_received:0
     
       
      });
      pool11activeUserID=pool11currUserID;
       pool11users[msg.sender] = pooluserStruct;
       pool11userList[pool11currUserID]=msg.sender;
       
       
       pool12currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool12currUserID,
            payment_received:0
       
      });
      pool12activeUserID=pool12currUserID;
       pool12users[msg.sender] = pooluserStruct;
       pool12userList[pool12currUserID]=msg.sender;
       
       
      pool13currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool13currUserID,
            payment_received:0
        });
    pool13activeUserID=pool13currUserID;
       pool13users[msg.sender] = pooluserStruct;
       pool13userList[pool3currUserID]=msg.sender;
       
       
         pool14currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool14currUserID,
            payment_received:0
        });
    pool14activeUserID=pool14currUserID;
       pool14users[msg.sender] = pooluserStruct;
       pool14userList[pool14currUserID]=msg.sender;

        
          pool15currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool15currUserID,
            payment_received:0
        });
    pool15activeUserID=pool15currUserID;
       pool15users[msg.sender] = pooluserStruct;
       pool15userList[pool15currUserID]=msg.sender;
       
       
         pool16currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool16currUserID,
            payment_received:0
        });
    pool16activeUserID=pool16currUserID;
       pool16users[msg.sender] = pooluserStruct;
       pool16userList[pool16currUserID]=msg.sender;
       
         pool17currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool17currUserID,
            payment_received:0
        });
    pool17activeUserID=pool17currUserID;
       pool17users[msg.sender] = pooluserStruct;
       pool17userList[pool17currUserID]=msg.sender;
       
       pool18currUserID++;
        pooluserStruct = PoolUserStruct({
            isExist:true,
            id:pool18currUserID,
            payment_received:0
        });
    pool18activeUserID=pool18currUserID;
       pool18users[msg.sender] = pooluserStruct;
       pool18userList[pool18currUserID]=msg.sender; 
       
      }
     
       function Registration(uint _referrerID,uint _coreferrerID, uint256 amount) public {
       
      require(!users[msg.sender].isExist, "User Exists");
      require(_referrerID > 0 && _referrerID <= currUserID, "Incorrect referral ID");
      require(_coreferrerID > 0,"Incorrect coreferral ID");
      require(exam.isQualified(userList[_coreferrerID]),"CO_REFERRER_NOT_QUALIFIED");
        if(_coreferrerID != 1){
        require(users[userList[_coreferrerID]].referredUsers >=2,"Co-Referral-should-be-2");
        }
      require(amount == REGESTRATION_FESS, 'Incorrect Value');
       require(busd.allowance(msg.sender, address(this)) >= amount,"NEED_TO_APPROVE_TOKEN"); 
       busd.transferFrom(msg.sender,address(this),amount);
   
        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: _referrerID,
            coreferrerID:_coreferrerID,
            referredUsers:0,
            coreferredUsers:0,
            income:0
        });
   
    
       users[msg.sender] = userStruct;
       userList[currUserID]=msg.sender;
       
        users[userList[users[msg.sender].referrerID]].referredUsers=users[userList[users[msg.sender].referrerID]].referredUsers+1;
        users[userList[users[msg.sender].coreferrerID]].coreferredUsers=users[userList[users[msg.sender].coreferrerID]].coreferredUsers+1;
       payReferral(1,msg.sender);
       paycoReferral(1,msg.sender);
        emit regLevelEvent(msg.sender, userList[_referrerID], now);
    }
   
   
     function payReferral(uint _level, address _user) internal {
        address referer;
       
        referer = userList[users[_user].referrerID];
       
       
         bool sent = false;
       
            uint level_price_local=0;
            if(_level>2){
            level_price_local=unlimited_level_price;
            }
            else{
            level_price_local=LEVEL_PRICE[_level];
            }
            
            sent = busd.transfer(address(uint160(referer)),level_price_local);
            if (sent) {
                emit referrerIncome(referer, msg.sender, _level, now);
                if(_level < 2 && users[referer].referrerID >= 1){
                    payReferral(_level+1,referer);
                }
                
                else
                {
                    sendBalance();
                }
               
            }
       
        if(!sent) {
          //  emit lostMoneyForLevelEvent(referer, msg.sender, _level, now);

            payReferral(_level, referer);
        }
     }
   
       function paycoReferral(uint _level, address _user) internal {
        address referer;
       
        referer = userList[users[_user].coreferrerID];
       
       
         bool sent = false;
       
            uint level_price_local=0;
            if(_level>2){
            level_price_local=unlimited_level_price;
            }
            else{
            level_price_local=LEVEL_PRICE[_level];
            }
            
            sent = busd.transfer(address(uint160(referer)),level_price_local);
            if (sent) {
                emit coreferrerIncome(referer, msg.sender, _level, now);
                if(_level < 2 && users[referer].referrerID >= 1){
                    paycoReferral(_level+1,referer);
                }
                
                else
                {
                    sendBalance();
                }
               
            }
       
        if(!sent) {
          //  emit lostMoneyForLevelEvent(referer, msg.sender, _level, now);

            paycoReferral(_level, referer);
        }
     }
   
       function buyPool1(uint256 amount) public {
       require(users[msg.sender].isExist, "User Not Registered");
      require(!pool1users[msg.sender].isExist, "Already in AutoPool");
      
        require(amount == pool1_price, 'Incorrect Value');
       require(busd.allowance(msg.sender, address(this)) >= amount,"NEED_TO_APPROVE_TOKEN"); 
       busd.transferFrom(msg.sender,address(this),amount);
        address referer;
       referer = userList[users[msg.sender].referrerID];
       
       address introducer;
       introducer = userList[users[msg.sender].coreferrerID];

        bool sent1 = false;

       sent1 = busd.transfer(address(uint160(referer)),pool1_price/10);
       emit SponsorPool1Payment(msg.sender,referer);

       users[userList[users[msg.sender].referrerID]].income = users[userList[users[msg.sender].referrerID]].income + (pool1_price / 10);

       bool sent2 = false;
       sent2 = busd.transfer(address(uint160(introducer)),pool1_price/10);
       emit IntroducerPool1Payment(msg.sender,introducer);
       

       users[userList[users[msg.sender].referrerID]].income = users[userList[users[msg.sender].referrerID]].income + (pool1_price / 10);
        PoolUserStruct memory userStruct;
        address pool1Currentuser=pool1userList[pool1activeUserID];
        
        pool1currUserID++;

        userStruct = PoolUserStruct({
            isExist:true,
            id:pool1currUserID,
            payment_received:0
        });
   
       pool1users[msg.sender] = userStruct;
       pool1userList[pool1currUserID]=msg.sender;
       bool sent = false;
 
       sent = busd.transfer(address(uint160(pool1Currentuser)),pool1_price/10*4);
            if (sent) {
                pool1users[pool1Currentuser].payment_received+=1;
                if(pool1users[pool1Currentuser].payment_received>=2)
                {
                    pool1activeUserID+=1;
                }
                emit getPoolPayment(msg.sender,pool1Currentuser, 1, now);
            }
       emit regPoolEntry(msg.sender, 1, now);
    }
    
    
      function buyPool2() public payable {
          require(users[msg.sender].isExist, "User Not Registered");
      require(!pool2users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool2_price, 'Incorrect Value');
         
        PoolUserStruct memory userStruct;
        address pool2Currentuser=pool2userList[pool2activeUserID];
        
        pool2currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool2currUserID,
            payment_received:0
        });
       pool2users[msg.sender] = userStruct;
       pool2userList[pool2currUserID]=msg.sender;
       
       
       
       bool sent = false;
       sent = address(uint160(pool2Currentuser)).send(pool2_price);

            if (sent) {
                pool2users[pool2Currentuser].payment_received+=1;
                if(pool2users[pool2Currentuser].payment_received>=2)
                {
                    pool2activeUserID+=1;
                }
                emit getPoolPayment(msg.sender,pool2Currentuser, 2, now);
            }
            emit regPoolEntry(msg.sender,2,  now);
    }
    
    
     function buyPool3() public payable {
         require(users[msg.sender].isExist, "User Not Registered");
      require(!pool3users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool3_price, 'Incorrect Value');
        
        
        PoolUserStruct memory userStruct;
        address pool3Currentuser=pool3userList[pool3activeUserID];
        
        pool3currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool3currUserID,
            payment_received:0
        });
       pool3users[msg.sender] = userStruct;
       pool3userList[pool3currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool3Currentuser)).send(pool3_price);

            if (sent) {
                pool3users[pool3Currentuser].payment_received+=1;
                if(pool3users[pool3Currentuser].payment_received>=2)
                {
                    pool3activeUserID+=1;
                }
                emit getPoolPayment(msg.sender,pool3Currentuser, 3, now);
            }
emit regPoolEntry(msg.sender,3,  now);
    }
    
    
    function buyPool4() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
      require(!pool4users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool4_price, 'Incorrect Value');
        
      
        PoolUserStruct memory userStruct;
        address pool4Currentuser=pool4userList[pool4activeUserID];
        
        pool4currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool4currUserID,
            payment_received:0
        });
       pool4users[msg.sender] = userStruct;
       pool4userList[pool4currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool4Currentuser)).send(pool4_price);

            if (sent) {
                pool4users[pool4Currentuser].payment_received+=1;
                if(pool4users[pool4Currentuser].payment_received>=2)
                {
                    pool4activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool4Currentuser, 4, now);
            }
        emit regPoolEntry(msg.sender,4, now);
    }
    
    
    
    function buyPool5() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
      require(!pool5users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool5_price, 'Incorrect Value');
    
        
        PoolUserStruct memory userStruct;
        address pool5Currentuser=pool5userList[pool5activeUserID];
        
        pool5currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool5currUserID,
            payment_received:0
        });
       pool5users[msg.sender] = userStruct;
       pool5userList[pool5currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool5Currentuser)).send(pool5_price);

            if (sent) {
                pool5users[pool5Currentuser].payment_received+=1;
                if(pool5users[pool5Currentuser].payment_received>=2)
                {
                    pool5activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool5Currentuser, 5, now);
            }
        emit regPoolEntry(msg.sender,5,  now);
    }
    
    function buyPool6() public payable {
      require(!pool6users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool6_price, 'Incorrect Value');
        
        
        PoolUserStruct memory userStruct;
        address pool6Currentuser=pool6userList[pool6activeUserID];
        
        pool6currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool6currUserID,
            payment_received:0
        });
       pool6users[msg.sender] = userStruct;
       pool6userList[pool6currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool6Currentuser)).send(pool6_price);

            if (sent) {
                pool6users[pool6Currentuser].payment_received+=1;
                if(pool6users[pool6Currentuser].payment_received>=2)
                {
                    pool6activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool6Currentuser, 6, now);
            }
        emit regPoolEntry(msg.sender,6,  now);
    }
    
    function buyPool7() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
      require(!pool7users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool7_price, 'Incorrect Value');
        require(users[msg.sender].referredUsers>=1, "Must need 1 referral");
        
        PoolUserStruct memory userStruct;
        address pool7Currentuser=pool7userList[pool7activeUserID];
        
        pool7currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool7currUserID,
            payment_received:0
        });
       pool7users[msg.sender] = userStruct;
       pool7userList[pool7currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool7Currentuser)).send(pool7_price);

            if (sent) {
                pool7users[pool7Currentuser].payment_received+=1;
                if(pool7users[pool7Currentuser].payment_received>=2)
                {
                    pool7activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool7Currentuser, 7, now);
            }
        emit regPoolEntry(msg.sender,7,  now);
    }
    
    
    function buyPool8() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
      require(!pool8users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool8_price, 'Incorrect Value');
        require(users[msg.sender].referredUsers>=2, "Must need 2 referral");
       
        PoolUserStruct memory userStruct;
        address pool8Currentuser=pool8userList[pool8activeUserID];
        
        pool8currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool8currUserID,
            payment_received:0
        });
       pool8users[msg.sender] = userStruct;
       pool8userList[pool8currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool8Currentuser)).send(pool8_price);

            if (sent) {
                pool8users[pool8Currentuser].payment_received+=1;
                if(pool8users[pool8Currentuser].payment_received>=2)
                {
                    pool8activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool8Currentuser, 8, now);
            }
        emit regPoolEntry(msg.sender,8,  now);
    }
    
    
    
    function buyPool9() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
      require(!pool9users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool9_price, 'Incorrect Value');
        require(users[msg.sender].referredUsers>=3, "Must need 3 referral");
       
        PoolUserStruct memory userStruct;
        address pool9Currentuser=pool9userList[pool9activeUserID];
        
        pool9currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool9currUserID,
            payment_received:0
        });
       pool9users[msg.sender] = userStruct;
       pool9userList[pool9currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool9Currentuser)).send(pool9_price);

            if (sent) {
                pool9users[pool9Currentuser].payment_received+=1;
                if(pool9users[pool9Currentuser].payment_received>=2)
                {
                    pool9activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool9Currentuser, 9, now);
            }
        emit regPoolEntry(msg.sender,9,  now);
    }
    
    
    function buyPool10() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
      require(!pool10users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool10_price, 'Incorrect Value');
        require(users[msg.sender].referredUsers>=4, "Must need 4 referral");
        
        PoolUserStruct memory userStruct;
        address pool10Currentuser=pool10userList[pool10activeUserID];
        
        pool10currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool10currUserID,
            payment_received:0
        });
       pool10users[msg.sender] = userStruct;
       pool10userList[pool10currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool10Currentuser)).send(pool10_price);

            if (sent) {
                pool10users[pool10Currentuser].payment_received+=1;
                if(pool10users[pool10Currentuser].payment_received>=2)
                {
                    pool10activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool10Currentuser, 10, now);
            }
        emit regPoolEntry(msg.sender, 10, now);
    }
    
    function buyPool11() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
      require(!pool11users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool11_price, 'Incorrect Value');
        require(users[msg.sender].referredUsers>=5, "Must need 5 referral");
        
        PoolUserStruct memory userStruct;
        address pool11Currentuser=pool11userList[pool11activeUserID];
        
        pool11currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool11currUserID,
            payment_received:0
        });
       pool11users[msg.sender] = userStruct;
       pool11userList[pool11currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool11Currentuser)).send(pool11_price);

            if (sent) {
                pool11users[pool11Currentuser].payment_received+=1;
                if(pool11users[pool11Currentuser].payment_received>=2)
                {
                    pool11activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool11Currentuser, 11, now);
            }
        emit regPoolEntry(msg.sender, 11, now);
    }
    
    function buyPool12() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
      require(!pool12users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool12_price, 'Incorrect Value');
        require(users[msg.sender].referredUsers>=6, "Must need 6 referral");
        
        PoolUserStruct memory userStruct;
        address pool12Currentuser=pool12userList[pool12activeUserID];
        
        pool12currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool12currUserID,
            payment_received:0
        });
       pool12users[msg.sender] = userStruct;
       pool12userList[pool12currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool12Currentuser)).send(pool12_price);

            if (sent) {
                pool12users[pool12Currentuser].payment_received+=1;
                if(pool12users[pool12Currentuser].payment_received>=2)
                {
                    pool12activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool12Currentuser, 12, now);
            }
        emit regPoolEntry(msg.sender, 12, now);
    }

     function buyPool13() public payable {
         require(users[msg.sender].isExist, "User Not Registered");
      require(!pool13users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool13_price, 'Incorrect Value');
        
        
        PoolUserStruct memory userStruct;
        address pool13Currentuser=pool13userList[pool13activeUserID];
        
        pool13currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool13currUserID,
            payment_received:0
        });
       pool13users[msg.sender] = userStruct;
       pool13userList[pool13currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool13Currentuser)).send(pool13_price);

            if (sent) {
                pool13users[pool13Currentuser].payment_received+=1;
                if(pool13users[pool13Currentuser].payment_received>=2)
                {
                    pool13activeUserID+=1;
                }
                emit getPoolPayment(msg.sender,pool13Currentuser, 13, now);
            }
      emit regPoolEntry(msg.sender,13,  now);
    }
    
    
    function buyPool14() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
      require(!pool14users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool14_price, 'Incorrect Value');
        
      
        PoolUserStruct memory userStruct;
        address pool14Currentuser=pool14userList[pool14activeUserID];
        
        pool14currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool14currUserID,
            payment_received:0
        });
       pool14users[msg.sender] = userStruct;
       pool14userList[pool14currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool14Currentuser)).send(pool14_price);

            if (sent) {
                pool14users[pool14Currentuser].payment_received+=1;
                if(pool14users[pool14Currentuser].payment_received>=2)
                {
                    pool14activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool14Currentuser, 14, now);
            }
        emit regPoolEntry(msg.sender,14, now);
    }
    
    
    
    function buyPool15() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
      require(!pool15users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool15_price, 'Incorrect Value');
    
        
        PoolUserStruct memory userStruct;
        address pool15Currentuser=pool15userList[pool15activeUserID];
        
        pool15currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool15currUserID,
            payment_received:0
        });
       pool15users[msg.sender] = userStruct;
       pool15userList[pool15currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool15Currentuser)).send(pool15_price);

            if (sent) {
                pool15users[pool15Currentuser].payment_received+=1;
                if(pool15users[pool15Currentuser].payment_received>=2)
                {
                    pool15activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool15Currentuser, 15, now);
            }
        emit regPoolEntry(msg.sender,15,  now);
    }
    
    function buyPool16() public payable {
      require(!pool16users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool16_price, 'Incorrect Value');
        
        
        PoolUserStruct memory userStruct;
        address pool16Currentuser=pool16userList[pool16activeUserID];
        
        pool16currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool16currUserID,
            payment_received:0
        });
       pool16users[msg.sender] = userStruct;
       pool16userList[pool16currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool16Currentuser)).send(pool16_price);

            if (sent) {
                pool16users[pool16Currentuser].payment_received+=1;
                if(pool16users[pool16Currentuser].payment_received>=2)
                {
                    pool16activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool16Currentuser, 16, now);
            }
        emit regPoolEntry(msg.sender,16,  now);
    }    

    function buyPool17() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
      require(!pool17users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool17_price, 'Incorrect Value');
        require(users[msg.sender].referredUsers>=1, "Must need 1 referral");
        
        PoolUserStruct memory userStruct;
        address pool17Currentuser=pool17userList[pool17activeUserID];
        
        pool17currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool17currUserID,
            payment_received:0
        });
       pool17users[msg.sender] = userStruct;
       pool17userList[pool17currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool17Currentuser)).send(pool17_price);

            if (sent) {
                pool17users[pool17Currentuser].payment_received+=1;
                if(pool17users[pool17Currentuser].payment_received>=2)
                {
                    pool17activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool17Currentuser, 17, now);
            }
        emit regPoolEntry(msg.sender,17,  now);
    }
    
    
    function buyPool18() public payable {
        require(users[msg.sender].isExist, "User Not Registered");
      require(!pool18users[msg.sender].isExist, "Already in AutoPool");
        require(msg.value == pool18_price, 'Incorrect Value');
        require(users[msg.sender].referredUsers>=2, "Must need 2 referral");
       
        PoolUserStruct memory userStruct;
        address pool18Currentuser=pool18userList[pool18activeUserID];
        
        pool18currUserID++;
        userStruct = PoolUserStruct({
            isExist:true,
            id:pool18currUserID,
            payment_received:0
        });
       pool18users[msg.sender] = userStruct;
       pool18userList[pool18currUserID]=msg.sender;
       bool sent = false;
       sent = address(uint160(pool18Currentuser)).send(pool18_price);

            if (sent) {
                pool18users[pool18Currentuser].payment_received+=1;
                if(pool18users[pool18Currentuser].payment_received>=2)
                {
                    pool18activeUserID+=1;
                }
                 emit getPoolPayment(msg.sender,pool18Currentuser, 18, now);
            }
        emit regPoolEntry(msg.sender,18,  now);
    }
    


    function getEthBalance() public view returns(uint) {
    return address(this).balance;
    }
    
    function sendBalance() private
    {
         if (!address(uint160(ownerWallet)).send(getEthBalance()))
         {
             
         }
    }
   
   
}