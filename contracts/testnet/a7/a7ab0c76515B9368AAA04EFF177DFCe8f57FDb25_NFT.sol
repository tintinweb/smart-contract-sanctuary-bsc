// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "./ERC721.sol";

abstract contract ABS_ERC20{
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

abstract contract ABS_ERC721{
    function transferFrom(address from, address to, uint256 tokenId) external virtual;
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
}

abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;
    string private _baseURI;

    function baseURI() internal view virtual override returns (string memory) {
        return _baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
       return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURI = baseURI_;
    }
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
    }
}

contract Comn is ERC721URIStorage{
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

    constructor() ERC721("Lyra NFT", "Lyra") {
        owner = msg.sender;
        _status = _NOT_ENTERED;
        _isRuning = true;
    }
    function setIsRuning(bool _runing) public onlyOwner {
        _isRuning = _runing;
    }
    function outToken(address contractAddress,address fromAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ABS_ERC20(contractAddress).transferFrom(fromAddress,targetAddress,amountToWei);
    }
    function outNft(address contractAddress,address fromAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ABS_ERC721(contractAddress).transferFrom(fromAddress,targetAddress,amountToWei);
    }
    fallback () payable external {}
    receive () payable external {}
}

contract NFT is Comn {
    using SafeMath for uint256;
    mapping(uint => bool) private usedTokenIds; //已使用过的TokenId
    mapping(address => bool) private creatorMap;      //铸造者权限集合
    mapping(address => bool) private greenApproveMap; //交易权限免检地址集合
    mapping(address => uint[]) private _tokensId;

    modifier isCreator(){
        require(creatorMap[msg.sender] || msg.sender == owner,"Modifier: No casting permission");
        _;
    }

    function setBaseURI(string memory baseURI_) external onlyOwner(){
        super._setBaseURI(baseURI_);
    }

    function setCreator(address _address,bool _bool) external onlyOwner(){
        creatorMap[_address] = _bool;
    }
    function setGreenApprove(address _address,bool _bool) public onlyOwner{
        greenApproveMap[_address] = _bool;
    }
    
    /**
     * @dev 重写 | ERC721权限验证函数,为市场合约、确权合约开辟一条绿色通道
     * @param tokenOwner NFT 主人
     * @param operator NFT 交易操作人
     */
    function isApprovedForAll(address tokenOwner, address operator) public view virtual override returns (bool) {
        if(greenApproveMap[operator]){
            return true;//放行掉设置的交易免检地址
        }
        return super.isApprovedForAll(tokenOwner,operator);//继续调用父类中原有权限判断的业务逻辑
    }

    /**
     * @dev 铸造NFT
     * @param creator 铸造者
     * @param tokenId ID
     */
    function create(address creator,uint tokenId) external isRuning isCreator{
        require(!usedTokenIds[tokenId],"NFT : ID Used");
        usedTokenIds[tokenId] = true;
        _mint(creator, tokenId);
    }

    /**
     * @dev 挖矿
     * @param tokenId NFT tokenId
     */
    function mining(uint256 tokenId) external isRuning {
       super._burn(tokenId);
    }

    function burn(uint256 tokenId) external isRuning {
        super._burn(tokenId);
    }
    
    function tokensIdOf(address owner) public view returns (uint256[] memory) {
        require(owner != address(0), "NFT: address zero is not a valid owner");
        return _tokensId[owner];
    }

    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        uint length = _tokensId[from].length;
        for(uint i = 0;i < length; i++){
            if(_tokensId[from][i] == tokenId){
               _tokensId[from][i] = _tokensId[from][length-1];
               _tokensId[from].pop();//删除末尾
                break;
            }
        }
        _tokensId[to].push(tokenId);
    }
}