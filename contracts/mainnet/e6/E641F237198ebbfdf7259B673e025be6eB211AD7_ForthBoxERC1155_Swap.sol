/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.10;


interface IERC1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 id,uint256 amount,bytes calldata data) external;
    function safeBatchTransferFrom(address from,address to,uint256[] calldata ids,uint256[] calldata amounts,bytes calldata data) external;
    function uri(uint256 id) external view returns (string memory);
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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

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


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

// Inheritancea
interface IERC1155Swap {
    // Views
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenOfOwner(address owner) external view returns (uint256[] memory);
    function tokenURI() external view returns (string memory);
    function bExistsID(uint256 tokenId) external view returns (bool);
    function getSellInfos(uint256[] calldata tokenIdArr) external view returns ( address[] memory addrs,uint256[] memory nums,uint256[] memory prices,uint256[] memory times);
    
    //sell withdraw buy
    function sell(uint256 num,uint256 price) external returns (bool);
    function sells(uint256[] calldata tokenIds,uint256[] calldata prices) external returns (bool);
    function withdraw(uint256 tokenId) external returns (bool);
    function withdraws(uint256[] calldata tokenIds) external returns (bool);
    function buy(uint256 tokenId) external returns (bool);
    function buys(uint256[] calldata tokenIds) external returns (bool);

