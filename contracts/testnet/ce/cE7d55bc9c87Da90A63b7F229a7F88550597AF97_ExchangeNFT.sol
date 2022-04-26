/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

pragma solidity ^0.4.26;
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
 * @title TRC21 interface
 */
interface ITRC21 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function issuer() external view returns (address);

    function estimateFee(uint256 value) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Fee(address indexed from, address indexed to, address indexed issuer, uint256 value);
}

/**
 * @title Standard TRC21 token
 * @dev Implementation of the basic standard token.
 */
contract TRC21 is ITRC21 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    uint256 private _minFee;
    address private _issuer;
    mapping (address => mapping (address => uint256)) private _allowed;
    uint256 private _totalSupply;

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
    function allowance(address owner,address spender) public	view returns (uint256){
        return _allowed[owner][spender];
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
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        require(_balances[msg.sender] >= _minFee);
        _allowed[msg.sender][spender] = value;
        _transfer(msg.sender, _issuer, _minFee);
        emit Approval(msg.sender, spender, value);
        return true;
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

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != 0);
        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != 0);
        require(value <= _balances[account]);

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
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
     * @dev Change minFee
     * @param value minFee
     */
    function _changeMinFee(uint256 value) internal {
        _minFee = value;
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
    function owner() public view returns(address) {
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
    function isOwner() public view returns(bool) {
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
contract ITRC721 {
    function transferFrom(address from, address to, uint256 tokenId) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);
    function ownerOf(uint256 tokenId) public view returns (address owner);
    function metadata(uint256 tokenId) public view returns (address creator);
    function transfer(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);
}
contract ExchangeNFT is TRC21, Ownable{
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    constructor () public {
        _name = 'ExchangeNFT';
        _symbol = 'ENFT';
        _decimals = 18;
        _changeIssuer(msg.sender);
        _changeMinFee(0);
        // ==============
    }

    /**
     * @return the name of the token.
     */
    event MakeOrder(address maker, uint256 index, string orderId);
    event CancelOrder(address maker, uint256 index);
    event ExchangeNFT(address sender, uint256 index, ITRC721 NFTTo, uint256 tokenIdTo);
    
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function setMinFee(uint256 value) public {
        require(msg.sender == issuer());
        _changeMinFee(value);
    }

    /**
     * @dev Function to burn tokens
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function burn(
        uint256 value
    )
    public
    returns (bool)
    {
        _burn(msg.sender, value);
        return true;
    }
    // ==================
    using SafeMath for uint256;
    ITRC21 public feeToken = ITRC21(0x33d609d6E9Ae742e92dB567F4D4C545D18D43C60);
    address public signer = 0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6;
    uint public feeExchange = 40;
    uint public panaltyPercent = 20;
    modifier onlySigner() {
        require(signer == msg.sender);
        _;
    }
    struct order {
        string _orderId;
        ITRC721 _NFTFrom;
        uint _tokenIdFrom;
        uint status; // 1 waiting; 2 finish; 3 canceled
        string _type;
    }
    mapping(address => order[]) public orders;
    function getMessageHash(uint timestamp, uint _tokenIdTo) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(timestamp, _tokenIdTo));
    }
    
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function permit(uint timestamp, uint _tokenIdTo, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
        return ecrecover(getEthSignedMessageHash(getMessageHash(timestamp, _tokenIdTo)), v, r, s) == signer;
    }
    
    function getOrders(address _from) public view returns(order[] memory){
        return orders[_from];
    }
    function getFee() public view returns(uint) {
        uint decimal = feeToken.decimals();
        return feeExchange.mul(10**decimal);
    }
    function makeOrder(string _orderId, ITRC721 _NFTFrom, uint _tokenIdFrom, string _type) public {
        require(feeToken.transferFrom(msg.sender, address(this), getFee()));
        orders[msg.sender].push(order(_orderId, _NFTFrom, _tokenIdFrom, 1, _type));
        emit MakeOrder(msg.sender, orders[msg.sender].length - 1, _orderId);
    }
    function cancelOrder(uint _index) public {
        require(orders[msg.sender][_index].status == 1);
        require(feeToken.transfer(msg.sender, getFee().mul(100-panaltyPercent).div(100)));
        orders[msg.sender][_index].status = 3;
        emit CancelOrder(msg.sender, _index);
    }
    function exchange(address _From, uint _index, ITRC721 _NFTTo, uint _tokenIdTo, uint timestamp, uint8 v, bytes32 r, bytes32 s) public {
        require(orders[_From][_index].status == 1);
        require(permit(timestamp, _tokenIdTo, v, r, s));
        require(feeToken.transferFrom(msg.sender, address(this), getFee()));
        _NFTTo.transferFrom(msg.sender, _From, _tokenIdTo);
        orders[_From][_index]._NFTFrom.transferFrom(_From, msg.sender, orders[_From][_index]._tokenIdFrom);
        orders[_From][_index].status = 2;
        emit ExchangeNFT(msg.sender, _index, _NFTTo, _tokenIdTo);
    }
    function configSigner(address _signer) public onlySigner {
        signer = _signer;
    }
    function config(ITRC21 _feeToken, uint _feeExchange, uint _panaltyPercent) public onlyOwner {
        feeToken = _feeToken;
        feeExchange = _feeExchange;
        panaltyPercent = _panaltyPercent;
    }
    function withdraw(ITRC21 _token, uint _amount, address _to) public onlyOwner {
        _token.transfer(_to, _amount);
    }
}