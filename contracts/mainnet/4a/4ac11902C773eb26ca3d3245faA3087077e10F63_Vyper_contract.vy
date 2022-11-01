# @version 0.3.7

# LOTTERY

interface VRFCoordinatorV2:
    def getRequestConfig() -> (uint16, uint32, Bytes[1000]): view
    def requestRandomWords(keyHash: bytes32, subId: uint64, minimumRequestConfirmations: uint16, callbackGasLimit: uint32, numWords: uint32) -> uint256: nonpayable
    def createSubscription() -> uint64: nonpayable
    def addConsumer(subId: uint64, consumer: address): nonpayable

interface LinkToken:
    def transferAndCall(_to: address, _value: uint256, _data: Bytes[2000]) -> bool: nonpayable
    def balanceOf(_who: address) -> uint256: view

interface iVault:
    def EligibleAddressMap(_to: address) -> uint256: view
    def eligible_index_count() -> uint256: view
    def EligibleIndexMap(arg0: uint256) -> address: view

interface iHoloYield:
    def balanceOf(_who: address) -> uint256: view

interface iBUSD:
    def balanceOf(_who: address) -> uint256: view
    def transfer(_to: address, _val: uint256) -> bool: nonpayable

interface IQuote:
	def transfer(_to: address, _val: uint256) -> bool: nonpayable
	def transferFrom(_from: address, _to: address, _val: uint256) -> bool: nonpayable
	def approve(_spender: address, _val: uint256) -> bool: nonpayable
	def balanceOf(_who: address) -> uint256: view

interface iGilts:
    def current_gilt_balance(arg0: address) -> uint256: view

# ===== EVENTS ===== #

event ReturnedRandomness:
    random_words: DynArray[uint256, MAX_ARRAY_SIZE]

event Payment:
    _value: uint256
    _sender: address

event UneligibleWinner:
    _address: address
    _idx: uint32

event Claim:
    _address: indexed(address)
    _amount: uint256


# ===== DATA STRUCTURE ===== #

struct WinnerInfo:
    _id: uint256
    _time: uint256
    _amount: uint256
    _address: address
    _claimed: bool

# ===== STATE VARIABLES ===== #

NUM_WORDS: constant(uint32) = 10
MAX_ARRAY_SIZE: constant(uint256) = 20
REQUEST_CONFIRMATIONS: constant(uint16) = 3
CALLBACK_GAS_LIMIT: constant(uint32) = 500000

WINNERS_DISPLAY_ITERATOR: constant(uint256) = 1024

vrf_coordinator: public(VRFCoordinatorV2)
subscription_id: public(uint64)

key_hash: bytes32
random_words: public(uint256[NUM_WORDS])
last_random_words: public(uint256[1])

owner: immutable(address)
has_init: bool

vault: iVault
gilts: iGilts
holoyield: iHoloYield
BUSD: iBUSD
link: public(LinkToken)

minimum_value_win: public(uint256)

next_draw: public(uint256)
last_win_time: public(uint256)
lottery_frequency: public(uint256)

unclaimed: public(uint256)
winning_address: public(address)
num_winners: public(uint256)
winners_map: public(HashMap[address, WinnerInfo])
winners_index_map: public(HashMap[uint256, address])


# ===== DEFAULT ===== #

@external
@payable
def __default__():
    log Payment(msg.value, msg.sender)

# ===== INIT ===== #

@external
def __init__(_vrf_coordinator_address: address, _link_address: address, _key_hash: bytes32):

    owner = msg.sender
    self.vrf_coordinator = VRFCoordinatorV2(_vrf_coordinator_address)
    self.link = LinkToken(_link_address)
    self.key_hash = _key_hash


@external
def initialise( _holoyield_address: address, _busd_address: address, _vault_address: address, _gilt_address: address):

    assert msg.sender == owner
    assert not self.has_init

    self.holoyield = iHoloYield(_holoyield_address)
    self.BUSD = iBUSD(_busd_address)
    self.vault = iVault(_vault_address)
    self.gilts = iGilts(_gilt_address)
    self.has_init = True


# ===== SET_PARAMETERS ===== #

@external
def set_minimum_value_win(_minimum_value_win: uint256):

    assert msg.sender == owner

    self.minimum_value_win = _minimum_value_win
    

@external
def set_lottery_frequency(_freq: uint256):

    assert msg.sender == owner

    self.lottery_frequency = _freq

@external
def set_next_draw(_time: uint256):

    assert msg.sender == owner

    self.next_draw = _time

