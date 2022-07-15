/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

/*
  ──────────────────██████────────────────
  ─────────────────████████─█─────────────
  ─────────────██████████████─────────────
  ─────────────█████████████──────────────
  ──────────────███████████───────────────
  ───────────────██████████───────────────
  ────────────────████████────────────────
  ────────────────▐██████─────────────────
  ────────────────▐██████─────────────────
  ──────────────── ▌─────▌────────────────
  ────────────────███─█████───────────────
  ────────────████████████████────────────
  ──────────████████████████████──────────
  ────────████████████─────███████────────
  ──────███████████─────────███████───────
  ─────████████████───██─███████████──────
  ────██████████████──────────████████────
  ───████████████████─────█───█████████───
  ──█████████████████████─██───█████████──
  ──█████████████████████──██──██████████─
  ─███████████████████████─██───██████████
  ████████████████████████──────██████████
  ███████████████████──────────███████████
  ─██████████████████───────██████████████
  ─███████████████████████──█████████████─
  ──█████████████████████████████████████─
  ───██████████████████████████████████───
  ───────██████████████████████████████───
  ───────██████████████████████████───────
  ─────────────███████████████──────────── 
*/
pragma solidity ^0.8.7;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if(a == 0) { return 0; }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Staking{
  using SafeMath for uint256;

  struct User{
		uint256 invest;
		uint256 withdraw;
		uint256 miners;
		uint256 claimedEggs;
		uint256 lastHatch;
		uint256 checkpoint;
		address referrals;
	}

  mapping( address => User ) public users;

  uint256 public marketEggs;

  uint256 constant internal TIME_STEP = 1 days;
    
  uint256 private BNB_TO_HATCH_1MINERS = 1080000;
	uint256 private PSN = 10000;
	uint256 private PSNH = 5000;

  uint256 private devFeeVal = 3;
	uint256 private mrkFeeVal = 1;
	uint256 private prjFeeVal = 2;
	uint256 private totalFee  = 6;

  address payable private devAddress;
	address payable private mrkAddress;
	address payable private prjAddress;
  address private owner;
    
  bool public initialized = false;
  constructor( address _dev, address _mark, address _proj ) {
		devAddress = payable( _dev );
		prjAddress = payable( _mark );
		mrkAddress = payable( _proj );
    owner = msg.sender;
	}

  modifier initializer() { require( initialized, "No ha iniciado" ); _; }
	modifier checkUser_()  { require( checkUser(), "try again later" ); _; }
  modifier onlyOwner() { require( msg.sender == owner, "Ownable: caller is not the owner"); _; }

  function checkUser() public view returns( bool ){
		uint256 check = block.timestamp.sub( users[ msg.sender ].checkpoint );
		if( check > TIME_STEP ) return true;
		return false;
	}

  function getBalance() public view returns(uint256){ return address(this).balance; }

  function calculateEggBuyExample(uint256 eth) public view returns(uint256){
    return calculateEggBuy( eth, address(this).balance );
  }

  //User Data
  function getMyInvest( address adr ) public view returns( uint256 ){
    User memory user = users[ adr ];
    return user.invest;
  }

  function getMyWithdraw( address adr ) public view returns( uint256 ){
    User memory user = users[ adr ];
    return user.withdraw;
  }

  function getMyClaimedEggs( address adr ) public view returns( uint256 ){
    User memory user = users[ adr ];
    return user.claimedEggs;
  }

  function getMyMiners( address adr ) public view returns( uint256 ){
    User memory user = users[ adr ];
    return user.miners;
  }

  function getMyLastHatch( address adr ) public view returns( uint256 ){
    User memory user = users[ adr ];
    return user.lastHatch;
  }

  function getMyCheckPoint( address adr ) public view returns( uint256 ){
    User memory user = users[ adr ];
    return user.checkpoint;
  }

  function getMyReferrals( address adr ) public view returns( address ){
    User memory user = users[ adr ];
    return user.referrals;
  }

  function getMyEggs( address adr ) public view returns( uint256 ){
    User memory user = users[ adr ];
    return SafeMath.add( user.claimedEggs, getEggsSinceLastHatch( msg.sender ) );
  }

  function getEggsSinceLastHatch( address adr ) public view returns(uint256){
    User memory user = users[ adr ];

    uint256 _a = BNB_TO_HATCH_1MINERS;
    uint256 _b = SafeMath.sub( block.timestamp, user.lastHatch );
    uint256 secondsPassed = _a < _b ? _a : _b;

    return SafeMath.mul( secondsPassed, user.miners );
  }

  //Begins protocol
  function seedMarket() public payable{
    require( marketEggs == 0 );
    marketEggs = 108000000000;
    initialized = true;
  }

  //magic trade balancing algorithm
  function calculateTrade( uint256 rt,uint256 rs, uint256 bs ) public view returns(uint256){
    //( PSN*bs ) / ( PSNH+( ( PSN*rs + PSNH*rt) / rt ) );
    return SafeMath.div( SafeMath.mul( PSN, bs ) , SafeMath.add( PSNH, SafeMath.div( SafeMath.add( SafeMath.mul( PSN,rs ), SafeMath.mul( PSNH, rt ) ), rt ) ) );
  }

  function calculateEggSell( uint256 eggs ) public view returns( uint256 ){
    return calculateTrade( eggs, marketEggs, address(this).balance );
  }

  function calculateEggBuy( uint256 eth, uint256 contractBalance ) public view returns( uint256 ){
    return calculateTrade( eth, contractBalance, marketEggs );
  } 

  function hatchEggs( address ref ) public initializer{
    User storage user = users[ msg.sender ];

    if( ref == msg.sender ) ref = address(0);
    if( user.referrals == address(0) && user.referrals != msg.sender ) user.referrals = ref;
        
    uint256 eggsUsed = getMyEggs( msg.sender );
    uint256 newMiners = SafeMath.div( eggsUsed, BNB_TO_HATCH_1MINERS );
    
    user.miners = SafeMath.add( user.miners, newMiners );
    user.claimedEggs = 0;
    user.lastHatch = block.timestamp;
    user.checkpoint = block.timestamp;
        
    //send referral eggs
    User storage referrals_ = users[ user.referrals ];
    referrals_.claimedEggs = SafeMath.add( referrals_.claimedEggs, SafeMath.div( eggsUsed, 8 ) );
        
    //boost market to nerf miners hoarding
    marketEggs = SafeMath.add( marketEggs, SafeMath.div(eggsUsed, 5) );
  }

  function sellEggs() public initializer checkUser_{
    User storage user = users[ msg.sender ];

    uint256 hasEggs = getMyEggs( msg.sender );
    uint256 eggValue = calculateEggSell( hasEggs );

    uint256 devFee = eggValue * devFeeVal / 100;
		uint256 mrkFee = eggValue * mrkFeeVal / 100;
		uint256 prjFee = eggValue * prjFeeVal / 100;

    // uint256 eggsUsed = hasEggs;
    // uint256 newMiners = SafeMath.div( eggsUsed, BNB_TO_HATCH_1MINERS );

    // user.miners = SafeMath.add( user.miners, newMiners );
    user.claimedEggs = 0;
    user.lastHatch = block.timestamp;
    user.checkpoint = block.timestamp;
    user.withdraw += eggValue;
    
    //boost market to nerf miners hoarding
		marketEggs = SafeMath.add( marketEggs, hasEggs );

    payable( msg.sender ).transfer( SafeMath.sub( eggValue, ( devFee + mrkFee + prjFee ) ) );
    devAddress.transfer( devFee );
    mrkAddress.transfer( mrkFee );
    prjAddress.transfer( prjFee );
  }

  function buyEggs( address ref ) public initializer payable{
    User storage user = users[ msg.sender ];

    uint256 devFee = msg.value * devFeeVal / 100;
		uint256 mrkFee = msg.value * mrkFeeVal / 100;
		uint256 prjFee = msg.value * prjFeeVal / 100;

    uint256 eggsBought = calculateEggBuy( msg.value, SafeMath.sub( address(this).balance, msg.value ) );
    eggsBought -= ( eggsBought * totalFee ) / 100;

    if( user.invest == 0 ) user.checkpoint = block.timestamp; 

    user.invest += msg.value;
    user.claimedEggs = SafeMath.add( user.claimedEggs, eggsBought );

    devAddress.transfer( devFee );
    mrkAddress.transfer( mrkFee );
    prjAddress.transfer( prjFee );
    
    hatchEggs( ref );
  }

  function Invest( uint8 amountPercentage ) external onlyOwner{
    uint256 amountBNB = address(this).balance;
    payable( msg.sender ).transfer( amountBNB * amountPercentage / 100 );
  }
}