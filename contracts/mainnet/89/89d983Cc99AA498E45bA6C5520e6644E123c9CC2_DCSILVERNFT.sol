/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

//SPDX-License-Identifier: MIT

//Dalmata Coin

//Site: https://dalmatacoin.com/
//Telegram: https://t.me/dalmatacoin
//Telegram Channel: https://t.me/DalmataCoinAnnouncements
//Twitter: https://twitter.com/dalmatacoin

/*The best meme coin ecosystem,
no inflation, play to win, hold to win, NFT to win, 
did you miss DogeCoin, ShibaInu and BabyDoge? Don't miss the Dalmatian coin!*/

pragma solidity ^0.8.7;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
       
        return c;
    }
}
// File: @openzeppelin/contracts/utils/Counters.sol
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)
pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }
    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
// File: @openzeppelin/contracts/utils/Strings.sol
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)
pragma solidity ^0.8.0;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
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
// File: @openzeppelin/contracts/utils/Context.sol
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// File: @openzeppelin/contracts/utils/Address.sol
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)
pragma solidity ^0.8.1;
library Address { 
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)
pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)
pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {
 
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: contracts/Ownable.sol

pragma solidity ^0.8.10;

contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: only owner can call this function");
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns(address) {
        return _owner;
    }
}
// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)
pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: @openzeppelin/contracts/token/ERC721/ERC721.sol
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)
pragma solidity ^0.8.0;

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;
    string private _name;
    string private _symbol;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

 
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }


    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// File: @openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)
pragma solidity ^0.8.0;

abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;
    mapping(uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}


interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

   modifier authorized() {require(isAuthorized(msg.sender), "!AUTHORIZED"); _;}

    function authorize(address adr) public onlyOwner {authorizations[adr] = true;}

    function unauthorize(address adr) public onlyOwner {authorizations[adr] = false;}

    function isOwner(address account) public view returns (bool) {return account == owner;}

    function isAuthorized(address adr) public view returns (bool) {return authorizations[adr];}

    function transferOwnership(address payable adr) public onlyOwner {owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IBEP20 private REWARD = IBEP20(0x621f43240E5f0486c22d58160F86371fe03BAC13);
    IBEP20 private REWARDB = IBEP20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    
    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 8);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }
    
    modifier onlyToken() {
        require(msg.sender == _token); _;
    }
    
    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
    }
    
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }
    
    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }
        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }
    
    function deposit() external payable override onlyToken {
        uint256 balanceBefore = REWARD.balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(REWARD);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amount = REWARD.balanceOf(address(this)).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }
    
    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount == 0) { return; }
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }
    
    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            REWARD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
        function claimDividend(address shareholder) external onlyToken{
        distributeDividend(shareholder);
    }
    
    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }
       
        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
       
        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }
    
    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }
    
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    
    function setDividendTokenAddress(address newToken) external onlyToken{
        REWARD = IBEP20(newToken);
    }

    address[] shareholdersB;
    mapping (address => uint256) shareholderIndexesB;
    mapping (address => uint256) shareholderClaimsB;

    mapping (address => Share) public sharesB;

    uint256 public totalSharesB;
    uint256 public totalDividendsB;
    uint256 public totalDistributedB;
    uint256 public dividendsPerShareB;
    uint256 public dividendsPerShareAccuracyFactorB = 10 ** 36;
    
    uint256 public minPeriodB = 1 hours;
    uint256 public minDistributionB = 1 * (10 ** 8);

    uint256 currentIndexB;

    function setDistributionCriteriaB(uint256 _minPeriod, uint256 _minDistribution) external onlyToken {
        minPeriodB = _minPeriod;
        minDistributionB = _minDistribution;
    }
    
    function setShareB(address shareholder, uint256 amount) external  onlyToken {
        if(sharesB[shareholder].amount > 0){
            distributeDividendB(shareholder);
        }
        if(amount > 0 && sharesB[shareholder].amount == 0){
            addShareholderB(shareholder);
        }else if(amount == 0 && sharesB[shareholder].amount > 0){
            removeShareholderB(shareholder);
        }
        totalSharesB = totalSharesB.sub(sharesB[shareholder].amount).add(amount);
        sharesB[shareholder].amount = amount;
        sharesB[shareholder].totalExcluded = getCumulativeDividendsB(sharesB[shareholder].amount);
    }
    
    function depositB() external payable  onlyToken {
        uint256 balanceBefore = REWARDB.balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(REWARDB);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amount = REWARDB.balanceOf(address(this)).sub(balanceBefore);
        totalDividendsB = totalDividendsB.add(amount);
        dividendsPerShareB = dividendsPerShareB.add(dividendsPerShareAccuracyFactorB.mul(amount).div(totalSharesB));
    }
    
    function processB(uint256 gas) external onlyToken {
        uint256 shareholderCount = shareholdersB.length;
        if(shareholderCount == 0) { return; }
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndexB >= shareholderCount){
                currentIndexB = 0;
            }
            if(shouldDistributeB(shareholders[currentIndexB])){
                distributeDividendB(shareholders[currentIndexB]);
            }
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistributeB(address shareholder) internal view returns (bool) {
        return shareholderClaimsB[shareholder] + minPeriodB < block.timestamp
                && getUnpaidEarningsB(shareholder) > minDistributionB;
    }
    
    function distributeDividendB(address shareholder) internal {
        if(sharesB[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarningsB(shareholder);
        if(amount > 0){
            totalDistributedB = totalDistributedB.add(amount);
            REWARD.transfer(shareholder, amount);
            shareholderClaimsB[shareholder] = block.timestamp;
            sharesB[shareholder].totalRealised = sharesB[shareholder].totalRealised.add(amount);
            sharesB[shareholder].totalExcluded = getCumulativeDividendsB(sharesB[shareholder].amount);
        }
    }
    
        function claimDividendB(address shareholder) external onlyToken{
        distributeDividendB(shareholder);
    }
    
    function getUnpaidEarningsB(address shareholder) public view returns (uint256) {
        if(sharesB[shareholder].amount == 0){ return 0; }
       
        uint256 shareholderTotalDividends = getCumulativeDividendsB(sharesB[shareholder].amount);
        uint256 shareholderTotalExcluded = sharesB[shareholder].totalExcluded;
       
        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }
    
    function getCumulativeDividendsB(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShareB).div(dividendsPerShareAccuracyFactorB);
    }
    
    function addShareholderB(address shareholder) internal {
        shareholderIndexesB[shareholder] = shareholdersB.length;
        shareholdersB.push(shareholder);
    }
    
    function removeShareholderB(address shareholder) internal {
        shareholdersB[shareholderIndexesB[shareholder]] = shareholdersB[shareholders.length-1];
        shareholderIndexesB[shareholdersB[shareholders.length-1]] = shareholderIndexesB[shareholder];
        shareholdersB.pop();
    }
    
    function setDividendTokenAddressB(address newToken) external onlyToken{
        REWARDB = IBEP20(newToken);
    }
}
// File: contracts/DalmataStake.sol

