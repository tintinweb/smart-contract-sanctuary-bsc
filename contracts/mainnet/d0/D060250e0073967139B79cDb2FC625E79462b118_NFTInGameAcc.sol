pragma solidity >=0.7.0 <0.9.0;

import "./ERC20Upgradeable.sol";
import "./SafeERC20Upgradeable.sol";
import "./IERC721Upgradeable.sol";
import "./SafeMathUpgradeable.sol";
import "./ERC721HolderUpgradeable.sol";
import "./ReentrancyGuardUpgradeable.sol";

import "./OperatorsUpgradeable.sol";

interface INFTCanBurn {
    function safeMint(address to, uint256 tokenId) external;

    function burn(uint256 tokenId) external;
}

contract NFTInGameAcc is
    OperatorsUpgradeable,
    ERC721HolderUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct AssetList {
        uint256 nfttype;
        bool canmint;
        bool canburn;
        address nftcontract;
        bool available;
    }

    struct ActionList {
        bool ingame;
        uint256 assetid;
        uint256 tokenid;
        bool mintorburn;
        uint256 blocknumber;
    }

    AssetList[] public assets;
    ActionList[] public actions;

    address payable public feeGather;
    uint256 public feeAmount;

    uint256[48] private __gap;

    event SetFeeGather(address feeGather, uint256 feeAmount);
    event TokenInGame(
        address indexed user,
        address tokenContract,
        uint256 tokenId
    );
    event TokenOutGame(address indexed user, uint256 tokenId, bool b);

    function initialize() external initializer {
        __Operators_init();
    }

    function addAsset(
        address _assets,
        bool _canmint,
        bool _canburn
    ) external onlyOwner {
        assets.push(AssetList(721, _canmint, _canburn, _assets, true));
    }

    function setAssetOp(
        uint256 _aid,
        bool _canmint,
        bool _canburn
    ) external onlyOwner {
        assets[_aid].canmint = _canmint;
        assets[_aid].canburn = _canburn;
    }

    function setAssetAvailable(uint256 _aid, bool _available)
        external
        onlyOwner
    {
        assets[_aid].available = _available;
    }

    function getAssetsLength() external view returns (uint256) {
        return assets.length;
    }

    function getActionsLength() external view returns (uint256) {
        return actions.length;
    }

    function setFeeGather(address payable _feeGather, uint256 _feeAmount)
        external
        onlyOwner
    {
        require(_feeGather != address(0), "_feeGather!");
        feeGather = _feeGather;
        feeAmount = _feeAmount;
        emit SetFeeGather(feeGather, feeAmount);
    }

    function lockInGame(uint256 _aid, uint256 _tokenId)
        external
        payable
        returns (bool)
    {
        require(msg.value >= feeAmount, "fee!");
        if (feeGather != address(0)) {
            feeGather.transfer(msg.value);
        }
        require(assets[_aid].available, "available!");

        IERC721Upgradeable(assets[_aid].nftcontract).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );

        actions.push(ActionList(true, _aid, _tokenId, false, block.number));

        emit TokenInGame(
            msg.sender,
            address(assets[_aid].nftcontract),
            _tokenId
        );
        return true;
    }

    function unlockMintFromGame(
        uint256 _aid,
        uint256 _tokenId,
        address _user,
        bool _mintorburn
    ) public onlyOper returns (bool) {
        require(assets[_aid].canmint, "canmint!");
        address asset = assets[_aid].nftcontract;
        INFTCanBurn(asset).safeMint(address(this), _tokenId);
        return unlockFromGame(_aid, _tokenId, _user, _mintorburn);
    }

    function unlockMintFromGameBatch(
        uint256 _aid,
        uint256[] memory _tokenId,
        address[] memory _user,
        bool _mintorburn
    ) external onlyOper returns (bool) {
        require(_tokenId.length == _user.length, "length!");
        for (uint256 i = 0; i < _tokenId.length; i++) {
            unlockMintFromGame(_aid, _tokenId[i], _user[i], _mintorburn);
        }
        return true;
    }

    function unlockToBurn(uint256 _aid, uint256 _tokenId)
        public
        onlyOper
        returns (bool)
    {
        require(assets[_aid].canburn, "canburn!");
        address asset = assets[_aid].nftcontract;
        INFTCanBurn(asset).burn(_tokenId);
        return true;
    }

    function unlockFromGame(
        uint256 _aid,
        uint256 _tokenId,
        address _user,
        bool _mintorburn
    ) public onlyOper returns (bool) {
        address asset = assets[_aid].nftcontract;
        // 有持有，有对象
        IERC721Upgradeable(asset).safeTransferFrom(
            address(this),
            _user,
            _tokenId
        );

        actions.push(
            ActionList(false, _aid, _tokenId, _mintorburn, block.number)
        );

        emit TokenOutGame(_user, _tokenId, false);
        return true;
    }

    function unlockFromGameBatch(
        uint256 _aid,
        uint256[] memory _tokenId,
        address[] memory _user,
        bool _mintorburn
    ) external onlyOper returns (bool) {
        require(_tokenId.length == _user.length, "length!");
        for (uint256 i = 0; i < _tokenId.length; i++) {
            unlockFromGame(_aid, _tokenId[i], _user[i], _mintorburn);
        }
        return true;
    }
}