# ===== MUTATIVE ===== #

@external
def request_random_words():

    assert msg.sender == owner

    self._request_random_words()

@internal
def _request_random_words():
    self.vrf_coordinator.requestRandomWords(
        self.key_hash,
        self.subscription_id,
        REQUEST_CONFIRMATIONS,
        CALLBACK_GAS_LIMIT,
        NUM_WORDS
    )

@external
def createNewSubscription():

    assert msg.sender == owner

    self.subscription_id = self.vrf_coordinator.createSubscription()

    self.vrf_coordinator.addConsumer(self.subscription_id, self)


@external
def topUpSubscription(_amount: uint256):

    assert msg.sender == owner

    self.link.transferAndCall(self.vrf_coordinator.address, _amount, _abi_encode(self.subscription_id))

@internal
def fulfillRandomWords(request_id: uint256, _random_words: DynArray[uint256, MAX_ARRAY_SIZE]):

    for i in range(NUM_WORDS):
        self.random_words[i] = _random_words[i]

    log ReturnedRandomness(_random_words)

    

@external
def rawFulfillRandomWords(requestId: uint256, randomWords: DynArray[uint256, MAX_ARRAY_SIZE]):

    assert msg.sender == self.vrf_coordinator.address
    
    self.fulfillRandomWords(requestId, randomWords)

@view
@internal
def _busd_balance() -> uint256:

    return self.BUSD.balanceOf(self)

@view
@external
def busd_balance() -> uint256:

    return self._busd_balance()

@nonreentrant('lock')
@external
def draw():

    assert msg.sender == owner
    assert (self._busd_balance() - self.unclaimed) > self.minimum_value_win
    assert block.timestamp > self.next_draw

    for i in range(NUM_WORDS):

        _winner_index: uint256 = self.random_words[i] % self.vault.eligible_index_count()

        potential_winner: address = self.vault.EligibleIndexMap(_winner_index)

        if potential_winner == self.winning_address:
            log UneligibleWinner(potential_winner, i)
            continue

        elif self.holoyield.balanceOf(potential_winner) != 0:
            self.winning_address = potential_winner
            break

        elif self.holoyield.balanceOf(potential_winner) == 0 and self.gilts.current_gilt_balance(potential_winner) != 0:
            self.winning_address = potential_winner
            break

        elif i != NUM_WORDS - 1:
            log UneligibleWinner(potential_winner, i)
            continue

        elif i == NUM_WORDS - 1:
            raise "No eligible winners in this draw"

    win_amount: uint256 = self._busd_balance() - self.unclaimed

    winner_info: WinnerInfo = WinnerInfo({_id: self.num_winners, _time: block.timestamp, _amount: win_amount,  _address: self.winning_address, _claimed: False})

    self.winners_map[self.winning_address] = winner_info
    self.winners_index_map[self.num_winners] = self.winning_address

    self.unclaimed += win_amount

    self.num_winners += 1

    self.last_win_time = block.timestamp

    self.next_draw = self.last_win_time + self.lottery_frequency


@nonreentrant('lock')
@external
def claim():

    winner_info: WinnerInfo = self.winners_map[msg.sender]

    assert (winner_info._amount > 0) and (not winner_info._claimed)

    self.BUSD.transfer(msg.sender, winner_info._amount)

    self.winners_map[msg.sender] = WinnerInfo({_id: winner_info._id, _time: winner_info._time, _amount: winner_info._amount, _address: msg.sender, _claimed: True})

    self.unclaimed -= winner_info._amount

@view
@external
def view_winners() -> DynArray[WinnerInfo, WINNERS_DISPLAY_ITERATOR]:

    winners_array: DynArray[WinnerInfo, WINNERS_DISPLAY_ITERATOR] = []

    for i in range(WINNERS_DISPLAY_ITERATOR):

        if i == self.num_winners:
            break

        _address: address = self.winners_index_map[i]

        winners_array.append(self.winners_map[_address])
        
    return winners_array

@external
def withdraw(_to: address, _amount: uint256) -> bool:

	assert msg.sender == owner
	assert _to != empty(address)

	send(_to, _amount)
	
	return True

@external
def withdraw_quote(_to: address, _quote_address: address, _amount: uint256) -> bool:

	assert msg.sender == owner
	assert _to != empty(address)
	assert _quote_address != empty(address)

	quote: IQuote = IQuote(_quote_address)

	quote.transfer(_to, _amount)

	return True