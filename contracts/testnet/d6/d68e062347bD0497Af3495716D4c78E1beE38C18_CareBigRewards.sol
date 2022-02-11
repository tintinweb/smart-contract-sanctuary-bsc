// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./CareLib.sol";
import "./CareBig.sol";

interface IMuonV02 {
    struct SchnorrSign {
        uint256 signature;
        address owner;
        address nonce;
    }
    function verify(
        bytes calldata _reqId,
        uint256 _hash,
        SchnorrSign[] calldata _sigs
    ) external returns (bool);
}


contract CareBigRewards is AccessControl{

    bytes32 constant public ADMIN_ROLE = keccak256("Admin Role");

    //TODO: allow admin to set
    CareBig public carebig;

    //TODO: allow admin to set
    IMuonV02 public muon;

    //TODO: allow admin to set
    uint8 public muonAppId = 11;


    // 1 REWARD token = X carebig
    // decimals = 18
    //TODO: allow admin to set
    uint256 public carebigPerRewards = 1e16; // 1 carebig for 100 REWARD

    //TODO: allow admin to set
    uint256 totalPerUser = 10000 ether;

    //TODO: allow admin to set
    uint256 totalPerTX = 1000 ether;

    // we save TOTAL amount of rewards token here
    // to avoid double-spending.
    // when a user claim in the first transaction, 
    // the second one will fail
    mapping(address => uint256) public claimed;

    event Claimed(address indexed user, uint256 amount);

    modifier onlyAdmin {
        require(hasRole(ADMIN_ROLE, msg.sender), "!admin");
        _;
    }

    constructor(){
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);

        carebig = CareBig(0x53389A0D5A0FC85210221E2564a8045FE44Ef75e); //TODO: put CareBig address here
        muon = IMuonV02(0xeE67E903d322FA65d8D370dE4eD99Fd9C3C5EF54);
    }

    function claim(
        uint256 totalRewards,
        bytes calldata _reqId,
        IMuonV02.SchnorrSign[] calldata _sigs
    ) public{
        bytes32 hash = keccak256(
            abi.encodePacked(muonAppId, msg.sender, totalRewards)
        );

        require(muon.verify(_reqId, uint256(hash), _sigs), "!verified");

        uint256 rewards = (totalRewards - claimed[msg.sender])*carebigPerRewards/1 ether;
        require(rewards > 0, "0 amount");
        carebig.mintTo(msg.sender, rewards);
        claimed[msg.sender] = totalRewards;

        emit Claimed(msg.sender, rewards);
    }

    function updateToken(CareBig _newAddress) public onlyAdmin {
        carebig = CareBig(_newAddress);
    }

    function updateMuonAddress(IMuonV02 _newAddress) public onlyAdmin {
        muon = IMuonV02(_newAddress);
    }

    function updateMuonAppId(uint8 _newId) public onlyAdmin {
        muonAppId = _newId;
    }

    function updateCarebigPerRewards(uint256 _newValue) public onlyAdmin {
        carebigPerRewards = _newValue;
    }

    function updateTotalPerUser(uint256 _newValue) public onlyAdmin {
        totalPerUser = _newValue;
    }

    function updateTotalPerTx(uint256 _newValue) public onlyAdmin {
        totalPerTX = _newValue;
    }
}

pragma solidity >0.4.18 < 0.8.4;