    // EVENTS
    event Sell(uint256 indexed num, uint256 price);
    event Withdraw(uint256 indexed tokenId);
    event Buy(address indexed buyer,address indexed from, uint256 num, uint256 price);
    event AddWhiteAccount(address indexed sender,address indexed account);
    event RemoveWhiteAccount(address indexed sender,address indexed account);
    event ChangeBatchOperation(address indexed sender, bool tBatchOperation);
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
library Counters {
    struct Counter {
        uint256 _value;
    }
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    function increment(Counter storage counter) internal {
        unchecked {counter._value += 1;}
    }
}

contract ForthBoxERC1155_Swap is ERC165,IERC1155Swap, Ownable, ReentrancyGuard,IERC1155Receiver {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string private _name = "ForthBox ERC1155 Swap";
    string private _symbol = "ERC1155 Swap ";
    IERC20 public fbxToken;
    IERC1155 public nftToken;
    uint256 public nftId=1;
    address public fundAdress;

    bool public bBatchOperation = false;

    mapping(uint256 => address) private _owners;
    mapping(uint256 => uint256) private _sellPrice;
    mapping(uint256 => uint256) private _sellNum;
    mapping(uint256 => uint256) private _sellTime;
    mapping(address => uint256) private _balances;

    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;
    uint256[] private _allTokens;
    mapping(uint256 => uint256) private _allTokensIndex;

    mapping (address => bool) private _Is_WhiteContractArr;
    address[] private _WhiteContractArr;
    
    struct sBuyPropertys {
        uint256 id;
        string optType;
        address addr;
        uint256 tokenId;
        uint256 num;
        uint256 price;
        uint256 time;
    }

    mapping(uint256 => sBuyPropertys) private _swapPropertys;
    mapping(address => uint256[]) private _swapIds;
    uint256 private _swapCount;
    

    constructor(address fbxTokenAdrr,address nftTokenAdrr, address tFundAdress,uint256 tNftId) {
        fbxToken = IERC20(fbxTokenAdrr);
        nftToken = IERC1155(nftTokenAdrr);
        fundAdress = tFundAdress;
        nftId = tNftId;
    }
 
    /* ========== VIEWS ========== */
    function name() external view returns (string memory) {
        return _name;
    }
    function symbol() external view returns (string memory) {
        return _symbol;
    }
    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }
    function tokenByIndex(uint256 index) external view returns (uint256) {
        require(index < totalSupply(), "ForthBoxERC1155_Swap: global index out of bounds");
        return _allTokens[index];
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ForthBoxERC1155_Swap: owner query for nonexistent token");
        return owner;
    }
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }
    function bExistsID(uint256 tokenId) external view returns (bool) {
        return _exists(tokenId);
    }
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
        require(index < balanceOf(owner), "ForthBoxERC1155_Swap: owner index out of bounds");
        return _ownedTokens[owner][index];
    }
    function tokenOfOwner(address owner) external view returns (uint256[] memory) {
        uint256 num = balanceOf(owner);
        uint256[] memory Token_list = new uint256[](uint256(num));
        for(uint256 i=0; i<num; ++i) {
            Token_list[i] =_ownedTokens[owner][i];
        }
        return Token_list;
    }

    function onERC1155Received(address,address,uint256,uint256,bytes calldata) external pure returns (bytes4){
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address,address,uint256[] calldata,uint256[] calldata,bytes calldata) external pure returns (bytes4){
        return this.onERC1155BatchReceived.selector;
    }

    function tokenURI() external view returns (string memory){      
        return nftToken.uri(nftId);
    }

    function isWhiteContract(address account) public view returns (bool) {
        if(!account.isContract()) return true;
        return _Is_WhiteContractArr[account];
    }
    function getWhiteAccountNum() external view returns (uint256){
        return _WhiteContractArr.length;
    }
    function getWhiteAccountIth(uint256 ith) external view returns (address WhiteAddress){
        require(ith <_WhiteContractArr.length, "ForthBoxERC1155_Swap: not in White Adress");
        return _WhiteContractArr[ith];
    }

    function getSellInfo(uint256 tokenId) external view returns (address addrs,uint256 num,uint256 prices,uint256 time){
        require(_exists(tokenId), "ForthBoxERC1155_Swap: token none exist");
        return (_owners[tokenId],_sellNum[tokenId],_sellPrice[tokenId],_sellTime[tokenId]);
    }

    function getSellInfos(uint256[] calldata tokenIdArr) external view returns (
        address[] memory addrs,
        uint256[] memory nums,uint256[] memory prices,uint256[] memory times){
        uint256 num = tokenIdArr.length;
        addrs = new address[](uint256(num));
        nums = new uint256[](uint256(num));
        prices = new uint256[](uint256(num));
        times = new uint256[](uint256(num));
        for(uint256 i=0; i<tokenIdArr.length; ++i) {
            addrs[i] = _owners[tokenIdArr[i]];
            nums[i] = _sellNum[tokenIdArr[i]];   
            prices[i] = _sellPrice[tokenIdArr[i]];
            times[i] =_sellTime[tokenIdArr[i]];
        }
        return (addrs,nums,prices,times);
    }

    function swapCount() external view returns(uint256){
        return _swapCount;
    }
    function swapInfo(uint256 iD) external view returns (
        uint256 id,
        string memory optType,
        address addr,
        uint256 tokenId,
        uint256 num,
        uint256 price,
        uint256 time
        ) {
        require(iD <= _swapCount, "ForthBoxBuyCoin: exist num!");
        id = _swapPropertys[iD].id;
        optType = _swapPropertys[iD].optType;
        addr = _swapPropertys[iD].addr;
        tokenId = _swapPropertys[iD].tokenId;
        num = _swapPropertys[iD].num;
        price = _swapPropertys[iD].price;
        time = _swapPropertys[iD].time;
        return (id,optType,addr,tokenId, num,price,time);
    }
    function swapNum(address addr) external view returns (uint256) {
        return _swapIds[addr].length;
    }
    function swapIthId(address addr,uint256 ith) external view returns (uint256) {
        require(ith < _swapIds[addr].length, "ForthBoxBuyCoin: not exist!");
        return _swapIds[addr][ith];
    }

    function swapInfos(uint256 fromId,uint256 toId) external view returns (
        uint256[] memory idArr,
        string[] memory optTypeArr,
        address[] memory addrArr,
        uint256[] memory tokenIdArr,
        uint256[] memory numArr,
        uint256[] memory priceArr,
        uint256[] memory timeArr
        ) {
        require(toId <= _swapCount, "ForthBoxBuyCoin: exist num!");
        require(fromId <= toId, "ForthBoxBuyCoin: exist num!");
        idArr = new uint256[](toId-fromId+1);
        optTypeArr = new string[](toId-fromId+1);
        addrArr = new address[](toId-fromId+1);
        tokenIdArr = new uint256[](toId-fromId+1);
        numArr = new uint256[](toId-fromId+1);
        priceArr = new uint256[](toId-fromId+1);
        timeArr = new uint256[](toId-fromId+1);
        uint256 i=0;
        for(uint256 ith=fromId; ith<=toId; ith++) {
            idArr[i] = _swapPropertys[ith].id;
            optTypeArr[i] = _swapPropertys[ith].optType;
            addrArr[i] = _swapPropertys[ith].addr;
            tokenIdArr[i] = _swapPropertys[ith].tokenId;
            numArr[i] = _swapPropertys[ith].num;
            priceArr[i] = _swapPropertys[ith].price;
            timeArr[i] = _swapPropertys[ith].time;
            i = i+1;
        }
        return (idArr,optTypeArr,addrArr,tokenIdArr,numArr,priceArr,timeArr);
    }
    
    //---internal---//
    function _mint(address to) internal returns (uint256) {
        require(to != address(0), "ForthBoxERC1155_Swap: mint to the zero address");
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        _addTokenToAllTokensEnumeration(tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
        _balances[to] += 1;
        _owners[tokenId] = to;
        return tokenId;
    }
    function _burn(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);
        _removeTokenFromOwnerEnumeration(owner, tokenId);
        _removeTokenFromAllTokensEnumeration(tokenId);
        _balances[owner] -= 1;
        delete _owners[tokenId];
        delete _sellPrice[tokenId];   
        delete _sellNum[tokenId];   
        delete _sellTime[tokenId];
    }
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) internal {
        uint256 length = balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }
    function _addTokenToAllTokensEnumeration(uint256 tokenId) internal {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) internal {
        uint256 lastTokenIndex = balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) internal {
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];
        uint256 lastTokenId = _allTokens[lastTokenIndex];
        _allTokens[tokenIndex] = lastTokenId; 
        _allTokensIndex[lastTokenId] = tokenIndex;
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

    //---write---//
    function _sell(uint256 tokenNum,uint256 price) internal{
        nftToken.safeTransferFrom(_msgSender(), address(this), nftId,tokenNum,"");
        uint256 tokenId = _mint(_msgSender());
        _sellPrice[tokenId] = price;
        _sellNum[tokenId] = tokenNum;
        _sellTime[tokenId] = block.timestamp;


        _swapCount = _swapCount.add(1);
        _swapIds[_msgSender()].push(_swapCount);

        _swapPropertys[_swapCount].id = _swapCount;
        _swapPropertys[_swapCount].optType = "sell";
        _swapPropertys[_swapCount].addr = _msgSender();
        _swapPropertys[_swapCount].tokenId = tokenId;
        _swapPropertys[_swapCount].num = tokenNum;
        _swapPropertys[_swapCount].price = price;
        _swapPropertys[_swapCount].time =  block.timestamp;

        emit Sell(tokenId, price);
    }
    function sell(uint256 tokenNum,uint256 price) external nonReentrant returns (bool){
        require(isWhiteContract(_msgSender()), "ForthBoxERC1155_Swap: Contract not in white list!");
        _sell(tokenNum,price);
        return true;
    }
    function sells(uint256[] calldata tokenNums,uint256[] calldata prices ) external nonReentrant returns (bool){
        require(isWhiteContract(_msgSender()), "ForthBoxNFT_Swap: Contract not in white list!");
        require(tokenNums.length<=200, "ForthBoxNFT_Swap: num exceed 200!");
        require(bBatchOperation, "ForthBoxNFT_Swap: can not BatchOperation!");

        for(uint256 i=0; i<tokenNums.length; ++i) {
            _sell(tokenNums[i],prices[i]);
        }
        return true;
    }
    function _withdraw(uint256 tokenId) internal{
        require(_msgSender() == ownerOf(tokenId),"ForthBoxERC1155_Swap: Only the owner of this Token could withdraw It!");
        nftToken.safeTransferFrom(address(this),_msgSender(), nftId,_sellNum[tokenId],"");
        _burn(tokenId);

        _swapCount = _swapCount.add(1);
        _swapIds[_msgSender()].push(_swapCount);

        _swapPropertys[_swapCount].id = _swapCount;
        _swapPropertys[_swapCount].optType = "withdraw";
        _swapPropertys[_swapCount].addr = _msgSender();
        _swapPropertys[_swapCount].tokenId = tokenId;
        _swapPropertys[_swapCount].num = _sellNum[tokenId];
        _swapPropertys[_swapCount].price = _sellPrice[tokenId];
        _swapPropertys[_swapCount].time =  block.timestamp;

        emit Withdraw(tokenId);
    }

    function withdraw(uint256 tokenId) external nonReentrant returns (bool){
        require(isWhiteContract(_msgSender()), "ForthBoxERC1155_Swap: Contract not in white list!");
        _withdraw(tokenId);
        return true;
    }
    function withdraws(uint256[] calldata tokenIds) external nonReentrant returns (bool){
        require(isWhiteContract(_msgSender()), "ForthBoxERC1155_Swap: Contract not in white list!");
        require(tokenIds.length<=200, "ForthBoxERC1155_Swap: num exceed 200!");
        require(bBatchOperation, "ForthBoxERC1155_Swap: can not BatchOperation!");

        for(uint256 i=0; i<tokenIds.length; ++i) {
            _withdraw(tokenIds[i]);
        }
        return true;
    }

    function _buy(uint256 tokenId) internal{
        require(_exists(tokenId),"ForthBoxERC1155_Swap: token none exist");

        address ownerToken = ownerOf(tokenId);
        uint256 price0 = _sellPrice[tokenId];

        uint256 allFee = price0.mul(5).div(100);
        uint256 feeFund = allFee.mul(20).div(100);
        uint256 tokenNum = _sellNum[tokenId];

        fbxToken.safeTransferFrom(_msgSender(), ownerToken, price0.sub(allFee));
        fbxToken.safeTransferFrom(_msgSender(), fundAdress, feeFund);
        fbxToken.safeTransferFrom(_msgSender(), address(0), allFee.sub(feeFund));

        nftToken.safeTransferFrom(address(this),_msgSender(),  nftId,tokenNum,"");

        _swapCount = _swapCount.add(1);
        _swapIds[_msgSender()].push(_swapCount);

        _swapPropertys[_swapCount].id = _swapCount;
        _swapPropertys[_swapCount].optType = "buy";
        _swapPropertys[_swapCount].addr = _msgSender();
        _swapPropertys[_swapCount].tokenId = tokenId;
        _swapPropertys[_swapCount].num = _sellNum[tokenId];
        _swapPropertys[_swapCount].price = _sellPrice[tokenId];
        _swapPropertys[_swapCount].time =  block.timestamp;

        _burn(tokenId);
        emit Buy(_msgSender(), ownerToken,tokenNum,price0);
    }
    function buy(uint256 tokenId) external nonReentrant returns (bool){
        require(isWhiteContract(_msgSender()), "ForthBoxERC1155_Swap: Contract not in white list!");
        _buy(tokenId);
        return true;
    }
    function buys(uint256[] calldata tokenIds) external nonReentrant returns (bool){
        require(isWhiteContract(_msgSender()), "ForthBoxERC1155_Swap: Contract not in white list!");
        require(tokenIds.length<=200, "ForthBoxNFT: num exceed 200!");
        require(bBatchOperation, "ForthBoxERC1155_Swap: can not BatchOperation!");

        for(uint256 i=0; i<tokenIds.length; ++i) {
            _buy(tokenIds[i]);
        }
        return true;
    }

    //---write onlyOwner---//
    function changeBatchOperation(bool tBatchOperation) external onlyOwner{
        bBatchOperation = tBatchOperation;
        emit ChangeBatchOperation(_msgSender(), bBatchOperation);
    }

    function addWhiteAccount(address account) external onlyOwner{
        require(!_Is_WhiteContractArr[account], "ForthBoxERC1155_Swap: Account is already White list");
        require(account.isContract(), "ForthBoxERC1155_Swap: not contract address");
        _Is_WhiteContractArr[account] = true;
        _WhiteContractArr.push(account);
        
        emit AddWhiteAccount(_msgSender(), account);
    }
    function removeWhiteAccount(address account) external onlyOwner{
        require(_Is_WhiteContractArr[account], "ForthBoxERC1155_Swap: Account is already out White list");
        for (uint256 i = 0; i < _WhiteContractArr.length; i++){
            if (_WhiteContractArr[i] == account){
                _WhiteContractArr[i] = _WhiteContractArr[_WhiteContractArr.length - 1];
                _WhiteContractArr.pop();
                _Is_WhiteContractArr[account] = false;
                break;
            }
        }
        emit RemoveWhiteAccount(_msgSender(), account);
    }

}