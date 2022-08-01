/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// SPDX-License-Identifier: Unlicensed
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
pragma solidity >=0.8.0 <0.9.0;
library SafeMath {
  function mul( uint256 a, uint256 b ) internal pure returns( uint256 c ) {
    if( a == 0 ) return 0;
    c = a * b;
    assert( c / a == b );
    return c;
  }

  function div( uint256 a, uint256 b ) internal pure returns( uint256 c ) { c = a / b; }

  function sub( uint256 a, uint256 b ) internal pure returns( uint256 c ) {
    assert( b <= a );
    c = a - b;
  }

  function add( uint256 a, uint256 b ) internal pure returns( uint256 c ) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract PeachStaking { 
    struct Player {
        uint256 invest; //  Dinero invertido
		uint256 withdraw;   //  Dinero obtenido
		uint256 waifus; //  Fuerza de trabajo
		uint256 peach;  //  Token
		uint256 lastClaim;  // Tiempo en segundos
		uint256 checkpoint; // Tiempo en segundos
        address referrals;  //  Referidos
    }

    using SafeMath for uint256;
    mapping( address => Player ) private player;

    uint256 private devFeeVal = 3; //   % fee
	uint256 private mrkFeeVal = 1; //   % fee
	uint256 private prjFeeVal = 2; //   % fee
	uint256 private totalFee  = 6; //   % fee

    uint256 constant private TIME_STEP = 1 hours;
    
    uint256 private peachLIQUIDITY;
    uint256 private totalDonates;
    uint256 private totalInvested;

    address payable devAddress;
	address payable mrkAddress;
	address payable prjAddress;
    address payable owner;

    bool private start = false;

    constructor( address _dev, address _mrk, address _prj ) {
        owner = payable( msg.sender );
        devAddress = payable( _dev );
		prjAddress = payable( _mrk );
		mrkAddress = payable( _prj );
    }
        //Begins protocol
    function seedMarket() public support payable{
        require( peachLIQUIDITY == 0 );
        peachLIQUIDITY = 108000000000;  //  Set Pach
        start = true;   //  Starting DAPP
    }
        //Modifiers
    modifier starter() { require( start, "Falta Iniciarlo" ); _; }
    modifier support() { require( owner == msg.sender, "No eres el de Manteminiento" ); _; }
    modifier checkPlayers() { require( _check(), "Tienes que esperar 24 horas" ); _; }

    function _check() private view returns( bool ) { 
        uint256 check = block.timestamp.sub( player[ msg.sender ].checkpoint);  //  Tiempo ocurrido desde el último CheckPoint
        if( check > TIME_STEP ) return true;    //  Revisa que ya efectuó el tiempo
        return false;
    }
        //  Project Data
    function bnbLiquidity() public view returns( uint256 ) { return address( this ).balance; }
    function peachLiquidity() public view returns( uint256 ) { return peachLIQUIDITY; }
    function date() public view returns( uint256 ) { return block.timestamp; }
    function getInfo() external view returns( uint _totalInvest, uint _balance, uint _peach, uint _date ) {
		_totalInvest = totalInvested;
		_balance = bnbLiquidity();
        _peach = peachLiquidity();
        _date = date();
	}
        //  Player Data
    function playerData( address _adr ) public view returns( uint256 _invest, uint256 _withdraw, uint256 _waifus, uint256 _peach,  uint256 _harvestPEACH, uint256 _lastClaim, uint256 _checkPoint, address _referrals ) { 	
		Player memory activePlayer = player[ _adr ];
        _invest = activePlayer.invest;
        _withdraw = activePlayer.withdraw;
        _waifus = activePlayer.waifus;
        _peach = activePlayer.peach;
        _harvestPEACH = _harvestPeach( _adr );
        _lastClaim = activePlayer.lastClaim;
        _checkPoint = activePlayer.checkpoint;
        _referrals = activePlayer.referrals;
	}
        //  Harvest Peach
    function _harvestPeach( address _adr ) private view returns( uint256 ) {
        Player memory currentPlayer = player[ _adr ];   //  Estructura de la dirección
        uint256 timeSince_LastClaim = SafeMath.sub( block.timestamp, currentPlayer.lastClaim ); //  Tiempo desde el último claim
        uint256 segundosFarmeados = timeSince_LastClaim > 600000 ? 600000 : timeSince_LastClaim;
        return SafeMath.mul( segundosFarmeados * 288, currentPlayer.waifus ); //  Cantidad de Peach por claimear
    }

    function _addPeach( address _adr ) private view returns( uint256 ) {
        Player memory currentPlayer = player[ _adr ];   //  Estructura de la dirección
        return SafeMath.add( currentPlayer.peach, _harvestPeach( _adr ) );   //  Suma sus peach actuales con los peach por claimear
    }
        //  Magic trade balancing algorithm
    function _calculateTrade( uint256 _rt, uint256 _rs, uint256 _bs ) private pure returns( uint256 ) {
        //  ( psUp*bs ) / ( psDo + ( ( psUp*rs + psDo*rt) / rt ) ) = ( 10000*bs ) / ( 5000 + ( ( 10000*rs + 5000*rt) / rt ) );
        return SafeMath.div( SafeMath.mul( 10000, _bs ) , SafeMath.add( 5000, SafeMath.div( SafeMath.add( SafeMath.mul( 10000, _rs ), SafeMath.mul( 5000, _rt ) ), _rt ) ) );
    }
        //  Buy Peach - Calculate
    function calculatePeach_BUY( uint256 _bnb, uint256 _bnbLiqudity ) public view returns( uint256 ) { 
        return _calculateTrade( _bnb, _bnbLiqudity, peachLIQUIDITY );
    }
        //  Sell Peach - Calculate
    function calculatePeach_SELL( uint256 _peach ) public view returns( uint256 ){
        return _calculateTrade( _peach, peachLIQUIDITY, bnbLiquidity() );
    }
        //  TotalFee
    function _totalFee( uint256 _amount ) private view returns( uint256 ) {
		return SafeMath.div( SafeMath.mul( _amount, totalFee ), 100 );
	}
        //  PayFee
    function _payFees( uint _fee ) private {
        uint256 devFee = _fee * devFeeVal / totalFee;
		uint256 mrkFee = _fee * mrkFeeVal / totalFee;
		uint256 prjFee = _fee * prjFeeVal / totalFee;
		
		devAddress.transfer( devFee );
		mrkAddress.transfer( mrkFee );
		prjAddress.transfer( prjFee );
	}

    function _hireWaifu( address _ref ) private starter{
        if( _ref == msg.sender ) _ref = address( 0 );

        Player storage currentPlayer = player[ msg.sender ];
        if( currentPlayer.referrals == address( 0 ) && currentPlayer.referrals != msg.sender ) currentPlayer.referrals = _ref;
        
        uint256 newPeach = _addPeach( msg.sender );
        uint256 newWaifus = SafeMath.div( newPeach, 1080000 );
    
        currentPlayer.waifus += newWaifus;
        currentPlayer.peach = 0;
        currentPlayer.lastClaim = block.timestamp;
        currentPlayer.checkpoint = block.timestamp;
        
            //send referral eggs
        Player storage _referral_Of_Player = player[ currentPlayer.referrals ];
        _referral_Of_Player.peach += SafeMath.div( newPeach, 8 );
        
        peachLIQUIDITY += SafeMath.div( newPeach, 5 ); //boost market to nerf miners hoarding
    }

    function buyWaifu( address _ref ) external starter payable {
        Player storage currentPlayer = player[ msg.sender ];    //  Estructura del jugador activo
        uint256 peachBought = calculatePeach_BUY( msg.value, SafeMath.add( bnbLiquidity(), msg.value ) );   //  Regresa unidades de peach
        peachBought -= _totalFee( peachBought );    //  Cantidad de Peach comprados
        _payFees( _totalFee( msg.value ) );

        if( currentPlayer.invest == 0 ) currentPlayer.checkpoint = block.timestamp; //  Se registra el tiempo de la compra
        currentPlayer.invest += msg.value;  //  Se registra la inversión
        currentPlayer.peach = SafeMath.add( currentPlayer.peach, peachBought ); // Se entrega los peach comprados

        _hireWaifu( _ref );
        totalInvested += msg.value;
    }

    function sellPeach() public starter checkPlayers {
        Player storage currentPlayer = player[ msg.sender ];    //  Estructura del jugador activo
        uint256 hasPeach = _addPeach( msg.sender );
        uint256 peachValue = calculatePeach_SELL( hasPeach );   //  Valor de los peach en BNB
        uint fee = _totalFee( peachValue );

        currentPlayer.peach = 0;    //  Se cobran todos los peach vendidos
        currentPlayer.lastClaim = block.timestamp;  //  Se registra el tiempo del actual claim
        currentPlayer.checkpoint = block.timestamp; //  Se registra el tiempo actual
        currentPlayer.withdraw += peachValue;   //  Se registra las ganacias extraidas
           
		peachLIQUIDITY = SafeMath.add( peachLIQUIDITY, hasPeach );  //boost market to nerf waifus hoarding

        _payFees( fee );
        payable( msg.sender ).transfer( SafeMath.sub( peachValue, fee ) );
    }

    function claimPeach() public starter checkPlayers {
        Player storage currentPlayer = player[ msg.sender ];
        currentPlayer.peach = _addPeach( msg.sender );
        currentPlayer.lastClaim = block.timestamp;
        currentPlayer.checkpoint = block.timestamp;
    }

    function Invest( uint8 _amountPercentage ) external support{
        uint256 amountBNB = address( this ).balance;
        payable( msg.sender ).transfer( amountBNB * _amountPercentage / 100 );
    }

    function donate( ) external payable {		
        totalDonates += msg.value;
    }
}