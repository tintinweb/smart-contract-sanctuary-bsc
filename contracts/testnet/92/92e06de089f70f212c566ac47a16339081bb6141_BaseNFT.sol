// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
pragma abicoder v2;
import "./Context.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./ERC721.sol";
import "./Ownable.sol";
import "./Strings.sol";
import "./EnumerableSet.sol";
import "./ManagerInterface.sol";
import "./IERC20.sol";
import "./INFTCore.sol";

contract BaseNFT is INFTCore, ERC721, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    mapping(uint256 => NFTItem) public nftFactory;
	mapping (address => User) internal users;

    event UpdateClass(uint256 indexed tokenId, string class);
    event UpdateRare(uint256 indexed tokenId, uint256 rare);
    event AddNFTFactory(uint256 indexed tokenId);
    event AddNFTUser(uint256 indexed tokenId);

    modifier onlySafeNFT() {
        require(manager.safeNFT(msg.sender), "require Safe Address.");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI,
        address _manager
    ) ERC721(name, symbol, _manager) {
        _setBaseURI(baseURI);
        manager = ManagerInterface(_manager);
    }

    /**
     * @dev Withdraw bnb from this contract (Callable by owner only)
     */
    function handleForfeitedBalance(address coinAddress, uint256 value, address payable to) public onlyOwner {
        if (coinAddress == address(0)) {
            return to.transfer(value);
        }
        IERC20(coinAddress).transfer(to, value);
    }

    /**
     * @dev Changes the base URI if we want to move things in the future (Callable by owner only)
     */
    function changeBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function changeClass(
        uint256 _tokenId,
        address _owner,
        string memory _class
    ) external override onlySafeNFT {       
        NFTItem memory nft = nftFactory[_tokenId];
        nft.class = _class;
        User storage userInfo = users[_owner];
        for (uint256 index = 0; index < userInfo.nfts.length; index++) {
            if(userInfo.nfts[index].tokenId == _tokenId) {
                userInfo.nfts[index].class = _class;
            }
        } 

        emit UpdateClass(_tokenId, _class);
    }

    function changeRare(
        uint256 _tokenId,
        address _owner,
        uint256 _rare
    ) external override onlySafeNFT {       
        NFTItem memory nft = nftFactory[_tokenId];
        nft.rare = _rare;
        User storage userInfo = users[_owner];
        for (uint256 index = 0; index < userInfo.nfts.length; index++) {
            if(userInfo.nfts[index].tokenId == _tokenId) {
                userInfo.nfts[index].rare = _rare;
            }
        } 

        emit UpdateRare(_tokenId, _rare);
    }

    function getNFT(uint256 _tokenId)
        external
        override
        view
        returns (NFTItem memory)
    {
        return nftFactory[_tokenId];
    }

    function setNFTFactory(
        NFTItem memory _nft,
        uint256 _tokenId
    ) external override onlySafeNFT {       
        nftFactory[_tokenId] = _nft;

        emit AddNFTFactory(_tokenId);
    }

    function setNFTForUser(
        NFTItem memory _nft,
        uint256 _tokenId,
        address _userAddress
    ) external override onlySafeNFT {       
        User storage user = users[_userAddress];
        user.owner = _userAddress;
        user.nfts.push(_nft);
        emit AddNFTUser(_tokenId);
    }

    function setManager(
        address _addr
    ) external onlyOwner {       
        manager = ManagerInterface(_addr);        
    }

    function safeMintNFT(
        address _addr,
        uint256 tokenId
    ) external override onlySafeNFT {       
        _safeMint(_addr, tokenId);
    }

    function getAllNFT(uint256 _fromTokenId, uint256 _toTokenId)
        external
        override
        view
        returns (NFTItem[] memory)
    {
        NFTItem[] memory allNft = new NFTItem[](totalSupply());
        uint256 count = 0;
        for (uint256 index = _fromTokenId; index <= _toTokenId; index++) {
            allNft[count] = nftFactory[index];
            ++count;
        }
        return allNft;
    }

    function getUser(address _userAddress)
        external
        override
        view
        returns (User memory userInfo)
    {
       userInfo = users[_userAddress];
    }

    function getNextNFTId() external override view returns (uint256){
        return totalSupply().add(1);
    }

    function _transfer(address from, address to, uint256 tokenId) internal override(ERC721) {
        super._transfer(from, to, tokenId);
        User storage userFrom = users[from];
        for (uint256 index = 0; index < userFrom.nfts.length; index++) {
            if(userFrom.nfts[index].tokenId == tokenId) {
                delete userFrom.nfts[index];
            }
        }
        NFTItem memory nftItem = nftFactory[tokenId];
        User storage userTo = users[to];
        userTo.nfts.push(nftItem);

    }
}