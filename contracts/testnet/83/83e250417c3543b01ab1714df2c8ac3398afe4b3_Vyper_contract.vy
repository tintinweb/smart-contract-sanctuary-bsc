"""
@title BEEP TOKEN SMART CONTRACT, CREATED TODAY 18TH OF OCTOBER, 2022.
@license MIT
@dev BEP20 TOKEN IMPLEMENTAION IN VYPER 
@notice This contract is written for the Beepo App Ecosystem  
@author Timileyin Pelumi

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
NAME : constant(String[32]) = "Beep" 
SYMBOL : constant(String[4]) = "BEEP"
DECIMALS  : constant(uint8) = 18 
TS :  constant(uint256) = 20000000


# Constructor

@external
def __init__():

    self.name = NAME
    self.symbol = SYMBOL
    self.decimals = DECIMALS

    initial_supply : uint256 =  TS  * 10 **  convert( DECIMALS, uint256)
    self.balanceOf[msg.sender] = initial_supply
    self.totalSupply =  initial_supply

    self.owner = msg.sender
    self.pauseTrade = False

    log Transfer(empty(address), msg.sender, initial_supply )


@external
@view
def tradingIsActive()->bool:
    assert msg.sender == self.owner
    return self.pauseTrade



@external
def pauseTrading( _status : bool)-> bool:
    assert msg.sender == self.owner

    if( self.pauseTrade == _status ):
        return True
    
    self.pauseTrade = _status
    return True

@external
def swapOwner( _new_owner : address):
    assert msg.sender == self.owner
    assert _new_owner != empty(address)

    self.owner = _new_owner


# Trading Functions 


@internal
def _transfer( _from : address,_to : address, _value : uint256):

    self.balanceOf[ _from ] -= _value
    self.balanceOf[ _to ] += _value

    log Transfer( _from , _to, _value )



@external
def transfer(  _to : address, _value : uint256)->bool:
    
    assert  not self.pauseTrade, "Trading is paused"

    self._transfer( msg.sender , _to, _value)

    return True



@external
def transferFrom( _from :address, _to : address, _value : uint256)->bool:

    assert  not self.pauseTrade, "Trading is paused"

   
    # Vyper does not support underflows and overflows, so the transaction will revert on insufficient allowance of the sender

    self.allowance[_from][msg.sender] -= _value

    self._transfer( _from , _to, _value)

    return True



@external
def approve( _spender : address, _value : uint256)-> bool:
    assert _spender != empty(address)
    
    self.allowance[msg.sender][_spender] = _value

    log Approval(msg.sender, _spender, _value)
    return True



@external
def increaseAllowance( _spender  :address, _value : uint256)->bool:
    assert _spender != empty(address)
    self.allowance[msg.sender][_spender] += _value

    log Approval(msg.sender, _spender, self.allowance[msg.sender][_spender] )
    return True


@external
def decreaseAllowance( _spender  :address, _value : uint256)->bool:
    assert _spender != empty(address)
    self.allowance[msg.sender][_spender] -= _value

    log Approval(msg.sender, _spender, self.allowance[msg.sender][_spender] )
    return True