/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

pragma solidity ^0.4.26;

library SafeMath {
    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ITRC21 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Fee(
        address indexed from,
        address indexed to,
        address indexed issuer,
        uint256 value
    );
}

contract TRC21 is ITRC21 {
    mapping(address => uint256) _balances;
    uint256 private _minFee = 0;
    address private _issuer;
    using SafeMath for uint256;
    mapping(address => mapping(address => uint256)) private _allowed;
    uint256 private _totalSupply;

    constructor() public {
        _changeIssuer(msg.sender);
        _balances[msg.sender] = _totalSupply;
    }

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev  The amount fee that will be lost when transferring.
     */
    function minFee() public view returns (uint256) {
        return _minFee;
    }

    /**
     * @dev token's foundation
     */
    function issuer() public view returns (address) {
        return _issuer;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Estimate transaction fee.
     * @param value amount tokens sent
     */
    function estimateFee(uint256 value) public view returns (uint256) {
        return value.mul(0).add(_minFee);
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowed[owner][spender];
    }

    /**
     * @dev Transfers token's foundation to new issuer
     * @param newIssuer The address to transfer ownership to.
     */
    function _changeIssuer(address newIssuer) internal {
        require(newIssuer != address(0));
        _issuer = newIssuer;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        uint256 total = value.add(_minFee);
        require(to != address(0));
        require(value <= total);
        require(total <= _allowed[from][msg.sender]);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(total);
        _transfer(from, to, value);
        _transfer(from, _issuer, _minFee);
        emit Fee(msg.sender, to, _issuer, _minFee);
        return true;
    }

    /**
     * @dev Transfer token for a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        uint256 total = value.add(_minFee);
        require(to != address(0));
        require(value <= total);
        _transfer(msg.sender, to, value);
        if (_minFee > 0) {
            _transfer(msg.sender, _issuer, _minFee);
            emit Fee(msg.sender, to, _issuer, _minFee);
        }
        return true;
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        require(value <= _balances[from]);
        require(to != address(0));
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
}

contract ITRC721 {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;

    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool);

    function ownerOf(uint256 tokenId) public view returns (address owner);
}

contract NFTScan is TRC21, Ownable {
    string private _name;
    string private _symbol;
    uint8 private _decimals = 1;
    using SafeMath for uint256;
    address[] public businessAddresses;

    struct sendTrc721 {
        address trc721;
        uint256 tokenId;
        address maker;
        address taker;
        uint256 start;
        uint256 end;
        uint256 status; // 1 available, 2 canceled, 3 taken
    }
    mapping(uint256 => sendTrc721) private sendTrc721s;
    modifier onlyManager() {
        require(msg.sender == owner() || isBusiness());
        _;
    }

    constructor() public {
        _name = "NFTScan";
        _symbol = "NFTScan";
        businessAddresses.push(msg.sender);
    }

    function isBusiness() public view returns (bool) {
        bool valid;
        for (uint256 i = 0; i < businessAddresses.length; i++) {
            if (businessAddresses[i] == msg.sender) valid = true;
        }
        return valid;
    }

    function setBusinessAdress(address[] _businessAddresses) public onlyOwner {
        businessAddresses = _businessAddresses;
    }

    event SendTRC721(uint256 _id);
    event RequestSendTRC721(uint256 _id, address taker, uint256 tokenId);

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    /**
     * @dev Gets the token name.
     * @return string representing the token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function validateTime(uint256 _id) public view returns (bool validate) {
        validate = now >= sendTrc721s[_id].start && now <= sendTrc721s[_id].end;
    }

    function sendTRC721s(
        uint256[] _ids,
        address _trc721,
        uint256[] _tokenIds,
        uint256 _start,
        uint256 _end
    ) public {
        ITRC721 trc721 = ITRC721(_trc721);
        for (uint256 i = 0; i < _ids.length; i++) {
            trc721.transferFrom(msg.sender, address(this), _tokenIds[i]);
            _sendTRC721(_ids[i], _trc721, _tokenIds[i], _start, _end);
        }
    }

    function sendTRC721(
        uint256 _id,
        address _trc721,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) public {
        ITRC721 trc721 = ITRC721(_trc721);
        trc721.transferFrom(msg.sender, address(this), _tokenId);
        _sendTRC721(_id, _trc721, _tokenId, _start, _end);
    }

    function _sendTRC721(
        uint256 _id,
        address _trc721,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) public {
        require(sendTrc721s[_id].maker == address(0), "This id existed !");

        sendTrc721s[_id].trc721 = _trc721;
        sendTrc721s[_id].tokenId = _tokenId;
        sendTrc721s[_id].maker = msg.sender;
        sendTrc721s[_id].start = _start;
        sendTrc721s[_id].end = _end;
        sendTrc721s[_id].status = 1;
        emit SendTRC721(_id);
    }

    function getSendTRC721(uint256 _id)
        public
        view
        returns (
            address trc721,
            address maker,
            address taker,
            uint256 tokenId,
            uint256 start,
            uint256 end,
            uint256 status
        )
    {
        return (
            sendTrc721s[_id].trc721,
            sendTrc721s[_id].maker,
            sendTrc721s[_id].taker,
            sendTrc721s[_id].tokenId,
            sendTrc721s[_id].start,
            sendTrc721s[_id].end,
            sendTrc721s[_id].status
        );
    }

    function requestSendTRC721(uint256 _id) public {
        require(sendTrc721s[_id].status == 1, "this package not existed !");
        uint256 status = 3;
        if (msg.sender != sendTrc721s[_id].maker)
            require(validateTime(_id), "This time not available !");
        else {
            require(now > sendTrc721s[_id].end, "This time not available !");
            status = 2;
        }
        ITRC721 trc721 = ITRC721(sendTrc721s[_id].trc721);
        uint256 tokenId = sendTrc721s[_id].tokenId;
        trc721.transferFrom(address(this), msg.sender, tokenId);
        sendTrc721s[_id].tokenId = 0;
        sendTrc721s[_id].status = status;
        sendTrc721s[_id].taker = msg.sender;
        emit RequestSendTRC721(_id, msg.sender, tokenId);
    }
}