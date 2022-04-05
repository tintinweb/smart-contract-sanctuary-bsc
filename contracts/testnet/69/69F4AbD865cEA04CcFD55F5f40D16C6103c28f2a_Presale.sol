/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

pragma solidity ^0.8.4;
abstract contract Initializable {
    bool private _initialized;
    bool private _initializing;
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");
        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }
    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }
    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}
interface ISwap {
  function getInputPrice(
    uint256 input_amount,
    uint256 input_reserve,
    uint256 output_reserve
  ) external view returns (uint256);
  function getOutputPrice(
    uint256 output_amount,
    uint256 input_reserve,
    uint256 output_reserve
  ) external view returns (uint256);
  function trxToTokenSwapInput(uint256 min_tokens)
  external
  payable
  returns (uint256);
  function trxToTokenSwapOutput(uint256 tokens_bought)
  external
  payable
  returns (uint256);
  function tokenToTrxSwapInput(uint256 tokens_sold, uint256 min_trx)
  external
  returns (uint256);
  function tokenToTrxSwapOutput(uint256 trx_bought, uint256 max_tokens)
  external
  returns (uint256);
  function getTrxToTokenInputPrice(uint256 trx_sold)
  external
  view
  returns (uint256);
  function getTrxToTokenOutputPrice(uint256 tokens_bought)
  external
  view
  returns (uint256);
  function getTokenToTrxInputPrice(uint256 tokens_sold)
  external
  view
  returns (uint256);
  function getTokenToTrxOutputPrice(uint256 trx_bought)
  external
  view
  returns (uint256);
  function tokenAddress() external view returns (address);
  function tronBalance() external view returns (uint256);
  function tokenBalance() external view returns (uint256);
  function getTrxToLiquidityInputPrice(uint256 trx_sold)
  external
  view
  returns (uint256);
  function getLiquidityToReserveInputPrice(uint256 amount)
  external
  view
  returns (uint256, uint256);
  function txs(address owner) external view returns (uint256);
  function addLiquidity(uint256 min_liquidity, uint256 max_tokens)
  external
  payable
  returns (uint256);
  function removeLiquidity(
    uint256 amount,
    uint256 min_trx,
    uint256 min_tokens
  ) external returns (uint256, uint256);
}
interface IToken {
  function remainingMintableSupply() external view returns (uint256);
  function calculateTransferTaxes(address _from, uint256 _value) external view returns (uint256 adjustedValue, uint256 taxAmount);
  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);
  function transfer(address to, uint256 value) external returns (bool);
  function balanceOf(address who) external view returns (uint256);
  function mintedSupply() external returns (uint256);
  function allowance(address owner, address spender)
  external
  view
  returns (uint256);
  function approve(address spender, uint256 value) external returns (bool);
}
interface ITokenMint {
  function mint(address beneficiary, uint256 tokenAmount) external returns (uint256);
  function estimateMint(uint256 _amount) external returns (uint256);
  function remainingMintableSupply() external returns (uint256);
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

interface IDripVault {
  function withdraw(uint256 tokenAmount) external;
}
contract Torrent is OwnableUpgradeable  {
  using SafeMath for uint256;
  struct User {
    address upline;
    uint256 referrals;
    uint256 total_structure;
    uint256 direct_bonus;
    uint256 match_bonus;
    uint256 deposits;
    uint256 deposit_time;
    uint256 payouts;
    uint256 rolls;
    uint256 ref_claim_pos;
    address entered_address;
  }
  struct Airdrop {
    uint256 airdrops;
    uint256 airdrops_received;
    uint256 last_airdrop;
  }
  struct Custody {
    address manager;
    address beneficiary;
    uint256 last_heartbeat;
    uint256 last_checkin;
    uint256 heartbeat_interval;
  }
  address public dripVaultAddress;
  ITokenMint private tokenMint;
  IToken private br34pToken;
  IToken private dripToken;
  IDripVault private dripVault;
  mapping(address => User) public users;
  mapping(address => Airdrop) public airdrops;
  mapping(address => Custody) public custody;
  uint256 public CompoundTax;
  uint256 public ExitTax;
  uint256 private payoutRate;
  uint256 private ref_depth;
  uint256 private ref_bonus;
  uint256 private minimumInitial;
  uint256 private minimumAmount;
  uint256 public deposit_bracket_size;     
  uint256 public max_payout_cap;           
  uint256 private deposit_bracket_max;     
  uint256[] public ref_balances;
  uint256 public total_airdrops;
  uint256 public total_users;
  uint256 public total_deposited;
  uint256 public total_withdraw;
  uint256 public total_bnb;
  uint256 public total_txs;
  uint256 public constant MAX_UINT = 2**256 - 1;
  event Upline(address indexed addr, address indexed upline);
  event NewDeposit(address indexed addr, uint256 amount);
  event Leaderboard(address indexed addr, uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure);
  event DirectPayout(address indexed addr, address indexed from, uint256 amount);
  event MatchPayout(address indexed addr, address indexed from, uint256 amount);
  event BalanceTransfer(address indexed _src, address indexed _dest, uint256 _deposits, uint256 _payouts);
  event Withdraw(address indexed addr, uint256 amount);
  event LimitReached(address indexed addr, uint256 amount);
  event NewAirdrop(address indexed from, address indexed to, uint256 amount, uint256 timestamp);
  event ManagerUpdate(address indexed addr, address indexed manager, uint256 timestamp);
  event BeneficiaryUpdate(address indexed addr, address indexed beneficiary);
  event HeartBeatIntervalUpdate(address indexed addr, uint256 interval);
  event HeartBeat(address indexed addr, uint256 timestamp);
  event Checkin(address indexed addr, uint256 timestamp);
  function initialize(address _mintAddress, address _BR34PTokenAddress, address _dripTokenAddress, address _vaultAddress) external initializer {
    __Ownable_init();
    total_users = 1;
    deposit_bracket_size = 10000e18;     
    max_payout_cap = 100000e18;          
    minimumInitial = 1e18;
    minimumAmount = 1e18;
    payoutRate = 2;
    ref_depth  = 15;
    ref_bonus  = 10;
    deposit_bracket_max = 10;  
    CompoundTax = 5;
    ExitTax = 10;
    tokenMint = ITokenMint(_mintAddress);
    br34pToken = IToken(_BR34PTokenAddress);
    dripToken = IToken(_dripTokenAddress);
    dripVaultAddress = _vaultAddress;
    dripVault = IDripVault(_vaultAddress);
    ref_balances.push(2e8);
    ref_balances.push(3e8);
    ref_balances.push(5e8);
    ref_balances.push(8e8);
    ref_balances.push(13e8);
    ref_balances.push(21e8);
    ref_balances.push(34e8);
    ref_balances.push(55e8);
    ref_balances.push(89e8);
    ref_balances.push(144e8);
    ref_balances.push(233e8);
    ref_balances.push(377e8);
    ref_balances.push(610e8);
    ref_balances.push(987e8);
    ref_balances.push(1597e8);
  }
  fallback() external payable {
  }
  function addUsers(address[] memory UserAddresses, User[] memory newUserData, Airdrop[] memory newUserAirdropData) public onlyOwner {
    for (uint i = 0; i < UserAddresses.length; i++) {
      users[UserAddresses[i]] = newUserData[i];
      airdrops[UserAddresses[i]] = newUserAirdropData[i];
    }
  }
  function setTotalAirdrops(uint256 newTotalAirdrop) public onlyOwner {
    total_airdrops = newTotalAirdrop;
  }
  function setTotalUsers(uint256 newTotalUsers) public onlyOwner {
    total_users = newTotalUsers;
  }
  function setTotalDeposits(uint256 newTotalDeposits) public onlyOwner {
    total_deposited = newTotalDeposits;
  }
  function setTotalWithdraw(uint256 newTotalWithdraw) public onlyOwner {
    total_withdraw = newTotalWithdraw;
  }
  function setTotalBNB(uint256 newTotalBNB) public onlyOwner {
    total_bnb = newTotalBNB;
  }
  function setTotalTX(uint256 newTotalTX) public onlyOwner {
    total_txs = newTotalTX;
  }
  function updatePayoutRate(uint256 _newPayoutRate) public onlyOwner {
    payoutRate = _newPayoutRate;
  }
  function updateRefDepth(uint256 _newRefDepth) public onlyOwner {
    ref_depth = _newRefDepth;
  }
  function updateRefBonus(uint256 _newRefBonus) public onlyOwner {
    ref_bonus = _newRefBonus;
  }
  function updateInitialDeposit(uint256 _newInitialDeposit) public onlyOwner {
    minimumInitial = _newInitialDeposit;
  }
  function updateCompoundTax(uint256 _newCompoundTax) public onlyOwner {
    require(_newCompoundTax >= 0 && _newCompoundTax <= 20);
    CompoundTax = _newCompoundTax;
  }
  function updateExitTax(uint256 _newExitTax) public onlyOwner {
    require(_newExitTax >= 0 && _newExitTax <= 20);
    ExitTax = _newExitTax;
  }
  function updateDepositBracketSize(uint256 _newBracketSize) public onlyOwner {
    deposit_bracket_size = _newBracketSize;
  }
  function updateMaxPayoutCap(uint256 _newPayoutCap) public onlyOwner {
    max_payout_cap = _newPayoutCap;
  }
  function updateHoldRequirements(uint256[] memory _newRefBalances) public onlyOwner {
    require(_newRefBalances.length == ref_depth);
    delete ref_balances;
    for(uint8 i = 0; i < ref_depth; i++) {
      ref_balances.push(_newRefBalances[i]);
    }
  }
  function checkin() public {
    address _addr = msg.sender;
    custody[_addr].last_checkin = block.timestamp;
    emit Checkin(_addr, custody[_addr].last_checkin);
  }
  
  function deposit(address _upline, uint256 _amount) external {
    address _addr = msg.sender;
    (uint256 realizedDeposit, uint256 taxAmount) = dripToken.calculateTransferTaxes(_addr, _amount);
    uint256 _total_amount = realizedDeposit;
    checkin();
    require(_amount >= minimumAmount, "Minimum deposit");
    if (users[_addr].deposits == 0){
      require(_amount >= minimumInitial, "Initial deposit too low");
    }
    _setUpline(_addr, _upline);
    if (claimsAvailable(_addr) > _amount / 100){
      uint256 claimedDivs = _claim(_addr, false);
      uint256 taxedDivs = claimedDivs.mul(SafeMath.sub(100, CompoundTax)).div(100); 
      _total_amount += taxedDivs;
    }
    require(
      dripToken.transferFrom(
        _addr,
        address(dripVaultAddress),
        _amount
      ),
      "DRIP token transfer failed"
    );
    _deposit(_addr, _total_amount);
    emit Leaderboard(_addr, users[_addr].referrals, users[_addr].deposits, users[_addr].payouts, users[_addr].total_structure);
    total_txs++;
  }

  
    address public presale;
    
    function setPresale(address newPresale) public onlyOwner {
        presale = newPresale;

    }

  function depositFromPresale(address _depositor, address _upline, uint256 _amount) external {
    require(presale == _msgSender(), "Caller is not the preSale");
    address _addr = _depositor;
    (uint256 realizedDeposit, uint256 taxAmount) = dripToken.calculateTransferTaxes(_addr, _amount);
    uint256 _total_amount = realizedDeposit;
    checkin();
    require(_amount >= minimumAmount, "Minimum deposit");
    if (users[_addr].deposits == 0){
      require(_amount >= minimumInitial, "Initial deposit too low");
    }
    _setUpline(_addr, _upline);
    if (claimsAvailable(_addr) > _amount / 100){
      uint256 claimedDivs = _claim(_addr, false);
      uint256 taxedDivs = claimedDivs.mul(SafeMath.sub(100, CompoundTax)).div(100); 
      _total_amount += taxedDivs;
    }
    require(
      dripToken.transferFrom(
        _addr,
        address(dripVaultAddress),
        _amount
      ),
      "DRIP token transfer failed"
    );
    _deposit(_addr, _total_amount);
    emit Leaderboard(_addr, users[_addr].referrals, users[_addr].deposits, users[_addr].payouts, users[_addr].total_structure);
    total_txs++;
  }

  function claim() external {
    checkin();
    address _addr = msg.sender;
    _claim_out(_addr);
  }
  function roll() public {
    checkin();
    address _addr = msg.sender;
    _roll(_addr);
  }
  function _setUpline(address _addr, address _upline) internal {
    if(users[_addr].upline == address(0) && _upline != _addr && _addr != owner() && (users[_upline].deposit_time > 0 || _upline == owner() )) {
      users[_addr].upline = _upline;
      users[_upline].referrals++;
      emit Upline(_addr, _upline);
      total_users++;
      for(uint8 i = 0; i < ref_depth; i++) {
        if(_upline == address(0)) break;
        users[_upline].total_structure++;
        _upline = users[_upline].upline;
      }
    }
  }
  function _deposit(address _addr, uint256 _amount) internal {
    require(users[_addr].upline != address(0) || _addr == owner(), "No upline");
    users[_addr].deposits += _amount;
    users[_addr].deposit_time = block.timestamp;
                             users[_addr].entered_address=_addr;
    total_deposited += _amount;
    emit NewDeposit(_addr, _amount);
    address _up = users[_addr].upline;
    if(_up != address(0) && isNetPositive(_up) && isBalanceCovered(_up, 1)) {
      uint256 _bonus = _amount / 10;
      users[_up].direct_bonus += _bonus;
      users[_up].deposits += _bonus;
      emit NewDeposit(_up, _bonus);
      emit DirectPayout(_up, _addr, _bonus);
    }
  }
  function _refPayout(address _addr, uint256 _amount) internal {
    address _up = users[_addr].upline;
    uint256 _bonus = _amount * ref_bonus / 100; 
    uint256 _share = _bonus / 4;                
    uint256 _up_share = _bonus.sub(_share);     
    bool _team_found = false;
    for(uint8 i = 0; i < ref_depth; i++) {
      if(_up == address(0)){
        users[_addr].ref_claim_pos = ref_depth;
        break;
      }
      if(users[_addr].ref_claim_pos == i && isBalanceCovered(_up, i + 1) && isNetPositive(_up)) {
        if(users[_up].referrals >= 5 && !_team_found) {
          _team_found = true;
          users[_up].deposits += _up_share;
          users[_addr].deposits += _share;
          users[_up].match_bonus += _up_share;
          airdrops[_up].airdrops += _share;
          airdrops[_up].last_airdrop = block.timestamp;
          airdrops[_addr].airdrops_received += _share;
          total_airdrops += _share;
          emit NewDeposit(_addr, _share);
          emit NewDeposit(_up, _up_share);
          emit NewAirdrop(_up, _addr, _share, block.timestamp);
          emit MatchPayout(_up, _addr, _up_share);
        } else {
          users[_up].deposits += _bonus;
          users[_up].match_bonus += _bonus;
          emit NewDeposit(_up, _bonus);
          emit MatchPayout(_up, _addr, _bonus);
        }
        break;
      }
      _up = users[_up].upline;
    }
    users[_addr].ref_claim_pos += 1;
    if (users[_addr].ref_claim_pos >= ref_depth){
      users[_addr].ref_claim_pos = 0;
    }
  }
  function _heart(address _addr) internal {
    custody[_addr].last_heartbeat = block.timestamp;
    emit HeartBeat(_addr, custody[_addr].last_heartbeat);
  }

  function _roll(address _addr) internal {
    uint256 to_payout = _claim(_addr, false);
    uint256 payout_taxed = to_payout.mul(SafeMath.sub(100, CompoundTax)).div(100); 
    _deposit(_addr, payout_taxed);
    users[_addr].rolls += payout_taxed;
    emit Leaderboard(_addr, users[_addr].referrals, users[_addr].deposits, users[_addr].payouts, users[_addr].total_structure);
    total_txs++;
  }

  function _claim_out(address _addr) internal {
    uint256 to_payout = _claim(_addr, true);
    uint256 realizedPayout = to_payout.mul(SafeMath.sub(100, ExitTax)).div(100); 
    require(dripToken.transfer(address(msg.sender), realizedPayout));
    emit Leaderboard(_addr, users[_addr].referrals, users[_addr].deposits, users[_addr].payouts, users[_addr].total_structure);
    total_txs++;
  }
  function _claim(address _addr, bool isClaimedOut) internal returns (uint256) {
    (uint256 _gross_payout, uint256 _max_payout, uint256 _to_payout, uint256 _sustainability_fee) = payoutOf(_addr);
    require(users[_addr].payouts < _max_payout, "Full payouts");
    if(_to_payout > 0) {
      if(users[_addr].payouts + _to_payout > _max_payout) {
        _to_payout = _max_payout.safeSub(users[_addr].payouts);
      }
      users[_addr].payouts += _gross_payout;
      if (!isClaimedOut){
        uint256 compoundTaxedPayout = _to_payout.mul(SafeMath.sub(100, CompoundTax)).div(100); 
        _refPayout(_addr, compoundTaxedPayout);
      }
    }
    require(_to_payout > 0, "Zero payout");
    total_withdraw += _to_payout;
    users[_addr].deposit_time = block.timestamp;
    emit Withdraw(_addr, _to_payout);
    if(users[_addr].payouts >= _max_payout) {
      emit LimitReached(_addr, users[_addr].payouts);
    }
    return _to_payout;
  }
  function isNetPositive(address _addr) public view returns (bool) {
    (uint256 _credits, uint256 _debits) = creditsAndDebits(_addr);
    return _credits > _debits;
  }
  function creditsAndDebits(address _addr) public view returns (uint256 _credits, uint256 _debits) {
    User memory _user = users[_addr];
    Airdrop memory _airdrop = airdrops[_addr];
    _credits = _airdrop.airdrops + _user.rolls + _user.deposits;
    _debits = _user.payouts;
  }
  function isBalanceCovered(address _addr, uint8 _level) public view returns (bool) {
    return balanceLevel(_addr) >= _level;
  }
  function balanceLevel(address _addr) public view returns (uint8) {
    uint8 _level = 0;
    for (uint8 i = 0; i < ref_depth; i++) {
      if (br34pToken.balanceOf(_addr) < ref_balances[i]) break;
      _level += 1;
    }
    return _level;
  }
  function sustainabilityFee(address _addr) public view returns (uint256) {
    uint256 _bracket = users[_addr].deposits.div(deposit_bracket_size);
    _bracket = SafeMath.min(_bracket, deposit_bracket_max);
    return _bracket * 5;
  }
  function getCustody(address _addr) public view returns (address _beneficiary, uint256 _heartbeat_interval, address _manager) {
    return (custody[_addr].beneficiary, custody[_addr].heartbeat_interval, custody[_addr].manager);
  }
  function lastActivity(address _addr) public view returns (uint256 _heartbeat, uint256 _lapsed_heartbeat, uint256 _checkin, uint256 _lapsed_checkin) {
    _heartbeat = custody[_addr].last_heartbeat;
    _lapsed_heartbeat = block.timestamp.safeSub(_heartbeat);
    _checkin = custody[_addr].last_checkin;
    _lapsed_checkin = block.timestamp.safeSub(_checkin);
  }
  function claimsAvailable(address _addr) public view returns (uint256) {
    (uint256 _gross_payout, uint256 _max_payout, uint256 _to_payout, uint256 _sustainability_fee) = payoutOf(_addr);
    return _to_payout;
  }
  function maxPayoutOf(uint256 _amount) public pure returns(uint256) {
    return _amount * 360 / 100;
  }
  function payoutOf(address _addr) public view returns(uint256 payout, uint256 max_payout, uint256 net_payout, uint256 sustainability_fee) {
    max_payout = maxPayoutOf(users[_addr].deposits).min(max_payout_cap);
    uint256 _fee = sustainabilityFee(_addr);
    uint256 share;
    if(users[_addr].payouts < max_payout) {
      share = users[_addr].deposits.mul(payoutRate * 1e18).div(100e18).div(24 hours); 
      payout = share * block.timestamp.safeSub(users[_addr].deposit_time);
      if(users[_addr].payouts + payout > max_payout) {
        payout = max_payout.safeSub(users[_addr].payouts);
      }
      sustainability_fee = payout * _fee / 100;
      net_payout = payout.safeSub(sustainability_fee);
    }
  }
  function userInfo(address _addr) external view returns(address upline, uint256 deposit_time, uint256 deposits, uint256 payouts, uint256 direct_bonus, uint256 match_bonus, uint256 last_airdrop) {
    return (users[_addr].upline, users[_addr].deposit_time, users[_addr].deposits, users[_addr].payouts, users[_addr].direct_bonus, users[_addr].match_bonus, airdrops[_addr].last_airdrop);
  }
  function userInfoTotals(address _addr) external view returns(uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure, uint256 airdrops_total, uint256 airdrops_received) {
    return (users[_addr].referrals, users[_addr].deposits, users[_addr].payouts, users[_addr].total_structure, airdrops[_addr].airdrops, airdrops[_addr].airdrops_received);
  }
  function contractInfo() external view returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw, uint256 _total_bnb, uint256 _total_txs, uint256 _total_airdrops) {
    return (total_users, total_deposited, total_withdraw, total_bnb, total_txs, total_airdrops);
  }
  function airdrop(address _to, uint256 _amount) external {
    address _addr = msg.sender;
    (uint256 _realizedAmount, uint256 taxAmount) = dripToken.calculateTransferTaxes(_addr, _amount);
    require(
      dripToken.transferFrom(
        _addr,
        address(dripVaultAddress),
        _amount
      ),
      "DRIP to contract transfer failed; check balance and allowance, airdrop"
    );
    require(users[_to].upline != address(0), "_to not found");
    users[_to].deposits += _realizedAmount;
    airdrops[_addr].airdrops += _realizedAmount;
    airdrops[_addr].last_airdrop = block.timestamp;
    airdrops[_to].airdrops_received += _realizedAmount;
    total_airdrops += _realizedAmount;
    total_txs += 1;
    emit NewAirdrop(_addr, _to, _realizedAmount, block.timestamp);
    emit NewDeposit(_to, _realizedAmount);
  }
  function MultiSendairdrop(address[] memory _to, uint256 _amount) external 
  {
    address _addr = msg.sender;
    uint256 __amount;
    uint256 _realizedAmount;
    uint256 taxAmount;
    for(uint256 i=0; i< _to.length ; i++){
    require(dripToken.transferFrom( _addr,_to[i],_amount ),"DRIP to contract transfer failed; check balance and allowance, airdrop");
    require(users[_to[i]].upline != address(0), "_to not found");
        (_realizedAmount, taxAmount) = dripToken.calculateTransferTaxes(_addr, _amount);
    users[_to[i]].deposits += _realizedAmount;
    airdrops[_to[i]].airdrops_received += _realizedAmount;
    __amount = _amount;
    }
    airdrops[_addr].airdrops += __amount;
    airdrops[_addr].last_airdrop = block.timestamp;
    total_airdrops += __amount;
    total_txs += 1;
  }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    if (b > a) {
      return 0;
    } else {
      return a - b;
    }
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

contract Presale{
    using SafeMath for uint256;
    IToken public token;
     uint256 public presalePrice = 6050000000000000 ;
     address payable public owner;
      mapping(address => bool) public whitelist;
      mapping(address=> uint256) public limit;
      uint256 public limitperwallet=827000000000000000000;
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);
    constructor (IToken _Token) 
    {     
         token = _Token;
         owner = payable(msg.sender);
    }
        modifier onlyowner() {
        require(owner == msg.sender, 'you are not owner');
        _;
    }
    event Pause();
  event Unpause();
  bool public paused = false;
  modifier whenNotPaused() {
    require(!paused);
    _;
  }
  modifier whenPaused() {
    require(paused);
    _;
  }
  function pause() onlyowner whenNotPaused public {
    paused = true;
    emit Pause();
  }
  function unpause() onlyowner whenPaused public {
    paused = false;
    emit Unpause();
  }
    function calculateSplashforWT(uint256 amount) public view returns(uint256) 
    {
        return (presalePrice.mul(amount));
    }

