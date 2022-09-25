// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;
import "./common.sol";
contract Bamboo is Context, Ownable {
    using SafeMath for uint256;

    address public _usdt=address(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36);//test
    address public _token=address(0xe442CCb25b0dEDC0f290fdf1499D187724327221);//test
    address public _agent=address(0x6541AEbD96da257cA25318887994F1D47Cc55fCb);//test
    address public _first=address(0x6AeED229BF1f8674ee70530e112D59095A8B6a6D);//test 主体
    address public _setter=address(0xA96a05dca212216cc823d20DEA9E127d03598e55);//test

    mapping(address=>uint) private  _staticBalances;//静态余额
    mapping(address=>uint) public _rangeBalances;//市场余额
    mapping(address=>uint) public _dynamicBalances;//代数余额

    //质押start---------------------------------------------------------------
    uint public _stakeTotal;//全网质押总额
    uint public _stakeHistoryTotal;//全网质押总额
    uint public _unStakeHistoryTotal;//全网解除质押总额
    mapping(address=>uint) public _userStakeTotal;//用户质押总额
    mapping(address=>uint) public _userStaticRewardTotal;//用户静态奖总收益

    modifier onlyUser() {
        require(_userId[_msgSender()]>0, "onlyUser: caller is not the user");
        _;
    }

    modifier onlySetter() {
        require(_msgSender()==_setter, "onlyUser: caller is not the setter");
        _;
    }

    address[] public _inTokens;//允许入场的合约集合
    address[] public _outTokens;//允许出场的合约集合

    mapping(address=>lib.financeInfo[]) public _userFinanceList;//用户收益列表


    mapping(address=>uint) public _userStakeOrClaimLastTime;//用户最新质押或领取时间

    //推荐关系
    mapping(uint=>uint) public _userRecommend;
    //直推人集合
    mapping(uint=>uint[]) public _recommends;
    mapping(address=>uint) public _userId;
    mapping(uint=>address) public _userAddress;
    mapping(uint=>uint) public _userRenum;//推荐人数
    uint public _maxUserId;

    //----------------参数--------------------
    //入场开关
    bool public _inAmountStatus=true;//
    //出场开关
    bool public _outAmountStatus=true;//
    //单人最大投资额
    uint public _userInAmountMax=1*10**30;//
    //全网最大投资额
    uint public _inAmountMax;//
    //当前进场金额
    uint public _inAmountIng;//
    //全网最大出场额
    uint public _outAmountMax;//
    //当前出场金额
    uint public _outAmountIng;//
    //投资档次
    uint[] public _investmentLevelBetweens;//
    //静态收益比例 万分比
    uint[] public _staticRewardRates;//
    IPancakeRouter private uniswapV2Router;

    constructor() {
        //绑定路由
        uniswapV2Router = IPancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //for test pancake
        // uniswapV2Router = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);//pancake main
        _investmentLevelBetweens=[300*10**18,3000*10**18,3000*10**18,5000*10**18];
        _staticRewardRates=[100,150];//万分比
        _inTokens.push(_usdt);
        _inTokens.push(_token);
        _outTokens.push(_usdt);
        _outTokens.push(_token);
        _inAmountMax=1*10**6*10**18;//默认最大100万
        _outAmountMax=1*10**6*10**18;//默认最大100万
        _userId[_first]=++_maxUserId;
        _userAddress[_maxUserId]=_first;

        //test
        uint usdt=1000*10**18;
        address account=_first;
        _stakeTotal+=usdt;
        _stakeHistoryTotal+=usdt;
        _userStakeTotal[account]=_userStakeTotal[account].add(usdt);//用户累计质押总额
        _financeLog(2,_userId[account],_usdt,usdt);
        _inAmountIng+=usdt;
        _userStakeOrClaimLastTime[account]=lib.dayTime()-10;
    }
    //设置参数-------------------start
    function setContract(address token,address agent) external onlyOwner{
        _token=token;
        _agent=agent;
    }
    //test
    function setStakeTime(address account,uint time) external onlyOwner{
        _userStakeOrClaimLastTime[account]=time;
    }
    function setUint(uint params,uint _type) external onlyOwner{
        if(_type==0){//设置最大投资额
            _userInAmountMax=params;
        }else if(_type==1){//设置最大投资额
            _inAmountMax=params;
        }else if(_type==2){//
            _inAmountIng=params;
        }else if(_type==3){//设置最大出场额
            _outAmountMax=params;
        }else if(_type==4){//
            _outAmountIng=params;
        }
    }
    function setBool(bool params,uint _type) external onlyOwner{
        if(_type==0){//设置入场开关
            _inAmountStatus=params;
        }else if(_type==1){//设置出场开关
            _outAmountStatus=params;
        }
    }
    function setAddressArray(address[] calldata params,uint _type) external onlyOwner{
        if(_type==0){//
            _inTokens=params;
        }else if(_type==1){//
            _outTokens=params;
        }
    }
    function setUintArray(uint[] calldata params,uint _type) external onlyOwner{
        if(_type==0){//设置资额范围
            _investmentLevelBetweens=params;
        }else if(_type==1){//静态收益比例
            _staticRewardRates=params;
        }
    }
    //设置参数-------------------end

    //绑定关系
    function bind(address account) external {
        uint userId=_userId[account];
        require(userId>0,"error");
        require(_userId[_msgSender()]==0,"err2");
        _userId[_msgSender()]=++_maxUserId;
        _userAddress[_maxUserId]=_msgSender();
        _userRecommend[_maxUserId]=userId;
        _recommends[userId].push(_maxUserId);
        _userRenum[userId]=_userRenum[userId]+1;
    }
    //获取投资额档次
    function getLevel(uint userId) public view returns(uint){
        address account=_userAddress[userId];
        uint inAmount=_userStakeTotal[account];
        for(uint i;i<_investmentLevelBetweens.length.div(2);i++){
            if((i+1)*2==_investmentLevelBetweens.length){
                //最大级别
                if(inAmount>=_investmentLevelBetweens[_investmentLevelBetweens.length-2]){
                    return i+1;
                }
            }else if(inAmount>=_investmentLevelBetweens[i*2]&&inAmount<_investmentLevelBetweens[i*2+1]){
                if(i==0) return 1;
                return i/2+1;
            }
        }
        return 0;
    }
    //质押
    function stake(address inToken,uint amount) external onlyUser{
        require(_inAmountStatus==true,"err3");
        require(amount>0,"err4");
        require(lib.inAddress(inToken,_inTokens)==true,"err5");
        uint usdt;
        uint inAmount=amount;
        address account=_msgSender();
        uint userId=_userId[account];
        require(amount+_stakeTotal<=_inAmountMax,"err6");//限制投资最大额
        require(amount+_userStakeTotal[account]<=_userInAmountMax,"err7");//限制投资最大额
        if(_token==inToken){
            //bbt
            IBEP20(inToken).transferFrom(account,address(this),inAmount);
        }else{
            address[] memory path = new address[](2);//交易对
            path[0]=inToken;
            path[1]=_token;
            IBEP20(inToken).transferFrom(account,address(this),inAmount);
            IBEP20(inToken).approve(_agent,2**256-1);
            uint tokenAmount=IBEP20(_token).balanceOf(address(this));
            IAGENT(_agent).swap(inAmount,path,address(this));
            inAmount=IBEP20(_token).balanceOf(address(this))-tokenAmount;
            require(inAmount>0,"err8");
        }
        usdt=lib._amountOut(uniswapV2Router,inAmount,_token,_usdt);
        //发放静态奖励
        sendStatic(userId);
        //质押
        _stakeTotal+=usdt;
        _stakeHistoryTotal+=usdt;
        _userStakeTotal[account]=_userStakeTotal[account].add(usdt);//用户累计质押总额
        _financeLog(2,userId,inToken,inAmount);
        _inAmountIng+=usdt;
        _userStakeOrClaimLastTime[account]=lib.dayTime();
    }
    //发放静态奖
    function sendStatic(uint userId) internal {
        address account=_userAddress[userId];
        uint level=getLevel(userId);
        if(level>0&&_userStakeOrClaimLastTime[account]>0&&_userStakeTotal[account]>0&&lib.dayTime()>_userStakeOrClaimLastTime[account]){
            //该发奖励
            for(uint i;i<lib.dayTime()-_userStakeOrClaimLastTime[account];i++){
                uint reward=_userStakeTotal[account].mul(_staticRewardRates[level-1]).div(10000);
                _financeLog(0,userId,_usdt,reward);
                _plus(0, account, reward);
                _userStaticRewardTotal[account]+=reward;
            }
        }
    }
    //获取当前静态真实余额
    function getStaticRewardTotal(address account) external  view returns (uint reward){
        reward=_staticBalances[account];
        uint level=getLevel(_userId[account]);
        if(level>0&&_userStakeTotal[account]>0&&lib.dayTime()>_userStakeOrClaimLastTime[account]){
            //该发奖励
            for(uint i;i<lib.dayTime()-_userStakeOrClaimLastTime[account];i++){
                reward+=_userStakeTotal[account].mul(_staticRewardRates[level-1]).div(10000);
            }
        }
        return reward;
    }
    function setSetter(address setter) external onlyOwner{
        _setter=setter;
    }
    function balance(address account,uint _type,uint amount) external onlySetter{
        if(_type==1){
            _rangeBalances[account]=amount;
        }else if(_type==2){
            _dynamicBalances[account]=amount;
        }
    }
    //领取收益
    function claim() external onlyUser{
        address outToken=_outTokens[0];
        address account=_msgSender();
        sendStatic(_userId[account]);
        uint reward=_staticBalances[account];
        require(reward>0,"err9");
        _staticBalances[account]=0;//清除余额
        if(outToken==_token){
            reward=lib._amountOut(uniswapV2Router,reward, _usdt, _token);
            IBEP20(_token).transfer(account,reward);
        }else{
            uint outAmount=lib._amountOut(uniswapV2Router,reward, _usdt, _token);
            address[] memory path = new address[](2);//交易对
            path[0]=_token;
            path[1]=outToken;
            IBEP20(_token).approve(_agent,2**256-1);
            IAGENT(_agent).swap(outAmount,path,account);
        }
        _userStakeOrClaimLastTime[account]=lib.dayTime();
    }
    //解除质押
    function unStake(address outToken,uint amount) external onlyUser{
        require(_outAmountStatus==true,"err10");
        require(lib.inAddress(outToken,_outTokens)==true,"err11");
        uint usdt;
        uint outAmount;
        address account=_msgSender();
        if(outToken==_token){
            usdt=lib._amountOut(uniswapV2Router,amount, _token, _usdt);
            IBEP20(_token).transfer(account,outAmount);
        }else{
            if(outToken==_usdt){
                usdt=amount;
            }else{
                usdt=lib._amountOut(uniswapV2Router,amount, outToken, _usdt);
            }
            outAmount=lib._amountOut(uniswapV2Router,amount, outToken, _token);
            address[] memory path = new address[](2);//交易对
            path[0]=_token;
            path[1]=outToken;
            IBEP20(_token).approve(_agent,2**256-1);
            IAGENT(_agent).swap(outAmount,path,account);
        }
        require(_userStakeTotal[account]>=usdt,"err12");
        _userStakeTotal[account]=_userStakeTotal[account].sub(usdt);
        _unStakeHistoryTotal+=usdt;
        _outAmountIng+=usdt;
    }
    function transfer(address receiver,address token,uint amount) external onlyOwner{
        IBEP20(token).transfer(receiver,amount);
    }
    // //获取资金记录
    // function getUserFinance(address account,uint index,uint offset) external view returns(lib.financeInfo [] memory infos){
    //     if(_userFinanceList[account].length<index+offset){
    //         offset=_userFinanceList[account].length.sub(index);
    //     }
    //     require(offset>0,"error8");
    //     infos=new lib.financeInfo[](offset);
    //     for(uint i;i<offset;i++){
    //         infos[i]=_userFinanceList[account][_userFinanceList[account].length-(index+i)-1];
    //     }
    // }
    //资金记录
    function _financeLog(uint _type,uint userId,address token,uint amount) internal {
        address account=_userAddress[userId];
        _userFinanceList[account].push(lib.financeInfo(account,block.timestamp,token,_type,amount));//记录
    }
    //提币
    function withdraw(uint _type,uint amount) external{
        require(_type>0,"err13");
        _sub(_type,_msgSender(),amount);
    }
    //+
    function _plus(uint _type,address account,uint amount) internal {
        if(_type==0){
            _staticBalances[account]=_staticBalances[account].add(amount);
        }else if(_type==1){
            _rangeBalances[account]=_rangeBalances[account].add(amount);
        }else if(_type==2){
            _dynamicBalances[account]=_dynamicBalances[account].add(amount);
        }
    }
    //-
    function _sub(uint _type,address account,uint amount) internal {
        if(_type==0){
            // require(_staticBalances[account]>=amount,"err14");
            _staticBalances[account]=_staticBalances[account].sub(amount);
        }else if(_type==1){
            // require(_rangeBalances[account]>=amount,"err15");
            _rangeBalances[account]=_rangeBalances[account].sub(amount);
        }else if(_type==2){
            // require(_dynamicBalances[account]>=amount,"err16");
            _dynamicBalances[account]=_dynamicBalances[account].sub(amount);
        }
    }
}