// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./IERC20.sol";
import "./ERC1155.sol";

contract LaunchpadNFTERC1155 is LaunchpadNFTERC1155Core, ERC1155 {
    using SafeMath for uint256;
    using Strings for uint256;
    using Address for address;

    event AddLaunchpadFactory(uint256 indexed tokenId);

    mapping(uint256 => LaunchpadNFTERC1155) private LaunchpadFactory;

    // mapping project to tokenId
    mapping(string => uint256) private LaunchpadToTokenId;

    modifier onlySafeNFT() {
        require(manager.safeNFT(msg.sender) == true, "require Safe Address.");
        _;
    }

    modifier onlySafeTransferNFT() {
        require(manager.safeTransferNFT(msg.sender) == true, "require Safe Transfer Address.");
        _;
    }

    constructor(
        string memory baseURI,
        address _manager
    ) ERC1155(baseURI, _manager, "Netkiin Launchpad", "NetkiinNFT") {}

    /**
     * @dev Withdraw bnb from this contract (Callable by owner only)
     */
    function SwapExactToken(address coinAddress, uint256 value, address payable to) public onlyOwner {
        if (coinAddress == address(0)) {
            return to.transfer(value);
        }
        IERC20(coinAddress).transfer(to, value);
    }

    function safeMintNFT(address _addr, uint256 tokenId, uint256 amount) external override onlySafeNFT {
        _mint(_addr, tokenId, amount, "0x0");
    }

    function safeBatchMintNFT(address _addr, uint256[] memory tokenId, uint256[] memory amount) external override onlySafeNFT {
        _mintBatch(_addr, tokenId, amount, "0x0");
    }

    function burnNFT(address _addr, uint256 tokenId, uint256 amount) external override onlySafeTransferNFT {
        _burn(_addr, tokenId, amount);
    }

    function burnBatchNFT(address _addr, uint256[] memory ids, uint256[] memory amounts) external override onlySafeTransferNFT {
        _burnBatch(_addr, ids, amounts);
    }

    /**
    * @dev Changes the base URI if we want to move things in the future (Callable by owner only)
    */
    function changeBaseURI(string memory baseURI) public onlyOwner {
        _setURI(baseURI);
    }

    function setNFTFactory(LaunchpadNFTERC1155 memory _launchpad, uint256 _tokenId) external override onlySafeNFT {
        if (LaunchpadFactory[_tokenId].tokenId > 0 && bytes(LaunchpadFactory[_tokenId].launchpad_id).length != bytes(_launchpad.launchpad_id).length) {
            delete LaunchpadToTokenId[LaunchpadFactory[_tokenId].launchpad_id];
        }
        LaunchpadFactory[_tokenId] = _launchpad;
        LaunchpadToTokenId[_launchpad.launchpad_id] = _tokenId;
        emit AddLaunchpadFactory(_tokenId);
    }

    function getAllNFT(uint256 _fromTokenId, uint256 _toTokenId) external view override returns (LaunchpadNFTERC1155[] memory) {
        uint256 total = _toTokenId - _fromTokenId;
        require(total >= 0, "_toTokenId must be greater than _fromTokenId");
        LaunchpadNFTERC1155[] memory allLaunchpad = new LaunchpadNFTERC1155[](total);
        uint256 count = 0;
        for (uint256 index = _fromTokenId; index <= _toTokenId; index++) {
            allLaunchpad[count] = LaunchpadFactory[index];
            ++count;
        }
        return allLaunchpad;
    }

    function getLaunchpadFactory(uint256 _tokenId) external view override returns (LaunchpadNFTERC1155 memory){
        return LaunchpadFactory[_tokenId];
    }

    function getLaunchpadToTokenId(string memory _launchpad_id) external view override returns (uint256){
        return LaunchpadToTokenId[_launchpad_id];
    }

    function getNextNFTId() external view override returns (uint256){
        return totalSupply().add(1);
    }
}