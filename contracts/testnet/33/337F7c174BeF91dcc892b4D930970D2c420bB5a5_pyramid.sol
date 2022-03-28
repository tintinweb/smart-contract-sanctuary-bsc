/**
 *Submitted for verification at BscScan.com on 2022-03-27
*/

pragma solidity ^0.4.26;



contract pyramid  {
   struct person{
        address _ID;
        address parentID;
        address leftSon;
        address rightSon;
        bool hasLeft;        
        bool hasRight;
        uint rightAmount;
        uint leftAmount;
        uint found;
        uint gift;
        uint missedGift;
        uint getedGift;
        bool isRight;
        bool isOffer;
   }
   address owner;
 
   uint public minimumAmount = 10**15 wei; // 
   uint public totalAmount=0;
   // The total number of  the users have made
   uint public totalGift=0;
   uint public totalMissed=0;

   // The maximum amount of money can be taken from each player
   uint public maxAmount = 10**18 wei ;//2000

   // Array of players
   address[] public players;
   mapping(address => person) public playerDetail;

/// @notice Constructor that's used to configure ...
    constructor() public{
      owner = msg.sender;
      players.push(owner);
      person memory newPerson ;//= ...;//person(owner,owner,0,0,0,0,0,0,0,0,0,false);
      //  address _ID;address parentID; address leftSon;address rightSon;uint leftCount;uint rightCount;
      //  uint rightAmount; uint leftAmount;uint found; uint gift;uint missedGift;bool isRight;
      newPerson._ID =owner;
      newPerson.parentID = owner;
      //newPerson.leftSon =0;0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
      //newPerson.rightSon =0;
      newPerson.hasLeft = false;
      newPerson.hasRight = false;
      newPerson.rightAmount = 0;
      newPerson.leftAmount  = 0;
      newPerson.found  = 10**17 wei;
      newPerson.gift = 0 wei;
      newPerson.missedGift = 0 wei;
      newPerson.getedGift = 0 wei;
      newPerson.isRight = false;
      newPerson.isOffer = false;
      playerDetail[owner] = newPerson;
    }
///
    function isNewPlayer(address playerAddress) private view returns(bool) {
        if (players.length == 0) {
            return true;
        }
        return (playerDetail[playerAddress]._ID != playerAddress);
    }

/// 
     uint8 private testIndex =8;
     function addTest() public {
         assert (msg.sender == owner);
         //for (uint8 i=0;i<2;i++)
            participateTest(owner,address(keccak256(abi.encodePacked(++testIndex))));
        
     }

    function participateTest(address refralcode,address thisID) private 
    {     
      assert (msg.sender == owner);      
      person memory newPerson ;
      newPerson._ID =thisID;  
      //  address _ID;address parentID; address leftSon;address rightSon;uint leftCount;uint rightCount;
      //  uint rightAmount; uint leftAmount;uint found; uint gift;uint missedGift;bool isRight;
      
      if (isNewPlayer(thisID)) {

        if(isNewPlayer(refralcode))
            newPerson.parentID = owner;
        else
            newPerson.parentID = refralcode;

        newPerson._ID =thisID;        
        newPerson.leftSon =0;
        newPerson.rightSon =0;
        newPerson.hasLeft = false;
        newPerson.hasRight = false;
        newPerson.rightAmount = 0;
        newPerson.leftAmount  = 0;
        newPerson.found  =  10**16 wei;
        newPerson.gift = 0;
        newPerson.missedGift = 0;
        newPerson.getedGift = 0;
        newPerson.isRight = false;
        newPerson.isOffer = true;
        playerDetail[thisID] = newPerson;
        players.push(thisID);

        totalAmount += newPerson.found;
        if (thisID != owner)
        {
            person memory  newMem = playerDetail[newPerson._ID];
            person memory  parent = playerDetail[newMem.parentID];
            uint gift = newMem.found/10; //// msg.value
            if (gift > 0)
            {
                if (parent.gift+gift > 5*parent.found){

                    uint newGift = 5*parent.found - parent.gift;
                    totalMissed += gift- newGift;
                    totalGift += newGift;
                    parent.gift=5*parent.found;
                    parent.missedGift+= gift- newGift;
                    //parent._ID.transfer(newGift); /////send gift !
                }else{
                    totalGift += gift;
                    parent.gift+=gift;
                    //parent._ID.transfer(gift); /////send gift !
                }
                        
                playerDetail[newMem.parentID]=parent;
            }

            if (parent.leftAmount < parent.rightAmount)
                addMemberToLeft(parent,newMem);
            else
                addMemberToRight(parent,newMem);
        }
      }       
    }
   
   function participate(address refralcode) public payable
   {

      // Check that the amount paid is bigger or equal the minimum 
      assert(msg.value >= minimumAmount);
      assert(msg.value <= maxAmount);
      assert(playerDetail[msg.sender].found + msg.value <=maxAmount);

      person memory newPerson ;
      newPerson._ID =msg.sender;  
      //  address _ID;address parentID; address leftSon;address rightSon;uint leftCount;uint rightCount;
      //  uint rightAmount; uint leftAmount;uint found; uint gift;uint missedGift;bool isRight;
      
      if (isNewPlayer(msg.sender)) {

        if(isNewPlayer(refralcode))
            newPerson.parentID = owner;
        else
            newPerson.parentID = refralcode;

        newPerson._ID =msg.sender;        
        //newPerson.leftSon =0;
        //newPerson.rightSon =0;
        newPerson.hasLeft =false;
        newPerson.hasRight = false;
        newPerson.rightAmount = 0;
        newPerson.leftAmount  = 0;
        newPerson.found  =  msg.value - 6*10**16;
        newPerson.gift = 0;
        newPerson.missedGift = 0;
        newPerson.getedGift = 0;
        newPerson.isRight = false;
        playerDetail[msg.sender] = newPerson;
        players.push(msg.sender);

        if (msg.sender != owner)
        {
            person memory  newMem = playerDetail[msg.sender];
            person memory  parent = playerDetail[newMem.parentID];
            uint gift = newMem.found/10; //// msg.value
            if (parent.gift+gift > 5*parent.found){

                uint newGift = 5*parent.found - parent.gift;
                totalMissed += gift- newGift;
                totalGift += newGift;
                parent.gift=5*parent.found;
                parent.missedGift+= gift- newGift;
                ///test if (!parent.isOffer)
                    ///test parent._ID.transfer(newGift); /////send gift !
            }else{
                totalGift += gift;
                parent.gift+=gift;
                ///test if (!parent.isOffer)
                    ///test parent._ID.transfer(gift); /////send gift !
            }
                    
            playerDetail[newMem.parentID]=parent;

            if (parent.leftAmount < parent.rightAmount)
                addMemberToLeft(parent,newMem);
            else
                addMemberToRight(parent,newMem);
        }
      } else {
        playerDetail[msg.sender].found += msg.value - 6*10**16;
      }



      
    }
  
///
    function addMemberToRight(person memory p,person memory newMem) private{
        if (! p.hasRight ){
            p.rightSon = newMem._ID;
            p.hasRight = true;
            newMem.parentID = p._ID;
            newMem.isRight = true;
            playerDetail[newMem.parentID]=p;           
            playerDetail[newMem._ID]=newMem;
            updateBalance(p._ID,true,newMem.found);
        }else{
            person memory son = playerDetail[p.rightSon];
            if (son.leftAmount < son.rightAmount)
                addMemberToLeft(son,newMem);
            else
                addMemberToRight(son,newMem);
        }
    }

    function addMemberToLeft(person memory p,person memory newMem) private{
        if (!p.hasLeft){
            p.leftSon = newMem._ID;
            p.hasLeft = true;
            newMem.parentID = p._ID;
            newMem.isRight = false;
            playerDetail[newMem.parentID]=p;            
            playerDetail[newMem._ID]=newMem;
            updateBalance(p._ID,false,newMem.found);
        }else{
            person memory son = playerDetail[p.leftSon];
            if (son.leftAmount < son.rightAmount)
                addMemberToLeft(son,newMem);
            else
                addMemberToRight(son,newMem);
        }
    }

    function updateBalance(address _id,bool _isRight,uint _newMoney) private {
        //if _id <= playerDetail.length and _id >= 0:
            person memory  x=playerDetail[_id];
            if (x.gift< 5*x.found) {
                if (_isRight)
                {
                    //x.rightCount += 1;
                    x.rightAmount += _newMoney;
                }else{
                    //x.leftCount += 1;
                    x.leftAmount += _newMoney;
                }
                uint gift =0;
                //if x.rightCount == x.leftCount :
                if (x.rightAmount< x.leftAmount){ 
                    gift = x.leftAmount/10;
                    x.leftAmount -= x.rightAmount;
                    x.rightAmount =0;
                }else{
                    gift =x.leftAmount/10;
                    x.rightAmount -= x.leftAmount;
                    x.leftAmount =0;
                }
                if (gift > 0){    
                    if ( x.gift+gift > 5*x.found){
                        uint newGift = 5*x.found - x.gift;
                        totalMissed += gift- newGift;
                        totalGift += newGift;
                        x.gift=5*x.found;
                        x.missedGift+= gift- newGift;
                        ///test if (!x.isOffer)
                            ///test x._ID.transfer(newGift);//////
                    }else{
                        x.gift +=gift;
                        totalGift += gift;
                        ///test if (!x.isOffer)
                            ///test x._ID.transfer(gift);//////
                    }
                }
                playerDetail[_id]=x;
            }
            if (x._ID !=owner)      
                updateBalance(x.parentID,playerDetail[x.parentID].rightSon==x._ID,_newMoney);
    }
    
    function kill() public {
        if(msg.sender == owner) selfdestruct(owner);
     }

    function dailyGift(uint  precent) public{
        assert(msg.sender == owner);
        assert(precent <20);
        for(uint i = 0;i<players.length;i++){
            person memory thisPerson = playerDetail[players[i]];
            uint gift = (thisPerson.found/1000)*precent;
            if(thisPerson.gift + gift > 5*thisPerson.found){
                uint newGift = 5*thisPerson.found- thisPerson.gift;
                if (newGift >0){
                    thisPerson.missedGift +=gift - newGift;
                    thisPerson.gift +=newGift;
                    totalGift += newGift;
                    totalMissed += gift - newGift;
                    ///test if (!thisPerson.isOffer)
                        ///test players[i].transfer(newGift);
                }
            }else{
                thisPerson.gift +=gift;
                totalGift += gift;
                ///test if (!thisPerson.isOffer)
                    ///test players[i].transfer(gift);
            }
        }
    }

    function playerCount() public view returns(uint){
        return players.length;
    }

    function allPlayerDetails() public view returns(address[] memory){        
        return players;
    }

    function telegramChanel() public pure  returns(string){
        return "https://t.me/ourBeautifulChannel";
    }

    function getGift(uint _askedValue) public {        
        person memory thisPerson = playerDetail[msg.sender];
        assert(thisPerson.getedGift + _askedValue <= thisPerson.gift);
        thisPerson.getedGift += _askedValue;
        playerDetail[msg.sender] = thisPerson;
        msg.sender.transfer(_askedValue);
    }

    function showMyGift() public view returns(uint){
        assert(isNewPlayer(msg.sender));
        uint  val = playerDetail[msg.sender].gift -playerDetail[msg.sender].getedGift;
        return val;
    }


}