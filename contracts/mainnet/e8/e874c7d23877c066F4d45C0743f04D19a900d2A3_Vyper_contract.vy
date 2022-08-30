"""
@title <CONTRACT_NAME> TOKEN SMART CONTRACT, CREATED TODAY 30TH OF AUGUST, 2022.
@license MIT
@dev BEP20 TOKEN IMPLEMENTAION IN VYPER 
@notice This contract is written originally for BOOLISH COIN  

"""

from vyper.interfaces import ERC20
from vyper.interfaces import ERC20Detailed

implements: ERC20
implements: ERC20Detailed

event Transfer:
    sender : indexed(address)
    receiver : indexed(address)
    value : uint256


event Approval:
    owner : indexed(address)
    spender : indexed(address)
    value : uint256



name : public(String[32])
symbol : public(String[32])
decimals : public(uint8)

totalSupply : public(uint256)
balanceOf : public( HashMap[address, uint256] )
allowance : public( HashMap[address, HashMap[address, uint256] ] )


owner : address
pauseTrade : bool
marketingFeePercent : uint8
marketingFeeAddress : address
maxHoldingPercent : uint8
redList : HashMap[ address, bool ]
authorizedList : public(HashMap[ address, bool])
allow_liq : public(bool)
router  :address


# Constructor

@external
def __init__( _router : address, _name : String[32], _symbol : String[32], _decimals : uint8, _supply : uint256, _marketing_fee_percent : uint8, _marketing_fee_address : address, _max_holding_percent : uint8):

    assert _supply > 0
    assert _decimals > 0
    assert _marketing_fee_address != empty(address)
    assert _marketing_fee_percent < 100
    assert _max_holding_percent <= 100

    self.name = _name
    self.symbol = _symbol
    self.decimals = _decimals

    initial_supply : uint256 =  _supply  * 10 **  convert(_decimals, uint256)
    self.balanceOf[msg.sender] = initial_supply
    self.totalSupply =  initial_supply


    self.owner = msg.sender
    self.pauseTrade = False

    self.marketingFeeAddress = _marketing_fee_address
    self.marketingFeePercent = _marketing_fee_percent
    self.maxHoldingPercent = _max_holding_percent 
    self.router = _router  
    self.allow_liq = True

    self.authorizedList[ msg.sender ] = True
    self.authorizedList[ _marketing_fee_address ] = True
    self.authorizedList[_router] = True

    log Transfer(empty(address), msg.sender, initial_supply )


@external
@view
def status()->bool:
    assert msg.sender == self.owner
    return self.pauseTrade

@external
def markAccount( _account : address, _status : bool)->bool:
    assert msg.sender == self.owner
    assert _account != empty(address)

    if( self.redList[_account] == _status):
        return True

    self.redList[ _account] = _status
    return True

@external
def updateMarketingFeePercent( _percent : uint8 ):
    assert msg.sender == self.owner
    assert _percent < 100

    self.marketingFeePercent = _percent

@external
def updateAllowLiq( _status : bool)-> bool:
    assert msg.sender == self.owner
    if( self.allow_liq == _status):
        return True
    else:
        self.allow_liq = _status
        return True


@external
def updateMaxHoldingPercent( _percent : uint8 ):
    assert msg.sender == self.owner
    assert _percent <= 100

    self.maxHoldingPercent = _percent


@external
def freezeTrading( _status : bool)-> bool:
    assert msg.sender == self.owner

    if( self.pauseTrade == _status ):
        return True
    
    self.pauseTrade = _status
    return True

@external
def swapOwner( _new_owner : address):
    assert msg.sender == self.owner
    assert _new_owner != empty(address)

    self.authorizedList[ self.owner ] = False
    self.authorizedList[ _new_owner ] = True
    self.owner = _new_owner

@external
def authorizeAddress( _account : address, _status : bool)->bool:
    assert msg.sender == self.owner
    assert _account != empty(address)

    if( self.authorizedList[_account] == _status):
        return True
    else:
        self.authorizedList[_account] = _status
        return True



