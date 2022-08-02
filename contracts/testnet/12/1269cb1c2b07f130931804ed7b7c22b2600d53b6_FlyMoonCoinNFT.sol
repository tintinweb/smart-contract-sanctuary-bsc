// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "./SafeOwnable.sol";
import "./ERC721.sol";
import "./SmartDisPatchInitializable.sol";

contract FlyMoonCoinNFT is
    ERC721("FlyMoonCoinNFT", "FM-NFT"),
    SafeOwnable
{
      using Strings for uint256;
    // 是否准许nft开卖-开关
    bool public _isSaleActive = false;
    // 初始化盲盒，等到一定时机可以随机开箱，变成true
    bool public _revealed = false;
   
    // nft的总数量
    uint256 public constant MAX_SUPPLY = 2000;
    // 铸造Nft的价格
    uint256 public mintPrice = 0.003 ether;
   
    // 一次mint的nft的数量
    uint256 public maxMint = 10;
   
    // 盲盒开关打开后，需要显示开箱的图片的base地址
    // 盲盒图片的meta,json地址，后文会提到
    string public notRevealedUri;
    // 默认地址的扩展类型
    string public baseExtension = ".json";
   
    mapping(uint256 => string) private _tokenURIs;


    SmartDisPatchInitializable public dispatchHandle;
    
    mapping(address => bool) public isMinner;

    event Mint(address account, uint256 tokenId);
    event NewMinner(address account);
    event DelMinner(address account);

    function createDispatchHandle() external onlyOwner {
        bytes memory bytecode = type(SmartDisPatchInitializable).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(address(this)));
        address poolAddress;
        assembly {
            poolAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
    
        SmartDisPatchInitializable(poolAddress).initialize();

        dispatchHandle = SmartDisPatchInitializable(poolAddress);
    }

    function setDispatchHandle(address _handle) external onlyOwner {
        dispatchHandle = SmartDisPatchInitializable(_handle);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if (address(dispatchHandle) != address(0)) {
            if (from != address(0)) {
                dispatchHandle.withdraw(from, 1);
            }
            dispatchHandle.stake(to, 1);
        }
    }

    // 外部地址进行铸造nft的函数调用
    function mintNft(uint256 tokenQuantity) public payable {
        // 校验总供应量+每次铸造的数量<= nft的总数量
        require(
            totalSupply() + tokenQuantity <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        // 校验是否开启开卖状态
        require(_isSaleActive, "Sale must be active to mint NicMetas");
    
        // 校验本次铸造的数量*铸造的价格 == 本次消息附带的eth的数量
        require(
            tokenQuantity * mintPrice == msg.value,
            "Not enough ether sent"
        );
        // 校验本次铸造的数量 <= 本次铸造的最大数量
        require(tokenQuantity <= maxMint, "Can only mint 10 tokens at a time");
         payable(owner()).transfer(msg.value);
        // 以上校验条件满足，进行nft的铸造
        _mintNft(tokenQuantity);
    }
   
    // 进行铸造
    function _mintNft(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            // mintIndex是铸造nft的序号，按照总供应量从0开始累加
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                // 调用erc721的安全铸造方法进行调用
                _safeMint(msg.sender, mintIndex);
            }
        }
    }
   
    // 返回每个nft地址的Uri，这里包含了nft的整个信息，包括名字，描述，属性等
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
   
        // 盲盒还没开启，那么默认是一张黑色背景图片或者其他图片
        if (_revealed == false) {
            return notRevealedUri;
        }
   
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();
   
        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return
            string(abi.encodePacked(base, tokenId.toString(), baseExtension));
    }
   
   
    //only owner
    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }
   
    function flipReveal() public onlyOwner {
        _revealed = !_revealed;
    }
   
    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }
   
    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }
   
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
         _setBaseURI(_newBaseURI);
    }
   
    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }
   
   
    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }
}