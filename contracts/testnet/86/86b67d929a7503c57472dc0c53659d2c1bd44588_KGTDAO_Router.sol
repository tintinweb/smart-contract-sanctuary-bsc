/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
interface IPancakePair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
}


contract KGTDAO_Router {

    address private owner;
    address public  KGTDAO = 0x12906140700BD0f991d1e0b001C8a63B3dbD7d27;
    address public  pancakdSwapFactory = 0x6725F303b657a9451d8BA641348b6761A6CC7a17; // test 0x6725F303b657a9451d8BA641348b6761A6CC7a17 main 0xca143ce32fe78f1f7019d7d551a6402fc5350c73
    address public  deadAddr = address(0xDEAD);
    struct vipLog{
        address _address;
        uint    _level;
        uint    _weight_get;
        uint    _costKGT;
        uint    _costUSD;
        uint    _time;
        uint    _type;  // 0 buy 1 levelUp
    }
    vipLog[]                  private all_log_vipBuy;
    uint[]  public vip_usd      = [0,50,100,300,600,1000,1500];
    uint[]  public vip_weight   = [0,20,20,25,25,30,30];
    struct user {
        address _address;
        address _referrer;
        uint256 _weight_pledge;
        uint256 _weight_pledge_team;
        uint256 _weight_vip_current;
        uint256 _weight_vip_total;
        uint256 _teamSize;
        uint256 _teamSizeValid;
        uint256 _reward_total;
        uint256 _reward_static;
        uint256 _reward_dynamic;
        uint    _level;
        uint    _regTime;
        bool    _isValid;
        bool    _isValidVip;
    }
    struct pledgeLog{
        uint    _payKGT;
        uint    _payUSD;
        uint    _payToken;
        address _payTokenContract;
        uint    _time;
        uint    _getWeight;
    }

    mapping(address=> user)   private allUsers;
    mapping(address=> user[]) private getTeam_1;
    mapping(address=> user[]) private getTeam_all;

    mapping(address=> pledgeLog[]) private allPledgeLog;

    event Pledge(address,uint,address,uint);
    event UpgradeVIP(address _addr,uint _levelNow,uint _levelLast,uint _payUSD,uint _payKGT);

    // constructor(address _owner)payable{
    //     owner = _owner;
    //     allUsers[_owner] = user(_owner,address(0x0),0,0,0,0,0,0,false);
    // }
     constructor()payable{
        owner = msg.sender;
        allUsers[KGTDAO] = user(KGTDAO,address(0x0),0,0,0,0,0,0,0,0,0,0,block.timestamp,false,false);
    }
    function getVipBuyLog() public view returns(vipLog[] memory) {
        require(msg.sender == owner);
        return all_log_vipBuy;
    }
    function myTeam(bool allTeam,address _addr) public view returns(user[] memory){
        address _address = msg.sender;
        if(msg.sender == owner){
            _address = _addr;
        }
        if(allTeam)
            return getTeam_all[_address];
        return getTeam_1[_address];
    }
    function myPledgeLog(address _addr)public view returns(pledgeLog[] memory){
        address _address = msg.sender;
        if(msg.sender == owner){
            _address = _addr;
        }
        return allPledgeLog[_address];
    }
    function getUser(address _addr)public view returns(user memory){
         address _address = msg.sender;
        if(msg.sender == owner){
            _address = _addr;
        }
        return allUsers[_address];
    }
    function totalDestory()public view returns(uint){
        return IERC20(KGTDAO).balanceOf(deadAddr);
    }
    function pledge(uint _kgtValue,address _token,uint _tokenValue,address _referrer) public payable {
        require(_kgtValue > 0);
        if(allUsers[msg.sender]._referrer == address(0x0)){
            require(_referrer != address(0x0),"please input referrer");
            require(allUsers[_referrer]._address != address(0x0),"referrer error");
        }
        uint _weight_get = 0;
        IERC20(KGTDAO).transferFrom(msg.sender, deadAddr, _kgtValue);
        if(_tokenValue > 0 && _token != address(0x0)){
             IERC20(_token).transferFrom(msg.sender, owner, _tokenValue);
              // rate * 7
              _weight_get = _tokenValue * 7;
        }
        else{
            // rate * 10
             _weight_get = _tokenValue * 10;
        }
        //reg
        bool noReg = false;
        if(allUsers[msg.sender]._address == address(0x0)){
            noReg = true;
            allUsers[msg.sender] = user(msg.sender,_referrer,0,0,0,0,0,0,0,0,0,0,block.timestamp,true,true);
        }
        address referrerAddress = allUsers[msg.sender]._referrer;
        uint round = 1;
        while(referrerAddress != address(0x0)){
            allUsers[referrerAddress]._weight_pledge_team += _weight_get;
            if(noReg){
                allUsers[referrerAddress]._teamSize += 1;
                allUsers[referrerAddress]._teamSizeValid += 1;
                if(round++ == 1){
                    user[] memory _team_1 = getTeam_1[referrerAddress];
                    _team_1[_team_1.length] = allUsers[msg.sender];
                }
                user[] memory _team_all = getTeam_all[referrerAddress];
                _team_all[_team_all.length] = allUsers[msg.sender];
            }
            referrerAddress = allUsers[referrerAddress]._referrer;
        }
        allUsers[msg.sender]._weight_pledge += _weight_get;
        pledgeLog[] storage _userLog = allPledgeLog[msg.sender];
        _userLog[_userLog.length] = pledgeLog(_kgtValue,0,_tokenValue,_token,block.timestamp,_weight_get);
        allPledgeLog[msg.sender] = _userLog;
        emit Pledge(msg.sender,_kgtValue,_token,_tokenValue);
    } 
    function getPrice_KGT_USD()public view returns(uint){
        (uint reseves0_0,uint reseves0_1) = _getPairReserves(_WBNB(), _BUSD());
        (uint reseves1_0,uint reseves1_1) = _getPairReserves(_WBNB(), KGTDAO);
        return (reseves0_1 * 10 ** 18 / reseves0_0) * (reseves1_0 * 10 ** 18 / reseves1_1) / (10 ** 18);
    }
    
    function getTokenPriceUSD(address _token)public view returns (uint) {
         (uint reseves0,uint reseves1) = _getPairReserves(_token, _BUSD());
         return reseves1 * 10 ** 18 / reseves0;
    }

    function _WBNB()internal pure returns(address){
        return 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    }
    function _BUSD()internal pure returns(address){
        return 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814;
    }
    function _getPairReserves(address token0,address token1)internal view returns(uint112,uint112) {
        address pair = IPancakeFactory(pancakdSwapFactory).getPair(token0, token1);
        (uint112 reseves0,uint112 reseves1,) = IPancakePair(pair).getReserves();
        if(token0 > token1)
            (reseves1,reseves0) = (reseves0,reseves1);
        return (reseves0,reseves1); 
    }
    function estimatePledgeTokenValue(address _tokenAddress,uint _kgtDaoValue)public view returns(uint){
        uint kgt_usd = getPrice_KGT_USD();
        uint token_usd = getTokenPriceUSD(_tokenAddress);
        return _kgtDaoValue * kgt_usd / token_usd;
    }
    function estimateVIPpayKGT(uint _levelNow,uint _levelNext)public view returns (uint){
        require(_levelNext <= 6 && _levelNow <= 6 && _levelNow >= 0 && _levelNext > 0);
        uint _needUsd = vip_usd[_levelNext] - vip_usd[_levelNow];
        require(_needUsd >= 0);
        return _needUsd * 10 ** 36 / getPrice_KGT_USD();

    }
    function upgradeVIP(uint payKGT,uint16 level_set)external payable{
      
        require(level_set > 0 && level_set <= 6,'level error');
        require(allUsers[msg.sender]._address != address(0x0),"no reg");
       
        uint level_last = allUsers[msg.sender]._level;
        require(level_set > level_last,'level_set > level_last');
        
        require(payKGT > 0,'pay KGT error');

        uint estimateKGT = estimateVIPpayKGT(level_last, level_set);

        (uint _0,uint _1) = (payKGT,estimateKGT);
        if(_1 > _0)
            (_0,_1) = (estimateKGT,payKGT);
        
        require((_0 - _1) / payKGT < 3 ,'out 5%');

        IERC20(KGTDAO).transferFrom(msg.sender, deadAddr, payKGT);
        uint payUSD = vip_usd[level_set] - vip_usd[level_last];
        uint weight_get = (vip_weight[level_set] - vip_weight[level_last]) * payKGT / 10;

        
        all_log_vipBuy[all_log_vipBuy.length] = vipLog(msg.sender,level_set,weight_get,payKGT,payUSD,block.timestamp,(level_set == level_last + 1) ? 0 : 1);
        allUsers[msg.sender]._level = level_set;
        allUsers[msg.sender]._weight_vip_total += weight_get;
        emit UpgradeVIP(msg.sender,level_set,level_last,payUSD,payKGT);

    }
}