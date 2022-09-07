/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// File: contracts\openzeppelin-contracts\contracts\utils\introspection\IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: contracts\openzeppelin-contracts\contracts\token\ERC721\IERC721.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;
/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: contracts\openzeppelin-contracts\contracts\token\ERC721\extensions\IERC721Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;
/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: contracts\openzeppelin-contracts\contracts\token\ERC721\extensions\IERC721Enumerable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;
/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: contracts\openzeppelin-contracts\contracts\utils\strings.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

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

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: contracts\Keeper.sol

pragma solidity ^0.8.0;
abstract contract Keeper {
    address public keeper;
    
    constructor() {
        keeper = msg.sender;
    }
    
    modifier onlyOwner() {
        require(keeper == msg.sender, "onlyKeeper");
        _;
    }
    
    function setKeeper(address _keeper) public onlyOwner {
        keeper = _keeper;
    }
}

// File: contracts\NFT.sol

pragma solidity ^0.8.0;





interface IToken{
    function mint(address, uint256) external;
    function transfer(address, uint256) external;
    function transferFrom(address, address, uint256) external;
}

interface IRelation{
    function bind(address user, address inviter) external;
    function parents(address) external view returns(address);
    function family(address) external view returns(uint256);
}

interface IFee{
    function get() external view returns(uint256 _totalRate, address _feeAddr, uint256 _feeRate, uint256[] memory _rates, uint256[] memory _numbers);
}

