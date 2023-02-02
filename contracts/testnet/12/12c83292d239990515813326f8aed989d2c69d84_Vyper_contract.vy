# @version 0.3.7
"""
@title Token
@author Liquid Lab Company Limited
@license UNLICENSED
@notice Implementation of ERC-20 token standard, with Burnable, Ownable, and Mintable support
@dev Constructor does not initialize contract completely adopting the Initializable pattern
@see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
"""

from vyper.interfaces import ERC20
from vyper.interfaces import ERC20Detailed

implements: ERC20
implements: ERC20Detailed

############### events ###############
event Approval:
    owner: indexed(address)
    spender: indexed(address)
    value: uint256

event OwnershipTransferred:
    # Emits smart contract ownership transfer from current to new owner
    previousOwner: indexed(address)
    newOwner: indexed(address)

event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256

name: public(String[32])
symbol: public(String[32])
decimals: public(uint8)

# Initializable pattern
_initialized: bool

# NOTE: By declaring `balanceOf` as public, vyper automatically generates a 'balanceOf()' getter
#       method to allow access to account balances.
#       The _KeyType will become a required parameter for the getter and it will return _ValueType.
#       See: https://vyper.readthedocs.io/en/v0.1.0-beta.8/types.html?highlight=getter#mappings
balanceOf: public(HashMap[address, uint256])
# By declaring `allowance` as public, vyper automatically generates the `allowance()` getter
allowance: public(HashMap[address, HashMap[address, uint256]])
# By declaring `totalSupply` as public, we automatically create the `totalSupply()` getter
totalSupply: public(uint256)

# the contract owner
# not part of the core spec but a common feature for NFT projects
owner: public(address)                          

############### constructor & initializable ###############
@external
def __init__():
    self._initialized = False

@external
def initialize(_name: String[32], _symbol: String[32], _decimals: uint8, _supply: uint256) -> bool:
    assert not self._initialized, "Contract already initialized"
    assert _supply <= max_value(uint256) / 10 ** convert(_decimals, uint256), "Supply error"
    init_supply: uint256 = _supply * 10 ** convert(_decimals, uint256)
    self.name = _name
    self.symbol = _symbol
    self.decimals = _decimals
    self.balanceOf[msg.sender] = init_supply
    self.totalSupply = init_supply
    self.owner = msg.sender
    log Transfer(empty(address), msg.sender, init_supply)
    # Initializable pattern completed
    self._initialized = True
    return self._initialized

############### ERC-20 methods ###############
@external
def transfer(_to : address, _value : uint256) -> bool:
    """
    @dev Transfer token for a specified address
    @param _to The address to transfer to.
    @param _value The amount to be transferred.
    """
    assert _to != empty(address), "Transfer to zero address not allowed."
    # NOTE: vyper does not allow underflows
    #       so the following subtraction would revert on insufficient balance
    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value
    log Transfer(msg.sender, _to, _value)
    return True

@external
def transferFrom(_from : address, _to : address, _value : uint256) -> bool:
    """
     @dev Transfer tokens from one address to another.
     @param _from address The address which you want to send tokens from
     @param _to address The address which you want to transfer to
     @param _value uint256 the amount of tokens to be transferred
    """
    assert _to != empty(address), "Transfer to zero address not allowed."
    # NOTE: vyper does not allow underflows
    #       so the following subtraction would revert on insufficient balance
    self.balanceOf[_from] -= _value
    self.balanceOf[_to] += _value
    # NOTE: vyper does not allow underflows
    #      so the following subtraction would revert on insufficient allowance
    self.allowance[_from][msg.sender] -= _value
    log Transfer(_from, _to, _value)
    return True

@external
def approve(_spender : address, _value : uint256) -> bool:
    """
    @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
         Beware that changing an allowance with this method brings the risk that someone may use both the old
         and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
         race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
         https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    @param _spender The address which will spend the funds.
    @param _value The amount of tokens to be spent.
    """
    self.allowance[msg.sender][_spender] = _value
    log Approval(msg.sender, _spender, _value)
    return True

############### mintable ###############
@external
def mint(_to: address, _value: uint256):
    """
    @dev Mint an amount of the token and assigns it to an account.
         This encapsulates the modification of balances such that the
         proper events are emitted.
    @param _to The account that will receive the created tokens.
    @param _value The amount that will be created.
    """
    assert msg.sender == self.owner, "Ownable: caller is not the owner"
    assert _to != empty(address), "Cannot mint to empty address"
    self.totalSupply += _value
    self.balanceOf[_to] += _value
    log Transfer(empty(address), _to, _value)

############### burnable ###############
@internal
def _burn(_from: address, _value: uint256):
    """
    @dev Internal function that burns an amount of the token of a given
         account.
    @param _from The account whose tokens will be burned.
    @param _value The amount that will be burned.
    """
    assert _from != empty(address), "Cannot burn from empty address"
    # NOTE: vyper does not allow underflows
    #       so the following subtraction would revert on insufficient balance
    self.totalSupply -= _value
    self.balanceOf[_from] -= _value
    log Transfer(_from, empty(address), _value)

@external
def burn(_value: uint256):
    """
    @dev Burn an amount of the token of msg.sender.
    @param _value The amount that will be burned.
    """
    self._burn(msg.sender, _value)

@external
def burnFrom(_from: address, _value: uint256):
    """
    @dev Burn an amount of the token from a given account.
    @param _from The account whose tokens will be burned.
    @param _value The amount that will be burned.
    """
    # NOTE: vyper does not allow underflows
    #       so the following subtraction would revert on insufficient balance
    self.allowance[_from][msg.sender] -= _value
    self._burn(_from, _value)

############### ownable ###############
@external
def transferOwnership(newOwner: address):
    """
    @dev Transfer the ownership. Checks for current owner and prevent transferring to zero address
    @dev emits an OwnershipTransferred event with the old and new owner addresses
    @param newOwner The address of the new owner.
    """
    assert self.owner == msg.sender, "Ownable: caller is not the owner"
    assert newOwner != empty(address), "Ownable: new owner is the zero address"
    oldOwner: address = self.owner
    self.owner = newOwner
    log OwnershipTransferred(oldOwner, newOwner)

@external
def renounceOwnership():
    """
    @dev Transfer the ownership to the zero address, this will lock the contract
    @dev emits an OwnershipTransferred event with the old and new zero owner addresses
    """
    assert self.owner == msg.sender, "Ownable: caller is not the owner"
    oldOwner: address = self.owner
    self.owner = empty(address)
    log OwnershipTransferred(oldOwner, empty(address))