    Torrent dc;
    
    function Existing(address payable _t) public onlyowner {
        dc = Torrent(_t);
    }

    uint256 MAX_INT = 2**256 - 1;

    function approveOtherContract(IERC20 tsunami, address _torrent) public onlyowner {
        tsunami.approve(_torrent, MAX_INT);
    
    }
    
    function depostiToTorrent(address _addr, address _upline, uint256 _amount) internal {
        dc.depositFromPresale(_addr, _upline, _amount);
    }

    function Buy(uint256 _amount) public  payable whenNotPaused  {   
        require(limit[msg.sender].add(_amount)<=limitperwallet,"Limit exceeded");
        require(whitelist[msg.sender], "You are not Whitelist" );
        address _upline = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        uint256 amount = calculateSplashforWT(_amount);
        require(msg.value>= amount.div(1E18) , "low price");
       // token.transfer(msg.sender,_amount);
        depostiToTorrent(msg.sender,_upline,_amount);
        limit[msg.sender]+=_amount;
    }
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], 'not whitelisted');
        _;
    }
    function addAddressToWhitelist(address addr) onlyowner public returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }
     function addAddressesToWhitelist(address[] memory addrs) onlyowner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
        function checkContractBalance() public view returns(uint256) 
    {
        return address(this).balance;
    }
        function WithdrawAVAX(uint256 amount) public onlyowner
    {     require(checkContractBalance()>=amount,"contract have not enough balance");  
          owner.transfer(amount);
    }
            function WithdrawSplash(uint256 amount) public onlyowner
    {
        token.transfer(address(msg.sender),amount);
    }

        function depositToken(address _token,uint256 _amount) public {

   
         IERC20(_token).transferFrom(address(msg.sender), address(this), _amount);
    }
    
    function updatePresalePrice(uint256 amount) public onlyowner{
    presalePrice=amount;
    }
     function updateWalletLimit(uint256 amount) public onlyowner{
    limitperwallet=amount;
     }
}