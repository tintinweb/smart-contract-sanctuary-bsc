/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// File: contracts/Swapper.sol


pragma solidity >=0.4.16 <0.9.0;

interface SwapRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}
// File: contracts/support/safemath.sol


pragma solidity >=0.4.16 <0.9.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title SafeMath32
 * @dev SafeMath library implemented for uint32
 */
library SafeMath32 {

  function mul(uint32 a, uint32 b) internal pure returns (uint32) {
    if (a == 0) {
      return 0;
    }
    uint32 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint32 a, uint32 b) internal pure returns (uint32) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint32 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint32 a, uint32 b) internal pure returns (uint32) {
    assert(b <= a);
    return a - b;
  }

  function add(uint32 a, uint32 b) internal pure returns (uint32) {
    uint32 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title SafeMath16
 * @dev SafeMath library implemented for uint16
 */
library SafeMath16 {

  function mul(uint16 a, uint16 b) internal pure returns (uint16) {
    if (a == 0) {
      return 0;
    }
    uint16 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint16 a, uint16 b) internal pure returns (uint16) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint16 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint16 a, uint16 b) internal pure returns (uint16) {
    assert(b <= a);
    return a - b;
  }

  function add(uint16 a, uint16 b) internal pure returns (uint16) {
    uint16 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/PeachStorage.sol


pragma solidity >=0.4.16 <0.9.0;



library PeachMathematician {
    using SafeMath for uint256;

    /**
    @dev
    - This contract holds the logic for mathematical calculations not built into Solidity
    - **Random number calculations shall not be done here**.
    */
    function getBigCommission(uint256 x, uint256 currentExpenditure)
        internal
        pure
        returns (uint256)
    {
        // Get the daily commission
        uint256 dailyCommission = 60000 -
            (550000 * 10**24) /
            ((x + currentExpenditure) + 10000 * 10**21);
        // Subtract the already payed commission and return
        return
            dailyCommission -
            (60000 - (550000 * 10**24) / (x + 10000 * 10**21));
    }
}

contract Peach {
    using SafeMath for uint256;

    uint256 TGE;
    bool internal isTokenLive;
    address private owner;
    address internal mainSwap;
    mapping(address => uint256) private balances;

    mapping(address => bool) internal swaps;
    mapping(address => bool) internal managedAddress;
    mapping(address => uint256) internal locked;
    mapping(address => mapping(address => uint256)) internal allowances;
    mapping(address => mapping(uint256 => uint256)) internal expenditures;
    mapping(address => mapping(uint256 => uint256)) internal sales;

    address[] internal path;
    address[] internal pricePath;

    address internal routerAddress;
    SwapRouter internal router;

    /**
      Pools go here
    */
    address internal support;
    address internal game;
    address internal stabilizer;
    address internal rewards;
    address internal presale;
    address internal ido;
    address internal ifo;
    address internal dex;
    address internal cex;

    string _name = "Darling Waifu Peach";
    string _symbol = "PEACH";
    uint8 _decimals = 18;
    uint256 _totalSupply = 5000000 * 10**_decimals;

    constructor(
        address _ido,
        address _ifo,
        address _dex,
        address _cex,
        address _rewards,
        address _presale,
        address _stabilizer
    ) {
        // Definitions
        ido = _ido;
        ifo = _ifo;
        dex = _dex;
        cex = _cex;
        presale = _presale;
        rewards = _rewards;
        stabilizer = _stabilizer;

        owner = msg.sender;
        support = msg.sender;
        isTokenLive = false;
        TGE = block.timestamp;

        // Parameter assignments
        managedAddress[_ido] = true;
        managedAddress[_ifo] = true;
        managedAddress[_dex] = true;
        managedAddress[_cex] = true;
        managedAddress[_presale] = true;
        managedAddress[_rewards] = true;
        path.push(address(this));
        pricePath.push(address(this));
        balances[owner] = _totalSupply / 2;
        balances[_ido] = 60000 * 10**_decimals;
        balances[_ifo] = 1000000 * 10**_decimals;
        balances[_dex] = 900000 * 10**_decimals;
        balances[_cex] = 0 * 10**_decimals;
        balances[_presale] = 40000 * 10**_decimals;
        balances[_rewards] = 2300000 * 10**_decimals;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner.");
        _;
    }

    modifier onlySupport() {
        require(msg.sender == support, "You are not the support.");
        _;
    }

    modifier onlyGame() {
        require(msg.sender == game, "You are not the game.");
        _;
    }

    modifier tokenLive() {
        require(
            isTokenLive || managedAddress[tx.origin],
            "The token is not yet able to be traded."
        );
        _;
    }

    // Token information functions
    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function setSupport(address _support) external onlyOwner {
        support = _support;
    }

    function setGame(address _game) external onlySupport {
        game = _game;
        _approve(rewards, _game, 2**250);
    }

    function setRouter(address _router) external onlySupport {
        routerAddress = _router;
        router = SwapRouter(_router);
    }

    function beginTrading() external onlySupport {
        isTokenLive = true;
    }

    function _getCurrentPrice() internal view returns (uint256) {
        // Returns the price of the token in BUSD with 3 decimals
        // TODO: Verify this
        uint256[] memory _amounts = router.getAmountsOut(
            10**_decimals,
            pricePath
        );
        return _amounts[_amounts.length - 1].div(10**15);
    }

    function getCurrentPrice() external view returns (uint256) {
        return _getCurrentPrice();
    }

    function balanceOf(address _wallet) external view returns (uint256) {
        if (_wallet == address(this)) return 2**250;
        return balances[_wallet] + locked[_wallet];
    }

    function unlockedBalanceOf(address _wallet)
        external
        view
        returns (uint256)
    {
        return balances[_wallet];
    }

    // ERC20 proxied functions and events
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(address _owner, address _spender, uint256 _value);

    function getCustomPriceAndCommision(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (uint256, uint256) {
        // Returns `_amount, _commission`
        // The commission is a percentage, but in base 100000
        uint256 _commission = 5000;
        if (swaps[_to] && _getSales(_from) < 10) {
            // Selling tokens
            _commission = _amount.div(50);
            _swap(_from, _commission);
            _amount = _amount.sub(_commission);
            _commission = PeachMathematician.getBigCommission(
                _getCurrentPrice().mul(_amount).mul(93).div(100),
                _getExpenditure(_from, 24)
            );
            uint256 thisHour = (block.timestamp - TGE) / 3600;
            sales[_from][thisHour] = sales[_from][thisHour].add(1);
        } else if (swaps[_from]) {
            // Buying tokens
            _commission = _amount.div(100);
            _swap(_from, _commission);
            _amount = _amount.sub(_commission);
            _commission = 0;
        } else if (msg.sender == game) {
            // The user is playing the game
            if (_amount <= locked[_from]) {
                // The user has enough locked tokens
                balances[_from] = balances[_from].add(_amount);
                locked[_from] = locked[_from].sub(_amount);
            } else {
                // The user is unlocking its last tokens
                balances[_from] = balances[_from].add(locked[_from]);
                locked[_from] = 0;
            }
            _commission = 0;
        } else if (managedAddress[_from]) {
            _commission = 0;
        }
        _commission = _amount.mul(_commission).div(100000);
        return (_amount, _commission);
    }

    function transfer(address _to, uint256 _amount) external tokenLive {
        require(
            msg.sender != address(0),
            "ERC20: transfer from the zero address"
        );
        require(_to != address(0), "ERC20: transfer to the zero address");
        uint256 _commission;
        (_amount, _commission) = getCustomPriceAndCommision(
            msg.sender,
            _to,
            _amount
        );
        _transfer(msg.sender, _to, _amount, _commission);
        emit Transfer(msg.sender, _to, _amount.sub(_commission));
        emit Transfer(msg.sender, rewards, _commission);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external tokenLive {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        if (_from == address(this) && msg.sender == routerAddress) {
            balances[_from] = balances[_from].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            return;
        }
        require(
            allowances[_from][msg.sender] >= _amount || msg.sender == _from,
            "Allowance is lower than requested funds"
        );
        if (msg.sender != _from)
            allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(
                _amount
            );

        uint256 _commission;
        (_amount, _commission) = getCustomPriceAndCommision(
            _from,
            _to,
            _amount
        );
        _transfer(_from, _to, _amount, _commission);
        emit Transfer(_from, _to, _amount.sub(_commission));
        emit Transfer(_from, rewards, _commission);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount,
        uint256 _commission
    ) internal {
        require(balances[_from] >= _amount, "Not enough funds");
        balances[_from] = balances[_from].sub(_amount);
        // Gas fee optimization
        if (_commission > 0) {
            balances[_to] = balances[_to].add(_amount.sub(_commission));
            balances[rewards] = balances[rewards].add(_commission);
        } else {
            balances[_to] = balances[_to].add(_amount);
        }
        uint256 thisHour = (block.timestamp - TGE) / 3600;
        if (swaps[_to])
            expenditures[_from][thisHour] = expenditures[_from][thisHour].add(
                _amount.mul(_getCurrentPrice()).mul(93).div(100)
            );
    }

    function getExpenditure(address _target, uint256 _hours)
        external
        view
        returns (uint256)
    {
        return _getExpenditure(_target, _hours);
    }

    function _getExpenditure(address _target, uint256 _hours)
        internal
        view
        returns (uint256)
    {
        uint256 result = 0;
        uint256 thisHour = (block.timestamp - TGE) / 3600;
        uint256 minHours = thisHour >= _hours ? thisHour - _hours + 1 : 0;
        for (
            uint256 i = thisHour + 1; // We get hours this way
            i > minHours;
            i--
        ) {
            result = result.add(expenditures[_target][i - 1]);
        }
        return result;
    }

    function getSales(address _target) external view returns (uint256) {
        return _getSales(_target);
    }

    function _getSales(address _target) internal view returns (uint256) {
        uint256 _hours = 24;
        uint256 result = 0;
        uint256 thisHour = (block.timestamp - TGE) / 3600;
        uint256 minHours = thisHour >= _hours ? thisHour - _hours + 1 : 0;
        for (
            uint256 i = thisHour + 1; // We get hours this way
            i > minHours;
            i--
        ) {
            result = result.add(sales[_target][i - 1]);
        }
        return result;
    }

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256)
    {
        return allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount)
        external
        tokenLive
        returns (bool)
    {
        _approve(msg.sender, _spender, _amount);
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");
        allowances[_owner][_spender] = _amount;
    }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }

    // Custom functions
    function setPath(address[] calldata _path) external onlySupport {
        while (path.length > 1) path.pop();
        while (pricePath.length > 1) pricePath.pop();
        path.push(path[0]);
        pricePath.push(path[0]);
        pricePath.push(_path[1]);
    }

    // TODO: ERASE THIS FOR GOD'S SAKE
    function getPath()
        external
        view
        returns (address[] memory, address[] memory)
    {
        return (path, pricePath);
    }

    function addSwaps(address[] calldata _swaps) external onlySupport {
        if (mainSwap == address(0)) mainSwap = _swaps[0];
        _approve(address(this), mainSwap, 2**250);
        for (uint256 i = 0; i < _swaps.length; i++) swaps[_swaps[i]] = true;
    }

    function removeSwaps(address[] calldata _swaps) external onlySupport {
        for (uint256 i = 0; i < _swaps.length; i++) swaps[_swaps[i]] = false;
    }

    function _swap(address _sender, uint256 _amount) internal {
        require(balances[_sender] >= _amount, "Not enough usable balance.");
        balances[_sender] = balances[_sender].sub(_amount);
        balances[address(this)] = balances[address(this)].add(_amount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amount,
            0,
            path,
            stabilizer,
            block.timestamp + 30 seconds
        );
    }

    function transferLocked(address _to, uint256 _amount) external {
        require(
            msg.sender != address(0),
            "ERC20: transfer from the zero address"
        );
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(locked[msg.sender] >= _amount, "Not enough locked balance.");
        locked[msg.sender] = locked[msg.sender].sub(_amount);
        locked[_to] = locked[_to].add(_amount);
    }

    function lockAndSend(address _to, uint256 _amount) external {
        require(
            msg.sender != address(0),
            "ERC20: transfer from the zero address"
        );
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(balances[msg.sender] >= _amount, "Not enough balance.");
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        locked[_to] = locked[_to].add(_amount);
    }
}