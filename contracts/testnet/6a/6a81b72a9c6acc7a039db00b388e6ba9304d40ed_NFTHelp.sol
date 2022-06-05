// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

interface IYiBoxNFT {
    function getHashrateByAddress(address _target) external view returns (uint256);
    function getTokensByStatus(address _owner, uint8 _status) external view returns (uint256[] memory);
    function setStatus(address _s, uint256 tokenId, uint8 _status) external;
    function tokenBase(uint256 tokenId) external view returns (string memory, uint16, uint8 ,uint32, uint8, uint256, uint16);
    // function setPrice(address _owner, uint256 _tokens, uint256 _price) external;
    function ownerOf(uint256 tokenId) external returns (address);
    function transferFromInternal(address from, address to, uint256 tokenId) external;
    function getLevelsByToken(uint256 _token) external returns (uint16[] memory, uint256[] memory, uint32[] memory);
    function getAllOwners() external returns (address[] memory _owners);
    function getAllTokens() external  returns (uint256[] memory _tokens);
}

interface IYiBoxSetting {
    function getIncomePool() external returns (address);
    function getrepoPool() external returns (address);
    function getIncomePer() external returns (uint32);
    function getRepoPer() external returns (uint32);
    function getHashrate(uint q, uint com, uint r) external returns (uint[] memory, uint[] memory);
}

interface IHashratePool {
    function settlementAll() external;
}