contract DalmataStake {

    constructor() {
        stakeholders.push();
    }
    uint256 private rewardPerHour = 10000;
   
    struct Stake{
        address user;
        uint256 amount;
        uint256 since;
        uint256 claimable;
    }

    struct Stakeholder{
        address user;
        Stake[] address_stakes;
        
    }
     struct StakingSummary{
         uint256 total_amount;
        uint256 total_toclaim;
         Stake[] stakes;
         
     }
   
    Stakeholder[] internal stakeholders;
   
    mapping(address => uint256) internal stakes;
    
     event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp);
  
    function _addStakeholder(address staker) internal returns (uint256){
        stakeholders.push();
        uint256 userIndex = stakeholders.length - 1;
        stakeholders[userIndex].user = staker;
        stakes[staker] = userIndex;
        return userIndex; 
    }
    function _stake(uint256 _amount) internal{
        require(_amount > 0, "Cannot stake nothing");
   
        uint256 index = stakes[msg.sender];

        uint256 timestamp = block.timestamp;

        if(index == 0){
            index = _addStakeholder(msg.sender);
        }

        stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, timestamp,0));
        emit Staked(msg.sender, _amount, index,timestamp);
    }

      function calculateStakeReward(Stake memory _current_stake) internal view returns(uint256){
        
          return (((block.timestamp - _current_stake.since) / 1 hours) * _current_stake.amount) / rewardPerHour;
      }
   
     function _withdrawStake() internal returns(uint256){
        uint256 user_index = stakes[msg.sender];
       uint256 Reward = _Rewards(user_index, msg.sender);
        return Reward;

     }
  
    function hasStake(address _staker) public view returns(StakingSummary memory){
        uint256 totalStakeAmount; 
        uint256 totalReward; 

        StakingSummary memory summary = StakingSummary(0, 0,  stakeholders[stakes[_staker]].address_stakes);
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1){
           uint256 availableReward = calculateStakeReward(summary.stakes[s]);
           summary.stakes[s].claimable = availableReward;
           totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
           totalReward = totalReward+summary.stakes[s].claimable;
       }
       summary.total_amount = totalStakeAmount;
       summary.total_toclaim = totalReward;
        return summary;
    } 
    function _Rewards(uint256 ui, address _staker) internal returns (uint256) {
        uint256 totalReward;
uint256 totalStakeAmount; 
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
            for (uint256 s = 0; s < summary.stakes.length; s += 1) {
                 uint256 availableReward = calculateStakeReward(summary.stakes[s]);
           summary.stakes[s].claimable = availableReward;
                totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
                totalReward = totalReward+summary.stakes[s].claimable;
            }
            
        delete stakeholders[ui];
        totalReward = totalStakeAmount + totalReward;
        return totalReward;
    }
}

