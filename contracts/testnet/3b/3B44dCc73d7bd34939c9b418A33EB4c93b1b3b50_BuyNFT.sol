/**
 *Submitted for verification at BscScan.com on 2022-04-28
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

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private minters;

    constructor() internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

contract ITRC721 {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function ownerOf(uint256 tokenId) public view returns (address owner);

    function metadata(uint256 tokenId) public view returns (address creator);

    function transfer(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);
}

contract FIATContract {
    function getToken2JPY(string __symbol) public view returns (string _symbolToken, uint256 _token2JPY);
}

contract BuyNFT is TRC21, MinterRole, Ownable {
    event SetFiat(string[] _symbols, address[] _address, address _from);
    event _setPrice(address _game, uint256[] _tokenIds, uint256 _Price, uint8 _type);
    event _resetPrice(address _game, uint256 _orderId);
    using SafeMath for uint256;

    // TomoZ
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    // Struct
    struct Token {
        string symbol;
        bool existed;
    }

    struct GameFee {
        string fee;
        address taker;
        uint256 percent;
        bool existed;
    }

    struct Price {
        uint256[] tokenIds;
        address maker;
        uint256 Price2JPY;
        address[] fiat;
        address buyByFiat;
        bool isBuy;
    }

    struct Game {
        uint256 fee;
        uint256 limitFee;
        uint256 creatorFee;
        mapping(uint256 => Price) tokenPrice;
        GameFee[] arrFees;
        mapping(string => GameFee) fees;
    }

    // Contract
    address public BuyNFTSub = address(0);
    address public ceoAddress = address(0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6);
    uint256 public Percen = 1000;
    FIATContract public fiatContract;
    mapping(address => Token) public tokensFiat;
    address[] public fiat = [
        address(0x33d609d6E9Ae742e92dB567F4D4C545D18D43C60) // PREMA
    ];

    mapping(address => Game) public Games;
    address[] public arrGames;

    modifier onlyCeoAddress() {
        require(msg.sender == ceoAddress);
        _;
    }
    modifier onlySub() {
        require(msg.sender == BuyNFTSub);
        _;
    }

    modifier isValidFiatBuy(address _fiat) {
        require(tokensFiat[_fiat].existed);
        _;
    }

    constructor() public {
        _name = "BuyNFT";
        _symbol = "BNFT";
        _decimals = 18;
        _changeIssuer(msg.sender);
        _changeMinFee(0);
        // ==============
        tokensFiat[address(0x33d609d6E9Ae742e92dB567F4D4C545D18D43C60)] = Token("PREMA", true);
        fiatContract = FIATContract(0x8f867B30d60c34c8026a36C0D7Dd442f7b78c94D);
    }

    function() public payable {}

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function setMinFee(uint256 value) public {
        require(msg.sender == issuer());
        _changeMinFee(value);
    }

    function mint(address to, uint256 value) public onlyMinter returns (bool) {
        _mint(to, value);
        return true;
    }

    function burn(uint256 value) public returns (bool) {
        _burn(msg.sender, value);
        return true;
    }

    function checkIsOwnerOf(address _game, uint256[] _tokenIds) public view returns (bool) {
        bool flag = true;
        ITRC721 erc721Address = ITRC721(_game);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            if (erc721Address.ownerOf(_tokenIds[i]) != msg.sender) flag = false;
        }
        return flag;
    }

    modifier isOwnerOf(address _game, uint256[] _tokenIds) {
        require(checkIsOwnerOf(_game, _tokenIds));
        _;
    }

    modifier isValidFiat(address[] _fiat) {
        require(_fiat.length > 0);
        bool isValid = true;
        for (uint256 i = 0; i < _fiat.length; i++) {
            bool isExist = tokensFiat[_fiat[i]].existed;
            if (!isExist) {
                isValid = false;
                break;
            }
        }
        require(isValid);
        _;
    }

    function getFiat() public view returns (address[]) {
        return fiat;
    }

    function setBuyNFTSub(address _sub) public onlyOwner {
        BuyNFTSub = _sub;
    }

    function setFiat(string[] _symbols, address[] addrrs) public onlyOwner {
        for (uint256 i = 0; i < _symbols.length; i++) {
            tokensFiat[addrrs[i]].symbol = _symbols[i];
            if (!tokensFiat[addrrs[i]].existed) {
                fiat.push(addrrs[i]);
                tokensFiat[addrrs[i]].existed = true;
            }
        }
        emit SetFiat(_symbols, addrrs, msg.sender);
    }

    function getTokensFiat(address _fiat) public view returns (string __symbol, bool _existed) {
        return (tokensFiat[_fiat].symbol, tokensFiat[_fiat].existed);
    }

    function price2wei(uint256 _price, address _fiatBuy) public view returns (uint256) {
        uint256 weitoken;
        (, weitoken) = fiatContract.getToken2JPY(tokensFiat[_fiatBuy].symbol);
        return _price.mul(weitoken).div(1);
    }

    function tokenId2wei(
        address _game,
        uint256 _orderId,
        address _fiatBuy
    ) public view returns (uint256) {
        uint256 _price = Games[_game].tokenPrice[_orderId].Price2JPY;
        return price2wei(_price, _fiatBuy);
    }

    function setFiatContract(address _fiatContract) public onlyOwner {
        fiatContract = FIATContract(_fiatContract);
    }

    function getTokenPrice(address _game, uint256 _orderId)
        public
        view
        returns (
            address _maker,
            uint256[] _tokenIds,
            uint256 _Price2JPY,
            address[] _fiat,
            address _buyByFiat,
            bool _isBuy
        )
    {
        return (
            Games[_game].tokenPrice[_orderId].maker,
            Games[_game].tokenPrice[_orderId].tokenIds,
            Games[_game].tokenPrice[_orderId].Price2JPY,
            Games[_game].tokenPrice[_orderId].fiat,
            Games[_game].tokenPrice[_orderId].buyByFiat,
            Games[_game].tokenPrice[_orderId].isBuy
        );
    }

    function getArrGames() public view returns (address[] memory) {
        return arrGames;
    }

    function ownerOf(address _game, uint256 _tokenId) public view returns (address) {
        ITRC721 erc721Address = ITRC721(_game);
        return erc721Address.ownerOf(_tokenId);
    }

    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }

    function updateArrGames(address _game) internal {
        bool flag = false;
        for (uint256 i = 0; i < arrGames.length; i++) {
            if (arrGames[i] == _game) flag = true;
        }
        if (!flag) arrGames.push(_game);
    }

    function setPrice(
        uint256 _orderId,
        address _game,
        uint256[] _tokenIds,
        uint256 _price,
        address[] _fiat
    ) internal {
        require(Games[_game].tokenPrice[_orderId].maker == address(0) || Games[_game].tokenPrice[_orderId].maker == msg.sender);
        Games[_game].tokenPrice[_orderId] = Price(_tokenIds, msg.sender, _price, _fiat, address(0), false);
        updateArrGames(_game);
    }

    function calFee(
        address _game,
        string _fee,
        uint256 _price
    ) public view returns (uint256) {
        uint256 amount = _price.mul(Games[_game].fees[_fee].percent).div(Percen);
        return amount;
    }

    function calPrice(address _game, uint256 _orderId)
        public
        view
        returns (
            address _tokenOwner,
            uint256 _Price2JPY,
            address[] _fiat,
            address _buyByFiat,
            bool _isBuy
        )
    {
        return (
            Games[_game].tokenPrice[_orderId].maker,
            Games[_game].tokenPrice[_orderId].Price2JPY,
            Games[_game].tokenPrice[_orderId].fiat,
            Games[_game].tokenPrice[_orderId].buyByFiat,
            Games[_game].tokenPrice[_orderId].isBuy
        );
    }

    function setPriceFee(
        uint256 _orderId,
        address _game,
        uint256[] _tokenIds,
        uint256 _Price,
        address[] _fiat
    ) public isOwnerOf(_game, _tokenIds) isValidFiat(_fiat) {
        setPrice(_orderId, _game, _tokenIds, _Price, _fiat);
        emit _setPrice(_game, _tokenIds, _Price, 1);
    }

    function getGame(address _game) public view returns (uint256, uint256, uint256) {
      return (Games[_game].fee, Games[_game].limitFee, Games[_game].creatorFee);  
    }

    function getGameFees(address _game) public view returns (string[], address[], uint256[], uint256) {
        uint256 length = Games[_game].arrFees.length;
        string[] memory fees = new string[](length);
        address[] memory takers = new address[](length);
        uint256[] memory percents = new uint256[](length);
        uint256 sumGamePercent = 0;
        for (uint256 i = 0; i < length; i++) {
            GameFee storage gameFee = Games[_game].arrFees[i];
            fees[i] = gameFee.fee;
            takers[i] = gameFee.taker;
            percents[i] = gameFee.percent;
            sumGamePercent += gameFee.percent;
        }

        return (fees, takers, percents, sumGamePercent);
    }

    function getGameFeePercent(address _game, string _fee) public view returns (uint256) {
        return Games[_game].fees[_fee].percent;
    }

    function setLimitFee(
        address _game,
        uint256 _fee,
        uint256 _limitFee,
        uint256 _creatorFee,
        string[] memory _gameFees,
        address[] memory _takers,
        uint256[] memory _percents
    ) public onlyOwner {
        require(_fee >= 0 && _limitFee >= 0);
        Games[_game].fee = _fee;
        Games[_game].limitFee = _limitFee;
        Games[_game].creatorFee = _creatorFee;

        for (uint256 i = 0; i < _gameFees.length; i++) {
            if (!Games[_game].fees[_gameFees[i]].existed) {
                GameFee memory newFee = GameFee({fee: _gameFees[i], taker: _takers[i], percent: _percents[i], existed: true});
                Games[_game].fees[_gameFees[i]] = newFee;
                Games[_game].arrFees.push(newFee);
            } else {
                Games[_game].fees[_gameFees[i]].percent = _percents[i];
                Games[_game].fees[_gameFees[i]].taker = _takers[i];
                Games[_game].arrFees[i].percent = _percents[i];
                Games[_game].arrFees[i].taker = _takers[i];
            }
        }
        updateArrGames(_game);
    }

    function setLimitFeeAll(
        address[] memory _games,
        uint256[] memory _fees,
        uint256[] memory _limitFees,
        uint256[] memory _creatorFees,
        string[][] memory _gameFees,
        address[][] memory _takers,
        uint256[][] memory _percents
    ) public onlyOwner {
        require(_games.length == _fees.length);
        for (uint256 i = 0; i < _games.length; i++) {
            setLimitFee(_games[i], _fees[i], _limitFees[i], _creatorFees[i], _gameFees[i], _takers[i], _percents[i]);
        }
    }

    function _withdraw(uint256 amount) internal {
        require(address(this).balance >= amount);
        if (amount > 0) {
            ceoAddress.transfer(amount);
        }
    }

    function withdraw(
        uint256 amount,
        address[] _tokenTRC21s,
        uint256[] _amountTRC21s
    ) public onlyOwner {
        _withdraw(amount);
        for (uint256 i = 0; i < _tokenTRC21s.length; i++) {
            if (_tokenTRC21s[i] != address(0)) {
                ITRC21 trc21 = ITRC21(_tokenTRC21s[i]);
                require(trc21.balanceOf(address(this)) >= _amountTRC21s[i]);
                if (_amountTRC21s[i] > 0) {
                    trc21.transfer(ceoAddress, _amountTRC21s[i]);
                }
            }
        }
    }

    function changeCeo(address _address) public onlyCeoAddress {
        require(_address != address(0));
        ceoAddress = _address;
    }

    function removePrice(address _game, uint256 _orderId) public {
        require(msg.sender == Games[_game].tokenPrice[_orderId].maker);
        resetPrice(_game, _orderId);
    }

    function resetPrice(address _game, uint256 _orderId) internal {
        Price storage _price = Games[_game].tokenPrice[_orderId];
        _price.maker = address(0);
        _price.Price2JPY = 0;
        _price.buyByFiat = address(0);
        _price.isBuy = false;
        Games[_game].tokenPrice[_orderId] = _price;
        emit _resetPrice(_game, _orderId);
    }

    function resetPrice4sub(address _game, uint256 _tokenId) public onlySub {
        resetPrice(_game, _tokenId);
    }
}