/**
 *Submitted for verification at BscScan.com on 2022-03-12
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
    function swapExactTokensForTokens(uint,uint,address[] memory,address,uint) external returns(uint256[] memory);
    function swapTokensForExactTokens(uint,uint,address[] memory,address,uint) external returns(uint256[] memory);
    function getAmountsOut(uint amountIn, address[] memory path)external returns(uint256[] memory) ;
}

interface EatLike {
    function recommend(address) external view  returns (address);
    function renum(address) external view  returns (uint);
    function setlevel(address,address) external;  
    function lottery(address,uint,uint)external view returns (uint); 
    function results(uint,uint)external view returns (uint);  
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
    struct Pledge {  
        address    owner;
        uint256    usdtamount;
        uint256    eatamount;
        uint256    lasttime;
    }
    struct Waitin {  
        address    owner;
        uint256    usdtamount;
        uint256    lasttime;
    }
    uint256        public usdtmin;
    uint256        public usdtmax;
    uint256        public accrual;
    uint256        public cycle;
    uint256        public week;
    uint256        public pau;
    uint256        public order;
    address[]      public path = [0x55d398326f99059fF775485246999027B3197955,0x0f77144eba9c24545aA520a03f9874C4f1f4850F];
    address[]      public path2 = [0x0f77144eba9c24545aA520a03f9874C4f1f4850F,0x55d398326f99059fF775485246999027B3197955];
    TokenLike      public eat = TokenLike(0x0f77144eba9c24545aA520a03f9874C4f1f4850F);
    TokenLike      public usdt = TokenLike(0x55d398326f99059fF775485246999027B3197955);
    RouterV2       public router = RouterV2(0x10ED43C718714eb63d5aA57B78B54704E256024E);


    mapping (uint256 => Pledge) public pledge;
    mapping (uint256 => Waitin) public waitin;
    mapping (address => uint256) public usdtamount;
    mapping (address => address) public recommend;

    event Pledgeusdt( address  indexed  owner,
                   uint256           awad,
                   uint256           bwad,
                   uint256           order,
                   uint256           time
                  );
    event Waitinline( address  indexed  owner,
                    uint256           usdtamount,
                    uint256           pau,
                    uint256           time
                 );
                 
    event Harvest( address  indexed  owner,
                    uint256           usdtamount,
                    uint256           pau
                 );             
    event Waitout( address  indexed  owner,
                    uint256           pau
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
        else if (what == 5) week = data;
        else if (what == 6) live = data;
        else revert("DigitalDeal/file-unrecognized-param");
    }
    //authorization usdt
    function init() external {
        uint256 wad = 10**30;
        usdt.approve(address(router), wad);
    }
    //Deposit usdt   
    function deposit(uint256 _usdtamount,address _recommend) public {
        require(live == 1 , "DigitalDeal/stop");
        usdt.transferFrom(msg.sender, address(this), _usdtamount);
        usdtamount[msg.sender] += _usdtamount;
        if (recommend[msg.sender] == address(0) && _recommend != address(0)) 
            recommend[msg.sender] = _recommend;  
    }
    // 
    function pledgeusdt(uint256 _usdtamount) public returns (uint) {
        require(live == 1 , "DigitalDeal/stop");
        require(_usdtamount>=usdtmin && _usdtamount<=usdtmax, "DigitalDeal/Quantity out of range");
        usdtamount[msg.sender] = sub(usdtamount[msg.sender],_usdtamount);
        uint256[] memory amounts;
        if (usdt.balanceOf(address(this)) >= _usdtamount) amounts = router.swapExactTokensForTokens(_usdtamount, 0,path,address(this),block.timestamp); 
        else amounts = router.getAmountsOut( _usdtamount, path); 
        order +=1;
        pledge[order].owner = msg.sender;
        pledge[order].usdtamount = _usdtamount;
        pledge[order].eatamount = amounts[1]; 
        pledge[order].lasttime = block.timestamp; 
        emit Pledgeusdt(msg.sender,_usdtamount,amounts[1],order, block.timestamp); 
        return  order;
    }
    //
    function waitinline (uint256 _usdtamount) public returns (uint) {
        require(live == 1 , "DigitalDeal/stop");
        require(_usdtamount>=usdtmin && _usdtamount<=usdtmax, "DigitalDeal/Quantity out of range");
        usdtamount[msg.sender] = sub(usdtamount[msg.sender],_usdtamount);
        pau +=1;
        waitin[pau].owner = msg.sender;
        waitin[pau].usdtamount = _usdtamount;
        waitin[pau].lasttime = block.timestamp; 
        emit Waitinline(msg.sender,_usdtamount,pau,block.timestamp); 
        return pau;  
    }
    function waitforpledge(uint256 _pau) public returns (uint256) {
        require(live == 1 , "DigitalDeal/stop");
        require(waitin[_pau].lasttime !=0 , "DigitalDeal/Not received last time");
        uint256 _usdtamount= waitin[_pau].usdtamount;
        address owner = waitin[_pau].owner;
        waitin[_pau].lasttime = 0; 
        uint256[] memory amounts;
        if (usdt.balanceOf(address(this)) >= _usdtamount) amounts = router.swapExactTokensForTokens(_usdtamount, 0,path,address(this),block.timestamp); 
        else amounts = router.getAmountsOut( _usdtamount, path);  
        order +=1;
        pledge[order].owner = owner;
        pledge[order].usdtamount = _usdtamount;
        pledge[order].eatamount = amounts[1]; 
        pledge[order].lasttime = block.timestamp; 
        emit Pledgeusdt(owner,_usdtamount,amounts[1],order, block.timestamp);
        return  order;
    }
    function waitout(uint256 _pau) public{
        require(waitin[_pau].lasttime !=0 && block.timestamp <= waitin[_pau].lasttime + week, "DigitalDeal/Not received last time");
        require(waitin[_pau].owner == msg.sender, "DigitalDeal/Not owner");
        usdtamount[msg.sender] += waitin[_pau].usdtamount;
        waitin[_pau].lasttime = 0; 
        emit Waitout(msg.sender,_pau);   
    }

    function withdrawusdt(uint256 _usdtamount) public {
        require(usdtamount[msg.sender] >= _usdtamount, "DigitalDeal/Not received last time");
        usdtamount[msg.sender] = sub(usdtamount[msg.sender],_usdtamount);
        if (usdt.balanceOf(address(this)) < _usdtamount) router.swapTokensForExactTokens(_usdtamount,eat.balanceOf(address(this)),path2,address(this),block.timestamp); 
        usdt.transfer(msg.sender, _usdtamount);   
    }
    function withdraweat(address ust ,uint256 _eatamount) public auth{
        eat.transfer(ust, _eatamount);   
    }
    function harvest(uint256 _order) public {
        require(pledge[_order].lasttime !=0 && block.timestamp >= pledge[_order].lasttime + cycle, "DigitalDeal/Not received last time");
        uint256 _usdtamount = pledge[_order].usdtamount*accrual/100;
        usdtamount[pledge[_order].owner] += _usdtamount;
        pledge[_order].lasttime = 0;  
        emit Harvest(pledge[_order].owner,_usdtamount, _order);     
    }
    //Get referrals
    function recommends(address usr,uint256 level ) public view returns (address[] memory) {
        address[] memory superstratum = new address[](level);
        address _recommend = usr;
        for (uint i =0 ;i< level;++i) {
            address recommender = recommend[_recommend];
            if (recommender == address(0)) break;
            superstratum[i] = recommender;
            _recommend = recommender;
        }
        return  superstratum; 
    }

 }