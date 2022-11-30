/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

pragma solidity =0.8.0;

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
}

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns(bool);
}

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

interface IERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}

interface IERC721TokenReceiverEx is IERC721TokenReceiver {
    // bytes4(keccak256("onERC721ExReceived(address,address,uint256[],bytes)")) = 0x0f7b88e3
    function onERC721ExReceived(address operator, address from,
        uint256[] memory tokenIds, bytes memory data)
        external returns(bytes4);
}

library Address {

    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns(bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

library AddressSet {
    struct Set {
        mapping(address => uint256) indexes;
        address[] addresses;
    }
    
    function add(Set storage set, address addr) internal returns(bool) {
        if (contains(set, addr)) {
            return false;
        }
        
        set.indexes[addr] = set.addresses.length;
        set.addresses.push(addr);
        
        return true;
    }
    
    function remove(Set storage set, address addr) internal returns(bool) {
        if (!contains(set, addr)) {
            return false;
        }
        
        uint256 index = set.indexes[addr];
        address tail = set.addresses[set.addresses.length - 1];
        
        set.indexes[addr] = 0;
        set.indexes[tail] = index;
        
        set.addresses[index] = tail;
        set.addresses.pop();
        
        return true;
    }
    
    function contains(Set storage set, address addr) internal view returns(bool) {
        return set.indexes[addr] != 0 ||
            set.addresses.length > 0 && set.addresses[0] == addr;
    }
    
    function indexOf(Set storage set, address addr) internal view returns(uint256) {
        if (contains(set, addr)) {
            return set.indexes[addr];
        } else {
            return ~uint256(0);
        }
    }
    
    function length(Set storage set) internal view returns(uint256) {
        return set.addresses.length;
    }
    
    function get(Set storage set, uint256 index)
        internal view returns(address) {
        
        require(index < set.addresses.length, "invalid index");
        
        return set.addresses[index];
    }
    
    // [startIndex, endIndex)
    function get(Set storage set, uint256 startIndex, uint256 endIndex)
        internal view returns(address[] memory) {
        
        if (endIndex == 0) {
            endIndex = set.addresses.length;
        }
        
        require(startIndex <= endIndex && endIndex <= set.addresses.length,
            "invalid index");
        
        address[] memory result = new address[](endIndex - startIndex);
        
        for (uint256 i = startIndex; i < endIndex; ++i) {
            result[i - startIndex] = set.addresses[i];
        }
        
        return result;
    }
}

library SafeERC20 {
    using Address for address;
	
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
	
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
	
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
	
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
	
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) - value;
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
	
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: IERC20 operation did not succeed");
        }
    }
}

library String {
    function equals(string memory a, string memory b)
        internal pure returns(bool) {
        
        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);
        
        uint256 la = ba.length;
        uint256 lb = bb.length;
        
        for (uint256 i = 0; i < la && i < lb; ++i) {
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
        
        for (uint256 i = 0; i < bal; ++i) {
            bc[k++] = ba[i];
        }
        
        for (uint256 i = 0; i < bbl; ++i) {
            bc[k++] = bb[i];
        }
        
        return string(bc);
    }
}

library UInteger {
    function toString(uint256 a, uint256 radix)
        internal pure returns(string memory) {
        
        if (a == 0) {
            return "0";
        }
        
        uint256 length = 0;
        for (uint256 n = a; n != 0; n /= radix) {
            ++length;
        }
        
        bytes memory bs = new bytes(length);
        
        for (uint256 i = length - 1; a != 0; --i) {
            uint256 b = a % radix;
            a /= radix;
            
            if (b < 10) {
                bs[i] = bytes1(uint8(b + 48));
            } else {
                bs[i] = bytes1(uint8(b + 87));
            }
        }
        
        return string(bs);
    }
    
    function toString(uint256 a) internal pure returns(string memory) {
        return UInteger.toString(a, 10);
    }
    
    function max(uint256 a, uint256 b) internal pure returns(uint256) {
        return a > b ? a : b;
    }
    
    function min(uint256 a, uint256 b) internal pure returns(uint256) {
        return a < b ? a : b;
    }
    
    function shiftLeft(uint256 n, uint256 bits, uint256 shift)
        internal pure returns(uint256) {
        
        require(n < (1 << bits), "shiftLeft overflow");
        
        return n << shift;
    }
}

