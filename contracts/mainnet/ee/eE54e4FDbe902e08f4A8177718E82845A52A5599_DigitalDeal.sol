/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;  
    function approve(address,uint256) external;  
    function balanceOf(address) external view returns(uint256);
    function getReserves()external view returns(uint256,uint256,uint256);
}
interface RouterV2 {
    function SwapExactTokensForTokens(uint,uint,address[] memory,address,uint) external returns(uint256[] memory) ;
}

interface EatLike {
    function recommend(address) external view  returns (address);
    function renum(address) external view  returns (uint);
    function setlevel(address,address) external;   
}
contract DigitalDeal {

    // --- Auth ---
    uint256 public live;
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { require(live == 1, "DigitalDeal/not-live"); wards[usr] = 1; }
    function deny(address usr) external  auth { require(live == 1, "DigitalDeal/not-live"); wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "DigitalDeal/not-authorized");
        _;
    }
    struct UserInfo {  
        uint256    lasttime;
        uint256    eatamount;
        uint256    usdtamount;
    }
    uint256        public usdtmin;
    uint256        public usdtmax;
    uint256        public reserve;
    address        public foundation;
    uint256        public accrual;
    uint256        public cycle;
    TokenLike      public eat = TokenLike(0x0f77144eba9c24545aA520a03f9874C4f1f4850F);
    TokenLike      public usdt = TokenLike(0x55d398326f99059fF775485246999027B3197955);
    TokenLike      public LP = TokenLike(0x54Df4a86a372664b56c4eD50ECAb7a44c999DE93);
    RouterV2       public router = RouterV2(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    EatLike        public eatlevel = EatLike(0xBa8D6AB40ddA82847d38FDd8d93a39aC9c8a1300);

    mapping (address => UserInfo) public userInfo;

    event Deposit( address  indexed  owner,
                   uint256           awad,
                   uint256           bwad,
                   uint256           time
                  );
    event Withdraw( address  indexed  owner,
                    uint256           awad,
                    uint256           bwad
                 );

    constructor(){
        wards[msg.sender] = 1;
        live = 1;
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
    function file(uint what, uint256 data) external auth {
        if (what == 1 ) usdtmin = data;
        else if (what == 2) usdtmax = data; 
        else if (what == 3 && data <=107 ) accrual = data; 
        else if (what == 4) cycle = data; 
        else if (what == 5) live = data;
        else revert("DigitalDeal/file-unrecognized-param");
    }
    function setfound(address _found) external auth {
        foundation = _found;
    }
    //Add a reserve USDT 
    function addreserve(uint256 _usdtamount) external {
        usdt.transferFrom(msg.sender, address(this), _usdtamount);
        reserve += _usdtamount;
    }
    //authorization usdt
    function init() external {
        uint256 wad = 10**30;
        usdt.approve(address(router), wad);
    }
    //Deposit usdt and Converted to EAT
    function depositusdt(uint256 _usdtamount,uint amountOutMin,address[] calldata path,address _recommend) public {
        require(live == 1 , "DigitalDeal/stop");
        require(_usdtamount>=usdtmin && _usdtamount<=usdtmax, "DigitalDeal/Quantity out of range");
        UserInfo storage user = userInfo[msg.sender]; 
        require(user.lasttime ==0 , "DigitalDeal/Only at the same time");
        usdt.transferFrom(msg.sender, address(this), _usdtamount);
        uint256[] memory amounts = router.SwapExactTokensForTokens(_usdtamount, amountOutMin,path,address(this),block.timestamp);
        depositeat(amounts[1],_recommend);
    }  
    //Deposit EAT
    function depositeat(uint256 _eatamount,address _recommend) public {
        require(live == 1 , "DigitalDeal/stop");
        UserInfo storage user = userInfo[msg.sender];
        require(user.lasttime ==0 , "DigitalDeal/Only at the same time");
        (uint eatreserve, uint usdtreserve,) = LP.getReserves();  
        user.eatamount = _eatamount;
        user.usdtamount = _eatamount * usdtreserve/eatreserve;
        require(user.usdtamount >= usdtmin &&user.usdtamount <= usdtmax && reserve >= user.usdtamount*accrual/100,"DigitalDeal/Quantity out of range");
        reserve -= user.usdtamount*accrual/100;
        user.lasttime = block.timestamp;
        eat.transferFrom(msg.sender, address(this), _eatamount);       
        if (_recommend != address(0)) {
            if (eatlevel.recommend(msg.sender) == address(0)  
            && eat.balanceOf(_recommend) != 0 && eatlevel.recommend(_recommend) != address(0)) 
            eatlevel.setlevel(msg.sender,_recommend);
        }      
        emit Deposit(msg.sender,_eatamount, user.usdtamount,block.timestamp);     
    }
    //When it expires, you withdraw the interest and release EAT 
    function withdraw() public {
        UserInfo storage user = userInfo[msg.sender]; 
        require(user.lasttime !=0 && block.timestamp >= user.lasttime + cycle, "DigitalDeal/Not received last time");
        usdt.transfer(msg.sender, user.usdtamount*accrual/100);
        eat.transfer(foundation, user.eatamount);
        user.lasttime = 0;  
        emit Withdraw(msg.sender,user.usdtamount*accrual/100, user.eatamount);     
    }
    //Get referrals
    function getrecommend(address usr,uint256 level ) public view returns (address[] memory) {
        address[] memory superstratum = new address[](level);
        address _recommend = usr;
        for (uint i =0 ;i< level;++i) {
            address recommender = eatlevel.recommend(_recommend);
            if (recommender == address(0)) break;
            superstratum[i] = recommender;
            _recommend = recommender;
        }
        return  superstratum; 
    }
 }