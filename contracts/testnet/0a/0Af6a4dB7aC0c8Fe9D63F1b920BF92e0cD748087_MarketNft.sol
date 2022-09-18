/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20{
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

abstract contract ERC721{
    function transferFrom(address from, address to, uint256 tokenId) external virtual;
}

abstract contract Panel{
    function isMember(address member) external virtual returns (bool flag);
    function isBlack(address member) external virtual returns (bool flag);
}

library Counters {
    struct Counter {uint256 _value;}
    function current(Counter storage counter) internal view returns (uint256) {return counter._value;}
    function increment(Counter storage counter) internal {unchecked {counter._value += 1;}}
    function decrement(Counter storage counter) internal {uint256 value = counter._value; require(value > 0, "Counter: decrement overflow"); unchecked {counter._value = value - 1;}}
    function reset(Counter storage counter) internal {counter._value = 0;}
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        if (b == a) {
            return 0;
        }
        require(b < a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
    function divFloat(uint256 a, uint256 b,uint decimals) internal pure returns (uint256){
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 c = aPlus/b;
        return c;
    }
    function backWei(uint256 a, uint decimals) internal pure returns (uint256){
        if (a == 0) {
            return 0;
        }
        uint256 amount = a / (10 ** uint256(decimals));
        return amount;
    }
}

contract Comn {
    address internal owner;
    bool _isRuning;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status = 1;
    modifier onlyOwner(){
        require(msg.sender == owner,"Modifier: The caller is not the creator");
        _;
    }
    modifier isRuning(){
        require(_isRuning,"Modifier: Closed");
        _;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    constructor(){
        owner = msg.sender;
        _status = _NOT_ENTERED;
        _isRuning = true;
    }
    function setIsRuning(bool _runing) public onlyOwner {
        _isRuning = _runing;
    }
    function outToken(address contractAddress,address fromAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ERC20(contractAddress).transferFrom(fromAddress,targetAddress,amountToWei);
    }
    function outNft(address contractAddress,address fromAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ERC721(contractAddress).transferFrom(fromAddress,targetAddress,amountToWei);
    }
    fallback () payable external {}
    receive () payable external {}
}

/** NFT交易市场 **/
contract MarketNft is Comn {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    mapping(address => mapping(uint256 => uint)) private nftSellPriceMap;      //NFT出售价格
    mapping(address => mapping(uint256 => uint)) private nftSellStatusMap;     //NFT出售状态 (1:正在出售中,2:已出售)
    mapping(uint256 => address) private nftOwnerMap;     //当前正在市场售卖的NFT所有人


    modifier isMember(){
        bool _isMember = Panel(panelContract).isMember(msg.sender);
        require(_isMember,"Modifier: Not a member");
        _;
    }

    modifier isBlack(){
        bool _isBlack = Panel(panelContract).isBlack(msg.sender);
        require(!_isBlack,"Modifier: No permission");
        _;
    }
    
    //出售NFT
    function sellNft(uint256 tokenId,uint256 amountToWei) external isRuning isMember isBlack nonReentrant{
        if(amountToWei == 0){ _status = _NOT_ENTERED; revert("NftMarket: Amount must be > 0"); }
        ERC721(nftContract).transferFrom(msg.sender,address (this),tokenId);
        //写入出售信息
        nftSellPriceMap[msg.sender][tokenId] = amountToWei;
        nftSellStatusMap[msg.sender][tokenId] = 1;
        nftOwnerMap[tokenId] = msg.sender;
    }
    
    //购买NFT
    function buyNft(uint256 tokenId) external isRuning isMember isBlack nonReentrant{
        if(nftOwnerMap[tokenId] == address(0)){ _status = _NOT_ENTERED; revert("NftMarket: NFT information error"); }
        if(nftSellStatusMap[nftOwnerMap[tokenId]][tokenId] != 1){ _status = _NOT_ENTERED; revert("NftMarket: NFT status error"); }
        if(nftSellPriceMap[nftOwnerMap[tokenId]][tokenId] == 0){ _status = _NOT_ENTERED; revert("NftMarket: NFT price error"); }
        
        uint256 totalAmountToWei = nftSellPriceMap[nftOwnerMap[tokenId]][tokenId];//总支付金额
        uint256 gasAmountToWei = totalAmountToWei.div(gasSaclePair[1]).mul(gasSaclePair[0]);
        uint256 sellerAmountToWei = totalAmountToWei.sub(gasAmountToWei);
        ERC20(nusContract).transferFrom(msg.sender, nftOwnerMap[tokenId], sellerAmountToWei);
        ERC20(nusContract).transferFrom(msg.sender, gasFocusAddr, gasAmountToWei);
        ERC721(nftContract).transferFrom(address (this),msg.sender,tokenId);
        //清除出售信息
        nftOwnerMap[tokenId] = address(0);
        nftSellStatusMap[nftOwnerMap[tokenId]][tokenId] = 0;
        nftSellPriceMap[nftOwnerMap[tokenId]][tokenId] = 0;
    }

    //赎回NFT
    function redeemNft(uint256 tokenId) external isRuning isMember isBlack nonReentrant{
        if(nftOwnerMap[tokenId] != msg.sender){ _status = _NOT_ENTERED; revert("NftMarket: NFT Attribution error"); }
        if(nftSellStatusMap[nftOwnerMap[tokenId]][tokenId] != 1){ _status = _NOT_ENTERED; revert("NftMarket: NFT status error"); }
        if(nftSellPriceMap[nftOwnerMap[tokenId]][tokenId] == 0){ _status = _NOT_ENTERED; revert("NftMarket: NFT price error"); }

        ERC721(nftContract).transferFrom(address (this),msg.sender,tokenId);
        //清除出售信息
        nftOwnerMap[tokenId] = address(0);
        nftSellStatusMap[nftOwnerMap[tokenId]][tokenId] = 0;
        nftSellPriceMap[nftOwnerMap[tokenId]][tokenId] = 0;
    }

    //修改NFT价格
    function priceNft(uint256 tokenId,uint256 amountToWei) external isRuning isMember isBlack nonReentrant{
        if(amountToWei == 0){ _status = _NOT_ENTERED; revert("NftMarket: Amount must be > 0"); }
        if(nftOwnerMap[tokenId] != msg.sender){ _status = _NOT_ENTERED; revert("NftMarket: NFT Attribution error"); }
        if(nftSellStatusMap[nftOwnerMap[tokenId]][tokenId] != 1){ _status = _NOT_ENTERED; revert("NftMarket: NFT status error"); }
        if(nftSellPriceMap[nftOwnerMap[tokenId]][tokenId] == 0){ _status = _NOT_ENTERED; revert("NftMarket: NFT price error"); }
        nftSellPriceMap[nftOwnerMap[tokenId]][tokenId] = amountToWei;
    }

    
    /*---------------------------------------------------管理运营-----------------------------------------------------------*/
    address private panelContract;                 //面板合约
    address private nusContract;                   //nus合约地址
    address private nftContract;                   //NFT合约

    uint[] private gasSaclePair;                   //交易手续费 [分子:gasSaclePair[0],分母:gasSaclePair[1]]
    address private gasFocusAddr;                  //交易手续费收款地址 


    /*
     * 初始配置
     * @param _panelContract 面板合约
     * @param _nusContract nus合约地址
     * @param _nftContract nft合约地址
     */
    function setConfig(address _panelContract,address _nusContract,address _nftContract) public onlyOwner {
        panelContract = _panelContract;
        nusContract = _nusContract;
        nftContract = _nftContract;
    }


    /*
     * 设置交易手续费率
     * @param _gasSacle 手续费率
     */
    function setGasSaclePair(uint[] memory _gasSaclePair) public onlyOwner {
        gasSaclePair = _gasSaclePair;
    }

    /*
     * 交易手续费收款地址 
     * @param _gasSacle 手续费率
     */
    function setGasFocusAddr(address _gasFocusAddr) public onlyOwner {
        gasFocusAddr = _gasFocusAddr;
    }

}