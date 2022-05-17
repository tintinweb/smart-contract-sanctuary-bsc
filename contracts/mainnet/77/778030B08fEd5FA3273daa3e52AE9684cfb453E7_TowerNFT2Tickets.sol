/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
        return c;
    }
}

interface IERC721 {
    function safeTransferFrom(address from_, address to_, uint256 tokenId_) external;
    function getHashrateByTokenId(uint256 tokenId_) external view returns(uint256);
    function feedFBXOnlyPrice() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function getDegreeByTokenId(uint256 tokenId) external view returns(uint256);
    function burnNFT(uint256 tokenId) external returns (uint256);
}


contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}
interface IERC721Receiver {
    function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data) view external returns (bytes4);
}
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
interface IForthBoxNFT {
     function getUsdtFBXPrice() external view returns (uint256);
}
interface ITowerNFT2Tickets {
    function bHaveTicket(address account) external view returns(bool);
}

contract TowerNFT2Tickets is Ownable, ReentrancyGuard,IERC721Receiver {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    string private _name = "TowerNFT2Tickets";
    string private _symbol = "TowerNFT2Tickets";

    IERC721 public ERC721Token;
    struct sSellPropertys {
        uint256 id;
        address addr;
        uint256 SellAmount;
        uint256 time;
    }
    mapping (address => bool) private _bHaveTicket;

    mapping(uint256 => sSellPropertys) private _SellPropertys;
    mapping(address => uint256[]) private _SellIds;
    uint256 private _sumCount;
    
    mapping (address => uint256) private _balances;
    uint256 private _totalSupply;

    mapping (address => bool) private _Is_WhiteContractArr;
    address[] private _WhiteContractArr;
    bool private _bStart = false;
    event SellTokens(address indexed user, uint256 amount,uint256 id);

    IERC20 public FBXToken;
    address public FundAdress;

    IForthBoxNFT public hamNFTToken;
    uint256 public totlaUpdataFBX=0;

    ITowerNFT2Tickets public TowerNFT2TicketToken;

    constructor(){
        FundAdress = 0x75dCC20b49429ACF978e577eE5D0BEB1A79DB559;
        hamNFTToken = IForthBoxNFT(0x1F599A0281d024bfeF7e198bDae78B49A6e87049);

        FBXToken = IERC20(0xFD57aC98aA8E445C99bc2C41B23997573fAdf795);
        ERC721Token = IERC721(0x52C2b76C30fB7D1581DdCfa20e07d1ae789FF912);

        TowerNFT2TicketToken = ITowerNFT2Tickets(0x3cfC8E06Ab5d819Cd5d5f63c12ABA97197EE7f8f);
    }
    
    /* ========== VIEWS ========== */
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
   function balanceOf(address account) external view  returns (uint256) {
        return _balances[account];
    }
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function bHaveTicket(address account) external view returns(bool){
        return _bHaveTicket[account];
    }
    function sumCount() external view returns(uint256){
        return _sumCount;
    }
    function onERC721Received(address,address,uint256,bytes memory) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    //read info
    function SellInfo(uint256 iD) external view returns (
        uint256 id,
        address addr,
        uint256 sellAmount,
        uint256 time
        ) {
        require(iD <= _sumCount, "ForthBoxSellToken: exist num!");
        id = _SellPropertys[iD].id;
        addr = _SellPropertys[iD].addr;
        sellAmount = _SellPropertys[iD].SellAmount;
        time = _SellPropertys[iD].time;
        return (id,addr,sellAmount,time);
    }
    function SellNum(address addr) external view returns (uint256) {
        return _SellIds[addr].length;
    }
    function SellIthId(address addr,uint256 ith) external view returns (uint256) {
        require(ith < _SellIds[addr].length, "ForthBoxSellToken: not exist!");
        return _SellIds[addr][ith];
    }

    function SellInfos(uint256 fromId,uint256 toId) external view returns (
        uint256[] memory idArr,
        address[] memory addrArr,
        uint256[] memory SellAmountArr,
        uint256[] memory timeArr
        ) {
        require(toId <= _sumCount, "ForthBoxSellToken: exist num!");
        require(fromId <= toId, "ForthBoxSellToken: exist num!");
        idArr = new uint256[](toId-fromId+1);
        addrArr = new address[](toId-fromId+1);
        SellAmountArr = new uint256[](toId-fromId+1);
        timeArr = new uint256[](toId-fromId+1);
        uint256 i=0;
        for(uint256 ith=fromId; ith<=toId; ith++) {
            idArr[i] = _SellPropertys[ith].id;
            addrArr[i] = _SellPropertys[ith].addr;
            SellAmountArr[i] = _SellPropertys[ith].SellAmount;
            timeArr[i] = _SellPropertys[ith].time;
            i = i+1;
        }
        return (idArr,addrArr,SellAmountArr,timeArr);
    }
    
    function isWhiteContract(address account) public view returns (bool) {
        if(!account.isContract()) return true;
        return _Is_WhiteContractArr[account];
    }
    function getWhiteAccountNum() public view returns (uint256){
        return _WhiteContractArr.length;
    }
    function getWhiteAccountIth(uint256 ith) public view returns (address WhiteAddress){
        require(ith <_WhiteContractArr.length, "ForthBoxSellToken: not in White Adress");
        return _WhiteContractArr[ith];
    }
    //---write---//
    function SellToken(uint256[] calldata tokenIds,uint256 time) external nonReentrant{
        require(_bStart, "ForthBoxSellToken:not start!");
        require(tokenIds.length==6, "ForthBoxSellToken:length not 6!");
        require(isWhiteContract(_msgSender()), "ForthBoxSellToken: Contract not in white list!");
        require(TowerNFT2TicketToken.bHaveTicket(_msgSender()), "ForthBoxSellToken:need have ticket!");

        uint256[] memory bIdOk = new uint256[](uint256(7));

        for(uint256 i=0; i<tokenIds.length; i++){
            uint256 degree = ERC721Token.getDegreeByTokenId(tokenIds[i]);
            bIdOk[degree]=1;
        }
        for(uint256 i=0; i<tokenIds.length; i++){
            require( bIdOk[i+1]==1, "ForthBoxSellToken:tokens not right!");
        }

        for(uint256 i=0; i<tokenIds.length; i++){
            ERC721Token.safeTransferFrom(_msgSender(),address(this),tokenIds[i]);
            ERC721Token.burnNFT(tokenIds[i]);
        }
        updataFBX();

        _sumCount = _sumCount.add(1);
        _SellIds[_msgSender()].push(_sumCount);

        _SellPropertys[_sumCount].id = _sumCount;
        _SellPropertys[_sumCount].addr = _msgSender();
        _SellPropertys[_sumCount].SellAmount = 6;
        _SellPropertys[_sumCount].time = time;

        _balances[msg.sender] = _balances[msg.sender].add(6);
        _totalSupply = _totalSupply.add(6);

        _bHaveTicket[_msgSender()] = true;

        emit SellTokens(msg.sender, 6, _sumCount);
    }

    function getFBXFeedingProportion(uint256 price) public pure returns (uint256 ) {
            uint256 feedingProportion=2500*10**18;
            if(price<=15*10**15) {
            feedingProportion = 2500*10**18;
            return feedingProportion;
            }
            if(price<=30*10**15){
            feedingProportion = 5000*10**18;
            return feedingProportion;
            }
            if(price<=60*10**15){
            feedingProportion = 10000*10**18;
            return feedingProportion;
            }
            if(price<=80*10**15){
            feedingProportion = 10000*10**18;
            return feedingProportion;
            }
            if(price<=1*10**17){
            feedingProportion = 10000*10**18;
            return feedingProportion;
            }
            if(price<=3*10**17){
            feedingProportion = 8000*10**18;
            return feedingProportion;
            }
            if(price<=5*10**17){
            feedingProportion = 6000*10**18;
            return feedingProportion;
            }
            if(price<=9*10**17){
            feedingProportion =  4000*10**18;
            return feedingProportion;
            }
            feedingProportion = 2500*10**18;
            return feedingProportion;           
    }
    function getFBXCost() public view returns (uint256 ) {
        uint256 tUsdt2FBX = hamNFTToken.getUsdtFBXPrice();
        uint256 feedingPrice =  getFBXFeedingProportion(tUsdt2FBX);
        return feedingPrice;           
    }
    function updataFBX() internal{
        uint256 feedingPrice = getFBXCost();
        FBXToken.safeTransferFrom(_msgSender(), FundAdress, feedingPrice.mul(10).div(100));
        FBXToken.safeTransferFrom(_msgSender(), address(0), feedingPrice.mul(90).div(100));

        totlaUpdataFBX=totlaUpdataFBX.add(feedingPrice);
        return ;
    }
    //---write onlyOwner---//
    function setStart(bool bStart) external onlyOwner{
        _bStart = bStart;
    }
    function setTokens(address tFBoxToken) external onlyOwner{
       ERC721Token = IERC721(tFBoxToken);
    }
    function addWhiteAccount(address account) external onlyOwner{
        require(!_Is_WhiteContractArr[account], "ForthBoxSellToken:Account is already White list");
        require(account.isContract(), "ForthBoxSellToken: not Contract Adress");
        _Is_WhiteContractArr[account] = true;
        _WhiteContractArr.push(account);
    }
    function removeWhiteAccount(address account) external onlyOwner{
        require(_Is_WhiteContractArr[account], "ForthBoxSellToken:Account is already out White list");
        for (uint256 i = 0; i < _WhiteContractArr.length; i++){
            if (_WhiteContractArr[i] == account){
                _WhiteContractArr[i] = _WhiteContractArr[_WhiteContractArr.length - 1];
                _WhiteContractArr.pop();
                _Is_WhiteContractArr[account] = false;
                break;
            }
        }
    }



    
}