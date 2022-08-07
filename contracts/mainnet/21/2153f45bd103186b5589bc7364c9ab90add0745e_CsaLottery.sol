/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;  
    function balanceOf(address) external view returns(uint256);
}
interface exchequerLike {
    function lotteryPool(address) external returns (uint256);
}
contract CsaLottery {

    // --- Auth ---
    uint256 public live = 1;
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { require(live == 1, "CsaLottery/not-live"); wards[usr] = 1; }
    function deny(address usr) external  auth { require(live == 1, "CsaLottery/not-live"); wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "CsaLottery/not-authorized");
        _;
    }

    uint256        public GoldAward = 150 * 1E18;
    uint256        public SilverAward = 100 * 1E18;
    uint256        public BronzeAward = 50 * 1E18;
    uint256        public luckyAwardTotal = 200 * 1E18;
    uint256        public day = 1;
    uint256        public cycle = 129600;
    TokenLike      public usdt = TokenLike(0x55d398326f99059fF775485246999027B3197955);
    TokenLike      public goldKey = TokenLike(0xd4ee1e59Af6CA30f578aB05d371db290696aaAE4);
    exchequerLike  public exchequerCsa = exchequerLike(0x6211F387Da41e0290327AfdeFC80A86BE7193742);
    exchequerLike  public exchequerCcoin;

    mapping (address => uint256) public award;
    mapping (address => uint256) public totalAward;
    mapping (uint256 => uint256) public startTime;
    mapping (uint256 => uint256) public number;
    mapping (uint256 =>mapping (uint256 => address)) public numberForOwner;
    mapping (address => mapping (uint256 => uint256[])) public lottery;
    mapping (uint256 => uint256[3]) public results;

    event Luckilystar( address  indexed  owner,
                       uint256           day,
                       uint256[3]         luck
                    );
    event Award( address  indexed  owner,
                 uint256           awad
                 );           
    event Lottery( address  indexed  owner,
                    uint256           _day,
                    uint256           wad
                 );

    constructor(){
        wards[msg.sender] = 1;
    }
        // --- Math ---
    function add(uint x, int y) internal pure returns (uint z) {
        z = x + uint(y);
        require(y >= 0 || z <= x);
        require(y <= 0 || z >= x);
    }
    function sub(uint x, int y) internal pure returns (uint z) {
        z = x - uint(y);
        require(y <= 0 || z <= x);
        require(y >= 0 || z >= x);
    }
    function mul(uint x, int y) internal pure returns (int z) {
        z = int(x) * y;
        require(int(x) >= 0);
        require(y == 0 || z / y == int(x));
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    
        return c;
      }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
    //Setting global Parameters
    function file(uint what, uint256 data, address ust) external auth {
        if (what == 1) GoldAward = data;
        if (what == 2) SilverAward = data;
        if (what == 3) BronzeAward = data;
        if (what == 4) luckyAwardTotal = data;
        if (what == 5) startTime[1] = data; //First startup time
        if (what == 6) cycle = data;  //Interval between rounds of scanning
        if (what == 7) live = data;
        if (what == 8) goldKey = TokenLike(ust);
        if (what == 9) exchequerCsa = exchequerLike(ust);
        if (what == 10) exchequerCcoin = exchequerLike(ust);
    }

    function csaBet(uint256 goldKeyAmount) public {
        require(live == 1 , "CsaLottery/stop");
        require(goldKeyAmount >=1 , "CsaLottery/data is invalid");
        if (block.timestamp > add(startTime[day],cycle)) luckilystar();
        if (award[msg.sender] != 0 && award[msg.sender] != day) selfaward();
        goldKey.transferFrom(msg.sender, address(this), goldKeyAmount);  
        for (uint i = 0; i < goldKeyAmount ; ++i) {
            lottery[msg.sender][day].push(number[day]);
            numberForOwner[day][number[day]] = msg.sender;
            number[day] +=1;
        } 
        award[msg.sender] = day;
        emit Lottery(msg.sender,day,goldKeyAmount); 
    }
    //Draw the winning numbers
    function luckilystar() public {
        require(block.timestamp >add(startTime[day],cycle), "CsaLottery/The drawing time is not here yet");
        if (number[day] < 13) number[day] = 13;
        uint bets = number[day]-1;
        uint m;
        for(m=0;bets>=1;m++) bets=bets/10;
        for (uint i = 0; i<3 ; ++i) {
            bytes32 hash = keccak256(abi.encodePacked(msg.sender, block.timestamp,i));
            uint256 luckily = uint256(hash)%(10**m);           
            while (luckily > number[day]-1) luckily = luckily/2;
            if (i == 0) results[day][0]=luckily;
            if (i == 1) {
                if (luckily == results[day][0]){
                    if (luckily != 0 ) luckily = luckily-1;
                    else luckily = (number[day]-1)/2;
                }
                results[day][1]=luckily;
            }
            if (i == 2) {
                while (luckily == results[day][0] || luckily == results[day][1]){
                    luckily = luckily+1;
                    if(luckily > number[day] -1) luckily = 0;
                }
                results[day][2]=luckily;
                day +=1;
                startTime[day] = add(startTime[day-1],cycle);
            } 
        }
        emit Luckilystar(msg.sender,day,results[day]); 
    }
    //Draw the winning numbers
    function selfaward() public {
        require(award[msg.sender] != 0, "CsaLottery/already received");
        uint256 _day = award[msg.sender];
        require(day > _day, "CsaLottery/The drawing is not over yet");
        uint256 limit = lottery[msg.sender][_day].length;
        uint256 luckyAward = luckyAwardTotal/(number[_day]-3);
        for (uint i = 0; i <limit ; ++i) {
            uint256 wad = 0;
            uint n =lottery[msg.sender][_day][i];
            if (n == results[_day][0])  wad = GoldAward;
            else if (n == results[_day][1]) wad = SilverAward;
            else if (n == results[_day][2]) wad = BronzeAward;
            else wad = luckyAward; 
            if (usdt.balanceOf(address(this)) < wad) {
                exchequerCsa.lotteryPool(address(this));
                if (address(exchequerCcoin) != address(0)) exchequerCcoin.lotteryPool(address(this));
            }
            totalAward[msg.sender] +=wad;
            usdt.transfer(msg.sender,wad);    
        }
        award[msg.sender] = 0;
        emit Award(msg.sender,_day); 
    }
    //Extract EAT and MRT  
    function withdraw(address asses, uint256 amount, address ust) public auth {
        TokenLike(asses).transfer(ust, amount);
    }
    function getresults(uint256 _day) public view returns (uint[3] memory) {
        return  results[_day];   
    }
    function getlottery(address usr,uint256 _day ) public view returns (uint[] memory) {
        return  lottery[usr][_day];   
    }
    function getlotteryleng(address usr,uint256 _day ) public view returns (uint) {
        return  lottery[usr][_day].length; 
    }
    function getOwnerAward(address usr,uint256 _day) public view returns (uint[6] memory){
        uint n = lottery[usr][_day].length;
        uint bets;
        uint[6] memory topThree;
        for(uint i = 0; i< n; ++i) {
            uint luckNumber = lottery[usr][_day][i];
            if (luckNumber == results[_day][0]) topThree[0] = GoldAward;
            else if (luckNumber == results[_day][1]) topThree[1] = SilverAward;
            else if (luckNumber == results[_day][2]) topThree[2] = BronzeAward;
            else bets +=1;
        }
        topThree[3] = n;
        topThree[4] = bets;
        uint luckyprizeAmount =  luckyAwardTotal/(number[_day] - 3);
        topThree[5] = luckyprizeAmount;
        return topThree;
    }
    function getTopthree(uint256 _day ) public view returns (uint[3] memory,address[3] memory){
         address[3] memory topThree;
         topThree[0] = numberForOwner[_day][results[_day][0]];
         topThree[1] = numberForOwner[_day][results[_day][1]];
         topThree[2] = numberForOwner[_day][results[_day][2]];
         return (results[_day],topThree);
    }
    function getLuckyprize(uint256 _day ) public view returns (uint,address[] memory,uint){
        uint n = number[_day];
        address[] memory luckyprize = new address[](n - 3);
        uint j=0;
        for(uint i = 0; i< n; ++i) {
            if (i != results[_day][0] && i != results[_day][1] && i != results[_day][2]) {
                address luckyer = numberForOwner[_day][i];
                luckyprize[j] = luckyer;
                j +=1;
            }
        }
        uint luckyprizeAmount =  luckyAwardTotal/(n - 3);
        return ((n - 3),luckyprize,luckyprizeAmount);
    }
 }