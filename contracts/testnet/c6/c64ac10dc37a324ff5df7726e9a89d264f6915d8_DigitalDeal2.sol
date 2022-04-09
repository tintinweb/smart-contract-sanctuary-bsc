/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;  
    function approve(address,uint256) external;  
    function balanceOf(address) external view returns(uint256);
}
interface RouterV2 {
    function swapExactTokensForTokens(uint,uint,address[] memory,address,uint) external returns(uint256[] memory);
}

interface Dex {
    function gazprice()external view returns (uint); 
    function buygaz(uint) external returns (uint);  
}
contract DigitalDeal2 {

    // --- Auth ---

    mapping (address => uint) public wards;
    function rely(address usr) external  auth {wards[usr] = 1; }
    function deny(address usr) external  auth {wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "DigitalDeal2/not-authorized");
        _;
    }

    uint256        public startAmount = 1000*10**18;   //第一轮1000u启动
    uint256        public base = 5*10**18;             //每轮报单上线增加5u
    uint256        public week = 172800;               //每轮众筹时间48小时
    address        public zero;                        //零地址
    address[]      public path = [0x55d398326f99059fF775485246999027B3197955,0x0f77144eba9c24545aA520a03f9874C4f1f4850F];
    TokenLike      public usdt = TokenLike(0x55d398326f99059fF775485246999027B3197955);
    RouterV2       public router = RouterV2(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    Dex            public dex; 

    mapping (address => uint256) public usdtamount; //账户可用usd余额
    mapping (address => uint256) public gazamount;  //爆仓后锁仓gaz余额
    mapping (address => address) public recommend;  //推荐关系
    mapping (uint256 => uint256) public extract;    //某仓项目方已提取推荐奖励
    mapping (uint256 =>mapping(uint256 => uint256)) public crowdfundSum;  //某仓某轮已众筹金额
    mapping (uint256 =>mapping(uint256 => uint256)) public starttime;     //某仓某轮开启众筹时间；
    mapping (address =>mapping (uint256 =>mapping(uint256 => uint256))) public participation; //某账户某仓某轮已众筹金额；

    event Participate( address  indexed   owner,
                   uint256            warehouse,
                   uint256                round,
                   uint256                  wad
                  );
    event Award( address  indexed         owner,
                   uint256            warehouse,
                   uint256                round,
                   uint256                  wad
                  );
    event Blasting( address  indexed      owner,
                   uint256            warehouse,
                   uint256                round,
                   uint256                  wad
                  );
    event Backstrack( address  indexed    owner,
                      uint256         warehouse,
                      uint256             round,
                      uint256               wad
                  );           
    constructor(){
        //usdt.approve(address(router), ~uint(1));
        //usdt.approve(address(dex), ~uint(1));
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

    //用户充值   
    function deposit(uint256 _usdtamount,address _recommend) public {
        usdt.transferFrom(msg.sender, address(this), _usdtamount);
        usdtamount[msg.sender] += _usdtamount*95/100;
        uint256 _gazamount = dex.buygaz(_usdtamount*5/100);
        balanceOf[msg.sender] += _gazamount;
        totalSupply += _gazamount;
        emit Transfer(zero,msg.sender, _gazamount);
        if (recommend[msg.sender] == address(0) && _recommend != address(0)) 
            recommend[msg.sender] = _recommend;  
    }
    // 用户参与众筹
    function participate(uint256 _warehouse,uint256 _round,uint256 _usdtamount) public returns (bool) {
        require(block.timestamp < starttime[_warehouse][_round] + week && block.timestamp > starttime[_warehouse][_round], "DigitalDeal2/stop");
        require(participation[msg.sender][_warehouse][_round] == 0, "DigitalDeal2/You can only participate once in a round");
        require(_usdtamount <=usdtamount[msg.sender] && _usdtamount<=add(mul(_round,base),uint(15*10**18)), "DigitalDeal2/Participation amount exceeds allowable");
        uint256 should = _usdtamount;
        uint256 maxsum;
        if (_round == 1) maxsum = startAmount;
        else maxsum = mul(startAmount,13**(_round-1))/10**(_round-1);
        require(maxsum > crowdfundSum[_warehouse][_round], "DigitalDeal2/The crowdfunding is full");

        //如果众筹的金额等于或超出本轮余额，就开启下一轮
        if (should >= sub(maxsum,crowdfundSum[_warehouse][_round])) {
            should = sub(maxsum, crowdfundSum[_warehouse][_round]);
            starttime[_warehouse][_round +1] = block.timestamp + 86400;
        }
        crowdfundSum[_warehouse][_round] += should;
        usdtamount[msg.sender] = sub(usdtamount[msg.sender],should);
        participation[msg.sender][_warehouse][_round] = should;

        //如果用户有锁仓中的gaz,就按1%的比例释放
        if (gazamount[msg.sender] >0) {
            uint256 releaseusdt = should/100;
            uint256 releasegaz = mul(releaseusdt,uint(1e18))/dex.gazprice();
            if (releasegaz > gazamount[msg.sender]) {
                releasegaz = gazamount[msg.sender];
                releaseusdt = mul(releasegaz,dex.gazprice())/10e18;
            }
            gazamount[msg.sender] = sub (gazamount[msg.sender],releasegaz);
            balanceOf[msg.sender] = add(balanceOf[msg.sender],releasegaz);
            totalSupply += releasegaz;
            emit Transfer(zero,msg.sender, releasegaz);
        }
        uint256 _gaz = (should*5/100)*10**18/dex.gazprice();
        require(balanceOf[msg.sender] >= _gaz, "DigitalDeal2/The gaZ balance of the declaration is insufficient");
        balanceOf[msg.sender] = sub(balanceOf[msg.sender],_gaz);
        totalSupply -= _gaz;
        emit Transfer(msg.sender, zero, _gaz);
        emit Participate(msg.sender,_warehouse,_round,should); 
        return  true;
    }
    //用户盈利结算
    function selfaward(uint256 _warehouse,uint256 _round) public {
        uint256 Should = participation[msg.sender][_warehouse][_round];
        require(Should > 0, "DigitalDeal2/have already settled");
        require(crowdfundSum[_warehouse][_round+3] == mul(startAmount,13**(_round+2))/10**(_round+2), "DigitalDeal2/The settlement conditions are not met");
        participation[msg.sender][_warehouse][_round] = 0;
        usdtamount[msg.sender] = add(usdtamount[msg.sender],Should);
        uint256 _buyeat = Should*13/100;
        router.swapExactTokensForTokens(_buyeat, 0,path,msg.sender,block.timestamp);
        emit Award(msg.sender,_warehouse,_round,Should); 
    }
    //用户爆仓结算
    function blasting(uint256 _warehouse,uint256 _round) public {
        uint256 Should = participation[msg.sender][_warehouse][_round];
        require(Should > 0, "DigitalDeal2/have already settled");
        
        //结算轮次的后三轮中有一轮超出众筹时间而未众筹满
        require(crowdfundSum[_warehouse][_round+3] < mul(startAmount,13**(_round+2))/10**(_round+2) && block.timestamp > starttime[_warehouse][_round +3] + week 
                || crowdfundSum[_warehouse][_round+2] < mul(startAmount,13**(_round+1))/10**(_round+1) && block.timestamp > starttime[_warehouse][_round +2] + week
                || crowdfundSum[_warehouse][_round+1] < mul(startAmount,13**(_round))/10**_round && block.timestamp > starttime[_warehouse][_round +1] + week 
                , "DigitalDeal2/Settlement has not yet begun");
        participation[msg.sender][_warehouse][_round] = 0;
        usdtamount[msg.sender] = add(usdtamount[msg.sender],Should*75/100);
        gazamount[msg.sender] = add(gazamount[msg.sender],Should*25/100);
        emit Blasting(msg.sender,_warehouse,_round,Should); 
    }
    //众筹失败原路退回
    function backstrack(uint256 _warehouse,uint256 _round) public {
        uint256 Should = participation[msg.sender][_warehouse][_round];
        require(Should > 0, "DigitalDeal2/have already settled");
        require(crowdfundSum[_warehouse][_round] < mul(startAmount,13**(_round-1))/10**(_round-1), "DigitalDeal2/The crowdfunding is full");
        require(block.timestamp > starttime[_warehouse][_round] + week, "DigitalDeal2/The crowdfunding period is not over");
        participation[msg.sender][_warehouse][_round] = 0;
        usdtamount[msg.sender] = add(usdtamount[msg.sender],Should);
        emit Backstrack(msg.sender,_warehouse,_round,Should); 
    }
    //项目方开仓
    function openWarehouse(uint256 _warehouse) public auth returns (bool) {
        starttime[_warehouse][1] = block.timestamp;
        return  true;
    }
    //用户提取usdt
    function withdrawusdt(uint256 _usdtamount) public {
        require(usdtamount[msg.sender] >= _usdtamount, "DigitalDeal2/Exceeds withdrawal amount");
        uint256 _gaz = (_usdtamount*5/100)*10**18/dex.gazprice();
        require(balanceOf[msg.sender] >= _gaz, "DigitalDeal2/Insufficient balance of available GAZ");
        balanceOf[msg.sender] = sub(balanceOf[msg.sender],_gaz);
        totalSupply -= _gaz;
        emit Transfer(msg.sender, zero, _gaz);
        usdtamount[msg.sender]  = sub(usdtamount[msg.sender],_usdtamount);
        usdt.transfer(msg.sender, _usdtamount);   
    }

    //项目方提取推荐奖励
    function recommendusdt(uint256 _warehouse,uint256 _round,uint wad ,address usr) public auth{
        require(_round >= 4, "DigitalDeal2/Less than 4 rounds cannot be extracted");
        require(crowdfundSum[_warehouse][_round] == mul(startAmount,13**(_round-1))/10**(_round-1), "DigitalDeal2/The amount of crowdfunding is not slow");
        //最后3仓总额度的25%为总收益
        uint256 amount1 = mul(mul(startAmount,uint256(13**(_round-1)))/10**(_round-1),uint256(25))/100;
        uint256 amount2 = mul(mul(startAmount,uint256(13**(_round-2)))/10**(_round-2),uint256(25))/100;
        uint256 amount3 = mul(mul(startAmount,uint256(13**(_round-3)))/10**(_round-3),uint256(25))/100; 
        //除掉最后3轮的总额度的13%为用户需要提取的收益
        uint256 expenditure = startAmount;
        for (uint i =2;i<= _round-3; ++i) {
            uint256 _expenditure = mul(startAmount,13**(i-1))/10**(i-1);
            expenditure = add(expenditure,_expenditure);
        }
        //operability为项目方最多可以提取的推荐奖励金额
        uint256 operability = sub(add(add(amount1,amount2),amount3),uint256(expenditure*13/100));
        require(wad <= sub(operability,extract[_warehouse]), "DigitalDeal2/Withdrawal amount out of range");
        extract[_warehouse] = add(extract[_warehouse],wad);
        usdt.transfer(usr, wad);   
    }

    //返回用户的推荐关系
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
    //标准ERC20
    uint256                                           public  totalSupply;
    mapping (address => uint256)                      public  balanceOf;
    mapping (address => mapping (address => uint))    public  allowance;
    string                                            public  symbol = "gazt";
    string                                            public  name = "gaztoken";     
    uint256                                           public  decimals = 18; 

	function approve(address guy) external returns (bool) {
        return approve(guy, ~uint(1));
    }

    function approve(address guy, uint wad) public  returns (bool){
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) external  returns (bool){
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public  returns (bool)
    {
        if (src != msg.sender && allowance[src][msg.sender] != ~uint(1)) {
            require(allowance[src][msg.sender] >= wad, "gazt/insufficient-approval");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }
        require(balanceOf[src] >= wad, "gazt/insuff-balance");
        
        balanceOf[src] = sub(balanceOf[src], wad);
        balanceOf[dst] = add(balanceOf[dst], wad*98/100);
        totalSupply -= wad*2/100;
        emit Transfer(src, dst, wad*98/100);
        emit Transfer(src, zero, wad*2/100);
        return true;
    }
	event Transfer(
		address indexed _from,
		address indexed _to,
		uint _value
		);
	event Approval(
		address indexed _owner,
		address indexed _spender,
		uint _value
		);
 }