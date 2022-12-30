/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

pragma solidity 0.5.9;


pragma solidity 0.5.9;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Transfer to null address is not allowed");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

}


contract Beneficiary is Ownable {

    address payable public beneficiary;

    constructor() public  {
        beneficiary = msg.sender;
    }

    function setBeneficiary(address payable _beneficiary) public onlyOwner {
        beneficiary = _beneficiary;
    }

    function withdrawal(uint256 value) public onlyOwner {
        if (value > address(this).balance) {
            revert("Insufficient balance");
        }

        beneficiaryPayout(value);
    }

    function withdrawalAll() public onlyOwner {
        beneficiaryPayout(address(this).balance);
    }

    function beneficiaryPayout(uint256 value) internal {
        beneficiary.transfer(value);
        emit BeneficiaryPayout(value);
    }

    event BeneficiaryPayout(uint256 value);
}



contract Manageable is Beneficiary {

    uint256 DECIMALS = 10e8;

    bool maintenance = false;

    mapping(address => bool) public managers;

    modifier onlyManager() {

        require(managers[msg.sender] || msg.sender == address(this), "Only managers allowed");
        _;
    }

    modifier notOnMaintenance() {
        require(!maintenance);
        _;
    }

    bool saleOpen = false;

    modifier onlyOnSale() {
        require(saleOpen);
        _;
    }

    constructor() public {
        managers[msg.sender] = true;
    }

    function setMaintenanceStatus(bool _status) public onlyManager {
        maintenance = _status;
        emit Maintenance(_status);
    }

    function setManager(address _manager) public onlyOwner {
        managers[_manager] = true;
    }

    function deleteManager(address _manager) public onlyOwner {
        delete managers[_manager];
    }

    function _addressToPayable(address _address) internal pure returns (address payable) {
        return address(uint160(_address));
    }

    event Maintenance(bool status);

    event FailedPayout(address to, uint256 value);

}


interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721 {
    function name() external view returns (string memory _name);

    function symbol() external view returns (string memory _symbol);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    function approve(address _approved, uint256 _tokenId) external;

    function setApprovalForAll(address _operator, bool _approved) external;

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    function getApproved(uint256 _tokenId) external view returns (address);

    function balanceOf(address _owner) external view returns (uint256);

    function tokenURI(uint256 _tokenId) external view returns (string memory);

    function baseTokenURI() external view returns (string memory);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;


    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);


}

interface IERC721Receiver {
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
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}

contract LockableToken is Manageable {
    mapping(uint256 => bool) public locks;

    modifier onlyNotLocked(uint256 _tokenId) {
        require(!locks[_tokenId]);
        _;
    }

    function isLocked(uint256 _tokenId) public view returns (bool) {
        return locks[_tokenId];
    }

    function lockToken(uint256 _tokenId) public onlyManager {
        locks[_tokenId] = true;
    }

    function unlockToken(uint256 _tokenId) public onlyManager {
        locks[_tokenId] = false;
    }

    function _lockToken(uint256 _tokenId) internal {
        locks[_tokenId] = true;
    }

    function _unlockToken(uint256 _tokenId) internal {
        locks[_tokenId] = false;
    }

}

library Strings {
    // via https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {
        return strConcat(_a, _b, "", "", "");
    }

    function uint2str(uint i) internal pure returns (string memory) {
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0) {
            bstr[k--] = byte(uint8(48 + i % 10));
            i /= 10;
        }
        return string(bstr);
    }

    function bytes32ToString(bytes32 x) internal pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function bytesToUInt(bytes32 b) internal pure returns (uint256){
        uint256 number;
        for(uint i=0;i<b.length;i++){
            number = number + uint256(uint8(b[i]))*(2**(8*(b.length-(i+1))));
        }
        return number;
    }

}

