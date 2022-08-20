// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./Owner.sol";

interface IYiBoxNFT1155 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

interface IYiBoxNFT {
    function getTokensByStatus(address _owner, uint256 _status) external view returns (uint256[] memory);
    function setStatus(address _s, uint256 tokenId, uint256 _status) external;
    function tokenBase(uint256 tokenId) external view returns (uint256, uint256,uint256, uint256, uint256);
    function getAllOwners() external view returns (address[] memory _owners);
    function getAllTokens() external view returns (uint256[] memory _tokens);
    function ownerOf(uint256 tokenId) external view returns (address);
    function getLevelsByToken(uint256 _token) external view returns (uint256[] memory, uint256[] memory, uint256[] memory);
    function tokensOfOwner(address owner) external view returns (uint256[] memory);
    //function getHashrateByAddress(address _target) external view returns (uint256);
}

interface IHashratePool {
    function settlementAll() external;
    function getRealHashrate(address target) external view returns (uint256);
}

contract NFTHelpAdv1 is Ownable {
    address public NFTToken;
    address public HashratePool;
    address public mainPool; //主矿池
    address public BoxAddress;  //盒子nft地址

    event eRentHero(uint8 indexed _st);
    event eFarm(uint8 indexed _st);
    event eUnLockBox(uint32 indexed _num);


    function setMainPool(address _token) public onlyOwner {
        mainPool = _token;
    }

    function setBoxAddress(address _token) external onlyOwner {
        BoxAddress = _token;
    }

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

    modifier haveBoxAddress() {
        require(BoxAddress != address(0), 'BoxAddress error');
        _;
    }

    modifier haveMainPool() {
        require(mainPool != address(0), 'mainPool error');
        _;
    }

    function rentHero(uint256 _tokenID) external lock haveNft returns (uint8 _st) {
        (, , , uint256 _status,) = IYiBoxNFT(NFTToken).tokenBase(_tokenID);
        require(_status == 4,"4 status error");
        IYiBoxNFT(NFTToken).setStatus(_msgSender(), _tokenID, 6);
        _st = 6;
        emit eRentHero(_st);
    }

    function unRentHero(uint256 _tokenID) external haveNft returns (uint8 _st) {
        (, , , uint256 _status,) = IYiBoxNFT(NFTToken).tokenBase(_tokenID);
        require(_status == 5 || _status == 6,"6 status error");
        IYiBoxNFT(NFTToken).setStatus(_msgSender(), _tokenID, 4);
        _st = 4;
        emit eRentHero(_st);
    }

    function unLockBox(uint32 _num) external lock haveBoxAddress haveMainPool returns  (uint32 _res) {
        IYiBoxNFT1155(BoxAddress).safeTransferFrom(_msgSender(), mainPool, 1, _num, "");
        IYiBoxNFT1155(BoxAddress).safeTransferFrom(mainPool, _msgSender(), 2, _num, "");
        _res = _num;
        emit eUnLockBox(_num);
    }

    function farm(uint256 _tokenID) external haveNft haveHashpool returns (uint8 _st) {
        (, , , uint256 _status,) = IYiBoxNFT(NFTToken).tokenBase(_tokenID);
        require(_status == 8,"8 status error");
        IYiBoxNFT(NFTToken).setStatus(_msgSender(), _tokenID, 4);
        _st = 4;
        IHashratePool(HashratePool).settlementAll();
        emit eFarm(_st);
    }

    function unfarm(uint256 _tokenID) external haveNft haveHashpool returns (uint8 _st) {
        (, , , uint256 _status,) = IYiBoxNFT(NFTToken).tokenBase(_tokenID);
        require(_status == 4,"4 status error");
        IYiBoxNFT(NFTToken).setStatus(_msgSender(), _tokenID, 8);
        _st = 8;
        IHashratePool(HashratePool).settlementAll();
        emit eFarm(_st);
    }

    function walletTop(uint _top) external view haveNft haveHashpool haveMainPool returns (address[] memory _wal, uint256[] memory _hash) {
        address[] memory allAddress = IYiBoxNFT(NFTToken).getAllOwners();

        _wal = new address[](_top);
        _hash = new uint256[](_top);

        for (uint i = 0; i < allAddress.length; i++) {
            address _tar = allAddress[i];
            if (_tar != mainPool) {
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

     struct NftBase {
        address _ow;
        uint256 _le;
        uint256 _qu;
        uint256 _ha;
        uint256 _st;
        uint256 _ty;
    }

    function HeroTop(uint _top) external view haveMainPool haveNft returns (address[] memory _wal, uint256[] memory _token, uint256[] memory _type, uint256[] memory _level, uint256[] memory _quality, uint256[] memory _hashrate) {
        uint256[] memory allTokens = IYiBoxNFT(NFTToken).getAllTokens();

        NftBase memory _n;
        _wal = new address[](_top);
        _token = new uint256[](_top);
        _type = new uint256[](_top);
        _level = new uint256[](_top);
        _quality = new uint256[](_top);
        _hashrate = new uint256[](_top);

        for (uint i = 0; i < allTokens.length; i++) {
            (_n._ow,_n._le, _n._qu, _n._ha, _n._st, _n._ty,,,) = this.queryBytoken(allTokens[i]);
            if (_n._st == 4 || _n._st == 6 || _n._st == 7) {
                for (uint j = 0; j < _hashrate.length; j++) {
                    if (_n._ha >= _hashrate[j]) {
                        for (uint z = _hashrate.length - 1; z > j; z--) {
                            _hashrate[z] = _hashrate[z - 1];
                            _wal[z] = _wal[z - 1];
                            _token[z] = _token[z - 1];
                            _type[z] = _type[z - 1];
                            _level[z] = _level[z - 1];
                            _quality[z] = _quality[z - 1];
                        }
                        _wal[j] = _n._ow;
                        _hashrate[j] = _n._ha;
                        _token[j] = allTokens[i];
                        _type[j] = _n._ty;
                        _level[j] = _n._le;
                        _quality[j] = _n._qu;
                        break;
                    }
                }
            }
        } 
    }

    function queryBytoken(uint256 _token) external view haveNft returns (address _owner, uint256 _level, uint256 _quality,uint256 _hashrate, uint256 _status, uint256 _type, uint256[] memory _Levels, uint256[] memory _UpTimes, uint256[] memory _HashRates) {
        _owner = IYiBoxNFT(NFTToken).ownerOf(_token);
        (_level, _quality, _hashrate, _status, _type) = IYiBoxNFT(NFTToken).tokenBase(_token);
        (_Levels, _UpTimes, _HashRates) = IYiBoxNFT(NFTToken).getLevelsByToken(_token);
    }

    // function queryAll() external haveNft returns (address[] memory _owner, string[] memory _uri, uint16[] memory _level, uint8[] memory _quality,uint32[] memory _hashrate, uint8[] memory _status, uint16[] memory _type, uint16[][] memory _Levels, uint256[][] memory _UpTimes, uint32[][] memory _HashRates) {
    function queryByOwner(address _inowner) external view haveNft returns (address[] memory _outowner, uint256[] memory _level, uint256[] memory _quality,uint256[] memory _hashrate, uint256[] memory _status, uint256[] memory _type) {    
        // uint256[] memory allTokens = IYiBoxNFT(NFTToken).getAllTokens();
        uint256[] memory allTokens;
        if (_inowner == address(0)) {
            allTokens = IYiBoxNFT(NFTToken).getAllTokens();
        } else {
            allTokens = IYiBoxNFT(NFTToken).tokensOfOwner(_inowner);
        }
        uint256 _size = allTokens.length;
        require(_size > 0, "none tokens");
        _outowner = new address[](_size);
        // _uri = new string[](_size);
        _level = new uint256[](_size);
        _quality = new uint256[](_size);
        _hashrate = new uint256[](_size);
        _status = new uint256[](_size);
        _type = new uint256[](_size);
        // _Levels = new uint16[][](_size);
        // _UpTimes = new uint256[][](_size);
        // _HashRates = new uint32[][](_size);
        for (uint i = 0; i < _size; i++) {
            // (_owner[i],_uri[i],_level[i],_quality[i],_hashrate[i],_status[i],_type[i],_Levels[i],_UpTimes[i],_HashRates[i]) = this.queryBytoken(allTokens[i]);
            (_outowner[i],_level[i],_quality[i],_hashrate[i],_status[i],_type[i],,,) = this.queryBytoken(allTokens[i]);
        }
    }

    // function queryByOwners(address[] memory _inowner) external view returns (address[] memory _outowner, uint16[] memory _level, uint8[] memory _quality,uint32[] memory _hashrate, uint8[] memory _status, uint16[] memory _type) {
    //     for (uint i = 0; i < _inowner.length; i++) {
    //         (address[] memory _outowner1, uint16[] memory _level1, uint8[] memory _quality1,uint32[] memory _hashrate1, uint8[] memory _status1, uint16[] memory _type1) = this.queryByOwner(_inowner[i]);
    //     }
    // }
}