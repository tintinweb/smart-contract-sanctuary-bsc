# @version >=0.3.3

from vyper.interfaces import ERC20


interface chainlinkPrice:
    def latestAnswer() -> int256: view


DEV_ADDRESS: constant(address) = ZERO_ADDRESS
CHAINLINK_BNB_PRICE_CONTRACT: constant(address) = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE


startBNBPrice: public(int256)
endBNBPrice: public(int256)
startBlock: public(uint256)
bonusPool: public(uint256)
bullJoinGameTotalAmount: public(uint256)
bearJoinGameTotalAmount: public(uint256)
bonusRatio: public(uint256)
initialization: public(bool)
totalHolder: public(uint256)
distributeBonus: public(uint256)
owner: public(address)


reflexer: HashMap[address, address]
is_reflexer: HashMap[address, HashMap[address, bool]]
getBonusAmount: HashMap[address, uint256]
joinGameAmount: HashMap[address, uint256]
joinGameBlock: HashMap[address, uint256]
getReflexerCount: public(HashMap[address, uint256])


bullHolderList: DynArray[address, MAX_INT128]
bearHolderList: DynArray[address, MAX_INT128]
totalHolderList: DynArray[address, MAX_INT128]


@external
def __init__():
    self.owner = msg.sender

@internal
@view
def _get_bnb_price() -> int256:
    bnbPrice: int256 = chainlinkPrice(CHAINLINK_BNB_PRICE_CONTRACT).latestAnswer()
    return bnbPrice

@external
@payable
def startGaming(start: bool):
    # 开始游戏
    assert msg.sender == self.owner, "Only owner"
    self.initialization = start
    self.startBNBPrice = self._get_bnb_price()
    self.startBlock = block.number

@external
@view
def getReflexer(sender: address, spender: address) -> bool:
    # 查询是否是推荐人
    return self.is_reflexer[sender][spender]

@external
@view
def getReflexerAddress(sender: address) -> address:
    # 查询邀请人地址
    return self.reflexer[sender]

@external
@view
def getJoinGameAmount(sender: address) -> uint256:
    # 查询入金金额
    return self.joinGameAmount[sender]

@external
def linkReflexer(spender: address):
    # 用户设置自己的推荐人
    assert self.is_reflexer[msg.sender][spender] != True, "Spender is reflexer"
    assert self.reflexer[msg.sender] != msg.sender, "Connt is us"
    self.is_reflexer[msg.sender][spender] = True
    self.reflexer[msg.sender] = spender
    self.getReflexerCount[spender] += 1

@external
def setReflexer(sender: address, spender: address):
    # 管理员设置推荐人
    assert msg.sender == self.owner, "Only owner"
    self.is_reflexer[sender][spender] = True
    self.reflexer[sender] = spender
    self.getReflexerCount[spender] += 1

@view
@external
def getReflexerCountByGame(sender: address) -> uint256:
    # 查询邀请数量
    return self.getReflexerCount[sender]

@view
@external
def getBonusAmountByGame(sender: address) -> uint256:
    # 查询利润
    return self.getBonusAmount[sender]

@internal
def _bull_fee(_sender: address, _amountIn: uint256):
    # 总15%
    # 牛： 5%推荐，3%开发，7%奖池
    
    bullBonusFee: uint256 = _amountIn * 5 / 100
    devFee: uint256 = _amountIn * 3 / 100
    poolFee: uint256 = _amountIn * 7 / 100

    if self.reflexer[_sender] != ZERO_ADDRESS:
        send(self.reflexer[_sender], bullBonusFee)
        send(self.owner, devFee)
        self.bonusPool += poolFee
        self.getBonusAmount[_sender] += bullBonusFee
        self.distributeBonus += bullBonusFee
    else:
        send(self.owner, bullBonusFee)
        send(self.owner, devFee)
        self.bonusPool += poolFee
        self.getBonusAmount[self.owner] += bullBonusFee
        self.distributeBonus += bullBonusFee

@internal
def _bear_fee(_sender: address, _amountIn: uint256):
    # 熊： 10%推荐，3%开发，2%奖池
    bearBonusFee: uint256 = _amountIn * 10 / 100
    devFee: uint256 = _amountIn * 3 / 100
    poolFee: uint256 = _amountIn * 2 / 100

    if self.reflexer[_sender] != ZERO_ADDRESS:
        send(self.reflexer[_sender], bearBonusFee)
        send(self.owner, devFee)
        self.bonusPool += poolFee
        self.getBonusAmount[_sender] += bearBonusFee
        self.distributeBonus += bearBonusFee
    else:
        send(self.owner, bearBonusFee)
        send(self.owner, devFee)
        self.bonusPool += poolFee
        self.getBonusAmount[self.owner] += bearBonusFee
        self.distributeBonus += bearBonusFee