contract ERC721 is Manageable, LockableToken, IERC721, IERC165 {
    using Strings for string;

    mapping(address => uint256) public balances;
    mapping(uint256 => address) public approved;
    mapping(address => mapping(address => bool)) private operators;
    mapping(uint256 => address) private tokenOwner;

    uint256 public totalSupply = 0;

    string private _tokenURI = "";

    string private tokenName = '';
    string private tokenSymbol = '';

    modifier onlyTokenOwner(uint256 _tokenId) {
        require(msg.sender == tokenOwner[_tokenId]);
        _;
    }

    function setName(string memory _name) public onlyManager {
        tokenName = _name;
    }

    function setSymbol(string memory _symbol) public onlyManager {
        tokenSymbol = _symbol;
    }

    function name() external view returns (string memory _name) {
        return tokenName;
    }

    function symbol() external view returns (string memory _symbol) {
        return tokenSymbol;
    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool) {
        return interfaceID == 0x5b5e139f || interfaceID == 0x80ac58cd;
    }

    function setBaseTokenURI(string memory _newTokenURI) public onlyManager {
        _tokenURI = _newTokenURI;
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        return tokenOwner[_tokenId];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public onlyNotLocked(_tokenId) {
        require(_to != address(0));
        require(_isApprovedOrOwner(msg.sender, _tokenId));

        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) public onlyNotLocked(_tokenId) {
        address owner = ownerOf(_tokenId);
        require(_approved != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        approved[_tokenId] = _approved;

        emit Approval(owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        require(_operator != msg.sender);

        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operators[_owner][_operator];
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        return approved[_tokenId];
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }


    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function transfer(address _from, address _to, uint256 _tokenId) public onlyTokenOwner(_tokenId) onlyNotLocked(_tokenId) {
        require(_to != address(0));
        _transfer(_from, _to, _tokenId);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from);

        delete approved[_tokenId];

        if (_from != address(0)) {
            balances[_from]--;
        } else {
            totalSupply++;
        }

        if (_to != address(0)) {
            balances[_to]++;
        }

        tokenOwner[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function _mint(uint256 _tokenId, address _owner) internal {
        _transfer(address(0), _owner, _tokenId);
    }

    function _burn(uint256 _tokenId) internal {
        _transfer(ownerOf(_tokenId), address(0), _tokenId);
    }


    function baseTokenURI() public view returns (string memory) {
        return _tokenURI;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        return Strings.strConcat(
            baseTokenURI(),
            Strings.uint2str(_tokenId)
        );
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable {
        require(_isApprovedOrOwner(msg.sender, _tokenId));
        require(_to != address(0));

        IERC721Receiver receiver = IERC721Receiver(_to);

        _transfer(_from, _to, _tokenId);

        require(receiver.onERC721Received(msg.sender, _from, _tokenId, data) == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require(_isApprovedOrOwner(msg.sender, _tokenId));
        require(_to != address(0));

        IERC721Receiver receiver = IERC721Receiver(_to);

        _transfer(_from, _to, _tokenId);

        require(receiver.onERC721Received(msg.sender, _from, _tokenId, "") == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
    }

    function burn(uint256 _tokenId) public onlyManager {
        _burn(_tokenId);
    }


    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
}

contract BnbBank is Manageable {

    function transferToAddress(address payable _to, uint256 _value) external onlyManager {
        require(_value <= address(this).balance);

        if(!_to.send(_value)) {
            emit FailedPayout(_to, _value);
        }
    }

    function() external payable {

    }
}


contract UserBalance is Manageable {

    BnbBank bnbBankContract;

    mapping (address => uint256) public userBalance;

    constructor(address payable _bnbBank) public {
        bnbBankContract = BnbBank(_bnbBank);
    }

    function setBnbBank(address payable _bnbBank) public onlyManager {
        bnbBankContract = BnbBank(_bnbBank);
    }

    function addBalance(address user, uint256 value, uint8 transactionType, uint8 _incomeType) external onlyManager returns (uint256) {
        return _addBalance(user, value, transactionType, _incomeType);
    }

    function decBalance(address user, uint256 value, uint8 transactionType) public onlyManager returns (uint256) {
        return _decBalance(user, value, transactionType);
    }

    function _decBalance(address _user, uint _value, uint8 _transactionType) internal returns (uint){
        require(userBalance[_user] >= _value, "Insufficient balance");
        userBalance[_user] -= _value;

        emit DecBalance(_user, _value, _transactionType);
        return userBalance[_user];
    }

    function _addBalance(address _user, uint _value, uint8 _transactionType, uint8 _incomeType) internal returns (uint){
        userBalance[_user] += _value;
        emit AddBalance(_user, _value, _transactionType, _incomeType);
        return userBalance[_user];
    }


    function getBalance(address user) public view returns (uint256) {
        return userBalance[user];
    }

    function userWithdrawal() public {
        require(false);
    }

    function store() external payable {
        address(bnbBankContract).transfer(msg.value);
    }

    function beneficiaryTransfer(uint _value) public onlyManager {
        if(_value > 0) {
            bnbBankContract.transferToAddress(beneficiary, _value);
            emit BeneficiaryPayout(_value);
        }
    }

    event UserWithdrawalDone(address user, uint256 value);

    event AddBalance(address user, uint256 value, uint8 transactionType, uint8 _incomeType);
    event DecBalance(address user, uint256 value, uint8 transactionType);

    function () external payable {
    }

}

contract Market is Manageable {

    enum SALE_TYPE {NONE, REGULAR, AUCTION, DUTCH_AUCTION, OFFER}

    uint public DECIMALS = 18;
    uint public tax = 0.035 * (10 ** 18);

    uint public DEFAULT_PERIOD = 7 days;

    struct MarketItem {
        ERC721 erc721Contract;
        uint tokenId;
        address payable seller;
        uint saleId;
        uint sellPrice;
        uint endSalePrice;
        uint minStep;
        uint period;
        uint saleStarts;
    }

    struct Offer {
        ERC721 erc721Contract;
        uint tokenId;
        address seller;
        address buyer;
        uint value;
        bool active;
        uint offerDate;
    }

    struct Bid {
        uint bid;
        address payable buyer;
        uint ts;
    }

    uint public saleCount;

    mapping(uint => SALE_TYPE) public types;
    mapping(uint => MarketItem) public sales;
    mapping(uint => Offer) public offers;
    mapping(uint => Bid[]) public bids;

    mapping(address => mapping(uint => uint)) public activeSales;

    mapping(address => bool) public whitelist;
    UserBalance public userBalance;


    modifier onlyWhiteListed(address _contract) {
        require(whitelist[_contract]);
        _;
    }

    constructor(address payable _userBalance, address[] memory _whiteList) public {
        userBalance = UserBalance(_userBalance);

        for(uint i = 0; i < _whiteList.length; i++) {
            whitelist[_whiteList[i]] = true;
        }
    }

    function setUserBalance(address payable _userBalance) public onlyManager {
        userBalance = UserBalance(_userBalance);
    }

    function addToWhitelist(address[] memory _contracts) public onlyManager {
        for (uint i = 0; i < _contracts.length; i++) {
            whitelist[_contracts[i]] = true;
        }
    }

    function removeFromWhiteList(address[] memory _contracts) public onlyManager {
        for (uint i = 0; i < _contracts.length; i++) {
            delete whitelist[_contracts[i]];
        }
    }

    function _canBeOnSale(ERC721 _erc721, address _owner, uint _tokenId) internal view returns (bool) {
        if(_erc721.ownerOf(_tokenId) != _owner) {
            return false;
        }

        if(_erc721.getApproved(_tokenId) != address(this) && !_erc721.isApprovedForAll(_owner, address(this))) {
            return false;
        }

        return true;
    }


    function sellRegular(address payable _erc721Address, uint _tokenId, uint _sellPrice) public onlyWhiteListed(_erc721Address) {
        ERC721 _erc721 = ERC721(_erc721Address);

        require(_canBeOnSale(_erc721, msg.sender, _tokenId));

        if(activeSales[_erc721Address][_tokenId] > 0) { //Remove old sale
            emit CancelSale(activeSales[_erc721Address][_tokenId]);
            _deactivateSale(activeSales[_erc721Address][_tokenId]);
        }

        uint _saleId = genId();

        sales[_saleId] = MarketItem(_erc721, _tokenId, msg.sender, _saleId, _sellPrice, 0, 0, 0, now);
        types[_saleId] = SALE_TYPE.REGULAR;
        _activateSale(_saleId);

        emit CreateSale(_saleId);
    }

    function createOffer(address payable _erc721Address, uint _tokenId, uint _price, bool _fromBalance) public payable onlyWhiteListed(_erc721Address) {
        ERC721 _erc721 = ERC721(_erc721Address);
        uint _saleId = genId();

        if(!_fromBalance) {
            require(_price <= msg.value);
            userBalance.addBalance(msg.sender, msg.value, 99, 0);
            userBalance.store.value(msg.value)();
            emit IncUserBalance(msg.sender, _saleId, msg.value);
        }

        offers[_saleId] = Offer(_erc721, _tokenId, address(0), msg.sender, _price, true, now);
        types[_saleId] = SALE_TYPE.OFFER;

        userBalance.decBalance(msg.sender, _price, 101);
        emit DecUserBalance(msg.sender, _saleId, _price);

        emit CreateSale(_saleId);
    }

    function acceptOffer(uint _saleId) public {
        require(offers[_saleId].active && offers[_saleId].erc721Contract.ownerOf(offers[_saleId].tokenId) == msg.sender);
        offers[_saleId].active = false;

        offers[_saleId].erc721Contract.transferFrom(msg.sender, offers[_saleId].buyer, offers[_saleId].tokenId);
        offers[_saleId].seller = msg.sender;

        uint userPrice = biteFeeBalance(offers[_saleId].value);

        userBalance.addBalance(msg.sender, userPrice, 99, 0);
        emit IncUserBalance(offers[_saleId].buyer, _saleId, userPrice);
        emit CloseSale(_saleId, userPrice, offers[_saleId].buyer);
    }

    function declineOffer(uint _saleId) public {
        require(offers[_saleId].active && offers[_saleId].erc721Contract.ownerOf(offers[_saleId].tokenId) == msg.sender);
        offers[_saleId].active = false;
        offers[_saleId].seller = msg.sender;

        userBalance.addBalance(offers[_saleId].buyer, offers[_saleId].value, 101, 0);
        emit IncUserBalance(offers[_saleId].buyer, _saleId, offers[_saleId].value);

        emit CancelSale(_saleId);
    }

    function cancelOffer(uint _saleId) public {
        require(offers[_saleId].active && offers[_saleId].buyer == msg.sender);
        offers[_saleId].active = false;

        userBalance.addBalance(msg.sender, offers[_saleId].value, 101, 0);
        emit IncUserBalance(msg.sender, _saleId, offers[_saleId].value);

        emit CancelSale(_saleId);
    }

    function sellAuction(address payable _erc721Address, uint _tokenId, uint _sellPrice, uint _minStep, uint _buyout) public onlyWhiteListed(_erc721Address) {
        require(_sellPrice > 0 && _minStep > 0);
        ERC721 _erc721 = ERC721(_erc721Address);

        require(_canBeOnSale(_erc721, msg.sender, _tokenId));

        uint _saleId = genId();

        sales[_saleId] = MarketItem(_erc721, _tokenId, msg.sender, _saleId, _sellPrice, _buyout, _minStep, now + DEFAULT_PERIOD, now);
        types[_saleId] = SALE_TYPE.AUCTION;

        _activateSale(_saleId);

        emit CreateSale(_saleId);
    }

    function sellDutchAuction(address payable _erc721Address, uint _tokenId, uint _sellPrice, uint _endPrice, uint8 _period) public onlyWhiteListed(_erc721Address) {
        ERC721 _erc721 = ERC721(_erc721Address);

        require(_canBeOnSale(_erc721, msg.sender, _tokenId));

        if(activeSales[_erc721Address][_tokenId] > 0) { //Remove old sale
            emit CancelSale(activeSales[_erc721Address][_tokenId]);
            _deactivateSale(activeSales[_erc721Address][_tokenId]);
        }

        uint _saleId = genId();

        sales[_saleId] = MarketItem(_erc721, _tokenId, msg.sender, _saleId, _sellPrice, _endPrice, 0, now + _period * 1 days, now);
        types[_saleId] = SALE_TYPE.DUTCH_AUCTION;
        _activateSale(_saleId);

        emit CreateSale(_saleId);
    }

    function cancelSale(uint _saleId) public {
        require(_isActive(_saleId));

        MarketItem storage _sale = sales[_saleId];
        require(_sale.seller == msg.sender);
        require(types[_saleId] != SALE_TYPE.AUCTION || bids[_sale.saleId].length == 0);

        emit CancelSale(_saleId);
        _deactivateSale(_saleId);
    }

    function forceCancelSale(uint _saleId) public onlyManager {
        require(_isActive(_saleId));
        _forceCancelSale(_saleId);
    }

    function purchase(uint _saleId) public payable {
        _purchase(_saleId, msg.sender, msg.sender, msg.value, false);
    }

    function purchaseFor(uint _saleId, address payable _for) public payable {
        _purchase(_saleId, msg.sender, _for, msg.value, false);
    }

    function purchaseForBalance(uint _saleId) public payable {
        _purchase(_saleId, msg.sender, msg.sender, 0, true);
    }

    function _purchase(uint _saleId, address payable _sender, address payable _buyer, uint _value, bool _fromBalance) internal {
        require(_isActive(_saleId));


        MarketItem storage _sale = sales[_saleId];
        require(types[_saleId] == SALE_TYPE.REGULAR || types[_saleId] == SALE_TYPE.DUTCH_AUCTION);

        require(_sale.seller == _sale.erc721Contract.ownerOf(_sale.tokenId));

        uint _price = getCurrentSalePrice(_sale, types[_saleId]);
        uint _tokenId =  _sale.tokenId;
        if(!_fromBalance) {
            require(_price > 0 && _value >= _price);
        } else {
            userBalance.decBalance(_buyer, _price, 100);
            emit IncUserBalance(_buyer, _saleId, _price);

        }


        if (!_fromBalance && _value > _price) {
            _sender.transfer(_value - _price);
        }

        emit CloseSale(_saleId, _price, _buyer);

        _price = biteFee(_price);


        userBalance.addBalance(_sale.seller, _price, 100, 0);
        userBalance.store.value(_price)();
        emit IncUserBalance(_sale.seller, _saleId, _price);

        _deactivateSale(_saleId);

        _sale.erc721Contract.transferFrom(_sale.seller, _buyer, _tokenId);

    }

    function bid(uint _saleId) public payable {
        require(_isActive(_saleId));
        uint _price = getCurrentSalePrice(sales[_saleId], types[_saleId]);
        require(_price > 0 && msg.value >= _price);
        uint _tokenId = sales[_saleId].tokenId;
        address payable _seller = sales[_saleId].seller;
        require(_seller == sales[_saleId].erc721Contract.ownerOf(sales[_saleId].tokenId));

        if (sales[_saleId].endSalePrice > 0 && sales[_saleId].endSalePrice <= msg.value) {//Buyout

            if (sales[_saleId].endSalePrice > msg.value) {
                msg.sender.transfer(msg.value - sales[_saleId].endSalePrice);
                userBalance.store.value(sales[_saleId].endSalePrice);
            }

            emit CloseSale(_saleId, _price, msg.sender);
            _price = biteFee(sales[_saleId].endSalePrice);
            if (!sales[_saleId].seller.send(_price)) {
                emit FailedPayout(sales[_saleId].seller, _price);
            }

            userBalance.addBalance(sales[_saleId].seller, _price, 105, 0);
            userBalance.store.value(_price)();

            _deactivateSale(_saleId);

            sales[_saleId].erc721Contract.transferFrom(_seller, msg.sender, _tokenId);

        } else {
            sales[_saleId].period = now + DEFAULT_PERIOD;
            userBalance.store.value(msg.value);
        }

        if (bids[_saleId].length > 0) {
            Bid storage _oldBid = bids[_saleId][bids[_saleId].length - 1];
            userBalance.addBalance(_oldBid.buyer, _oldBid.bid, 115, 0);
            userBalance.store.value(msg.value)();
        }

        bids[_saleId].push(Bid(msg.value, msg.sender, now));

        emit BidSale(_saleId, msg.value, msg.sender);
    }

    function checkBidIsValid(uint _saleId) public {
        _tokenOwnerChangeFallback(address(sales[_saleId].erc721Contract), sales[_saleId].tokenId);
    }

    function collect(uint _saleId) public {
        require(_isActive(_saleId));
        require(sales[_saleId].period < now && msg.sender == bids[_saleId][bids[_saleId].length - 1].buyer);


        uint _price = biteFeeBalance(bids[_saleId][bids[_saleId].length - 1].bid);

        emit CloseSale(_saleId, _price, msg.sender);

        userBalance.addBalance(sales[_saleId].seller, _price, 105, 0);

        _deactivateSale(_saleId);

        sales[_saleId].erc721Contract.transferFrom(sales[_saleId].seller, msg.sender, sales[_saleId].tokenId);

    }

    function getBids(uint _saleId) public view returns (uint[] memory _bid, address[] memory _buyer, uint[] memory _ts) {
        if (bids[_saleId].length == 0) {
            return (_bid, _buyer, _ts);
        }

        _bid = new uint[](bids[_saleId].length);
        _buyer = new address[](bids[_saleId].length);
        _ts = new uint[](bids[_saleId].length);

        for (uint i = 0; i < bids[_saleId].length; i++) {
            _bid[i] = bids[_saleId][i].bid;
            _buyer[i] = bids[_saleId][i].buyer;
            _ts[i] = bids[_saleId][i].ts;
        }
    }

    function getCurrentPrice(uint _saleId) public view returns (uint) {
        return getCurrentSalePrice(sales[_saleId], types[_saleId]);
    }

    function getCurrentSalePrice(MarketItem memory _sale, SALE_TYPE _type) internal view returns (uint) {
        if (_type == SALE_TYPE.REGULAR) {
            return _sale.sellPrice;
        } else if (_type == SALE_TYPE.AUCTION) {
            if (_sale.period > now) {
                return 0;
            }

            return bids[_sale.saleId].length == 0 ? _sale.sellPrice : bids[_sale.saleId][bids[_sale.saleId].length - 1].bid + _sale.minStep;
        } else if (_type == SALE_TYPE.DUTCH_AUCTION) {
            uint _daysPassed = (now - _sale.saleStarts) / 1 days;
            uint _allDays = (_sale.period - _sale.saleStarts) / 1 days;
            return (_sale.sellPrice > _sale.endSalePrice) ?
            (_sale.sellPrice - _daysPassed * (_sale.sellPrice - _sale.endSalePrice) / _allDays) :
            (_sale.sellPrice + _daysPassed * (_sale.endSalePrice - _sale.sellPrice) / _allDays);
        }

        return 0;
    }


    function biteFee(uint _price) internal returns (uint) {
        uint fee = _price * tax / 10 ** DECIMALS;
        beneficiaryPayout(fee);
        return _price - fee;
    }

    function biteFeeBalance(uint _price) internal returns (uint) {
        uint fee = _price * tax / 10 ** DECIMALS;
        userBalance.beneficiaryTransfer(fee);
        return _price - fee;
    }

    function setTax(uint _tax) public onlyManager {
        tax = _tax;
    }

    function genId() internal returns (uint) {
        saleCount++;
        return saleCount;
    }

    function _activateSale(uint _saleId) internal {
        require(activeSales[address(sales[_saleId].erc721Contract)][sales[_saleId].tokenId] == 0);
        require(!sales[_saleId].erc721Contract.isLocked(sales[_saleId].tokenId));
        activeSales[address(sales[_saleId].erc721Contract)][sales[_saleId].tokenId] = _saleId;
    }

    function _deactivateSale(uint _saleId) internal {
        require(activeSales[address(sales[_saleId].erc721Contract)][sales[_saleId].tokenId] > 0);
        activeSales[address(sales[_saleId].erc721Contract)][sales[_saleId].tokenId] = 0;
    }

    function _isActive(uint _saleId) internal view returns (bool) {
        return activeSales[address(sales[_saleId].erc721Contract)][sales[_saleId].tokenId] == _saleId;
    }

    function _tokenOwnerChangeFallback(address _erc721, uint _tokenId) internal {
        if (activeSales[_erc721][_tokenId] > 0 && ERC721(_erc721).ownerOf(_tokenId) == msg.sender && msg.sender != sales[activeSales[_erc721][_tokenId]].seller) {
            _forceCancelSale(activeSales[_erc721][_tokenId]);
        }
    }

    function _forceCancelSale(uint _saleId) internal {
        require(_isActive(_saleId));

        emit CancelSale(_saleId);
        _deactivateSale(_saleId);

        if (types[_saleId] == SALE_TYPE.AUCTION && bids[_saleId].length > 0) {
            if (!bids[_saleId][bids[_saleId].length - 1].buyer.send(bids[_saleId][bids[_saleId].length - 1].bid)) {
                emit FailedPayout(bids[_saleId][bids[_saleId].length - 1].buyer, bids[_saleId][bids[_saleId].length - 1].bid);
            }
        }
    }

    function getCurrentPricesBySaleIds(uint[] calldata _saleIds) external view returns (uint[] memory _prices) {
        _prices = new uint[](_saleIds.length);
        for(uint i = 0; i < _saleIds.length; i++) {
            _prices[i] = getCurrentPrice(_saleIds[i]);
        }
    }

    event CreateSale(uint _saleId);
    event CancelSale(uint _saleId);
    event CloseSale(uint _saleId, uint _buyPrice, address _buyer);
    event BidSale(uint _saleId, uint _bid, address _buyer);
    event IncUserBalance(address _user, uint _saleId, uint _value);
    event DecUserBalance(address _user, uint _saleId, uint _value);
}