/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
}
interface OracleLike {
    function price() external view  returns (uint);
}
interface Medalerc20Like {
    function mint(address,uint) external;
}
contract MedalFarm {

    // --- Auth ---
    uint256 public live;
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { require(live == 1, "Medal/not-live"); wards[usr] = 1; }
    function deny(address usr) external  auth { require(live == 1, "Medal/not-live"); wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Medal/not-authorized");
        _;
    }
    struct UserInfo {
        uint256    amount;   
        uint256    latetime;
        uint256    harved;
    }

    uint256        public max;
    uint256        public waittime;
    uint256        public unit;
    OracleLike     public Oracle;
    TokenLike      public lptoken;
    Medalerc20Like public medalerc20;
    
    mapping (address => UserInfo) public userInfo;


    event Deposit( address  indexed  owner,
                   uint256           wad
                  );
    event Harvest( address  indexed  owner,
                   uint256           wad
                  );
    event Withdraw( address  indexed  owner,
                    uint256           wad
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

    function file(uint what, uint256 data) external auth {
        if (what == 1) max = data;
        else if (what == 2) waittime = data;
        else if (what == 3) unit = data;
        else revert("Medal/file-unrecognized-param");
    }  
    function setToken(uint what, address _token) external auth {
        if (what == 1) Oracle = OracleLike(_token);
        else if (what == 2) lptoken = TokenLike(_token);
        else if (what == 3) medalerc20 = Medalerc20Like(_token);
        else revert("Medal/file-unrecognized-param");
    } 
    //质押
    function deposit(uint _amount) public {
        lptoken.transferFrom(msg.sender, address(this), _amount);
        UserInfo storage user = userInfo[msg.sender]; 
        user.amount = add(user.amount,_amount); 
        user.latetime = block.timestamp;
        emit Deposit(msg.sender,_amount);     
    }
    //收割挖矿所得
    function harvest() public {
        uint256 wad = beharvest(msg.sender);
        UserInfo storage user = userInfo[msg.sender];
        require(block.timestamp >= add(user.latetime,waittime), "mdeal/timenot");
        user.latetime = block.timestamp;
        user.harved = add(user.harved,wad);
        medalerc20.mint(msg.sender,wad);
        emit Harvest(msg.sender,wad); 
    }
    //提现质押币
    function withdraw(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender]; 
        user.amount = sub(user.amount,_amount);
        lptoken.transfer(msg.sender, _amount);
        emit Withdraw(msg.sender,_amount);     
    }
    //预估收割
    function beharvest(address usr) public view returns (uint256) {
        uint256 _lpPrice = lpPrice();
        UserInfo storage user = userInfo[usr];
        uint256 amountMultiplier = div(mul(_lpPrice,user.amount), unit*1e18);
        if (amountMultiplier > max) amountMultiplier = max;
        return amountMultiplier;
    }
    function lpPrice() public view returns (uint256) {
        uint256 price = Oracle.price();
        return price;
    }
 }