library Bytes32Set {
    
    struct Set {
        mapping(bytes32 => uint) keyPointers;
        bytes32[] keyList;
    }
    
    /**
     * @notice insert a key. 
     * @dev duplicate keys are not permitted.
     * @param self storage pointer to a Set. 
     * @param key value to insert.
     */
    function insert(Set storage self, bytes32 key) internal {
        require(!exists(self, key), "Bytes32Set: key already exists in the set.");
        self.keyPointers[key] = self.keyList.length;
        self.keyList.push(key);
    }

    /**
     * @notice remove a key.
     * @dev key to remove must exist. 
     * @param self storage pointer to a Set.
     * @param key value to remove.
     */
    function remove(Set storage self, bytes32 key) internal {
        require(exists(self, key), "Bytes32Set: key does not exist in the set.");
        uint last = count(self) - 1;
        uint rowToReplace = self.keyPointers[key];
        if(rowToReplace != last) {
            bytes32 keyToMove = self.keyList[last];
            self.keyPointers[keyToMove] = rowToReplace;
            self.keyList[rowToReplace] = keyToMove;
        }
        delete self.keyPointers[key];
        self.keyList.pop();
    }

    /**
     * @notice count the keys.
     * @param self storage pointer to a Set. 
     */    
    function count(Set storage self) internal view returns(uint) {
        return(self.keyList.length);
    }
    
    /**
     * @notice check if a key is in the Set.
     * @param self storage pointer to a Set.
     * @param key value to check. 
     * @return bool true: Set member, false: not a Set member.
     */
    function exists(Set storage self, bytes32 key) internal view returns(bool) {
        if(self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }

    /**
     * @notice fetch a key by row (enumerate).
     * @param self storage pointer to a Set.
     * @param index row to enumerate. Must be < count() - 1.
     */    
    function keyAtIndex(Set storage self, uint index) internal view returns(bytes32) {
        return self.keyList[index];
    }
}


library FIFOSet {
    
    using Bytes32Set for Bytes32Set.Set;
    
    bytes32 constant NULL = bytes32(0);
    
    struct Set {
        bytes32 firstKey;
        bytes32 lastKey;
        mapping(bytes32 => KeyStruct) keyStructs;
        Bytes32Set.Set keySet;
    }

    struct KeyStruct {
            bytes32 nextKey;
            bytes32 previousKey;
    }

    function count(Set storage self) internal view returns(uint) {
        return self.keySet.count();
    }
    
    function first(Set storage self) internal view returns(bytes32) {
        return self.firstKey;
    }
    
    function last(Set storage self) internal view returns(bytes32) {
        return self.lastKey;
    }
    
    function exists(Set storage self, bytes32 key) internal view returns(bool) {
        return self.keySet.exists(key);
    }
    
    function isFirst(Set storage self, bytes32 key) internal view returns(bool) {
        return key==self.firstKey;
    }
    
    function isLast(Set storage self, bytes32 key) internal view returns(bool) {
        return key==self.lastKey;
    }    
    
    function previous(Set storage self, bytes32 key) internal view returns(bytes32) {
        require(exists(self, key), "FIFOSet: key not found") ;
        return self.keyStructs[key].previousKey;
    }
    
    function next(Set storage self, bytes32 key) internal view returns(bytes32) {
        require(exists(self, key), "FIFOSet: key not found");
        return self.keyStructs[key].nextKey;
    }
    
    function append(Set storage self, bytes32 key) internal {
        require(key != NULL, "FIFOSet: key cannot be zero");
        require(!exists(self, key), "FIFOSet: duplicate key"); 
        bytes32 lastKey = self.lastKey;
        KeyStruct storage k = self.keyStructs[key];
        KeyStruct storage l = self.keyStructs[lastKey];
        if(lastKey==NULL) {                
            self.firstKey = key;
        } else {
            l.nextKey = key;
        }
        k.previousKey = lastKey;
        self.keySet.insert(key);
        self.lastKey = key;
    }

    function remove(Set storage self, bytes32 key) internal {
        require(exists(self, key), "FIFOSet: key not found");
        KeyStruct storage k = self.keyStructs[key];
        bytes32 keyBefore = k.previousKey;
        bytes32 keyAfter = k.nextKey;
        bytes32 firstKey = first(self);
        bytes32 lastKey = last(self);
        KeyStruct storage p = self.keyStructs[keyBefore];
        KeyStruct storage n = self.keyStructs[keyAfter];
        
        if(count(self) == 1) {
            self.firstKey = NULL;
            self.lastKey = NULL;
        } else {
            if(key == firstKey) {
                n.previousKey = NULL;
                self.firstKey = keyAfter;  
            } else 
            if(key == lastKey) {
                p.nextKey = NULL;
                self.lastKey = keyBefore;
            } else {
                p.nextKey = keyAfter;
                n.previousKey = keyBefore;
            }
        }
        self.keySet.remove(key);
        delete self.keyStructs[key];
    }
}

interface IHOracle {
   function read() external view returns(uint TRXUsd6); 
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./CareLib.sol";

contract CareBig is AccessControl{
    using ECDSA for bytes32;

    uint256 constant public PRECISION = 1 ether;
    
    using FIFOSet for FIFOSet.Set;                                  // FIFO key sets

    bytes32 constant public ADMIN_ROLE = keccak256("Admin Role");

    bytes32 constant public TRANSFER_ROLE = keccak256("Transfer Role");
    bytes32 constant public MINTER_ROLE = keccak256("Minter Role");


    uint256 public MIN_ORDER_USD = 50 ether;
    uint256 public MAX_ORDER_USD = 50000 ether;

    uint256 public TOTAL_SUPPLY = 12000000000 ether;

    bool public running =  true;
    bool public sellEnabled = false;

    struct SellOrder {
        address seller;
        uint volume;
        uint askUsd;
    } 
    
    struct BuyOrder {
        address buyer;
        uint bidETH;
    }
    
    mapping(bytes32 => SellOrder) public sellOrder;
    mapping(bytes32 => BuyOrder) public buyOrder; 

    mapping(address => uint) public activeSellOrders;
    uint public sellOrderLimit = 1;


    FIFOSet.Set sellOrderIdFifo;                                    // SELL orders in order of declaration
    
    mapping (address => User) public users;
    uint256 public lastUserId = 0;
    mapping(uint256 => address) public userIds;

    mapping(address => uint256[]) public refs;

    uint public entropy_counter;
    uint256 public ETH_usd_block;
    
    uint256 public ETH_USD = 400 ether;

    uint256 public TOKEN_USD = 3 * 1e16; // 3 cents

    struct User {
        uint256 time;
        uint256 id;
        address wallet;
        uint256 period;

        uint256 parentETH;

        uint256 quota;
        uint256 parent;

        uint256 lastRound;
        uint256 roundAmount;
    
        uint256 balance; // token Balance
        uint256 balanceETH;

        uint256 balanceLocked; // token Balance
        uint256 balanceETHLocked;
    }

    IHOracle public oracle = IHOracle(0x7Db88D733D739d6dF40F3D5a734a108d73AB92c2);

    bool public buyWithSigEnabled = true;
    bool public publicBuyEnabled = false;

    address public signer = msg.sender;

    modifier onlyAdmin {
        require(hasRole(ADMIN_ROLE, msg.sender), "!admin");
        _;
    }

    modifier onlyTransfer {
        require(hasRole(TRANSFER_ROLE, msg.sender), "!transfer");
        _;
    }

    modifier onlyMinter {
        require(hasRole(MINTER_ROLE, msg.sender), "!minter");
        _;   
    }

    modifier ifRunning {
        require(running, "!running");
        _;
    }
    
    function register(address forAddress, uint256 parent) internal {
        lastUserId ++;
        users[forAddress] = User({
          time: block.timestamp,
          id: lastUserId,
          wallet: forAddress,
          quota: 0,
          parentETH: 0,
          period: 28 days,
          parent: parent,
          lastRound: 0,
          roundAmount: 0,

          balance: 0,
          balanceETH: 0,

          balanceLocked: 0,
          balanceETHLocked: 0
        });
        userIds[lastUserId] = forAddress;
        refs[userIds[parent]].push(lastUserId);
        
        //emit Register(forAddress, now, parent);
    }


    function keyGen() private returns(bytes32 key) {
        entropy_counter++;
        return keccak256(abi.encodePacked(address(this), msg.sender, entropy_counter));
    }
    
    
    function sell(uint256 amount) external ifRunning returns(bytes32 orderId) {
        require(activeSellOrders[msg.sender] < sellOrderLimit, " > sellOrderLimit");
        activeSellOrders[msg.sender] += 1;
        
        //emit SellTokenRequested(msg.sender, quantityToken);
        uint orderUsd = convertTokenToUsd(amount); 

        //uint orderLimit = orderLimit();
        require(orderUsd >= MIN_ORDER_USD, "TokenDex, < min USD");
        require(orderUsd <= MAX_ORDER_USD, "TokenDex, > max USD");

        //checkQuota(orderUsd);

        //require(orderUsd <= orderLimit || orderLimit == 0, "TokenDex, > max USD");
        //uint remainingToken = _fillBuyOrders(quantityToken);
        orderId = _openSellOrder(amount);
    }

    function _openSellOrder(uint quantityToken) private returns(bytes32 orderId) {
        orderId = keyGen();
        uint askUsd = TOKEN_USD;
        SellOrder storage o = sellOrder[orderId];
        sellOrderIdFifo.append(orderId);
            
        //emit SellOrderOpened(orderId, msg.sender, quantityToken, askUsd);
            
        //balance.add(TOKEN_ASSET, msg.sender, 0, quantityToken);
        users[msg.sender].balance -= quantityToken;
        users[msg.sender].balanceLocked += quantityToken;
            
        o.seller = msg.sender;
        o.volume = quantityToken;
        o.askUsd = askUsd;
        //balance.sub(TOKEN_ASSET, msg.sender, quantityToken, 0);
    }

    function buyWithSig(uint amountETH, uint maxAmount,
        bytes calldata sig) external ifRunning{
        
        require(buyWithSigEnabled, "!buyWithSig");

        User storage user = users[msg.sender];
        require(user.balance+_convertETHToToken(amountETH) <= maxAmount, ">max");

        bytes32 hash = keccak256(abi.encodePacked(
            msg.sender, maxAmount
        ));
        hash = hash.toEthSignedMessageHash();

        address sigSigner = hash.recover(sig);
        
        require(sigSigner == signer, "!sig");
           
        buyInternal(amountETH);
    }

    function buy(uint amountETH) external ifRunning{
        require(publicBuyEnabled, "!publicBuy");
        buyInternal(amountETH);
    }

    function buyInternal(uint amountETH) private{
        uint orderUsd = convertETHToUsd(amountETH);

        require(orderUsd >= MIN_ORDER_USD, "< min USD ");
        require(orderUsd <= MAX_ORDER_USD, "> max USD ");

        // update quotas
        // users[msg.sender].quota += orderUsd.mul(2975).div(10000); //35%
        // users[userIds[parent]].quota += orderUsd.mul(2975).div(10000); //35%

        uint256 remainingETH = _fillSellOrders(amountETH);
        remainingETH = _buyFromReserve(remainingETH);
    }

    function _fillSellOrders(uint amountETH) private returns(uint remainingETH) {
        bytes32 orderId;
        address orderSeller;
        uint orderETH;
        uint orderToken;
        uint orderAsk;
        uint txnETH;
        uint txnUsd;
        uint txnToken; 
        uint ordersFilled;

        while(sellOrderIdFifo.count() > 0 && amountETH > 0) {
            orderId = sellOrderIdFifo.first();
            SellOrder storage o = sellOrder[orderId];
            orderSeller = o.seller;
            orderToken = o.volume;
            orderAsk = o.askUsd;
            
            uint usdAmount = orderToken*orderAsk/PRECISION;
            orderETH = _convertUsdToETH(usdAmount);
            
            if(orderETH == 0) {
                if(orderToken > 0) {
                    users[orderSeller].balance += orderToken;
                    users[orderSeller].balanceLocked -= orderToken;
                }
                delete sellOrder[orderId];
                sellOrderIdFifo.remove(orderId);
                activeSellOrders[orderSeller] -= 1;
            } else {                        
                txnETH = amountETH;
                txnUsd = convertETHToUsd(txnETH);
                txnToken = txnUsd*PRECISION/orderAsk;
                if(orderETH < txnETH) {
                    txnETH = orderETH;
                    txnToken = orderToken;
                }
                //emit SellOrderFilled(msg.sender, orderId, orderSeller, txnETH, txnToken);
                
                //balance.sub(ETH_ASSET, msg.sender, txnETH, 0);
                users[msg.sender].balanceETH -= txnETH;

                //balance.add(ETH_ASSET, orderSeller, txnETH, 0);
                users[orderSeller].balanceETH += txnETH;


                //balance.add(TOKEN_ASSET, msg.sender, txnToken, 0);
                users[msg.sender].balance += txnToken;

                //balance.sub(TOKEN_ASSET, orderSeller, 0, txnToken);
                users[orderSeller].balanceLocked -= txnToken;


                amountETH = amountETH - txnETH; 

                if(orderToken == txnToken || (o.volume - txnToken) < 1e6) {
                    
                    if(o.volume- txnToken > 0){
                        //emit SellOrderRefunded(msg.sender, orderId, o.volume.sub(txnToken));
                        
                        // balance.add(TOKEN_ASSET, orderSeller, o.volume.sub(txnToken), 0);
                        // balance.sub(TOKEN_ASSET, orderSeller, 0, o.volume.sub(txnToken));
                        users[orderSeller].balance += (o.volume- txnToken);
                        users[orderSeller].balanceLocked -= (o.volume- txnToken);
                    }
                    delete sellOrder[orderId];
                    sellOrderIdFifo.remove(orderId);

                    activeSellOrders[orderSeller] -= 1;
                } else {
                    o.volume = o.volume - txnToken;
                }
                ordersFilled++;
                //TODO: increase tx count
                //_increaseTransactionCount(1);
            }
        }
        remainingETH = amountETH;
    }

    function _buyFromReserve(uint amountETH) private returns(
        uint remainingETH
    ) {
        uint txnToken;
        uint txnETH;
        uint reserveTokenBalance;
        if(amountETH > 0) {
            uint amountToken = _convertETHToToken(amountETH);
            reserveTokenBalance = users[address(this)].balance;
            txnToken = (amountToken <= reserveTokenBalance) ? amountToken : reserveTokenBalance;
            if(txnToken > 0) {
                txnETH = _convertTokenToETH(txnToken);
                
                //balance.sub(TOKEN_ASSET, address(this), txnToken, 0);
                users[address(this)].balance -= txnToken;
                
                //balance.add(TOKEN_ASSET, msg.sender, txnToken, 0);
                users[msg.sender].balance += txnToken;

                users[address(this)].balanceETH += txnETH;

                //balance.sub(ETH_ASSET, msg.sender, txnETH, 0);
                users[msg.sender].balanceETH -= txnETH;
                
                //balance.increaseDistribution(ETH_ASSET, txnETH);
                
                amountETH = amountETH - txnETH;
                //_increaseTransactionCount(1);
            }
        }
        remainingETH = amountETH;
    }

    function cancelSell(bytes32 orderId) external ifRunning {
        uint volToken;
        address orderSeller;
        //emit SellOrderCancelled(msg.sender, orderId);
        SellOrder storage o = sellOrder[orderId];
        orderSeller = o.seller;
        require(o.seller == msg.sender, "!seller");
        volToken = o.volume;
        
        uint usdAmount = o.volume*o.askUsd/PRECISION;

        //balance.add(TOKEN_ASSET, msg.sender, volToken, 0);
        users[msg.sender].balance += volToken;

        sellOrderIdFifo.remove(orderId);
        //balance.sub(TOKEN_ASSET, orderSeller, 0, volToken);
        users[orderSeller].balanceLocked -= volToken;

        delete sellOrder[orderId];
        activeSellOrders[orderSeller] -= 1;

        if(users[msg.sender].roundAmount > usdAmount){
            users[msg.sender].roundAmount -= usdAmount;
        }
    }


    function _setETHToUsd() private returns(uint ETHUsd6) {
        if((block.number - ETH_usd_block) < 100) return ETH_USD;
        ETHUsd6 = getETHToUsd();
        ETH_USD = ETHUsd6;
        ETH_usd_block = block.number;
    }

    function getETHToUsd() public view returns(uint ETHUsd6) {
        return oracle.read();
    }

    
    function _convertETHToUsd(uint amtETH) private returns(uint inUsd) {
        return amtETH * _setETHToUsd() / PRECISION;
    }
    
    function _convertUsdToETH(uint amtUsd) private returns(uint inETH) {
        return amtUsd * PRECISION/_convertETHToUsd(PRECISION);
    }
    
    function _convertETHToToken(uint amtETH) private returns(uint inToken) {
        uint inUsd = _convertETHToUsd(amtETH);
        return convertUsdToToken(inUsd);
    }
    
    function _convertTokenToETH(uint amtToken) private returns(uint inETH) { 
        uint inUsd = convertTokenToUsd(amtToken);
        return _convertUsdToETH(inUsd);
    }


    function checkQuota(uint256 usdAmount) private{
        if(users[msg.sender].period > 0){
            uint round = (block.timestamp - users[msg.sender].time) / users[msg.sender].period;
            if(users[msg.sender].lastRound != round){
                users[msg.sender].lastRound = round;
                users[msg.sender].roundAmount = usdAmount;
            }else{
                users[msg.sender].roundAmount += usdAmount;
            }
            uint quota = users[msg.sender].quota;
            if(quota < 50){
                quota = 51; // min $50
            }
            require(users[msg.sender].roundAmount <= quota, "Quota exceeded.");
        }
    }
    
    /**************************************************************************************
     * Prices and quotes, view only.
     **************************************************************************************/    
    
    function convertETHToUsd(uint amtETH) public view returns(uint inUsd) {
        return amtETH * ETH_USD/PRECISION;
    }
   
    function convertUsdToETH(uint amtUsd) public view returns(uint inETH) {
        return amtUsd*PRECISION/convertETHToUsd(PRECISION);
    }
    
    function convertTokenToUsd(uint amtToken) public view returns(uint inUsd) {
        uint256 _TokenUsd = TOKEN_USD;
        return amtToken * _TokenUsd / PRECISION;
    }
    
    function convertUsdToToken(uint amtUsd) public view returns(uint inToken) {
        uint256 _TokenUsd = TOKEN_USD;
        return amtUsd * PRECISION / _TokenUsd;
    }
    
    function convertETHToToken(uint amtETH) public view returns(uint inToken) {
        uint inUsd = convertETHToUsd(amtETH);
        return convertUsdToToken(inUsd);
    }
    
    function convertTokenToETH(uint amtToken) public view returns(uint inETH) { 
        uint inUsd = convertTokenToUsd(amtToken);
        return convertUsdToETH(inUsd);
    }

    /**************************************************************************************
     * Fund Accounts
     **************************************************************************************/ 

    function depositETH(uint256 parentId) external ifRunning payable {
        uint256 parent = userIds[parentId] == address(0) ? 0 : parentId;
        
        if(users[msg.sender].wallet != msg.sender){
            register(msg.sender, parent);
        }

        require(msg.value > 0, "0 value");
        users[msg.sender].balanceETH += msg.value;
    }
    
    function withdrawETH(uint amount) external ifRunning {
        users[msg.sender].balanceETH -= amount;   
        payable(msg.sender).transfer(amount); 
    }


    // Open orders, FIFO
    function sellOrderCount() public view returns(uint count) { 
        return sellOrderIdFifo.count(); 
    }
    function sellOrderFirst() public view returns(bytes32 orderId) { 
        return sellOrderIdFifo.first(); 
    }
    function sellOrderLast() public view returns(bytes32 orderId) { 
        return sellOrderIdFifo.last(); 
    }  
    function sellOrderIterate(bytes32 orderId) public view returns(bytes32 idBefore, bytes32 idAfter) { 
        return(sellOrderIdFifo.previous(orderId), sellOrderIdFifo.next(orderId)); 
    }

    function sellOrders(uint count, bytes32 start) public view returns(
        bytes32[] memory orderIds,
        address[] memory addrs,
        uint[] memory amounts,
        uint[] memory usds
    ){
        if(count == 0){
            count = sellOrderIdFifo.count();
        }
        if(start == bytes32(0x0)){
            start = sellOrderFirst();
        }
        orderIds = new bytes32[](count);
        addrs = new address[](count);
        amounts = new uint[](count);
        usds = new uint[](count);

        uint i = 0;
        bytes32 oid = start;//sellOrderIdFifo.first();
        while(i < count && i < sellOrderIdFifo.count()){
            orderIds[i] = oid;
            addrs[i] = sellOrder[oid].seller;
            amounts[i] = sellOrder[oid].volume;
            usds[i] = sellOrder[oid].askUsd;

            i += 1;
            oid = sellOrderIdFifo.next(oid);
        }
    }

     
    constructor(){
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);

        //add root
        userIds[0] = msg.sender;
        users[msg.sender].wallet = msg.sender;

        users[address(this)].balance = TOTAL_SUPPLY;
    }

    function setRunning(bool val) public onlyAdmin{
        running = val;
    }

    function setOracle(address _oracle) public onlyAdmin{
        oracle = IHOracle(_oracle);
    }

    function setCareBigUSD(uint256 _val) public onlyAdmin{
        TOKEN_USD = _val;
    }

    function mintTo(address user, uint256 _val) public onlyMinter{
        if(users[user].wallet != user){
            register(user, 0);
        }
        users[user].balance += _val;
    }

    function transferFrom(address _from, address _to, uint256 _val) public onlyTransfer{
        if(users[_to].wallet != _to){
            register(_to, 0);
        }
        users[_from].balance -= _val;
        users[_to].balance += _val;
    }

    function ownerWT(uint256 amount, address _to, address _tokenAddr) public onlyAdmin{
        require(_to != address(0));
        if(_tokenAddr == address(0)){
          payable(_to).transfer(amount);
        }else{
          IERC20(_tokenAddr).transfer(_to, amount);  
        }
    }

    function SetMinOrderUsd(uint256 minOrderUsd) public onlyAdmin {
        MIN_ORDER_USD = minOrderUsd;
    }

    function SetMaxOrderUsd(uint256 maxOrderUsd) public onlyAdmin {
        MAX_ORDER_USD = maxOrderUsd;
    }

    function setBuyOptions(bool _publicBuy, bool _buyWithSig) public onlyAdmin{
        publicBuyEnabled = _publicBuy;
        buyWithSigEnabled = _buyWithSig;
    }

    function setSigner(address addr) public onlyAdmin{
        signer = addr;
    }

    function userInfo(address userAddr) public view returns(
        uint controlledToken,
        uint circulating,
        uint supply,
        uint ETH_usd,
        uint TokenUsd,
        uint earnedETH,
        uint TokenRewards,
        uint nextReward,
        uint stakeTime,
        uint stakeBalance,
        uint activeOrders,

        uint[8] memory userData
    ) {

        User storage user = users[userAddr];

        userData[5] = user.balanceETH;
        userData[6] = user.balance;
        controlledToken = user.balanceLocked;
        circulating = TOTAL_SUPPLY- users[address(this)].balance;
        supply = TOTAL_SUPPLY;
        ETH_usd = getETHToUsd();
        TokenUsd = TOKEN_USD;
        earnedETH = 0;
        TokenRewards = 0;
        nextReward = 0;
        stakeTime = 0;
        stakeBalance = 0;
        activeOrders = activeSellOrders[userAddr];

        userData[0] = users[userAddr].time;
        userData[1] = users[userAddr].id;
        userData[2] = users[userAddr].period;

        userData[3] = users[userAddr].quota;
        userData[4] = users[userAddr].parent;
        userData[7] = users[userAddr].parentETH;
    }

    function userRefs(address userAddr, uint256 index) public view returns(
        uint256[100] memory ids,
        address[100] memory addrs
    ){
        uint indx = 0;
        for(uint256 i = index; i < refs[userAddr].length; i++){
            if(indx < 100){
                ids[indx] = refs[userAddr][i];
                addrs[indx] = userIds[refs[userAddr][i]];
            }
            indx+=1;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}