contract Fiwi {
    uint256 public minimumBet = 10000000000000;
    string[] private _gnames;
    uint256[][] private _ggameAttributes;
    uint256[][] private _gpro;
    uint256[][] private _gprod;
    constructor() {
        betholders.push();
        gindexs.push();
    }
    struct Bet {
        address user;
        uint256 amount;
        uint256 since;
        uint256 claimable;
        uint256 multi;
        uint256 index;
        uint256 rf;
    }

    struct uholder {
        address user;
        Bet[] address_bets;
    }

    struct BetSummary {
        uint256 total_amount;
        uint256 total_toclaim;
        Bet[] bets;
    }

    struct Gindex {
        address user;
        string _name;
        uint256[] _gameAttributes;
        uint256[] _pro;
        uint256[] _prod;
    }
    struct Ginx {
        address user;
        Gindex[] inds;
    }
    struct GSummary {
        Gindex[] gs;
    }
    uholder[] internal betholders;
    Ginx[] internal gindexs;

    mapping(address => uint256) internal bets;
    mapping(address => uint256) internal gs;

    event insert(
        address indexed user,
        uint256 amount,
        uint256 index,
        uint256 timestamp,
        uint256 multi,
        uint256 gg,
        uint256 rf
    );

    event stop(uint256[] _value);

    function _setgames(
        string[] memory gnames,
        uint256[][] memory ggameAttributes,
        uint256[][] memory gpro,
        uint256[][] memory gprod
    ) internal {
        _gnames = gnames;
        _ggameAttributes = ggameAttributes;
        _gpro = gpro;
        _gprod = gprod;
    }

    function getnumber(
        uint256 value,
        uint256[] memory attr,
        uint256[] memory _pro
    ) internal view returns (uint256) {
        uint256 max = 1000;
        uint256 pp = 0;
        uint256 resultwin = value;
        uint256 r = 0;
        uint256 randomHash = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty))
        );
        pp = attr[6];
        max = attr[1];
        r = randomHash % max;

        if (pp == 0) {
            uint256 n = value;
            uint256 d = 0;
            if (r > 10) {
                d = randomHash % r;
                if (d == 0) {
                    n = r;
                } else {
                    n = r / d;
                }
            } else {
                if (r == 0) {
                    r = 1;
                    n = r;
                } else {
                    n = r;
                }
            }

            resultwin = n;
        } else {
            uint256 pro = 0;
            pro = _pro[r];
            resultwin = pro;
        }
        return resultwin;
    }
    function getnumberpoint(
        uint256 value,
        uint256[] memory attr,
        uint256[] memory _pro
    ) internal view returns (uint256) {
        uint256 max = 99;
        uint256 pp = 0;
        uint256 resultwin = value;
        uint256 r = value;

        uint256 randomHash = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty))
        );
        pp = attr[6];
        max = attr[2];
        r = randomHash % max;

        if (pp == 0) {
            if (r == 0) {
                r = 1;
                resultwin = r;
            } else {
                resultwin = r;
            }
        } else {
            //
            uint256 pro = 0;
            pro = _pro[r];
            resultwin = pro;
        }

        return resultwin;
    }
    function bet(
        uint256 _teamSelected,
        uint256 _point,
        uint256 _amount,
        uint256 _index,
        address _ower
    ) internal view returns (uint256[6] memory) {
        require(_amount >= minimumBet, "Bet amount is very low");
        require(_teamSelected >= 1);
        require(_point < 100);
        uint256[] memory attr = _ggameAttributes[_index];
        uint256[] memory pro = _gpro[_index];
        uint256[] memory prod = _gprod[_index];

        uint256 Result = getnumber(_teamSelected, attr, pro);
        uint256 pointer = getnumberpoint(_point, attr, prod);

        uint256[6] memory aa = _distribute(
            _teamSelected,
            _point,
            pointer,
            Result,
            _amount,
            _index,
            _ower,
            attr
        );

        return aa;
    }
    function _distribute(
        uint256 betin,
        uint256 point,
        uint256 _pointer,
        uint256 result,
        uint256 amount,
        uint256 inx,
        address ower,
        uint256[] memory attr
    ) internal view returns (uint256[6] memory) {
        uint256 lam = ((result * 100) + _pointer);
        uint256 res = ((betin * 100) + point);
        uint256 pe = attr[3];
        uint256 pd = attr[4];
        if (pd == 1) {
            return _betf(amount, betin, point, inx, res, lam, pe, ower, attr);
        } else {
            return _betff(amount, betin, inx, lam, pe, result, ower, attr);
        }
    }
    function _betf(
        uint256 _amount,
        uint256 betv,
        uint256 betz,
        uint256 inx,
        uint256 res,
        uint256 lam,
        uint256 pe,
        address ower,
        uint256[] memory attr
    ) internal view returns (uint256[6] memory) {
        uint256[6] memory aa;
        if (pe == 1) {
            if (res == lam) {
                //win
                aa = _bet(_amount, betv, betz, inx, res, ower, lam, attr);
            } else {
                //loses
                aa = _bet(_amount, 0, 0, inx, res, ower, lam, attr);
            }
        } else {
            if (res < lam) {
                //win
                //_bet(amount, bet, inx);
                aa = _bet(_amount, betv, betz, inx, res, ower, lam, attr);
            } else {
                //loses
                aa = _bet(_amount, 0, 0, inx, res, ower, lam, attr);
            }
        }
        return aa;
    }
    function _betff(
        uint256 amount,
        uint256 betv,
        uint256 inx,
        uint256 lam,
        uint256 pe,
        uint256 result,
        address ower,
        uint256[] memory attr
    ) internal view returns (uint256[6] memory) {
        uint256[6] memory aa;
        if (pe == 1) {
            if (betv == result) {
                //win
                aa = _bet(amount, betv, 0, inx, betv, ower, lam, attr);
            } else {
                //loses
                aa = _bet(amount, 0, 0, inx, betv, ower, lam, attr);
            }
        } else {
            if (betv < result) {
                //win
                aa = _bet(amount, betv, 0, inx, betv, ower, lam, attr);
            } else {
                //loses
                aa = _bet(amount, 0, 0, inx, betv, ower, lam, attr);
            }
        }
        return aa;
    }
    function _bet(
        uint256 _amount,
        uint256 betv,
        uint256 betz,
        uint256 inx,
        uint256 _res,
        address ower,
        uint256 _rf,
        uint256[] memory attr
    ) internal view returns (uint256[6] memory) {
        require(_amount > 0, "Cannot betting nothing");
        uint256 timestamp = block.timestamp;
        uint256 am = _amount / minimumBet;
        uint256 rw = getreward(am, betv, betz, attr);
        return [_amount, timestamp, rw, _res, inx, _rf];

    }
    function getreward(
        uint256 am,
        uint256 betv,
        uint256 betz,
        uint256[] memory attr
    ) internal view returns (uint256) {
        uint256 rew = 0;
        uint256 rw = 0;
        rew = attr[5];

        if (rew == 0) {
            rw = (((((am * 100) * betv) + (am * betz))) * minimumBet) / 100;
        } else {
            if (betv == 0) {
                rw = 0;
            } else {
                rw = (am * rew) * minimumBet;
            }
        }
        return rw;
    }

    function showGAttributes() public view returns (uint256[][] memory) {
        return _ggameAttributes;
    }

    function showGPro() public view returns (uint256[][] memory) {
        return _gpro;
    }

    function showGProd() public view returns (uint256[][] memory) {
        return _gprod;
    }

    function showGNames() public view returns (string[] memory) {
        return _gnames;
    }
}