library Util {
    bytes4 internal constant ERC721_RECEIVER_RETURN = 0x150b7a02;
    bytes4 internal constant ERC721_RECEIVER_EX_RETURN = 0x0f7b88e3;
    
    uint256 internal constant DENO = 1e10;
    
    bytes internal constant BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
    
    uint256 internal constant COUNTRY_WEI = 1;
    uint256 internal constant COUNTRY_SHU = 2;
    uint256 internal constant COUNTRY_WU = 3;
    uint256 internal constant COUNTRY_QUN = 4;
    
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
        
        for (uint256 i = weights.length - 1; i > 0; --i) {
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
        while (i < length) {
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
    
    function calcBuffer(uint256 value, uint256 buffer)
        internal pure returns(uint256) {
        
        return value * (DENO + buffer) / DENO;
    }
}

abstract contract ContractOwner {
    address immutable public contractOwner = msg.sender;
    
    modifier onlyContractOwner {
        require(msg.sender == contractOwner, "only contract owner");
        _;
    }
}

abstract contract ERC721 is IERC165, IERC721, IERC721Metadata {
    using Address for address;
    
    /*
     * bytes4(keccak256("supportsInterface(bytes4)")) == 0x01ffc9a7
     */
    bytes4 private constant INTERFACE_ID_ERC165 = 0x01ffc9a7;
    
    /*
     *     bytes4(keccak256("balanceOf(address)")) == 0x70a08231
     *     bytes4(keccak256("ownerOf(uint256)")) == 0x6352211e
     *     bytes4(keccak256("approve(address,uint256)")) == 0x095ea7b3
     *     bytes4(keccak256("getApproved(uint256)")) == 0x081812fc
     *     bytes4(keccak256("setApprovalForAll(address,bool)")) == 0xa22cb465
     *     bytes4(keccak256("isApprovedForAll(address,address)")) == 0xe985e9c5
     *     bytes4(keccak256("transferFrom(address,address,uint256)")) == 0x23b872dd
     *     bytes4(keccak256("safeTransferFrom(address,address,uint256)")) == 0x42842e0e
     *     bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)")) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    
    bytes4 private constant INTERFACE_ID_ERC721Metadata = 0x5b5e139f;
    
    string public override name;
    string public override symbol;
    
    mapping(address => uint256[]) internal ownerTokens;
    mapping(uint256 => uint256) internal tokenIndexs;
    mapping(uint256 => address) internal tokenOwners;
    
    mapping(uint256 => address) internal tokenApprovals;
    mapping(address => mapping(address => bool)) internal approvalForAlls;
    
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
            endIndex = tokens.length;
        }
        
        uint256[] memory result = new uint256[](endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; ++i) {
            result[i - startIndex] = tokens[i];
        }
        
        return result;
    }
    
    function ownerOf(uint256 tokenId)
        external view override returns(address) {
        
        address owner = tokenOwners[tokenId];
        require(owner != address(0), "nobody own the token");
        return owner;
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId)
            external payable override {
        
        safeTransferFrom(from, to, tokenId, "");
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId,
        bytes memory data) public payable override {
        
        _transferFrom(from, to, tokenId);
        
        if (to.isContract()) {
            require(IERC721TokenReceiver(to)
                .onERC721Received(msg.sender, from, tokenId, data)
                == Util.ERC721_RECEIVER_RETURN,
                "onERC721Received() return invalid");
        }
    }
    
    function transferFrom(address from, address to, uint256 tokenId)
        external payable override {
        
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
        uint256 index = tokenIndexs[tokenId];
        
        uint256[] storage tokens = ownerTokens[from];
        uint256 indexLast = tokens.length - 1;
        
        // save gas
        // if (index != indexLast) {
            uint256 tokenIdLast = tokens[indexLast];
            tokens[index] = tokenIdLast;
            tokenIndexs[tokenIdLast] = index;
        // }
        
        tokens.pop();
        
        // delete tokenIndexs[tokenId]; // save gas
        delete tokenOwners[tokenId];
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
}

abstract contract AddressMap is ContractOwner {
    using AddressSet for AddressSet.Set;
    
    mapping(string => AddressSet.Set) internal addressMap;
    
    modifier checkAddressMap(string memory key) {
        require(addressMap[key].contains(msg.sender), "sender not in addressMap");
        _;
    }
    
    function addAddressMap(string memory key, address account)
        public onlyContractOwner returns(bool) {
        
        return addressMap[key].add(account);
    }
    
    function removeAddressMap(string memory key, address account)
        public onlyContractOwner returns(bool) {
        
        return addressMap[key].remove(account);
    }
    
    function getAddressMapLength(string memory key) public view returns(uint256) {
        return addressMap[key].length();
    }
    
    // [startIndex, endIndex)
    function getAddressMaps(string memory key, uint256 startIndex, uint256 endIndex)
        public view returns(address[] memory) {
        
        return addressMap[key].get(startIndex, endIndex);
    }
    
    function containsAddressMap(string memory key, address account)
        public view returns(bool) {
        
        return addressMap[key].contains(account);
    }
}

contract Manager is ContractOwner {
    using AddressSet for AddressSet.Set;
    
    mapping(string => address) public members;
    
    mapping(string => AddressSet.Set) internal permits;
    
    modifier onlyPermit(string memory permit) {
        require(permits[permit].contains(msg.sender), "no permit");
        _;
    }
    
    function setMember(string memory name, address member)
        external onlyContractOwner {
        
        members[name] = member;
    } 
    
    function addPermit(string memory permit, address account)
        external onlyContractOwner {
        
        require(permits[permit].add(account), "account existed");
    }
    
    function removePermit(string memory permit, address account)
        external onlyContractOwner {
        
        require(permits[permit].remove(account), "account not existed");
    }
    
    function removePermitAll(string memory permit)
        external onlyContractOwner {
        
        delete permits[permit];
    }
    
    function getPermitLength(string memory permit) external view returns(uint256) {
        return permits[permit].length();
    }
    
    // [startIndex, endIndex)
    function getPermitMaps(string memory permit, uint256 startIndex, uint256 endIndex)
        external view returns(address[] memory) {
        
        return permits[permit].get(startIndex, endIndex);
    }
    
    function containsPermit(string memory permit, address account)
        public view returns(bool) {
        
        return permits[permit].contains(account);
    }
    
    function requirePermit(string memory permit, address account) public view {
        require(containsPermit(permit, account), "not permit");
    }
    
    function getTimestamp() external view returns(uint256) {
        return block.timestamp;
    }
}

abstract contract Member is AddressMap {
    modifier onlyPermit(string memory permit) {
        require(manager.containsPermit(permit, msg.sender),
            "no permit");
        _;
    }
    
    Manager public manager;
    
    function setManager(address addr) external onlyContractOwner {
        manager = Manager(addr);
    }
}

abstract contract MoneyTransfer is Member {
    function _transferMoney(address money, address from, address to,
        uint256 amount) internal {
        
        if (money == address(1)) {
            if (from == address(this)) {
                payable(address(to)).transfer(amount);
            } else if (to == address(this)) {
                require(from == msg.sender, "transfer ETH from invalid");
                require(msg.value == amount, "transfer ETH value invalid");
            } else {
                require(false, "transfer ETH from and to invalid");
            }
        } else {
            if (from == address(this)) {
                require(IERC20(money).transfer(to, amount),
                    "transfer money failed");
            } else {
                require(IERC20(money).transferFrom(from, to, amount),
                    "transfer money failed");
            }
        }
    }
    
    function _receiveMoneyFrom(address money, address from, uint256 amount) internal {
        _transferMoney(money, from, address(this), amount);
    }
    
    function _receiveMoney(address money, uint256 amount) internal {
        _transferMoney(money, msg.sender, address(this), amount);
    }
    
    function _receiveMoneyExceed(address money, uint256 amount)
        internal returns(uint256) {
        
        if (money == address(1)) {
            require(msg.value >= amount, "receive ETH value invalid");
            return msg.value - amount;
        } else {
            _transferMoney(money, msg.sender, address(this), amount);
            return 0;
        }
    }
    
    function _sendMoneyTo(address money, address to,
        uint256 amount) internal {
        
        _transferMoney(money, address(this), to, amount);
    }
    
    function _sendMoney(address money, uint256 amount) internal {
        _transferMoney(money, address(this), msg.sender, amount);
    }
}

abstract contract ERC721Ex is ERC721, Member {
    using Address for address;
    using String for string;
    
    uint256 public totalSupply = 0;
    
    string public uriPrefix;
    
    function _mint(address to, uint256 tokenId) internal {
        _addTokenTo(to, tokenId);
        
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
        uint256[] memory tokenIds) external {
        
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
        
        address sender = msg.sender;
        bool approval = from == sender || approvalForAlls[from][sender];
        
        for (uint256 i = 0; i < tokenIds.length; ++i) {
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
    
    function setUriPrefix(string memory prefix)
        external onlyPermit("Config") {
        
        uriPrefix = prefix;
    }
    
    function tokenURI(uint256 cardId)
        external view override virtual returns(string memory) {
        
        bytes memory bs = abi.encodePacked(cardId);
        return uriPrefix.concat(Util.base64Encode(bs));
    }
}

abstract contract Card is ERC721Ex {
    // except mintTime and index
    uint256 public constant CARD_ID_PREFIX_MASK = uint256(~uint160(0)) << 96;
    
    function mint(address to, uint256 cardIdPre) external checkAddressMap("package") {
        uint256 cardId = (cardIdPre & CARD_ID_PREFIX_MASK) |
            (uint256(uint40(block.timestamp)) << 56) |
            uint56(totalSupply + 1);
        
        _mint(to, cardId);
    }
    
    function burn(uint256 cardId) public virtual;
    
    function batchBurn(uint256[] memory cardIds) external {
        for (uint256 i = 0; i < cardIds.length; ++i) {
            burn(cardIds[i]);
        }
    }
}

// country  order   skin    star    tokenAmount padding shop    mintTime    index
// 8        24      8       8       72          24      16      40          56
// 248      224     216     208     136         112     96      56          0

contract Hero is Card, MoneyTransfer {
    uint256 public burnLockDuration = 2 days;
    
    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol) {
    }
    
    function setBurnLockDuration(uint256 duration)
        external onlyPermit("Config") {
        
        burnLockDuration = duration;
    }
    
    function burn(uint256 cardId) public override {
        address owner = tokenOwners[cardId];
		
        require(msg.sender == owner
            || msg.sender == tokenApprovals[cardId]
            || approvalForAlls[owner][msg.sender],
            "msg.sender must be owner or approved");
        
        if (!containsAddressMap("burnWhiteList", msg.sender)) {
            uint256 mintTime = uint40(cardId >> 56);
            require(mintTime + burnLockDuration < block.timestamp, "hero has not unlocked");
        }
        
        _burn(cardId);
        
        uint256 tokenAmount = uint72(cardId >> 136);
        _sendMoneyTo(manager.members("token"), owner, tokenAmount);
    }
}