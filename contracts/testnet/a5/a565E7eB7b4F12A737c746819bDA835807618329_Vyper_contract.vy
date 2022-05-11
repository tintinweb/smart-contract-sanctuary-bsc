# ERC20 implementation adapted from https://github.com/ethereum/vyper/blob/master/examples/tokens/ERC20.vy

event Transfer: 
    _from: indexed(address)
    _to: indexed(address)
    _value: uint256
event Approval:
    _owner: indexed(address)
    _spender: indexed(address)
    _value: uint256

name: public(String[32])
symbol: public(String[32])
decimals: public(uint256)
totalSupply: public(uint256)
balanceOf: public(HashMap[address, uint256])
allowances: HashMap[address, HashMap[address, uint256]]


@external
def __init__():
    _supply: uint256 = 500*10**18
    self.name = 'Unisocks Edition 0'
    self.symbol = 'SOCKS'
    self.decimals = 18
    self.balanceOf[msg.sender] = _supply
    self.totalSupply = _supply
    log Transfer(ZERO_ADDRESS, msg.sender, _supply)


@external
@view
def allowance(_owner : address, _spender : address) -> uint256:
    return self.allowances[_owner][_spender]


@external
def transfer(_to : address, _value : uint256) -> bool:
    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value
    log Transfer(msg.sender, _to, _value)
    return True


@external
def transferFrom(_from : address, _to : address, _value : uint256) -> bool:
    self.balanceOf[_from] -= _value
    self.balanceOf[_to] += _value
    if self.allowances[_from][msg.sender] < MAX_UINT256:
        self.allowances[_from][msg.sender] -= _value
    log Transfer(_from, _to, _value)
    return True


@external
def approve(_spender : address, _value : uint256) -> bool:
    self.allowances[msg.sender][_spender] = _value
    log Approval(msg.sender, _spender, _value)
    return True


@external
def burn(_value: uint256) -> bool:
    self.totalSupply -= _value
    self.balanceOf[msg.sender] -= _value
    log Transfer(msg.sender, ZERO_ADDRESS, _value)
    return True


@external
def burnFrom(_from: address, _value: uint256) -> bool:
    if self.allowances[_from][msg.sender] < MAX_UINT256:
        self.allowances[_from][msg.sender] -= _value
    self.totalSupply -= _value
    self.balanceOf[_from] -= _value
    log Transfer(_from, ZERO_ADDRESS, _value)
    return True