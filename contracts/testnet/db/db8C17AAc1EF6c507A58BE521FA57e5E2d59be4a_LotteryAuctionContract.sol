/**
 *Submitted for verification at BscScan.com on 2022-09-29
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

    function transferForeignNFTToken(address _token, address _to,uint256 value) public onlyOwner{
        IERC721(_token).transferFrom(address(this),_to, value);
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

    function mint(string memory _tokenURI, address _toAddress, uint _price) external returns (uint);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function ownerOf(uint256 tokenId) external view returns (address) ;

    function transferFrom(address from, address to, uint256 tokenId) external;
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


contract LotteryAuctionContract is Ownable{
    using SafeMath for uint256;
    mapping (address=>bool) tokenManager;

    //竞猜平台治理代币
    address public _LotteryTokenContract= 0x1486dC1ADF9121280A2024b198Cfc0409772C274;
    IERC20  _LotteryToken;

    //竞猜平台竞猜NFT
    address public _LotteryNFTTokenContract= 0xDA196d49864041F4434E16D29B3900BD18F85c8c;
    IERC721 _LotteryNFTToken;

    constructor(){
        _LotteryToken=IERC20(_LotteryTokenContract);
        _LotteryNFTToken=IERC721(_LotteryNFTTokenContract);
        tokenManager[_msgSender()]=true;
    }

    function setLotteryTokenContract(address token) external onlyOwner {
        _LotteryTokenContract=token;
        _LotteryToken=IERC20(_LotteryTokenContract);
    }

    function setLotteryNFTTokenContract(address token) external onlyOwner{
        _LotteryNFTTokenContract=token;
        _LotteryNFTToken=IERC721(_LotteryNFTTokenContract);
    }

    /////// 拍卖NFT竞猜 /////////
    struct NFTAuction {
        uint256 tokenId;
        uint256 basePrice;//起拍价
        uint256 increase;//每次最低加价额度
        //0=待开始，1=进行中，2=已结束
        uint8 status;
    }

    //key: 0全部  1、足球  2、篮球  3、电子竞技  9、其他
    //value: tokenId集合
    //key；tokenId  value:NFTAuction
    mapping (uint256 =>NFTAuction)  _NFTAuctionInfoMap;
    //key: tokenId  key2:use  value:price  用户参与竞拍的金额
    mapping (uint256 =>mapping(address=>uint256))  _NFTAuctionOfferMap;
    //key: tokenId  key2:use  value:price  用户赎回参与竞拍的金额
    mapping (uint256 =>mapping(address=>uint256))  _NFTAuctionRedeemMoneyMap;
    //key: tokenId  key2:use  Nft被谁赎回
    mapping (uint256 =>address)  _NFTAuctionRedeemMap;
    //key: tokenId  value:maxPrice tokenId当前的最高出价
    mapping (uint256 =>uint256)  _NFTAuctionMaxPriceMap;

    function addAuction(uint256[] memory tokenId,uint256[] memory basePrice,uint256[] memory increase,uint8 status) external onlyOwner returns(bool){
        require(tokenId.length>0, "ERC721Metadata: tokenId is non!");
        for(uint i=0;i<tokenId.length;i++){
            NFTAuction memory auction = _NFTAuctionInfoMap[tokenId[i]];
            if(auction.tokenId==tokenId[i]){
                continue;
            }
            NFTAuction memory auctionValue=NFTAuction(tokenId[i],basePrice[i],increase[i],status);
            _NFTAuctionInfoMap[tokenId[i]]=auctionValue;
        }
        return true;
    }

    function queryAuctionByToken(uint256[] memory _tokenId,address userAddress) external view returns(uint256[] memory tokenId,uint256[] memory basePrice,uint256[] memory increase,uint256[] memory maxPrice,uint8[] memory status,uint256[] memory uPrice){
        require(_tokenId.length>0, "ERC721Metadata: tokenId is non!");
        uint256 count=_tokenId.length;
        tokenId=new uint256[](count);
        basePrice=new uint256[](count);
        increase=new uint256[](count);
        maxPrice=new uint256[](count);
        status=new uint8[](count);
        uPrice=new uint256[](count);
        for(uint i=0;i<count;i++){
            NFTAuction memory auction = _NFTAuctionInfoMap[_tokenId[i]];
            tokenId[i]=auction.tokenId;
            basePrice[i]=auction.basePrice;
            increase[i]=auction.increase;
            maxPrice[i]=_NFTAuctionMaxPriceMap[auction.tokenId];
            status[i]=auction.status;
            uPrice[i]=_NFTAuctionOfferMap[_tokenId[i]][userAddress];
        }
    }
    //修改拍卖数据
    function changeAuction(uint256 tokenId,uint256 basePrice,uint256 increase) external onlyOwner {
        require(tokenId>0, "ERC721Metadata: tokenId is non!");
        NFTAuction storage auction = _NFTAuctionInfoMap[tokenId];
        if(auction.tokenId!=tokenId){
            return;
        }
        auction.increase=increase;
        auction.basePrice=basePrice;
    }
    //设置比赛状态
    function setAuctionStatus(uint256 tokenId,uint8 status) external {
        require(tokenId>0, "error: tokenId is non!");
        require(tokenManager[_msgSender()],"No Permission");
        NFTAuction storage auction = _NFTAuctionInfoMap[tokenId];
        if(auction.tokenId!=tokenId){
            return;
        }
        auction.status=status;
    }
    //参与竞拍
    function betAuction(uint256 tokenId,uint256 price) external returns(bool){
        require(tokenId>0, "error: tokenId is non!");
        NFTAuction memory auction = _NFTAuctionInfoMap[tokenId];
        require(auction.tokenId==tokenId, "error: tokenId non-existent!");
        require(auction.basePrice<=price, "error: Your bid is less than the lowest bid!");
        require(auction.status==1, "error: Auction status error!");
        uint256 uPrice=price.add(_NFTAuctionOfferMap[tokenId][_msgSender()]);
        require(uPrice>_NFTAuctionMaxPriceMap[tokenId].add(auction.increase), "error: Your bid is not the highest bid!");
        _NFTAuctionOfferMap[tokenId][_msgSender()]=uPrice;
        _NFTAuctionMaxPriceMap[tokenId]=uPrice;
        _LotteryToken.transferFrom(_msgSender(),address(this),price);
        return true;
    }
    //赎回金额or NFT
    function redeemAuction(uint256 tokenId) external  returns(bool){
        require(tokenId>0, "error: tokenId is non!");
        require(_NFTAuctionOfferMap[tokenId][_msgSender()]>=(_NFTAuctionRedeemMoneyMap[tokenId][_msgSender()]), "error: No bid!");
        require(_NFTAuctionRedeemMap[tokenId]!=_msgSender(), "error: Received!");
        NFTAuction memory auction = _NFTAuctionInfoMap[tokenId];
        require(auction.tokenId==tokenId, "error: tokenId non-existent!");
        require(auction.status==2, "error: Auction has ended!");
        if(_NFTAuctionOfferMap[tokenId][_msgSender()]==_NFTAuctionMaxPriceMap[tokenId]&&_NFTAuctionRedeemMap[tokenId]==address(0)){
            _NFTAuctionRedeemMap[tokenId]=_msgSender();
            _LotteryNFTToken.transferFrom(address(this),_msgSender(),tokenId);
        }else{
            uint256 money=_NFTAuctionOfferMap[tokenId][_msgSender()].sub(_NFTAuctionRedeemMoneyMap[tokenId][_msgSender()]);
            _NFTAuctionRedeemMoneyMap[tokenId][_msgSender()]=_NFTAuctionOfferMap[tokenId][_msgSender()];
            _LotteryToken.transfer(_msgSender(),money);
        }
        return true;
    }
    //设置管理员
    function setManager(address manager,bool status) public onlyOwner{
        tokenManager[manager]=status;
    }
}