/**
 *Submitted for verification at BscScan.com on 2022-09-25
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

    //竞猜平台治理代币
    address _QZTokenContract= 0x1486dC1ADF9121280A2024b198Cfc0409772C274;
    IERC20  _QZToken;

    //竞猜平台竞猜NFT
    address _QZNFTTokenContract= 0xDA196d49864041F4434E16D29B3900BD18F85c8c;
    IERC721 _QZNFTToken;

    //复合竞猜奖池
    address poolAddress= 0x60c094F7b72D6Bb51C3a377f82614F33D02CEBFE;
    uint256 poolFee=0;

    //平台税收
    address platformAddress= 0xd0eC69B5a776baf8022DFE747DcaB0eeE904fF74;
    uint256 platformFee=1;

    //游戏LP池子
    address gameLpAddress= 0x88B133054B35889b1Db7F5237279d6E492606b54;
    //加游戏LP比例
    uint256 gameLpFee=2;

    //回购地址
    address buyBackAddress= 0x330e1a59445E2A508E301aCCA989EbFe64feDf67;
    //回购比例
    uint256 buyBackFee=1;

    //Nft Kol持有者获取比例
    uint256 nftKolFee=10;

    //返佣比例
    uint256 inviteAwardFee=6;

    //////NFT竞猜//////
    constructor(){
        _QZToken=IERC20(_QZToken);
        _QZNFTToken=IERC721(_QZNFTTokenContract);
    }

    //奖池剩余比例
    function prizePool()private view returns(uint256){
        uint256 prizePoolValue=100;
        return prizePoolValue.sub(nftKolFee).sub(inviteAwardFee).sub(platformFee).sub(buyBackFee).sub(gameLpFee);
    }

    function setQZTokenContract(address token) external onlyOwner {
        _QZTokenContract=token;
        _QZToken=IERC20(_QZTokenContract);
    }

    function setQZNFTTokenContract(address token) external onlyOwner{
        _QZNFTTokenContract=token;
        _QZNFTToken=IERC721(_QZNFTTokenContract);
    }

    function setInviteAwardFee(uint256 _inviteAwardFee) external onlyOwner{
        inviteAwardFee=_inviteAwardFee;
    }

    function setBuyBackFee(uint256 _buyBackFee) external onlyOwner{
        buyBackFee=_buyBackFee;
    }

    function setGameLpFee(uint256 _gameLpFee) external onlyOwner{
        gameLpFee=_gameLpFee;
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
    mapping (uint256 =>mapping(uint8=>uint256))  _NFTBetWayMap;
    //key: tokenId  key2:ways key3=choose value:price  每场比赛每个玩法每个选项的投注总金额
    mapping (uint256 =>mapping(uint8=>mapping(string=>uint256)))  _NFTBetWayChooseMap;
    //key: tokenId  key2:use  value:price  每场比赛每个用户的投注总金额
    mapping (uint256 =>mapping(address=>uint256))  _NFTBetUseOfferMap;
    //key: tokenId  key2:ways key3=choose  key4:use value:price  每场比赛每个玩法每个选项的每个用户的投注总金额
    mapping (uint256 =>mapping(uint8=>mapping(string=>mapping(address=>uint256))))  _NFTBetWayChooseUseMap;
    //key: tokenId  key2:ways key3:use value:[]  每场比赛每个玩法每个用户的投注选项汇总
    mapping (uint256 =>mapping(uint8=>mapping(address=>string[])))  _NFTBetWayChooseValueUseMap;
    //key: user  value:tokenId  用户参与的投注NftToken集合
    mapping (address=>uint256[]) _NFTUseBetTokenMap;
    //key: orderId   value:order  bet订单明细
    mapping (uint256=>NFTBet) _NFTBetOrderMap;
    //订单Id
    Counters.Counter public _BetOrderId;

    //邀请人的地址 key是用户  value是被谁邀请的
    mapping(address=>address) _inviteAddress;
    //邀请人返利总金额
    mapping(address=>uint256) _inviteReturn;
    //邀请人提取金额
    mapping(address=>uint256) _inviteReturnExtract;
    //邀请人的返佣列表
    mapping(address=>InviteReturn[]) _inviteListMap;
    struct InviteReturn {
        address use;//投注人
        uint256 money;//投注金额
        uint256 inviteReturn;//返佣金额
        uint256 tmSmp;//时间
    }

    //Kol返利金额
    // key1=tokenId key=way value=金额
    mapping(uint256=>mapping(uint8=>uint256)) _Bonus;
    //Kol返利金额 已提取金额
    // key1=tokenId key=way value=金额
    mapping(uint256=>mapping(uint8=>uint256)) _BonusExtract;
    //key: tokenId  key2:ways  value:price  每场比赛每个玩法的归属用户的代币金额  考虑税率的变动 因此将金额单独存储
    mapping (uint256 =>mapping(uint8=>uint256))  _NFTBetWayToUserMap;
    //key: tokenId  key2:ways key3:user value:price  每场比赛每个玩法用户领取的金额
    mapping (uint256 =>mapping(uint8=>mapping(address=>uint256)))  _NFTBetWayExtractMap;
    //////////////////////////下注接口//////////////////////////

    //下注接口
    function betOrder(uint256[] memory _tokenId,uint8[] memory ways,string[] memory wayValue,uint256[] memory betMoney,address inviteAddress)external returns(bool){
        require(_tokenId.length==ways.length&&ways.length==wayValue.length&&wayValue.length==betMoney.length, "error: parameter is error!");
        uint sumMoney=0;
        for(uint index=0;index<_tokenId.length;index++){
            _BetOrderId.increment();
            //只有已经创建的比赛可以投注
            if(_QZNFTToken.getTokenStatus(_tokenId[index])==1){
                continue;
            }
            require(betMoney[index]>0, "error: bet money is non!");
            NFTBet memory betInfo=NFTBet(_BetOrderId._value,_tokenId[index],ways[index],wayValue[index],betMoney[index],_msgSender());
            _NFTBetOrderMap[betInfo.orderId]=betInfo;
            _NFTBetWayMap[_tokenId[index]][ways[index]]+=betMoney[index];
            _NFTBetWayChooseMap[_tokenId[index]][ways[index]][wayValue[index]]+=betMoney[index];
            if(_NFTBetWayChooseUseMap[_tokenId[index]][ways[index]][wayValue[index]][_msgSender()]<=0){
              _NFTBetWayChooseValueUseMap[_tokenId[index]][ways[index]][_msgSender()].push(wayValue[index]);
            }
            _NFTBetWayChooseUseMap[_tokenId[index]][ways[index]][wayValue[index]][_msgSender()]+=betMoney[index];

            if(_NFTBetUseOfferMap[_tokenId[index]][_msgSender()]<=0){
                _NFTUseBetTokenMap[_msgSender()].push(betInfo.tokenId);
            }
            _NFTBetUseOfferMap[_tokenId[index]][_msgSender()]+=betMoney[index];
            bonusPay(_tokenId[index],ways[index],betMoney[index]);
            sumMoney+=betMoney[index];
        }
        if(_inviteAddress[_msgSender()]!=address(0)){
            if(inviteAddress==address(0)){
               _inviteAddress[_msgSender()]=poolAddress;
            }else{
                _inviteAddress[_msgSender()]=inviteAddress;
            }
        }
        betPay(sumMoney);
        return true;
    }

    //支付分配
    function betPay(uint256 sumMoney) internal{
        transferToAddress(poolAddress,sumMoney.mul(poolFee).div(100));
        transferToAddress(platformAddress,sumMoney.mul(platformFee).div(100));
        transferToAddress(gameLpAddress,sumMoney.mul(gameLpFee).div(100));
        transferToAddress(buyBackAddress,sumMoney.mul(buyBackFee).div(100));
        uint256 inviteAwardValue=sumMoney.mul(inviteAwardFee).div(100);
        if(inviteAwardValue>0){
            _inviteReturn[_inviteAddress[_msgSender()]]+=inviteAwardValue;
            InviteReturn memory ir=InviteReturn(_msgSender(),sumMoney,inviteAwardValue,block.timestamp);
            _inviteListMap[_inviteAddress[_msgSender()]].push(ir);
        }
    }
    //转账
    function transferToAddress(address recipient, uint256 amount) private {
        if(amount<=0){
            return;
        }
        _QZToken.transferFrom(_msgSender(),recipient,amount);
    }
    //返佣KOL分配 记录
    function bonusPay(uint256 tokenId,uint8 way,uint256 sumMoney) internal{
        _Bonus[tokenId][way]+=sumMoney.mul(nftKolFee).div(100);
        _NFTBetWayToUserMap[tokenId][way]+=sumMoney.mul(prizePool()).div(100);
    }

    //////////////////////////我的邀请列表//////////////////////////

    //我的邀请列表 及 可提取返佣金额 和 已提取返佣金额
    function queryInviteList(uint256 _lastIndex,uint256 _limit) external view returns(address[] memory use,uint256[] memory sumMoney,uint256[] memory returnMoney,uint256 lastIndex,uint256 inviteReceiveValue,uint256 completeInviteReceive){
        InviteReturn[] memory ir=_inviteListMap[_msgSender()];
        if(ir.length<=0){
            return (use,sumMoney,returnMoney,0,_inviteReturn[_msgSender()],_inviteReturnExtract[_msgSender()]);
        }
        if(_lastIndex==0){
            _lastIndex=ir.length-1;
        }
        if(_lastIndex<_limit){
            _limit=_lastIndex+1;
        }
        use=new address[](_limit);
        returnMoney=new uint256[](_limit);
        sumMoney=new uint256[](_limit);
        uint256 valueIndex=0;
        for(uint256 index=_lastIndex;index>=0;index--){
            lastIndex=index;
            if(valueIndex<=_limit){
                break;
            }
            InviteReturn memory irValue=ir[index];
            use[valueIndex]=irValue.use;
            returnMoney[valueIndex]=irValue.inviteReturn;
            sumMoney[valueIndex]=irValue.money;
            valueIndex++;
        }
        return (use,sumMoney,returnMoney,lastIndex,_inviteReturn[_msgSender()],_inviteReturnExtract[_msgSender()]);
    }

    //提取邀请返佣金额
    function inviteReceive() external{
        uint256 maxReceive=_inviteReturn[_msgSender()].sub(_inviteReturnExtract[_msgSender()]);
        require(maxReceive>0, "error: your credit is running low!");
        _inviteReturnExtract[_msgSender()]+=maxReceive;
        _QZToken.transferFrom(address(this),_msgSender(),maxReceive);
    }


    //////////////////////////我参加的竞猜列表//////////////////////////
    // tokenInfo[][index 0 = tokenId index 1=url,2=model,3=startTime,4=endTime,5=status]
    // _tokenId[tokenIndex] 和 ways[tokenIndex][way数量：1，2，4等] 相对应
    // ways[tokenIndex][way数量] 和 itemChooseSet[（tokenIndex*way数量）+way的索引][itemValue]
    // 比方:
    // tokenId=[1001,1002,1003]
    // ways=[0][1,2];  way 1 的choose=[A,B,C]  way 2 的choose=[A,B]
    //      [1][4];    way 4 的choose=[C]
    //      [2][2];    way 2 的choose=[B]
    // itemChooseSet[0]=[A,B,C]  itemChooseSet[1]=[A,B]  itemChooseSet[2]=[C]  itemChooseSet[3]=[B]
    // tokenId和ways的顺序是强一致的
    // itemChoose 和 itemChooseOdds的逻辑完全一致 每个选项的赔率
    // lotteryStatus 0 全部 1进行中 2已结束
    function queryMyLotteryList(uint256 lastIndex,uint256 limit,address user) external view returns(uint256[] memory _tokenId,uint8[][] memory _ways,string[][] memory _betValue,uint256[][] memory _betValueMoney,uint256[][] memory _betAward,uint256 _lastIndex){
        (_tokenId,_lastIndex) = calcLotteryTokenId(lastIndex,limit,user);
        (,_ways,_betValue,_betValueMoney,_betAward)=queryLotteryItemChoose(_tokenId);
        return (_tokenId,_ways,_betValue,_betValueMoney,_betAward,_lastIndex);
    }

    //获取我参加的竞猜TokenId集合
    function calcLotteryTokenId(uint256 lastIndex,uint256 limit,address user) internal view returns(uint256[] memory _tokenId,uint256 _lastIndex){
        if(_NFTUseBetTokenMap[user].length<=0){
            return (_tokenId,_lastIndex);
        }
        if(lastIndex==0){
            lastIndex=_NFTUseBetTokenMap[user].length-1;
        }
        if(lastIndex<=0){
            return (_tokenId,_lastIndex);
        }
        if(lastIndex<limit){
            limit=lastIndex;
        }
        _tokenId = new uint256[](limit);
        uint256 pageIndex=0;
        for(uint index=lastIndex;index>=0;lastIndex--){
            if(pageIndex>=limit){
                _lastIndex=index;
                break;
            }
            _tokenId[pageIndex++]=_NFTUseBetTokenMap[user][index];
        }
        return (_tokenId,_lastIndex);
    }

    //获取我的所有投注项
    function queryLotteryItemChoose(uint256[] memory tokenId)private view returns(uint256[] memory _tokenId,uint8[][] memory _ways,string[][] memory betValue,uint256[][] memory betValueMoney,uint256[][] memory betAward){
        string[][] memory _itemValue;
        (_ways,_itemValue) = _QZNFTToken.getLotteryResultListByTokenId(tokenId);
        // token的玩法索引累计
        // 第一个token有两个的玩法 1，2  第二个token有1个的玩法 1   第三个个token有3个的玩法  1,2,4
        // betResult[0][]=第一个token的第1个玩法的投注结果集合
        // betResult[1][]=第一个token的第2个玩法的投注结果集合
        // betResult[2][]=第二个token的第1个玩法的投注结果集合
        // betResult[3][]=第三个token的第1个玩法的投注结果集合
        // betResult[4][]=第三个token的第2个玩法的投注结果集合
        // betResult[5][]=第三个token的第3个玩法的投注结果集合
        uint256 calcLengthValue = calcItemChooseLength(_tokenId,_ways);
        betValue=new string[][](calcLengthValue);
        // token的玩法索引累计
        // 第一个token有两个的玩法 1，2  第二个token有1个的玩法 1   第三个个token有3个的玩法  1,2,4
        // betValueMoney[0][]=第一个token的第1个玩法的投注集合  索引和betResult相对应
        // betValueMoney[1][]=第一个token的第2个玩法的投注集合  索引和betResult相对应
        // betValueMoney[2][]=第二个token的第1个玩法的投注集合  索引和betResult相对应
        // betValueMoney[3][]=第三个token的第1个玩法的投注集合  索引和betResult相对应
        // betValueMoney[4][]=第三个token的第2个玩法的投注集合  索引和betResult相对应
        // betValueMoney[5][]=第三个token的第3个玩法的投注集合  索引和betResult相对应
        betValueMoney=new uint256[][](calcLengthValue);
        // token的玩法索引累计
        // 第一个token有两个的玩法 1，2  第二个token有1个的玩法 1   第三个个token有3个的玩法  1,2,4
        // betAward[0][0]=第一个token的第1个玩法的可领奖结果
        // betAward[1][0]=第一个token的第2个玩法的可领奖结果
        // betAward[2][0]=第二个token的第1个玩法的可领奖结果
        // betAward[3][0]=第三个token的第1个玩法的可领奖结果
        // betAward[4][0]=第三个token的第2个玩法的可领奖结果
        // betAward[5][0]=第三个token的第3个玩法的可领奖结果
        betAward=new uint256[][](calcLengthValue);
        uint256 itemIndex=0;
        for(uint256 index =0;index< _tokenId.length;index++){
            for(uint256 wayIndex=0;wayIndex<_ways[index].length;wayIndex++){
                itemIndex++;
                //获取所有的下注
                string[] memory chooseItem= _NFTBetWayChooseValueUseMap[_tokenId[index]][_ways[index][wayIndex]][_msgSender()];
                if(chooseItem.length<=0){
                  continue;
                }
                betValue[itemIndex]=chooseItem;
                betValueMoney[itemIndex]=new uint256[](chooseItem.length);
                betAward[itemIndex]=new uint256[](1);
                for(uint256 chooseIndex=0;chooseIndex<=chooseItem.length;chooseIndex++){
                    uint256 betMoney=_NFTBetWayChooseUseMap[_tokenId[index]][_ways[index][wayIndex]][chooseItem[chooseIndex]][_msgSender()];
                    betValue[itemIndex][chooseIndex]=chooseItem[chooseIndex];
                    betValueMoney[itemIndex][chooseIndex]=betMoney;
                    if(_itemValue[index][wayIndex].isEqual(chooseItem[chooseIndex])){
                        betAward[itemIndex][0]+=calcBetAward(_tokenId[index],_ways[index][wayIndex],chooseItem[chooseIndex],betMoney);
                    }
                }
            }
        }
        return(_tokenId,_ways,betValue,betValueMoney,betAward);
    }

    //计算可选项的总长度
    function calcItemChooseLength(uint256[] memory tokenId,uint8[][] memory ways) internal pure returns(uint256 length){
        for(uint256 index =0;index< tokenId.length;index++){
          for(uint256 wayIndex=0;wayIndex<ways[index].length;wayIndex++){
            length++;
          }
        }
        return length;
    }

    //计算单项中奖金额
    function calcBetAward(uint256 tokenId,uint8 way,string memory chooseItemValue,uint256 betMoney) internal view returns(uint256 award){
         uint256 chooseItemValueSum=_NFTBetWayChooseMap[tokenId][way][chooseItemValue];
         if(chooseItemValueSum<=0){
             return 0;
         }
         //中奖金额等于= （投注金额/获奖总金额）* 单场赛事玩法的除税总金额 中奖金额*(1-N%税收)
         return betMoney.div(chooseItemValueSum).mul(_NFTBetWayToUserMap[tokenId][way]);
     }

    //获取每个奖池中选项的赔率和每个奖池的金额
    function queryLotteryOdds(uint256[] memory tokenId,uint8[][] memory ways,string[][] memory itemChooseSet) external view returns(uint256[][] memory itemChooseSetOdds,uint256[][] memory jackpot){
        itemChooseSetOdds=new uint256[][](itemChooseSet.length);
        jackpot=new uint256[][](tokenId.length);
        for(uint256 index=0;index<=tokenId.length;index++){
            itemChooseSetOdds[index]=new uint256[](ways[index].length);
            jackpot[index]=new uint256[](ways[index].length);
            for(uint256 wayIndex=0;wayIndex<=ways[index].length;wayIndex++){
                //总金额
                jackpot[index][wayIndex]=_NFTBetWayMap[tokenId[index]][ways[index][wayIndex]];
                if(jackpot[index][wayIndex]<=0){
                    itemChooseSetOdds[index][wayIndex]=0;
                    continue;
                }
                //选项金额
                uint256 itemSumMoney=_NFTBetWayChooseMap[tokenId[index]][ways[index][wayIndex]][itemChooseSet[index][wayIndex]];
                if(itemSumMoney<=0){
                    itemChooseSetOdds[index][wayIndex]=jackpot[index][wayIndex];
                    continue;
                }
                itemChooseSetOdds[index][wayIndex]=jackpot[index][wayIndex].div(itemSumMoney);
            }
        }
    }

    //投注人员金额提取
    function userBetReceive(uint256 _tokenId,uint8 _way) external returns (bool){
        (uint256 _status)=_QZNFTToken.getTokenStatus(_tokenId);
        require(_status==3, "error: Lottery Not calculated!");
        string memory _itemValue= _QZNFTToken.getLotteryResultValue(_tokenId,_way);
        require(!_itemValue.isEqual(""), "error: Lottery result Not calculated !");
        //获取我所有的下注
        string[] memory chooseItem= _NFTBetWayChooseValueUseMap[_tokenId][_way][_msgSender()];
        uint256 betAward=0;
        for(uint256 chooseIndex=0;chooseIndex<=chooseItem.length;chooseIndex++){
            if(_itemValue.isEqual(chooseItem[chooseIndex])){
                uint256 betMoney=_NFTBetWayChooseUseMap[_tokenId][_way][chooseItem[chooseIndex]][_msgSender()];
                betAward=calcBetAward(_tokenId,_way,chooseItem[chooseIndex],betMoney);
                break;
            }
        }
        uint256 balance=betAward.sub(_NFTBetWayExtractMap[_tokenId][_way][_msgSender()]);
        require(balance>0, "error:Fail to win a prize!");
        _NFTBetWayExtractMap[_tokenId][_way][_msgSender()]+=balance;
        _QZToken.transfer(_msgSender(),balance);
        return true;
    }

    //获取赛事玩法的投注总和和分红
    function queryLotteryWayBet(uint256 tokenId,uint8[] memory ways) external view returns(uint256[] memory wayBonus,uint256[] memory wayMoney){
        wayBonus=new uint256[](ways.length);
        wayMoney=new uint256[](ways.length);
        for(uint index=0;index<ways.length;index++){
            wayBonus[index]= _Bonus[tokenId][ways[index]];
            wayMoney[index]= _NFTBetWayMap[tokenId][ways[index]];
        }
        return (wayBonus,wayMoney);
    }

    //NFT持有者返佣提取
    function bonusReceive(uint256 tokenId,uint8 way) external returns (bool){
        require(_QZNFTToken.ownerOf(tokenId)==_msgSender(), "ERC721Metadata: tokenId no power!");
        (uint256 _status)=_QZNFTToken.getTokenStatus(tokenId);
        require(_status==3, "error: Lottery Not calculated!");
        uint256 bonusBalance=_Bonus[tokenId][way].sub(_BonusExtract[tokenId][way]);
        require(bonusBalance>0, "error: tokenId Belonging to yu!");
        _BonusExtract[tokenId][way]+=bonusBalance;
        _QZToken.transfer(_msgSender(),bonusBalance);
        return true;
    }
}