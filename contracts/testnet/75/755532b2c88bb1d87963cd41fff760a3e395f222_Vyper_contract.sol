ava: address
eden: HashMap[address, bool]
bible : HashMap[address, bytes32]
church: HashMap[bytes32, address]


score: public(uint256[3])


@external
def __init__():
  self.ava = msg.sender
  self.score = [7,5,3]

@external
def adam(eve: address):
  assert msg.sender == self.ava
  self.ava = eve
  

@external
@payable
def play(verse: String[32]):
  send(self.ava, msg.value)
  self.church[sha256(verse)] = msg.sender
  self.bible[msg.sender] = sha256(verse)
  self.eden[msg.sender] = True
  self.score = [7,5,3]

@external
@payable
def pray(poem: bytes32):
  assert msg.sender == self.ava
  assert self.bible[self.church[poem]] == poem
  assert self.eden[self.church[poem]]
  send(self.church[poem], msg.value)
  self.bible[self.church[poem]] = EMPTY_BYTES32
  self.eden[self.church[poem]] = False

@external
def set(newscore: uint256[3]):
  self.score = newscore

@external
@view
def getScore() -> uint256[3]:
  return [self.score[0], self.score[1], self.score[2]]