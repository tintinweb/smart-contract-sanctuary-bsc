/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract RabbitHoleSmartGame  {
    
/*Start Mappings*/
mapping (address =>bool) private isReferal; 

mapping (address=>uint) private referals; 
mapping (uint =>address) private referalsID; 
mapping (address=>address) private referals_connect;



/*LVL1*/
mapping (address =>uint) private TimeRegistration1;  
mapping (address =>bool) private isHolder1; 
mapping (address =>uint) private CurrentPosition1;  
mapping (address=>uint) private usersId1; 
mapping (address=>uint) private usersId2; 
mapping (address=>uint) private usersId3;
mapping (address=>uint) private usersId4;
mapping (address=>uint) private usersId5;
mapping (address=>uint) private usersId6;
/*LVL2*/
mapping (address =>uint) private TimeRegistration2;  
mapping (address =>bool) private isHolder2; 
mapping (address =>uint) private CurrentPosition2;


/*LVL3*/
mapping (address =>uint) private TimeRegistration3;  
mapping (address =>bool) private isHolder3; 
mapping (address =>uint) private CurrentPosition3;


/*LVL4*/
mapping (address =>uint) private TimeRegistration4;  
mapping (address =>bool) private isHolder4; 
mapping (address =>uint) private CurrentPosition4;


/*LVL5*/
mapping (address =>uint) private TimeRegistration5; 
mapping (address =>bool) private isHolder5; 
mapping (address =>uint) private CurrentPosition5;  


/*LVL6*/
mapping (address =>uint) private TimeRegistration6; 
mapping (address =>bool) private isHolder6; 
mapping (address =>uint) private CurrentPosition6;  


/*End Mappings*/



/*Start main uints*/
address private owner=0xac3bE8b6Df694DA976e87BF72642Db4889002BC8; 
uint private referalID=0;  
address private OurBank;
address private Marketing;
uint private LockedToBank =0; 
uint private refPercent =5;
uint private bankPercent =25;
uint private userPercent =60;
uint private adminsPercent =10;
uint private totalBNB=0;
uint private deals=0;



/*LVL1*/
uint  private countppl1=0;
uint private maxppl1 =1; 
uint private AlicaCount1=0; 
uint private AlicaForHour1 = 1; 
uint private lostIncome1=0; 
uint private userId1=0; 
/*LVL2*/
uint  private countppl2=0;
uint private maxppl2 =1; 
uint private AlicaCount2=0; 
uint private AlicaForHour2 = 2; 
uint private lostIncome2=0; 
uint private userId2=0; 
/*LVL3*/
uint  private countppl3=0;
uint private maxppl3 =1; 
uint private AlicaCount3=300; 
uint private AlicaForHour3 = 3; 
uint private lostIncome3=0; 
uint private userId3=0; 
/*LVL4*/
uint  private countppl4=0;
uint private maxppl4 =1; 
uint private AlicaCount4=0; 
uint private AlicaForHour4 = 6; 
uint private lostIncome4=0; 
uint private userId4=0; 
/*LVL5*/
uint  private countppl5=0;
uint private maxppl5 =1; 
uint private AlicaCount5=1000; 
uint private AlicaForHour5 = 8; 
uint private lostIncome5=0; 
uint private userId5=0; 
/*LVL6*/
uint  private countppl6=0;
uint private maxppl6 =1; 
uint private AlicaCount6=2000; 
uint private AlicaForHour6 = 10; 
uint private lostIncome6=0; 
uint private userId6=0; 

/*END main uints*/



//Структура пользователя пула
struct User{
    address from;
    uint referal;
    uint countGetBNB1;
    uint countGetBNB2;
    uint countGetBNB3;
    uint countGetBNB4;
    uint countGetBNB5;
    uint countGetBNB6;
    uint refBalance1;
    uint refBalance2;
    uint refBalance3;
    uint refBalance4;
    uint refBalance5;
    uint refBalance6;
}

//объявляем массив из структуры пользователя
User[] private users1;
User[] private users2;
User[] private users3;
User[] private users4;
User[] private users5;
User[] private users6;      




/*Start Events*/
event BuyLvl(address indexed _addr, uint indexed lvl, uint indexed id);
event TakeBnb1(address indexed _addr, uint bnb, uint indexed id,uint indexed time);
/*End events*/






constructor(address _owner,address _OurBank,address _marketing){ 
   require(msg.sender==owner,'You are not Owner');
 owner = _owner;
  OurBank=_OurBank;
 Marketing=_marketing;
 users1.push(User(Marketing,0,0,0,0,0,0,0,0,0,0,0,0,0));
 users2.push(User(Marketing,0,0,0,0,0,0,0,0,0,0,0,0,0));
 users3.push(User(Marketing,0,0,0,0,0,0,0,0,0,0,0,0,0));
 users4.push(User(Marketing,0,0,0,0,0,0,0,0,0,0,0,0,0));
 users5.push(User(Marketing,0,0,0,0,0,0,0,0,0,0,0,0,0));
 users6.push(User(Marketing,0,0,0,0,0,0,0,0,0,0,0,0,0));
 addReferal(Marketing);

}
 



 /*Start modifiers*/
//Модификация не позволяет принимать повторно оплату от пользователя, который уже в пуле
modifier isReferalAlready (address _addr){  
 require (isReferal[_addr]==false, "You're already have referal link!");  
 _;
 }
modifier minimumSend1 (address _addr,uint send){  
 require (send==0.1 ether, "Wrong amount BNB");  
 _;
 }
 modifier minimumSend2 (address _addr,uint send){  
 require (send==0.2 ether, "Wrong amount BNB");  
 _;
 }
  modifier minimumSend3 (address _addr,uint send){  
 require (send==0.3 ether, "Wrong amount BNB");  
 _;
 }
   modifier minimumSend4 (address _addr,uint send){  
 require (send==0.6 ether, "Wrong amount BNB");  
 _;
 }
    modifier minimumSend5 (address _addr,uint send){  
 require (send==0.8 ether, "Wrong amount BNB");  
 _;
 }
     modifier minimumSend6 (address _addr,uint send){  
 require (send==1 ether, "Wrong amount BNB");  
 _;
 }
//Выполняем действие только если обращается владелец контракта
modifier isOwner() {
   
        require(msg.sender == owner, "Caller is not owner");
        _;
 }


//Отображаем сколько токенов накапало, только если человек учавствует в проекте
modifier TimeNotZero1(address addr) {
   
        require(TimeRegistration1[addr] != 0, "You are not registered");
        _;
 }
 modifier TimeNotZero2(address addr) {
   
        require(TimeRegistration2[addr] != 0, "You are not registered");
        _;
 }
 modifier TimeNotZero3(address addr) {
   
        require(TimeRegistration3[addr] != 0, "You are not registered");
        _;
 }
 modifier TimeNotZero4(address addr) {
   
        require(TimeRegistration4[addr] != 0, "You are not registered");
        _;
 }
 modifier TimeNotZero5(address addr) {
   
        require(TimeRegistration5[addr] != 0, "You are not registered");
        _;
 }
 modifier TimeNotZero6(address addr) {
   
        require(TimeRegistration6[addr] != 0, "You are not registered");
        _;
 }
//Модификация не позволяет принимать повторно оплату от пользователя, который уже в пуле
modifier isHolder_1 (address _addr){  
 require (isHolder1[_addr]==false, "You're already in pool!");  
 _;
 }
 modifier isHolder_2 (address _addr){  
 require (isHolder2[_addr]==false, "You're already in pool!");  
 _;
 }
 modifier isHolder_3 (address _addr){  
 require (isHolder3[_addr]==false, "You're already in pool!");  
 _;
 }
 modifier isHolder_4 (address _addr){  
 require (isHolder4[_addr]==false, "You're already in pool!");  
 _;
 }
 modifier isHolder_5 (address _addr){  
 require (isHolder5[_addr]==false, "You're already in pool!");  
 _;
 }
 modifier isHolder_6 (address _addr){  
 require (isHolder6[_addr]==false, "You're already in pool!");  
 _;
 }
/*END modifiers*/






/*Start MAIN functions*/

//добавление реферела
function addReferal(address addr) public isReferalAlready(addr) returns (uint)  {  
 referals[addr]=referalID;   
 referalsID[referalID]=addr; 
 referalID++;
 isReferal[addr]=true;
 return referalID-1;
 }





/*LVL1*/
function refreshCountPpl1 () private{  
    countppl1=0;
 }

function updateMaxppl1 () private{  
    maxppl1=users1.length;
 }

function resetMaxppl1 () private {
    maxppl1=10;
 }

function _CreateUser1 (address _addr,uint ID) private  isHolder_1(_addr){  
 isHolder1[_addr]=true;

 if (ID==0){referals_connect[_addr]=referalsID[0];}
 else{referals_connect[_addr]=referalsID[ID];} 

    userId1++;
    usersId1[_addr]=userId1;
    TimeRegistration1[_addr]=block.timestamp;
 users1.push(User(_addr,ID,0,0,0,0,0,0,0,0,0,0,0,0));

 }


/*LVL2*/
function refreshCountPpl2 () private{  
    countppl2=0;
 }

function updateMaxppl2 () private{  
    maxppl2=users2.length;
 }

function resetMaxppl2 () private {
    maxppl2=10;
 }

function _CreateUser2 (address _addr) private  isHolder_2(_addr){  
 isHolder2[_addr]=true; 
 userId2++;
    usersId2[_addr]=userId2;
 TimeRegistration2[_addr]=block.timestamp;
 users2.push(users1[usersId1[_addr]]);

 }


 /*LVL3*/
function refreshCountPpl3 () private{  
    countppl3=0;
 }

function updateMaxppl3 () private{  
    maxppl3=users3.length;
 }

function resetMaxppl3 () private {
    maxppl3=10;
 }

function _CreateUser3 (address _addr) private  isHolder_3(_addr){  
 isHolder3[_addr]=true; 
 TimeRegistration3[_addr]=block.timestamp;
 userId3++;
    usersId3[_addr]=userId3;
 users3.push(users2[usersId2[_addr]]);
 }


  /*LVL4*/
function refreshCountPpl4 () private{  
    countppl4=0;
 }

function updateMaxppl4 () private{  
    maxppl4=users4.length;
 }

function resetMaxppl4 () private {
    maxppl4=10;
 }

function _CreateUser4 (address _addr) private  isHolder_4(_addr){  
 isHolder4[_addr]=true; 
 userId4++;
    usersId4[_addr]=userId4;
 TimeRegistration4[_addr]=block.timestamp;
 users4.push(users3[usersId3[_addr]]);
 }


   /*LVL5*/
function refreshCountPpl5 () private{  
    countppl5=0;
 }

function updateMaxppl5 () private{  
    maxppl5=users5.length;
 }

function resetMaxppl5 () private {
    maxppl5=10;
 }

function _CreateUser5 (address _addr) private  isHolder_5(_addr){  
 isHolder5[_addr]=true; 
 userId5++;
usersId5[_addr]=userId5;
 TimeRegistration5[_addr]=block.timestamp;
 users5.push(users4[usersId4[_addr]]);
 }


   /*LVL6*/
function refreshCountPpl6 () private{  
    countppl6=0;
 }

function updateMaxppl6 () private{  
    maxppl6=users6.length;
 }

function resetMaxppl6 () private {
    maxppl6=10;
 }

function _CreateUser6 (address _addr) private  isHolder_6(_addr){  
 isHolder6[_addr]=true; 
 userId6++;
    usersId6[_addr]=userId6;
 TimeRegistration6[_addr]=block.timestamp;
 users6.push(users5[usersId5[_addr]]);
 }


/*END MAIN functions */







/*Start VIEW functions*/

function getReferalId(address addr) external view  returns (uint){
   require (isReferal[addr]==true, "You are not a referral yet!");  
    return referals[addr];
 }

function ViewTotalBnb () external view returns (uint) {
    return totalBNB;
 }

function ViewTotalALS() external view returns (uint) {
    return AlicaCount1*users1.length+AlicaCount2*users2.length+AlicaCount3*users3.length+AlicaCount4*users4.length+AlicaCount5*users5.length+AlicaCount6*users6.length;
 }

function LockedToBankCount() external view returns (uint) {
    return LockedToBank;
 }

function GetPplCountAll() external view returns(uint){
        return users1.length;
 }
function isInlvl (address adres) external view returns (bool lvl1,bool lvl2,bool lvl3,bool lvl4,bool lvl5,bool lvl6) {
    return (isHolder1[adres],isHolder2[adres],isHolder3[adres],isHolder4[adres],isHolder5[adres],isHolder6[adres]);
 }

function DealsDone() external view returns(uint){
        return deals;
 }

function userGetBnb(address addr) external view returns(uint){
   require (isHolder1[addr]==true, "You're not in pool!");  
        return users1[usersId1[addr]].countGetBNB1+users2[usersId2[addr]].countGetBNB2+users3[usersId3[addr]].countGetBNB3+users4[usersId4[addr]].countGetBNB4+users5[usersId5[addr]].countGetBNB5+users6[usersId6[addr]].countGetBNB6;
 }


function userGetRefGet(address addr) external view returns(uint){
   require (isHolder1[addr]==true, "You're not in pool!");  
        return users1[usersId1[addr]].refBalance1+users2[usersId2[addr]].refBalance2+users3[usersId3[addr]].refBalance3+users4[usersId4[addr]].refBalance4+users5[usersId5[addr]].refBalance5+users6[usersId6[addr]].refBalance6;
 }

function GetAllUsersCount() public view returns (uint lvl1, uint lvl2,uint lvl3,uint lvl4,uint lvl5,uint lvl6){
return (users1.length,users2.length,users3.length,users4.length,users5.length,users6.length);
}

function GetCurrentPpl() external view returns(uint ppl1,uint ppl2,uint ppl3,uint ppl4,uint ppl5,uint ppl6){
        return (countppl1,countppl2,countppl3,countppl4,countppl5,countppl6);
 }

 function ViewBnbReward (address addres) external view returns (uint lvl1,uint lvl2,uint lvl3,uint lvl4,uint lvl5,uint lvl6) {
    require (isHolder1[addres]==true, "You're not in pool!");  
    return (users1[usersId1[addres]].countGetBNB1,users2[usersId2[addres]].countGetBNB2,users3[usersId3[addres]].countGetBNB3,users4[usersId4[addres]].countGetBNB4,users5[usersId5[addres]].countGetBNB5,users6[usersId6[addres]].countGetBNB6);
 }

function GetReferelIncome(address addres) external view  returns(uint lvl1,uint lvl2,uint lvl3,uint lvl4,uint lvl5,uint lvl6) {
   require (isHolder1[addres]==true, "You're not in pool!");  
        return (users1[usersId1[addres]].refBalance1,users2[usersId2[addres]].refBalance2,users3[usersId3[addres]].refBalance3,users4[usersId4[addres]].refBalance4,users5[usersId5[addres]].refBalance5,users6[usersId6[addres]].refBalance6);
 }

function GetlostIncome() external view returns(uint lvl1,uint lvl2,uint lvl3,uint lvl4,uint lvl5,uint lvl6){
   
        return (lostIncome1,lostIncome2,lostIncome3,lostIncome4,lostIncome5,lostIncome6);
 }


function GetCurrentPosition(address addr) external view returns(uint lvl1,uint lvl2,uint lvl3,uint lvl4,uint lvl5,uint lvl6){
   require (isHolder1[addr]==true, "You're not in pool!");  
        return (CurrentPosition1[addr],CurrentPosition2[addr],CurrentPosition3[addr],CurrentPosition4[addr],CurrentPosition5[addr],CurrentPosition6[addr]);
 }


 /*LVL1*/




function ViewGettingAlicaToUser1 (address addres) external view TimeNotZero1(addres) returns (uint) {
   if(((block.timestamp-TimeRegistration1[addres])/3600)*AlicaForHour1 < 72){
   return ((block.timestamp-TimeRegistration1[addres])/3600)*AlicaForHour1+AlicaCount1;
   }
    else{return 72+AlicaCount1;}
 }




 /*LVL2*/



function ViewGettingAlicaToUser2 (address addres) external view TimeNotZero2(addres) returns (uint) {
   if(((block.timestamp-TimeRegistration2[addres])/3600)*AlicaForHour2<144){
    return ((block.timestamp-TimeRegistration2[addres])/3600)*AlicaForHour2+AlicaCount2;
    }
    else{return 144+AlicaCount2;}
 }



 /*LVL3*/



function ViewGettingAlicaToUser3 (address addres) external view TimeNotZero3(addres) returns (uint) {
   if(((block.timestamp-TimeRegistration3[addres])/3600)*AlicaForHour3<216){
return ((block.timestamp-TimeRegistration3[addres])/3600)*AlicaForHour3+AlicaCount3;
   }
    else{return 216+AlicaCount3;}
 }



 /*LVL4*/



function ViewGettingAlicaToUser4 (address addres) external view TimeNotZero4(addres) returns (uint) {
   if(((block.timestamp-TimeRegistration4[addres])/3600)*AlicaForHour4<720){
return ((block.timestamp-TimeRegistration4[addres])/3600)*AlicaForHour4+AlicaCount4;
   }
   else{return 720+AlicaCount4;}
    
 }



 /*LVL5*/



function ViewGettingAlicaToUser5 (address addres) external view TimeNotZero5(addres) returns (uint) {
       if(((block.timestamp-TimeRegistration5[addres])/3600)*AlicaForHour5<960){
return ((block.timestamp-TimeRegistration5[addres])/3600)*AlicaForHour5+AlicaCount5;
   }
   else{return 960+AlicaCount5;}
 }


 /*LVL6*/



function ViewGettingAlicaToUser6 (address addres) external view TimeNotZero6(addres) returns (uint) {
           if(((block.timestamp-TimeRegistration6[addres])/3600)*AlicaForHour6<1200){
return ((block.timestamp-TimeRegistration6[addres])/3600)*AlicaForHour6+AlicaCount6;
   }
   else{return 1200+AlicaCount6;}
 }




 
/*End VIEW functions*/







/*Start payable functions*/

/*LVL1*/
function getPaymant1 (uint ID) public payable isHolder_1(msg.sender) minimumSend1(msg.sender,msg.value){
 _CreateUser1(msg.sender,ID); 
 totalBNB+=msg.value;
 payable(OurBank).transfer((msg.value/100)*25);
 payable(Marketing).transfer((msg.value/100)*10); 
 payable(referals_connect[msg.sender]).transfer((msg.value/100)*5);
 users1[usersId1[referals_connect[msg.sender]]].refBalance1+=(msg.value/100)*5; 
 LockedToBank+=(msg.value/100)*25;
 deals++;
 CurrentPosition1[msg.sender]=usersId1[msg.sender];
 for(uint i = 0; i < maxppl1; i++){
    
 users1[countppl1].countGetBNB1+=((msg.value/100)*60)/maxppl1;
 payable(users1[countppl1].from).transfer(((msg.value/100)*60)/maxppl1);
 totalBNB+=((msg.value/100)*60)/maxppl1;
    
 countppl1++;
 if(countppl1 == users1.length-1){refreshCountPpl1();lostIncome1+=((msg.value/100)*60)/maxppl1;}
 }


 if(users1.length<10){maxppl1++;}
 else{maxppl1=10;}
 }


 /*LVL2*/
function getPaymant2 () public payable isHolder_2(msg.sender) minimumSend2(msg.sender,msg.value){
   require (isHolder1[msg.sender]==true, "Lvl 1 require to buy!");  
 _CreateUser2(msg.sender); 
 totalBNB+=msg.value;




 payable(OurBank).transfer(((msg.value/100)*bankPercent));
 payable(Marketing).transfer(((msg.value/100)*adminsPercent)); 
 payable(referals_connect[msg.sender]).transfer(((msg.value/100)*refPercent));
 users2[usersId2[referals_connect[msg.sender]]].refBalance2+=((msg.value/100)*refPercent); 
 LockedToBank+=((msg.value/100)*bankPercent);
 deals++;
 CurrentPosition2[msg.sender]=usersId2[msg.sender];
 emit BuyLvl(msg.sender, 2, usersId2[msg.sender]);
 for(uint i = 0; i < maxppl2; i++){
    
 users2[countppl2].countGetBNB2+=((msg.value/100)*userPercent)/maxppl2;
 payable(users2[countppl2].from).transfer(((msg.value/100)*userPercent)/maxppl2);
 totalBNB+=((msg.value/100)*userPercent)/maxppl2;
    
 countppl2++;
 if(countppl2 == users2.length-1){refreshCountPpl2();lostIncome2+=((msg.value/100)*userPercent)/maxppl2;}
 }


 if(users2.length<10){maxppl2++;}
 else{maxppl2=10;}
 }


  /*LVL3*/
function getPaymant3 () public payable isHolder_3(msg.sender) minimumSend3(msg.sender,msg.value){
   require (isHolder2[msg.sender]==true, "Lvl 2 require to buy!");  
 _CreateUser3(msg.sender); 
totalBNB+=msg.value;
payable(OurBank).transfer((msg.value/100)*bankPercent);
 payable(Marketing).transfer((msg.value/100)*adminsPercent); 
 payable(referals_connect[msg.sender]).transfer((msg.value/100)*refPercent);
 users3[usersId3[referals_connect[msg.sender]]].refBalance3+=(msg.value/100)*refPercent; 
 LockedToBank+=(msg.value/100)*bankPercent;
 deals++;
 CurrentPosition3[msg.sender]=usersId3[msg.sender];
 emit BuyLvl(msg.sender, 3, usersId3[msg.sender]);
 for(uint i = 0; i < maxppl3; i++){
    
 users3[countppl3].countGetBNB3+=((msg.value/100)*userPercent)/maxppl3;
 payable(users3[countppl3].from).transfer(((msg.value/100)*userPercent)/maxppl3);
 totalBNB+=((msg.value/100)*userPercent)/maxppl3;
    
 countppl3++;
 if(countppl3 == users3.length-1){refreshCountPpl3();lostIncome3+=((msg.value/100)*userPercent)/maxppl3;}
 }


 if(users3.length<10){maxppl3++;}
 else{maxppl3=10;}
  
 }


 /*LVL4*/
function getPaymant4 () public payable isHolder_4(msg.sender) minimumSend4(msg.sender,msg.value){
   require (isHolder3[msg.sender]==true, "Lvl 3 require to buy!");  
 _CreateUser4(msg.sender); 

 totalBNB+=msg.value; //


 payable(OurBank).transfer((msg.value/100)*bankPercent);//
 payable(Marketing).transfer((msg.value/100)*adminsPercent); //
 payable(referals_connect[msg.sender]).transfer((msg.value/100)*refPercent);//
 users4[usersId4[referals_connect[msg.sender]]].refBalance4+=(msg.value/100)*refPercent; 
 LockedToBank+=(msg.value/100)*bankPercent;//
 deals++;
 CurrentPosition4[msg.sender]=usersId4[msg.sender];
 emit BuyLvl(msg.sender, 4, usersId4[msg.sender]);
 for(uint i = 0; i < maxppl4; i++){
    
 users4[countppl4].countGetBNB4+=((msg.value/100)*userPercent)/maxppl4;
 payable(users4[countppl4].from).transfer(((msg.value/100)*userPercent)/maxppl4);
 totalBNB+=((msg.value/100)*userPercent)/maxppl4;
    
 countppl4++;
 if(countppl4 == users4.length-1){refreshCountPpl4();lostIncome4+=((msg.value/100)*userPercent)/maxppl4;}
 }


 if(users4.length<10){maxppl4++;}
 else{maxppl4=10;}
  
 }

  /*LVL5*/
function getPaymant5 () public payable isHolder_5(msg.sender) minimumSend5(msg.sender,msg.value){
   require (isHolder4[msg.sender]==true, "Lvl 4 require to buy!");  
 _CreateUser5(msg.sender); 

 totalBNB+=msg.value; //



 payable(OurBank).transfer((msg.value/100)*bankPercent);//
 payable(Marketing).transfer((msg.value/100)*adminsPercent); //
 payable(referals_connect[msg.sender]).transfer((msg.value/100)*refPercent);//
 users5[usersId5[referals_connect[msg.sender]]].refBalance5+=(msg.value/100)*refPercent; 
 LockedToBank+=(msg.value/100)*bankPercent;//
 deals++;
 CurrentPosition5[msg.sender]=usersId5[msg.sender];
 emit BuyLvl(msg.sender, 5, usersId5[msg.sender]);
 for(uint i = 0; i < maxppl5; i++){
    
 users5[countppl5].countGetBNB5+=((msg.value/100)*userPercent)/maxppl5;
 payable(users5[countppl5].from).transfer(((msg.value/100)*userPercent)/maxppl5);
 totalBNB+=((msg.value/100)*userPercent)/maxppl5;
    
 countppl5++;
 if(countppl5 == users5.length-1){refreshCountPpl5();lostIncome5+=((msg.value/100)*userPercent)/maxppl5;}
 }


 if(users5.length<10){maxppl5++;}
 else{maxppl5=10;}
  
 }

  /*LVL6*/
function getPaymant6 () public payable isHolder_6(msg.sender) minimumSend6(msg.sender,msg.value){
    require (isHolder5[msg.sender]==true, "Lvl 5 require to buy!");  
 _CreateUser6(msg.sender); 

 totalBNB+=msg.value; //


 payable(OurBank).transfer((msg.value/100)*bankPercent);//
 payable(Marketing).transfer((msg.value/100)*adminsPercent); //
 payable(referals_connect[msg.sender]).transfer((msg.value/100)*refPercent);//
 users6[usersId6[referals_connect[msg.sender]]].refBalance6+=(msg.value/100)*refPercent; 

 LockedToBank+=(msg.value/100)*bankPercent;//
 deals++;
 CurrentPosition6[msg.sender]=usersId6[msg.sender];
 emit BuyLvl(msg.sender, 6, usersId6[msg.sender]);
 for(uint i = 0; i < maxppl6; i++){
    
 users6[countppl6].countGetBNB6+=((msg.value/100)*userPercent)/maxppl6;
 payable(users6[countppl6].from).transfer(((msg.value/100)*userPercent)/maxppl6);
 totalBNB+=((msg.value/100)*userPercent)/maxppl6;
    
 countppl6++;
 if(countppl6 == users6.length-1){refreshCountPpl6();lostIncome6+=((msg.value/100)*userPercent)/maxppl6;}
 }


 if(users6.length<10){maxppl6++;}
 else{maxppl6=10;}
  
 }
/*End payable functions*/














}