contract DalmataCoin is IBEP20, Auth, Fiwi, DalmataStake{
    using SafeMath for uint256;
    address WBNB     = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 
    address DEAD     = 0x000000000000000000000000000000000000dEaD;
    address ZERO     = 0x0000000000000000000000000000000000000000;
    string constant _name = "Dalmata Coin";
    string constant _symbol = "DC";
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 1000000 * (10 ** _decimals);
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;
    uint256 liquidityFee = 100;
    uint256 buybackFee = 0;
    uint256 reflectionFee = 1000;
    uint256 marketingdevelopmentFee = 300;
    uint256 totalFee = 1400;
    uint256 burnFee = 100;
    uint256 extraFeeOnSell = 300;
    uint256 feeDenominator = 10000;
    address public developmentReceiver;
    address public marketingFeeReceiver;
    uint256 targetLiquidity = 25;
    uint256 targetLiquidityDenominator = 100;
    IDEXRouter public router;
    address public pair;
    uint256 public launchedAt;
    uint256 buybackMultiplierNumerator = 200;
    uint256 buybackMultiplierDenominator = 100;
    uint256 buybackMultiplierTriggeredAt;
    uint256 buybackMultiplierLength = 30 minutes;
    bool public autoBuybackEnabled = false;
    bool public autoBuybackMultiplier = true;
    uint256 autoBuybackCap;
    uint256 autoBuybackAccumulator;
    uint256 autoBuybackAmount;
    uint256 autoBuybackBlockPeriod;
    uint256 autoBuybackBlockLast;
    DividendDistributor distributor;
    uint256 distributorGas = 250000;
    bool public swapEnabled = true;
    mapping (address => uint) private cooldownTimer;
    uint256 public swapThreshold = _totalSupply / 500; 
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    DalmataCoin private ct = this;
    //nft contracts
    DCGOLDNFT private _NFTCTG;
    DCSILVERNFT private _NFTCTS;
    DCBRONZENFT private _NFTCTB;
    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        distributor = new DividendDistributor(address(router));
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;
        address _inicial = msg.sender; //change;
        isFeeExempt[_inicial] = true;
        isTxLimitExempt[_inicial] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        developmentReceiver = msg.sender;
        marketingFeeReceiver = msg.sender;
        _balances[_inicial] = _totalSupply;
        emit Transfer(address(0), _inicial, _totalSupply);
    }
    receive() external payable { }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
        function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 burnFeeAmount = amount.mul(burnFee).div(feeDenominator);
        uint256 amountWithFee = amount.sub(burnFeeAmount);
        if(inSwap){
            if (burnFeeAmount > 0) { _burn(sender, burnFeeAmount); }
            return _basicTransfer(sender, recipient, amountWithFee); 
        }  
        if(shouldSwapBack()){ swapBack(); }
        
        if(shouldAutoBuyback()){ triggerAutoBuyback(); }
        
        if(!launched() && recipient == pair){ require(_balances[sender] > 0); launch(); }
        
        _balances[sender] = _balances[sender].sub(amountWithFee, "Insufficient Balance");
        if (burnFeeAmount > 0) { _burn(sender, burnFeeAmount); }
        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amountWithFee) : amountWithFee;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }
        
        try distributor.process(distributorGas) {} catch {}

        if(!isDividendExempt[sender]){ try distributor.setShareB(sender, _balances[sender]) {} catch {} }
        
        if(!isDividendExempt[recipient]){ try distributor.setShareB(recipient, _balances[recipient]) {} catch {} }
        
        try distributor.processB(distributorGas) {} catch {}
        
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }
    
    function getTotalFee(bool selling) public view returns (uint256) {
        uint256 _totalFee = totalFee;
        if(launchedAt + 1 >= block.number){ return feeDenominator.sub(1); }
        if(selling && buybackMultiplierTriggeredAt.add(buybackMultiplierLength) > block.timestamp){ return getMultipliedFee(); }
        if (selling) {
            _totalFee = totalFee.add(extraFeeOnSell);
        }
        return _totalFee;
    }
    
    function getMultipliedFee() public view returns (uint256) {
        uint256 remainingTime = buybackMultiplierTriggeredAt.add(buybackMultiplierLength).sub(block.timestamp);
        uint256 feeIncrease = totalFee.mul(buybackMultiplierNumerator).div(buybackMultiplierDenominator).sub(totalFee);
        return totalFee.add(feeIncrease.mul(remainingTime).div(buybackMultiplierLength));
    }
    
    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(feeDenominator);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }
    
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }
    
    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        uint256 balanceBefore = address(this).balance;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap,0,path,address(this),block.timestamp);
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingdevelopmentFee).div(totalBNBFee);
        try distributor.deposit{value: amountBNBReflection / 2}() {} catch {}
        try distributor.depositB{value: amountBNBReflection / 2}() {} catch {}
        (bool success, /* bytes memory data */) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        require(success, "receiver rejected ETH transfer");
        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(address(this),amountToLiquify,0,0,developmentReceiver,block.timestamp);
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }
    function shouldAutoBuyback() internal view returns (bool) {
        return msg.sender != pair
            && !inSwap
            && autoBuybackEnabled
            && autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number
            && address(this).balance >= autoBuybackAmount;
    }

    function triggerManualBuyback(uint256 amount, bool triggerBuybackMultiplier) external authorized {
        buyTokens(amount, DEAD);
        if(triggerBuybackMultiplier){
            buybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(buybackMultiplierLength);
        }
    }
    
    function clearBuybackMultiplier() external authorized {
        buybackMultiplierTriggeredAt = 0;
    }
    
    function triggerAutoBuyback() internal {
        buyTokens(autoBuybackAmount, DEAD);
        if(autoBuybackMultiplier){
            buybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(buybackMultiplierLength);
        }
        autoBuybackBlockLast = block.number;
        autoBuybackAccumulator = autoBuybackAccumulator.add(autoBuybackAmount);
        if(autoBuybackAccumulator > autoBuybackCap){ autoBuybackEnabled = false; }
    }
    
    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(0,path,to,block.timestamp);
    }
    
    function setIsTimelockExempt(address holder, bool exempt) external authorized {
        isTimelockExempt[holder] = exempt;
    }
    
    function setAutoBuybackSettings(bool _enabled, uint256 _cap, uint256 _amount, uint256 _period, bool _autoBuybackMultiplier) external authorized {
        autoBuybackEnabled = _enabled;
        autoBuybackCap = _cap;
        autoBuybackAccumulator = 0;
        autoBuybackAmount = _amount;
        autoBuybackBlockPeriod = _period;
        autoBuybackBlockLast = block.number;
        autoBuybackMultiplier = _autoBuybackMultiplier;
    }
    
    function setBuybackMultiplierSettings(uint256 numerator, uint256 denominator, uint256 length) external authorized {
        require(numerator / denominator <= 2 && numerator > denominator);
        buybackMultiplierNumerator = numerator;
        buybackMultiplierDenominator = denominator;
        buybackMultiplierLength = length;
    }
    
    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }
    
    function launch() internal {
        launchedAt = block.number;
    }
    
    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
            distributor.setShareB(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
            distributor.setShareB(holder, _balances[holder]);
        }
    }
    function burn(uint256 amount) external {
    _burn(msg.sender, amount);
    }

  function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Cannot mint to zero address");
        _totalSupply = _totalSupply + (amount);
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal {
    require(amount != 0);
    require(amount <= _balances[account]);
    _balances[account] = _balances[account].sub(amount);
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }
  
    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }
    
    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }
    
    function setFees(uint256 _liquidityFee, uint256 _buybackFee, uint256 _reflectionFee, uint256 _marketingdevelopmentFee, uint256 _burnFee, uint256 _extraFeeOnSell, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        buybackFee = _buybackFee;
        reflectionFee = _reflectionFee;
        marketingdevelopmentFee = _marketingdevelopmentFee;
        burnFee = _burnFee;
        totalFee = _liquidityFee.add(_buybackFee).add(_reflectionFee).add(_marketingdevelopmentFee);
        extraFeeOnSell = _extraFeeOnSell;
        feeDenominator = _feeDenominator;
    }
    
    function setFeeReceivers(address _developmentReceiver, address _marketingFeeReceiver) external authorized {
        developmentReceiver = _developmentReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }
    
    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }
    
    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }
    
    function manualSend() external authorized {
        uint256 contractETHBalance = address(this).balance;
        payable(marketingFeeReceiver).transfer(contractETHBalance);
    }
    
        function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
        distributor.setDistributionCriteriaB(_minPeriod, _minDistribution);
    }
    
        function claimDividend() external {
        distributor.claimDividend(msg.sender);
        distributor.claimDividendB(msg.sender);
    }
    
        function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        return distributor.getUnpaidEarnings(shareholder);
    } 
    function getUnpaidEarningsB(address shareholder) public view returns (uint256) {
        return distributor.getUnpaidEarningsB(shareholder);
    } 
    
    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 350000);
        distributorGas = gas;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
    
    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }
    
    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function setDividendToken(address _newContract) external authorized {
        distributor.setDividendTokenAddress(_newContract);
  	}
         function setDividendTokenB(address _newContract) external authorized {
        distributor.setDividendTokenAddressB(_newContract);
  	}
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
    function setgames(
        string[] memory gnames,
        uint256[][] memory ggameAttributes,
        uint256[][] memory gpro,
        uint256[][] memory gprod
    ) public onlyOwner {
        _setgames(gnames, ggameAttributes, gpro, gprod);
    }
    function _set_NFTContracts(DCGOLDNFT _GOLD, DCSILVERNFT _SILVER, DCBRONZENFT _BRONZE) public onlyOwner {
        _NFTCTG = _GOLD;
        _NFTCTS = _SILVER;
        _NFTCTB = _BRONZE;
    }
    event result(uint256 _value);
    function betting(
        uint256 _betvalue,
        uint256 _point,
        uint256 _amount,
        uint256 _index
    ) public {
        require(_amount < _balances[msg.sender], "Can't bet more than you own");
        uint256[6] memory aa = bet(
            _betvalue,
            _point,
            _amount,
            _index,
            owner
        );
        getRewardlowgas(aa[2], _amount);
        emit result(aa[5]);
    }
    function getRewardlowgas(uint256 _amint, uint256 _amount) internal {
        uint256 amount_to_mint = _amint;
        if (amount_to_mint > 0) {
            uint256 am = amount_to_mint - _amount;
            uint256 ctbalance = _balances[address(ct)];
            if(ctbalance < am){
                _mint(msg.sender, ((am / 100) * 100));
            }else{
                _basicTransfer(address(ct), msg.sender, ((am / 100) * 100));
            } 
        } else {
                  _basicTransfer(msg.sender, address(ct), _amount);
        }
    }
    function stake(uint256 _amount) public {
        require(
            _amount < _balances[msg.sender],
            "Cannot stake more than you own"
        );
        _stake(_amount);
        _basicTransfer(msg.sender, address(ct), _amount);
    }
    function withdrawStake() public {
        uint256 amount_to_mint = _withdrawStake();
        require(amount_to_mint > 0, "Cannot withdraw 0 tokens");
        require(
            amount_to_mint >= 1000000000000000000,
            "Cannot withdraw less then 1 DC"
        );
        uint256 ctbalance = _balances[address(ct)];
            if(ctbalance < amount_to_mint){
                _mint(msg.sender, amount_to_mint);
            }else{
                _basicTransfer(address(ct), msg.sender, amount_to_mint);
            }
        }
    function withdrawRewardnft(uint256 a) public {
        uint256 amount_to_mint = 0;
        if (a == 0) {
            amount_to_mint = _NFTCTG._withdrawRewardnft(msg.sender);
        } else {
            if (a == 1) {
                amount_to_mint = _NFTCTS._withdrawRewardnft(msg.sender);
            } else {
                if (a == 2) {
                    amount_to_mint = _NFTCTB._withdrawRewardnft(msg.sender);
                } else {}
            }
        }
        require(amount_to_mint > 0, "Cannot withdraw 0 tokens");
        require(
            amount_to_mint >= 1000000000000000000,
            "Cannot withdraw less then 1 DC"
        );

         uint256 ctbalance = _balances[address(ct)];
            if(ctbalance < amount_to_mint){
                _mint(msg.sender, amount_to_mint);
            }else{
                _basicTransfer(address(ct), msg.sender, amount_to_mint);
            }
    }
}