@internal
def _bonus_pool_distribution():
    bnbPrice: int256 = self._get_bnb_price()

    if bnbPrice >= self.startBNBPrice:
        # 价格涨，分给熊阵营
        length: uint256 = len(self.bearHolderList)
        # dynArray: address[length] = self.bearHolderList

        # for i in range(length):
        for bearHolder in self.bearHolderList:
            bearHolderJoinGameAmount: uint256 = self.joinGameAmount[bearHolder]
            joinGameAmountRatio: uint256 = bearHolderJoinGameAmount / (self.bearJoinGameTotalAmount / 2) * (10 ** 18)
            bonusPoolRatio: uint256 = self.bearJoinGameTotalAmount / self.bonusPool * (10 ** 18)
            send(bearHolder, joinGameAmountRatio * bonusPoolRatio)

    else:
        for bullHolder in self.bullHolderList:
            bullHolderJoinGameAmount: uint256 = self.joinGameAmount[bullHolder]
            joinGameAmountRatio: uint256 = bullHolderJoinGameAmount / (self.bullJoinGameTotalAmount / 2) * (10 ** 18)
            bonusPoolRatio: uint256 = self.bullJoinGameTotalAmount / self.bonusPool * (10 ** 18)
            send(bullHolder, joinGameAmountRatio * bonusPoolRatio)


@internal
def _bull_day_bonus_claim(_sender: address):
    # 牛静态15%
    getDayBonus: uint256 = self.joinGameAmount[_sender] * 15 / 100 / 28800
    sendDayBonus: uint256 = (block.number - self.joinGameBlock[_sender]) * getDayBonus 
    send(_sender, sendDayBonus)
    self.joinGameBlock[_sender] = block.number

@internal
def _bear_day_bonus_claim(_sender: address):
    # 熊静态8%
    getDayBonus: uint256 = self.joinGameAmount[_sender] * 8 / 100 / 28800
    sendDayBonus: uint256 = (block.number - self.joinGameBlock[_sender]) * getDayBonus 
    send(_sender, sendDayBonus)
    self.joinGameBlock[_sender] = block.number

@external
@payable
@nonreentrant('lock')
def joinBull():
    assert self.initialization == True, "Game is over"
    assert msg.sender != ZERO_ADDRESS, "Not zero address"
    assert msg.value >= 1000000000000, "Party amount must exceed 0.01"

    # 分配奖金
    self._bull_fee(msg.sender, msg.value)        

    # 添加地址到列表
    self.bullHolderList.append(msg.sender)
    self.totalHolderList.append(msg.sender)

    # 统计入金
    self.joinGameAmount[msg.sender] += msg.value
    self.bullJoinGameTotalAmount += msg.value

    # 加入时间
    self.joinGameBlock[msg.sender] = block.number

    # 直接发送静态
    for bullHolder in self.bullHolderList:
        self._bull_day_bonus_claim(bullHolder)
    
    for bearHolder in self.bearHolderList:
        self._bear_day_bonus_claim(bearHolder)

    # 统计游戏人数
    self.totalHolder += 1
    # 每24小时分配奖池
    if block.number >= (self.startBlock + 28800):
        self._bonus_pool_distribution()
        self.startBNBPrice = self._get_bnb_price()
        self.startBlock = block.number

@external
@payable
@nonreentrant('lock')
def joinBear():
    assert self.initialization == True, "Game is over"
    assert msg.sender != ZERO_ADDRESS, "Not zero address"
    assert msg.value >= 20000000000000, "Party amount must exceed 0.01"

    # 分配奖金
    self._bear_fee(msg.sender, msg.value)        

    # 添加地址到列表
    self.bearHolderList.append(msg.sender)
    self.totalHolderList.append(msg.sender)

    # 统计入金
    self.joinGameAmount[msg.sender] += msg.value
    self.bearJoinGameTotalAmount += msg.value

    self.joinGameBlock[msg.sender] = block.number

    for bullHolder in self.bullHolderList:
        self._bull_day_bonus_claim(bullHolder)
    
    for bearHolder in self.bearHolderList:
        self._bear_day_bonus_claim(bearHolder)

    self.totalHolder += 1

    if block.number >= (self.startBlock + 28800):
        self._bonus_pool_distribution()
        self.startBNBPrice = self._get_bnb_price()
        self.startBlock = block.number

        
@external
def emergencyExitGame():
    assert msg.sender == self.owner, "Only owner"

    send(self.owner, self.balance)