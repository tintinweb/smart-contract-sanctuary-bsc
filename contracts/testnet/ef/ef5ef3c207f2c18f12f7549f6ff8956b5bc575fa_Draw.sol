/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

pragma solidity 0.4.26;
pragma experimental ABIEncoderV2;

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
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}
contract ITRC721 {
    mapping (uint256 => address) public kittyIndexToApproved;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);

    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);

    function approvedFor(uint256 _tokenId) public view returns (address);

    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function transfer(address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
    function safeMint(address user) public;
    function create(address to) public returns (uint256);
    function _burnItem(address owner, uint256 tokenId) public ;
}
interface ITRC21 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Fee(address indexed from, address indexed to, address indexed issuer, uint256 value);
}
contract TRC21 is ITRC21 {
    mapping (address => uint256) _balances;
    uint256 private _minFee=0;
    address private _issuer;
    uint public _decimals = 18;
    // Token name
    string public _name = 'Draw';

    // Token symbol
    string public _symbol = 'Draw';
    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) private _allowed;
    uint256 private _totalSupply=100000000 * 10**_decimals;
    constructor () public {
        _changeIssuer(msg.sender);
        _balances[msg.sender] = _totalSupply;

    }

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
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
     * @dev Gets the token symbol.
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
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
    function allowance(address owner,address spender) public view returns (uint256){
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
    function transferFrom(address from, address to, uint256 value)  public returns (bool) {
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
    function _transfer(address from, address to, uint256 value) internal {
        require(value <= _balances[from]);
        require(to != address(0));
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
}
contract Draw is TRC21, Ownable {
    struct item {
        uint256[] tokenIds;
    }
    struct items {
        mapping(address => item) items;
        uint8 totalItem;
    }
    // bool public isEnded;
    mapping(address => items) public awardDatas;
    struct ticket {
        address user;
        bool isUsed;
    }
    address[] public businessAddresses;
    mapping(uint256 => ticket) public tickets;
    event _getTicket(address _from, uint256 ticket, uint256 tiketPrice);
    event _setAward(address _to, address _game, uint256 tokenId);
    event _setAwardTomo(address _to, uint256 amount);
    event _setAwardTRC21(address _to, ITRC21 trc21, uint256 amount);
    event _getAwardTRC721(address _from, address _game, uint256 tokenId, uint256 _type);
    ITRC21 public OwaDrawTrc21 = ITRC21(0x49aF7a3480011EF445F98f9b0d033a82DF8cfc01);
    ITRC721 public OwaDrawTrc721 = ITRC721(0xA836614BD513Af0071FF2b5Ea6D698b381EF299e);
    uint256[] public ticketPrice = [1 ether];
    constructor() public {}
    modifier onlyManager() {
        require(msg.sender == owner || isBusiness());
        _;
    }
    function validTicket(uint256 _ticket) public view returns (bool) {
        return (tickets[_ticket].user != address(0) && !tickets[_ticket].isUsed);
    }
    function setAwardPrice(ITRC21 _trc21, uint256[] _ticketPrice) public onlyOwner {
        OwaDrawTrc21 = _trc21;
        ticketPrice = _ticketPrice;
    }

    function buyTicket(uint256 _ticket, uint256 typeticket) public {
        require(tickets[_ticket].user == address(0));
        require(OwaDrawTrc21.transferFrom(msg.sender, address(this), ticketPrice[typeticket]));
        tickets[_ticket] = ticket(msg.sender, false);
        emit _getTicket(msg.sender, _ticket, ticketPrice[typeticket]);
    }
    function checkTicket(uint256 _ticket) public view returns (ticket) {
        return tickets[_ticket];
    }
    function isApprovedForAll(address _game, uint256 _tokenId) public view returns (bool){
        ITRC721 erc721 = ITRC721(_game);

        return (erc721.approvedFor(_tokenId) == address(this) ||
        erc721.getApproved(_tokenId) == address(this) ||
        erc721.isApprovedForAll(erc721.ownerOf(_tokenId), address(this)));
    }
    function getTokenIdByIndex(address _game, uint8 _index) public view returns (uint256){
        return awardDatas[msg.sender].items[_game].tokenIds[_index];
    }
    function getGameBalance(address _game) public view returns (uint256){
        return awardDatas[msg.sender].items[_game].tokenIds.length;
    }
    function setAwardTomo(uint256 _ticket, address _user, uint256 _amount) public payable onlyManager{
        require(validTicket(_ticket));
        _user.transfer(_amount);
        tickets[_ticket].isUsed = true;
        emit _setAwardTomo(_user, _amount);
    }
    function setAwardTRC21(uint256 _ticket, address _user, ITRC21 _trc21, uint256 _amount) public onlyManager{
        require(validTicket(_ticket));
        _trc21.transferFrom(msg.sender, _user, _amount);
        tickets[_ticket].isUsed = true;
        emit _setAwardTRC21(_user, _trc21, _amount);
    }
    function setAwardTRC721(uint256 _ticket, address _user) public onlyManager{
        require(validTicket(_ticket));
        uint256 _tokenId = OwaDrawTrc721.create(_user);
        awardDatas[_user].items[OwaDrawTrc721].tokenIds.push(_tokenId);
        awardDatas[_user].totalItem +=1;
        tickets[_ticket].isUsed = true;
        emit _setAward(_user, OwaDrawTrc721, _tokenId);
    }
    function setTRC721(ITRC721 _trc721) public onlyOwner{
        OwaDrawTrc721 = _trc721;
    }
    function setTRC21(ITRC21 _trc21) public onlyOwner{
        OwaDrawTrc21 = _trc21;
    }
    function getAwardTRC721(address _game, uint256 _tokenId, uint256 _type) public {
        ITRC721 erc721 = ITRC721(_game);
        // require(checkowner(_game, _tokenId));
        erc721.transferFrom(msg.sender, address(this), _tokenId);
        erc721._burnItem(address(this), _tokenId);
        emit _getAwardTRC721(msg.sender, erc721, _tokenId, _type);
    }
    function checkowner(address _game, uint256 _tokenId) internal returns(bool) {
        bool valid;
        uint256[] storage ids = awardDatas[msg.sender].items[_game].tokenIds;
        for(uint8 i = 0; i< ids.length; i++){
            if(ids[i] == _tokenId) {
                valid = true;
                _burnArrayTokenId(_game, i);
            }
        }
        return valid;
    }
    function _burnArrayTokenId(address _game, uint256 index)  internal {
        if (index >= awardDatas[msg.sender].items[_game].tokenIds.length) return;

        for (uint i = index; i<awardDatas[msg.sender].items[_game].tokenIds.length-1; i++){
            awardDatas[msg.sender].items[_game].tokenIds[i] = awardDatas[msg.sender].items[_game].tokenIds[i+1];
        }
        delete awardDatas[msg.sender].items[_game].tokenIds[awardDatas[msg.sender].items[_game].tokenIds.length-1];
        awardDatas[msg.sender].items[_game].tokenIds.length--;
        awardDatas[msg.sender].totalItem -=1;
    }
            
    function setBusinessAddress(address[] _businessAddresses) public onlyOwner {
        businessAddresses = _businessAddresses;
    }
    function isBusiness() public view returns (bool) {
        for(uint256 i = 0; i < businessAddresses.length; i++) {
            if(businessAddresses[i] == msg.sender) return true;
        }
        return false;
    }
}