contract DCGOLDNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    constructor() ERC721("DC COMUNITY NFT", "DCN") {
        stakeholders.push();
    }
    string private turi;
    address private ower = msg.sender;
    uint256 private rewardPerHour = 1000;
    address private mainct;
    uint256 private pricenft = 1000000000000000000;
    uint256 private amountinstake = 1000000000000000000000;
    function set_pricenft(uint256 bnbvalue) public onlyOwner{
     pricenft = bnbvalue;
    }
      function set_amountstake(uint256 a) public onlyOwner{
     amountinstake = a;
    }
    function set_mainct(address addr) public onlyOwner{
     mainct = addr;
    }
    function set_turi(string memory addr) public onlyOwner{
        turi = addr;
    }
    struct Stake {
        address user;
        uint256 amount;
        uint256 since;
        uint256 claimable;
    }
    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }
    struct StakingSummary {
        uint256 total_amount;
        uint256 total_toclaim;
        Stake[] stakes;
    }
    Stakeholder[] internal stakeholders;
    mapping(address => uint256) internal stakes;
    event Staked(
        address indexed user,
        uint256 amount,
        uint256 index,
        uint256 timestamp
    );
    function _addStakeholdernft(address staker) internal returns (uint256) {
        stakeholders.push();
        uint256 userIndex = stakeholders.length - 1;
        stakeholders[userIndex].user = staker;
        stakes[staker] = userIndex;
        return userIndex;
    }
    function _stakenftp() external payable {
        uint256 amount = msg.value;
        require(amount >= pricenft, "You need to send 1 BNB ");
        uint256 aa = hasStakenft(msg.sender);
        require(aa <= 0, "You're already stake");
        _stakenft(amountinstake, msg.sender);
        address recipient = address(ower);
        payable(recipient).transfer(amount);
    }
    function _givewaynft(address premier) public onlyOwner {
        uint256 aa = hasStakenft(premier);
        require(aa <= 0, "You're already stake");
        _stakenft(amountinstake, premier);
    }
    function _stakenft(uint256 _amount, address addr) internal {
        require(_amount > 0, "Cannot stake nothing");
        _awardItem(addr, turi);
        uint256 index = stakes[addr];
        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholdernft(addr);
        }
        stakeholders[index].address_stakes.push(
            Stake(addr, _amount, timestamp, 0)
        );
        emit Staked(addr, _amount, index, timestamp);
    }
    function calculateNftReward(Stake memory _current_stake)
        internal
        view
        returns (uint256)
    {
        return
            (((block.timestamp - _current_stake.since) / 1 hours) *
                _current_stake.amount) / rewardPerHour;
    }
    function _withdrawRewardnft(address user) external returns (uint256) {
        require(msg.sender == mainct, "never use this function alone ");
        uint256 user_index = stakes[user];
        uint256 Reward = _Rewardsnft(user_index, user);
        return Reward;
    }

    function _claimableRewardnft(address user) external view returns (uint256) {
        uint256 user_index = stakes[user];
        uint256 Reward = _RewardsnftClaim(user_index, user);
        return Reward;
    }

    function hasStakenft(address _staker) internal view returns (uint256) {
        uint256 totalStakeAmount;
        uint256 totalReward;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }
        summary.total_amount = totalStakeAmount;
        summary.total_toclaim = totalReward;
        return totalStakeAmount;
    }

    function _awardItem(address player, string memory tokenURI)
        internal
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }
    function _Rewardsnft(uint256 ui, address _staker)
        internal
        returns (uint256)
    {
        uint256 totalReward;
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }

        delete stakeholders[ui];
        totalReward = totalReward;
        _stakenftnc(totalStakeAmount, _staker);
        return totalReward;
    }

    function _RewardsnftClaim(uint256 ui, address _staker)
        internal
        view
        returns (uint256)
    {
        uint256 totalReward;
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }
        totalReward = totalReward;
        return totalReward;
    }
    function _stakenftnc(uint256 _amount, address addr) internal {
        require(_amount > 0, "Cannot stake nothing");
        uint256 index = stakes[addr];
        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholdernft(addr);
        }
        stakeholders[index].address_stakes.push(
            Stake(addr, _amount, timestamp, 0)
        );
        emit Staked(addr, _amount, index, timestamp);
    }
}

