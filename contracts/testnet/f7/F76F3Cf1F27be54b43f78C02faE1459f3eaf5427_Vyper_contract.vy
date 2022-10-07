# @version ^0.3.0

# GRVSNAP HELPER

owner: address

has_interacted: public(HashMap[address, bool])

@external
def __init__():

    self.owner = msg.sender

@external
def set_has_interacted():

    self.has_interacted[msg.sender] = True