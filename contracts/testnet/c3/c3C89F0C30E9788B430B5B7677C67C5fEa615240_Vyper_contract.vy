"""

@title THE Myx ECOSYSTEM TOKEN SMART CONTRACT, CREATED TODAY 23RD OF AUGUST, 2023.
@license MIT
@dev ERC20 TOKEN IMPLEMENTAION IN VYPER CODE
@notice This contract is written originally for the Myx ecosystem.  

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
liq_fee : uint256
markt_fee : uint256
liq_fee_account : address
markt_fee_account : address
bl : HashMap[address,bool]
max_percentage_per_wallet : uint8



@external
def __init__(  _name : String[32], _symbol : String[32], _decimals : uint8, _supply : uint256, _liq_fee : uint256, _markt_fee : uint256, _liq_fee_account : address, _markt_fee_account  :address, _max_percentage_per_wallet : uint8):
    assert _liq_fee_account != empty(address)
    assert _markt_fee_account != empty(address)

    assert _supply > 0 , "Supply must be greater than one"
    assert _decimals > 0, "Decimals must be greater than one"
    assert _liq_fee + _markt_fee <= 50, "Fee cannot not be more than 50%"
    assert _max_percentage_per_wallet < 100

    initial_supply : uint256 = _supply  * 10 **  convert(_decimals, uint256)
    self.name = _name
    self.symbol = _symbol
    self.decimals = _decimals
    self.balanceOf[msg.sender] = initial_supply
    self.totalSupply = initial_supply
    self.minter  = msg.sender
    self.trading_status =  True
    self.liq_fee = _liq_fee
    self.markt_fee = _markt_fee
    self.liq_fee_account = _liq_fee_account
    self.markt_fee_account = _markt_fee_account
    self.max_percentage_per_wallet = _max_percentage_per_wallet


    log Transfer(empty(address), msg.sender, initial_supply )


@external 
def barAddress( _account : address):
    assert self.minter == msg.sender
    assert _account != empty(address)

    self.bl[_account] = True

@external 
def modifyFees( _liq_fee : uint256, _markt_fee : uint256 ):
    assert self.minter == msg.sender
    assert _liq_fee + _markt_fee <= 50, "Fee cannot not be more than 50%"

    self.liq_fee = _liq_fee
    self.markt_fee = _markt_fee

@internal
def _check_max_percentage_per_wallet( _value : uint256)->bool:
    amt_of_percentage : uint256 =  self.totalSupply  * ( convert(self.max_percentage_per_wallet, uint256)/100 )
    return _value < amt_of_percentage


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
    


@internal
def _transfer( _from : address, _to : address, _value : uint256):
    """
    @dev Transfer token to a specified address
    @param _to The address to transfer the token to
    @param _value The amount of token to transfer 

    """
    assert _value > 0
    assert _to != empty(address)

    self.balanceOf[_from] -=  _value
    self.balanceOf[_to] += _value
    log Transfer( _from, _to, _value)


@external
def transfer( _to : address, _value : uint256)-> bool:
    """
    @dev Transfer token to a specified address
    @param _to The address to transfer the token to
    @param _value The amount of token to transfer 

    """
    assert self.trading_status

    assert self.bl[msg.sender] != True
    assert self.bl[_to] != True

    check_quota : bool = self._check_max_percentage_per_wallet(_value)
    assert check_quota

    total : uint256 = _value
    markt_fee_amt : uint256 = total * ( self.markt_fee/100 ) 
    liq_fee_amt : uint256 = total * ( self.liq_fee/100 )
    transferrable_amt : uint256 = total - ( markt_fee_amt + liq_fee_amt )

    self._transfer(msg.sender, _to, transferrable_amt)
    self._transfer(msg.sender, self.liq_fee_account , liq_fee_amt)
    self._transfer(msg.sender, self.markt_fee_account, markt_fee_amt)


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

    assert self.bl[_from] != True
    assert self.bl[_to] != True

    check_quota : bool = self._check_max_percentage_per_wallet(_value)
    assert check_quota


    total : uint256 = _value
    markt_fee_amt : uint256 = total * ( self.markt_fee/100 ) 
    liq_fee_amt : uint256 = total * ( self.liq_fee/100 )
    transferrable_amt : uint256 = total - ( markt_fee_amt + liq_fee_amt )

    self._transfer(msg.sender, _to, transferrable_amt)
    self._transfer(msg.sender, self.liq_fee_account , liq_fee_amt)
    self._transfer(msg.sender, self.markt_fee_account, markt_fee_amt)

    # Vyper does not support underflows and overflows, so the transaction will revert on insufficient allowance of the sender

    self.allowance[_from][msg.sender] -= _value

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

    assert self.bl[msg.sender] != True
    assert self.bl[_spender] != True



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

    assert self.bl[msg.sender] != True
    assert self.bl[_spender] != True
    


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
    
    assert self.bl[msg.sender] != True
    assert self.bl[_spender] != True


    self.allowance[msg.sender][_spender] -= _value

    log Approval(msg.sender, _spender, self.allowance[msg.sender][_spender] )
    return True



@external
def mint(_to: address, _value: uint256):
    """

    @dev Mints an amount of token and assign it to an address
    @param _to The address to mint to
    @param _value The amount of token to mint

    """

    assert msg.sender == self.minter, "Only minter can mint!"
    assert _to != empty(address)

    self.totalSupply += _value
    self.balanceOf[_to] += _value

    log Transfer( empty(address), _to, _value)


@internal
def _burn( _to : address,  _value: uint256):
    """

    @dev Burns an amount of token  of an address
    @param _to The address whose token will be burned
    @param _value The amount of token to burn

    """

    assert _to != empty(address)
    self.totalSupply -= _value
    self.balanceOf[_to] -= _value

    log Transfer(_to, empty(address), _value)


@external
def burn(_value : uint256):

    """

    @dev Burn an amount of the token of msg.sender.
    @param _value The amount that will be burned.

    """

    assert msg.sender == self.minter, "Only minter can burn!"

    
    self._burn(msg.sender, _value)