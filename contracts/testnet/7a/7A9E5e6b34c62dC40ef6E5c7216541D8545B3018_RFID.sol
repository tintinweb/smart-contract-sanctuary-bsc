// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

pragma experimental ABIEncoderV2;

import "ownable.sol";
import "SafeMath.sol";

import "IERC1410.sol";
import "IERC1594.sol";
import "IERC20.sol";
import "IERC1643.sol";

contract RFID is IERC20, IERC1410, IERC1594, IERC1643, Ownable {
    using SafeMath for uint256;

    /*------------------ERC-1643 Implementation--------------------*/

    struct Document {
        bytes32 docHash; // Hash of the document
        uint256 lastModified; // Timestamp at which document details was last modified
        string uri; // URI of the document that exist off-chain
    }

    mapping(bytes32 => Document) internal _documents;
    bytes32[] internal _docNames;
    mapping(bytes32 => uint256) internal _docIndexes;

    function getDocument(bytes32 _Name)
        public
        view
        override
        onlyOwner
        _isSaleOn
        returns (
            string memory,
            bytes32,
            uint256
        )
    {
        return (
            _documents[_Name].uri,
            _documents[_Name].docHash,
            _documents[_Name].lastModified
        );
    }

    function setDocument(
        bytes32 Name,
        string memory Uri,
        bytes32 _DocumentHash
    ) public override onlyOwner {
        require(Name != bytes32(0), "Zero value is not allowed");
        require(bytes(Uri).length > 0, "Should not be a empty uri");
        if (_documents[Name].lastModified == uint256(0)) {
            _docNames.push(Name);
            _docIndexes[Name] = _docNames.length;
        }
        _documents[Name] = Document(_DocumentHash, block.timestamp, Uri);
        _isIssuable = true;
        emit DocumentUpdated(Name, Uri, _DocumentHash);
    }

    function removeDocument(bytes32 _Name) public override _isSaleOn onlyOwner {
        require(
            _documents[_Name].lastModified != uint256(0),
            "Document should be existed"
        );
        uint256 index = _docIndexes[_Name] - 1;
        if (index != _docNames.length - 1) {
            _docNames[index] = _docNames[_docNames.length - 1];
            _docIndexes[_docNames[index]] = index + 1;
        }
        // _docNames.length = _docNames.length - 1;
        _docNames.pop();
        emit DocumentRemoved(
            _Name,
            _documents[_Name].uri,
            _documents[_Name].docHash
        );
        delete _documents[_Name];
    }

    function getAllDocuments()
        external
        view
        override
        returns (bytes32[] memory)
    {
        return _docNames;
    }

    /*------------------ERC-1594 Implementation--------------------*/

    bool _isIssuable;

    struct TokenSaleData {
        uint256 purchaseDateTime;
        uint256 tokenValue;
        bytes gram;
        bool isRedemed;
        uint256 goldPartFromGram;
    }
    mapping(address => TokenSaleData[]) addressTokenHistory;

    struct saleData {
        uint256 purchaseDateTime;
        uint256 tokenValue;
        bytes gram;
        uint256 goldPartFromGram;
        address _address;
    }

    saleData[] orderHistory;

    event Burn(address indexed burner, uint256 value);

    function isIssuable() external view override returns (bool) {
        return _isIssuable;
    }

    // function transferFromWithData(address from, address to, uint256 value, bytes calldata data) external override onlyOwner
    // {
    //      if (_isIssuable && balanceAvailable.div(10 ** 18) >= value)
    //      {
    //          _transferFromWithData(owner(),to,value,data);
    //      }
    //      else
    //      {
    //          revert('Transfer Not done');
    //      }

    //  }
    //  function _transferFromWithData(address from, address to, uint256 value, bytes memory data) internal onlyOwner isUserBlackListed(to) isUserKyc(to)
    //  {
    //      _balances[from] = _balances[from].sub(value.mul(10**18));
    //      _balances[to] = _balances[to].add(value.mul(10**18));
    //      addressTokenHistory[to].push(TokenSaleData(now,value.mul(10 **18),data,false,currentGoldGramPart));
    //      incGramCount++;
    //      emit Issued(from,to,value,data);
    //  }
    function issue(
        address tokenHolder,
        uint256 value,
        bytes calldata _data
    )
        external
        override
        onlyOwner
        isUserBlackListed(tokenHolder)
        isUserKyc(tokenHolder)
    {
        // get gram Value _data;
        if (_isIssuable && balanceAvailable.div(10**18) >= value) {
            _balances[tokenHolder] = _balances[tokenHolder].add(
                value.mul(10**18)
            );
            _balances[owner()] = _balances[owner()].sub(value.mul(10**18));
            balanceAvailable = balanceAvailable.sub(value.mul(10**18));
            //TokenSaleData structData = TokenSaleData(now,value,value);
            addressTokenHistory[tokenHolder].push(
                TokenSaleData(
                    block.timestamp,
                    value.mul(10**18),
                    _data,
                    false,
                    currentGoldGramPart
                )
            );
            orderHistory.push(
                saleData(
                    block.timestamp,
                    value,
                    _data,
                    currentGoldGramPart,
                    tokenHolder
                )
            );
            emit Issued(address(0), tokenHolder, value, _data);
            incGramCount = incGramCount + value;
        } else {
            revert("Token issue unavailable");
        }
    }

    function redeemFrom(
        address tokenHolder,
        uint256 value,
        bytes calldata _data
    ) external override onlyOwner {
        if (_balances[tokenHolder].div(10**18) >= value) {
            _balances[tokenHolder] = _balances[tokenHolder].sub(
                value.mul(10**18)
            );
            balanceAvailable = balanceAvailable.add(value); // fix: uncommented

            addressTokenHistory[tokenHolder].push(
                TokenSaleData(
                    block.timestamp,
                    value.mul(10**18),
                    _data,
                    true,
                    0
                )
            );
            emit Redeemed(address(0), tokenHolder, value, _data);
            _burn(tokenHolder, value);
        } else {
            revert("Token cannot be redeemed");
        }
    }

    /*------------------ERC-1410 Implementation--------------------*/

    struct Partition {
        uint256 amount;
        bytes32 partition;
    }

    mapping(address => Partition[]) partitions;
    mapping(address => mapping(bytes32 => uint256)) partitionToIndex;

    function issueByPartition(
        bytes32 _partition,
        address _tokenHolder,
        uint256 _value,
        bytes memory _data
    )
        public
        virtual
        override
        onlyOwner
        isUserBlackListed(_tokenHolder)
        isUserKyc(_tokenHolder)
    {
        if (_isIssuable && balanceAvailable >= _value) {
            _validateParams(_partition, _value);

            require(_tokenHolder != address(0), "Invalid token receiver");
            uint256 index = partitionToIndex[_tokenHolder][_partition];
            if (index == 0) {
                partitions[_tokenHolder].push(Partition(_value, _partition));
                partitionToIndex[_tokenHolder][_partition] = partitions[
                    _tokenHolder
                ].length;
            } else {
                partitions[_tokenHolder][index - 1].amount = partitions[
                    _tokenHolder
                ][index - 1].amount.add(_value);
            }

            _balances[_tokenHolder] = _balances[_tokenHolder].add(_value);
            balanceAvailable = balanceAvailable.sub(_value);
            emit IssuedByPartition(_partition, _tokenHolder, _value, _data);
        } else {
            revert("Token issue unavailable");
        }
    }

    /*------------------ERC-20 Implementation--------------------*/

    uint256 internal balanceAvailable;
    string public name;
    string public symbol;
    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balances;

    // uint256 decimals; // fix: Not used in contract
    // uint256 internal maxGram = 15; //0.15 Gram
    // uint256 internal minGram = 1000; //0.001 Gram
    // uint256 internal baseIncGram = 3725; //3725 / 10**12 0.000000003725

    uint256 currentGoldGramPart;
    struct MintGold {
        uint256 Gram;
        uint256 Date;
        address _address;
    }

    MintGold[] MintGoldHistory;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        _totalSupply = 0;
    }

    function mintNumberOfGram(uint256 gram, address _address)
        external
        onlyOwner //input will be in gram
    {
        currentGoldGramPart = gram;
        MintGoldHistory.push(MintGold(gram, block.timestamp, msg.sender));

        // balanceAvailable =  calculateTokenBasedOnGram(gram); // fix: no more using the function
        // balanceAvailable =  balance;
        // _balances[_address] = balanceAvailable;
        emit Issued(
            address(0),
            _address,
            balanceAvailable.div(10**18),
            toBytes(gram)
        );
    }

    function getHistoryOfMintedGold()
        external
        view
        returns (MintGold[] memory)
    {
        return MintGoldHistory;
    }

    function _balanceAvailable() external view returns (uint256) {
        return balanceAvailable.div(10**18);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply.div(10**18);
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    // function transfer(address recipient, uint256 amount) external override returns (bool)
    // {
    //     return false;
    // }
    function getAllPurchaseHistory() external view returns (saleData[] memory) {
        return orderHistory;
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= _balances[_who]);
        _balances[_who] = _balances[_who].sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }

    // FIX: removed
    // function getMinGram() external view returns(uint256)
    // {
    //     return minGram;
    // }
    // function getBaseIncGram() external view returns(uint256)
    // {
    //     return baseIncGram;
    // }

    function getcurrentGoldGramPart() external view returns (uint256) {
        return currentGoldGramPart;
    }

    /*------------------Supporttive Function--------------------*/

    uint256 incGramCount = 0;
    uint256 decimalGram = 1000;

    function _incGramCount() public view returns (uint256) {
        return incGramCount;
    }

    function _validateParams(bytes32 _partition, uint256 _value) internal pure {
        require(_value != uint256(0), "Zero value not allowed");
        require(_partition != bytes32(0), "Invalid partition");
    }

    modifier _isSaleOn() {
        require(_isIssuable, "Sale is off");
        _;
    }

    receive() external payable {
        revert("Invalid transaction");
    }

    function calculatePrice() external view returns (uint256) {
        //uint incGram = 3725 * 10**18;
        //uint currentGram = (1000 * 10**18).add((incGram.mul(incGramCount)));
    }

    function getUserOrderHistory(address _address)
        external
        view
        returns (TokenSaleData[] memory)
    {
        return addressTokenHistory[_address];
    }

    function toUint256(bytes memory _bytes)
        internal
        pure
        returns (uint256 value)
    {
        assembly {
            value := mload(add(_bytes, 0x20))
        }
    }

    function toBytes(uint256 x) internal pure returns (bytes memory b) {
        b = new bytes(32);
        for (uint256 i = 0; i < 32; i++) {
            b[i] = bytes1(uint8(x / (2**(8 * (31 - i)))));
        }
        return b;
    }

    // FIX: removed function (not needed)
    // function calculateTokenBasedOnGram(uint256 gram) internal view returns(uint256)
    // {

    //     uint256 totalGram = 3016000 * 10**18;
    //     uint256 token = (_totalSupply.mul(gram.mul(10**18))).div(totalGram); // fix: gram * 10**18 ==> gram.mul(10**18)
    //     return token;
    // }

    /*----------------------------------User Checking---------------------------*/

    event UserIsBlackListedByAdmin(address indexed _user);
    event UserKycStatus(address indexed _user, bool _status);
    mapping(address => bool) blackListed;
    mapping(address => bool) userKycStatus;

    function setUserKycStatus(address _address, bool _bool) external onlyOwner {
        userKycStatus[_address] = _bool;
        emit UserKycStatus(_address, _bool);
    }

    function setBlackList(address _address, bool _bool) external onlyOwner {
        blackListed[_address] = _bool;
        emit UserIsBlackListedByAdmin(_address);
    }

    function getUserKycStatus(address _address) external view returns (bool) {
        return userKycStatus[_address];
    }

    modifier isUserBlackListed(address _address) {
        require(blackListed[_address] == false, "User Is BlackListed");
        _;
    }

    modifier isUserKyc(address _address) {
        require(userKycStatus[_address] == true, "User Kyc Is InCompelet");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

pragma experimental ABIEncoderV2;

contract Ownable {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    address private _owner;

    constructor() {
        _owner = msg.sender;
        //emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

pragma experimental ABIEncoderV2;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

pragma experimental ABIEncoderV2;

interface IERC1410 {
    // Token Information
    //function balanceOf(address _tokenHolder) external view returns (uint256);
    //function balanceOfByPartition(bytes32 partition, address tokenHolder) external view returns (uint256);
    //function partitionsOf(address _tokenHolder) external view returns (bytes32[] memory);
    //function totalSupply() external view returns (uint256);

    // Token Transfers
    // function transferByPartition(bytes32 partition, address to, uint256 value, bytes calldata data) external returns (bytes32);
    //function operatorTransferByPartition(bytes32 partition, address from, address to, uint256 value, bytes calldata data, bytes calldata operatorData) external returns (bytes32);
    //function canTransferByPartition(address from, address to, bytes32 partition, uint256 value, bytes calldata _data) external view returns (byte, bytes32, bytes32);

    // Operator Information
    //function isOperator(address operator, address tokenHolder) external view returns (bool);
    //function isOperatorForPartition(bytes32 partition, address operator, address _tokenHolder) external view returns (bool);

    // Operator Management
    //function authorizeOperator(address _operator) external;
    //function revokeOperator(address _operator) external;
    //function authorizeOperatorByPartition(bytes32 partition, address operator) external;
    //function revokeOperatorByPartition(bytes32 partition, address operator) external;

    // Issuance / Redemption
    function issueByPartition(
        bytes32 partition,
        address tokenHolder,
        uint256 value,
        bytes calldata data
    ) external;

    // function redeemByPartition(bytes32 partition, uint256 value, bytes calldata _data) virtual external;
    // function operatorRedeemByPartition(bytes32 partition, address tokenHolder, uint256 value, bytes calldata data, bytes calldata _operatorData) virtual external;

    // Transfer Events
    event TransferByPartition(
        bytes32 indexed _fromPartition,
        address _operator,
        address indexed _from,
        address indexed _to,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

    // Operator Events
    event AuthorizedOperator(
        address indexed operator,
        address indexed tokenHolder
    );
    event RevokedOperator(
        address indexed operator,
        address indexed tokenHolder
    );
    event AuthorizedOperatorByPartition(
        bytes32 indexed partition,
        address indexed operator,
        address indexed tokenHolder
    );
    event RevokedOperatorByPartition(
        bytes32 indexed partition,
        address indexed operator,
        address indexed tokenHolder
    );

    // Issuance / Redemption Events
    event IssuedByPartition(
        bytes32 indexed partition,
        address indexed to,
        uint256 value,
        bytes data
    );
    event RedeemedByPartition(
        bytes32 indexed partition,
        address indexed operator,
        address indexed from,
        uint256 value,
        bytes data,
        bytes operatorData
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

pragma experimental ABIEncoderV2;

interface IERC1594 {
    // Transfers
    // function transferWithData(address to, uint256 value, bytes calldata _data) external;
    // function transferFromWithData(address from, address to, uint256 value, bytes calldata data) external;

    // Token Issuance
    function isIssuable() external view returns (bool);

    function issue(
        address tokenHolder,
        uint256 value,
        bytes calldata _data
    ) external;

    // Token Redemption
    //function redeem(uint256 value, bytes calldata data) external;
    function redeemFrom(
        address tokenHolder,
        uint256 value,
        bytes calldata _data
    ) external;

    // Transfer Validity
    // function canTransfer(address to, uint256 value, bytes calldata _data) external view returns (bool, byte, bytes32);
    // function canTransferFrom(address from, address to, uint256 value, bytes calldata data) external view returns (bool, byte, bytes32);

    // Issuance / Redemption Events
    event Issued(
        address indexed operator,
        address indexed to,
        uint256 value,
        bytes data
    );
    event Redeemed(
        address indexed operator,
        address indexed from,
        uint256 value,
        bytes data
    );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

pragma experimental ABIEncoderV2;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    //function transfer(address recipient, uint256 amount) external returns (bool);
    //function allowance(address owner, address spender) external view returns (uint256);
    // function approve(address spender, uint256 amount) external returns (bool);
    //  function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

pragma experimental ABIEncoderV2;

interface IERC1643 {
    // Document Management
    function getDocument(bytes32 _name)
        external
        view
        returns (
            string memory,
            bytes32,
            uint256
        );

    function setDocument(
        bytes32 name,
        string calldata uri,
        bytes32 _documentHash
    ) external;

    function removeDocument(bytes32 _name) external;

    function getAllDocuments() external view returns (bytes32[] memory);

    // Document Events
    event DocumentRemoved(
        bytes32 indexed name,
        string uri,
        bytes32 _documentHash
    );
    event DocumentUpdated(
        bytes32 indexed name,
        string uri,
        bytes32 _documentHash
    );
}