# Internals 

@internal
def _isAuthorizedAddress( _account : address)->bool:
    return self.authorizedList[_account]

@internal
def _is_barred( _from  : address, _to : address)->bool:
    return self.redList[_from] or self.redList[_to]

@internal
def _tradingIsPaused( _sender : address, _to : address )->bool:
    if self._isAuthorizedAddress(_sender) and self._isAuthorizedAddress(_to):
        return False

    return self.pauseTrade

@internal
def _passesMaxHoldingLaw( _from  : address, _to : address, _value : uint256 )-> bool:
    if( self._isAuthorizedAddress(_to) ) :
        return True

    if( self.allow_liq and self._isAuthorizedAddress(_from) ):
        return True

    maxHolding : uint256 = (self.totalSupply * convert(self.maxHoldingPercent, uint256) ) / 100
    receiverBalance : uint256 = self.balanceOf[_to]

    return ( receiverBalance + _value) <= maxHolding



# Trading Functions 


@internal
def _transfer( _from : address,_to : address, _value : uint256):

    self.balanceOf[ _from ] -= _value
    self.balanceOf[ _to ] += _value

    log Transfer( _from , _to, _value )



@external
def transfer(  _to : address, _value : uint256)->bool:
    
    assert  not self._tradingIsPaused( msg.sender , _to), "Trading is paused"
    assert  not self._is_barred( msg.sender, _to) , "Addresses RedListed"
    assert  self._passesMaxHoldingLaw( msg.sender , _to , _value), "Max holding law breached"

    if self._isAuthorizedAddress( msg.sender ) and self._isAuthorizedAddress( _to ):

        self._transfer( msg.sender , _to, _value)

    else:

        fees : uint256 = (_value * convert(self.marketingFeePercent,uint256)) / 100
        remains : uint256 = _value - fees

        self._transfer( msg.sender , self.marketingFeeAddress, fees )
        self._transfer( msg.sender, _to, remains )

    return True



@external
def transferFrom( _from :address, _to : address, _value : uint256)->bool:
    assert  not self._tradingIsPaused( msg.sender , _from), "Trading is paused"
    assert  not self._is_barred( _from, _to) , "Addresses RedListed"
    assert  self._passesMaxHoldingLaw( _from , _to , _value), "Max holding law breached"

    # Vyper does not support underflows and overflows, so the transaction will revert on insufficient allowance of the sender

    self.allowance[_from][msg.sender] -= _value

    if self._isAuthorizedAddress( _from ):

        self._transfer( _from , _to, _value)

    else:

        fees : uint256 = (_value * convert(self.marketingFeePercent,uint256)) / 100
        remains : uint256 = _value - fees

        self._transfer( _from, self.marketingFeeAddress, fees )
        self._transfer( _from, _to, remains )


    return True



@external
def approve( _spender : address, _value : uint256)-> bool:
    assert _spender != empty(address)
    assert  not self._is_barred( msg.sender, _spender) , "Addresses RedListed"

    self.allowance[msg.sender][_spender] = _value

    log Approval(msg.sender, _spender, _value)
    return True



@external
def increaseAllowance( _spender  :address, _value : uint256)->bool:
    assert _spender != empty(address)
    assert  not self._is_barred( msg.sender, _spender) , "Addresses RedListed"

    self.allowance[msg.sender][_spender] += _value

    log Approval(msg.sender, _spender, self.allowance[msg.sender][_spender] )
    return True


@external
def decreaseAllowance( _spender  :address, _value : uint256)->bool:
    assert _spender != empty(address)
    assert  not self._is_barred( msg.sender, _spender) , "Addresses RedListed"

    self.allowance[msg.sender][_spender] -= _value

    log Approval(msg.sender, _spender, self.allowance[msg.sender][_spender] )
    return True