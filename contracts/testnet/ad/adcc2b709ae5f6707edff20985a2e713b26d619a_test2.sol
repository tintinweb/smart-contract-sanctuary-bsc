/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.6.0;
library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
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
}
pragma solidity >0.6.0;

interface IBEP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity >0.6.0;
contract test2  {
     using SafeMath for uint256; 
     IBEP20 public USDT;
    uint256 public constant decimal_number = 10 ** 18;
    uint256[] public  package_amount = [35,50,100,250,500,2500,5000];
    uint256[] public X1_level_income = [10,1,1,1,1,1,1,1,1,1,1,1];
    uint256[] public X2_level_income = [20,20,20,20,20,20,20];
    uint256[] public X3_level_income = [40,40,40,40,40,40,40];
    uint256[] public X4_level_income = [100,100,100,100,100,100,100];
    uint256[] public X5_level_income = [200,200,200,200,200,200,200];
    uint256[] public X6_level_income = [1000,1000,1000,1000,1000,1000,1000];
    uint256[] public X7_level_income = [2000,2000,2000,2000,2000,2000,2000];
    uint public constant X1_LEVEL_SUM = 25;
    uint public constant X2_LEVEL_SUM = 20;
    uint public constant X3_LEVEL_SUM = 40;
    uint public constant X4_LEVEL_SUM = 100;
    uint public constant X5_LEVEL_SUM = 200;
    uint public constant X6_LEVEL_SUM = 1000;
    uint public constant X7_LEVEL_SUM = 2000;
    uint256[] public X1_LEVEL = [1,1,1,1,1,1,1,1,1,1];
    uint256[] public X2_LEVEL = [2,2,2,2,2,2,2,2,2,2];
    uint256[] public X3_LEVEL = [4,4,4,4,4,4,4,4,4,4];
    uint256[] public X4_LEVEL = [10,10,10,10,10,10,10,10,10,10];
    uint256[] public X5_LEVEL = [20,20,20,20,20,20,20,20,20,20];
    uint256[] public X6_LEVEL = [100,100,100,100,100,100,100,100,100,100];
    uint256[] public X7_LEVEL = [200,200,200,200,200,200,200,200,200,200];
  
    address public admin = 0xCdB2F82b25cdaB26362F04411D0622aCC4692244;
 
    uint public BOOSTING_AMOUNT = 25;
    constructor(address _usdtAddr)   {
         USDT = IBEP20(_usdtAddr);                
     }  
    struct User {
        uint256 id;
        address user_id;
        address sponser_id;
        uint256 directs;
        uint256 package_amount;
        uint256 total_package_amount;
        uint paid_status;
        uint package_id;
        bool set;
        uint256 created_at;
    }
    struct X1 {
        uint256 id;
        address user_id;
        address upline_id;
        uint down_count;
        uint team;
        uint256 created_at;
    }
    struct X2 {
        uint256 id;
        address user_id;
        address upline_id;
        uint down_count;
        uint team;
        uint256 created_at;
    }
    struct X3 {
        uint256 id;
        address user_id;
        address upline_id;
        uint down_count;
        uint team;
        uint256 created_at;
    }
    struct X4 {
        uint256 id;
        address user_id;
        address upline_id;
        uint down_count;
        uint team;
        uint256 created_at;
    }
    struct X5 {
        uint256 id;
        address user_id;
        address upline_id;
        uint down_count;
        uint team;
        uint256 created_at;
    }
    struct X6 {
        uint256 id;
        address user_id;
        address upline_id;
        uint down_count;
        uint team;
        uint256 created_at;
    }
    struct X7 {
        uint256 id;
        address user_id;
        address upline_id;
        uint down_count;
        uint team;
        uint256 created_at;
    }

    mapping(address => User) public users;
    mapping(address => X1) public my1xUsers;
    mapping(address => X2) public my2xUsers;
    mapping(address => X3) public my3xUsers;
    mapping(address => X4) public my4xUsers;
    mapping(address => X5) public my5xUsers;
    mapping(address => X6) public my6xUsers;
    mapping(address => X7) public my7xUsers;
    mapping(address => uint256) balances;
    mapping(address => uint256) direct_balances;
    mapping(address => uint256) level_balances;
    mapping(address => uint256) pool_balances;
      mapping(address => uint256) boosting_balances;
    mapping(uint => uint256) total_business;

    User[] public allUsers;

    X1[] public all1xUsers;
    X2[] public all2xUsers;
    X3[] public all3xUsers;
    X4[] public all4xUsers;
    X5[] public all5xUsers;
    X6[] public all6xUsers;
    X7[] public all7xUsers;
   
   
     struct XBoosting {
        uint256 id;
        address user_id;
        address upline_id;
        uint down_count;
        uint team;
        uint256 created_at;
    }
    
      mapping(address => XBoosting) public myBoostingxUsers;
      XBoosting[] public allBoostingxUsers;
      event Register( address indexed sender);
      event UpgradeAccount(uint256 value , address indexed sender);
      event BoostingAccount(uint256 value , address indexed sender);

      address payable owner;
      modifier onlyOwner(){
        require(msg.sender != owner,"You are not authorized owner.");
        _;
   }
   function createUser(address _userAddress, uint8 plan) public onlyOwner {
        User storage user = users[_userAddress];
        require(!user.set);
        if(allUsers.length == 0){
            User memory user1 = users[_userAddress] = User({
                id : allUsers.length,
                user_id : _userAddress,
                sponser_id : address(0),
                directs: 0,
                package_amount: package_amount[plan],
                total_package_amount: package_amount[plan],
                paid_status : 1,
                package_id : 1,
                set : true,
                created_at : block.timestamp
            });        
            allUsers.push(user1);
            total_business[0] += package_amount[plan];
            for(uint i=0; i < package_amount.length; i++){
                if(i == 0){
                    X1 memory pool_u = my1xUsers[_userAddress] = X1({
                        id : all1xUsers.length,
                        user_id : _userAddress,
                        upline_id : address(0),
                        down_count: 0,
                        team: 0,
                        created_at : block.timestamp
                    });
                    all1xUsers.push(pool_u);
                }

                if(i == 1){
                    X2 memory pool_u = my2xUsers[_userAddress] = X2({
                        id : all2xUsers.length,
                        user_id : _userAddress,
                        upline_id : address(0),
                        down_count: 0,
                        team: 0,
                        created_at : block.timestamp
                    });

                    all2xUsers.push(pool_u);
                }
                
                if(i == 2){
                    X3 memory pool_u = my3xUsers[_userAddress] = X3({
                        id : all3xUsers.length,
                        user_id : _userAddress,
                        upline_id : address(0),
                        down_count: 0,
                        team: 0,
                        created_at : block.timestamp
                    });

                    
                    all3xUsers.push(pool_u);
                }

                if(i == 3){
                    X4 memory pool_u = my4xUsers[_userAddress] = X4({
                        id : all4xUsers.length,
                        user_id : _userAddress,
                        upline_id : address(0),
                        down_count: 0,
                        team: 0,
                        created_at : block.timestamp
                    });
                    all4xUsers.push(pool_u);
                }

                if(i == 4){
                    X5 memory pool_u = my5xUsers[_userAddress] = X5({
                        id : all5xUsers.length,
                        user_id : _userAddress,
                        upline_id : address(0),
                        down_count: 0,
                        team: 0,
                        created_at : block.timestamp
                    });
                    all5xUsers.push(pool_u);
                }

                if(i == 5){
                    X6 memory pool_u = my6xUsers[_userAddress] = X6({
                        id : all6xUsers.length,
                        user_id : _userAddress,
                        upline_id : address(0),
                        down_count: 0,
                        team: 0,
                        created_at : block.timestamp
                    });
                    
                    all6xUsers.push(pool_u);
                }

                if(i == 6){
                    X7 memory pool_u = my7xUsers[_userAddress] = X7({
                        id : all7xUsers.length,
                        user_id : _userAddress,
                        upline_id : address(0),
                        down_count: 0,
                        team: 0,
                        created_at : block.timestamp
                    });
                    all7xUsers.push(pool_u);
                }

            }
            
        }
    }

    

 function register(address sponser_id) external {
        require(sponser_id != address(0), "Invaild Sponser Wallet Address!");
        require(msg.sender != address(0), "Invaild Wallet Address!");
        require(allUsers.length != 0, "First User not registered by admin!");
        require(check_user(sponser_id) != false, "Sponser Wallet Address Invaild or not registered with us!");
        require(check_user(msg.sender) != true, "Wallet Address already registered with us!");
        uint256 registerpackageamt = 35;
        USDT.transferFrom(msg.sender, address(this), registerpackageamt*decimal_number);
        User memory user1 = users[msg.sender] = User({
            id : allUsers.length,
            user_id : msg.sender,
            sponser_id : sponser_id,
            directs: 0,
            package_amount: registerpackageamt,
            total_package_amount: registerpackageamt,
            paid_status : 1,
            package_id : 1,
            set : true,
            created_at : block.timestamp
        });

        allUsers.push(user1);

        User storage my_sponser = users[sponser_id];
        my_sponser.directs += 1;
        allUsers[my_sponser.id].directs += 1;   
        address level_sponser_id = sponser_id;
        uint256 level_sum = X1_LEVEL_SUM;
        uint256[] memory level_income = X1_level_income;
        for(uint i=0; i < level_income.length; i++){
            User storage my_sponser_level = users[level_sponser_id];
            if(my_sponser_level.sponser_id != address(0)){
                if(i == 0){ 
                    direct_balances[my_sponser_level.user_id] = direct_balances[my_sponser_level.user_id].add(level_income[0]);
                    level_balances[my_sponser_level.user_id] = level_balances[my_sponser_level.user_id].add(level_income[1]);                
                    USDT.transfer(my_sponser_level.user_id, level_income[i]*decimal_number);
                    USDT.transfer(my_sponser_level.user_id, 1*decimal_number);                            
                    level_sum = level_sum.sub(1);
                }else{
                    level_balances[my_sponser_level.user_id] = level_balances[my_sponser_level.user_id].add(level_income[i]);
                    USDT.transfer( my_sponser_level.user_id, level_income[i]*decimal_number);
                }
                balances[my_sponser_level.user_id] = balances[my_sponser_level.user_id].add(level_income[i]);
                level_sum = level_sum.sub(level_income[i]);
                level_sponser_id = my_sponser_level.sponser_id;
            }
        }
        if(level_sum > 0){
            level_balances[admin] = level_balances[admin].add(level_sum);
            balances[admin] = balances[admin].add(level_sum);
            USDT.transfer(admin,level_sum*decimal_number);
        }


        address upline_id = get_upline(0);

        if(upline_id != address(0)){
            X1 memory pool_u = my1xUsers[msg.sender] = X1({
                id : all1xUsers.length,
                user_id : msg.sender,
                upline_id : upline_id,
                down_count: 0,
                team: 0,
                created_at : block.timestamp
            });
            
            all1xUsers.push(pool_u);


            X1 storage my_pool = my1xUsers[upline_id];
            if(my_pool.down_count < 2){
                my_pool.down_count += 1;
                all1xUsers[my_pool.id].down_count += 1;
            }

            updateTeam(msg.sender, 0);
            uint256 X1_SUM = 10; // X1_LEVEL_POOL_SUM;//SUM_X1();
            for(uint i=0; i < X1_LEVEL.length; i++){
                X1 storage pool_ip_upline = my1xUsers[upline_id];
                if(pool_ip_upline.user_id != address(0)){
                    pool_balances[pool_ip_upline.user_id] = pool_balances[pool_ip_upline.user_id].add(X1_LEVEL[i]);
                    balances[pool_ip_upline.user_id] = balances[pool_ip_upline.user_id].add(X1_LEVEL[i]);
                     USDT.transfer( pool_ip_upline.user_id, X1_LEVEL[i]*decimal_number);                  
                    X1_SUM = X1_SUM.sub(X1_LEVEL[i]);
                    upline_id = pool_ip_upline.upline_id;
                }
            }
            if(X1_SUM > 0){
                pool_balances[admin] = pool_balances[admin].add(X1_SUM);
                balances[admin] = balances[admin].add(X1_SUM);
                USDT.transfer( admin, X1_SUM*decimal_number);
            }
        }
        total_business[0] += registerpackageamt;
        emit Register(msg.sender);
    }
    function updateTeam(address upline_id, uint8 _package_amount) private returns (bool) {
        if(_package_amount == 0){
            X1 storage my_user = my1xUsers[upline_id];
            if(my_user.user_id != address(0)){
                X1 storage my_pool = my1xUsers[my_user.upline_id];
                all1xUsers[my_pool.id].team += 1;
                my_pool.team += 1;
                updateTeam(my_pool.upline_id, _package_amount);
            }
        }else if(_package_amount == 1){
            X2 storage my_user = my2xUsers[upline_id];
            if(my_user.user_id != address(0)){
                X2 storage my_pool = my2xUsers[my_user.upline_id];
                all2xUsers[my_pool.id].team += 1;
                my_pool.team += 1;
                updateTeam(my_pool.upline_id, _package_amount);
            }
        }else if(_package_amount == 2){
            X3 storage my_user = my3xUsers[upline_id];
            if(my_user.user_id != address(0)){
                X3 storage my_pool = my3xUsers[my_user.upline_id];
                all3xUsers[my_pool.id].team += 1;
                my_pool.team += 1;
                updateTeam(my_pool.upline_id, _package_amount);
            }
        }else if(_package_amount == 3){
            X4 storage my_user = my4xUsers[upline_id];
            if(my_user.user_id != address(0)){
                X4 storage my_pool = my4xUsers[my_user.upline_id];
                all4xUsers[my_pool.id].team += 1;
                my_pool.team += 1;
                updateTeam(my_pool.upline_id, _package_amount);
            }
        }else if(_package_amount == 4){
            X5 storage my_user = my5xUsers[upline_id];
            if(my_user.user_id != address(0)){
                X5 storage my_pool = my5xUsers[my_user.upline_id];
                all5xUsers[my_pool.id].team += 1;
                my_pool.team += 1;
                updateTeam(my_pool.upline_id, _package_amount);
            }
        }else if(_package_amount == 5){
            X6 storage my_user = my6xUsers[upline_id];
            if(my_user.user_id != address(0)){
                X6 storage my_pool = my6xUsers[my_user.upline_id];
                all6xUsers[my_pool.id].team += 1;
                my_pool.team += 1;
                updateTeam(my_pool.upline_id, _package_amount);
            }
        }else if(_package_amount == 6){
            X7 storage my_user = my7xUsers[upline_id];
            if(my_user.user_id != address(0)){
                X7 storage my_pool = my7xUsers[my_user.upline_id];
                all7xUsers[my_pool.id].team += 1;
                my_pool.team += 1;
                updateTeam(my_pool.upline_id, _package_amount);
            }
        }else if(_package_amount == 100){
            XBoosting storage my_user = myBoostingxUsers[upline_id];
            if(my_user.user_id != address(0)){
                XBoosting storage my_pool = myBoostingxUsers[my_user.upline_id];
                allBoostingxUsers[my_pool.id].team += 1;
                my_pool.team += 1;
                updateTeam(my_pool.upline_id, _package_amount);
            }
        }
        return true;
    }
     function get_upline(uint8 _package_amount) public view returns (address) {
        address upline_id_new;
        if(_package_amount == 0){
            for(uint i=0; i < all1xUsers.length; i++){
                if(all1xUsers[i].down_count < 2){
                    upline_id_new = all1xUsers[i].user_id;
                    break;
                }
            }
        }
        if(_package_amount == 1){
            for(uint i=0; i < all2xUsers.length; i++){
                if(all2xUsers[i].down_count < 2){
                    upline_id_new = all2xUsers[i].user_id;
                    break;
                }
            }
        }
        if(_package_amount == 2){
            for(uint i=0; i < all3xUsers.length; i++){
                if(all3xUsers[i].down_count < 2){
                    upline_id_new = all3xUsers[i].user_id;
                    break;
                }
            }
        }

        if(_package_amount == 3){
            for(uint i=0; i < all4xUsers.length; i++){
                if(all4xUsers[i].down_count < 2){
                    upline_id_new = all4xUsers[i].user_id;
                    break;
                }
            }
        }

        if(_package_amount == 4){
            for(uint i=0; i < all5xUsers.length; i++){
                if(all5xUsers[i].down_count < 2){
                    upline_id_new = all5xUsers[i].user_id;
                    break;
                }
            }
        }

        if(_package_amount == 5){
            for(uint i=0; i < all6xUsers.length; i++){
                if(all6xUsers[i].down_count < 2){
                    upline_id_new = all6xUsers[i].user_id;
                    break;
                }
            }
        }

        if(_package_amount == 6){
            for(uint i=0; i < all7xUsers.length; i++){
                if(all7xUsers[i].down_count < 2){
                    upline_id_new = all7xUsers[i].user_id;
                    break;
                }
            }
        }  
     if(_package_amount == 100){
            for(uint i=0; i < allBoostingxUsers.length; i++){
                if(allBoostingxUsers[i].down_count < 4){
                    upline_id_new = allBoostingxUsers[i].user_id;
                    break;
                }
            }
        }


        return upline_id_new;
    }
     function check_user(address _user) public view returns (bool) {
        User storage my_user = users[_user];
        if(my_user.user_id == _user){
            return true;
        }else{
            return false;
        }
    }

  
 function upgradeAccount(uint8 plan ) external {
        require(msg.sender != address(0), "Invaild Wallet Address!");
        require(allUsers.length != 0, "First User not registered by admin!");
        require(check_user(msg.sender) != false, "Wallet Address not registered with us!");   
        require(plan != 0, "Invaild Package Selected for upgrade!"); 
        User storage my_user = users[msg.sender];
        require(my_user.package_id+1 == plan+1, "Invaild Plan!");
        uint256 upgradepackageamt = package_amount[plan];
        USDT.transferFrom(msg.sender, address(this), upgradepackageamt.mul(decimal_number));
        my_user.package_amount = package_amount[plan];
        my_user.package_id = plan+1;
        my_user.total_package_amount += package_amount[plan];
        allUsers[my_user.id].package_amount = package_amount[plan];
        allUsers[my_user.id].package_id = plan+1;
        allUsers[my_user.id].total_package_amount += package_amount[plan];
        address sponser_id = my_user.sponser_id;
        address level_sponser_id = sponser_id;
        uint256 level_sum = 0;
        uint256[] memory level_income;
        if(plan == 1){
            level_income = X2_level_income;
            level_sum = X2_LEVEL_SUM;
        }else if(plan == 2){
            level_income = X3_level_income;
            level_sum = X3_LEVEL_SUM;
        }else if(plan == 3){
            level_income = X4_level_income;
            level_sum = X4_LEVEL_SUM;
        }else if(plan == 4){
            level_income = X5_level_income;
            level_sum = X5_LEVEL_SUM;
        }else if(plan == 5){
            level_income = X6_level_income;
            level_sum = X6_LEVEL_SUM;
        }else if(plan == 6){
            level_income = X7_level_income;
            level_sum = X7_LEVEL_SUM;
        }
        uint256 pending_income = package_amount[plan];
        for(uint i=0; i < level_income.length; i++){
            uint sponser_count = i+1;          
            User storage my_sponser_level = users[level_sponser_id];
       
            if(my_sponser_level.sponser_id != address(0)){
                if(sponser_count == plan+1 && my_sponser_level.package_id >=plan+1){

                    direct_balances[my_sponser_level.user_id] = direct_balances[my_sponser_level.user_id].add(level_income[0]);
                    balances[my_sponser_level.user_id] = balances[my_sponser_level.user_id].add(level_income[i]);
                    USDT.transfer( my_sponser_level.user_id, level_income[i]*decimal_number);
                    level_sum = level_sum.sub(level_income[i]);
                    pending_income = pending_income.sub(level_income[i]);
                }
                level_sponser_id = my_sponser_level.sponser_id;
            }
        }
        if(level_sum > 0){
            level_balances[admin] = level_balances[admin].add(level_sum);
            balances[admin] = balances[admin].add(level_sum);
            USDT.transfer( admin, level_sum*decimal_number);
            pending_income = pending_income.sub(level_sum);

        }
        address upline_id = get_upline(plan);
        if(upline_id != address(0)){
            if(plan == 1){
                X2 memory pool_u = my2xUsers[msg.sender] = X2({
                    id : all2xUsers.length,
                    user_id : msg.sender,
                    upline_id : upline_id,
                    down_count: 0,
                    team: 0,
                    created_at : block.timestamp
                });
                
                all2xUsers.push(pool_u);
                X2 storage my_pool = my2xUsers[upline_id];
                if(my_pool.down_count < 2){
                    my_pool.down_count += 1;
                    all2xUsers[my_pool.id].down_count += 1;
                }
            }else if(plan == 2){
                X3 memory pool_u = my3xUsers[msg.sender] = X3({
                    id : all3xUsers.length,
                    user_id : msg.sender,
                    upline_id : upline_id,
                    down_count: 0,
                    team: 0,
                    created_at : block.timestamp
                });
                all3xUsers.push(pool_u);
                X3 storage my_pool = my3xUsers[upline_id];
                if(my_pool.down_count < 2){
                    my_pool.down_count += 1;
                    all3xUsers[my_pool.id].down_count += 1;
                }
            }else if(plan == 3){
                X4 memory pool_u = my4xUsers[msg.sender] = X4({
                    id : all4xUsers.length,
                    user_id : msg.sender,
                    upline_id : upline_id,
                    down_count: 0,
                    team: 0,
                    created_at : block.timestamp
                });
                all4xUsers.push(pool_u);
                X4 storage my_pool = my4xUsers[upline_id];
                if(my_pool.down_count < 2){
                    my_pool.down_count += 1;
                    all4xUsers[my_pool.id].down_count += 1;
                }
            }else if(plan == 4){
                X5 memory pool_u = my5xUsers[msg.sender] = X5({
                    id : all5xUsers.length,
                    user_id : msg.sender,
                    upline_id : upline_id,
                    down_count: 0,
                    team: 0,
                    created_at : block.timestamp
                });
                
                all5xUsers.push(pool_u);
                X5 storage my_pool = my5xUsers[upline_id];
                if(my_pool.down_count < 2){
                    my_pool.down_count += 1;
                    all5xUsers[my_pool.id].down_count += 1;
                }
            }else if(plan == 5){
                X6 memory pool_u = my6xUsers[msg.sender] = X6({
                    id : all6xUsers.length,
                    user_id : msg.sender,
                    upline_id : upline_id,
                    down_count: 0,
                    team: 0,
                    created_at : block.timestamp
                });
                
                all6xUsers.push(pool_u);
                X6 storage my_pool = my6xUsers[upline_id];
                if(my_pool.down_count < 2){
                    my_pool.down_count += 1;
                    all6xUsers[my_pool.id].down_count += 1;
                }
            }else if(plan == 6){
                X7 memory pool_u = my7xUsers[msg.sender] = X7({
                    id : all7xUsers.length,
                    user_id : msg.sender,
                    upline_id : upline_id,
                    down_count: 0,
                    team: 0,
                    created_at : block.timestamp
                });
                all7xUsers.push(pool_u);
                X7 storage my_pool = my7xUsers[upline_id];
                if(my_pool.down_count < 2){
                    my_pool.down_count += 1;
                    all7xUsers[my_pool.id].down_count += 1;
                }
            }
            updateTeam(msg.sender, plan);
            uint256 X1_SUM = 0;
            uint256[] memory pool_level_income;
            if(plan == 1){
                pool_level_income = X2_LEVEL;
                X1_SUM = 20; // X2_LEVEL_POOL_SUM;
            }else if(plan == 2){
                pool_level_income = X3_LEVEL;
                X1_SUM = 40;//X3_LEVEL_POOL_SUM;
            }else if(plan == 3){
                pool_level_income = X4_LEVEL;
                X1_SUM = 100;//X4_LEVEL_POOL_SUM;
            }else if(plan == 4){
                pool_level_income = X5_LEVEL;
                X1_SUM =200;// X5_LEVEL_POOL_SUM;
            }else if(plan == 5){
                pool_level_income = X6_LEVEL;
                X1_SUM = 1000;//X6_LEVEL_POOL_SUM;
            }else if(plan == 6){
                pool_level_income = X7_LEVEL;
                X1_SUM = 2000;//X7_LEVEL_POOL_SUM;
            }
            address pool_ip_upline_user_id;
            address pool_ip_upline_upline;
            for(uint i=0; i < pool_level_income.length; i++){
                if(plan == 1){
                    pool_ip_upline_user_id = my2xUsers[upline_id].user_id;
                    pool_ip_upline_upline = my2xUsers[upline_id].upline_id;
                }else if(plan == 2){
                    pool_ip_upline_user_id = my3xUsers[upline_id].user_id;
                    pool_ip_upline_upline = my3xUsers[upline_id].upline_id;
                }else if(plan == 3){
                    pool_ip_upline_user_id = my4xUsers[upline_id].user_id;
                    pool_ip_upline_upline = my4xUsers[upline_id].upline_id;
                }else if(plan == 4){
                    pool_ip_upline_user_id = my5xUsers[upline_id].user_id;
                    pool_ip_upline_upline = my5xUsers[upline_id].upline_id;
                }else if(plan == 5){
                    pool_ip_upline_user_id = my6xUsers[upline_id].user_id;
                    pool_ip_upline_upline = my6xUsers[upline_id].upline_id;
                }else if(plan == 6){
                    pool_ip_upline_user_id = my7xUsers[upline_id].user_id;
                    pool_ip_upline_upline = my7xUsers[upline_id].upline_id;
                }
                if(pool_ip_upline_user_id != address(0)){
                    pool_balances[pool_ip_upline_user_id] = pool_balances[pool_ip_upline_user_id].add(pool_level_income[i]);
                    balances[pool_ip_upline_user_id] = balances[pool_ip_upline_user_id].add(pool_level_income[i]);
                    USDT.transfer( pool_ip_upline_user_id, pool_level_income[i]*decimal_number);
                    X1_SUM = X1_SUM.sub(pool_level_income[i]);            
                    upline_id = pool_ip_upline_upline;
                    pending_income = pending_income.sub(pool_level_income[i]);
                }
            }
            if(X1_SUM > 0){
                pool_balances[admin] = pool_balances[admin].add(X1_SUM);
                balances[admin] = balances[admin].add(X1_SUM);
                pending_income = pending_income.sub(X1_SUM);
                USDT.transfer( admin, X1_SUM*decimal_number);
            }
            if(pending_income > 0){
                USDT.transfer( admin, pending_income*decimal_number);
            }
        }
        total_business[0] += upgradepackageamt;
        emit UpgradeAccount(upgradepackageamt*decimal_number,msg.sender);
    }
  
   
    function incomes(address _owner) public view returns (uint256 total_income, uint256 direct_income, uint256 level_income, uint256 pool_income, uint256 all_company_business, uint256 all_users, uint256 company_business) {
        return (balances[_owner], direct_balances[_owner], level_balances[_owner], pool_balances[_owner], total_business[0], allUsers.length, total_business[0]);
    } 
   
    function pool_users() public view returns (uint256 all_X1_users, uint256 all_X2_users, uint256 all_X3_users, uint256 all_X4_users, uint256 all_X5_users, uint256 all_X6_users, uint256 all_X7_users) {
        return (all1xUsers.length, all2xUsers.length, all3xUsers.length, all4xUsers.length, all5xUsers.length, all6xUsers.length, all7xUsers.length);
    }


}