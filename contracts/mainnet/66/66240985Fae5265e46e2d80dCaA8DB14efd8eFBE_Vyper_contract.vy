# @version 0.3.7

# TOKEN TIMELOCK

interface iToken:
    def transfer(_to: address, _val: uint256) -> bool: nonpayable
    def balanceOf(_who: address) -> uint256: view

release_time: public(uint256)
token: iToken
owner: address
beneficiary: address

@external
def __init__():

    self.owner = msg.sender

@external
def set_token(_token_address: address):

    assert msg.sender == self.owner

    self.token = iToken(_token_address)

@external
def set_beneficiary(_beneficiary: address):

    assert msg.sender == self.owner

    self.beneficiary = _beneficiary

@external
def set_release_time(_time: uint256):

    assert msg.sender == self.owner
    assert _time > block.timestamp

    self.release_time = _time

@external
def renounce_ownership():

    assert msg.sender == self.owner

    self.owner = empty(address)

@external
def release():

    assert block.timestamp >= self.release_time

    _amount: uint256 = self.token.balanceOf(self)

    assert _amount > 0

    self.token.transfer(self.beneficiary, _amount)