//SPDX-License-Identifier: MIT License
pragma solidity 0.8.9;
interface Itoken {
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 retue);

    event Approve(
        address indexed owner,
        address indexed spender,
        uint256 retue
    );
}

contract LOTTERY{
  uint256 public nonce;
  address public  Admin ;
  Itoken public token;
  uint256 public duration;
  uint256 public  lottery_price;

  uint256 [3] public winners_percentages = [50 , 30 , 20];


  //distribution criteria
  uint256 public pool_percentage = 40;
  uint256 public next_pool_percentage = 30;
  uint256 public winbusd_pool_percentage = 10;
  uint256 public creator_percentage = 10;
  uint256 public reffral_percentage = 10;
  uint256 public withdraw_refferal_percentage = 10;
  uint256 public divider = 100;

  //address's 
  address public  creator_address;
  address public  staking_address;
  address public  winbusd_address;


  

  struct lotterydata{
    address [] participants;
    address [] uniqueaddress;
    mapping(address => bool) hasparticipated;
    mapping(address => bool) won;
    address [] winners;
    uint256 prize;
    uint256 start_time;
    uint256 end_time;
    uint256 [] winner_reward;
  }

  struct player{
    address player_address;
    uint256 overall_rewards;
    uint256 overall_lotteries_bought;
    mapping(uint256 => uint256) lotteries_bought;
    mapping(uint256 => uint256) lotteries_rewards;
    mapping(uint256 => bool) lotteries_won;
    mapping(uint256 => bool) claimed_rewards;
  }

  mapping (uint256 => lotterydata) private lotteries;
  mapping (address => player) public players;
  mapping (address => address) public reffral;

  event BOUGHT(address player, uint256 lotteries_bought, uint256 nonce);
  event WON(address player, uint256 claimed_rewards, uint256 nonce);

  modifier onlyAdmin{
    require(msg.sender == Admin);
    _;
  }


  constructor(){
    Admin = 0x01CFef0aCE06FEA1757374A1D137eDD97edBD170;
    staking_address = msg.sender;
    creator_address = msg.sender;
    winbusd_address = msg.sender;
    nonce = 0;
    token = Itoken(0xA57a21E9Dd19f1e75dd4Fb5E59374871842026f1);
    duration = 10 minutes;
    lottery_price = 10 * (10 ** token.decimals());
    lotteries[nonce].start_time = block.timestamp;
    lotteries[nonce].end_time = block.timestamp + duration;
  }

  function buy(uint256 count,address ref) public {
    require( block.timestamp < lotteries[nonce].end_time,"time passed" );
    require(msg.sender != ref && ref != address(0) && count > 0, "Invalid ref address");
    reffral[msg.sender] = ref;
    token.transferFrom(msg.sender, address(this), count * lottery_price);
    player storage user = players[msg.sender];
    user.overall_lotteries_bought += count;
    user.lotteries_bought[nonce] += count;
    for(uint256 i = 0; i < count; i++){
      lotteries[nonce].participants.push(msg.sender);
    }
    uint256 amount = count * lottery_price;
    lotteries[nonce].prize = amount*pool_percentage/divider;
    if(!lotteries[nonce].hasparticipated[msg.sender]){
      lotteries[nonce].uniqueaddress.push(msg.sender);
      lotteries[nonce].hasparticipated[msg.sender] = true;
    }
    token.transfer(creator_address,amount*creator_percentage/divider);
    lotteries[nonce+1].prize = amount*next_pool_percentage/divider;
    token.transfer(winbusd_address,amount*winbusd_pool_percentage/divider);
    token.transfer(ref,amount*reffral_percentage/divider);
    emit BOUGHT(msg.sender, count, nonce);
  }

  function setwinners() external onlyAdmin{
    require(block.timestamp > lotteries[nonce].end_time);
    if(lotteries[nonce].participants.length > 0){
    for(uint256 i = 0; i < winners_percentages.length && i < lotteries[nonce].uniqueaddress.length; i++){
    address winner = getwinner(i);
    lotteries[nonce].won[winner] = true;
    lotteries[nonce].winners.push(winner);
    lotteries[nonce].winner_reward.push( lotteries[nonce].prize*winners_percentages[i]/100);
    
    player storage user = players[lotteries[nonce].winners[i]];
    user.overall_rewards += lotteries[nonce].winner_reward[i];
    user.lotteries_rewards[nonce] += lotteries[nonce].winner_reward[i];
    user.lotteries_won[nonce] = true;
    user.claimed_rewards[nonce] = true;

    token.transfer(lotteries[nonce].winners[i], (lotteries[nonce].winner_reward[i]-lotteries[nonce].winner_reward[i]*withdraw_refferal_percentage/divider));
    token.transfer(reffral[lotteries[nonce].winners[i]], lotteries[nonce].winner_reward[i]*withdraw_refferal_percentage/divider);

    emit WON(lotteries[nonce].winners[i], lotteries[nonce].winner_reward[i], nonce);
    }
    }

    nonce++;
    lotteries[nonce].start_time = block.timestamp;
    lotteries[nonce].end_time = block.timestamp + duration;

  }

  function getwinner(uint256 index) internal view returns (address winner){
    uint256 winner_index = random(lotteries[nonce].participants.length,index);
    return lotteries[nonce].participants[winner_index];
  }
  function random(uint256 length,uint256 _index) internal view returns (uint256 index){
    uint256 random_number = uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty,address(this),block.number,block.coinbase,length,_index)));
    return random_number % length;
  }

  function get_lottery_data(uint256 index) public view returns (address [] memory winner, uint256 prize, uint256 start_time, uint256 end_time, uint256 [] memory winner_reward,address [] memory participants){
    return (lotteries[index].winners, lotteries[index].prize, lotteries[index].start_time, lotteries[index].end_time, lotteries[index].winner_reward,lotteries[index].participants);
  }

  function get_user_data(address user , uint256 index) public view returns (uint256 lotteries_bought,uint256 lotteries_rewards,bool lotteries_won,bool claimed_rewards){
    return (players[user].lotteries_bought[index], players[user].lotteries_rewards[index], players[user].lotteries_won[index], players[user].claimed_rewards[index]);
  }

  function set_token(Itoken _token) external onlyAdmin{
    require(address(_token) != address(0));
    token = _token;
  }
  function set_lottery_price(uint256 _lottery_price)external onlyAdmin{
    require(_lottery_price > 0);
    lottery_price = _lottery_price;
  }
  function set_admin(address newAdmin) external onlyAdmin{
    Admin = newAdmin;
  }

  function get_contract_balance() external view returns (uint256){
    return token.balanceOf(address(this));
  }

  function withdraw_stuck_token(Itoken _token,uint256 stuck_amount) external onlyAdmin{
    require(address(_token) != address(0));
    require(stuck_amount > 0 && stuck_amount <= token.balanceOf(address(this)));
    _token.transfer(msg.sender, stuck_amount);
  }

  function set_creator_percentage(uint256 _creator_percentage) external onlyAdmin{
    require(_creator_percentage > 0);
    creator_percentage = _creator_percentage;
  }
  function set_creator_address(address _creator_address) external onlyAdmin{
    require(address(_creator_address) != address(0));
    creator_address = _creator_address;
  }
  function set_staking_percentage(uint256 _staking_percentage) external onlyAdmin{
    require(_staking_percentage > 0);
    next_pool_percentage = _staking_percentage;
  }
  function set_staking_address(address _staking_address) external onlyAdmin{
    require(address(_staking_address) != address(0));
    staking_address = _staking_address;
  }
  function set_winbusd_percentage(uint256 _winbusd_percentage) external onlyAdmin{
    require(_winbusd_percentage > 0);
    winbusd_pool_percentage = _winbusd_percentage;
  }
  function set_winbusd_address(address _winbusd_address) external onlyAdmin{
    require(address(_winbusd_address) != address(0));
    winbusd_address = _winbusd_address;
  }
  function set_reffral_percentage(uint256 _reffral_percentage) external onlyAdmin{
    require(_reffral_percentage > 0);
    reffral_percentage = _reffral_percentage;
  }
  function set_withdraw_refferal_percentage(uint256 _withdraw_refferal_percentage) external onlyAdmin{
    require(_withdraw_refferal_percentage > 0);
    withdraw_refferal_percentage = _withdraw_refferal_percentage;
  }
  function set_duration(uint256 _duration) external onlyAdmin{
    require(_duration > 0);
    duration = _duration;
  }

}