contract NFT is Keeper {
    using Strings for uint256;
    string public name;
    string public symbol;
    string private uri;
    bool public pause;
    bool public useSeparateUri;
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256[]) public tokenOfOwnerByIndex;
    struct RewardRate{
        uint256 startDay;
        uint256 rewardPerDay;
    }
    struct Miner{
        uint256 updateTime;
        uint256 totalReward;
    }
    IToken private token;
    uint256 private oneday = 1 days;
    uint256 private startTime = 1662519480;
    uint256 private price;
    uint256 private totalReward;
    uint256 public activeBind;
    RewardRate[] private rewardRate;
    Miner[] public miner;
    IFee public fee1;
    IFee public fee2;
    IRelation public relation;
    address public blackHole = 0x000000000000000000000000000000000000dEaD;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    
    constructor(string memory _name, string memory _symbol, string memory _uri, IToken _token, uint256 _price,
        uint256 _totalReward, uint256 rewardPerDay, uint256 _activeBind, IFee _fee1, IFee _fee2, IRelation _relation){
        name = _name;
        symbol = _symbol;
        uri = _uri;
        token = _token;
        price = _price;
        totalReward = _totalReward;
        activeBind = _activeBind;
        rewardRate.push(RewardRate(0, rewardPerDay));
        fee1 = _fee1;
        fee2 = _fee2;
        relation = _relation;
    }
    
    function setPrice(uint256 _price) external onlyOwner{
        price = _price;
    }
    
    function setTotalReward(uint256 _totalReward) external onlyOwner{
        totalReward = _totalReward;
    }
    
    function addRewardrate(uint256 rewardPerDay) external onlyOwner{
        uint256 day = getDay(block.timestamp);
        require(day > rewardRate[rewardRate.length - 1].startDay, "NFT:reward is set");
        rewardRate.push(RewardRate(day, rewardPerDay));
    }
    
    function supportsInterface(bytes4 interfaceId) public pure  returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId;
    }
    
    function exists(uint256 tokenId) public view returns (bool) {
        return ownerOf[tokenId] != address(0);
    }
    
    function tokenURI(uint256 tokenId) external view returns (string memory){
        if(useSeparateUri){
            require(exists(tokenId), "NFT:tokenId not exists");
            return bytes(uri).length > 0 ? string(abi.encodePacked(uri, tokenId.toString())) : "";
        }else{
            return uri;
        }
    }
    
    function getApproved(uint256 tokenId) public pure returns (address) {
        revert("NFT:tokenId not exists");
    }
    
    function isApprovedForAll(address owner, address operator) public pure returns (bool) {
        return false;
    }
    
    function totalSupply() external view returns(uint256){
        return miner.length;
    }
    
    function _mint(address to, uint256 number) internal {
        require(!pause, "NFT:paused");
        require(to != address(0), "NFT:zero address");
        for(uint256 i = 0; i < number; i++){
            uint256 tokenId = tokenByIndex(miner.length);
            ownerOf[tokenId] = to;
            tokenOfOwnerByIndex[to].push(tokenId);
            miner.push(Miner(_max(block.timestamp, startTime), 0));
            emit Transfer(address(0), to, tokenId);
        }
    }
    
    function balanceOf(address account) external view returns(uint256){
        return tokenOfOwnerByIndex[account].length;
    }
    
    function setURI(string memory _uri, bool _useSeparateUri) external onlyOwner {
        uri = _uri;
        useSeparateUri = _useSeparateUri;
    }
    
    function setPause(bool _pause) external onlyOwner {
        pause = _pause;
    }
    
    function setActiveBind(uint256 _activeBind) external onlyOwner{
        activeBind = _activeBind;
    }
    
    function tokenByIndex(uint256 index) public pure returns (uint256){
        return index * 0x10002 + 0x100000000;
    }
    
    function indexOf(uint256 tokenId) public pure returns(uint256){
        return (tokenId - 0x100000000) / 0x10002;
    }
    
    function getMiners(address account) external view returns (uint256[] memory tokenIds, Miner[] memory miners, uint256[] memory rewards){
        tokenIds = tokenOfOwnerByIndex[account];
        miners = new Miner[](tokenIds.length);
        rewards = new uint256[](tokenIds.length);
        for(uint256 i = 0; i < tokenIds.length; i++){
            uint256 tokenId = tokenIds[i];
            miners[i] = miner[indexOf(tokenId)];
            (rewards[i],) = pendingReward(tokenId);
        }
    }
	
	function getRewardRate() external view returns(RewardRate[] memory){
		return rewardRate;
	}
	
	function pool() external view returns(address _token, uint256 _day, uint256 _startTime, uint256 _price, uint256 _totalReward, uint256 _rewardPerDay){
	    return (address(token), oneday, startTime, price, totalReward, rewardRate[rewardRate.length - 1].rewardPerDay);
	}
    
    function mint(uint256 number, address inviter) external {
        require(number > 0, "NFT:zero number");
        address to = msg.sender;
        uint256 amount = number * price;
        if(amount > 0){
            token.transferFrom(to, address(this), amount);
            if(number >= activeBind){
                relation.bind(msg.sender, inviter);
            }
            uint256 left = amount;
            (, address feeAddr, uint256 feeRate, uint256[] memory rates, uint256[] memory numbers) = fee1.get();
            uint256 fee = amount * feeRate / 1000;
            if(fee > 0 && feeAddr != address(0)){
                token.transfer(feeAddr, fee);
                left -= fee;
            }
            inviter = to;
            for(uint256 i = 0; i < rates.length; i++){
                inviter = relation.parents(inviter);
                if(inviter == address(0)){
                    break;
                }
                fee = amount * rates[i] / 1000;
                if(fee > 0 && relation.family(inviter) >= numbers[i]){
                    token.transfer(inviter, fee);
                    left -= fee;
                }
            }
            if(left > 0){
                token.transfer(blackHole, left);
            }
        }
        _mint(to, number);
    }
    
    function mintBatch(address[] memory tos, uint256[] memory numbers) external onlyOwner{
        require(tos.length == numbers.length, "NFT:array not match");
        for(uint256 i = 0; i < tos.length; i++){
            _mint(tos[i], numbers[i]);
        }
    }
    
    function getDay(uint256 timestamp) public view returns(uint256){
        return timestamp > startTime ? (timestamp - startTime) / oneday : 0;
    }
    
    function rewardIndex(uint256 day) public view returns(uint256){
        for(uint256 i = rewardRate.length; i > 0; i--){
            RewardRate memory r = rewardRate[i - 1];
            if(day >= r.startDay ){
                return i - 1;
            }
        }
        return 0;
    }
    
    function _max(uint256 a, uint256 b) internal pure returns(uint256 c){
        c = a > b ? a : b;
    }
    
    function _min(uint256 a, uint256 b) internal pure returns(uint256 c){
        c = a < b ? a : b;
    }
    
    function calcReward(uint256 startTimestamp, uint256 endTimestamp) public view returns(uint256 reward, uint256 day){
        reward = 0;
		if(endTimestamp <= startTimestamp){
			day = 0;
		}else{
            day = (endTimestamp - startTimestamp) / oneday;
            if(day > 0){
			    uint256 startDay = getDay(startTimestamp);
			    uint256 endDay = startDay + day;
                uint256 endIndex = rewardIndex(endDay - 1);
                for(uint256 i = rewardIndex(startDay); i <= endIndex; i++){
                    uint256 end = (i == rewardRate.length - 1) ? endDay : rewardRate[i + 1].startDay;
                    reward += rewardRate[i].rewardPerDay * (_min(end, endDay) - _max(rewardRate[i].startDay, startDay));
                }
            }
		}
    }
    
    function pendingReward(uint256 tokenId) public view returns(uint256 reward, uint256 day){
        Miner memory m = miner[indexOf(tokenId)];
        (reward, day) = calcReward(m.updateTime, block.timestamp);
        reward = _min(reward, totalReward - m.totalReward);
    }
    
    function harvest(uint256[] memory tokenIds) external {
        uint256 reward = 0;
        address to = msg.sender;
        for(uint256 i = 0; i < tokenIds.length; i++){
            uint256 tokenId = tokenIds[i];
            require(ownerOf[tokenId] == to, "NFT:only harvest you owned");
            (uint256 mreward, uint256 day) = pendingReward(tokenId);
            miner[indexOf(tokenId)].updateTime += day * oneday;
            miner[indexOf(tokenId)].totalReward += mreward;
            reward += mreward;
        }
        require(reward > 0, "NFT:no reward");
        token.mint(address(this), reward);
		(uint256 totalRate, address feeAddr, uint256 feeRate, uint256[] memory rates, uint256[] memory numbers) = fee2.get();
        uint256 left = reward * totalRate / 1000;
        uint256 res = reward - left;
        if(res > 0){
            token.transfer(to, res);
        }
        uint256 fee = reward * feeRate / 1000;
        if(fee > 0){
            token.transfer(feeAddr, fee);
            left -= fee;
        }
        address inviter = to;
        for(uint256 i = 0; i < rates.length; i++){
            inviter = relation.parents(inviter);
            if(inviter == address(0)){
                break;
            }
            fee = reward * rates[i] / 1000;
            if(fee > 0 && relation.family(inviter) >= numbers[i]){
                token.transfer(inviter, fee);
                left -= fee;
            }
        }
        if(left > 0){
            token.transfer(blackHole, left);
        }
    }
    
    function getTimestamp() external view returns(uint256){
        return block.timestamp;
    }
    
    function claimToken(IToken _token, address to, uint256 amount) external onlyOwner{
        _token.transfer(to, amount);
    }
}