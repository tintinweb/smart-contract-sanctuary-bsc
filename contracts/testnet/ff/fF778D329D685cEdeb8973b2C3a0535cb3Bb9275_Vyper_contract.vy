"""

@title THE BEEPO ECOSYSTEM TOKEN SMART CONTRACT, CREATED TODAY 23RD OF AUGUST, 2023.
@license MIT
@author TIMILEYIN PELUMI - Chief Technical Officer, BEEPO.
@dev ERC20 TOKEN IMPLEMENTAION IN VYPER CODE
@notice This contract is written originally for the Beepo ecosystem.  

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

balanceOf : public(HashMap[address,uint256])
allowance : public(HashMap[address, HashMap[address, uint256 ]])
totalSupply : public(uint256)
minter : address
trading_status : bool




@external
def __init__(  _name : String[32], _symbol : String[32], _decimals : uint8, _supply : uint256):

    assert _supply > 0 , "Supply must be greater than one"
    assert _decimals > 0, "Decimals must be greater than one"

    initial_supply : uint256 = _supply  * 10 **  convert(_decimals, uint256)
    self.name = _name
    self.symbol = _symbol
    self.decimals = _decimals
    self.balanceOf[msg.sender] = initial_supply
    self.totalSupply = initial_supply
    self.minter  = msg.sender
    self.trading_status =  True


    log Transfer(empty(address), msg.sender, initial_supply )



@external
def setTradingStatus(_status : bool):
    assert self.minter == msg.sender

    self.trading_status = _status

    

@external
def setMinter( _minter : address):
    """

    @dev Swaps the minter address for a new address
    @param _minter The new minter address

    """

    assert self.minter == msg.sender

    self.minter = _minter
    


@external
def transfer( _to : address, _value : uint256)-> bool:
    """
    @dev Transfer token to a specified address
    @param _to The address to transfer the token to
    @param _value The amount of token to transfer 

    """

    assert self.trading_status

    self.balanceOf[msg.sender] -=  _value
    self.balanceOf[_to] += _value

    log Transfer( msg.sender, _to, _value)
    return True


@external
def transferFrom( _from : address, _to  :address, _value  :uint256)-> bool:
    """

    @dev Transfers token from one address to another
    @param _from The address to transfer the token from
    @param _to The address to transfer the token to
    @param _value The amount of token to transfer

    """

    assert self.trading_status


    self.balanceOf[_from] -=  _value
    self.balanceOf[_to] += _value

    # Vyper does not support underflows and overflows, so the transaction will revert on insufficient allowance of the sender

    self.allowance[_from][msg.sender] -= _value

    log Transfer( _from, _to, _value)
    return True


@external
def approve( _spender : address, _value : uint256)-> bool:
    """

    @dev Approves an allowance for an address to be spent of behalf of the sender
    @param _spender The address to allocate to
    @param _value The amount of token to allocate

    """

    assert self.trading_status

    assert _spender != empty(address)


    self.allowance[msg.sender][_spender] = _value

    log Approval(msg.sender, _spender, _value)
    return True


@external
def increaseAllowance( _spender  :address, _value : uint256)->bool:
    """

    @dev Adds to the allowance for an address 
    @param _spender The address to add allowance to
    @param _value The amount of allowance to add

    """

    assert self.trading_status
    
    assert _spender != empty(address)


    self.allowance[msg.sender][_spender] += _value

    log Approval(msg.sender, _spender, self.allowance[msg.sender][_spender] )
    return True



@external
def decreaseAllowance( _spender  :address, _value : uint256)->bool:
    """

    @dev Subtracts from the allowance for an address 
    @param _spender The address to add allowance to
    @param _value The amount of allowance to subtract

    """

    assert self.trading_status
    
    assert _spender != empty(address)


    self.allowance[msg.sender][_spender] -= _value

    log Approval(msg.sender, _spender, self.allowance[msg.sender][_spender] )
    return True