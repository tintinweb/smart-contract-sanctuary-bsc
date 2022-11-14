/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function sweep() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }


    function transferForeignToken(address _token, address _to,uint256 value) public onlyOwner returns(bool _sent){
        uint256 _contractBalance = value;
        if(value<=0){
            _contractBalance=IERC20(_token).balanceOf(address(this));
        }
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

    receive() external payable {

    }

    fallback() external payable {

    }
}

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface IERC721 {

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    function ownerOf(uint256 tokenId) external view returns (address) ;

    function getTokenStatus(uint256 tokenId) external view returns(uint8);

    function getTokenStatusList(uint256[] memory tokenId) external view returns(uint8[] memory stateList);

    function getLotteryResultValue(uint256 tokenId,uint8 way) external view returns(string memory _itemValue);

    function getLotteryResultListByTokenId(uint256[] memory tokenId) external view returns(uint8[][] memory _ways,string[][] memory _itemValue);
}

/**
 * @dev String operations.
 */
library Strings {
    //string 对比
    function isEqual(string memory a, string memory b) internal pure returns (bool) {
        bytes memory aa = bytes(a);
        bytes memory bb = bytes(b);
        // 如果长度不等，直接返回
        if (aa.length != bb.length) return false;
        // 按位比较
        for(uint i = 0; i < aa.length; i ++) {
            if(aa[i] != bb[i]) return false;
        }
        return true;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
    unchecked {
        counter._value += 1;
    }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
    unchecked {
        counter._value = value - 1;
    }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

contract LotteryBetContract is Ownable{
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using Strings for string;

    //竞猜平台支付代币（USDT）
    address public _LotteryTokenContract= 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    IERC20  _LotteryToken;

    address public _GameTokenContract= 0x77c50f560FB3ccCC6D0cB8d505F9Ad4A32db017E;
    IERC20  _GameToken;

    //竞猜平台竞猜NFT
    address public _LotteryNFTTokenContract= 0x647C588469d959db1793C24Dd6f267E763A602BE;
    IERC721 _LotteryNFTToken;

    //复合竞猜奖池
    address public poolAddress= 0x60c094F7b72D6Bb51C3a377f82614F33D02CEBFE;
    uint256 public poolFee=3;

    //平台税收
    address public platformAddress= 0xd0eC69B5a776baf8022DFE747DcaB0eeE904fF74;
    uint256 public platformFee=2;

    //回购地址
    address public buyBackAddress= 0x330e1a59445E2A508E301aCCA989EbFe64feDf67;
    //回购比例
    uint256 public buyBackFee=2;

    //Nft Kol持有者获取比例
    uint256 public nftKolFee=5;

    //返佣比例
    uint256 public inviteAwardFee=5;

    //足球游戏代币返现比例
    uint256 public gameRakeBackRatio=6;

    //足球游戏币提现开关
    bool public gameTokenWithdrawalsWitch=false;

    //////NFT竞猜//////
    constructor(){
        _LotteryToken=IERC20(_LotteryTokenContract);
        _LotteryNFTToken=IERC721(_LotteryNFTTokenContract);
    }

    //奖池剩余比例
    function prizePool()private view returns(uint256){
        uint256 prizePoolValue=100;
        if(_IA[_msgSender()]==poolAddress){
            return prizePoolValue.sub(nftKolFee).sub(buyBackFee).sub(poolFee).sub(platformFee);
        }else{
            return prizePoolValue.sub(nftKolFee).sub(inviteAwardFee).sub(platformFee);
        }
    }
    //奖池剩余比例
    function sendBetPool()private view returns(uint256){
        uint256 prizePoolValue=100;
        if(_IA[_msgSender()]==poolAddress){
            return prizePoolValue.sub(nftKolFee).sub(buyBackFee).sub(poolFee).sub(platformFee);
        }else{
            return prizePoolValue.sub(nftKolFee).sub(platformFee);
        }
    }

    function setLotteryTokenContract(address token) external onlyOwner {
        _LotteryTokenContract=token;
        _LotteryToken=IERC20(_LotteryTokenContract);
    }

    function setGameTokenContract(address token) external onlyOwner {
        _GameTokenContract=token;
        _GameToken=IERC20(_GameTokenContract);
    }

    function setLotteryNFTTokenContract(address token) external onlyOwner{
        _LotteryNFTTokenContract=token;
        _LotteryNFTToken=IERC721(_LotteryNFTTokenContract);
    }

    function setInviteAwardFee(uint256 _inviteAwardFee) external onlyOwner{
        inviteAwardFee=_inviteAwardFee;
    }

    function setBuyBackFee(uint256 _buyBackFee) external onlyOwner{
        buyBackFee=_buyBackFee;
    }

    function setPlatformFee(uint256 _platformFee) external onlyOwner{
        platformFee=_platformFee;
    }

    function setPoolFee(uint256 _poolFee) external onlyOwner{
        poolFee=_poolFee;
    }

    function setNftKolFee(uint256 _nftKolFee) external onlyOwner{
        nftKolFee=_nftKolFee;
    }

    function setGameRakeBackRatio(uint256 _gameRakeBackRatio) external onlyOwner{
        gameRakeBackRatio=_gameRakeBackRatio;
    }

    function setGameTokenWithdrawalsWitch(bool status) external onlyOwner{
        gameTokenWithdrawalsWitch=status;
    }


    //////NFT竞猜/////
    struct NFTBet {
        uint256 orderId;//订单号
        uint256 tokenId;
        uint8 way;//玩法
        string choose;//投注项
        uint256 money;//投注额
        address use;//投注人
    }
    //mad:0、其他  1、足球  2、篮球  3、电子竞技
    //ways;//1.胜负平模式 2.比分模式 4.N选1模式
    //key: tokenId  key2:ways  value:price  每场比赛每个玩法的总金额
    mapping (uint256 =>mapping(uint8=>uint256)) public _BWP;
    //key: tokenId  key2:ways key3=choose value:price  每场比赛每个玩法每个选项的投注总金额
    mapping (uint256 =>mapping(uint8=>mapping(string=>uint256))) public _BWCM;
    //key: tokenId  key2:ways key3=choose  key4:use value:price  每场比赛每个玩法每个选项的每个用户的投注总金额
    mapping (uint256 =>mapping(uint8=>mapping(string=>mapping(address=>uint256)))) public _BWCUM;
    //key: tokenId  key2:ways key3:use value:[]  每场比赛每个玩法每个用户的投注选项汇总
    mapping (uint256 =>mapping(uint8=>mapping(address=>string[]))) public _BWCVUM;
    //key: user  value:tokenId  用户参与的投注NftToken集合
    mapping (address=>uint256[]) public _UBTM;
    //key: user  value:tokenId  value: way集合 用户参与的投注Way集合
    mapping (address=>mapping(uint256=>uint8[])) public _UTW;
    //用户投注总额
    mapping (address =>uint256) public _UM;
    //游戏代币提取总额
    mapping (address =>uint256) public _UMRG;

    //邀请人的地址 key是用户  value是被谁邀请的
    mapping(address=>address) public _IA;
    //邀请人返利总金额
    mapping(address=>uint256) public _IAR;
    //邀请人提取金额
    mapping(address=>uint256) public _IARE;
    //邀请人的返佣列表
    mapping(address=>InviteReturn[]) public _IALM;
    struct InviteReturn {
        address use;//投注人
        uint256 money;//投注金额
        uint256 inviteReturn;//返佣金额
        uint256 tmSmp;//时间
    }

    //Kol返利金额
    // key1=tokenId key=way value=金额
    mapping(uint256=>mapping(uint8=>uint256)) public _BP;
    //Kol返利金额 已提取金额
    // key1=tokenId key=way value=金额
    mapping(uint256=>mapping(uint8=>uint256)) public _BPE;
    //key: tokenId  key2:ways  value:price  每场比赛每个玩法的归属用户的代币金额  考虑税率的变动 因此将金额单独存储
    mapping(uint256 =>mapping(uint8=>uint256)) public _BWTUM;
    //key: tokenId  key2:ways key3:user value:price  每场比赛每个玩法用户领取的金额
    mapping(uint256 =>mapping(uint8=>mapping(address=>uint256))) public _BWEM;
    //////////////////////////下注接口//////////////////////////
    //返佣出的游戏币总数
    uint256 public _gameTokenTotal=0;
    //下注接口
    function betOrder(uint256[] memory _tokenId,uint8[] memory ways,string[] memory wayValue,uint256[] memory betMoney,address inviteAddress)external returns(bool){
        require(_tokenId.length==ways.length&&ways.length==wayValue.length&&wayValue.length==betMoney.length, "error: parameter is error!");
        if(_msgSender()==inviteAddress){
            inviteAddress = address(0);
        }
        uint8[] memory stateList = _LotteryNFTToken.getTokenStatusList(_tokenId);
        uint sumMoney=0;
        for(uint index=0;index<_tokenId.length;index++){
            //只有已经创建的比赛可以投注
            require(stateList[index]==1, "bet status is error!");
            require(betMoney[index]>=1 * 10**18, "bet money is error!");
            if(_UTW[_msgSender()][_tokenId[index]].length<=0){
                _UBTM[_msgSender()].push(_tokenId[index]);
            }
            if(_BWP[_tokenId[index]][ways[index]]<=0){
                _UTW[_msgSender()][_tokenId[index]].push(ways[index]);
            }
            _BWP[_tokenId[index]][ways[index]]+=betMoney[index];
            _BWCM[_tokenId[index]][ways[index]][wayValue[index]]+=betMoney[index];
            if(_BWCUM[_tokenId[index]][ways[index]][wayValue[index]][_msgSender()]<=0){
              _BWCVUM[_tokenId[index]][ways[index]][_msgSender()].push(wayValue[index]);
            }
            _BWCUM[_tokenId[index]][ways[index]][wayValue[index]][_msgSender()]+=betMoney[index];
            _BP[_tokenId[index]][ways[index]]+=sumMoney.mul(nftKolFee).div(100);
            _BWTUM[_tokenId[index]][ways[index]]+=sumMoney.mul(prizePool()).div(100);
            sumMoney+=betMoney[index];
        }
        if(_IA[_msgSender()]==address(0)){
            if(inviteAddress==address(0)){
               _IA[_msgSender()]=poolAddress;
            }else{
                _IA[_msgSender()]=inviteAddress;
            }
        }
        betPay(sumMoney);
        return true;
    }

    //支付分配
    function betPay(uint256 sumMoney) internal{
        transferToAddress(address(this),sumMoney.mul(sendBetPool()).div(100));
        transferToAddress(platformAddress,sumMoney.mul(platformFee).div(100));
        if(_IA[_msgSender()]==poolAddress){
            transferToAddress(poolAddress,sumMoney.mul(poolFee).div(100));
            transferToAddress(buyBackAddress,sumMoney.mul(buyBackFee).div(100));
            //transfer(poolAddress,sumMoney.mul(poolFee.add(buyBackFee)).div(100));
        }else{
            uint256 inviteAwardValue = sumMoney.mul(inviteAwardFee).div(100);
            if(inviteAwardValue>0){
                _IAR[_IA[_msgSender()]]+=inviteAwardValue;
                InviteReturn memory ir=InviteReturn(_msgSender(),sumMoney,inviteAwardValue,block.timestamp);
                _IALM[_IA[_msgSender()]].push(ir);
            }
        }
        _UM[_msgSender()]+=sumMoney;
    }
    //转账
    function transferToAddress(address recipient, uint256 amount) private {
        if(amount>0)
            _LotteryToken.transferFrom(_msgSender(),recipient,amount);
    }

    //////////////////////////我的邀请列表//////////////////////////
    //我的邀请列表 及 可提取返佣金额 和 已提取返佣金额
    function queryInviteList(uint256 _lastIndex,uint256 _limit) external view returns(address[] memory use,uint256[] memory sumMoney,uint256[] memory returnMoney,uint256[] memory timeValue,uint256 lastIndex,uint256 inviteReceiveValue,uint256 completeInviteReceive){
        InviteReturn[] memory ir= _IALM[_msgSender()];
        if(ir.length<=0){
            return (use,sumMoney,returnMoney,timeValue,0, _IAR[_msgSender()], _IARE[_msgSender()]);
        }
        if(_lastIndex>=ir.length){
            _lastIndex=ir.length.sub(1);
        }
        if(_lastIndex<_limit.sub(1)){
            _limit=_lastIndex.add(1);
        }
        use=new address[](_limit);
        returnMoney=new uint256[](_limit);
        sumMoney=new uint256[](_limit);
        timeValue=new uint256[](_limit);
        for(uint256 index=0;index<_limit;index++){
            InviteReturn memory irValue=ir[_lastIndex];
            use[index]=irValue.use;
            returnMoney[index]=irValue.inviteReturn;
            sumMoney[index]=irValue.money;
            timeValue[index]=irValue.tmSmp;
            if(_lastIndex>0){
                _lastIndex--;
            }
        }
        return (use,sumMoney,returnMoney,timeValue,_lastIndex, _IAR[_msgSender()], _IARE[_msgSender()]);
    }

    //提取邀请返佣金额
    function inviteReceive() external{
        uint256 maxReceive= _IAR[_msgSender()].sub(_IARE[_msgSender()],"error: your credit is running low!");
        _IARE[_msgSender()]+=maxReceive;
        _LotteryToken.transfer(_msgSender(),maxReceive);
    }

    //////////////////////////我参加的竞猜列表//////////////////////////
    function queryMyLotteryList(uint256 lastIndex,uint256 limit,address user) external view returns(MyLotteryItem[] memory,uint256){
        (uint256[] memory _tokenId,uint256 _lastIndex) = calcLotteryTokenId(lastIndex,limit,user);
        (uint8[][] memory _ways,string[][] memory _itemValue) = _LotteryNFTToken.getLotteryResultListByTokenId(_tokenId);
        MyLotteryItem[] memory _myLottery= queryLotteryItemChoose(_tokenId,_ways,_itemValue,user);
        return (_myLottery,_lastIndex);
    }
    struct MyLotteryItem{
        uint256 tokenId;
        uint8 way;
        string item;
        uint256 itemMoney;
        uint256 award;
        uint256 receiveAward;
    }
    //获取我参加的竞猜TokenId集合
    function calcLotteryTokenId(uint256 lastIndex,uint256 limit,address user) public view returns(uint256[] memory _tokenId,uint256 _lastIndex){
        if(_UBTM[user].length<=0){
            return (_tokenId,lastIndex);
        }
        if(lastIndex>=_UBTM[user].length){
            lastIndex= _UBTM[user].length.sub(1);
        }
        if(lastIndex<limit.sub(1)){
            limit=lastIndex.add(1);
        }
        _tokenId = new uint256[](limit);
        for(uint256 index=0;index<limit;index++){
            _tokenId[index]= _UBTM[user][lastIndex];
            if(lastIndex>0){
                lastIndex--;
            }
        }
        return (_tokenId,lastIndex);
    }

    //获取我的所有投注项、投注金额和中奖金额
    function queryLotteryItemChoose(uint256[] memory _tokenId,uint8[][] memory _ways,string[][] memory _itemValue,address user)private view returns(MyLotteryItem[] memory _myLottery){
        _myLottery = new MyLotteryItem[](calcItemChooseLength(_tokenId,user));
        uint vIndex=0;
        for(uint256 index =0;index< _tokenId.length;index++){
            for(uint256 wayIndex=0;wayIndex<_UTW[user][_tokenId[index]].length;wayIndex++){
                //获取所有的下注
                string[] memory chooseItem= _BWCVUM[_tokenId[index]][_UTW[user][_tokenId[index]][wayIndex]][user];
                for(uint256 chooseIndex=0;chooseIndex<chooseItem.length;chooseIndex++){
                    _myLottery[vIndex++]=calcLotteryResult(_tokenId[index],_ways[index],_itemValue[index],_UTW[user][_tokenId[index]][wayIndex],chooseItem[chooseIndex],user);
                }
            }
        }
        return _myLottery;
    }

    function calcLotteryResult(uint256 tokenId,uint8[] memory ways,string[] memory itemValue,uint8 chekWay,string memory checkItemValue,address user) internal view returns(MyLotteryItem memory item){
        item=MyLotteryItem(tokenId,chekWay,checkItemValue,_BWCUM[tokenId][chekWay][checkItemValue][user],0,_BWEM[tokenId][chekWay][user]);
        for(uint index=0;index<ways.length;index++){
            if(ways[index]==chekWay){
                if(bytes(checkItemValue).length>0&&itemValue[index].isEqual(checkItemValue)){
                    item.award+=calcBetAward(tokenId,chekWay,checkItemValue,item.itemMoney);
                    break;
                }
            }
        }
        return item;
    }

    //计算可选项的总长度
    function calcItemChooseLength(uint256[] memory tokenId,address user) internal view returns(uint256 length){
        for(uint256 index =0;index< tokenId.length;index++){
          uint8[] memory ways=_UTW[user][tokenId[index]];
          for(uint8 wayIndex=0;wayIndex<ways.length;wayIndex++){
              string[] memory chooseItem= _BWCVUM[tokenId[index]][ways[wayIndex]][user];
              length+=chooseItem.length;
          }
        }
        return length;
    }

    //计算单项中奖金额
    function calcBetAward(uint256 tokenId,uint8 way,string memory chooseItemValue,uint256 betMoney) internal view returns(uint256 award){
         uint256 chooseItemValueSum= _BWCM[tokenId][way][chooseItemValue];
         if(chooseItemValueSum<=0){
             return 0;
         }
         //中奖金额等于= （投注金额/获奖总金额）* 单场赛事玩法的除税总金额 中奖金额*(1-N%税收)
         return betMoney.div(chooseItemValueSum).mul(_BWTUM[tokenId][way]);
     }


    struct TokenOdds{
        uint256 tokenId;
        uint8 way;
        uint256 jackpot;
        string item;
        uint256 odds;
    }

    //获取每个奖池中选项的赔率和每个奖池的金额
    function queryLotteryOdds(TokenOdds[] memory odds) external view returns(TokenOdds[] memory _odds){
        _odds=new TokenOdds[](odds.length);
        for(uint index=0;index<odds.length;index++){
            TokenOdds memory item= odds[index];
            item.jackpot=_BWP[item.tokenId][item.way];
            uint256 itemSumMoney= _BWCM[item.tokenId][item.way][item.item];
            if(itemSumMoney>0){
                item.odds=item.jackpot.mul(100).div(itemSumMoney);
            }else{
                item.odds=item.jackpot.mul(100);
            }
            _odds[index]=item;
        }
    }

    //投注人员金额提取
    function userBetReceive(uint256 _tokenId,uint8 _way) external returns (bool){
        (uint256 _status)=_LotteryNFTToken.getTokenStatus(_tokenId);
        require(_status==3, "error: Lottery Not calculated!");
        string memory _itemValue= _LotteryNFTToken.getLotteryResultValue(_tokenId,_way);
        require(bytes(_itemValue).length>0&&!_itemValue.isEqual(""), "error: Lottery result Not calculated !");
        //获取我所有的下注
        string[] memory chooseItem= _BWCVUM[_tokenId][_way][_msgSender()];
        uint256 betAward=0;
        for(uint256 chooseIndex=0;chooseIndex<chooseItem.length;chooseIndex++){
            if(_itemValue.isEqual(chooseItem[chooseIndex])){
                uint256 betMoney= _BWCUM[_tokenId][_way][chooseItem[chooseIndex]][_msgSender()];
                betAward=calcBetAward(_tokenId,_way,chooseItem[chooseIndex],betMoney);
                break;
            }
        }
        uint256 balance=betAward.sub(_BWEM[_tokenId][_way][_msgSender()],"error:Fail to win a prize!");
        _BWEM[_tokenId][_way][_msgSender()]+=balance;
        _LotteryToken.transfer(_msgSender(),balance);
        return true;
    }

    //获取赛事玩法的投注总和和分红
    function queryLotteryWayBet(uint256 tokenId,uint8[] memory ways) external view returns(uint256[] memory wayBonus,uint256[] memory wayMoney,uint256[] memory receiveBonus){
        wayBonus=new uint256[](ways.length);
        wayMoney=new uint256[](ways.length);
        receiveBonus=new uint256[](ways.length);
        for(uint index=0;index<ways.length;index++){
            wayBonus[index]= _BP[tokenId][ways[index]];
            wayMoney[index]= _BWP[tokenId][ways[index]];
            receiveBonus[index]=_BPE[tokenId][ways[index]];
        }
        return (wayBonus,wayMoney,receiveBonus);
    }

    //NFT持有者返佣提取
    function bonusReceive(uint256 tokenId,uint8 way) external returns (bool){
        require(_LotteryNFTToken.ownerOf(tokenId)==_msgSender(), "ERC721Metadata: tokenId no power!");
        (uint256 _status)=_LotteryNFTToken.getTokenStatus(tokenId);
        require(_status==3, "error: Lottery Not calculated!");
        uint256 bonusBalance= _BP[tokenId][way].sub(_BPE[tokenId][way],"error: tokenId Belonging to yu!");
        _BPE[tokenId][way]+=bonusBalance;
        _LotteryToken.transfer(_msgSender(),bonusBalance);
        return true;
    }

    function gameTokenReceive() external returns (bool){
        require(gameTokenWithdrawalsWitch, "No Start!");
        uint256 bonus= _UM[_msgSender()].mul(gameRakeBackRatio).div(100);
        require(bonus>_UMRG[_msgSender()], "Receive Balance Is Zero!");
        uint256 bonusBalance=bonus.sub(_UMRG[_msgSender()]);
        _UMRG[_msgSender()]+=bonusBalance;
        _GameToken.transfer(_msgSender(),bonusBalance);
        return true;
    }
}