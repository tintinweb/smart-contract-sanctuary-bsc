/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

pragma solidity ^0.4.26;
pragma experimental ABIEncoderV2;

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

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

interface ITRC21 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function issuer() external view returns (address);

    function estimateFee(uint256 value) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Fee(address indexed from, address indexed to, address indexed issuer, uint256 value);
}

contract TRC21 is ITRC21 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    uint256 private _minFee;
    address private _issuer;
    mapping(address => mapping(address => uint256)) private _allowed;
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
    function allowance(address owner, address spender) public view returns (uint256) {
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

contract TokenSale is TRC21, Ownable {
    event _register(address user, uint256 _tokenId);
    event Deposit(ITRC21 _fiat, uint256 _fiatAmount, address _to);

    string private _name;
    string private _symbol;
    int8 private _decimals;
    
    struct Sale {
        ITRC21 fiat;
        address saler;
        bool existed;
    }

    mapping(address => Sale) public sales;
    
    ITRC21[] public fiats;
    address[] public businessAddresses;
    uint256[] public prices = [500000000000000000000, 1000000000000000000000, 3000000000000000000000, 5000000000000000000000, 10000000000000000000000];
    mapping(address => bool) public userBlocks;

    constructor() public {
        _name = "TokenSale";
        _symbol = "TS";
        _decimals = 0;
        _changeIssuer(msg.sender);
    }

    modifier onlyManager() {
        require(msg.sender == owner || isBusiness());
        _;
    }

    modifier isValidFiatBuy(address _fiat) {
        require(sales[_fiat].existed);
        _;
    }
    
    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function setBlockUser(address _user, bool _status) public onlyOwner {
        userBlocks[_user] = _status;
    }

    function isBusiness() public view returns (bool) {
        bool valid;
        for (uint256 i = 0; i < businessAddresses.length; i++) {
            if (businessAddresses[i] == msg.sender) valid = true;
        }
        return valid;
    }

    function getFiats() public view returns(ITRC21[]) {
        return fiats;
    }

    function validPrice(uint256 _price) public view returns (bool) {
        bool valid;
        for (uint256 i = 0; i < prices.length; i++) {
            if (prices[i] == _price) valid = true;
        }
        return valid;
    }

    function validPrices(uint256[] _prices) public view returns (bool) {
        bool valid = true;
        for (uint256 i = 0; i < _prices.length; i++) {
            if (!validPrice(_prices[i])) valid = false;
        }
        return valid;
    }

    function deposit(ITRC21 _fiat, uint256[] _fiatAmounts, address _to) public onlyManager isValidFiatBuy(_fiat) {
        require(validPrices(_fiatAmounts), "Invalid price !!!");
        for (uint256 j = 0; j < _fiatAmounts.length; j++) {
            _fiat.transferFrom(sales[_fiat].saler, _to, _fiatAmounts[j]);
            emit Deposit(_fiat, _fiatAmounts[j], _to);
        }
    }

    function setFiatToken(ITRC21 _fiat, address _saler) public onlyManager {
        if (sales[_fiat].existed) {
            sales[_fiat].saler = _saler;
        } else {
            Sale memory newSale = Sale({fiat: _fiat, saler: _saler, existed: true});
            sales[_fiat] = newSale;
            fiats.push(_fiat);
        }
        
    }

    function setPrices(uint256[] _prices) public onlyManager {
        prices = _prices;
    }

    function setBusinessAdress(address[] _businessAddresses) public onlyOwner {
        businessAddresses = _businessAddresses;
    }
}