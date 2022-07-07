/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

/*
MrGreenNFTs - Your VIP access card to all current and future utilities made by MrGreenCrypto.

For more information:
- Website: https://mrgreencrypto.com
- Telegram-Channel: https://t.me/mrgreencalls
- Telegram-Group: https://t.me/mrgreengroup
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None
pragma solidity 0.8.15;

library Address {
    function isContract(address account) internal view returns (bool) {bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function isDead(address addy) internal pure returns (bool) {
        return addy == address(0)
            || addy == address(1)
            || addy == address(0xDEAD);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
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


library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    struct Map {EnumerableSet.Bytes32Set _keys;mapping (bytes32 => bytes32) _values;}
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {map._values[key] = value;return map._keys.add(key);}
    function _remove(Map storage map, bytes32 key) private returns (bool) {delete map._values[key];return map._keys.remove(key);}
    function _contains(Map storage map, bytes32 key) private view returns (bool) {return map._keys.contains(key);}
    function _length(Map storage map) private view returns (uint256) {return map._keys.length();}
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {bytes32 key = map._keys.at(index);return (key, map._values[key]);}
    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (_contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), errorMessage);
        return value;
    }
    struct UintToAddressMap {Map _inner;}
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));}
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {return _remove(map._inner, bytes32(key));}
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {return _contains(map._inner, bytes32(key));}
    function length(UintToAddressMap storage map) internal view returns (uint256) {return _length(map._inner);}
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {return address(uint160(uint256(_get(map._inner, bytes32(key)))));}
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

library EnumerableSet {
    struct Set {bytes32[] _values; mapping(bytes32 => uint256) _indexes;}
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }
    function _contains(Set storage set, bytes32 value) private view returns (bool) {return set._indexes[value] != 0;}
    function _length(Set storage set) private view returns (uint256) {return set._values.length;}
    function _at(Set storage set, uint256 index) private view returns (bytes32) {return set._values[index];}
    function _values(Set storage set) private view returns (bytes32[] memory) {return set._values;}
    struct Bytes32Set { Set _inner;}
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {return _add(set._inner, value);}
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {return _remove(set._inner, value);}
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {return _contains(set._inner, value);}
    function length(Bytes32Set storage set) internal view returns (uint256) {return _length(set._inner);}
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {return _at(set._inner, index);}
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {return _values(set._inner);}
    struct AddressSet {Set _inner;}
    function add(AddressSet storage set, address value) internal returns (bool) {return _add(set._inner, bytes32(uint256(uint160(value))));}
    function remove(AddressSet storage set, address value) internal returns (bool) {return _remove(set._inner, bytes32(uint256(uint160(value))));}
    function contains(AddressSet storage set, address value) internal view returns (bool) {return _contains(set._inner, bytes32(uint256(uint160(value))));}
    function length(AddressSet storage set) internal view returns (uint256) {return _length(set._inner);}
    function at(AddressSet storage set, uint256 index) internal view returns (address) {return address(uint160(uint256(_at(set._inner, index))));}
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;
        assembly {result := store}
        return result;
    }
    struct UintSet {Set _inner;}
    function add(UintSet storage set, uint256 value) internal returns (bool) {return _add(set._inner, bytes32(value));}
    function remove(UintSet storage set, uint256 value) internal returns (bool) {return _remove(set._inner, bytes32(value));}
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {return _contains(set._inner, bytes32(value));}
    function length(UintSet storage set) internal view returns (uint256) {return _length(set._inner);}
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {return uint256(_at(set._inner, index));}
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;
        assembly {result := store}
        return result;
    }
}

contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    mapping(bytes4 => bool) private _supportedInterfaces;
    constructor () {_registerInterface(_INTERFACE_ID_ERC165);}
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {return _supportedInterfaces[interfaceId];}
    function _registerInterface(bytes4 interfaceId) internal virtual {require(interfaceId != 0xffffffff, "ERC165: invalid interface id");_supportedInterfaces[interfaceId] = true;}
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
     function symbol() external view returns (string memory);
     function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IDexRouter {
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountsOut(uint256 amountIn,address[] calldata path) external view returns (uint256[] memory amounts);
}

contract MrGreenNFT is ERC165, IERC721Metadata, IERC721Enumerable {
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    address constant private DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant private MRGREEN = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    address constant private WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant private BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    IDexRouter private router = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address[] public niceProjects;
    mapping(address => uint256) private niceProjectIndex;
    
    mapping (address => EnumerableSet.UintSet) private _holderTokens;
    EnumerableMap.UintToAddressMap private _tokenOwners;
    mapping (uint256 => address) private _tokenApprovals;
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    mapping(uint256 => uint256) public whichNftIsForSale;
    mapping(uint256 => uint256) public publicSalePriceOfNft;
    mapping(uint256 => bool)  public isForSalePublicly;
    mapping(uint256 => address) private whoCanBuyThisNft;
    mapping(uint256 => uint256) private privateSalePriceOfNft;
    mapping(uint256 => bool) private isForSalePrivately;
    mapping(uint256 => uint256) public lastSellPrice;

    string private _name = "MrGreenNFT";
    string private  _symbol = "GREEN";
	uint256 private currentId;
	uint256 public maxSupply = 10000;
    uint256 private _mintPrice = 1 ether;
    uint256 public tradingCommission = 5;
    uint256 public publicSaleID;
    uint256 private lastWithdrawal;
    string private _baseUri;
	string private _fileExtension;
    
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x93254542;
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    modifier onlyOwner() {if(msg.sender != MRGREEN) return; _;}

    constructor() {
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view override returns (string memory) {return _name;}
    function symbol() public view override returns (string memory) {return _symbol;}

    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),"ERC721: approve caller is not owner nor approved for all");
        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "ERC721: approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public  override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        _holderTokens[to].add(tokenId);
        _tokenOwners.set(tokenId, to);
        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        _approve(address(0), tokenId);
        _holderTokens[owner].remove(tokenId);
        _tokenOwners.remove(tokenId);
        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "Can't transfer a token that is not owned by you");
        require(to != address(0), "Don't burn your NFT, better gift it to someone");
        _beforeTokenTransfer(from, to, tokenId);
        _approve(address(0), tokenId);
        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);
        _tokenOwners.set(tokenId, to);
        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
        if (!to.isContract()) return true;
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            msg.sender,
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal {}

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        return string(abi.encodePacked(_baseUri, uint2str(tokenId), _fileExtension));
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view override returns (uint256) {
        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

	function setMaxSupply(uint256 max) external onlyOwner {
		maxSupply = max;
	}

    function mintPrice() public view returns (uint256) {
        if(totalSupply() > 69) return _mintPrice;
        if(totalSupply() > 42) return _mintPrice * 69 / 100;
        if(totalSupply() > 13) return _mintPrice * 420 / 1000;
        return _mintPrice * 1337 / 10000;
    }

    function statusUpdate() public view returns(uint256, uint256) {
        return (totalSupply(), mintPrice());
    }

    function mintNFT() external payable{
        if(msg.sender != MRGREEN) require(msg.value >= mintPrice(), "Please pay mint price");
        require(currentId <= maxSupply, "There are no more available MrGreenNFTs. Sorry.");
        uint mintIndex = currentId;
        _safeMint(msg.sender, mintIndex);
		currentId++;
    }

    function setMintPrice(uint256 price) external onlyOwner {
		_mintPrice =  price;
	}

    function setBaseUri(string memory uri) public onlyOwner {
        _baseUri = uri;
    }
    
	function setFileExtension(string memory ext) public onlyOwner {
        _fileExtension = ext;
    }

	function setTradingCommission (uint256 commission) external onlyOwner {
		tradingCommission = commission ;
        require(tradingCommission < 7, "Max comission is 7% on sales");
	}

    function divideAndConquer() external onlyOwner {
        if(niceProjects.length == 0) {
            payable(MRGREEN).transfer(address(this).balance);
            return;
        }
        payable(MRGREEN).transfer(address(this).balance/2);
        investForTheFuture();
    }


////////////////////// making sure MrGreenCrypto.com is taken care of in the future /////////////////////////////
    function investForTheFuture() internal {
        uint256 random = (block.timestamp * block.difficulty)  % niceProjects.length;

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(niceProjects[random]);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function withdrawTenPercentOfOneToken(uint256 projectNumber) external onlyOwner{
        require(lastWithdrawal + 1 weeks < block.timestamp, "This portfolio is supposed to last forever, don't withdraw everything at once");
        uint256 balancesOfProject = IBEP20(niceProjects[projectNumber]).balanceOf(address(this));
        IBEP20(niceProjects[projectNumber]).transfer(MRGREEN, balancesOfProject / 10);
        lastWithdrawal = block.timestamp;
    }

    function withdrawTwentyPercentOfOneRandomToken() external onlyOwner{
        require(lastWithdrawal + 1 weeks < block.timestamp, "This portfolio is supposed to last forever, don't withdraw everything at once");
        uint256 projectNumber = (block.timestamp * block.difficulty)  % niceProjects.length;
        uint256 balancesOfProject = IBEP20(niceProjects[projectNumber]).balanceOf(address(this));
        IBEP20(niceProjects[projectNumber]).transfer(MRGREEN, balancesOfProject / 5);
        lastWithdrawal = block.timestamp;
    }

    function z_withdrawEverythingBecauseNobodyUsesTheUtilities() external onlyOwner{
        require(valueOfPortfolio() < 500 ether, "Only give up if the funds are running too low to continue");
        uint256[] memory balancesOfNiceProjects;

        for(uint256 i = 0; i < niceProjects.length; i++){
            balancesOfNiceProjects[i] = IBEP20(niceProjects[i]).balanceOf(address(this));
        }

        for(uint256 i = 0; i < niceProjects.length; i++){
            if(balancesOfNiceProjects[i]>0){
                IBEP20(niceProjects[i]).transfer(MRGREEN, balancesOfNiceProjects[i]);
            }
        }
    }

    function valueOfPortfolio() public view returns (uint256) {
        address[] memory path = new address[](3);
        path[1] = WETH;
        path[2] = BUSD;
        uint256 busdValue;

        for(uint256 i = 0; i < niceProjects.length; i++){
            uint256 balance = IBEP20(niceProjects[i]).balanceOf(address(this));
            if(balance > 0){
                path[0] = niceProjects[i];
                busdValue += valueInBusd(path,balance);
            }
        }
        return busdValue;
    }

    function valueInBusd(address[] memory path, uint256 amount) public view returns (uint256){
        return router.getAmountsOut(amount, path)[2];
    }

    function mrGreensFavouriteProjects() public view returns(address[] memory){
        return niceProjects;
    }

    function addNiceProject(address niceProject) external onlyOwner {
        IBEP20(niceProject).approve(address(router), type(uint256).max);
        niceProjectIndex[niceProject] = niceProjects.length;
        niceProjects.push(niceProject);
    }

    function removeBadProject(address badProject) external onlyOwner {
        niceProjects[niceProjectIndex[badProject]] = niceProjects[niceProjects.length - 1];
        niceProjectIndex[niceProjects[niceProjects.length - 1]] = niceProjectIndex[badProject];
        niceProjects.pop();

        uint256 random = (block.timestamp * block.difficulty)  % niceProjects.length;

        address[] memory path = new address[](3);
        path[0] = badProject;
        path[1] = WETH;
        path[2] = address(niceProjects[random]);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
        IBEP20(badProject).balanceOf(address(this)),
        0,
        path,
        address(this),
        block.timestamp
        );
    }

//////////// integrated Marketplace /////////////////////
    function listAllNftsThatAreForSale() public view returns (uint256[] memory) {
        uint256[] memory listOfIdsForSale;
        uint256 totalNftsForSale;

        for(uint256 i = 0; i <= publicSaleID; i++){
            if(isForSalePublicly[whichNftIsForSale[i]]) {
                totalNftsForSale++;
                listOfIdsForSale[totalNftsForSale] = whichNftIsForSale[i];
            }
        }
        return listOfIdsForSale;
    }

    function listThePricesOfAllNftsThatAreForSale() public view returns (uint256[] memory) {
        uint256[] memory listOfPricesOfNfts;
        uint256 totalNftsForSale;

        for(uint256 i = 0; i <= publicSaleID; i++){
            if(isForSalePublicly[whichNftIsForSale[i]]) {
                totalNftsForSale++;
                listOfPricesOfNfts[totalNftsForSale] = publicSalePriceOfNft[whichNftIsForSale[i]];
            }
        }
        return listOfPricesOfNfts;
    }

    function listAllNftsThatAreForSaleWithTheirPrices() public view returns (uint256[] memory, uint256[] memory) {
        uint256[] memory listOfIdsForSale = listAllNftsThatAreForSale();
        uint256[] memory listOfPricesOfNfts = listThePricesOfAllNftsThatAreForSale();
        return (listOfIdsForSale,listOfPricesOfNfts);
    }

    function howManyNftsAreForSale()  public view returns (uint256) {
        uint256 totalNftsForSale;

        for(uint256 i = 0; i <= publicSaleID; i++){
            if(isForSalePublicly[whichNftIsForSale[i]]) {
                totalNftsForSale++;
            }
        }
        return totalNftsForSale;
    }

    function offerNftForPublicSale(uint256 id, uint256 sellPrice) external {
        require(ownerOf(id) == msg.sender, "Can't transfer a token that is not owned by you");
        isForSalePublicly[id] = true;
        whichNftIsForSale[publicSaleID] = id;
        publicSalePriceOfNft[id] = sellPrice;
        publicSaleID++;
    }

    function offerNftForPrivateSale(uint256 id, uint256 sellPrice, address buyer) external{
        require(ownerOf(id) == msg.sender, "Can't transfer a token that is not owned by you");
        isForSalePrivately[id] = true;
        whoCanBuyThisNft[id] = buyer;
        privateSalePriceOfNft[id] = sellPrice;
    }

    function buyNftPrivately(uint256 id) external payable {
        require(isForSalePrivately[id], "Can't buy an NFT that isn't offered for sale");
        require(whoCanBuyThisNft[id] == msg.sender, "Can't buy an NFT privately that isn't offered to you");
        require(msg.value >= privateSalePriceOfNft[id], "Must offer enough to pay the asking price");
        
        payable(ownerOf(id)).transfer(privateSalePriceOfNft[id] * (100 - tradingCommission) / 100);
        _transfer(ownerOf(id), msg.sender, id);

        isForSalePrivately[id] = false;
        whoCanBuyThisNft[id] = address(0);
        lastSellPrice[id] = privateSalePriceOfNft[id];
        privateSalePriceOfNft[id] = 0;
    }

    function buyNFTPublicly(uint256 id) external payable {
        require(isForSalePublicly[id], "Can't buy an NFT that isn't offered for sale");
        require(msg.value >= publicSalePriceOfNft[id], "Must offer enough to pay the asking price");
        
        payable(ownerOf(id)).transfer(privateSalePriceOfNft[id] * (100 - tradingCommission) / 100);
        _transfer(ownerOf(id), msg.sender, id);

        isForSalePublicly[id] = false;
        lastSellPrice[id] = publicSalePriceOfNft[id];
        publicSalePriceOfNft[id] = 0;
    }
}