/**
 *Submitted for verification at BscScan.com on 2022-03-27
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IS {
    function stakeVSlice_h56(uint _amount, address _addr) external;
    function unstakeVSlice_Hha(uint _amount, address _addr) external;
    function vSliceViewBalance (address _addr) view external returns (uint);
    function wl(address _addr) view external  returns (bool);
    function active (address _fa, address _fcontract) external;
                     }
contract Fight {
    address  flipper;
    address  dev;
    address  dev2;
    address  fightAdmin;
    address  tc;
    address  influ2;
    address  charity;
    uint  totalStaked;
    uint dscs;
    uint dscs2;
    uint spotResPrice;
    uint spotCounter;
    uint flipperShare;
    uint influ2Share;
    uint spotCashBack;
    uint usersSlice;
    uint charitySlice;
    uint iscs;
    uint uscs;
    uint maxUsers;
    uint spotBusyTime;
    uint spotReservTime;
    uint v1;
    uint v2;
    address lsp;
    address ls;
    uint actTimer;
    uint startTime;
    address ff;
    uint created;
   
    function _a() private view {
        require (msg.sender == fightAdmin, "");
    }
    modifier a() {
    _a();
    _;
    }
    
    mapping (address => uint)  pw;
    mapping (address => uint)  votes;
   
    error NotEnoughEther();
    error YouHaveToReserveFirst();
    error FinishFightFirst();
   
    struct fightData {
        uint initPrice;
        uint np;
        uint extention;
        uint duration;
        string[5] fightTopics;
        string promo1;
        string promo2;
        address influ1;
        string shortUrl;
        }  
        fightData[]  fight;
     
    constructor(address _ff, address _dev, address _dev2, uint _dscs,uint _dscs2, uint _spotResPrice, address _fightAdmin, address _tc, address _influ2, address _charity, address _lsp) {
        dev = _dev;
        dev2 = _dev2;
        dscs = _dscs;
        dscs2 = _dscs2;
        iscs=10;
        uscs=54;
        flipperShare=70;
        influ2Share=10;
        usersSlice=85;
        charitySlice=5;
        spotCashBack=100;
        maxUsers=20000;
        spotBusyTime=300;
        spotReservTime=300;
        spotResPrice = _spotResPrice;
        fightAdmin=_fightAdmin;
        tc =_tc;
        influ2 = _influ2;
        charity = _charity;
        ff=_ff;
        lsp=_lsp;
        
}
        
        function addFightData(  
        address influ1,
        uint initPrice,
        uint np,
        uint extention,
        uint duration,
        string[5] memory fightTopics,
        string memory promo1,
        string memory promo2,
        string memory shortUrl
        ) public a{
        require(extention <=3600 && duration<= 604800, '');
       
        fight.push(fightData(
        initPrice,
        np,
        extention,
        duration,
        fightTopics,
        promo1,
        promo2,
        influ1=fightAdmin,
        shortUrl));
        actTimer=duration;
        startTime=block.timestamp;
        ls=influ1;
        IS(ff).active (msg.sender, address(this));
        created=block.timestamp;
        }
        
    struct Spots {
        uint SpotNo;
        uint priceOfSpot;
        uint bu;
        uint ru;
        address flipper;
        address booker;
        string text;
        string link;
        string pic;
        string mediaType;
    }
    Spots []  spots;
   
    struct Entry{
        uint index;
        uint value;
                }
    mapping(address => Entry)  map;
    address[]  keyList;
   
   // Stake Virtual Slice
    function stakeingVSlice_C64(uint _value) public {
        require(maxUsers>keyList.length, "");
        IS(tc).stakeVSlice_h56(_value, msg.sender);
        Entry storage entry = map[msg.sender];
        entry.value += _value;
        totalStaked += _value;
        if(entry.index > 0){
            return;
        }else {
            keyList.push(msg.sender);
            uint keyListIndex = keyList.length - 1;
            entry.index = keyListIndex + 1;
        }
    }

   //Unstake Virtual Slice
    function unstakeingVSlice_EK(uint _value) public {
        Entry storage entry = map[msg.sender];
        require(entry.value>=_value, "");
        IS(tc).unstakeVSlice_Hha(_value, msg.sender);
        entry.value -= _value;
        totalStaked -= _value;
        if(entry.index > 0){
            return;
        }else {
            keyList.push(msg.sender);
            uint keyListIndex = keyList.length - 1;
            entry.index = keyListIndex + 1;
        }
    }  

    //view Virtual Slice balance
    function viewVSliceBalance () view external returns (uint){
        return IS(tc).vSliceViewBalance(msg.sender);
    }
    //Create spot
     
    function createSpot_g4A(string memory _text, string memory _link, string memory _pic, string memory _mediaType) external payable {
        fightData storage m = fight[0];
        require((startTime+actTimer) > block.timestamp, '');
        if (msg.value != m.initPrice) revert NotEnoughEther();
        pw[dev] += (m.initPrice * dscs/100);
        pw[dev2] += (m.initPrice * dscs2/100);
        pw[lsp] += (m.initPrice * 30/100);
        pw[m.influ1] += (m.initPrice * iscs/100)/2;
        pw[influ2] += (m.initPrice * iscs/100)/2;
        if (keyList.length!=0) {
        for (uint i = 0; i < keyList.length; i++)
        {
        Entry storage entry = map[keyList[i]];
        if (IS(tc).wl(keyList[i])==true) {
        pw[keyList[i]] += ((m.initPrice * uscs/100) * entry.value/totalStaked);}
        else { pw[charity] += ((m.initPrice * uscs/100) * entry.value/totalStaked); }
        }
        } else {pw[charity]+=(m.initPrice * uscs/100);}
        uint nextPrice = m.initPrice + ((m.initPrice * m.np)/100);
        spotCounter=spotCounter+1;
        uint spotN = spotCounter;
        string memory text = _text;
        string memory link = _link;
        string memory pic= _pic;
        string memory mediaType=_mediaType;
        ls=msg.sender;
        //timer start
        uint timeLeft = actTimer - (block.timestamp-startTime);
        if (block.timestamp - created > 604800)
            {actTimer= 0;}
         else if (timeLeft+m.extention >=m.duration)
               {actTimer=m.duration;}
         else {actTimer= timeLeft+ m.extention;}
                startTime = block.timestamp;
        //timer end
        spots.push(Spots(spotN, nextPrice,block.timestamp+spotBusyTime, block.timestamp, msg.sender,msg.sender, text, link, pic, mediaType));
    
        
    }

  //flip
    
    function flip_Maf(uint _index, string memory _text, string memory _link, string memory _pic, string memory _mediaType) external payable {
        uint cb;
        Spots storage spot = spots[_index];
        fightData storage m = fight[0];
        require(spot.bu < block.timestamp, '');
        require(spot.booker==msg.sender || spot.ru<block.timestamp, '');
        require((startTime+actTimer) > block.timestamp, '');
        if (msg.value != spot.priceOfSpot) revert NotEnoughEther();
        uint currentPrice = spot.priceOfSpot;
        uint previousPrice = ((currentPrice / ((100 + m.np)))*100);
        cb= ((previousPrice * spotCashBack)/100);
        uint exFlipperProfit = ((currentPrice - previousPrice) * flipperShare)/100;
        uint nextPrice = ((spot.priceOfSpot * ((100 + m.np)))/100);
        pw[spot.flipper] += (cb + exFlipperProfit);
        uint toDistro = spot.priceOfSpot - (cb + exFlipperProfit);
        pw[m.influ1] += (toDistro * influ2Share/100)/2;
        pw[influ2] += (toDistro * influ2Share/100)/2;
        pw[charity] += (toDistro * charitySlice/100);
        if (keyList.length!=0) {
        for (uint i = 0; i < keyList.length; i++)
        {
        Entry storage entry = map[keyList[i]];
        if (IS(tc).wl(keyList[i])==true) {
        pw[keyList[i]] += (toDistro * usersSlice/100) * entry.value/totalStaked;}
        else {pw[charity] += (toDistro * usersSlice/100) * entry.value/totalStaked;}
        }
        } else {pw[charity]+=(toDistro * usersSlice/100);}
        spot.flipper = msg.sender;
        spot.priceOfSpot = nextPrice;
        spot.bu = block.timestamp+spotBusyTime;
        spot.ru=block.timestamp;
        spot.text = _text;
        spot.link = _link;
        spot.pic= _pic;
        spot.mediaType=_mediaType;
        ls=msg.sender;
        //timer start
        uint timeLeft = actTimer - (block.timestamp-startTime);
        if (block.timestamp - created > 604800)
            {actTimer= 0;}
        else if (timeLeft+m.extention >=m.duration)
               {actTimer=m.duration;}
         else {actTimer= timeLeft+ m.extention;}
        startTime = block.timestamp;
        //timer end
    }
       //Get spots
    function getSpots() public view returns (Spots[] memory){
      Spots[]    memory id = new Spots[](spots.length);
      for (uint i = 0; i < spots.length; i++) {
          Spots storage spot = spots[i];
          id[i] = spot;
      }
      return id;
  }
  
   //Spot Reservation
   
    function spotReserve_u5k(uint _indx) external payable {
        Spots storage spot = spots[_indx];
        require(spot.bu<block.timestamp && spot.ru<block.timestamp && spot.flipper != msg.sender, "");
        if (msg.value != spotResPrice) revert NotEnoughEther();
        pw[dev]+=spotResPrice;
        spot.ru = block.timestamp+spotReservTime;
        spot.booker=msg.sender;
        
    }
   //Spot reset
    function resetspot(uint _indx) external a (){
        fightData storage m = fight[0];
        Spots storage spot = spots[_indx];
        spot.priceOfSpot=m.initPrice;
        spot.bu=0;
        spot.ru=0;
        spot.text='';
        spot.pic='';
        spot.link='';
    }
   //make withdrawal 
    function makeWithdrawal() public {
        uint amount = pw[msg.sender];
        pw[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
    //make withdrawal of Last Spot Pot
    
    function makeWithdrawalLSP() public {
        require(ls==msg.sender && (startTime+actTimer) <= block.timestamp, '');
        uint amount = pw[lsp];
        pw[lsp] = 0;
        actTimer=0;
        payable(msg.sender).transfer(amount);
       
    }
    


   //Vote 1
    function voting1_E7O(address _addr) public {
        require(votes[_addr]==0 && IS(tc).wl(msg.sender)==true,'');
        votes[_addr]=1;
        v1 +=1;
    }
   //Vote 2
    function voting2_eoL(address _addr) public {
        require(votes[_addr]==0 && IS(tc).wl(msg.sender)==true,'');
        votes[_addr]=1;
        v2 +=1;

    }
    //Show votes
    function getVotes() view public returns (uint, uint, uint) {
        return (v1, v2, totalStaked);
    }
    //Get fight data
    function getFightData () public view returns (address, uint, uint, uint, uint, string[5] memory, string memory ,string memory, string memory) {
       fightData storage spot = fight[0];
    return (spot.influ1, spot.initPrice, spot.np, spot.extention, spot.duration, spot.fightTopics, spot.promo1, spot.promo2, spot.shortUrl);}

    // Staked tokens - number of Stakers - voted - fight createdDate
    function getFightParams2 () view external returns (uint, uint, uint, address, uint, uint, uint, uint, uint) {
        Entry storage entry = map[msg.sender];
    return (entry.value, keyList.length, created, charity, spotResPrice, uscs, charitySlice, usersSlice, actTimer);
    }
    
    //Get fights parameters
    function getFightParams() public view returns (uint, uint, uint, uint, uint, uint, uint , uint , uint, uint,uint, uint) {
    return (flipperShare,influ2Share,spotCashBack,usersSlice, charitySlice,iscs, uscs, maxUsers,spotBusyTime, spotReservTime, actTimer,startTime);}
        
    //Show withrawal balances
    function showBalance() view external returns (uint, uint, uint, address, uint, uint) {
    return (pw[msg.sender], pw[charity], pw[lsp],ls, created, actTimer);
    }
   
    //Update fight promo
    function ufp (string memory _promo1, string memory _promo2) public {
    fightData storage spot = fight[0];
    require((spot.influ1==msg.sender) , '');
    spot.promo2 = _promo2;
    spot.promo1=_promo1;
}   
    //Set fight parameters
    function sF (uint fs, uint infs, uint scb, uint us, uint cs, uint _iscs, uint _uscs, uint mu, uint sbt, uint srt) public a(){
    require ((infs+us+cs) == 100 && (_iscs+_uscs+dscs+dscs2) == 70 && spotReservTime >= 300 && flipperShare <=100 && spotCashBack<=100, '');
    flipperShare = fs;
    influ2Share = infs;
    spotCashBack = scb;
    usersSlice = us;
    charitySlice = cs;
    iscs = _iscs;
    uscs = _uscs;
    maxUsers=mu;
    spotBusyTime = sbt;
    spotReservTime = srt;
    }

}
    contract fightFactory {
    address dev;
    address dev2;
    uint  dscs;
    uint  dscs2;
    uint  spotResPrice;
    address  fightAdmin;
    address  tc;
    address  lca;
    address  influ2;
    address  charity;
    address lsp;
 
 
   
    struct fc {
        address fightAdmin;
        address fightContract;
        bool active;
    }
    fc []  fcl;
    mapping(address => mapping(address =>uint)) index;
    mapping(address => uint)  fightCount;
    
    constructor (address _tc) {
        dev = msg.sender;
        lsp=0x52dfA76eDDEF5DC72fb7EcF0e963e7a10Fd6c093;
        tc= _tc;
        dscs= 1;
        dscs2=5;
        spotResPrice=10000000000000000;
    }
 //creating a new fight
    event createNewFight (address indexed fightAddress, address indexed dev2);
    function createFight(address _dev2, address _influ2, address _charity) external returns(address){
       fightAdmin= msg.sender;
       lca = address(new Fight(address(this),dev,_dev2,dscs,dscs2,spotResPrice, fightAdmin, tc, _influ2, _charity, lsp));
       fcl.push(fc(msg.sender, lca, false));
       index[msg.sender][lca]=fcl.length-1;
       fightCount[msg.sender] +=1;
       emit createNewFight (lca, _dev2);    
    return lca;
    }
//get fights by admin 
         function getFightsByAdmin(address _owner) public view returns (fc[] memory) {
        fc[] memory result = new fc[](fightCount[_owner]);
        uint counter = 0;
       
        for (uint i = 0; i < fcl.length; i++) {
            if (fcl[i].fightAdmin == _owner) {
                fc storage list = fcl[i];
                result[counter] = list;
                counter++;
            }
        }
        return result;
    }
    
       function getAllFights() public view returns (fc[] memory){
      fc[]    memory id = new fc[](fcl.length);
      for (uint i = 0; i < fcl.length; i++) {
          fc storage spot = fcl[i];
          id[i] = spot;
      }
      return id;
  }
    
        function active (address _fa, address _fcontract) external {
        uint ind = index[_fa][_fcontract];
         fc storage m = fcl[ind];
         m.active=true;
    }

    
//Set Spot Reservation Price
    function srp (uint _price) external {
        require(msg.sender == dev, "");
        spotResPrice = _price;
    }

    }