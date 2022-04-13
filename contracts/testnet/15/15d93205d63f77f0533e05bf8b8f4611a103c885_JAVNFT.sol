/**
 *Submitted for verification at BscScan.com on 2022-04-13
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
    function create(address user, address _creator) public returns(uint);
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
    string public _name = 'JAVNFT';

    // Token symbol
    string public _symbol = 'JAV';
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
    function transferFrom(address from,	address to,	uint256 value)	public returns (bool) {
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
contract JAVNFT is TRC21, Ownable {
    struct taker {
        uint _type;
        bool _isTaked;
        uint _amount;
        address _creator;
    }
    mapping(address => taker) public takers;
    address[] public businessAddresses;
    event _setAward(address _to, uint256 amount, address _businessAddr);
    event _getAwardTRC21(address _to, uint256 amount, address _businessAddr);
    event _getAwardTRC721(address _to, ITRC721 _game, uint256 tokenId, address _businessAddr);
    ITRC21 public trc21 = ITRC21(0x18d4d562465df77da8171ec244ea21b1dbbae0d6);
    ITRC721 public trc721 = ITRC721(0xb2a08fe9ad034a1632ee8ca71eb2e33146503f31);
    event LogWithdrawal(address indexed receiver, uint amount);

    function isBusiness() public view returns (bool) {
        bool valid;
        for(uint256 i = 0; i < businessAddresses.length; i++) {
            if(businessAddresses[i] == msg.sender) valid = true;

        }
        return valid;
    }
    constructor () public {
        businessAddresses = [msg.sender];
    }
    function setBusinessAdress(address[] _businessAddresses) public onlyOwner {
        businessAddresses = _businessAddresses;
    }
    function setAward(uint _type, uint _amount, address _to, address _creator) public {
        require(isBusiness());
        require(takers[_to]._type == 0);
        takers[_to] = taker(_type, false, _amount, _creator);
        _setAward(_to, _amount, msg.sender);
    }
    function getAward() {
        uint _type = takers[msg.sender]._type;
        require(_type != 0);
        require(!takers[msg.sender]._isTaked);
        if(_type == 1) {
            trc21.transfer(msg.sender, takers[msg.sender]._amount);
            emit _getAwardTRC21(msg.sender, takers[msg.sender]._amount, msg.sender);
        }
        else {
            uint256 _tokenId = trc721.create(msg.sender, takers[msg.sender]._creator);
            emit _getAwardTRC721(msg.sender, trc721, _tokenId, msg.sender);
        }
        takers[msg.sender]._isTaked = true;
    }
    
    function getRemainingToken() public view returns (uint256) {
        return trc21.balanceOf(this);
    }
    
    function withdraw(address _address) public onlyOwner {
        require(_address != address(0));
        uint tokenBalanceOfContract = getRemainingToken();
        trc21.transfer(_address, tokenBalanceOfContract);
        emit LogWithdrawal(_address, tokenBalanceOfContract);
    }
}