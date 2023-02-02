/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

/**
The stage is set, and fate doth now call forth,
A challenge unto thee, brave soul.
A world in need of change, a mantle to hold,
Wilt thou embrace this quest, this goal?

Endgame awaits, a future to be shaped,
At endgame.black, a call to arms.
The end draweth nigh, but with thee by our side,
Perchance we shall conquer fate's alarms."
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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
        require(b != 0,
            'parameter 2 can not be 0');
        return a % b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
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
        emit OwnershipRenounced(_owner);
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

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface DividendPayingTokenInterface 
{
    function dividendOf(address _owner, address _rToken) external view returns(uint256);
    function withdrawDividend(address _rToken) external;
    event DividendsDistributed(
        address indexed from,
        uint256 weiAmount,
        address _rToken
    );

    event DividendWithdrawn(
        address indexed to,
        uint256 weiAmount,
        address _rToken
    );
}

interface DividendPayingTokenOptionalInterface {
    function withdrawableDividendOf(address _owner, address _rToken) external view returns(uint256);
    function withdrawnDividendOf(address _owner, address _rToken) external view returns(uint256);
    function accumulativeDividendOf(address _owner, address _rToken) external view returns(uint256);
}

contract DividendPayingToken is ERC20, Ownable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface 
{
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    address public taxSystem;
    address[] public rToken;
    uint256 constant internal magnitude = 2**128;
    mapping (address => uint256) internal magnifiedDividendPerShare;
    mapping (address => mapping (address => int256)) internal magnifiedDividendCorrections;
    mapping (address => mapping (address => uint256)) internal withdrawnDividends;

    mapping (address => uint256) public totalDividendsDistributed;

    modifier onlyTaxSystem() {
        require(msg.sender == taxSystem, "Not Tax System");
        _;
    }

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        
    }

    function distributeRTokenDividends(uint256 amount, address _rToken) public onlyTaxSystem{
        require(totalSupply() > 0);

        if (amount > 0) {
            magnifiedDividendPerShare[_rToken] = magnifiedDividendPerShare[_rToken].add(
                (amount).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, amount, _rToken);

            totalDividendsDistributed[_rToken] = totalDividendsDistributed[_rToken].add(amount);
        }
    }

    function withdrawDividend(address _rToken) public virtual override {
        _withdrawDividendOfUser(payable(msg.sender), _rToken);
    }


    function _withdrawDividendOfUser(address payable user, address _rToken) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(user, _rToken);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user][_rToken] = withdrawnDividends[user][_rToken].add(_withdrawableDividend);
            emit DividendWithdrawn(user, _withdrawableDividend, _rToken);
            bool success = IERC20(_rToken).transfer(user, _withdrawableDividend);

            if(!success) {
                withdrawnDividends[user][_rToken] = withdrawnDividends[user][_rToken].sub(_withdrawableDividend);
                return 0;
            }

            return _withdrawableDividend;
        }

        return 0;
    }


    function dividendOf(address _owner, address _rToken) public view override returns(uint256) {
        return withdrawableDividendOf(_owner, _rToken);
    }


    function withdrawableDividendOf(address _owner, address _rToken) public view override returns(uint256) {
        return accumulativeDividendOf(_owner, _rToken).sub(withdrawnDividends[_owner][_rToken]);
    }

    function withdrawnDividendOf(address _owner, address _rToken) public view override returns(uint256) {
        return withdrawnDividends[_owner][_rToken];
    }

    function accumulativeDividendOf(address _owner, address _rToken) public view override returns(uint256) {
        return magnifiedDividendPerShare[_rToken].mul(balanceOf(_owner)).toInt256Safe()
        .add(magnifiedDividendCorrections[_owner][_rToken]).toUint256Safe() / magnitude;
    }

    function _transfer(address from, address to, uint256 value) internal virtual override {
        require(false);

        for (uint256 i = 0; i < rToken.length; i++) {
            int256 _magCorrection = magnifiedDividendPerShare[rToken[i]].mul(value).toInt256Safe();
            magnifiedDividendCorrections[from][rToken[i]] = magnifiedDividendCorrections[from][rToken[i]].add(_magCorrection);
            magnifiedDividendCorrections[to][rToken[i]] = magnifiedDividendCorrections[to][rToken[i]].sub(_magCorrection);
        }
    }

    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        for (uint256 i = 0; i < rToken.length; i++) {
            magnifiedDividendCorrections[account][rToken[i]] = magnifiedDividendCorrections[account][rToken[i]]
            .sub( (magnifiedDividendPerShare[rToken[i]].mul(value)).toInt256Safe() );
        }
    }

    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        for (uint256 i = 0; i < rToken.length; i++) {
            magnifiedDividendCorrections[account][rToken[i]] = magnifiedDividendCorrections[account][rToken[i]]
            .add( (magnifiedDividendPerShare[rToken[i]].mul(value)).toInt256Safe() );
        }
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);

        if(newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if(newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }

    function addRToken(address _token) external onlyOwner {
        rToken.push(_token);
    }

    function rTokenLength() external view returns (uint256) {
        return rToken.length;
    }

    function updateTaxSystem(address _taxSystem) external onlyOwner {
        taxSystem = _taxSystem;
    }
}

library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

contract ENDGAMEDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    mapping (address => uint256) public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => mapping (address => uint256)) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event MinimumTokenBalanceForDividendsUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic, address _rToken);

    constructor() DividendPayingToken("ENDGAME_Dividend_Tracker", "ENDGAME_Dividend_Tracker") {
        claimWait = 3600;
        minimumTokenBalanceForDividends = 250 * (10**18); //must hold 250+ tokens
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "ENDGAME_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend(address) public pure override {
        require(false, "ENDGAME_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main ENDGAME contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "ENDGAME_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "ENDGAME_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function updateMinimumTokenBalanceForDividends(uint256 newMinimumTokenBalanceForDividends) external onlyOwner {
        require(newMinimumTokenBalanceForDividends != minimumTokenBalanceForDividends,
            "ENDGAME_Dividend_Tracker: Cannot update minimumTokenBalanceForDividends to same value");
        emit MinimumTokenBalanceForDividendsUpdated(newMinimumTokenBalanceForDividends, minimumTokenBalanceForDividends);
        minimumTokenBalanceForDividends = newMinimumTokenBalanceForDividends;
    }

    function getLastProcessedIndex(address _rToken) external view returns(uint256) {
        return lastProcessedIndex[_rToken];
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account, address _rToken)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex[_rToken]) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex[_rToken]));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex[_rToken] ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex[_rToken]) :
                                                        0;

                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }

        withdrawableDividends = withdrawableDividendOf(account, _rToken);
        totalDividends = accumulativeDividendOf(account, _rToken);

        lastClaimTime = lastClaimTimes[account][_rToken];

        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }

    function getAccountAtIndex(uint256 index, address _rToken)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account, _rToken);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if(lastClaimTime > block.timestamp)  {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance, address _rToken) external onlyOwner {
        if(excludedFromDividends[account]) {
            return;
        }

        if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        }
        else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }

        processAccount(account, true, _rToken);
    }

    function process(uint256 gas, address _rToken) public returns (uint256, uint256, uint256) {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if(numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex[_rToken]);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex[_rToken];

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while(gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if(canAutoClaim(lastClaimTimes[account][_rToken])) {
                if(processAccount(payable(account), true, _rToken)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if(gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }
            gasLeft = newGasLeft;
        }

        lastProcessedIndex[_rToken] = _lastProcessedIndex;
        return (iterations, claims, lastProcessedIndex[_rToken]);
    }

    function processAccount(address payable account, bool automatic, address _rToken) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account, _rToken);
        if(amount > 0) {
            lastClaimTimes[account][_rToken] = block.timestamp;
            emit Claim(account, amount, automatic, _rToken);
            return true;
        }

        return false;
    }
}