interface IBUSD {
    function balanceOf(address account) external returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

import "./Owner.sol";

contract NFTHelp is Ownable {
    address public NFTToken;
    address public HashratePool;
    address public payToken;            //支付 币种， 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7  busd
    address public YiSetting;

    mapping(uint256 => uint256[]) internal sellGroups;
    mapping(uint256 => uint256) internal sellPrices;
    uint256[] internal sellidx;
    uint256 GroupIdx = 1;

    constructor() public {
        payToken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    }

    function setSetting(address _setting) public onlyOwner {
        YiSetting = _setting;
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

    modifier haveBUSD() {
        require(payToken != address(0), 'payToken error');
        _;
    }

    modifier haveSetting() {
        require(YiSetting != address(0), 'YiSetting error');
        _;
    }

    

    function sellBox(uint256 _num, uint256 _price) external lock haveNft returns(uint256 _groupID) {
        require(_num <= 10,"unlockBox error");
        uint256[] memory _tokens = IYiBoxNFT(NFTToken).getTokensByStatus(_msgSender(), 1);
        require(_num <= _tokens.length,"Not enough nft");

        uint256[] memory _tks = new uint256[](_num);
        for (uint i = 0; i < _num; i++) {
            IYiBoxNFT(NFTToken).setStatus(_msgSender(), _tokens[i], 2);
            // IYiBoxNFT(NFTToken).setPrice(_msgSender(), _tokens[i], _price);
            _tks[i] = _tokens[i];
        }
        sellGroups[GroupIdx] = _tks;
        sellPrices[GroupIdx] = _price;
        sellidx.push(GroupIdx);
        _groupID = GroupIdx;
    }

    

    function tradeNFT(uint256 _GroupID) external lock haveNft haveHashpool haveBUSD haveSetting {
        require(sellGroups[_GroupID].length > 0, "GroupID error");
        for(uint i = 0; i < sellGroups[_GroupID].length; i++) {
            (, , , , uint8 _status,,) = IYiBoxNFT(NFTToken).tokenBase(sellGroups[_GroupID][i]);
            require(_status == 5 || _status == 2,"sell status error");
        }
        address _seller = IYiBoxNFT(NFTToken).ownerOf(sellGroups[_GroupID][0]);
        require(_seller != _msgSender(), "Can't Buy Self");
        require(sellPrices[_GroupID] > 0, "can't sell");
        uint256 _price = sellPrices[_GroupID];
        uint256 _balance = IBUSD(payToken).balanceOf(_msgSender());
        require(_balance >= _price,"Insufficient balance");

        uint256 _incomeFee = _price * IYiBoxSetting(YiSetting).getIncomePer() / 10000;
        uint256 _repoFee =  _price * IYiBoxSetting(YiSetting).getRepoPer() / 10000;
        require((_incomeFee + _repoFee) < _price, "fee error");
        IBUSD(payToken).transferFrom(_msgSender(), address(this), _price);

        IBUSD(payToken).transfer(IYiBoxSetting(YiSetting).getIncomePool(), _incomeFee);
        IBUSD(payToken).transfer(IYiBoxSetting(YiSetting).getrepoPool(), _repoFee);
        uint256 _result = _price - _incomeFee - _repoFee;
        bool res = IBUSD(payToken).transfer(_seller, _result);
        if (res) {
            IHashratePool(HashratePool).settlementAll();

            for (uint i = 0; i < sellGroups[_GroupID].length; i++) {
                uint256 _tarToken = sellGroups[_GroupID][i];
                (, , , , uint8 _status,,) = IYiBoxNFT(NFTToken).tokenBase(_tarToken);
                    if (_status == 2) {
                    IYiBoxNFT(NFTToken).setStatus(_msgSender(), _tarToken, 1);
                }
                
                if (_status == 5) {
                    IYiBoxNFT(NFTToken).setStatus(_msgSender(), _tarToken, 4);
                }
                IYiBoxNFT(NFTToken).transferFromInternal(_seller, _msgSender(), _tarToken);
            }
            removeByGroupID(_GroupID);
        }
    }

    function sellHero(uint256[] memory _tokens, uint256 _price) public lock haveNft haveHashpool returns(uint256 _groupID) {
        // require(NFTToken != address(0),"NFTToken error");

        IHashratePool(HashratePool).settlementAll();

        for (uint i = 0; i < _tokens.length; i++) {
            (, , , , uint8 _status,,) = IYiBoxNFT(NFTToken).tokenBase(_tokens[i]);
            require(_status == 4,"4 status error");
            require(IYiBoxNFT(NFTToken).ownerOf(_tokens[i]) == _msgSender(), "hero not yours");
        }

        uint256[] memory _tks = new uint256[](_tokens.length);
        for (uint i = 0; i < _tokens.length; i++) {
            IYiBoxNFT(NFTToken).setStatus(_msgSender(), _tokens[i], 5);
            _tks[i] = _tokens[i];
        }
        sellGroups[GroupIdx] = _tks;
        sellPrices[GroupIdx] = _price;
        sellidx.push(GroupIdx);
        _groupID = GroupIdx;
    }

    function removeByGroupID(uint256 _GroupID) internal {
        delete sellGroups[_GroupID];
        delete sellPrices[_GroupID];

        for (uint i = 0; i < sellidx.length; i++) {
            if (sellidx[i] == _GroupID) {
                if (i == sellidx.length - 1) {
                    delete sellidx[i];
                    sellidx.pop();
                } else {
                    for (uint ii = i; ii < sellidx.length-1; ii++) {
                        sellidx[ii] = sellidx[ii+1];
                    }
                    delete sellidx[sellidx.length-1];
                    sellidx.pop();
                }

                break;
            }
        }
    }

    function unSell(uint256 _GroupID) external lock haveNft haveHashpool {
        IHashratePool(HashratePool).settlementAll();
        require(sellGroups[_GroupID].length > 0, "GroupID error");
        for (uint i = 0; i < sellGroups[_GroupID].length; i++) {
            (, , , , uint8 _status,,) = IYiBoxNFT(NFTToken).tokenBase(sellGroups[_GroupID][i]);
            require(_status == 5 || _status == 2,"sell status error");
        }

        for (uint i = 0; i < sellGroups[_GroupID].length; i++) {
            (, , , , uint8 _status,,) = IYiBoxNFT(NFTToken).tokenBase(sellGroups[_GroupID][i]);
            if (_status == 2) {
                IYiBoxNFT(NFTToken).setStatus(_msgSender(), sellGroups[_GroupID][i], 1);
            }
            
            if (_status == 5) {
                IYiBoxNFT(NFTToken).setStatus(_msgSender(), sellGroups[_GroupID][i], 4);
            }
        }
        removeByGroupID(_GroupID);
    }

    

    function queryBytoken(uint256 _token) external haveNft returns (address _owner, string memory _uri, uint16 _level, uint8 _quality,uint32 _hashrate, uint8 _status, uint16 _type, uint16[] memory _Levels, uint256[] memory _UpTimes, uint32[] memory _HashRates) {
        _owner = IYiBoxNFT(NFTToken).ownerOf(_token);
        (_uri, _level, _quality, _hashrate, _status, , _type) = IYiBoxNFT(NFTToken).tokenBase(_token);
        (_Levels, _UpTimes, _HashRates) = IYiBoxNFT(NFTToken).getLevelsByToken(_token);
    }

    // function queryAll() external haveNft returns (address[] memory _owner, string[] memory _uri, uint16[] memory _level, uint8[] memory _quality,uint32[] memory _hashrate, uint8[] memory _status, uint16[] memory _type, uint16[][] memory _Levels, uint256[][] memory _UpTimes, uint32[][] memory _HashRates) {
    function queryAll() external haveNft returns (address[] memory _owner, uint16[] memory _level, uint8[] memory _quality,uint32[] memory _hashrate, uint8[] memory _status, uint16[] memory _type) {    
        uint256[] memory allTokens = IYiBoxNFT(NFTToken).getAllTokens();
        uint256 _size = allTokens.length;
        _owner = new address[](_size);
        // _uri = new string[](_size);
        _level = new uint16[](_size);
        _quality = new uint8[](_size);
        _hashrate = new uint32[](_size);
        _status = new uint8[](_size);
        _type = new uint16[](_size);
        // _Levels = new uint16[][](_size);
        // _UpTimes = new uint256[][](_size);
        // _HashRates = new uint32[][](_size);
        for (uint i = 0; i < _size; i++) {
            // (_owner[i],_uri[i],_level[i],_quality[i],_hashrate[i],_status[i],_type[i],_Levels[i],_UpTimes[i],_HashRates[i]) = this.queryBytoken(allTokens[i]);
            (_owner[i],,_level[i],_quality[i],_hashrate[i],_status[i],_type[i],,,) = this.queryBytoken(allTokens[i]);
        }
            
    }

    function walletTop(uint _top) external haveNft returns (address[] memory _wal, uint256[] memory _hash) {
        address[] memory allAddress = IYiBoxNFT(NFTToken).getAllOwners();

        _wal = new address[](_top);
        _hash = new uint256[](_top);

        for (uint i = 0; i < allAddress.length; i++) {
            address _tar = allAddress[i];
            uint256 _h = IYiBoxNFT(NFTToken).getHashrateByAddress(_tar);
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

    struct NftBase {
        address _ow;
        uint16 _le;
        uint8 _qu;
        uint32 _ha;
        uint8 _st;
        uint16 _ty;
    }

    function HeroTop(uint _top) external haveNft returns (address[] memory _wal, uint256[] memory _token, uint16[] memory _type, uint16[] memory _level, uint8[] memory _quality, uint32[] memory _hashrate) {
        uint256[] memory allTokens = IYiBoxNFT(NFTToken).getAllTokens();

        NftBase memory _n;
        _wal = new address[](_top);
        _token = new uint256[](_top);
        _type = new uint16[](_top);
        _level = new uint16[](_top);
        _quality = new uint8[](_top);
        _hashrate = new uint32[](_top);

        for (uint i = 0; i < allTokens.length; i++) {
            (_n._ow,,_n._le, _n._qu, _n._ha, _n._st, _n._ty,,,) = this.queryBytoken(allTokens[i]);
            if (_n._st == 4 ||
                _n._st == 6 ||
                _n._st == 7) {
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
}