/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface ILightbox {
    function walletOfOwner(address owner)
        external
        view
        returns (uint256[] memory);
     function balanceOfBronze(address _owner) external view returns (uint256);
     function balanceOfGold(address _owner) external view returns (uint256);
     function balanceOfDiamond(address _owner) external view returns (uint256);
}

interface ILightBoxV2 {
    function redeemNFT(
        uint256 countBronze,
        uint256 countGold,
        uint256 countDiamond,
        address redeemTo
    ) external;
}

contract LightBoxBurner is Ownable {
    IERC721 _sourceContract;
    ILightBoxV2 _targetContract;
    ILightbox _lightBoxContract;

    mapping(address => bool) private _redeemed;

    address deadAddress = 0x000000000000000000000000000000000000dEaD;

    constructor(address sourceContract, address targetContract) {
        _sourceContract = IERC721(sourceContract);
        _targetContract = ILightBoxV2(targetContract);
        _lightBoxContract = ILightbox(sourceContract);
    }

    function exchangeNFT(
        uint256 countBronze,
        uint256 countGold,
        uint256 countDiamond
    ) external {
        uint256 bronze = _lightBoxContract.balanceOfBronze(_msgSender());
        uint256 gold = _lightBoxContract.balanceOfGold(_msgSender());
        uint256 diamond = _lightBoxContract.balanceOfDiamond(_msgSender());
        uint256[] memory tokens = _lightBoxContract.walletOfOwner(_msgSender());
        require(countBronze == bronze && countGold == gold && countDiamond == diamond, "Incorrect token balances provided");
        require(
            tokens.length == countBronze + countGold + countDiamond,
            "Token redeem amount didnot match with burn amount"
        );
        require(!_redeemed[_msgSender()], "Already redeemed");

        //burn all
        for (uint256 i = 0; i < tokens.length; i++) {
            _sourceContract.transferFrom(_msgSender(), deadAddress, tokens[i]);
        }

        // mint V2
        _targetContract.redeemNFT(
            countBronze,
            countGold,
            countDiamond,
            _msgSender()
        );

        _redeemed[_msgSender()] = true;
    }

    function isRedeemed(address buyer) external view returns (bool){
        return _redeemed[buyer];
    }
}