/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

// File: contract\Math.sol

pragma solidity ^0.8.0;

library SafeMath {

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

// File: contract\IERC20.sol

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function decimals()  view external returns (uint8);

    function mint(address dst, uint256 amt) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);


}

// File: contract\Owner.sol

pragma solidity ^0.8.0;


contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

// File: contract\IMaxFactory.sol

interface IMdexFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function feeToRate() external view returns (uint256);

    function initCodeHash() external view returns (bytes32);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function setFeeToRate(uint256) external;

    function setInitCodeHash(bytes32) external;

    function sortTokens(address tokenA, address tokenB) external pure returns (address token0, address token1);

    function pairFor(address tokenA, address tokenB) external view returns (address pair);

    function getReserves(address tokenA, address tokenB) external view returns (uint256 reserveA, uint256 reserveB);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountOut);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// File: contract\Pool.sol

pragma solidity ^0.8.0;
// import "hardhat/console.sol";
abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IPool{

    function getUser(address a) external view returns(bool partake,uint256 levelNumber);
    function getMonthInviter(address a) external view   returns (uint256 number,uint256 pow,uint256 finalPow);
    function getFeeAddress () external view returns (address);
}

contract Pool is Context,Ownable,IPool {
    using SafeMath for uint256;

    IERC20 public FEtoken;

    address public pairContract;

    address[] public pairPath;

    uint256 public FEDecimal=8;

    uint256 public maxAmount =0;
    uint256 public feAmount=0;
    uint256 public profitTotal=0;
    uint256 public powerTotal=0;
    address public feeAddress;

    uint256 public airdrop_;
    uint256 public totalNumber;
    uint256 public airdropTotal;

    uint256 public price = 1e18;

    uint256 public blockTotal = 28800; //todo 28800
    uint256 public baseNumber_= 124; //todo 124

    struct UserInfo {
        uint256 fbAmount;
        uint256 initBlockNumber;
        uint256 startBlockNumber;
        uint256 profitTotal;
        uint256 profit;
        uint256 teamProfit;
        uint256 teamProfitTotal;
        uint256 airdrop;
        uint256 initPower;
        uint256 harvestTimes;
        uint256 inviteNumber;
        uint256 maxPower;
        bool partake ;
    }

    struct Inviter{
        address account;
        uint256 inviteBlockNumber;
        uint256 inviteTimestamp;
        uint256 rate;
    }

    struct claimInfo {
        uint256 serialNumber;
        uint256 times;
        uint256 nextBlockNumber;
    }

    mapping(address => address ) inviter;
    mapping(address => UserInfo) user;
    mapping(address => Inviter[]) memberInviter;
    mapping(uint256 => uint256) parentOneRate;
     mapping(uint256 => uint256) parentTRate;

    event airdropReceive(address a,uint256 number);
    event depositProfit(address a,uint256 feNumber);
    event memberInvite(address u,address b,uint256 rate,uint256 profit);
    event drawProfitNumber(address a,uint256 number,uint256 losePower);
    event powerReBoot(address a,uint256 power);

    constructor() public {
       init();
    }

    function setPair(address pairAddress,address[] memory path) public onlyOwner{
        pairContract = pairAddress;
        pairPath = path;
    }

    function setFeeAddress(address a) public onlyOwner{
        feeAddress = a;
    }

    function getFeeAddress () public override view returns (address){
        return feeAddress;
    }

    function getTotalAmount() public view returns(uint256){
        return totalNumber;
    }

    function getInviter(address a) public view returns (address){
        return inviter[a];
    }

    function setFEToken (IERC20 _feToken) public onlyOwner {
        FEtoken = _feToken;
         FEDecimal = 10** _feToken.decimals();
          airdrop_ = 100 * FEDecimal;
       maxAmount = 50000 * FEDecimal;
    }

    function init() private {
        parentOneRate[1] =10;
        parentOneRate[2] = 20;
        parentOneRate[3] = 25;
        parentOneRate[4] = 30;
        parentOneRate[5] = 35;
        parentOneRate[6] = 40;
        parentTRate[1] = 0;
        parentTRate[2] = 6;
        parentTRate[3] = 7;
        parentTRate[4] = 8;
        parentTRate[5] = 9;
        parentTRate[6] = 10;
    }


    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {size := extcodesize(addr)}
        return size > 0;
    }

    function receiveAirDrop() public {
        require(!isContract(msg.sender), 'Address: call from contract');
        UserInfo storage user = user[msg.sender];
        require(user.airdrop==0);
        user.airdrop = airdrop_;
        powerTotal = powerTotal.add(airdrop_);
        airdropTotal = airdropTotal.add(airdrop_);
        user.initPower = user.initPower.add(airdrop_);
        if(user.initPower>user.maxPower){user.maxPower=user.initPower;}
        user.partake = true;
        emit airdropReceive(msg.sender,airdrop_);
    }

    function addMemberInviter(address _inviter) public {
        require(!isContract(msg.sender), 'Address: call from contract');
        address parent = inviter[msg.sender];
        if(parent == address(0) && _inviter != msg.sender){
            inviter[msg.sender] = _inviter;
            UserInfo storage user = user[_inviter];
            (,uint256 levle) = level(user.initPower);
            uint256 baseRate =0;

            if(levle ==2){
                baseRate = 20;
            } else if(levle ==3){
                baseRate = 25;
            } else if(levle ==4){
                baseRate = 30;
            } else if(levle ==5){
                baseRate = 40;
            } else if(levle ==6){
                baseRate = 50;
            }

            Inviter memory invit = Inviter(msg.sender,block.number,block.timestamp,baseRate);
            addMemberInviter(_inviter,invit);

            user.inviteNumber = user.inviteNumber.add(1);
        }
    }

    function addMemberInviter(address _inviter, Inviter memory invit) private {
    if (memberInviter[_inviter].length > 0 && memberInviter[_inviter].length < 100) {
        memberInviter[_inviter].push(invit);
        // console.log("inviter %s",invit.account);
    } else {
        if (memberInviter[_inviter].length >= 100) {
            delete memberInviter[_inviter][0];
            for (uint256 i = 0; i < memberInviter[_inviter].length - 1; i++) {
                memberInviter[_inviter][i] = memberInviter[_inviter][i + 1];
            }
            memberInviter[_inviter].pop();
        }
         memberInviter[_inviter].push(invit);
        //  console.log("inviter %s",invit.account);
    }
}

    //
    function deposit(address inviter_ ,uint256 feNumber) public {

        require(FEtoken.balanceOf(msg.sender)>= feNumber,"Insufficient Balance");
        UserInfo storage user_ = user[msg.sender];
         require(user_.initPower <= maxAmount,"power is max");

         (uint256 profit_,uint256 total,) = getUserProfit(msg.sender);
         if(profit_ >0){
            (,,uint256 finalTotal_) = nextClaimBlock(msg.sender);
             FEtoken.mint(msg.sender,profit_);
             user_.profitTotal =  user_.profitTotal.add(profit_);
             if(user_.initPower >= profit_){
                user_.initPower = user_.initPower.sub(profit_);
             }else{
                 user_.initPower = 0;
             }

             user_.harvestTimes = finalTotal_+1;
         }

          (,uint256 level_) = level(user_.initPower);


         uint256 fepower = feNumber.mul(3);
         uint256 power_=0;

         if(fepower.add(user_.initPower) > maxAmount){
            uint256 power = maxAmount.sub(user_.initPower);
            feNumber = power.div(3);
            FEtoken.transferFrom(msg.sender,address(1),feNumber);
             user_.initPower = user_.initPower.add(power);
             if(user_.initPower>user_.maxPower){user_.maxPower=user_.initPower;}
             power_ = power;
         }else{
            FEtoken.transferFrom(msg.sender,address(1),feNumber);
            user_.initPower = user_.initPower.add(fepower);
            if(user_.initPower>user_.maxPower){user_.maxPower=user_.initPower;}
             power_ = fepower;
         }
         if(user_.initBlockNumber ==0){
             user_.initBlockNumber = block.number;
         }

         if(level_==1){
              user_.initBlockNumber = block.number;
          }
         user_.partake = true;
         user_.startBlockNumber = block.number;
         user_.fbAmount = user_.fbAmount.add(feNumber);

         powerTotal = powerTotal.add(power_);

         addInviterProfit(msg.sender,feNumber);

        feAmount = feAmount.add(feNumber);

        (,uint256 level2) = level(user_.initPower);

        address parent_ = inviter[msg.sender];

        if(parent_!=address(0)){
             UserInfo memory  parentUser = user[parent_];
          (,uint256 level3) = level(parentUser.initPower);
          if(level2>=2 && level3 >=2){
            Inviter[] storage arr = memberInviter[parent_];
            for(uint256 index_ =0;index_ < arr.length;index_++ ){
                    Inviter storage invitP_ = arr[index_];
                    if(invitP_.account == msg.sender && invitP_.rate == 0){
                         if(level3 ==2){
                            invitP_.rate = 20;
                        } else if(level3 ==3){
                            invitP_.rate = 25;
                        } else if(level3 ==4){
                            invitP_.rate = 30;
                        } else if(level3 ==5){
                            invitP_.rate = 40;
                        } else if(level3 ==6){
                            invitP_.rate = 50;
                        }
                         invitP_.inviteBlockNumber= block.number;
                    }
            }
          }
        }

         Inviter[] storage arr2 = memberInviter[msg.sender];
        for(uint256 index_ =0;index_ < arr2.length;index_++ ){
                    Inviter storage invitP_ = arr2[index_];
                    if(invitP_.rate == 0 && level2 >=2){
                        UserInfo memory  cuser_ = user[invitP_.account];
                         (,uint256 level3) = level(cuser_.initPower);
                         if(level3>=2){
                            if(level2 ==2){
                                invitP_.rate = 20;
                            } else if(level2 ==3){
                                invitP_.rate = 25;
                            } else if(level2 ==4){
                                invitP_.rate = 30;
                            } else if(level2 ==5){
                                invitP_.rate = 40;
                            } else if(level2 ==6){
                                invitP_.rate = 50;
                            }
                            invitP_.inviteBlockNumber= block.number;
                         }


                    }
            }


        emit depositProfit(msg.sender,feNumber);
    }


    function addInviterProfit(address _account,uint256 number) private {
         address parent1 = inviter[_account];

         if(parent1 !=address(0)){
            UserInfo storage userp1 = user[parent1];
            (,uint256 level_) = level(userp1.initPower);
            uint256 profitRate = getLevelProfit (level_,1);

            if(profitRate!=0){
                uint256 profit_ = profitRate.mul(number).div(1000);

                if(userp1.initPower>= profit_){
                    FEtoken.mint(parent1,profit_);
                    // userp1.teamProfit = userp1.teamProfit.add(profit_);
                    userp1.initPower = userp1.initPower.sub(profit_);
                    userp1.profitTotal = userp1.profitTotal.add(profit_);
                    userp1.teamProfitTotal = userp1.teamProfitTotal.add(profit_);
                    profitTotal = profitTotal.add(profit_);
                    emit memberInvite(_account,parent1,profitRate,profit_);
                    if(powerTotal >profit_ ){
                        powerTotal = powerTotal.sub(profit_);
                    }else{
                        powerTotal =0;
                    }

                }else{
                    uint256 n = userp1.initPower;
                    //userp1.teamProfit = userp1.teamProfit.add(n);
                    FEtoken.mint(parent1,n);
                    userp1.initPower = 0;
                      profitTotal = profitTotal.add(n);
                    userp1.profitTotal = userp1.profitTotal.add(n);
                    userp1.teamProfitTotal = userp1.teamProfitTotal.add(n);
                    if(powerTotal > n) {
                        powerTotal = powerTotal.sub(n);
                    }else{
                        powerTotal = 0;
                    }

                    emit memberInvite(_account,parent1,profitRate,n);
                }
            }

            address parent2 = inviter[parent1];
            if(parent2 !=address(0)){
                UserInfo storage userp2 = user[parent2];
                (,uint256 level2_) = level(userp2.initPower);
                uint256 profitRate2 = getLevelProfit (level2_,2);
                if(profitRate2!=0){
                    uint256 profit2_ = profitRate2.mul(number).div(1000);
                    if(userp2.initPower>= profit2_){
                        FEtoken.mint(parent2,profit2_);
                          profitTotal = profitTotal.add(profit2_);
                        // userp2.teamProfit = userp2.teamProfit.add(profit2_);
                        userp2.initPower = userp2.initPower.sub(profit2_);
                        userp2.profitTotal = userp2.profitTotal.add(profit2_);
                        userp2.teamProfitTotal = userp2.teamProfitTotal.add(profit2_);
                        emit memberInvite(_account,parent2,profitRate2,profit2_);

                         if(powerTotal >profit2_ ){
                            powerTotal = powerTotal.sub(profit2_);
                        }else{
                            powerTotal =0;
                        }
                    }else{
                         uint256 n = userp2.initPower;
                          FEtoken.mint(parent2,n);
                          profitTotal = profitTotal.add(n);
                           userp2.profitTotal = userp2.profitTotal.add(n);
                        userp2.teamProfitTotal = userp2.teamProfitTotal.add(n);
                      // userp2.teamProfit = userp2.teamProfit.add(n);
                        userp2.initPower = 0;
                        emit memberInvite(_account,parent2,profitRate2,n);

                         if(powerTotal > n) {
                            powerTotal = powerTotal.sub(n);
                        }else{
                            powerTotal = 0;
                        }
                    }
                }
            }
         }
    }

    function getLevelProfit(uint256 level,uint256 p) private view returns (uint256 rate){
        if(p==1){
            return parentOneRate[level];
        }else if(p==2){
            return parentTRate[level];
        }
        return 0;
    }

    function level(uint256 _power) public view returns (uint256 rate,uint256 level){
        if(_power >= 20000 * FEDecimal){
            return (65,6);
        }else if(_power >= 10000 * FEDecimal){
            return (60,5);
        }else if(_power >= 5000 * FEDecimal){
            return (55,4);
        }else if(_power >= 2000 * FEDecimal){
            return (50,3);
        }else if(_power >= 500 * FEDecimal){
            return (45,2);
        }else if(_power > 0 * FEDecimal){
            return (0,1);
        }else {
            return (0,0);
        }
    }



     function  nextClaimBlock(address memberAddress) public view
       returns(uint256 blockNumber,uint256 claimTotal,uint256 finalClaim) {
             UserInfo memory user = user[memberAddress];
             uint256 num = (block.number.sub(user.initBlockNumber)).div(blockTotal);
             uint256 days_ = blockTotal;
             uint256 interval =0;
             uint claimCount=0;
             uint finalClaim_=0;
             if(num > 420){
                 num = 420;
             }
             if(num==0){
                 num =1;
             }
             uint256 newBlock_=0;
             for(uint256 d =0; d< num;d++){
                 if(d!=0){
                    days_ = days_.add(baseNumber_);
                 }
                 if(interval.add(days_).add(user.initBlockNumber) > block.number){
                     break;
                 }
                 interval = interval.add(days_);
                 if(user.initBlockNumber.add(interval)<= block.number){
                     if(claimCount <= user.harvestTimes + 6 ){
                         claimCount++;
                        newBlock_ = user.initBlockNumber+interval;
                    }
                     finalClaim_++;
                 }

             }

             return (newBlock_,claimCount,finalClaim_);
     }

     function getUserProfit(address memberAddress) public view
        returns(uint256 profit,uint256 claimNumber,uint256 blockNumber){
             UserInfo memory user_ = user[memberAddress];
             if(user_.initBlockNumber ==0){
                 return (0,0,0);
             }
             (uint256 nextBlockNumber,uint256 total,) = nextClaimBlock(memberAddress);
             uint256 profitTotal_ = 0;
             (uint256 rate,) = level(user_.initPower);
             for(uint256 i=  user_.harvestTimes;i<total;i++){
                 uint256 prof = user_.initPower.mul(rate).div(10000);
                 profitTotal_ = profitTotal_.add(prof);
             }
            return (profitTotal_,total,nextBlockNumber);
        }

    function drawProfit() public {
        UserInfo storage user_ = user[msg.sender];
         (uint256 nextBlockNumber,uint256 total,uint256 finalTotal) = nextClaimBlock(msg.sender);
         require(nextBlockNumber<=block.number && total>0 ,"claim time is out");
         require(user_.initPower>=user_.maxPower.mul(95).div(100) ,"Less than 95%");

        (uint256 profit,uint256 claimNumber,uint256 blockNumber) = getUserProfit(msg.sender);
        uint256 profitTotal_ = profit.add(user_.profit).add(user_.teamProfit);
        require(profitTotal_>0);

        user_.profitTotal = user_.profitTotal.add(profitTotal_);
        user_.teamProfitTotal = user_.teamProfitTotal.add(user_.teamProfit);
        user_.teamProfit =0;
        user_.profit = 0;
        user_.harvestTimes = finalTotal+1;

        totalNumber = totalNumber.add(profitTotal_);
        FEtoken.mint(msg.sender,profitTotal_);
         profitTotal = profitTotal.add(profitTotal_);
        if(user_.initPower > profit){
            user_.initPower = user_.initPower.sub(profit);
        }else{
            user_.initPower = 0;
        }

         if(powerTotal > profit){
            powerTotal = powerTotal.sub(profit);
        }
        emit drawProfitNumber(msg.sender,profitTotal_,profit);
    }

    function reBootPower() public {

             UserInfo storage user_ = user[msg.sender];
              (uint256 nextBlockNumber,uint256 total,) = nextClaimBlock(msg.sender);
             require(user_.harvestTimes < total,"Not extracted");

            uint256 consumeNumber = rebootConsume(msg.sender);
            user_.initPower = user_.initPower.sub(consumeNumber);
            user_.initBlockNumber = block.number;
            user_.harvestTimes = 0;
            user_.maxPower = 0;
            powerTotal = powerTotal.sub(consumeNumber);
        emit powerReBoot(msg.sender,consumeNumber);
    }

    function rebootConsume(address a) public view returns(uint256 power){
         UserInfo memory user_ = user[a];
         uint256 num = (block.number-user_.initBlockNumber)/blockTotal;
         uint256 decay = ((23 * num)  * user_.initPower) /10000;
         if(decay > user_.initPower.mul(90).div(100)){
                decay = user_.initPower.mul(10).div(100);
         }
        return decay;
    }


    function getUserInviters(address a) public view returns (Inviter[] memory invit){
        return memberInviter[a];
    }

    function getUserPower(address a) public view returns(UserInfo memory member,uint256 levelNumber){
       (uint256 rate,uint256 levle) = level(user[a].initPower);
        return (user[a],levle);
    }

    function getUser(address a) public override  view returns(bool partake,uint256 levelNumber){
        (uint256 rate,uint256 levle) = level(user[a].initPower);
        return (user[a].partake,levle);
    }

    function getMonthInviter (address a) public override view
        returns (uint256 number,uint256 pow,uint256 finalPow){
       Inviter[] memory array = memberInviter[a];
       (uint256 rate,uint256 levle) = level(user[a].initPower);

       if(levle ==0){
           return (0,0,0);
       }

       uint256 startBlock = block.number;
       if(array.length > 0){
           for(uint256 i =0;i<array.length;i++){
               Inviter memory viter = array[i];
                uint invitNum = viter.inviteBlockNumber;
                 UserInfo memory user_ = user[viter.account];
                (uint256 rate,uint256 levle_) = level(user_.initPower);
               if( levle_ >= 2 || user_.fbAmount >=( 167 * FEDecimal)){
                   startBlock = array[i].inviteBlockNumber;
                   break;
               }
           }
       }
       uint256 pow_ =0;
//       uint256 num = (block.number.sub(startBlock)).div(uint256(5).mul(blockTotal)); //todo 30
        uint256 num = (block.number.sub(startBlock)).div(uint256(30).mul(blockTotal)); //todo 30
       for(uint256 index =0;index <= num;index++){
           if(pow_ >= 20){
               pow_ = pow_.sub(20);
           }else{

               pow_ = 0;
           }
           uint256 endBlockNum = startBlock.add(uint256(5).mul(blockTotal));
           uint256 count_=0;
           uint256 current =0;
           for(uint256 i=0;i<array.length;i++){
                Inviter memory viter = array[i];
                uint invitNum = viter.inviteBlockNumber;
                 UserInfo memory user_ = user[viter.account];
                (uint256 rate,uint256 levle) = level(user_.initPower);
                if( (levle >=2 || user_.fbAmount >=( 167 * FEDecimal))&& invitNum>= startBlock && invitNum < endBlockNum){
                    count_++;
                    current = current.add(viter.rate);
                }
            }
            startBlock = endBlockNum;
            pow_ = pow_.add(current);
            if(pow_ > 200){
                pow_ = 200;
            }
       }

      finalPow = pow_;
      if(levle ==2){
           if(finalPow > 80){
               finalPow = 80;
           }
       } else if(levle ==3){
           if(finalPow > 90){
               finalPow =90;
           }
       } else if(levle ==4){
           if(finalPow > 100){
               finalPow =100;
           }
       } else if(levle ==5){
           if(finalPow > 110){
               finalPow =110;
           }
       } else if(levle ==6){
           if(finalPow > 120){
               finalPow =120;
           }
       }
       return (array.length,pow_,finalPow);
    }

 function  NextSevenTimesClaimBlock(address memberAddress) public view
       returns(claimInfo [7] memory arr) {
            // console.log("members %s",block.number);
             UserInfo memory user = user[memberAddress];
             uint256 num = (block.number.sub(user.initBlockNumber)).div(blockTotal); //28800
            // console.log("number : ",num);
             uint256 days_ = blockTotal; //todo 28800
             uint256 interval= 0;
             uint256 claimCount=0;
             if(num< user.harvestTimes+7){
                 num = user.harvestTimes.add(uint256(7));
             }
             if(num > 420){
                 num = 420;
             }
             uint256 index_=0;
             for(uint256 d =0; d< num;d++){
                 if(d!=0){
                    days_ = days_.add(baseNumber_); // 124
                 }
                 interval = interval.add(days_);
                 claimCount++;
                 if(claimCount > user.harvestTimes){
                     uint256 nextBlock  = user.initBlockNumber.add(interval);
                     uint256 time_= 0;
                     if(nextBlock > block.number){
                         time_ = (nextBlock.sub(block.number)).mul(3);
                     }
                    //  console.log("index %s",index_);
                     arr[index_] = claimInfo(index_,time_,nextBlock);
                    //  console.log(index_,time_,nextBlock);
                     index_++;
                     if(index_>=7){
                         return arr;
                     }
                 }
             }
     }

}