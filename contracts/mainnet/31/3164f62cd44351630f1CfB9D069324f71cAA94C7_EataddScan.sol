/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    
    function balanceOf(address) external view returns(uint256);
}
interface EatLike {
    function recommend(address) external view  returns (address);
    function renum(address) external view  returns (uint);
    function setlevel(address,address) external;   
}
contract EataddScan {

    // --- Auth ---
    uint256 public live;
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { require(live == 1, "EataddScan/not-live"); wards[usr] = 1; }
    function deny(address usr) external  auth { require(live == 1, "EataddScan/not-live"); wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "EataddScan/not-authorized");
        _;
    }
    struct UserInfo {  
        uint256    loss;
        uint256    total;
        uint256    eatamount;
        uint256    mrtamount;
    }
    uint256        public eatamounts;
    uint256        public day;
    uint256        public cycle;
    uint256        public bonuses;
    TokenLike      public eat = TokenLike(0x0f77144eba9c24545aA520a03f9874C4f1f4850F);
    TokenLike      public medal = TokenLike(0x431fcd7FeB856a190eE153F7465553D69b5Dd842);
    EatLike        public eatlevel = EatLike(0xBa8D6AB40ddA82847d38FDd8d93a39aC9c8a1300);

    mapping (address => UserInfo) public userInfo;
    mapping (address => uint256) public award;
    mapping (uint256 => uint256) public lasttime;
    mapping (address => mapping (uint256 => uint256[])) public lottery;
    mapping (uint256 => uint256[3]) public results;

    event Luckilystar( address  indexed  owner,
                       uint256           wad
                    );
    event Deposit( address  indexed  owner,
                   uint256           awad,
                   uint256           bwad
                  );
    event Withdraw( address  indexed  owner,
                    uint256           awad,
                    uint256           bwad
                 );
    event Award( address  indexed  owner,
                 uint256           awad
                 );           
    event Scanadd( address  indexed  owner,
                    uint256           awad,
                    uint256           bwad
                 );
    constructor(){
        wards[msg.sender] = 1;
        live = 1;
        day = 1;
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

    function file(uint what, uint256 data) external auth {
        if (what == 1 && data <= 5*10**18) eatamounts = data;
        else if (what == 2) lasttime[1] = data;
        else if (what == 3) cycle = data;
        else if (what == 4) live = data;
        else revert("EataddScan/file-unrecognized-param");
    }  
    function deposit(uint256 _eatamount,uint256 _mrtamount,address _recommend) public {
        require(live == 1 , "EataddScan/stop");
        UserInfo storage user = userInfo[msg.sender]; 
        if (_recommend != address(0)) {
            if (eatlevel.recommend(msg.sender) == address(0)  
            && eat.balanceOf(_recommend) != 0 && eatlevel.recommend(_recommend) != address(0)) 
            eatlevel.setlevel(msg.sender,_recommend);
        }      
        if (_eatamount>0) {
            eat.transferFrom(msg.sender, address(this), _eatamount);
            user.eatamount = add(user.eatamount ,_eatamount);
        }
        if (_mrtamount>0) {
           medal.transferFrom(msg.sender, address(this), _mrtamount);
           user.mrtamount = add(user.mrtamount ,_mrtamount);
        } 
        emit Deposit(msg.sender,_eatamount, _mrtamount);     
    }
    function scanadd(uint256 limit) public {
        require(live == 1 , "EataddScan/stop");
        require(block.timestamp <add(lasttime[day],cycle), "EataddScan/The scanning time has ended");
        require(lottery[msg.sender][day].length == 0, "EataddScan/Scan only once a day");
        if (award[msg.sender] != 0) selfaward();
        UserInfo storage user = userInfo[msg.sender]; 
        require(limit >=1 , "EataddScan/data is invalid");
        require(user.eatamount >= mul(eatamounts,limit) && user.mrtamount >= limit , "EataddScan/asset deficiency");       
        user.mrtamount = sub(user.mrtamount,limit);
        user.total = add(user.total,limit);
        uint256[] memory a = new uint256[](limit);
        for (uint i = 1; i <=limit ; ++i) {
            bytes32 hash = keccak256(abi.encodePacked(msg.sender, block.timestamp,i));
            uint256 luckily = uint256(hash)%10;
            a[i-1]= luckily;
            } 
        lottery[msg.sender][day] =a;
        award[msg.sender] = day;
        emit Scanadd(msg.sender,day,limit); 
    }
    function luckilystar() public {
        require( block.timestamp >add(lasttime[day],cycle), "EataddScan/The drawing time is not here yet");
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, block.timestamp));
        uint256 luckily = uint256(hash)%10;
        if (luckily == 0) luckily = 10;
        if (results[day][0]==0) results[day][0]=luckily;
        else if (results[day][1]==0 && results[day][0] !=luckily) results[day][1]=luckily;
        else if (results[day][2]==0 && results[day][0] !=luckily && results[day][1] !=luckily) {
            results[day][2]=luckily;
            day +=1;
            lasttime[day]= add(lasttime[day-1],cycle);
            }
        else revert("EataddScan/file-unrecognized-param");
        emit Luckilystar(msg.sender,luckily); 
    }
    function selfaward() public {
        require(award[msg.sender] != 0, "EataddScan/already received");
        uint256 _day = award[msg.sender];
        require(results[_day][2] !=0, "EataddScan/The drawing is not over yet");
        uint256 limit = lottery[msg.sender][_day].length;
        UserInfo storage user = userInfo[msg.sender];
        for (uint i = 0; i <limit ; ++i) {
            uint n =lottery[msg.sender][_day][i];
            if (n ==0) n=10;
            if (n == results[_day][0] || n == results[_day][1] ||n == results[_day][2]) {
               user.eatamount = sub(user.eatamount, eatamounts/10);
               bonuses += eatamounts*4/100;
               user.loss +=1;
             } else user.eatamount = add(user.eatamount, eatamounts*2/100);      
        }
        award[msg.sender] = 0;
        emit Award(msg.sender,_day); 
    }
    function withdraw(uint256 _eatamount,uint256 _mrtamount) public {
        UserInfo storage user = userInfo[msg.sender]; 
        require(lottery[msg.sender][day].length == 0, "EataddScan/scaning..."); 
        require(award[msg.sender] == 0, "EataddScan/Not received last time");
        require(user.eatamount >= _eatamount && user.mrtamount >= _mrtamount, "EataddScan/quantity not sufficient");     
        if (_eatamount>0) {
            user.eatamount = sub(user.eatamount ,_eatamount);
            eat.transfer(msg.sender, _eatamount);
        }
        if (_mrtamount>0) {
           user.mrtamount = sub(user.mrtamount ,_mrtamount);
           medal.transfer(msg.sender, _mrtamount); 
        }      
        emit Withdraw(msg.sender,_eatamount, _mrtamount);     
    }
    function withdrawbonuses(address usr, uint256 _eatamount) public auth {
        require(bonuses >= _eatamount, "EataddScan/quantity not sufficient"); 
        bonuses = sub(bonuses ,_eatamount);
        eat.transfer(usr, _eatamount);
    }
 }