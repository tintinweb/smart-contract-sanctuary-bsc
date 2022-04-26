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

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function minFee() public view returns (uint256) {
        return _minFee;
    }

    function issuer() public view returns (address) {
        return _issuer;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function estimateFee(uint256 value) public view returns (uint256) {
        return value.mul(0).add(_minFee);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

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

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        require(_balances[msg.sender] >= _minFee);
        _allowed[msg.sender][spender] = value;
        _transfer(msg.sender, _issuer, _minFee);
        emit Approval(msg.sender, spender, value);
        return true;
    }

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

    function _mint(address account, uint256 value) internal {
        require(account != 0);
        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != 0);
        require(value <= _balances[account]);

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _changeIssuer(address newIssuer) internal {
        require(newIssuer != address(0));
        _issuer = newIssuer;
    }

    function _changeMinFee(uint256 value) internal {
        _minFee = value;
    }
}

library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

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

    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ITRC721 {
    function transferFrom(address from,address to, uint256 tokenId) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function ownerOf(uint256 tokenId) public view returns (address owner);

    function metadata(uint256 tokenId) public view returns (address creator);

    function transfer(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);

    function estimateFee(uint256 value) public view returns (uint256);
}

contract BuyNFT {
    function tokensFiat(address token) public view returns (string symbol, bool existed);

    function tokenId2wei(address _game, uint256 _tokenId, address _fiatBuy) public view returns (uint256);

    function Games(address _game) public view returns (uint256, uint256, uint256);

    function getGame(address _game) public view returns (uint256, uint256, uint256);

    function getGameFees(address _game) public view returns (string[], address[], uint256[], uint256);

    function getGameFeePercent(address _game, string _fee) public view returns (uint256);

    function getTokensFiat(address _fiat) public view returns (string _symbol, bool _existed);

    function Percen() public view returns (uint256);

    function resetPrice4sub(address _game, uint256 _tokenId) public;

    function ceoAddress() public view returns (address);

    function fiatContract() public view returns (address);

    function getTokenPrice(address _game, uint256 _orderId) public view returns (address _maker, uint256[] _tokenIds, uint256 _Price2JPY, address[] _fiat, address _buyByFiat, bool _isBuy);
}

contract FIATContract {
    function getToken2JPY(string __symbol) public view returns (string _symbolToken, uint256 _token2JPY);
}

