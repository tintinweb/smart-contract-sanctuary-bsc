//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../Utils/ERC721.sol";
import "../Utils/IERC20.sol";
import "../Utils/SafeMath.sol";
import "../Utils/String.sol";
import "../Utils/Util.sol";
import "../Utils/SafeERC20.sol";
import "../Manager/Member.sol";

interface IMarket{
    function createOrder(uint256 tokenid, uint256 tradeAmount) external;
}

interface IPromote{
    function update(uint256 amount) external;
}

interface ISuperPirate{
    function update(uint256 amount) external;
}

interface ITokenStake{
    function update(uint256 amount) external;
}

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

interface IRandom {
    function random(uint256 randomStart, uint256 randomEnd,uint256 randomLen) external returns(uint[] memory);
}

contract MechaMasterNFT is ERC721, Member {
    using String for string;
	using SafeERC20 for IERC20;
	using SafeMath for uint256;
    using String for uint256;
    
    uint256 public NFT_Id = 0; // 預售 NFT 編號從 0 開始
    uint256 public preStart; // 预售开始时间
    bool paused = false;
    uint256 public constant PRE_TOTAL = 2000;
    uint256 public preCount;
    uint256 public onceMax;
    uint256 public onceCount;
    uint256 public userMintStart;
    uint256 public userMintStartMax = 1 days; // 公開鑄造產量更新時間1天
    uint256 public userMintCount;
    uint256 public userMintCountMax = 150; // 公開鑄造釋放150個盲盒

    IERC20 public usdt;
    IERC20 public mca;
    IUniswapV2Pair public pair;

    struct starAttributesStruct{
      address origin; // 发布者
      uint256 power; // 算力
      bool offical;
      uint256 createTime; // 鑄造時間
      uint256 openTime; // 開盒時間
      string IpfsHash; // hash
      uint256 level; // 無限等級
      uint256 ethnicity; // 種族類型
    }

    mapping(uint256 => starAttributesStruct) public starAttributes;
    mapping(address => bool) public preBuy;
    mapping(address => bool) public whiteList;
    mapping(uint256 => uint256) public ethnicityCount; // 種族NFT數量

    event PreMint(address indexed origin, address indexed owner,uint256 power, uint256 TokenId);
    event UserMint(address indexed origin, address indexed owner,uint256 power, uint256 TokenId, uint256 MCAprice);
    event NftTransfer(address indexed from, address to, uint256 tokenid);
    event OpenBlindBox(address indexed origin, uint256 tokenId, string ipfshash, uint256 power, uint256 ethnicity, uint256 level);
    event UpdateNFT(address indexed origin, uint256 tokenId1, uint256 tokenId2, uint256 newLevel, uint256 newPower);
 
    constructor(IERC20 _usdt, IERC20 _mca, IUniswapV2Pair _pair)
        ERC721("MP NFT", "MP") {
            usdt = _usdt;
            mca = _mca;
            pair = _pair;
    }

    modifier onlyDev() {
        require(manager.members("dev") == msg.sender, "only dev");
        _;
    }

    modifier onlyWhiteList() {
        require(whiteList[msg.sender], "Only white list");
        _;
    }

    function preOfficalStart(uint256 start, uint256 num) public {
        require(msg.sender == manager.members("owner"), "only owner");
        require(num <= PRE_TOTAL - preCount, "num is valid");
        preStart = start;
        onceMax = num;
        onceCount = 0;
    }

    function transfer(address to,uint256 tokenId) external payable returns(bool) {
        _transferFrom(msg.sender, to, tokenId);
        emit NftTransfer(msg.sender, to, tokenId);
        return true;
    }

    function pauseOfficalMint(bool _switch) public{
        require(msg.sender == address(manager.members("owner")), "only owner");
        paused = _switch;
    }

    function checkSig(string memory _hash, bytes32 _r, bytes32 _s, uint8 _v, bytes32 _challenge) view internal {
        bytes  memory salt=abi.encodePacked(_hash, _challenge);
        bytes  memory Message=abi.encodePacked(
                    "\x19Ethereum Signed Message:\n",
                    "64",
                    salt
                );
        bytes32 digest = keccak256(Message);
        address signer=ecrecover(digest, _v, _r, _s);
        require(signer != address(0), "signer: address 0");
        require(signer == manager.members("relayer"), "invalid signature");
    }
    
    function _mintinternal(address origin, address to, bool isOffcial) internal {
        NFT_Id++;
        starAttributes[NFT_Id].origin = origin;
        starAttributes[NFT_Id].power = 10;
        starAttributes[NFT_Id].offical = isOffcial;
        starAttributes[NFT_Id].createTime = block.timestamp;
        _mint(to, NFT_Id);
    }
    
    function burn(uint256 Id) external {
        address owner = tokenOwners[Id];
        require(msg.sender == owner
            || msg.sender == tokenApprovals[Id]
            || approvalForAlls[owner][msg.sender],
            "msg.sender must be owner or approved");
        _burn(Id);
    }
    
    function tokenURI(uint256 NftId) external view override returns(string memory) {
        return uriPrefix.concat(starAttributes[NftId].IpfsHash);
    }

    function getStarAttributes(uint256 tokenId) external view returns (starAttributesStruct memory) {
        return starAttributes[tokenId];
    }

    function setUriPrefix(string memory prefix) external {
        require(msg.sender == manager.members("owner"), "only owner");
        uriPrefix = prefix;
    }

    function setUserMintCountMax(uint256 _userMintCountMax) external {
        require(msg.sender == manager.members("owner"), "only owner");
        userMintCountMax = _userMintCountMax;
    }

    function setUserMintStartMax(uint256 _userMintStartMax) external {
        require(msg.sender == manager.members("owner"), "only owner");
        userMintStartMax = _userMintStartMax;
    }

    function batchAddToWhitelist(address[] memory _users) public ContractOwnerOnly {
        uint256 i;
        uint256 len = _users.length;
        for(i; i < len; i++) {
            require(_users[i] != address(0), "address 0");
            require(!whiteList[_users[i]], "exist");
            whiteList[_users[i]] = true;
        }
    }

    function removeWhitelist(address _user) public ContractOwnerOnly {
        require(_user != address(0), "address 0");
        require(whiteList[_user], "not in white list");
        whiteList[_user] = false;
    }

    function preOfficalMint() onlyWhiteList public returns(uint256) {
        require(block.timestamp >= preStart, "NOT start!");
        require(preCount < 2000 && onceCount < onceMax ,"Sale Over!");
        require(!preBuy[msg.sender], "Can only pre buy once");
        preBuy[msg.sender] = true;
        address user = msg.sender;
        uint256 needPay = 500 * 1e18;
        IERC20(usdt).transferFrom(user, manager.members("OfficalAddress"), needPay);
        _mintinternal(user, user, true);
        emit PreMint(user, user, 10, NFT_Id);
        preCount++;
        onceCount++;
        return NFT_Id;
    }

    function userMint() public returns(uint256){
        require(paused == false, "mint is paused");
        if (block.timestamp <= (userMintStart + userMintStartMax)) {
            require(userMintCount < userMintCountMax, "mint has reached limit");
        }

        if (block.timestamp > (userMintStart + userMintStartMax)) {
            userMintStart = block.timestamp;
            userMintCount = 0;
        }
        address user = msg.sender;
        uint256 mca_price = getPrice();
        uint256 NFTprice = 525 * 1e18;
        uint256 needPay = NFTprice.mul(1e18).div(mca_price);
        uint256 forOfficalUSDT = 25 * 1e18;
        uint256 forOfficalMCA = forOfficalUSDT.mul(1e18).div(mca_price);
        userMintCount += 1;
        IERC20(mca).transferFrom(user, address(this), needPay);
        _distribute(needPay, forOfficalMCA);
        _mintinternal(user, user, false);
        emit UserMint(user, user, 10, NFT_Id, needPay);
        return NFT_Id;
    }

    function getPrice() public view returns(uint256){
        uint256 usd_balance;
        uint256 mca_balance;
        if (pair.token0() == address(usdt)) {
          (usd_balance, mca_balance , ) = pair.getReserves();   
        }  
        else{
          (mca_balance, usd_balance , ) = pair.getReserves();           
        }
        uint256 token_price = usd_balance.mul(1e18).div(mca_balance);
        return token_price;
    }

    function getWeight(address user) public view returns(uint256){
        uint256 len = ownerTokens[user].length;
        uint256 weight = 0;
        uint256[] storage tokens = ownerTokens[user];
        for(uint256 i = 0;i < len;i++){
            uint256 tokenId = tokens[i];
            weight += starAttributes[tokenId].power;
        }
        return weight;
    }

    function _distribute(uint256 needpay, uint256 forOfficalMCA) internal {        
        // 25U 項目方營運資本
        needpay = needpay.sub(forOfficalMCA);
        IERC20(mca).transfer(address(manager.members("OfficalAddress")), forOfficalMCA);

        // 40% 銷毀
        uint256 burnAmount = needpay.mul(40).div(100);
        IERC20(mca).burn(burnAmount);

        // 40% 進入MCA質押池
        uint256 mcaStakeAmount = needpay.mul(40).div(100);
        IERC20(mca).transfer(address(manager.members("MCAStakePool")), mcaStakeAmount);

        // 20% 進入LP質押池
        uint256 lpStakeAmount = needpay.mul(20).div(100);
        IERC20(mca).transfer(address(manager.members("LPStakePool")), lpStakeAmount);
    }

    function withdrawFunds(IERC20 token,uint256 amount) public returns(bool){
        require(msg.sender == manager.members("owner"), "only owner");
        if(amount >= token.balanceOf(address(this))){
            amount = token.balanceOf(address(this));
        }
        token.transfer(manager.members("funder"), amount);
        return true;
    }

    function _random(uint256 randomStart, uint256 randomEnd) internal returns(uint32) {
        require(manager.members("random") != address(0), "empty members random");
        uint[] memory r = IRandom(manager.members("random")).random(randomStart, randomEnd, 1);
        return uint32(r[0]);
    }

    function openBlindBox(uint256 tokenId) external {
        require(msg.sender == ownerOf(tokenId), "It's not your nft");
        require(starAttributes[tokenId].level == 0, "not blind box");
        
        uint256 ethnicity = _random(1, 3);
        uint256 power = _random(18, 25);
        string memory _hash = tokenId.toString().concat(".json");

        starAttributes[tokenId].openTime = block.timestamp;
        starAttributes[tokenId].IpfsHash = _hash;
        starAttributes[tokenId].level = 1;
        starAttributes[tokenId].ethnicity = ethnicity;
        starAttributes[tokenId].power = power;
        ethnicityCount[ethnicity] += 1;
        emit OpenBlindBox(msg.sender, tokenId, _hash, power, ethnicity, 1);
    }

    function updateNFT(uint256 tokenId1, uint256 tokenId2) external {
        require(ownerOf(tokenId1) == msg.sender && ownerOf(tokenId2) == msg.sender, "It's not your nft");
        require(starAttributes[tokenId1].level > 0 && starAttributes[tokenId2].level > 0, "not ethnicity nft");
        require(starAttributes[tokenId1].level == starAttributes[tokenId2].level, "different level");

        // m + ((m + s) / 2 * 1.15)
        uint256 newPower = starAttributes[tokenId1].power.add(starAttributes[tokenId1].power.add(starAttributes[tokenId2].power).div(2).mul(115).div(100));
        starAttributes[tokenId1].level += 1;
        starAttributes[tokenId1].power = newPower;

        ethnicityCount[starAttributes[tokenId2].ethnicity] -= 1;
        delete starAttributes[tokenId2];
        _burn(tokenId2);

        emit UpdateNFT(msg.sender, tokenId1, tokenId2, starAttributes[tokenId1].level, starAttributes[tokenId1].power);
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

import "./IERC165.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721TokenReceiver.sol";
import "./IERC721TokenReceiverEx.sol";

import "./Address.sol";
import "./Util.sol";

abstract contract ERC721 is IERC165, IERC721, IERC721Metadata {
    using Address for address;
    

    bytes4 private constant INTERFACE_ID_ERC165 = 0x01ffc9a7;
    
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    
    bytes4 private constant INTERFACE_ID_ERC721Metadata = 0x5b5e139f;
    
    string public override name;
    string public override symbol;
    uint256 public totalSupply = 0;
    string public uriPrefix = "https://ipfs.io/ipfs/";
    
    
    mapping(address => uint256[]) internal ownerTokens;         //玩家拥有代币数组
    mapping(uint256 => uint256) internal tokenIndexs;            //玩家拥有nft代币数组中的index
    mapping(uint256 => address) internal tokenOwners;         //根据tokenId查询玩家地址
    
    mapping(uint256 => address) internal tokenApprovals;        //代币授权
    mapping(address => mapping(address => bool)) internal approvalForAlls;       //owner对其他地址的授权
    
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
    
    function balanceOf(address owner) external view override returns(uint256) {
        require(owner != address(0), "owner is zero address");
        return ownerTokens[owner].length;
    }
    
    // [startIndex, endIndex)
    function tokensOf(address owner, uint256 startIndex, uint256 endIndex)
        external view returns(uint256[] memory) {
        
        require(owner != address(0), "owner is zero address");
        
        uint256[] storage tokens = ownerTokens[owner];
        if (endIndex == 0) {
            return tokens;
        }
        
        require(startIndex < endIndex, "invalid index");
        
        uint256[] memory result = new uint256[](endIndex - startIndex + 1);
        uint256 i2 = 0;
        for (uint256 tokenIndex = startIndex; tokenIndex <= endIndex; ++tokenIndex) {
            result[i2] = tokens[tokenIndex];
            ++i2;
        }
        
        return result;
    }
    
    function ownerOf(uint256 tokenId)
        public virtual view override returns(address) {
        
        address owner = tokenOwners[tokenId];
        require(owner != address(0), "nobody own the token");
        return owner;
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId)
            external payable override {
        
        safeTransferFrom(from, to, tokenId, "");
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId,
        bytes memory data) public payable override {                     //合约转账
        
        _transferFrom(from, to, tokenId);
        
        if (to.isContract()) {
            require(IERC721TokenReceiver(to)
                .onERC721Received(msg.sender, from, tokenId, data)
                == Util.ERC721_RECEIVER_RETURN,
                "onERC721Received() return invalid");
        }
    }
    
    function transferFrom(address from, address to, uint256 tokenId)
        external payable override {               //普通代理转账
        
        _transferFrom(from, to, tokenId);
    }
    
    function _transferFrom(address from, address to, uint256 tokenId)
        internal {
        
        require(from != address(0), "from is zero address");
        require(to != address(0), "to is zero address");
        
        require(from == tokenOwners[tokenId], "from must be owner");
        
        require(msg.sender == from
            || msg.sender == tokenApprovals[tokenId]
            || approvalForAlls[from][msg.sender],
            "sender must be owner or approvaled");
        
        if (tokenApprovals[tokenId] != address(0)) {
            delete tokenApprovals[tokenId];
        }
        
        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);
        
        emit Transfer(from, to, tokenId);
    }
    
    // ensure everything is ok before call it
    function _removeTokenFrom(address from, uint256 tokenId) internal {
        uint256 index = tokenIndexs[tokenId];  //0
        
        uint256[] storage tokens = ownerTokens[from];    
        uint256 indexLast = tokens.length - 1;   
        
        // save gas
        // if (index != indexLast) {
            uint256 tokenIdLast = tokens[indexLast];   //1
            tokens[index] = tokenIdLast;                 
            tokenIndexs[tokenIdLast] = index;   //tokenIndexs[1]=0
        // }
        
        tokens.pop();   //删除owner拥有nft代币数组
        
        // delete tokenIndexs[tokenId]; // save gas
        delete tokenOwners[tokenId];         //删除映射表中owner的nft记录
    }
    
    // ensure everything is ok before call it
    function _addTokenTo(address to, uint256 tokenId) internal {
        uint256[] storage tokens = ownerTokens[to];
        tokenIndexs[tokenId] = tokens.length;
        tokens.push(tokenId);
        
        tokenOwners[tokenId] = to;
    }
    
    function approve(address to, uint256 tokenId)
        external payable override {
        
        address owner = tokenOwners[tokenId];
        
        require(msg.sender == owner
            || approvalForAlls[owner][msg.sender],
            "sender must be owner or approved for all"
        );
        
        tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    
    function setApprovalForAll(address to, bool approved) external override {
        approvalForAlls[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }
    
    function getApproved(uint256 tokenId)
        external view override returns(address) {
        
        require(tokenOwners[tokenId] != address(0),
            "nobody own then token");
        
        return tokenApprovals[tokenId];
    }
    
    function isApprovedForAll(address owner, address operator)
        external view override returns(bool) {
        
        return approvalForAlls[owner][operator];
    }
    
    function supportsInterface(bytes4 interfaceID)
        external pure override returns(bool) {
        
        return interfaceID == INTERFACE_ID_ERC165
            || interfaceID == INTERFACE_ID_ERC721
            || interfaceID == INTERFACE_ID_ERC721Metadata;
    }

    // function _mint(address to, uint256 tokenId, string memory tokenURI) internal {
    function _mint(address to, uint256 tokenId) internal {
        _addTokenTo(to, tokenId);
        // _setTokenURI(to, tokenURI);
        ++totalSupply;
        
        emit Transfer(address(0), to, tokenId);
    }
    
    function _burn(uint256 tokenId) internal {
        address owner = tokenOwners[tokenId];
        _removeTokenFrom(owner, tokenId);
        
        if (tokenApprovals[tokenId] != address(0)) {
            delete tokenApprovals[tokenId];
        }
        
        emit Transfer(owner, address(0), tokenId);
    }
    
    function safeBatchTransferFrom(address from, address to,
        uint256[] memory tokenIds) external {                   //批量转账
        
        safeBatchTransferFrom(from, to, tokenIds, "");
    }
    
    function safeBatchTransferFrom(address from, address to,
        uint256[] memory tokenIds, bytes memory data) public {
        
        batchTransferFrom(from, to, tokenIds);
        
        if (to.isContract()) {
            require(IERC721TokenReceiverEx(to)
                .onERC721ExReceived(msg.sender, from, tokenIds, data)
                == Util.ERC721_RECEIVER_EX_RETURN,
                "onERC721ExReceived() return invalid");
        }
    }
    
    function batchTransferFrom(address from, address to,
        uint256[] memory tokenIds) public {
        
        require(from != address(0), "from is zero address");
        require(to != address(0), "to is zero address");
        
        uint256 length = tokenIds.length;
        address sender = msg.sender;
        
        bool approval = from == sender || approvalForAlls[from][sender];
        
        for (uint256 i = 0; i != length; ++i) {
            uint256 tokenId = tokenIds[i];
			
            require(from == tokenOwners[tokenId], "from must be owner");
            require(approval || sender == tokenApprovals[tokenId],
                "sender must be owner or approvaled");
            
            if (tokenApprovals[tokenId] != address(0)) {
                delete tokenApprovals[tokenId];
            }
            
            _removeTokenFrom(from, tokenId);
            _addTokenTo(to, tokenId);
            
            emit Transfer(from, to, tokenId);
        }
    }
    
    

    
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    function totalSupply() external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);
    
    function approve(address spender, uint256 value) external returns(bool);
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function burn(uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

library String {
    function equals(string memory a, string memory b)
        internal pure returns(bool) {
        
        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);
        
        uint256 la = ba.length;
        uint256 lb = bb.length;
        
        for (uint256 i = 0; i != la && i != lb; ++i) {
            if (ba[i] != bb[i]) {
                return false;
            }
        }
        
        return la == lb;
    }
    
    function concat(string memory a, string memory b)
        internal pure returns(string memory) {
            
        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);
        bytes memory bc = new bytes(ba.length + bb.length);
        
        uint256 bal = ba.length;
        uint256 bbl = bb.length;
        uint256 k = 0;
        
        for (uint256 i = 0; i != bal; ++i) {
            bc[k++] = ba[i];
        }
        for (uint256 i = 0; i != bbl; ++i) {
            bc[k++] = bb[i];
        }
        
        return string(bc);
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

library Util {
    bytes4 internal constant ERC721_RECEIVER_RETURN = 0x150b7a02;
    bytes4 internal constant ERC721_RECEIVER_EX_RETURN = 0x0f7b88e3;
    
    uint256 public constant UDENO = 10 ** 10;
    int256 public constant SDENO = 10 ** 10;
    
    uint256 public constant RARITY_WHITE = 0;
    uint256 public constant RARITY_GREEN = 1;
    uint256 public constant RARITY_BLUE = 2;
    uint256 public constant RARITY_PURPLE = 3;
    uint256 public constant RARITY_ORANGE = 4;
    uint256 public constant RARITY_GOLD = 5;
    
    bytes public constant BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
    
    function randomUint(bytes memory seed, uint256 min, uint256 max)
        internal pure returns(uint256) {
        
        if (min >= max) {
            return min;
        }
        
        uint256 number = uint256(keccak256(seed));
        return number % (max - min + 1) + min;
    }
    
    function randomWeight(bytes memory seed, uint256[] memory weights,
        uint256 totalWeight) internal pure returns(uint256) {
        
        uint256 number = Util.randomUint(seed, 1, totalWeight);
        
        for (uint256 i = weights.length - 1; i != 0; --i) {
            if (number <= weights[i]) {
                return i;
            }
            
            number -= weights[i];
        }
        
        return 0;
    }
    
    function randomProb(bytes memory seed, uint256 nume, uint256 deno)
        internal pure returns(bool) {
        
        uint256 rand = Util.randomUint(seed, 1, deno);
        return rand <= nume;
    }
    
    function base64Encode(bytes memory bs) internal pure returns(string memory) {
        uint256 remain = bs.length % 3;
        uint256 length = bs.length / 3 * 4;
        bytes memory result = new bytes(length + (remain != 0 ? 4 : 0) + (3 - remain) % 3);
        
        uint256 i = 0;
        uint256 j = 0;
        while (i != length) {
            result[i++] = Util.BASE64_CHARS[uint8(bs[j] >> 2)];
            result[i++] = Util.BASE64_CHARS[uint8((bs[j] & 0x03) << 4 | bs[j + 1] >> 4)];
            result[i++] = Util.BASE64_CHARS[uint8((bs[j + 1] & 0x0f) << 2 | bs[j + 2] >> 6)];
            result[i++] = Util.BASE64_CHARS[uint8(bs[j + 2] & 0x3f)];
            
            j += 3;
        }
        
        if (remain != 0) {
            result[i++] = Util.BASE64_CHARS[uint8(bs[j] >> 2)];
            
            if (remain == 2) {
                result[i++] = Util.BASE64_CHARS[uint8((bs[j] & 0x03) << 4 | bs[j + 1] >> 4)];
                result[i++] = Util.BASE64_CHARS[uint8((bs[j + 1] & 0x0f) << 2)];
                result[i++] = Util.BASE64_CHARS[0];
                result[i++] = 0x3d;
            } else {
                result[i++] = Util.BASE64_CHARS[uint8((bs[j] & 0x03) << 4)];
                result[i++] = Util.BASE64_CHARS[0];
                result[i++] = Util.BASE64_CHARS[0];
                result[i++] = 0x3d;
                result[i++] = 0x3d;
            }
        }
        
        return string(result);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";
import "./Manager.sol";

abstract contract Member is ContractOwner {
    modifier CheckPermit(string memory permit) {
        require(manager.userPermits(msg.sender, permit),
            "no permit");
        _;
    }
    
    Manager public manager;
    
    function setManager(address addr) external ContractOwnerOnly {
        manager = Manager(addr);
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns(bool);
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface IERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns(uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns(address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns(address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns(bool);
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x5b5e139f.
interface IERC721Metadata /* is ERC721 */ {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory);
    
    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string memory);
    
    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    /// {"name":"","description":"","image":""}
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface IERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

import "./IERC721TokenReceiver.sol";

interface IERC721TokenReceiverEx is IERC721TokenReceiver {
    // bytes4(keccak256("onERC721ExReceived(address,address,uint256[],bytes)")) = 0x0f7b88e3
    function onERC721ExReceived(address operator, address from,
        uint256[] memory tokenIds, bytes memory data)
        external returns(bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity ^0.8.0;
// SPDX-License-Identifier: SimPL-2.0

abstract contract ContractOwner {
    address public contractOwner = msg.sender;
    
    modifier ContractOwnerOnly {
        require(msg.sender == contractOwner, "contract owner only");
        _;
    }
}

pragma solidity ^0.8.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ContractOwner.sol";

contract Manager is ContractOwner {
    mapping(string => address) public members;
    
    mapping(address => mapping(string => bool)) public userPermits;
    
    function setMember(string memory name, address member)
        external ContractOwnerOnly {
        
        members[name] = member;
    }
    
    function setUserPermit(address user, string memory permit,
        bool enable) external ContractOwnerOnly {
        
        userPermits[user][permit] = enable;
    }
    
    function getTimestamp() external view returns(uint256) {
        return block.timestamp;
    }
}