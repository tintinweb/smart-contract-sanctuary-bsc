/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

pragma solidity >=0.6.0;
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
    address public  KGTDAO = 0xb8ee032f632E35F4694268209Ef964f65CeF3fC4;
    address public  pancakdSwapFactory = 0x6725F303b657a9451d8BA641348b6761A6CC7a17; // test 0x6725F303b657a9451d8BA641348b6761A6CC7a17 main 0xca143ce32fe78f1f7019d7d551a6402fc5350c73
    address public  deadAddr = address(0xDEAD);
    struct vip{
        address _address;
        uint    _level;
        uint    _weight;
        uint    _costKGT;
        uint    _costUSD;
        bool    _isValid;
    }
    mapping(address=>vip)  private allVip;
    uint[]  public vip_usd = [0,50,100,300,600,1000,1500];
    struct user {
        address _address;
        address _referrer;
        uint256 _weight;
        uint256 _teamSize;
        uint256 _reward_total;
        uint256 _reward_static;
        uint256 _reward_dynamic;
        uint    _level;
        bool    _isValid;
    }

    mapping(address=> user)     private allUsers;

    event Pledge(address,uint,address,uint);
    event UpgradeVIP(address _addr,uint _levelNow,uint _levelLast,uint _payUSD,uint _payKGT);

    constructor(address _owner)payable{
        owner = _owner;
        allUsers[_owner] = user(_owner,address(0x0),0,0,0,0,0,0,false);
    }
    function getMyVipInfo() public view returns(vip memory) {
        return allVip[msg.sender];
    }
    function getUser(address _addr)public view returns(user memory){
        if(msg.sender == owner)
            return allUsers[_addr];
        return allUsers[msg.sender];
    }
    function totalDestory()public view returns(uint256){
        return IERC20(KGTDAO).balanceOf(deadAddr);
    }
    function pledge(uint _kgtValue,address _token,uint _tokenValue) public payable {
        require(_kgtValue > 0);
        IERC20(KGTDAO).transferFrom(msg.sender, deadAddr, _kgtValue);
        if(_tokenValue > 0 && _token != address(0x0)){
             IERC20(_token).transferFrom(msg.sender, owner, _tokenValue);
        }
        emit Pledge(msg.sender,_kgtValue,_token,_tokenValue);
        // require(allUsers[msg.sender]._address != address(0x0));
    } 
    function getPrice_KGT_USD()public view returns(uint256){
        (uint256 reseves0_0,uint256 reseves0_1) = _getPairReserves(_WBNB(), _BUSD());
        (uint256 reseves1_0,uint256 reseves1_1) = _getPairReserves(_WBNB(), KGTDAO);
        return (reseves0_1 * 10 ** 18 / reseves0_0) * (reseves1_0 * 10 ** 18 / reseves1_1) / (10 ** 18);
    }
    
    function getTokenPriceUSD(address _token)public view returns (uint) {
         (uint112 reseves0,uint112 reseves1) = _getPairReserves(_token, _BUSD());
         return reseves1 * 10 ** 18 / reseves0;
    }

    function _WBNB()internal pure returns(address){
        return 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    }
    function _BUSD()internal pure returns(address){
        return 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814;
    }
    function _getPairReserves(address token0,address token1)internal view returns(uint112,uint112) {
        address pair = IPancakeFactory(0x6725F303b657a9451d8BA641348b6761A6CC7a17).getPair(token0, token1);
        (uint112 reseves0,uint112 reseves1,) = IPancakePair(pair).getReserves();
        if(token0 > token1)
            (reseves1,reseves0) = (reseves0,reseves1);
        return (reseves0,reseves1);
    
    }
    function estimatePledgeTokenValue(address _tokenAddress,uint256 _kgtDaoValue)public view returns(uint){
        uint kgt_usd = getPrice_KGT_USD();
        uint token_usd = getTokenPriceUSD(_tokenAddress);
        return _kgtDaoValue * kgt_usd / token_usd;
    }
    function estimateVIPpayValue(uint _levelNow,uint _levelNext)public view returns (uint){
        require(_levelNext <= 6 && _levelNow <= 6 && _levelNow >= 0 && _levelNext > 0);
        uint _needUsd = vip_usd[_levelNext] - vip_usd[_levelNow];
        require(_needUsd >= 0);
        return _needUsd * 10 ** 36 / getPrice_KGT_USD();

    }
    function updateVip(uint256 lockKGT,uint16 level)public payable{
        
        uint _lastLevel = allVip[msg.sender]._level;
        require(level > _lastLevel && level <= 6);
        require(lockKGT > 0);
        if(allUsers[msg.sender]._address == address(0))
            allUsers[msg.sender] = user(msg.sender,address(0x0),0,0,0,0,0,0,false);
      
        uint pay_kgt = estimateVIPpayValue(_lastLevel, level);
        require(pay_kgt <= lockKGT);
        (uint _0,uint _1) = (lockKGT,pay_kgt);
        require((_0 - _1) * 100 / pay_kgt < 5 ,'out 5%');
        IERC20(KGTDAO).transferFrom(msg.sender, deadAddr, pay_kgt);
        uint payUSD = vip_usd[level] - vip_usd[_lastLevel];
        allVip[msg.sender]._address = msg.sender;
        allVip[msg.sender]._level = level;
        allVip[msg.sender]._costKGT += pay_kgt;
        allVip[msg.sender]._costUSD += payUSD;
        allVip[msg.sender]._isValid = true;

        emit UpgradeVIP(msg.sender,level,_lastLevel,payUSD,lockKGT);

    }
}