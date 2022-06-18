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
    address OfficialAddress;
    address PromoteAddress;
    address funder;

    uint256 public constant NFT_TotalSupply = 87600;

    uint256 public NFT_Id = 0;
    uint256 public UserMintNFT_Id = 87600;
    uint256[] public nftPowerPrice = [500, 1000, 2000, 4000, 8000];

    bool airdropSwitch = true;
    bool paused = false;

    IERC20 public usdt;

    mapping(uint256 => starAttributesStruct) public starAttributes;
    mapping(uint256 => Bidder) public bidder;
    mapping(string => bool) public isSold;
    mapping(address => bool) public devOwner;

    uint256 biddersTime = 1; // Bidding time

    event PreMint(address indexed origin, address indexed owner, string iphshash, uint256 power, uint256 TokenId);
    event OfficialMint(address indexed origin, address indexed owner, string iphshash, uint256 power, uint256 TokenId, uint256 ERAprice);
    event UserMint(address indexed origin, uint256 indexed price, string iphshash, uint256 power, uint256 TokenId);

    event NftTransfer(address indexed from, address to, uint256 tokenid);

    // Maximum amount of auction
    event auction(address addr, uint amount, uint vamId);

    struct starAttributesStruct {
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

    function trunOffairdrop() public {
        require(contractOwner == msg.sender);
        airdropSwitch = false;
    }

    function setErc20(IERC20 _usdt) public {
        require(contractOwner == msg.sender);
        usdt = _usdt;
    }

    function setOfficeAddress(address _OfficialAddress, address _PromoteAddress, address _funder) public {
        require(contractOwner == msg.sender);
        OfficialAddress = _OfficialAddress;
        PromoteAddress = _PromoteAddress;
        funder = _funder;
    }

    function airdrop(uint256[] memory _id, string[] memory _hash, uint256[] memory _power, address[] memory _to, address[] memory _origin) public {
        require(contractOwner == msg.sender);
        require(_id.length == _hash.length
        && _power.length == _to.length
        && _hash.length == _power.length
            && _to.length == _origin.length);
        require(airdropSwitch, "air drop not allow");
        for (uint256 i = 0; i < _id.length; i++) {
            require(NFT_Id == _id[i], "not in order");
            starAttributes[NFT_Id].origin = _origin[i];
            starAttributes[NFT_Id].IphsHash = _hash[i];
            starAttributes[NFT_Id].power = _power[i];
            starAttributes[NFT_Id].price = nftPowerPrice[0];
            starAttributes[NFT_Id].stampFee = 0;
            starAttributes[NFT_Id].official = true;
            starAttributes[NFT_Id].is_sale = true;
            _mint(_to[i], NFT_Id);
            NFT_Id++;
        }
    }

    function transfer(address to, uint256 tokenId) external payable returns (bool) {
        require(starAttributes[tokenId].is_sale == false, 'on sold');
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
            starAttributes[NFT_Id].origin = origin;
            starAttributes[NFT_Id].IphsHash = ipfsHash;
            starAttributes[NFT_Id].power = power;
            starAttributes[NFT_Id].price = nftPowerPrice[0];
            starAttributes[NFT_Id].stampFee = stampFee;
            starAttributes[NFT_Id].official = isOfficial;
            starAttributes[NFT_Id].is_sale = true;
            _mint(to, NFT_Id);
        } else {
            UserMintNFT_Id++;
            starAttributes[UserMintNFT_Id].origin = origin;
            starAttributes[UserMintNFT_Id].IphsHash = ipfsHash;
            starAttributes[UserMintNFT_Id].power = power;
            starAttributes[UserMintNFT_Id].price = price;
            starAttributes[UserMintNFT_Id].stampFee = stampFee;
            starAttributes[UserMintNFT_Id].official = isOfficial;
            starAttributes[UserMintNFT_Id].is_sale = true;
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

    function officialMint(string memory _hash, uint256 _power, uint256 price) public returns (uint256){//官方创建
        require(devOwner[msg.sender] == true, ' not owner');
        require(isSold[_hash] == false, "minted");
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
        starAttributes[tokenId].power = power;
        starAttributes[tokenId].price = nftPowerPrice[power - 1];
        return true;
    }

    function takeOwnership(address _address, bool _Is) public {
        devOwner[_address] = _Is;
    }

    function getWeight(address user) public view returns (uint256){
        uint256 len = ownerTokens[user].length;
        uint256 weight = 0;
        uint256[] storage tokens = ownerTokens[user];
        for (uint256 i = 0; i < len; i++) {
            uint256 tokenId = tokens[i];
            weight += starAttributes[tokenId].power;
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
        require(starAttributes[_nftId].power > 0, 'error power');
        require(starAttributes[_nftId].origin == msg.sender, 'not nft owner');
        require(starAttributes[_nftId].is_sale == true, 'on sold');
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
        starAttributes[_nftId].is_sale = false;

    }

    // Start Bidders auction
    function Bidders(uint256 money, uint256 _nftId) public {
        require(block.timestamp > biddersTime + bidder[_nftId].startTime, 'TO FAST');
        require(starAttributes[_nftId].is_sale == false, 'Already sold');
        bidder[_nftId].startTime = block.timestamp;
        if (bidder[_nftId].is_fixed == true) {
            //判断余额
            require(usdt.balanceOf(msg.sender) >= bidder[_nftId].moneys[0].mul(1e18), 'BALANCE NOT ENOUGH');
            usdt.transferFrom(msg.sender, starAttributes[_nftId].origin, bidder[_nftId].moneys[0].mul(1e18));
            ERC721.approvalForAlls[starAttributes[_nftId].origin][msg.sender] = true;
            _transferFrom(starAttributes[_nftId].origin, msg.sender, _nftId);
            ERC721.approvalForAlls[starAttributes[_nftId].origin][msg.sender] = false;
            starAttributes[_nftId].origin = msg.sender;
            starAttributes[_nftId].is_sale = true;
            bidder[_nftId].addrs[0] = msg.sender;
            bidder[_nftId].grant = true;
            emit auction(msg.sender, money, _nftId);
            emit NftTransfer(starAttributes[_nftId].origin, bidder[_nftId].addrs[0], _nftId);
        } else {
            require(money > bidder[_nftId].money, 'MONEY NOT ENOUGH');
            require(money > bidder[_nftId].moneys[bidder[_nftId].moneys.length.sub(1)], 'PASS MONGH');
            require(usdt.balanceOf(msg.sender) >= money.mul(1e18), 'BALANCE NOT ENOUGH');
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

    // end auction
    function endBidders(uint256 _nftId) public {
        require(starAttributes[_nftId].origin == msg.sender, ' not nft owner');
        if (block.timestamp > biddersTime + bidder[_nftId].startTime &&
        bidder[_nftId].grant == false && starAttributes[_nftId].is_sale == false) {
            _transferFrom(starAttributes[_nftId].origin, bidder[_nftId].addrs[0], _nftId);
            starAttributes[_nftId].origin = bidder[_nftId].addrs[0];
            starAttributes[_nftId].is_sale = true;
            bidder[_nftId].grant = true;
            emit NftTransfer(starAttributes[_nftId].origin, bidder[_nftId].addrs[0], _nftId);

        }
    }


}