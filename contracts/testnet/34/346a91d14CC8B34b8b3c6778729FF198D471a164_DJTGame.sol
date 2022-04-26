/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

pragma solidity ^0.8.0;

interface IERC20 {
  function transfer(address recipient, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external  returns (bool) ;
  function decimals() external view returns (uint8);
}


contract DJTGame {
    //游戏类型
    string[4] game_type = ["A","B","C","D"];
    uint16 public current_round = 0;//第几轮游戏
    uint256 private six_hour = 6 * 60 * 60;
    uint8 status = 0;//0不可游戏状态 1正常游戏
    address public luck_address;
    string public luck_team_type;

    struct Game {
        uint256 start_date;//游戏开始时间
        uint256 end_date;
        uint256 key_price;//当前key价格
        uint16 players_num;//参与人数
        uint256 raward_pool;//奖池数量
        uint256 all_keys;//售出的key的数量
        mapping(string => uint256) key_num;

    }
    //游戏类型对象
    struct GameItem {
        uint8 invite_rate;
        uint8 team_rate;
        uint8 to_pool;
        uint8 pool_luck_rate;//幸运大奖
        uint8 pool_team_rate;//团队分红
        uint8 pool_next_rate;//下一轮游戏
        uint8 pool_manage_rate;//运营
    }

    struct User {
        address parent;
        uint256 deposit;//总的投资
//        uint256 invit_rewards_A;//推荐的奖励
//        uint256 team_rewards_B;//分红
//        uint256 luck_rewards_C;//幸运奖
        // team名称 -》 奖励
        mapping(string => uint256) rewards;
    }
    //默认地址
    address private manage;

    //初始化4个游戏抽象类 key -> 游戏名称
    mapping(string => GameItem) private gameItems;
    // uint16 - 游戏轮数
    mapping(uint16 => Game) games;

    //string:team名称         current_rount       uint16权重
    mapping(string =>mapping(uint16 => mapping(address => uint16))) teamMemberWeight;
    mapping(address => User) users;
    //string:team名称         current_rount       所有用户地址集合
    mapping(string => mapping(uint16 => address[])) teamMembers;


    IERC20 djtToken;
    address private coinAddress;
	constructor(address  _djtAddress)  {
        djtToken = IERC20(_djtAddress);
        coinAddress = _djtAddress;

        gameItems[game_type[0]] = GameItem(5,34,56,48,27,20,5);
        gameItems[game_type[1]] = GameItem(5,42,48,48,27,20,5);
        gameItems[game_type[2]] = GameItem(5,42,48,48,37,10,5);
        gameItems[game_type[3]] = GameItem(5,24,66,48,37,10,5);

        current_round += 1;
        status = 1;

        // uint256 start_date;//游戏开始时间
        // uint256 key_price;//当前key价格0.002 步长 0.0001 9位小数 =》2*10**6 步长10**5
        // uint16 players_num;//参与人数
        // uint256 raward_pool;//奖池数量
        // uint256 key_num;//售出的key的数量
        // games[current_round] = Game();
        Game storage _game = games[current_round];
        _game.start_date = block.timestamp;
        _game.end_date = block.timestamp + six_hour;
        _game.key_price = 2 * 10 ** 6;
        _game.key_num["A"] = 0;
        _game.key_num["B"] = 0;
        _game.key_num["C"] = 0;
        _game.key_num["D"] = 0;
        manage = msg.sender;

        users[manage].parent = manage;

    }



    //player 开始游戏
    function play(uint8 _type_index,uint16 _djt_num,address _parent) payable external returns(bool){
        //当前游戏
        Game storage _game = games[current_round];
        require(block.timestamp < _game.end_date,"this current is end,wait next game start...");
        address  _member = msg.sender;
        require( _type_index < 4 && _type_index >= 0,"not have this type game");
        string memory _game_name = game_type[_type_index];

        
        //当前key的价值
        uint256  _key_price = _game.key_price;
        uint256  _deposit_djt = _key_price * _djt_num;
        require(_key_price<=_deposit_djt , "min DJT token is one " );
        //先直接转djt到合约地址 需要先授权合约可以转djt
        djtToken.transferFrom(_member, address(this), _deposit_djt);


        //当前玩游戏的人
        User storage _player = users[_member];
        if(_player.parent == address(0)){
            if(_parent != address(0) && _player.parent != manage){
                require(teamMemberWeight[_game_name][current_round][_parent] > 0,"illegal parent address" );
                _player.parent = _parent;
            }else{
                _player.parent = manage;
            }

        }




        //当前游戏类型
        GameItem storage _game_item = gameItems[_game_name];

        _invite_action(_game_name,_player, _deposit_djt,_game_item);//推荐奖励
        _team_pool(_deposit_djt,_game_name, _game,_game_item);// 团队和奖池分配


        //更新 games users teamMemberWeight teamMembers
        _game.key_num[_game_name] += _djt_num * 2;//还会给推荐人100%key
        _game.all_keys += _djt_num * 2;
        _game.key_price = 2 * 10 ** 6 + _djt_num * 10 ** 5;//key price只计算一次


        //是否参加了本轮游戏
        uint16 _weight = teamMemberWeight[_game_name][current_round][_member];
        if(_weight == 0){//未参加游戏 权重为0
            _game.players_num += 1;
            teamMembers[_game_name][current_round].push(_member);
        }

        _player.deposit += _deposit_djt;
        teamMemberWeight[_game_name][current_round][_parent] += _djt_num;
        teamMemberWeight[_game_name][current_round][_member] += _djt_num;
        
        uint256 left_time = _game.end_date - block.timestamp;

        if(left_time < six_hour && left_time > 0 ){
            if( (left_time + 20 * _djt_num) >= six_hour){
                _game.end_date = block.timestamp + six_hour;
            }else{
                _game.end_date += 20 * _djt_num;
            }
        }

        luck_address = _member;
        luck_team_type = _game_name;

        return true;

    }

   function nextGame() external {

       require(msg.sender == luck_address||msg.sender == manage,"only manager or luck body can run it");
       
       Game storage _game = games[current_round];
      
       require(block.timestamp >= _game.end_date,"game is running,you cant do it");
       //获取team分配规则
       GameItem storage _rule = gameItems[luck_team_type];
      
       User storage _luck_body = users[luck_address];
       _luck_body.rewards[luck_team_type] += _game.raward_pool * _rule.pool_luck_rate / 100;

       //团队
        uint256 _fm = _game.key_num[luck_team_type];
        uint256 _all_add =  _game.raward_pool * _rule.pool_team_rate / 100;//团队分红

        address[] memory _teamMembers = teamMembers[luck_team_type][current_round];

        for(uint16 i = 0;i < _teamMembers.length;i++){
            address _c = _teamMembers[i];
            User storage _user = users[_c];
            uint16 _weight = teamMemberWeight[luck_team_type][current_round][_c];
            uint256 _add = _all_add * _weight / _fm;
            _user.rewards[luck_team_type] += _add;
        }

        //指定地址
        User storage _manager = users[manage];
        _manager.rewards[luck_team_type] +=  _game.raward_pool * _rule.pool_manage_rate / 100;

        //初始化
        current_round += 1;
        status = 1;
        luck_address = address(0);
        luck_team_type = "";
        //下一轮奖池
         Game storage _next_game = games[current_round];
        _next_game.start_date = block.timestamp;
        _next_game.end_date = block.timestamp + six_hour;
        _next_game.key_price = 2 * 10 ** 6;
        _next_game.key_num["A"] = 0;
        _next_game.key_num["B"] = 0;
        _next_game.key_num["C"] = 0;
        _next_game.key_num["D"] = 0;
        _next_game.raward_pool = _game.raward_pool * _rule.pool_next_rate / 100;

   }

    function _invite_action(string memory _game_name,User storage  _player,uint256 _deposit_djt,GameItem storage _item) internal {

        User storage _parent = users[_player.parent];
        uint256 _invite_one = _deposit_djt * _item.invite_rate / 100;
       _parent.rewards[_game_name] += _invite_one;


        User storage _great_parent = users[_parent.parent];
        _great_parent.rewards[_game_name] += _invite_one;

    }


    function _team_pool(uint256 _deposit_djt,string memory _game_name, Game storage _game,GameItem  storage _game_item) internal {
        address[] memory _teamMembers = teamMembers[_game_name][current_round];
        //当前权重分母
        uint256 _fm = _game.key_num[_game_name];
        uint256 _all_add = _deposit_djt * _game_item.team_rate / 100;//团队分红
        for(uint16 i = 0;i < _teamMembers.length;i++){
            address _c = _teamMembers[i];
            User storage _user = users[_c];
            uint16 _weight = teamMemberWeight[_game_name][current_round][_c];
            uint256 _add = _all_add * _weight / _fm;
            _user.rewards[_game_name] += _add;

        }

        uint256 _pool_add = _deposit_djt * _game_item.to_pool / 100; //奖池
        _game.raward_pool += _pool_add;

    }


    function gameInfo() public view returns(uint,uint,uint,uint16,uint256,uint){
        //  uint256 start_date;//游戏开始时间
        // uint256 end_date;
        // uint256 key_price;//当前key价格
        // uint16 players_num;//参与人数
        // uint256 raward_pool;
        Game storage g = games[current_round];
        return (g.start_date,g.end_date,g.key_price,g.players_num,g.all_keys,g.raward_pool);
    }







    function myInfo() public view returns(address,uint256){
        //   address parent;
        // uint256 deposit;//总的投资
//        uint256 invit_rewards_A;//推荐的奖励
//        uint256 team_rewards_B;//分红
//        uint256 luck_rewards_C;//幸运奖
        // team名称 -》 奖励
        // mapping(string => uint256) rewards;
        // return users[msg.sender];
        User storage u = users[msg.sender];
        return (u.parent,u.deposit);
    }

    function myKeys(uint8  _game_index) external view returns(uint256){

        return users[msg.sender].rewards[game_type[_game_index]];
    }


    function gameKeys(uint8 _game_index) external view returns(uint256){
        return games[current_round].key_num[game_type[_game_index]];
    }


    //转走所有的djt
    function pickAllDjt(uint _game_index) external{
        User storage u = users[msg.sender];
        uint amount = u.rewards[game_type[_game_index]];
        u.rewards[game_type[_game_index]] = 0;
      
        djtToken.transfer(msg.sender,amount);
    }





    receive() external payable  {}
    fallback() external payable  {}
}