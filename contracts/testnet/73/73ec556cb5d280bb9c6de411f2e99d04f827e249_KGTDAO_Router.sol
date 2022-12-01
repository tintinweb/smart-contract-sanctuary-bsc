/**
 *Submitted for verification at BscScan.com on 2022-11-30
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

    constructor(address _owner)payable{
        owner = _owner;
        allUsers[_owner] = user(_owner,address(0x0),0,0,0,0,0,0,false);
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
             IERC20(_token).transferFrom(msg.sender, owner, _kgtValue);
        }
        emit Pledge(msg.sender,_kgtValue,_token,_tokenValue);
        // require(allUsers[msg.sender]._address != address(0x0));
    }
    function getKGTPriceUSD()public view returns(uint){
        address _wbnb = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
        address _wusd = 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814;
        uint bnbPrice;
        (uint112 reseves0,uint112 reseves1) = _getPairReserves(_wbnb, _wusd);
        bnbPrice = reseves1 * 10 ** 8 / reseves0 ;
        (reseves0,reseves1) = _getPairReserves(_wbnb, KGTDAO);
        return bnbPrice * (reseves1 * 10 ** 8 / reseves0);
    }
    function _getPairReserves(address token0,address token1)internal view returns(uint112,uint112) {
        address pair = IPancakeFactory(0x6725F303b657a9451d8BA641348b6761A6CC7a17).getPair(token0, token1);
        (uint112 reseves0,uint112 reseves1,) = IPancakePair(pair).getReserves();
        if(token0 > token1)
            (reseves1,reseves0) = (reseves0,reseves1);
        return (reseves0,reseves1);
        // address _wbnb = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
        // address _wusd = 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814;
        // address pair = IPancakeFactory(0x6725F303b657a9451d8BA641348b6761A6CC7a17).getPair(_wbnb, _wusd);
        // (uint112 reseves0,uint112 reseves1,) = IPancakePair(pair).getReserves();
        // if(_wbnb > _wusd)
        //     (reseves1,reseves0) = (reseves0,reseves1);
        // uint _price_bnb_usd = reseves1 / reseves0 * 10 ** 18;

        // pair = IPancakeFactory(0x6725F303b657a9451d8BA641348b6761A6CC7a17).getPair(_wbnb, KGTDAO);
        // (reseves0,reseves1,) = IPancakePair(pair).getReserves();
        // if(_wbnb > KGTDAO)
        //     (reseves1,reseves0) = (reseves0,reseves1);
        // return _price_bnb_usd * (reseves0 / reseves1);

    }
    function estmatePledgeTokenValue(address _tokenAddress,uint256 _kgtDaoValue)public view {
        
    }
    function getLevelInfo(uint _level)public view returns(uint destory_kgt,uint destory_kgt_usd,uint weight,uint outMultiple){
        //  if(_level == 1){
        //     destory_kgt_usd = 50;
        //     weight = 300;
        //     outMultiple = 2;
        //  }
        // else if(_level == 2){
        //     destory_kgt_usd = 100;
        //     weight = 600;
        //     outMultiple = 2;
        // }    
        // else if(_level == 3){
        //     destory_kgt_usd = 300;
        //     weight = 1200;
        //     outMultiple = 2.5;
        // }     
        // else if(_level == 4){
        //     destory_kgt_usd = 600;
        //     weight = 3000;
        //     outMultiple = 2.5;
        // }   
        // else if(_level == 5){
        //     destory_kgt_usd = 1000;
        //     weight = 6000;
        //     outMultiple = 3;
        // }
        // else if(_level == 6){
        //     destory_kgt_usd = 1500;
        //     weight = 10000;
        //     outMultiple = 3;
        // }
             
    }
    function estmateLevelKGTvalue(uint16 _level)public view returns(uint256 destoryKgt,uint16 level) {
        uint256 kgt_usd = 0;

    }
    function register(address referrer,uint256 lockKGT,uint16 level)public payable{
        // require(allUsers[referrer]._address != address(0x0));
        // require(allUsers[msg.sender]._address != address(0x0));
        // allUsers[msg.sender] = user(msg.sender,referrer,0,0,0,0,0,0,false);
        // allUsers[referrer]._teamSize += 1;
        // (uint destory_kgt,uint destory_kgt_usd,uint weight,uint outMultiple) = this.getLevelInfo(level);
        // require(destory_kgt <= lockKGT * 10 ** 18 && destory_kgt > 0 && _level == level);
        // IERC20(KGTDAO).transferFrom(msg.sender, deadAddr,destory_kgt * 10 ** 18);
        // allUsers[msg.sender]._level = level;

    }
}