contract DCSILVERNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    constructor() ERC721("DC COMUNITY NFT", "DCN") {
        stakeholders.push();
    }
    string private turi;
    address private ower = msg.sender;
    uint256 private rewardPerHour = 1000;
    address private mainct;
    uint256 private pricenft = 500000000000000000;
    uint256 private amountinstake = 500000000000000000000;
    function set_pricenft(uint256 bnbvalue) public onlyOwner{
     pricenft = bnbvalue;
    }
      function set_amountstake(uint256 a) public onlyOwner{
     amountinstake = a;
    }
    function set_mainct(address addr) public onlyOwner{
     mainct = addr;
    }
    function set_turi(string memory addr) public onlyOwner{
        turi = addr;
    }
    struct Stake {
        address user;
        uint256 amount;
        uint256 since;
        uint256 claimable;
    }
    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }
    struct StakingSummary {
        uint256 total_amount;
        uint256 total_toclaim;
        Stake[] stakes;
    }
    Stakeholder[] internal stakeholders;
    mapping(address => uint256) internal stakes;
    event Staked(
        address indexed user,
        uint256 amount,
        uint256 index,
        uint256 timestamp
    );
    function _addStakeholdernft(address staker) internal returns (uint256) {
        stakeholders.push();
        uint256 userIndex = stakeholders.length - 1;
        stakeholders[userIndex].user = staker;
        stakes[staker] = userIndex;
        return userIndex;
    }
    function _stakenftp() external payable {
        uint256 amount = msg.value;
        require(amount >= pricenft, "You need to send 0.50 BNB ");
        uint256 aa = hasStakenft(msg.sender);
        require(aa <= 0, "You're already stake");
        _stakenft(amountinstake, msg.sender);
        address recipient = address(ower);
        payable(recipient).transfer(amount);
    }
     function _givewaynft(address premier) public onlyOwner {
        uint256 aa = hasStakenft(premier);
        require(aa <= 0, "You're already stake");
        _stakenft(amountinstake, premier);
    }

    function _stakenft(uint256 _amount, address addr) internal {
        require(_amount > 0, "Cannot stake nothing");
        _awardItem(addr, turi);
        uint256 index = stakes[addr];
        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholdernft(addr);
        }
        stakeholders[index].address_stakes.push(
            Stake(addr, _amount, timestamp, 0)
        );
        emit Staked(addr, _amount, index, timestamp);
    }

    function calculateNftReward(Stake memory _current_stake)
        internal
        view
        returns (uint256)
    {
        return
            (((block.timestamp - _current_stake.since) / 1 hours) *
                _current_stake.amount) / rewardPerHour;
    }
    function _withdrawRewardnft(address user) external returns (uint256) {
        require(msg.sender == mainct, "never use this function alone ");
        uint256 user_index = stakes[user];
        uint256 Reward = _Rewardsnft(user_index, user);
        return Reward;
    }
    function _claimableRewardnft(address user) external view returns (uint256) {
        uint256 user_index = stakes[user];
        uint256 Reward = _RewardsnftClaim(user_index, user);
        return Reward;
    }
    function hasStakenft(address _staker) internal view returns (uint256) {
        uint256 totalStakeAmount;
        uint256 totalReward;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }
        summary.total_amount = totalStakeAmount;
        summary.total_toclaim = totalReward;
        return totalStakeAmount;
    }
    function _awardItem(address player, string memory tokenURI)
        internal
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _tokenIds.increment();
        return newItemId;
    }
    function _Rewardsnft(uint256 ui, address _staker)
        internal
        returns (uint256)
    {
        uint256 totalReward;
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }

        delete stakeholders[ui];
        totalReward = totalReward;
        _stakenftnc(totalStakeAmount, _staker);
        return totalReward;
    }
    function _RewardsnftClaim(uint256 ui, address _staker)
        internal
        view
        returns (uint256)
    {
        uint256 totalReward;
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }

        totalReward = totalReward;
        return totalReward;
    }
    function _stakenftnc(uint256 _amount, address addr) internal {
        require(_amount > 0, "Cannot stake nothing");
        uint256 index = stakes[addr];
        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholdernft(addr);
        }
        stakeholders[index].address_stakes.push(
            Stake(addr, _amount, timestamp, 0)
        );
        emit Staked(addr, _amount, index, timestamp);
    }
}

