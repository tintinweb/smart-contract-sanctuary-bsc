/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

pragma solidity ^0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
    
    //開根號
    function sqrt(uint x) internal pure returns(uint) {
        uint z = (x + 1 ) / 2;
        uint y = x;
        while(z < y){
          y = z;
          z = ( x / z + z ) / 2;
        }
        return y;
     }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

interface ERC20 {
  function transfer(address _to, uint256 _value) external returns (bool);
  function balanceOf(address _owner) external view returns (uint256 balance);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
  function totalSupply() external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
}

contract ETKO{
    using SafeMath for uint256;
    using Address for address;

    ERC20 public BUSD;

    address public contract_owner;
    uint256 public total_supply = 10500;
    uint256 public PRICE = 2;// 測試: 2 BUSD
    uint256 public REWARD = 1;//獎勵 1 BUSD

    mapping (address => bool) public is_buy;// 是否購買過
    mapping (address => bool) public is_chg;// 是否兌換

    mapping (address => uint256) public Referral_reward;// 推薦獎勵
    mapping (address => uint256) public R_num;// 推薦人數

    constructor() public {
        contract_owner = msg.sender; 
        BUSD = ERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684); // 測試鏈BUSD
    }

    modifier onlyOwner() {
        require(msg.sender == contract_owner);
        _;
    }

    function buy_ETKO(address referrer) public returns (bool) {
        uint256 BUSD_B = BUSD.balanceOf(msg.sender);
        uint256 allowance = BUSD.allowance(msg.sender, address(this));
        require(referrer!=msg.sender, "The referrer con not be yourself.");
        require(is_buy[msg.sender]==false, "You have purchased.");
        require(BUSD_B >= PRICE*1*10**18,"Check your BUSD balance");
        require(allowance >= PRICE*1*10**18, "Check the BUSD allowance");
        require(total_supply > 0 ,"Not enough remaining quantity");
        
        BUSD.transferFrom(msg.sender, address(this), PRICE*1*10**18);

        is_buy[msg.sender] = true;
        is_chg[msg.sender] = false;
        total_supply = total_supply.sub(1);//總數-1

        if(referrer!=address(0))
        {
            Referral_reward[referrer] = Referral_reward[referrer].add(REWARD);//推薦獎勵 +20 BUSD
            R_num[referrer] = R_num[referrer].add(1);// 推薦人數+1
        }

        return true;
    }
    //堤推薦獎勵
    function withdraw_reward() public{
        uint256 reward_balance = Referral_reward[msg.sender];
        require(reward_balance > 0 ,"Insufficient balance");
        BUSD.transfer(msg.sender, reward_balance*1*10**18);

        Referral_reward[msg.sender] = Referral_reward[msg.sender].sub(reward_balance);
        
        //emit _withdraw(msg.sender, contract_balance, now);
    }

    //堤幣
    function withdraw() public onlyOwner{
        address contract_addr = address(this);
        uint256 contract_balance = BUSD.balanceOf(contract_addr);
        BUSD.transfer(msg.sender, contract_balance);
        
        //emit _withdraw(msg.sender, contract_balance, now);
    }

}