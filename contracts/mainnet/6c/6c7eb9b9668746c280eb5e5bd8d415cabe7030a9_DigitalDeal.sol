// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "./SafeMath.sol";
import "./Address.sol";

interface TokenLike {
    function transferFrom(address,address,uint256) external;
    function transfer(address,uint256) external;
    function approve(address,uint256) external;
    function balanceOf(address) external view returns(uint256);
}
interface RouterV2 {
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint256,uint256,address[] memory,address,uint256) external returns(uint256[] memory);
}

interface Oracle {
    function transferFrom(address,address,uint256) external;
    function transfer(address,uint256) external;
    function approve(address,uint256) external;
    function balanceOf(address) external view returns(uint256);
    function getGazPrice() external view returns (uint256);
    function buyGaz(uint256) external returns (uint256);
}
contract DigitalDeal {
    using SafeMath for uint256;
    using Address for address;

    // --- Auth ---
    mapping (address => uint256) public permissions;
    function rely(address usr) external  auth {permissions[usr] = 1; }
    function deny(address usr) external  auth {permissions[usr] = 0; }
    modifier auth {
        require(permissions[msg.sender] == 1, "DigitalDeal/not-authorized");
        _;
    }

    uint256        public startAmount = 1000*1e18;   //第一轮1000u启动
    uint256        public base = 5*1e18;            //每轮报单上线增加5u
    uint256        public week = 172800;               //每轮众筹时间48小时
    address        public zero = address(0);           //零地址
    uint256        public releaseRatio = 1;
    uint256        public betweenRound = 86400;
    uint256        public setGazPrice = 29000/10000*1e18;
    uint256        public usdtGazTotal = 0;
    bool           public isOpenGazPrice = false;
    uint256        public rechargeFee = 5;
    uint256        public transferFee = 2;
    uint256        public explosionFee = 25;
    uint256        public swapSlippage = 9800;
    address[]      public path = [0x55d398326f99059fF775485246999027B3197955, 0x0f77144eba9c24545aA520a03f9874C4f1f4850F];
    TokenLike      public usdt = TokenLike(0x55d398326f99059fF775485246999027B3197955);
    RouterV2       public router = RouterV2(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    Oracle         public oracle;  // 这里没有实例化

    //Setting global Parameters
    function global(uint256 what, uint256 data, bool openGazPrice, address _dexAddress) external auth {
        if (what == 1) startAmount = data;
        else if (what == 2) base = data;
        else if (what == 3) week = data;
        else if (what == 4) rechargeFee = data;
        else if (what == 5) transferFee = data;
        else if (what == 6) explosionFee = data;
        else if (what == 7) setGazPrice = data;
        else if (what == 8) releaseRatio = data;
        else if (what == 9) betweenRound = data;
        else if (what == 10) swapSlippage = data;
        else if (what == 11) isOpenGazPrice = openGazPrice;
        else if (what == 12) oracle = Oracle(_dexAddress); // 这里实例化
        else revert("DigitalDeal/global-unrecognized-param");
    }

    mapping (address => uint256) public usdtAmount; //账户可用usd余额
    mapping (address => uint256) public gazAmount;  //爆仓后锁仓gaz余额
    mapping (address => address) public recommend;  //推荐关系
    mapping (uint256 => uint256) public extract;    //某仓项目方已提取推荐奖励
    mapping (uint256 => mapping (uint256 => uint256)) public crowdfundSum;  //某仓某轮已众筹金额
    mapping (uint256 => mapping (uint256 => uint256)) public startTime;     //某仓某轮开启众筹时间；
    mapping (address => mapping (uint256 => mapping (uint256 => uint256))) public participation; //某账户某仓某轮已众筹金额；

    function b2Addr(bytes32 bs) internal pure returns(address) {
        return address(uint160(uint256(bs)));
    }

    function setMapping(uint256 what, bytes32[] memory str) external auth {
        if (what == 1) usdtAmount[b2Addr(str[1])] = uint256(str[2]);
        else if (what == 2) gazAmount[b2Addr(str[1])] = uint256(str[2]);
        else if (what == 3) recommend[b2Addr(str[1])] = b2Addr(str[2]);
        else if (what == 4) extract[uint256(str[1])] = uint256(str[2]);
        else if (what == 5) crowdfundSum[uint256(str[1])][uint256(str[2])] = uint256(str[3]);
        else if (what == 6) startTime[uint256(str[1])][uint256(str[2])] = uint256(str[3]);
        else if (what == 7) participation[b2Addr(str[1])][uint256(str[2])][uint256(str[3])] = uint256(str[4]);
        else revert("DigitalDeal/mapping-unrecognized-param");
    }

    event Participate( 
        address  indexed   owner,
        uint256            warehouse,
        uint256                round,
        uint256                  wad
    );
    event Award( 
        address  indexed       owner,
        uint256            warehouse,
        uint256                round,
        uint256                  wad,
        uint256                  eatNum
    );
    event Blasting(
        address  indexed      owner,
        uint256            warehouse,
        uint256                round,
        uint256                  wad
    );

    event Backstrack( 
        address  indexed    owner,
        uint256         warehouse,
        uint256             round,
        uint256               wad
    );

    event OpenWarehouse(uint256 _warehouse, uint256 _startTime, uint256 _week);
    event Deposit(address indexed owner, address indexed recommend, uint256 usdtNum, uint256 gazNum);
    event WithdrawUsdt(address indexed owner, uint256 usdtNum, uint256 gazNum);

    constructor(){
        permissions[msg.sender] = 1;
        usdt.approve(address(router), ~uint256(0));
    }

    function gazPrice() public view returns(uint256){
        if (address(oracle) == address(0)) return setGazPrice;
        else return oracle.getGazPrice();
    }

    //用户充值
    function deposit(uint256 _amount, address _recommend) public {
        require(_amount >= 1e18, "The quantity must be greater than or equal to 1 usdt");
        usdt.transferFrom(msg.sender, address(this), _amount);
        usdtAmount[msg.sender] += _amount * (100 - rechargeFee)/100;
        uint256 _gazAmount = (_amount * rechargeFee/100*1e18)/gazPrice();
        usdtGazTotal = usdtGazTotal.add(_amount * rechargeFee/100);
        balanceOf[msg.sender] += _gazAmount;
        totalSupply += _gazAmount;
        if (recommend[msg.sender] == address(0) && _recommend != address(0)){
            recommend[msg.sender] = _recommend;
        }
        emit Transfer(zero, msg.sender, _gazAmount);
        emit Deposit(msg.sender, _recommend, _amount*(100-rechargeFee)/100, _gazAmount);
    }

    function roundSub(uint256 _startAmount, uint256 _round, uint256 num) internal pure returns(uint256){
        return uint256(int(_startAmount.div(1e18).mul(13**(_round-num)).div(10**(_round-num))) * 1e18);
    }

    function roundAdd(uint256 _startAmount, uint256 _round, uint256 num) internal pure returns(uint256){
        return uint256(int(_startAmount.div(1e18).mul(13**(_round+num)).div(10**(_round+num))) * 1e18);
    }

    // 用户参与众筹
    function participate(uint256 _warehouse, uint256 _round, uint256 _amount) public returns (bool) {
        require(block.timestamp < startTime[_warehouse][_round] + week && block.timestamp > startTime[_warehouse][_round], "DigitalDeal/stop");
        require(participation[msg.sender][_warehouse][_round] == 0, "DigitalDeal/You can only participate once in a round");
        require(_amount*(100-rechargeFee)/100 <= usdtAmount[msg.sender] && _amount <= 20 * 1e18 + base.mul(_round - 1), "DigitalDeal/Participation amount exceeds allowable");
        uint256 should = _amount;
        uint256 maxSum;
        if (_round == 1) maxSum = startAmount;
        else maxSum = roundSub(startAmount, _round, 1);
        require(maxSum > crowdfundSum[_warehouse][_round], "DigitalDeal/The crowdfunding is full");

        //如果众筹的金额等于或超出本轮余额，就开启下一轮
        if (should >= maxSum.sub(crowdfundSum[_warehouse][_round])) {
            should = maxSum.sub(crowdfundSum[_warehouse][_round]);
            if((startTime[_warehouse][_round] + betweenRound) > block.timestamp){
                startTime[_warehouse][_round +1] = startTime[_warehouse][_round] + betweenRound;
            } else if((startTime[_warehouse][_round] + week) > block.timestamp){
                startTime[_warehouse][_round +1] = startTime[_warehouse][_round] + week;
            }
        }
        crowdfundSum[_warehouse][_round] += should;
        usdtAmount[msg.sender] = usdtAmount[msg.sender].sub(should * (100 - rechargeFee)/100);
        participation[msg.sender][_warehouse][_round] = should;

        //如果用户有锁仓中的gaz,就按比例释放
        if (gazAmount[msg.sender] > 0) {
            uint256 releaseGaz = should*releaseRatio/100;
            if(isOpenGazPrice) 
                releaseGaz = releaseGaz*1e18/gazPrice();
            if (releaseGaz > gazAmount[msg.sender]) {
                releaseGaz = gazAmount[msg.sender];
            }
            gazAmount[msg.sender] = gazAmount[msg.sender].sub(releaseGaz);
            balanceOf[msg.sender] = balanceOf[msg.sender].add(releaseGaz);
            totalSupply += releaseGaz;
            emit Transfer(zero, msg.sender, releaseGaz);
        }
        //destroy GAZ
        uint256 _gaz = (should * rechargeFee/100)*1e18/gazPrice();
        require(balanceOf[msg.sender] >= _gaz, "DigitalDeal/The gaz balance of the declaration is insufficient");
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_gaz);
        totalSupply -= _gaz;
        emit Transfer(msg.sender, zero, _gaz);
        emit Participate(msg.sender, _warehouse, _round, should);
        return  true;
    }
    //用户盈利结算
    function selfaward(uint256 _warehouse, uint256 _round) public {
        uint256 Should = participation[msg.sender][_warehouse][_round];
        require(Should > 0, "DigitalDeal/have already settled");
        require(crowdfundSum[_warehouse][_round+3] >= roundAdd(startAmount, _round, 2), "DigitalDeal/The settlement conditions are not met");
        participation[msg.sender][_warehouse][_round] = 0;
        usdtAmount[msg.sender] = usdtAmount[msg.sender].add(Should);
        uint256 _buyeat = Should * 13/100;
        uint256[] memory amounts = router.getAmountsOut(_buyeat, path);
        uint256 minioutamount = amounts[1]*swapSlippage/10000;
        uint256[] memory resultNum = router.swapExactTokensForTokens(_buyeat, minioutamount, path, msg.sender, block.timestamp);
        emit Award(msg.sender, _warehouse, _round, Should, resultNum[1]);
    }
    //用户爆仓结算
    function blasting(uint256 _warehouse, uint256 _round) public {
        uint256 Should = participation[msg.sender][_warehouse][_round];
        require(Should > 0, "DigitalDeal/have already settled");

        //结算轮次的后三轮中有一轮超出众筹时间而未众筹满
        require(
            crowdfundSum[_warehouse][_round+3] < roundAdd(startAmount, _round, 2) && startTime[_warehouse][_round +3] >0 && block.timestamp > startTime[_warehouse][_round +3] + week ||
            crowdfundSum[_warehouse][_round+2] < roundAdd(startAmount, _round, 1) && startTime[_warehouse][_round +2] >0 && block.timestamp > startTime[_warehouse][_round +2] + week ||
            crowdfundSum[_warehouse][_round+1] < roundAdd(startAmount, _round, 0) && startTime[_warehouse][_round +1] >0 && block.timestamp > startTime[_warehouse][_round +1] + week, "DigitalDeal/Settlement has not yet begun");
        participation[msg.sender][_warehouse][_round] = 0;
        usdtAmount[msg.sender] = usdtAmount[msg.sender].add(Should*(100-explosionFee)/100);
        //lockGaz
        gazAmount[msg.sender] = gazAmount[msg.sender].add(Should*explosionFee/100);
        emit Blasting(msg.sender, _warehouse, _round, Should);
    }
    //众筹失败原路退回
    function backstrack(uint256 _warehouse, uint256 _round) public {
        uint256 Should = participation[msg.sender][_warehouse][_round];
        require(Should > 0, "DigitalDeal/have already settled");
        require(crowdfundSum[_warehouse][_round] < roundSub(startAmount, _round, 1), "DigitalDeal/The crowdfunding is full");
        require(block.timestamp > startTime[_warehouse][_round] + week, "DigitalDeal/The crowdfunding period is not over");
        participation[msg.sender][_warehouse][_round] = 0;
        usdtAmount[msg.sender] = usdtAmount[msg.sender].add(Should*(100-rechargeFee)/100);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(Should*rechargeFee/100*1e18/gazPrice());
        emit Backstrack(msg.sender, _warehouse, _round, Should);
    }
    //项目方开仓
    function openWarehouse(uint256 _warehouse, uint256 _startTime, uint256 _week) public auth returns (bool) {
        if(_startTime == 0) _startTime = block.timestamp;
        if(startTime[_warehouse][1]==0) startTime[_warehouse][1] = _startTime;
        week = _week;
        emit OpenWarehouse(_warehouse, _startTime, _week);
        return  true;
    }

    //用户提取usdt
    function withdrawusdt(uint256 _amount) public {
        require(usdtAmount[msg.sender] >= _amount, "DigitalDeal/Exceeds withdrawal amount");
        uint256 _gaz = (_amount * rechargeFee/100)*10**18/gazPrice();
        require(balanceOf[msg.sender] >= _gaz, "DigitalDeal/Insufficient balance of available GAZ");
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_gaz);
        totalSupply -= _gaz;
        emit Transfer(msg.sender, zero, _gaz);
        usdtAmount[msg.sender]  = usdtAmount[msg.sender].sub(_amount);
        usdt.transfer(msg.sender, _amount);
        emit WithdrawUsdt(msg.sender, _amount, _gaz);
    }

    //提取usdt
    function withdraw(address usr, uint256 _amount) public auth {
        require(usdtGazTotal >= _amount, "DigitalDeal/Insufficient balance");
        usdtGazTotal = usdtGazTotal.sub(_amount);
        emit Transfer(address(this), usr, _amount);
        usdt.transfer(usr, _amount);
    }

    function mint(address _account, uint256 _amount) public auth {
        require(_account != zero, "BEP20: mint to the zero address");
        totalSupply += _amount;
        require(totalSupply <= 63000000 * 1e18, "The number of gazt cannot exceed 63 million");
        balanceOf[_account] += _amount;
        emit Transfer(zero, _account, _amount);
    }

    function lockGaz(address _account, uint256 _amount) public auth {
        require(_account != zero, "BEP20: mint to the zero address");
        gazAmount[_account] += _amount;
    }

    //项目方提取推荐奖励
    function recommendusdt(uint256 _warehouse, uint256 _round, uint256 wad, address usr) public auth {
        require(crowdfundSum[_warehouse][_round] == roundSub(startAmount, _round, 1), "DigitalDeal/The amount of crowdfunding is not slow");
        //最后3仓总额度的25%为总收益
        uint256 amount1;
        uint256 amount2;
        uint256 amount3;
        if ( _round >=1) amount1 = roundSub(startAmount, _round, 1).mul(explosionFee-5)/100;
        if ( _round >=2) amount2 = roundSub(startAmount, _round, 2).mul(explosionFee-5)/100;
        if ( _round >=3) amount3 = roundSub(startAmount, _round, 3).mul(explosionFee-5)/100;
        //除掉最后3轮的总额度的13%为用户需要提取的收益
        uint256 expenditure;
        if(_round >= 4) {
            expenditure = startAmount;
            for (uint i =2; i<=_round-3; ++i) {
                uint256 _expenditure = roundSub(startAmount, i, 1);
                expenditure = expenditure.add(_expenditure);
            }
        }
        //operability为项目方最多可以提取的推荐奖励金额
        uint256 operability = amount1.add(amount2).add(amount3).sub(uint256(expenditure*18/100));
        require(wad <= operability.sub(extract[_warehouse]), "DigitalDeal/Withdrawal amount out of range");
        extract[_warehouse] = extract[_warehouse].add(wad);
        usdt.transfer(usr, wad);
    }

    //返回用户的推荐关系
    function recommends(address usr, uint256 level) public view returns (address[] memory) {
        address[] memory superstratum = new address[](level);
        address _recommend = usr;
        for (uint256 i =0; i< level; ++i) {
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
    mapping (address => mapping (address => uint256))    public  allowance;
    string                                            public  symbol = "GAZ";
    string                                            public  name = "gaztoken";
    uint256                                           public  decimals = 18;

    function approve(address guy) external returns (bool) {
        return approve(guy, ~uint256(0));
    }

    function approve(address guy, uint256 wad) public returns (bool){
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint256 wad) external returns (bool){
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint256 wad) public returns (bool) {
    // 这里要注意，排除pair地址
        if (src != msg.sender && allowance[src][msg.sender] != ~uint(0)) {
            require(allowance[src][msg.sender] >= wad, "gazt/insufficient-approval");
            allowance[src][msg.sender] = allowance[src][msg.sender].sub(wad);
        }
        require(balanceOf[src] >= wad, "gazt/insuff-balance");

        balanceOf[src] = balanceOf[src].sub(wad);
        balanceOf[dst] = balanceOf[dst].add(wad*(100-transferFee)/100); 
        totalSupply -= wad * transferFee/100;
        emit Transfer(src, dst, wad*(100-transferFee)/100);
        emit Transfer(src, zero, wad*transferFee/100);
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