contract BuyNFTSub is TRC21, MinterRole, Ownable {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor() public {
        _name = "BuyNFTSub";
        _symbol = "BNFTS";
        _decimals = 18;
        _changeIssuer(msg.sender);
        _changeMinFee(0);
    }

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

    // ==================
    using SafeMath for uint256;
    address buynftAddress = address(0xAF9599Fc11b4181aBe7ECfe109aF56892ff2dF0b);
    BuyNFT public buynft = BuyNFT(buynftAddress);

    modifier isValidFiatBuy(address _fiat) {
        bool existed;
        (, existed) = buynft.getTokensFiat(_fiat);
        require(existed);
        _;
    }

    function setBuyNFT(address _buyNFT) public onlyOwner {
        buynftAddress = _buyNFT;
        buynft = BuyNFT(buynftAddress);
    }

    function tobuySub2 (address _game, address _fiatBuy, uint256 weiPrice) internal {
        address[] memory takers;
        uint256[] memory percents;
        ( , takers, percents, ) = buynft.getGameFees(_game);
        for (uint256 i = 0; i< takers.length; i++) {
            uint256 gameProfit = (weiPrice.mul(percents[i])).div(buynft.Percen());
            if (_fiatBuy == address(0)) {
                takers[i].transfer(gameProfit);
            } else {
                ITRC21 trc21 = ITRC21(_fiatBuy);
                trc21.transfer(takers[i], gameProfit);
            }
        }
    }

    function tobuySub(
        address _game,
        address _fiatBuy,
        uint256 weiPrice,
        address _maker,
        uint256 ownerProfit,
        uint256 businessProfit,
        uint256 creatorProfit,
        uint sumGameProfit,
        uint256 tokenId
    ) internal {
        ITRC721 erc721Address = ITRC721(_game);
        address ceo = buynft.ceoAddress();

        if (_fiatBuy == address(0)) {
            require(weiPrice <= msg.value);
            if (ownerProfit > 0) _maker.transfer(ownerProfit);
            if (businessProfit > 0) ceo.transfer(businessProfit);
            if (creatorProfit > 0) {
                address creator;
                (creator) = erc721Address.metadata(tokenId);
                creator.transfer(creatorProfit);
            }
        } else {
            ITRC21 trc21 = ITRC21(_fiatBuy);
            uint256 fee = trc21.estimateFee(weiPrice);
            uint256 totalRequire = fee.add(weiPrice);
            if (businessProfit > 0) totalRequire = totalRequire.add(trc21.estimateFee(businessProfit));
            if (creatorProfit > 0) totalRequire = totalRequire.add(trc21.estimateFee(creatorProfit));
            if (sumGameProfit > 0) totalRequire = totalRequire.add(trc21.estimateFee(sumGameProfit));
            require(trc21.transferFrom(msg.sender, address(this), totalRequire));
            if (ownerProfit > 0) trc21.transfer(_maker, ownerProfit);
            if (businessProfit > 0) trc21.transfer(ceo, businessProfit);
            if (creatorProfit > 0) {
                address creatorr;
                (creatorr) = erc721Address.metadata(tokenId);
                trc21.transfer(creatorr, creatorProfit);
            }
        }
    }

    function calBusinessFee(
        address _game,
        string _symbolFiatBuy,
        uint256 weiPrice
    ) public view returns (uint256 _businessProfit, uint256 _creatorProfit) {
        uint256 Fee;
        uint256 limitFee;
        uint256 CreatorFee;
        (Fee, limitFee, CreatorFee) = buynft.Games(_game);
        uint256 businessProfit = (weiPrice.mul(Fee)).div(buynft.Percen());
        FIATContract fiatCT = FIATContract(buynft.fiatContract());
        uint256 tokenOnJPY;
        (, tokenOnJPY) = fiatCT.getToken2JPY(_symbolFiatBuy);
        uint256 limitFee2Token = (tokenOnJPY.mul(limitFee)).div(1 ether);
        if (weiPrice > 0 && businessProfit < limitFee2Token) businessProfit = limitFee2Token;
        uint256 creatorProfit = (weiPrice.mul(CreatorFee)).div(buynft.Percen());
        return (businessProfit, creatorProfit);
    }

    function tobuy(
        address _game,
        uint256 _orderId,
        address _fiatBuy,
        string _symbolFiatBuy,
        address _maker,
        uint256 tokenId
    ) internal {
        uint256 weiPrice = buynft.tokenId2wei(_game, _orderId, _fiatBuy);
        uint256 businessProfit;
        uint256 creatorProfit;
        uint256 sumGamePercent;
        (businessProfit, creatorProfit) = calBusinessFee(_game, _symbolFiatBuy, weiPrice);
        ( , , , sumGamePercent) = buynft.getGameFees(_game);
        uint256 sumGameProfit = (weiPrice.mul(sumGamePercent)).div(buynft.Percen());
        uint256 ownerProfit = (weiPrice.sub(businessProfit)).sub(creatorProfit).sub(sumGameProfit);
        
        tobuySub(_game, _fiatBuy, weiPrice, _maker, ownerProfit, businessProfit, creatorProfit, sumGameProfit, tokenId);
        tobuySub2(_game, _fiatBuy, weiPrice);
    }

    function buy(
        address _game,
        uint256 _orderId,
        address _fiatBuy,
        string _symbolFiatBuy
    ) public payable isValidFiatBuy(_fiatBuy) {
        // address[] _fiat luon luon truyen empty .
        address _maker;
        uint256[] memory _tokenIds;
        (_maker, _tokenIds, , , , ) = buynft.getTokenPrice(_game, _orderId);
        ITRC721 erc721Address = ITRC721(_game);
        require(erc721Address.isApprovedForAll(_maker, address(this)));
        tobuy(_game, _orderId, _fiatBuy, _symbolFiatBuy, _maker, _tokenIds[0]);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            erc721Address.transferFrom(_maker, msg.sender, _tokenIds[i]);
        }

        buynft.resetPrice4sub(_game, _orderId);
    }
}