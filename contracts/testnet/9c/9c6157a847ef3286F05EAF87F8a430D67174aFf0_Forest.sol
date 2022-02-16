/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

//SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.0;

pragma experimental ABIEncoderV2;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
  */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
   */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}


contract Forest {

   using SafeMath for uint256;

    //fost合约
    address internal constant FostToken = 0x138f8139d1D554F77628f223884BaA02768501d4;
    //kft合约
    address internal constant KftToken = 0xa1FEDb033e4b79041c3125c604D5452714411417;
    //fost接收地址
    address internal constant fostAddress = 0xeE96DaA8000c4F87D9E2D108FEB4a467B45Be605;
    //kft接收地址
    address internal constant kftAddress = 0xe8BcE29d92121c5B658fe2283a03647fC396Ac1f;
    //kft质押数量
    uint256 internal constant KFT_AMOUNT = 2000000000000000000000;

    address internal constant UNISWAP_FACTORY_ADDRESS = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    address internal constant USDT_TOKEN = 0x55d398326f99059fF775485246999027B3197955;

    IBEP20 public fostToken;

    IBEP20 public kftToken;

    IUniswapV2Factory public uniswapFactory;

    constructor () {
       fostToken = IBEP20(FostToken);
       kftToken = IBEP20(KftToken);
       uniswapFactory = IUniswapV2Factory(UNISWAP_FACTORY_ADDRESS);
    }

    //forest players info
    struct Personal{
        //0: ordinary 1: node
        uint  level;
        //状态 0: inactivated 1：activated
        uint  status;
        //forest player
        address king;
        //forest player parent
        address kingParent;
        address[] child;
        //contribution
        uint256 contribution;
        //direct contribution
        uint256 directContribution;
        //indirect contribution
        uint256 indirectContribution;
        //node contribution
        uint256 nodeContribution;
        //额外贡献值.
        uint256 extraContribution;
        //LP池当前所属档次 0:无档次
        uint  gear;
        //时间戳.
        uint time;
    }

    struct Child{
        address addr;
        uint time;
    }

    //players assets
    struct Balance{
        //0: KFT 1: FOST 2: USDT
        uint  blanceType;

        uint  amount;
    }

    address public owner;

    //每天固定释放量.
    uint256 constant private RELEASES_COUNT = 16666;

    //所有地址集合.
    address[] public addresses;

    //声明一个balance数组.
    Balance[] public balances;

    //fost质押.
    struct FostPledge{
        uint pledgeAmount;
        uint dirAmount;
        uint indirAmount;
    }

    //kft质押.
    struct KftPledge{
        //节点奖励
        uint amount;
        //平级奖励
        uint sameAmount;
        //释放时间.
        uint realseTime;
    }

    mapping(address => FostPledge) public fostPledgeMap;

    mapping(address => KftPledge) public kftPledgeMap;

    mapping(address => Balance[]) public balancesArry;

    mapping(address => Personal) public personalMap;

    mapping(address => Child[]) public childMap;

    //获取直推列表详情.
    function getDirectList(address addr) public view returns(Child[] memory ){
        return childMap[addr];
    }

    //计算团队能量值.
    function getTeamPowers(address addr, uint totalPowers) public view returns(uint){
        Personal memory p =  personalMap[addr];

        address[] memory childs = p.child;

        for(uint i = 0; i < childs.length; i++){
            Personal memory child =  personalMap[childs[i]];
            if(child.status == 1){
                uint totalContri = calPersonalContri(childs[i]);
                totalPowers = totalPowers.add(totalContri);
                totalPowers = getTeamPowers(childs[i], totalPowers);
            }
        }
        return totalPowers;
    }

    //获取系统总质押.
    function getSystemPlege() public view returns(uint, uint){
        uint len = addresses.length;
        uint kftPledgeAmount = 0;
        uint fostPledgeAmount = 1199000000000000000000000;
        for(uint i =0 ; i < len; i++){
           KftPledge storage kft = kftPledgeMap[addresses[i]];
           if(kft.realseTime > 0){
               kftPledgeAmount = kftPledgeAmount.add(2000);
           }
           FostPledge storage fost = fostPledgeMap[addresses[i]];
           if(fost.pledgeAmount > 0){
               fostPledgeAmount = fostPledgeAmount.add(fost.pledgeAmount);
           }
        }
        return (kftPledgeAmount, fostPledgeAmount);
    }

    struct ExchangeLog{
        uint time;
        uint kftAmount;
        uint uAmount;
    }

    mapping(address => ExchangeLog[]) exchangeLogsMap;

    //获取记录.
    function getExchangeLog(address addr) public view returns(ExchangeLog[] memory){
        return exchangeLogsMap[addr];
    }

    //兑换记录.
    function exchange(address addr, uint kftAmount, uint uAmount) public returns(bool){
        ExchangeLog[] storage ex = exchangeLogsMap[addr];
        ex.push(ExchangeLog(block.timestamp, kftAmount, uAmount));
        return true;
    }

    //获取总质押.
    function getPlegeAmount(address addr) public view returns(KftPledge memory, FostPledge memory){
        return(kftPledgeMap[addr], fostPledgeMap[addr]);
    }

    //kft质押.
    function kftPledge(address addr) public returns(bool){
        //锁仓30天.
        KftPledge storage kft = kftPledgeMap[addr];
        require(kft.realseTime < block.timestamp, "kft is pledgeing");

        //kft质押数量转入.
        bool isSuccess = kftToken.transferFrom(addr, kftAddress, KFT_AMOUNT);
        require(isSuccess, "transferFrom fail, please approve first");

        //2592000
        kft.realseTime = block.timestamp.add(2592000);
        Personal storage p =  personalMap[addr];
        p.level = 1;
        return true;
    }

    //kft质押赎回.
    function kftPledgeRemove(address addr) public returns(bool){
        KftPledge storage kft = kftPledgeMap[addr];
        require(kft.realseTime <= block.timestamp, "Redemption time has not come");

        //退回KFT.
        bool isSuccess = kftToken.transferFrom(kftAddress, addr, KFT_AMOUNT);
        require(isSuccess, "transferFrom fail");

        Personal storage p =  personalMap[addr];
        p.nodeContribution = 0;
        p.level = 0;

        kft.amount = 0;
        kft.sameAmount = 0;
        kft.realseTime  = 0;
        return true;
    }

    function getPowersFromLevel(uint level) public pure returns(uint){
        if(level == 1){
            return 200;
        }else if(level == 2){
            return 600;
        }else if(level == 3){
            return 1000;
        }else if(level == 4){
            return 2000;
        }else if(level == 5){
            return 3000;
        }
        return 0;
    }

    function getPrice() public view returns(uint, uint){
        address factory = uniswapFactory.getPair(0x138f8139d1D554F77628f223884BaA02768501d4, USDT_TOKEN);
        IUniswapV2Pair pair = IUniswapV2Pair(factory);
        uint112 reserveA = 0;
        uint112 reserveB = 0;
        uint32 blockTimestampLast = 0;
        (reserveA, reserveB, blockTimestampLast) = pair.getReserves();
        return(reserveA, reserveB);
    }

    //fost质押.
    function fostPledge(address addr, uint level) public returns(bool){
        require(level > 0 && level < 6, "level is error");
        
        Personal storage p =  personalMap[addr];
        //获取能量.
        uint powers = getPowersFromLevel(level);
        require(p.contribution.add(powers) <= 3000, "Maximum pledge 300U");
        
        //获取价格
        uint256 reserveA = 0;
        uint256 reserveB = 0;
        (reserveA, reserveB) = getPrice();
        uint amount = (powers*1000000000000000000*1000000000000000000 / ((reserveB*1000000000000000000)/reserveA));

        //质押数量转入
        bool isSuccess = fostToken.transferFrom(addr, fostAddress, amount);
        require(isSuccess, "transferFrom fail, please approve first");

        //个人能量值增加.
        uint myContri = p.contribution.add(powers);
        
        p.contribution = myContri;
        //计算总能量值.
        FostPledge storage fost = fostPledgeMap[addr];
        uint pledgeAmount = fost.pledgeAmount.add(amount);
        fost.pledgeAmount = pledgeAmount;
        if(p.gear < level){
            p.gear = level;
        }
        bool isPass = calLevel(myContri);
        if(isPass){
            //直推奖励.
            Personal storage pre =  personalMap[p.kingParent];
            if(pre.status == 1 && pre.gear > 0){
                uint dirReward = powers * 1/10;
                pre.directContribution = pre.directContribution.add(dirReward);
                fost.dirAmount += dirReward;
            }
            //间推奖励.
            Personal storage ppre =  personalMap[pre.kingParent];
            if(ppre.status == 1 && ppre.gear > 0){          
                uint indirReward = powers * 8/100;
                ppre.indirectContribution = ppre.indirectContribution.add(indirReward);
                fost.indirAmount += indirReward;
            }
        }

        return true;
    }

    function calLevel(uint256 contri) public view returns(bool){
        uint256 addressCount = addresses.length;
        if(addressCount > 500 && contri < 600){
            return false;
        }else if(addressCount > 2000 && contri <1000){
            return false;
        }else if(addressCount > 10000 && contri <2000){
            return false;
        }else if(addressCount > 30000 && contri <3000){
            return false;
        }
        return true;
    }

    

    //fost赎回.
    function fostPledgeRemove(address addr) public returns(bool){
        FostPledge storage fp = fostPledgeMap[addr];
        require(fp.pledgeAmount > 0, "Please pledge first");
        //回退fost.
        bool isSuccess = fostToken.transferFrom(fostAddress, addr, fp.pledgeAmount);
        require(isSuccess, "transferFrom fail");

        //移除之后直推间推也消失.

        //质押级别回退.
        Personal storage p =  personalMap[addr];
        p.gear = 0;
        p.contribution = 0;
        p = personalMap[addr];
        p.directContribution = 0;
        p.indirectContribution = 0;
        p.nodeContribution = 0;

        //直推奖励回退.
        Personal storage pre =  personalMap[p.kingParent];
        if(fp.dirAmount > 0){
            if(pre.directContribution >= fp.dirAmount){
                pre.directContribution = pre.directContribution.sub(fp.dirAmount);
            }
        }
        if(fp.dirAmount > 0){
            //间推奖励回退.
            Personal storage ppre =  personalMap[pre.kingParent];
            if(ppre.indirectContribution >= fp.indirAmount){
                ppre.indirectContribution = ppre.indirectContribution.sub(fp.indirAmount);
            }
        }

        fp.pledgeAmount  = 0;
        fp.dirAmount = 0;
        fp.indirAmount = 0;
        return true;
    }

    //计算个人总贡献值.
    function calPersonalContri(address addr) public view returns(uint){
        Personal storage ps =  personalMap[addr];
        uint256 cb = ps.contribution + ps.directContribution + ps.indirectContribution + ps.nodeContribution + ps.extraContribution;
        return cb;
    }

    struct DirectPerson{
        address sender;
        uint time;
    }

    struct Home{
        uint totalContri;
        uint addressesCount;
        uint totalKft;
    }

    //首页信息.
    function homeInfo() public view returns(Home memory){
        //总贡献值.
        uint totalContri =  calTotalContribute();

        //持有地址总数.
        uint totalKft = 0;

        //流通KFT
        for(uint i = 0; i < addresses.length; i++){
            Balance[] memory bs = balancesArry[addresses[i]];
            for(uint j = 0; j < 3; j++){
                Balance memory b = bs[j];
                if(b.blanceType == 0){
                    if(b.amount > 0){
                        totalKft = totalKft.add(b.amount);
                    }
                }
            }
        }
        return Home(totalContri, addresses.length, totalKft);
    }

    //提币信息.
    struct Winthdraw{
        address addr;
        uint amount;
        uint time;
    }

    Winthdraw[] public wihtdraws;

    mapping(address => Winthdraw[]) public withdrawMap;

    function withdrawInfo(address addr, uint amount) public returns(bool){
        bool isSuccess = kftToken.transferFrom(addr, kftAddress, amount);
        require(isSuccess, "transferFrom fail");
        Balance[] storage bl = balancesArry[addr];
        for(uint i =  0; i < bl.length; i++){
            Balance storage  b = bl[i];
            if(b.blanceType  == 0 && b.amount >= amount){
                uint remain = b.amount - amount;
                b.amount = remain;
                Winthdraw[] storage wis = withdrawMap[addr];
                wis.push(Winthdraw(addr, amount, block.timestamp));
            }else{
                return false;
            }
        }
        return true;
    }

    function withdrawLog(address addr) public view returns(Winthdraw[] memory){
        Winthdraw[] storage w = withdrawMap[addr];
        return w;
    }


    //KFT奖励池 已提取.
     function withdrawed(address addr) public view returns(uint){
        Winthdraw[] storage w = withdrawMap[addr];
        uint amount = 0;
        for(uint i = 0; i < w.length; i++){
            amount = amount.add(w[i].amount);
        }
        return amount;
    }

    event ActiveInfo(
        address parent,
        address own
    );

    //激活.0.
    function active(address kingParent, address forestAddr) public returns(bool){
        require(kingParent != address(0), "please enter the parent address.");

        Personal storage sender = personalMap[forestAddr];

        require(sender.status < 1, "address is already active");

        // address forestAddr = msg.sender;
        // Personal memory p = personalMap[forestAddr];
        // require(p.king != address(0), "address is already exists");

        //添加到所有地址.
        addresses.push(forestAddr);

        Personal storage parent = personalMap[kingParent];

        address[] memory child;


        uint time = block.timestamp;
        //加入到子节点.
        parent.child.push(forestAddr);
        Child[] storage _child = childMap[parent.king];
        _child.push(Child(forestAddr, time));

        //初始化用户信息.
        personalMap[forestAddr] = Personal(0, 1, forestAddr, kingParent, child, 0, 0, 0, 0, 0, 0, time);

        //初始化balance
        balances.push(Balance({blanceType: 0, amount: 0}));
        balances.push(Balance({blanceType: 1, amount: 0}));
        balances.push(Balance({blanceType: 2, amount: 0}));
        balancesArry[forestAddr] = balances;

        emit ActiveInfo(kingParent, forestAddr);
        return true;
    }

    //计算平台总贡献值.
    function calTotalContribute() public view returns (uint256){
        uint length = addresses.length;
        uint amount = 0;
        for(uint i = 0; i < length; i++){
            //获取钱包信息.
            Personal storage ps = personalMap[addresses[i]];
            if(ps.status == 1){
                uint total = calPersonalContri(ps.king);
                amount += total;
            }

        }
        return amount;
    }

    //个人信息.
    function personalInfo() public view returns(Personal memory _ps){
        Personal storage info =  personalMap[msg.sender];
        return info;
    }

    function getBalance(address addr) public view returns(Balance[] memory b){
        Balance[] storage bl = balancesArry[addr];
        return bl;
    }

    //个人信息.
    function getPersonalInfo(address addr) public view returns(Personal memory _ps){
        Personal storage info =  personalMap[addr];
        return info;
    }

    //获取当前级别.
    function getAddrLevel(uint len) public pure returns(uint){
        uint level = 1;
        if(len > 30000){
            level = 5;
        }else if(level > 10000){
            level = 4;
        }else if(level > 2000){
            level = 3;
        }else if(level > 500){
            level = 2;
        }
        return level;
    }

    struct BalanceLog{
        uint amount;
        uint logType;
        uint time;
    }

    mapping(address => BalanceLog[]) logMap;

    function getLog(address addr) public view returns(BalanceLog[] memory){
        return logMap[addr];
    }

    address taskAddress = 0xDF1536D73C05B75330f6CA88CE4CDC254C66f130;

    function task() public returns (bool) {

        address sender = msg.sender;

        require(sender == taskAddress, "billing prohibited");

        uint length = addresses.length;
        //将所有节点奖励置为0.
        for(uint i = 0; i < length; i++){
            //获取钱包信息.
            Personal storage ps = personalMap[addresses[i]];
            ps.nodeContribution = 0;
            ps.extraContribution = 0;
        }
        //计算节点奖励.
        for(uint i = 0; i < length; i++){
            address addr = addresses[i];
            //获取钱包信息.
            Personal storage ps = personalMap[addresses[i]];
            if(ps.status == 1 && ps.level == 1){
                //计算团队总贡献值.
                KftPledge storage kft = kftPledgeMap[addr];
                uint totalPowers = getTeamPowers(addr, 0);
                if(totalPowers > 0){
                    uint nodeReward = totalPowers * 9/100;

                    kft.amount = kft.amount.add(nodeReward);

                    ps.nodeContribution = ps.nodeContribution.add(nodeReward);

                    //平级奖.
                    Personal storage pre =  personalMap[ps.kingParent];
                    if(pre.level == 1){
                        uint sameAmount = nodeReward * 1/5;

                        kft.sameAmount = sameAmount;
                        pre.nodeContribution = pre.nodeContribution.add(sameAmount);
                    }
                }
            }
        }

        //计算额外奖励.
        for(uint i = 0; i < length; i++){
            //获取钱包信息.
            Personal storage ps = personalMap[addresses[i]];
            if(ps.status == 1){
                Balance[] storage bs = balancesArry[addresses[i]];

                uint kftAmount = 0;

                for(uint j = 0; j < bs.length; j++){
                    if(bs[j].blanceType == 0){
                        kftAmount = bs[j].amount;
                        break;
                    }
                }
                //计算额外奖励.
                if(kftAmount >= 100){
                    uint extra = ps.contribution + ps.directContribution + ps.indirectContribution + ps.nodeContribution;
                    uint extraAmout = extra * 1/5;
                    ps.extraContribution = extraAmout;
                }

            }

        }

        uint256 totalContribute = calTotalContribute();
        for(uint i = 0; i < length; i++){
              //获取钱包信息.
            Personal storage ps = personalMap[addresses[i]];
            if(ps.status == 1){
                Balance[] storage bs = balancesArry[addresses[i]];

                uint level = getAddrLevel(length);
                uint cb = 0;
                if(level < ps.gear){
                    //只能拿自己的静态奖励.
                     cb = ps.contribution + ps.nodeContribution;
                 }else{
                    //计算个人总贡献值.
                    cb = calPersonalContri(ps.king);
                }


                 if(cb > 0){
                     //结算.
                    uint256 result =   (cb * 1000000000000000000).div(totalContribute);
                    //奖励.
                    uint256 reward = result * RELEASES_COUNT;

                    for(uint j = 0; j < bs.length; j++){
                        if(bs[j].blanceType == 0){
                            bs[j].amount = bs[j].amount + reward;
                            //log保存.
                            BalanceLog[] storage logs = logMap[addresses[i]];
                            logs.push(BalanceLog(reward, 0, block.timestamp));
                            break;
                        }
                    }

                }
            }
        }
        return true;
    }


}