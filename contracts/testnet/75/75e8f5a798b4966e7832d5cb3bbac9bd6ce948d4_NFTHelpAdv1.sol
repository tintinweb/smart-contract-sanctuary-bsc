// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./Owner.sol";

interface IYiBoxNFT {
    function getTokensByStatus(address _owner, uint8 _status) external view returns (uint256[] memory);
    function setStatus(address _s, uint256 tokenId, uint8 _status) external;
    function tokenBase(uint256 tokenId) external view returns (uint16, uint8 ,uint32, uint8, uint16);
    function getAllOwners() external view returns (address[] memory _owners);
    //function getHashrateByAddress(address _target) external view returns (uint256);
}

interface IHashratePool {
    function settlementAll() external;
    function getRealHashrate(address target) external view returns (uint256);
}

contract NFTHelpAdv1 is Ownable {
    address public NFTToken;
    address public HashratePool;

    event eRentHero(uint8 indexed _st);
    event eFarm(uint8 indexed _st);
    event eUnLockBox(uint256 indexed _tks);

    function setNFTaddress(address _nft) external onlyOwner {
        NFTToken = _nft;
    }

    function setHashratePool(address _pool) external onlyOwner {
        HashratePool = _pool;
    }

    modifier haveNft() {
        require(NFTToken != address(0), 'NFTToken error');
        _;
    }

    modifier haveHashpool() {
        require(HashratePool != address(0), 'HashratePool error');
        _;
    }

    function rentHero(uint256 _tokenID) external lock haveNft returns (uint8 _st) {
        (, , , uint8 _status,) = IYiBoxNFT(NFTToken).tokenBase(_tokenID);
        require(_status == 4,"4 status error");
        IYiBoxNFT(NFTToken).setStatus(_msgSender(), _tokenID, 6);
        _st = 6;
        emit eRentHero(_st);
    }

    function unRentHero(uint256 _tokenID) external haveNft returns (uint8 _st) {
        (, , , uint8 _status,) = IYiBoxNFT(NFTToken).tokenBase(_tokenID);
        require(_status == 5 || _status == 6,"6 status error");
        IYiBoxNFT(NFTToken).setStatus(_msgSender(), _tokenID, 4);
        _st = 4;
        emit eRentHero(_st);
    }

    function unLockBox(uint256 _num) external lock haveNft returns (uint256[] memory _tks) {
        uint256[] memory _tokens = IYiBoxNFT(NFTToken).getTokensByStatus(_msgSender(), 1);
        require(_num <= _tokens.length,"Not enough nft");
        _tks = new uint256[](_num);
        for (uint i = 0; i < _num; i++) {
            IYiBoxNFT(NFTToken).setStatus(_msgSender(), _tokens[i], 3);
            _tks[i] = _tokens[i];
            emit eUnLockBox(_tks[i]);
        }
    }

    function farm(uint256 _tokenID) external haveNft haveHashpool returns (uint8 _st) {
        IHashratePool(HashratePool).settlementAll();
        (, , , uint8 _status,) = IYiBoxNFT(NFTToken).tokenBase(_tokenID);
        require(_status == 8,"8 status error");
        IYiBoxNFT(NFTToken).setStatus(_msgSender(), _tokenID, 4);
        _st = 4;
        emit eFarm(_st);
    }

    function unfarm(uint256 _tokenID) external haveNft haveHashpool returns (uint8 _st) {
        IHashratePool(HashratePool).settlementAll();
        (, , , uint8 _status,) = IYiBoxNFT(NFTToken).tokenBase(_tokenID);
        require(_status == 4,"4 status error");
        IYiBoxNFT(NFTToken).setStatus(_msgSender(), _tokenID, 8);
        _st = 8;
        emit eFarm(_st);
    }

    function walletTop(uint _top) external view haveNft haveHashpool returns (address[] memory _wal, uint256[] memory _hash) {
        address[] memory allAddress = IYiBoxNFT(NFTToken).getAllOwners();

        _wal = new address[](_top);
        _hash = new uint256[](_top);

        for (uint i = 0; i < allAddress.length; i++) {
            address _tar = allAddress[i];
            uint256 _h = IHashratePool(HashratePool).getRealHashrate(_tar);
            for (uint j = 0; j < _hash.length; j++) {
                if (_h >= _hash[j]) {
                    for (uint z = _hash.length - 1; z > j; z--) {
                        _hash[z] = _hash[z - 1];
                        _wal[z] = _wal[z - 1];
                    }
                    _wal[j] = _tar;
                    _hash[j] = _h;
                    break;
                }
            }
        } 
    }
}