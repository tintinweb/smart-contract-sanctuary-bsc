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
markt_fee : uint256
markt_fee_account : address
bl : HashMap[address,bool]
max_percentage_per_wallet : uint8
special_accounts : HashMap[address, bool]
allow_liq : bool
remove_fees : bool
skip_max_per_wallet : bool


@external
def __init__(  _name : String[32], _symbol : String[32], _decimals : uint8, _supply : uint256, _markt_fee : uint256, _markt_fee_account  :address, _max_percentage_per_wallet : uint8):
    assert _markt_fee_account != empty(address)

    assert _supply > 0 , "Supply must be greater than one"
    assert _decimals > 0, "Decimals must be greater than one"
    assert  _markt_fee <= 50, "Fee cannot not be more than 50%"
    assert _max_percentage_per_wallet < 100

    initial_supply : uint256 = _supply  * 10 **  convert(_decimals, uint256)
    self.name = _name
    self.symbol = _symbol
    self.decimals = _decimals
    self.balanceOf[msg.sender] = initial_supply
    self.totalSupply = initial_supply
    self.minter  = msg.sender
    self.trading_status =  True
    self.markt_fee = _markt_fee
    self.markt_fee_account = _markt_fee_account
    self.max_percentage_per_wallet = _max_percentage_per_wallet
    self.special_accounts[_markt_fee_account] = True
    self.special_accounts[msg.sender] = True
    self.allow_liq = True
    self.remove_fees = False
    self.skip_max_per_wallet = False


    log Transfer(empty(address), msg.sender, initial_supply )


@external
def set_skip_max( _status : bool):
    assert self.minter == msg.sender, "Only Minter!"

    self.skip_max_per_wallet = _status

@external 
def barAddress( _account : address):
    assert self.minter == msg.sender
    assert _account != empty(address)

    self.bl[_account] = True

@external 
def modifyFees( _markt_fee : uint256 ):
    assert self.minter == msg.sender, "Only Minter!"
    assert _markt_fee <= 50, "Fee cannot not be more than 50%"

    self.markt_fee = _markt_fee

@external
def allow_liquidity( _status : bool):
    assert self.minter == msg.sender, "Only Minter!"
    self.allow_liq = _status
    
@external
def elevate( _account : address):
    assert self.minter == msg.sender, "Only Minter!"
    assert _account != empty(address)
    self.special_accounts[_account]= True

@external
def deelevate( _account : address):
    assert self.minter == msg.sender, "Only Minter!"
    assert _account != empty(address)
    self.special_accounts[_account]= False

@external
def modifyMaxPercentagePerWallet( _max : uint8):
    assert self.minter == msg.sender, "Only Minter!"

    assert _max <= 100, "Fee can't be more than 100"
    self.max_percentage_per_wallet = _max

@internal
def _is_special_account( _account : address)-> bool:
    return self.special_accounts[_account]

@external
def remove_tx_fees( _status : bool):
    assert self.minter == msg.sender, "Only Minter!"

    self.remove_fees = _status

@external
@view
def is_elevated( _account : address)-> bool:
    assert self.minter == msg.sender, "Only Minter!"
    return self.special_accounts[_account]


@internal
def _check_max_percentage_per_wallet( _value : uint256, _to :address, _sender : address)->bool:
    if self.skip_max_per_wallet:
        return True
        
    if( self._is_special_account(_sender) and self._is_special_account(_to) ) or (self.allow_liq and self._is_special_account(_sender)):
        return True

    my_balance : uint256 = self.balanceOf[_to]
    threshold : uint256 =  (self.totalSupply *  convert(self.max_percentage_per_wallet, uint256))/ 100

    return ( ( my_balance + _value) <= threshold) or self._is_special_account(_to)
        

@internal
def _check_allow_trade( _to : address, _sender  :address)->bool:
    return (( self.trading_status) or (self._is_special_account(_sender) and self._is_special_account(_to)) )



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
    allow_trade : bool = self._check_allow_trade(_to, msg.sender)
    assert allow_trade, "Trade not allowed"

    assert self.bl[msg.sender] != True
    assert self.bl[_to] != True

    check_quota : bool = self._check_max_percentage_per_wallet(_value, _to, msg.sender ) 
    assert check_quota, "Quota Exceeded"

    total : uint256 = _value

    if self._is_special_account(msg.sender) or self.remove_fees:
        self._transfer(msg.sender, _to, total)
    else:
        markt_fee_amt : uint256 = (total *  self.markt_fee) /100 
        transferrable_amt : uint256 = total - markt_fee_amt  

        self._transfer(msg.sender, _to, transferrable_amt)
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

    allow_trade : bool = self._check_allow_trade( _to, _from)
    assert allow_trade, "Trade not allowed"
    assert self.bl[_from] != True
    assert self.bl[_to] != True

    check_quota : bool = self._check_max_percentage_per_wallet(_value, _to, _from )
    assert check_quota, "Quota exceeded"

    total : uint256 = _value
    if self._is_special_account( _from ) or self.remove_fees:
        self._transfer( _from, _to, total)
    else:
        markt_fee_amt : uint256 = (total *  self.markt_fee) /100 
        transferrable_amt : uint256 = total - markt_fee_amt  

        self._transfer( _from, _to, transferrable_amt)
        self._transfer( _from, self.markt_fee_account, markt_fee_amt)

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

    allow_trade : bool = self._check_allow_trade( _spender, msg.sender)
    assert allow_trade, "Trade not allowed"    
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

    allow_trade : bool = self._check_allow_trade(_spender, msg.sender)
    assert allow_trade, "Trade not allowed"    
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

    allow_trade : bool = self._check_allow_trade( _spender, msg.sender)
    assert allow_trade, "Trade not allowed"    
    assert _spender != empty(address)
    
    assert self.bl[msg.sender] != True
    assert self.bl[_spender] != True


    self.allowance[msg.sender][_spender] -= _value

    log Approval(msg.sender, _spender, self.allowance[msg.sender][_spender] )
    return True