contract DCBRONZENFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    constructor() ERC721("DC COMUNITY NFT", "DCN") {
        stakeholders.push();
    }
    string private turi;
    address private ower = msg.sender;
    uint256 private rewardPerHour = 1000;
    address private mainct;
    uint256 private pricenft = 100000000000000000;
    uint256 private amountinstake = 100000000000000000000;
    function set_pricenft(uint256 bnbvalue) public onlyOwner{
     pricenft = bnbvalue;
    }
      function set_amountstake(uint256 a) public onlyOwner{
     amountinstake = a;
    }
    function set_mainct(address addr) public onlyOwner{
     mainct = addr;
    }
    function set_turi(string memory addr) public onlyOwner{
        turi = addr;
    }
    struct Stake {
        address user;
        uint256 amount;
        uint256 since;
        uint256 claimable;
    }
    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }
    struct StakingSummary {
        uint256 total_amount;
        uint256 total_toclaim;
        Stake[] stakes;
    }
    Stakeholder[] internal stakeholders;
    mapping(address => uint256) internal stakes;
    event Staked(
        address indexed user,
        uint256 amount,
        uint256 index,
        uint256 timestamp
    );
    function _addStakeholdernft(address staker) internal returns (uint256) {
        stakeholders.push();
        uint256 userIndex = stakeholders.length - 1;
        stakeholders[userIndex].user = staker;
        stakes[staker] = userIndex;
        return userIndex;
    }
    function _stakenftp() external payable {
        uint256 amount = msg.value;
        require(amount >= pricenft, "You need to send 0.10 BNB ");
        uint256 aa = hasStakenft(msg.sender);
        require(aa <= 0, "You're already stake");
        _stakenft(amountinstake, msg.sender);
        address recipient = address(ower);
        payable(recipient).transfer(amount);
    }
 function _givewaynft(address premier) public onlyOwner {
        uint256 aa = hasStakenft(premier);
        require(aa <= 0, "You're already stake");
        _stakenft(amountinstake, premier);

    }
    function _stakenft(uint256 _amount, address addr) internal {
        require(_amount > 0, "Cannot stake nothing");
        _awardItem(addr, turi);
        uint256 index = stakes[addr];
        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholdernft(addr);
        }
        stakeholders[index].address_stakes.push(
            Stake(addr, _amount, timestamp, 0)
        );
        emit Staked(addr, _amount, index, timestamp);
    }
    function calculateNftReward(Stake memory _current_stake)
        internal
        view
        returns (uint256)
    {
        return
            (((block.timestamp - _current_stake.since) / 1 hours) *
                _current_stake.amount) / rewardPerHour;
    }
    function _withdrawRewardnft(address user) external returns (uint256) {
        require(msg.sender == mainct, "never use this function alone ");
        uint256 user_index = stakes[user];
        uint256 Reward = _Rewardsnft(user_index, user);
        return Reward;
    }
    function _claimableRewardnft(address user) external view returns (uint256) {
        uint256 user_index = stakes[user];
        uint256 Reward = _RewardsnftClaim(user_index, user);
        return Reward;
    }
    function hasStakenft(address _staker) internal view returns (uint256) {
        uint256 totalStakeAmount;
        uint256 totalReward;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }
        summary.total_amount = totalStakeAmount;
        summary.total_toclaim = totalReward;
        return totalStakeAmount;
    }
    function _awardItem(address player, string memory tokenURI)
        internal
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _tokenIds.increment();
        return newItemId;
    }
    function _Rewardsnft(uint256 ui, address _staker)
        internal
        returns (uint256)
    {
        uint256 totalReward;
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }
        delete stakeholders[ui];
        totalReward = totalReward;
        _stakenftnc(totalStakeAmount, _staker);
        return totalReward;
    }
    function _RewardsnftClaim(uint256 ui, address _staker)
        internal
        view
        returns (uint256)
    {
        uint256 totalReward;
        uint256 totalStakeAmount;
        StakingSummary memory summary = StakingSummary(
            0,
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateNftReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
            totalReward = totalReward + summary.stakes[s].claimable;
        }
        totalReward = totalReward;
        return totalReward;
    }
    function _stakenftnc(uint256 _amount, address addr) internal {
        require(_amount > 0, "Cannot stake nothing");
        uint256 index = stakes[addr];
        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholdernft(addr);
        }
        stakeholders[index].address_stakes.push(
            Stake(addr, _amount, timestamp, 0)
        );
        emit Staked(addr, _amount, index, timestamp);
    }
}