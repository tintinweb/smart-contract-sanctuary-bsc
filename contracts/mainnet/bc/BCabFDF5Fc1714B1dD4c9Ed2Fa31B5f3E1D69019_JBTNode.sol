// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "./ERC721.sol";

library Counters {
    struct Counter {uint256 _value;}
    function current(Counter storage counter) internal view returns (uint256) {return counter._value;}
    function increment(Counter storage counter) internal {unchecked {counter._value += 1;}}
    function decrement(Counter storage counter) internal {uint256 value = counter._value; require(value > 0, "Counter: decrement overflow"); unchecked {counter._value = value - 1;}}
    function reset(Counter storage counter) internal {counter._value = 0;}
}

abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;
    mapping(uint256 => string) private _tokenURIs;
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return super.tokenURI(tokenId);
    }
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

/** JBT 平台下,超级节点NFT **/
contract JBTNode is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address private owner;//合约创建者
    bool isCreate;//创建开关
    mapping(address => bool) private greenTransactionApproveMapping; //交易免检地址mapping
    mapping(address => bool) private createTokenApproveMapping; //创建授权地址mapping

    modifier onlyOwner(){
        require(msg.sender == owner,"NFT : The caller is not the master");
        _;
    }

    modifier onlyCreate(){
        require(createTokenApproveMapping[msg.sender] || msg.sender == owner,"NFT : The caller is not the creator");
        require(isCreate,"NFT : Close create");
        _;
    }

    constructor() ERC721("JBT Node", "JNODE") {
        owner = msg.sender;
    }

    /*
     * @dev 设置创建开关
     * @param _bool 是否授权
     */
    function setIsCreate(bool _bool) public onlyOwner(){
        isCreate = _bool;
    }

    /*
     * @dev 设置交易免检地址
     * @param _address 交易免检地址
     * @param _bool 是否免检
     */
    function setGreenTransactionApproveAddress(address _address,bool _bool) public onlyOwner{
        greenTransactionApproveMapping[_address] = _bool;
    }

    /*
     * @dev 设置创建授权地址
     * @param _address 授权地址
     * @param _bool 是否授权
     */
    function setCreateApproveAddress(address _address,bool _bool) public onlyOwner(){
        createTokenApproveMapping[_address] = _bool;
    }

    /**
     * @dev 重写 | ERC721权限验证函数,为市场合约、确权合约开辟一条绿色通道
     * @param tokenOwner NFT 主人
     * @param operator NFT 交易操作人
     */
    function isApprovedForAll(address tokenOwner, address operator) public view virtual override returns (bool) {
        if(greenTransactionApproveMapping[operator]){
            return true;//放行掉设置的交易免检地址
        }
        return super.isApprovedForAll(tokenOwner,operator);//继续调用父类中原有权限判断的业务逻辑
    }

    /**
     * @dev 创建NFT
     * @param tokenURI 资源定位符
     * @param creator 创建者
     */
    function createToken(string memory tokenURI,address creator) public onlyCreate returns (uint) {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        //造币厂,创建一个ID为tokenId的非同质化代币到msg.sender地址
        _mint(creator, tokenId);
        //将tokenURI设置为tokenId的tokenURI
        _setTokenURI(tokenId, tokenURI);
        return tokenId;
    }


}