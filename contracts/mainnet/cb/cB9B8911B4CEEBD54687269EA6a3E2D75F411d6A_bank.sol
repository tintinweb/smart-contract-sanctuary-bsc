pragma solidity >=0.5.0 <0.6.0;
import "./SafeMath1.sol";

interface ERC20 {


function balanceOf(address _owner) external view returns (uint balance);
function transfer(address _to, uint _value) external returns (bool success);
function transferFrom(address _from, address _to, uint _value) external returns (bool success);
function approve(address _spender, uint _value) external returns (bool success);
function allowance(address _owner, address _spender) external view returns (uint remaining);
function parents(address _owner) external view returns (address parent);
function add_profit(address _address,uint256 _number)external;
function calculation(address _owner) external view returns (uint256 yeji);
}
interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}
interface ISwapRouter {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}
contract bank{
     using SafeMath for uint256;
    struct members_level{
             uint256 times;
             uint256 min_number;
             uint256 max_number;
             uint256 achievement_fee;
             uint256 yeji;
             uint256 money;
    }
    struct members_info{
            uint256 level;
            uint256 create_time;
            uint256 is_activte;
    }
    struct orders_info{
            uint256 money;
            uint256 profit;
            uint256 create_time;
            uint256 pay_time;
            uint256 end_time;
            uint256 update_time;
            uint256 already_profit;
            uint256 start_money;
            uint256 alre_profit;
            uint256 end_money;
            uint256 is_pay;
            uint256 status;//1 进行中  2支付尾款完成   3已完成
            uint256 order_ids;
            address _address;
    }
    uint256 private constant MAX = ~uint256(0);
    address public usdt_address=0x55d398326f99059fF775485246999027B3197955;
    address public token_address=0xB3ba749f428e1dB693876fF009902358c063e064;
    address public pair_address=0x2d932AD296624AeCA9880dBC8a6613B3D5022722;

    address public yhe_address = 0x6DD423d29dC23960D22d39C4c1b61eF0CdBA05B4;
    address public RouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public receive_address=0x28BbDF26DE2dd41f0AAEDe8038cE7E0ADca4ca28;
    mapping(uint256 => members_level)public level;
    uint256 public order_id = 1;
    mapping(uint256 => orders_info)public orders;
    address public nft_reawrd=0x84ed50C867dd993bf325DE011878Fa016FEaa4d1;
    uint256 public all_money;
    uint256 public update_money;
    uint256 public all_buyback;
    mapping(address => members_info)public infos;

     address public bind_address=0x9684a9f5F0b4aeE4E1d6d9887cbCA5C812cDF94f;//部署完绑定合约替换地址
    uint256 public create_time;
    address public owner; 
    address public quilidty_address=0x9DF1d1C0dCeE79C95CA914191ea4116CBC13e50B;
    uint256 public quilidty_radio=1;
    uint256 public nft_radio=2;
    uint256 public buy_back = 3;
    uint256 public push_radio = 2;
    uint256 day_profit = 12;
    mapping(address => uint256)public already_share;
    mapping(address => uint256)public already_achievement;
    mapping(address => uint256)public my_money;
    // uint256 public profit_times = 1 days;
    uint256 public profit_times = 1 days;//正式 为 1 days
    uint256 public pay_times=2 days;//正式48 hour  修改为2 days
    uint256 public update_time;
    uint256 public quota = 5000*10**18;//额度正式为5000
    uint256 public up_radio = 20;
    uint256 public quota_time=1 days;
    mapping(address => uint256)public member_times;
    mapping(address => uint256)public share_profit;
    mapping(address => uint256)public achievement_profit;
    mapping(address => uint256[])public my_order;
    mapping(address => uint256)public my_profit;
    mapping(address => uint256)public real_profit;
    uint256 is_open=0;//0关闭  1开启  正式默认为0部署
    mapping(address => uint256)private member_create_times;
    ISwapRouter public _swapRouter;
    constructor() public {
      owner = msg.sender;
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        ERC20(usdt_address).approve(address(swapRouter), MAX);
        _swapRouter = swapRouter;
    
        create_time = now;  
    }
     modifier onlyOwner() {
      require(msg.sender == owner);
    _;
    }
     function start(uint256 _quota,uint256 _up_radio,uint256 _is_open,uint256 _quota_time,uint256 _update_money)onlyOwner public returns(bool){
         update_time = now;
         quota = _quota;
        up_radio = _up_radio;
        is_open = _is_open;
        quota_time = _quota_time;
        update_money = _update_money;
    }
     function owner_withdraw(uint256 _amount,address _address)onlyOwner public returns(bool){
        ERC20(usdt_address).transfer(_address,_amount);
    }
    function setupdate_time(uint256 _update_time)onlyOwner public returns(bool){
        update_time = _update_time;
    }
    function setmember(uint256 _is_activity,uint256 _level,address _address)onlyOwner public returns(bool){
         infos[_address].is_activte = _is_activity;
         infos[_address].level = _level;
    }
    function set_profit_time(uint256 _profit_times)onlyOwner public returns(bool){
                profit_times = _profit_times;
    }
    function AddLevel(uint256 _level,uint256 _times,uint256 _min_number,uint256 _max_number,uint256 _achievement_fee,uint256 _yeji,uint256 _money)onlyOwner public returns(bool) {
                 level[_level].times = _times;
                 level[_level].min_number = _min_number;
                 level[_level].max_number = _max_number;
                 level[_level].achievement_fee = _achievement_fee;
                 level[_level].yeji = _yeji;
                 level[_level].money = _money;
    }
    function set_day_profit(uint256 _day_profit)onlyOwner public returns(bool){
        day_profit = _day_profit;
    }
    function check_user_profit(address _address) public view returns(uint256){
    
               if(real_profit[_address] > my_money[_address]*3){
                   return 1;
               }

        return 0;
    }
    function setFees(uint256 _quilidty_radio,uint256 _nft_radio,uint256 _buy_back,uint256 _push_radio)onlyOwner public returns(bool) {
                 quilidty_radio =  _quilidty_radio;
                 nft_radio =  _nft_radio;
                 buy_back =  _buy_back;
                 push_radio =  _push_radio;
    }
    function activite(address _address)public{
        require(_address != address(0x0));
        require(msg.sender == bind_address);
        member_create_times[_address] = now;
        infos[_address].is_activte = 1;
    }
    function achievement(address _address,uint256 amount)public{
           uint256 all_yeji = 10;
           uint256 i = 0;
           address  agent = ERC20(bind_address).parents(_address);
           uint256 is_v5 = 0;
           if(agent != address(0x0)){    
           do{
               uint256 profit_number = 0;
               if(all_yeji <= 0){
                    break;
               }
               if(agent == address(0x0)){
                   break;
               }
               if(infos[agent].level >= 1 && my_money[agent] > 0){
                   if(all_yeji >= level[infos[agent].level].achievement_fee){
                    profit_number = amount*level[infos[agent].level].achievement_fee/100;
                      all_yeji = all_yeji - level[infos[agent].level].achievement_fee;
                   }else{
                       if(all_yeji >= 0 && infos[agent].level == 5){
                           if(all_yeji > 0){
                              profit_number = amount*all_yeji/100;
                              all_yeji = 1;
                              is_v5 = 1;
                           }else{
                               if(infos[agent].level == 5 && is_v5 <=1){
                              profit_number = amount*1/100; 
                              is_v5 = is_v5+1;
                               all_yeji = 0;
                               }
                           }

                       }
                    
                   }
                   
                 
                   achievement_profit[agent] = achievement_profit[agent]+profit_number;            
               }
                   i = i+1;
                   agent = ERC20(bind_address).parents(agent);
           }while(i<=12 || all_yeji <= 1);
           }

    }
    function SetAddress(address _usdt_address,address _token_address,address _pair_address,address _receive_address,address _nft_reawrd,address _bind_address,address _quilidty_address) onlyOwner public returns(bool) {
      usdt_address =  _usdt_address;
      token_address = _token_address;
      pair_address = _pair_address;
      receive_address = _receive_address;
      nft_reawrd = _nft_reawrd;
      bind_address = _bind_address;
      quilidty_address = _quilidty_address;
      return true;
    }
     function set_pay_tims(uint256 _pay_tims)onlyOwner public{
        pay_times = _pay_tims;
    }
     function set_owner(address _owner)onlyOwner public{
        owner = _owner;
    }
    function up_user()public{
        uint yhe_balacne = ERC20(yhe_address).balanceOf(msg.sender);
        uint256 yhe_money = getusdt_number(yhe_balacne, pair_address);
        uint256 new_level = infos[msg.sender].level+1;
        uint256 yeji = ERC20(bind_address).calculation(msg.sender);
        require(yeji >= level[new_level].yeji && yhe_money >= level[new_level].money);
        infos[msg.sender].level = new_level;
    }
    function check_user(address _address)public view returns(uint256){
          uint yhe_balacne = ERC20(yhe_address).balanceOf(_address);
        uint256 yhe_money = getusdt_number(yhe_balacne, pair_address);
        uint256 new_level = infos[_address].level+1;
        uint256 yeji = ERC20(bind_address).calculation(_address);
        if(yeji >= level[new_level].yeji && yhe_money >= level[new_level].money){
            return 1;
        }
        return 0;
       
    }
    function Pledge(uint256 amount) public{
            require(infos[msg.sender].is_activte == 1,'111');
            require(is_open == 1);
            require(amount*2 >= level[infos[msg.sender].level].min_number && amount*2 <= level[infos[msg.sender].level].max_number,'222');
            require(member_times[msg.sender]+level[infos[msg.sender].level].times <= now,'3333');
            if(now >= update_time + quota_time){
            
                 if(update_money+1000*10**18 >= quota){
                     update_money = 0;
                     quota = quota + quota*20/100;
                 }
                 update_time = update_time + quota_time;
            }
             require(update_money + amount <= quota);
             uint256 pay_days = get_days(order_id,msg.sender);
             require(pay_days > 0,'444');
          
            ERC20(usdt_address).transferFrom(msg.sender,address(this),amount);         
            uint256 buy_back_number = amount*buy_back/100;
            if(buy_back_number > 0){
                buy_token(buy_back_number);
            }
            uint256 quilidty_number = amount*quilidty_radio/100;
            if(quilidty_number > 0){
                ERC20(usdt_address).transfer(quilidty_address,quilidty_number);
            }
            uint256 nft_number = amount*nft_radio/100;
            if(nft_number > 0){
                 ERC20(usdt_address).transfer(nft_reawrd,nft_number);
            }
            uint256 push_number = amount*push_radio/100;
            address agent = ERC20(bind_address).parents(msg.sender);
            if(agent != address(0x0) && push_number > 0){
                if(my_money[agent] > 0){
                share_profit[agent] = share_profit[agent] + push_number;
                }
            }
             my_money[msg.sender] = my_money[msg.sender] + amount;
            achievement(msg.sender,amount);
            all_money = all_money+amount;
            update_money = update_money +amount;
            orders[order_id].money = amount;
            orders[order_id].profit = day_profit;
            orders[order_id].create_time = now;
            orders[order_id].pay_time = now+pay_days;
            orders[order_id].end_time = 0;
            orders[order_id].already_profit = 0;
            orders[order_id].start_money = amount;
            orders[order_id].end_money = amount;
            orders[order_id].is_pay = 0;
            orders[order_id].status = 1;
            orders[order_id]._address = msg.sender;
            orders[order_id].order_ids = rand_order(msg.sender,order_id);
            member_times[msg.sender] = now;
            my_order[msg.sender].push(order_id);
            ERC20(bind_address).add_profit(msg.sender,amount);
            order_id = order_id +1;        
    }
    function pay_order(uint256 _order_id)public{
           require(orders[_order_id].is_pay == 0 && orders[_order_id].status == 1);
           require(now >= orders[_order_id].pay_time);
           require(orders[_order_id]._address == msg.sender);
           require(orders[_order_id].pay_time+ pay_times > now);
            uint256 pay_days = GetEndDays(order_id,msg.sender);
             require(pay_days > 0);
          
             uint256 amount = orders[_order_id].end_money;
                 all_money = all_money+amount;
                  my_money[msg.sender] = my_money[msg.sender] + amount;
            ERC20(usdt_address).transferFrom(msg.sender,address(this),amount);         
            uint256 buy_back_number = amount*buy_back/100;
            if(buy_back_number > 0){
                buy_token(buy_back_number);
            }
            uint256 quilidty_number = amount*quilidty_radio/100;
            if(quilidty_number > 0){
                ERC20(usdt_address).transfer(quilidty_address,quilidty_number);
            }
            uint256 nft_number = amount*nft_radio/100;
            if(nft_number > 0){
                 ERC20(usdt_address).transfer(nft_reawrd,quilidty_number);
            }
            uint256 push_number = amount*push_radio/100;
            address agent = ERC20(bind_address).parents(msg.sender);
            if(agent != address(0x0) && push_number > 0){
                  if(my_money[agent] > 0){
                share_profit[agent] = share_profit[agent] + push_number;
                  }
            }
            
            achievement(msg.sender,amount);

            claim(_order_id);
            ERC20(bind_address).add_profit(msg.sender,amount);
            orders[_order_id].end_time = now+pay_days;
            orders[_order_id].status = 2;
             orders[_order_id].update_time = now;
            orders[_order_id].money = orders[_order_id].money+amount;
            orders[_order_id].is_pay = 1;
    }
    function withdraw(uint256 _order_id)public{
            require(orders[_order_id].is_pay == 1 && orders[_order_id].status == 2);
           require(now >= orders[_order_id].end_time);
           require(orders[_order_id]._address == msg.sender);
           claim(_order_id);
           ERC20(usdt_address).transfer(msg.sender,orders[_order_id].money);
           orders[_order_id].status = 3;
    }
    function getprofit(uint256 _order_id)public view returns(uint256){
             require(orders[_order_id].status == 1 || orders[_order_id].status == 2 || orders[_order_id].status == 3);
             if(orders[_order_id].status == 3){
                 return 0;
             }
          
                uint256 Time;
             if(orders[_order_id].status == 1){
               if(orders[_order_id].pay_time+ pay_times < now){
                 return 0;
             }
                 Time = orders[_order_id].create_time;
             uint256 day = (block.timestamp - Time)/profit_times;
           uint256 usdt_number = orders[_order_id].money*day_profit*day/1000;
           uint256 profit = usdt_number - orders[_order_id].already_profit;
           return profit;
             }else if(orders[_order_id].status == 2){
                 Time = orders[_order_id].update_time;
                 uint256 EndTimes = block.timestamp;
                 if(block.timestamp > orders[_order_id].end_time){
                     EndTimes =  orders[_order_id].end_time;
                 }
                 uint256 day = (EndTimes - Time)/profit_times;
                 uint256 usdt_number = orders[_order_id].money*day_profit*day/1000;
                 uint256 profit = usdt_number - orders[_order_id].alre_profit;
            return profit;
             }
 
    }
      function getusdt_number(uint256 token_number,address _lp)public view returns(uint256){
     uint256 usdt_number = token_number*getusdt(_lp)/1e18;
      return usdt_number;
       }
  function getusdt(address _lp) public view returns (uint256) { 
    if(_lp == address(0)) {return 0;} 
    IPancakePair pair = IPancakePair(_lp);
     (uint112 _reserve0, uint112 _reserve1, ) = pair.getReserves(); 
     uint256 a = _reserve1; 
     uint256 b = _reserve0;
      return b*1e18/a;
    }
    function claim(uint256 _order_id)public{
        require(orders[_order_id].status == 1 || orders[_order_id].status == 2);
        require(orders[_order_id]._address == msg.sender);
           require(check_user_profit(msg.sender) == 0);
        uint256 profit_number = getprofit(_order_id);
        if(profit_number > 0){
        uint256 fee_number = profit_number*1/100;
        ERC20(token_address).transferFrom(msg.sender,address(this),fee_number);
        ERC20(usdt_address).transfer(msg.sender,profit_number);
        my_profit[msg.sender] = my_profit[msg.sender]+profit_number;
        real_profit[msg.sender] = real_profit[msg.sender]+profit_number;
        if(orders[_order_id].status == 1){
           orders[_order_id].already_profit = orders[_order_id].already_profit +  profit_number;
        }else if(orders[_order_id].status == 2){
           orders[_order_id].alre_profit = orders[_order_id].alre_profit +  profit_number;
        }
        }
     

    }
    function claim_share()public{
          require(share_profit[msg.sender] > 0);
            require(check_user_profit(msg.sender) == 0);
          ERC20(token_address).transferFrom(msg.sender,address(this),share_profit[msg.sender]*1/100);
          ERC20(usdt_address).transfer(msg.sender,share_profit[msg.sender]);
           my_profit[msg.sender] =  my_profit[msg.sender]+share_profit[msg.sender];
           real_profit[msg.sender] = real_profit[msg.sender]+share_profit[msg.sender];
          already_share[msg.sender] = already_share[msg.sender]+share_profit[msg.sender];
          share_profit[msg.sender] = 0;
    }
    function claim_achievement()public{
           require(achievement_profit[msg.sender] > 0);
             require(check_user_profit(msg.sender) == 0);
          ERC20(token_address).transferFrom(msg.sender,address(this),achievement_profit[msg.sender]*1/100);
          ERC20(usdt_address).transfer(msg.sender,achievement_profit[msg.sender]);
    
          my_profit[msg.sender] =  my_profit[msg.sender]+achievement_profit[msg.sender];
          real_profit[msg.sender] = real_profit[msg.sender]+achievement_profit[msg.sender];
          already_achievement[msg.sender] = already_achievement[msg.sender] + achievement_profit[msg.sender];
         achievement_profit[msg.sender] = 0;
    }
     function getpageOrderids(uint256 _limit,uint256 _pageNumber,address _address,uint256 status)public view returns(uint256[] memory){
         uint256 orderidsamount = my_order[_address].length;

        if(status != 0){
           orderidsamount = getNumberOforderListings(status,_address);
        }
        uint256 pageEnd = _limit * (_pageNumber + 1);
        uint256 orderSize = orderidsamount >= pageEnd ? _limit : orderidsamount.sub(_limit * _pageNumber);  
        uint256[] memory ordersids = new uint256[](orderSize);
        if(orderidsamount > 0){
             uint256 counter = 0;
        uint8 tokenIterator = 0;
        for (uint256 i = 0; i < my_order[_address].length && counter < pageEnd; i++) {
         if(status != 0 ){  
            if (orders[my_order[_address][i]].status == status){
                if(counter >= pageEnd - _limit) {
                    ordersids[tokenIterator] = my_order[_address][i];
                    tokenIterator++;
                }
                counter++;
            }
            }else{
                  if(counter >= pageEnd - _limit) {
                    ordersids[tokenIterator] = my_order[_address][i];
                    tokenIterator++;
                }
                counter++;
            }
        }
          }
        return ordersids;
  }
  //获取订单id的长度
   function getNumberOforderListings(uint256 status,address _address)
        public
        view
        returns (uint256)
    {
        uint256 counter = 0;
        for(uint256 i = 0; i < my_order[_address].length; i++) {
            if (orders[my_order[_address][i]].status == status){
                counter++;
            }
        }
        return counter;
    }
    function get_days(uint256 _orderid,address _address)public view returns(uint256){
             require(_orderid > 0 && _address != address(0x0));
            
             uint256 number = rand(_address,_orderid);
             uint256 pay_days;
             if(number <= 1000){
                  pay_days = 11 days;
                  if(number <= 700){
                      pay_days = 12 days;
                      if(number <= 600){
                          pay_days = 10 days;
                          if(number <= 150){
                              pay_days = 14 days;
                              if(number <= 100){
                                  pay_days = 13 days;
                                  if(number <= 80){
                                      pay_days = 15 days;
                                      if(number <= 70){
                                          pay_days = 9 days;
                                          if(number <= 60){
                                              pay_days = 8 days;
                                              if(number <= 50){
                                                  pay_days = 7 days;
                                                  if(number <= 40){
                                                      pay_days = 6 days;
                                                      if(number <= 30){
                                                          pay_days = 5 days;
                                                          if(number <= 25){
                                                              pay_days = 4 days;
                                                              if(number <= 20){
                                                                  pay_days = 2 days;
                                                                  if(number <= 15){
                                                                      pay_days = 2 days;
                                                                      if(number <= 10){
                                                                          pay_days = 1 days;
                                                                      }
                                                                  }
                                                              }
                                                          }
                                                      }
                                                  }
                                              }
                                          }
                                      }
                                  }
                              }
                          }
                      }
                  }
             }
        return pay_days;
      
    }
    function GetEndDays(uint256 _orderid,address _address)public view returns(uint256){
           
              require(_orderid > 0 && _address != address(0x0));
             uint256 number = rand(_address,_orderid);
             uint256 end_days;     
             if(number <= 1000){
                 end_days = 7 days;
                 if(number <= 700){
                     end_days = 8 days;
                     if(number <= 400){
                         end_days = 6 days;
                         if(number <= 300){
                             end_days = 9 days;
                             if(number <= 80){
                                 end_days = 11 days;
                                 if(number <= 50){
                                     end_days = 10 days;
                                     if(number <= 30){
                                         end_days = 5 days;
                                         if(number <= 20){
                                             end_days = 4 days;
                                         }
                                     }
                                 }
                             }
                         }
                     }
                 }
             }
             return end_days;
    }
     function rand(address _to,uint256 _orderid) private view returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp,_to,_orderid,block.number)));
        return random%1000;
    }
     function rand_order(address _to,uint256 _orderid) public view returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp,_to,_orderid,block.number)));
        return random%1000000000;
    }

       function buy_token(uint256 amount)public{
     all_buyback = all_buyback +amount;
         address[] memory path = new address[](2);
        path[0] = usdt_address;
        path[1] = yhe_address;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            receive_address,
            block.timestamp
        );
    }
}