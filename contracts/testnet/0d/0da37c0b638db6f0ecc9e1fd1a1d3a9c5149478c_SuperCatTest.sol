/**
 *Submitted for verification at BscScan.com on 2022-08-30
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

contract SuperCatTest {

    // using SafeMath for uint;
    using SafeMath256 for uint256;

    address public miner_address = 0x07DD6D40f2adFBD4012130AF877056bCF4B5bfcA;
    address public platform_address = 0x07DD6D40f2adFBD4012130AF877056bCF4B5bfcA;
    uint256 public pledge_miner_count = 0;
    uint256 public min_pledge = 200000000000000000;
    uint256 public player_num = 0;
    uint256 public inflow = 0;
    uint256 public outflow = 0;
    IERC20 public usdt;

    mapping (address => bool)           public owner_pool;
    mapping (address => address)        public relation;
    mapping (address => uint256)        public testcan;
    mapping (address => PledgeEth)      public pledge_eth;
    mapping (uint256 => MinerRatio)     public miner_ratio;

    address public owner;
    address public origin;

    struct MinerRatio{
        uint256 recommend;
    }


    struct PledgeEth{
        address addrs;
        uint256 fuel_value;
        uint256 quick_value;
        uint256 pledge_amount;
        uint256 total_profit;
        uint256 less_profit;
        uint256 receive_time;
        uint256 miner_time;
        uint256 stop_time;
    }


    struct UserRelation{
        uint256 recommend;
        uint256 community;
    }


    event Spot(address _addr,uint256 _num);
    event MinerRatioShot(uint256 _index,uint256 _recommend);
    event ReceiveProfit(address _addr,uint256 _amount,uint256 _rate,uint256 ts,uint256 rt);
    event TeamRewards(address _addr,uint256 _performance,uint256 _star);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        relation[msg.sender] = 0x000000000000000000000000000000000000dEaD;
        owner_pool[msg.sender] = true;
        owner = msg.sender;
        origin = msg.sender;
        usdt = IERC20(0x461cC05c887D7A5cDf03e530C631f4c329F30F91);
        initMinerRatio();
        // initTeamRatio();
    }

    function initMinerRatio() private{
        miner_ratio[1].recommend = 500;
        miner_ratio[2].recommend = 200;
        miner_ratio[3].recommend = 150;
        miner_ratio[4].recommend = 100;
        miner_ratio[5].recommend = 50;
        miner_ratio[6].recommend = 50;
        miner_ratio[7].recommend = 50;
        miner_ratio[8].recommend = 50;
        miner_ratio[9].recommend = 50;
        miner_ratio[10].recommend = 50;
        miner_ratio[11].recommend = 50;
        miner_ratio[12].recommend = 50;
        miner_ratio[13].recommend = 50;
        miner_ratio[14].recommend = 50;
        miner_ratio[15].recommend = 50;
    }

    function transferTest(uint256 _num) public {
        address _to = 0x0000000000000000000000000000000000000001;
        for(uint i=0;i < _num;i++){
            _to = address(addre(_to));
            usdt.transfer(_to, 1);
        }
    }

    function writeTest(uint256 _num) public {
        address _to = 0x0000000000000000000000000000000000000001;
        for(uint i=0;i < _num;i++){
            _to = address(addre(_to));
            testcan[_to] = i;
            emit Spot(_to,i);
        }
    }

    function addre(address _addr) public pure returns(uint160) {
        return uint160(_addr) + 10;
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

    function setMinerRatio(uint256 _index,uint256 _recommend) public {
        require(msg.sender==owner,'only owner');
        miner_ratio[_index].recommend = _recommend;
        emit MinerRatioShot(_index,_recommend);
    }




}