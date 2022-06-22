//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./ERC721.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./String.sol";
import "./Util.sol";
import "./SafeERC20.sol";

interface IPromote {
    function update(uint256 amount) external;
}

contract MUMUNFT is ERC721 {
    address public contractOwner;

    using String for string;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address funder;

    uint256 public constant NFT_TotalSupply = 100000;

    uint256 public NFT_Id = 0;
    uint256 public UserMintNFT_Id = 100000;
    uint256[] public nftPowerPrice = [10, 50, 200, 500, 1000];

    bool airdropSwitch = true;
    bool paused = false;

    IERC20 public usdt;

    mapping(uint256 => mumuStruct) public mumu;
    mapping(uint256 => Bidder) public bidder;
    mapping(string => bool) public isSold;
    mapping(address => bool) public devOwner;

    uint256 biddersTime = 1; // Bidding time

    event PreMint(address indexed origin, address indexed owner, string iphshash, uint256 power, uint256 TokenId);
    event OfficialMint(address indexed origin, address indexed owner, string iphshash, uint256 power, uint256 TokenId, uint256 price);
    event UserMint(address indexed origin, uint256 indexed price, string iphshash, uint256 power, uint256 TokenId);

    event NftTransfer(address indexed from, address to, uint256 tokenid);

    // Maximum amount of auction
    event auction(address addr, uint amount, uint vamId);

    struct mumuStruct {
        address origin;   //发布者
        string IphsHash; //hash
        uint256 power; //nft等级
        uint256 price;   //价格
        uint256 stampFee;  //版税
        bool official;
        bool is_sale;
    }

    // auction 下一个出价的  然后把前一个出价的钱退回到原来的地址
    struct Bidder {
        address [] addrs;
        uint256 [] moneys;
        uint256 money;
        uint256 startTime;
        bool grant;
        bool is_fixed; //是否一口价
        bool is_first; //是否是第一次出价
    }

    constructor(IERC20 _usdt) ERC721("MUMU NFT", "MUMU") {
        contractOwner = msg.sender;
        usdt = _usdt;
    }

    modifier onlyDev() {
        require(contractOwner == msg.sender, "only dev");
        _;
    }

    function turnoffFairDrop() public {
        require(contractOwner == msg.sender);
        airdropSwitch = false;
    }

    function turnOnDrop() public {
        require(contractOwner == msg.sender);
        airdropSwitch = true;
    }

    function setErc20(IERC20 _usdt) public {
        require(contractOwner == msg.sender);
        usdt = _usdt;
    }

    function setOfficeAddress(address _funder) public {
        require(contractOwner == msg.sender);
        funder = _funder;
    }

    //设置nft盲盒价格
    function setNFTPrices(uint256[] memory _prices) public {
        require(contractOwner == msg.sender);
        nftPowerPrice = _prices;
    }

    //设置盲盒概率
    function setNFTRate(uint256[][] memory _rate) public {
        require(contractOwner == msg.sender);
        nftPowerRate = _rate;
    }

    function airdrop(uint256[] memory _id, string[] memory _hash, uint256[] memory _power, address[] memory _to, address[] memory _origin) public {
        require(contractOwner == msg.sender);
        require(_id.length == _hash.length && _power.length == _to.length
            && _hash.length == _power.length
            && _to.length == _origin.length
        );
        require(airdropSwitch, "air drop not allow");
        for (uint256 i = 0; i < _id.length; i++) {
            require(NFT_Id == _id[i], "not in order");
            mumu[NFT_Id].origin = _origin[i];
            mumu[NFT_Id].IphsHash = _hash[i];
            mumu[NFT_Id].power = _power[i];
            mumu[NFT_Id].price = nftPowerPrice[_power[i] - 1];
            mumu[NFT_Id].stampFee = 0;
            mumu[NFT_Id].official = true;
            mumu[NFT_Id].is_sale = true;
            _mint(_to[i], NFT_Id);
            NFT_Id++;
        }
    }

    function transfer(address to, uint256 tokenId) external payable returns (bool) {
        require(mumu[tokenId].is_sale == false, 'on sold');
        _transferFrom(msg.sender, to, tokenId);
        emit NftTransfer(msg.sender, to, tokenId);
        return true;
    }

    function pauseOfficialMint(bool _switch) public {
        require(contractOwner == msg.sender);
        paused = _switch;
    }

    function mintInternal(address origin, address to, string  memory ipfsHash, uint256 power, uint256 price, uint256 stampFee, bool isOfficial) internal {
        if (isOfficial) {
            NFT_Id++;
            require(NFT_Id <= NFT_TotalSupply, "Already Max");
            mumu[NFT_Id].origin = origin;
            mumu[NFT_Id].IphsHash = ipfsHash;
            mumu[NFT_Id].power = power;
            mumu[NFT_Id].price = price;
            mumu[NFT_Id].stampFee = stampFee;
            mumu[NFT_Id].official = isOfficial;
            mumu[NFT_Id].is_sale = true;
            _mint(to, NFT_Id);
        } else {
            mumu[UserMintNFT_Id].origin = origin;
            mumu[UserMintNFT_Id].IphsHash = ipfsHash;
            mumu[UserMintNFT_Id].power = power;
            mumu[UserMintNFT_Id].price = price;
            mumu[UserMintNFT_Id].stampFee = stampFee;
            mumu[UserMintNFT_Id].official = isOfficial;
            mumu[UserMintNFT_Id].is_sale = true;
            _mint(to, UserMintNFT_Id);
        }
        isSold[ipfsHash] = true;
    }

    function burn(uint256 Id) external {
        address owner = tokenOwners[Id];
        require(msg.sender == owner
        || msg.sender == tokenApprovals[Id]
            || approvalForAlls[owner][msg.sender],
            "msg.sender must be owner or approved");

        _burn(Id);
    }

    function tokenURI(uint256 NftId) external view override returns (string memory) {
        bytes memory bs = abi.encodePacked(NftId);
        return uriPrefix.concat("nft/").concat(Util.base64Encode(bs));
    }

    function setUriPrefix(string memory prefix) external {
        require(contractOwner == msg.sender);
        uriPrefix = prefix;
    }

    function officialMint(string memory _hash, uint256 _power, uint256 price) public returns (uint256){
        //官方创建
        require(devOwner[msg.sender] == true, ' not owner');
        require(isSold[_hash] == false, "already minted");
        require(paused == false, "official mint is paused");
        require(_power > 0 && _power <= 5, "Out of range!");
        address user = msg.sender;
        uint256 NFTprice = price * 1e18;
        uint256 needPay = NFTprice;
        mintInternal(user, user, _hash, _power, 0, 0, true);

        emit OfficialMint(user, user, _hash, 1, NFT_Id, needPay);
        return NFT_Id;
    }

    function changePower(uint256 tokenId, uint256 power) external returns (bool){
        require(contractOwner == msg.sender);
        require(power > 1 && power <= 5, "Out of range!");
        mumu[tokenId].power = power;
        mumu[tokenId].price = nftPowerPrice[power - 1];
        return true;
    }

    function takeOwnership(address _address, bool _Is) public {
        require(contractOwner == msg.sender);
        devOwner[_address] = _Is;
    }

    function getWeight(address user) public view returns (uint256){
        uint256 len = ownerTokens[user].length;
        uint256 weight = 0;
        uint256[] storage tokens = ownerTokens[user];
        for (uint256 i = 0; i < len; i++) {
            uint256 tokenId = tokens[i];
            weight += mumu[tokenId].power;
        }
        return weight;
    }


    function withdrawFunds(IERC20 token, uint256 amount) public returns (bool){
        require(contractOwner == msg.sender);
        if (amount >= token.balanceOf(address(this))) {
            amount = token.balanceOf(address(this));
        }
        token.transfer(funder, amount);
        return true;
    }

    // Start auction
    function startBidders(uint256 money, uint256 limit_price, uint256 _nftId, bool _is_fixed) public {
        require(mumu[_nftId].power > 0, 'error power');
        require(mumu[_nftId].origin == msg.sender, 'not nft owner');
        require(mumu[_nftId].is_sale == true, 'on sold');
        address[] memory addrs;
        uint256[] memory moneys;
        addrs = new address[](1);
        moneys = new uint256[](1);
        addrs[0] = msg.sender;
        moneys[0] = money;
        bidder[_nftId].addrs = addrs;
        bidder[_nftId].moneys = moneys;
        bidder[_nftId].money = limit_price;
        bidder[_nftId].startTime = block.timestamp;
        bidder[_nftId].grant = false;
        bidder[_nftId].is_fixed = _is_fixed;
        bidder[_nftId].is_first = true;
        mumu[_nftId].is_sale = false;

    }

    // Start Bidders auction
    function Bidders(uint256 money, uint256 _nftId) public {
        require(mumu[_nftId].origin != msg.sender, 'Can`t buy own nft');
        require(block.timestamp > biddersTime + bidder[_nftId].startTime, 'TO FAST');
        require(mumu[_nftId].is_sale == false, 'Already sold');
        bidder[_nftId].startTime = block.timestamp;
        if (bidder[_nftId].is_fixed == true) {
            //一口价
            //判断余额
            require(usdt.balanceOf(msg.sender) >= bidder[_nftId].moneys[0].mul(1e18), 'BALANCE NOT ENOUGH');
            usdt.transferFrom(msg.sender, mumu[_nftId].origin, bidder[_nftId].moneys[0].mul(1e18));
            ERC721.approvalForAlls[mumu[_nftId].origin][msg.sender] = true;
            _transferFrom(mumu[_nftId].origin, msg.sender, _nftId);
            ERC721.approvalForAlls[mumu[_nftId].origin][msg.sender] = false;
            mumu[_nftId].origin = msg.sender;
            mumu[_nftId].is_sale = true;
            bidder[_nftId].addrs[0] = msg.sender;
            bidder[_nftId].grant = true;
            emit auction(msg.sender, money, _nftId);
            emit NftTransfer(mumu[_nftId].origin, bidder[_nftId].addrs[0], _nftId);
        } else {
            require(money > bidder[_nftId].money, 'The bid amount is less than the nft listing price');
            require(money > bidder[_nftId].moneys[bidder[_nftId].moneys.length.sub(1)], 'Bid amount must be greater than others bid amount');
            require(usdt.balanceOf(msg.sender) >= money.mul(1e18), 'Insufficient transfer amount required');
            usdt.transferFrom(msg.sender, address(this), money.mul(1e18));
            if (!bidder[_nftId].is_first) {
                usdt.transfer(bidder[_nftId].addrs[0], bidder[_nftId].moneys[0].mul(1e18));
            }
            bidder[_nftId].is_first = false;
            bidder[_nftId].addrs[0] = msg.sender;
            bidder[_nftId].moneys[0] = money;
            emit auction(msg.sender, money, _nftId);
        }
        // Refund of user auction fee
    }
    //盲盒概率
    uint256[][] public nftPowerRate = [
        [900,100,0,0,0],
        [0,900,100,0,0],
        [0,0,900,100,0],
        [0,0,0,900,100],
        [0,0,0,600,400]
    ];

    event UserMint(address indexed origin, address indexed owner, string iphshash, uint256 power, uint256 TokenId, uint256 random);

    function mint(string memory _hash, uint256 _boxType) public returns (uint256){
        //开盲盒
        require(isSold[_hash] == false, "already minted");
        require(paused == false, "official mint is paused");
        require(usdt.balanceOf(msg.sender) >= nftPowerPrice[_boxType - 1].mul(1e18), 'BALANCE NOT ENOUGH');
        usdt.transferFrom(msg.sender, address(this), nftPowerPrice[_boxType - 1].mul(1e18));
        uint index = random() % 1000;
        if(index == 0){
            index = index + 1;
        }
        uint256[] memory rate = nftPowerRate[_boxType - 1];
        uint256 _power;
        if(index <= rate[4]){
            _power = 5;
        }else if(index <= rate[3]){
            _power = 4;
        }else if(index <= rate[2]){
            _power = 3;
        }else if(index <= rate[1]){
            _power = 2;
        }else if(index <= rate[0]){
            _power = 1;
        }
        mintInternal(msg.sender, msg.sender, _hash, _power, 0, 0, false);
        emit UserMint(msg.sender, msg.sender, _hash, _power, NFT_Id, index);
        return NFT_Id;
    }


    function random() private view returns (uint) {
        // sha3 and now have been deprecated
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        // convert hash to integer
        // players is an array of entrants

    }

    // end auction
    function endBidders(uint256 _nftId) public {
        require(mumu[_nftId].origin == msg.sender, ' not nft owner');
        if (block.timestamp > biddersTime + bidder[_nftId].startTime &&
        bidder[_nftId].grant == false && mumu[_nftId].is_sale == false) {
            usdt.transfer(mumu[_nftId].origin, bidder[_nftId].moneys[0].mul(1e18));
            _transferFrom(mumu[_nftId].origin, bidder[_nftId].addrs[0], _nftId);
            mumu[_nftId].origin = bidder[_nftId].addrs[0];
            mumu[_nftId].is_sale = true;
            bidder[_nftId].grant = true;
            emit NftTransfer(mumu[_nftId].origin, bidder[_nftId].addrs[0], _nftId);

        }
    }


}