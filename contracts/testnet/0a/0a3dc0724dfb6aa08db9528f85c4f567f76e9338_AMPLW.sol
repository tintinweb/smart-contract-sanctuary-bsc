pragma solidity 0.4.24;

import "./ERC20Detailed.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./SafeMathInt.sol";



contract AMPLW is ERC20Detailed, Ownable {

using SafeMath for uint256;
using SafeMathInt for int256;

event LogRebase(uint256 indexed epoch, uint256 totalSupply);
event LogRebasePaused(bool paused);
event LogTokenPaused(bool paused);
event LogAMPLWPolicyUpdated(address AMPLWPolicy);

address public AMPLWPolicy;

modifier onlyAMPLWPolicy() {
    require(msg.sender == AMPLWPolicy);
    _;
}

bool public rebasePaused;
bool public tokenPaused;

modifier whenRebaseNotPaused() {
    require(!rebasePaused);
    _;
}

modifier whenTokenNotPaused() {
    require(!tokenPaused);
    _;
}

modifier validRecipient(address to) {
    require(to != address(0x0));
    require(to != address(this));
    _;
}

uint256 private constant DECIMALS = 18;
uint256 private constant MAX_UINT256 = ~uint256(0);
uint256 private constant INITIAL_AMPLW_SUPPLY = 5000000 * 10**DECIMALS;

uint256 private constant TOTAL_GONS = MAX_UINT256 -
    (MAX_UINT256 % INITIAL_AMPLW_SUPPLY);

uint256 private constant MAX_SUPPLY = ~uint128(0); 

uint256 private _totalSupply;
uint256 private _gonsPerFragment;
mapping(address => uint256) private _gonBalances;

mapping(address => mapping(address => uint256)) private _allowedAMPLWs;

function setAMPLWPolicy(address AMPLWPolicy_) external onlyOwner {
    AMPLWPolicy = AMPLWPolicy_;
    emit LogAMPLWPolicyUpdated(AMPLWPolicy_);
}

function setRebasePaused(bool paused) external onlyOwner {
    rebasePaused = paused;
    emit LogRebasePaused(paused);
}

function setTokenPaused(bool paused) external onlyOwner {
    tokenPaused = paused;
    emit LogTokenPaused(paused);
}

function rebase(uint256 epoch, int256 supplyDelta)
    external
    onlyAMPLWPolicy
    whenRebaseNotPaused
    returns (uint256)
{
    if (supplyDelta == 0) {
        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    if (supplyDelta < 0) {
        _totalSupply = _totalSupply.sub(uint256(supplyDelta.abs()));
    } else {
        _totalSupply = _totalSupply.add(uint256(supplyDelta));
    }

    if (_totalSupply > MAX_SUPPLY) {
        _totalSupply = MAX_SUPPLY;
    }

    _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

    emit LogRebase(epoch, _totalSupply);
    return _totalSupply;
}

function initialize(address owner_) public initializer {
    ERC20Detailed.initialize("AMPL POW", "AMPLW", uint8(DECIMALS));
    Ownable.initialize(owner_);

    rebasePaused = false;
    tokenPaused = false;

    _totalSupply = INITIAL_AMPLW_SUPPLY;
    _gonBalances[owner_] = TOTAL_GONS;
    _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

    emit Transfer(address(0x0), owner_, _totalSupply);
}

function totalSupply() public view returns (uint256) {
    return _totalSupply;
}

function balanceOf(address who) public view returns (uint256) {
    return _gonBalances[who].div(_gonsPerFragment);
}

function transfer(address to, uint256 value)
    public
    validRecipient(to)
    whenTokenNotPaused
    returns (bool)
{
    uint256 gonValue = value.mul(_gonsPerFragment);
    _gonBalances[msg.sender] = _gonBalances[msg.sender].sub(gonValue);
    _gonBalances[to] = _gonBalances[to].add(gonValue);
    emit Transfer(msg.sender, to, value);
    return true;
}

function allowance(address owner_, address spender)
    public
    view
    returns (uint256)
{
    return _allowedAMPLWs[owner_][spender];
}

function transferFrom(
    address from,
    address to,
    uint256 value
) public validRecipient(to) whenTokenNotPaused returns (bool) {
    _allowedAMPLWs[from][msg.sender] = _allowedAMPLWs[from][msg
        .sender]
        .sub(value);

    uint256 gonValue = value.mul(_gonsPerFragment);
    _gonBalances[from] = _gonBalances[from].sub(gonValue);
    _gonBalances[to] = _gonBalances[to].add(gonValue);
    emit Transfer(from, to, value);

    return true;
}

function approve(address spender, uint256 value)
    public
    whenTokenNotPaused
    returns (bool)
{
    _allowedAMPLWs[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
}

function increaseAllowance(address spender, uint256 addedValue)
    public
    whenTokenNotPaused
    returns (bool)
{
    _allowedAMPLWs[msg.sender][spender] = _allowedAMPLWs[msg
        .sender][spender]
        .add(addedValue);
    emit Approval(
        msg.sender,
        spender,
        _allowedAMPLWs[msg.sender][spender]
    );
    return true;
}


function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    whenTokenNotPaused
    returns (bool)
{
    uint256 oldValue = _allowedAMPLWs[msg.sender][spender];
    if (subtractedValue >= oldValue) {
        _allowedAMPLWs[msg.sender][spender] = 0;
    } else {
        _allowedAMPLWs[msg.sender][spender] = oldValue.sub(
            subtractedValue
        );
    }
    emit Approval(
        msg.sender,
        spender,
        _allowedAMPLWs[msg.sender][spender]
    );
    return true;
}
}