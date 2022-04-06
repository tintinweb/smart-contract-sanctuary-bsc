/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

// File: contracts/Swapper.sol


pragma solidity >=0.4.16 <0.9.0;

interface SwapRouter {
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

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

// File: contracts/Peach.sol


pragma solidity >=0.4.16 <0.9.0;



library PeachMathematician {
    using SafeMath for uint256;

    /**
    @notice Calculates big transactions 
    @dev Takes into account previous transactions in the last 24h
    @return Percentage (100k-based)
     */
    function getBigCommission(uint256 x, uint256 currentExpenditure)
        internal
        pure
        returns (uint256)
    {
        // Get the daily commission
        uint256 paidCommission = (currentExpenditure *
            (50000 - (45000 * 10**25) / (currentExpenditure + 10**25))) /
            100000;
        uint256 currentCommission = ((x + currentExpenditure) *
            (50000 - (45000 * 10**25) / ((x + currentExpenditure) + 10**25))) /
            100000;
        // Subtract the already payed commission and return
        return ((currentCommission - paidCommission) * 100000) / x;
    }
}

/**
 /$$$$$$$                               /$$      
| $$__  $$                             | $$      
| $$  \ $$ /$$$$$$   /$$$$$$   /$$$$$$$| $$$$$$$ 
| $$$$$$$//$$__  $$ |____  $$ /$$_____/| $$__  $$
| $$____/| $$$$$$$$  /$$$$$$$| $$      | $$  \ $$
| $$     | $$_____/ /$$__  $$| $$      | $$  | $$
| $$     |  $$$$$$$|  $$$$$$$|  $$$$$$$| $$  | $$
|__/      \_______/ \_______/ \_______/|__/  |__/
@title Peach
@author Franco Ramirez, Alonso Avalo (Darling Waifu NFT)
@notice Token for Darling Waifu. More details at https://docs.darlingwaifu.com
@dev Uses auto swap on DEX transactions
@custom:repo https://github.com/DarlingWaifuNFT/Peach
 */
contract Peach {
    using SafeMath for uint256;

    uint256 TGE;
    address private owner;
    address internal mainSwap;
    bool internal isTokenLive;
    bool internal isAutoSwappable;
    mapping(address => uint256) private balances;

    address internal game;
    mapping(address => bool) internal swaps;
    mapping(address => bool) internal managedAddress;
    mapping(address => uint256) internal locked;
    mapping(address => mapping(address => uint256)) internal allowances;
    mapping(address => mapping(uint256 => uint256)) internal expenditures;
    mapping(address => mapping(uint256 => uint256)) internal sales;

    address[] internal path;
    address[] internal pricePath;

    SwapRouter internal router;
    address internal routerAddress;

    /**
      Pools go here
    */
    uint256 internal constant poolNumber = 6;
    address internal cex;
    address internal dex;
    address internal ido;
    address internal ifo;
    address internal presale;
    address internal rewards;

    address internal support;
    address[] internal stabilizers;

    uint8 _decimals = 18;
    string _symbol = "PEACH";
    string _name = "Darling Waifu Peach";
    uint256 _totalSupply = 5000000 * 10**_decimals;

    constructor(
        address _cex,
        address _dex,
        address _ido,
        address _ifo,
        address _presale,
        address _rewards,
        address[] memory _stabilizers
    ) {
        // Definitions
        cex = _cex;
        dex = _dex;
        ido = _ido;
        ifo = _ifo;
        presale = _presale;
        rewards = _rewards;

        // Stabilizer definitions
        for (uint256 i = 0; i < _stabilizers.length; i++)
            stabilizers.push(_stabilizers[i]);

        owner = msg.sender;
        isTokenLive = false;
        support = msg.sender;
        TGE = block.timestamp;
        isAutoSwappable = true;

        // Parameter assignments
        managedAddress[_ido] = true;
        managedAddress[_ifo] = true;
        managedAddress[_dex] = true;
        managedAddress[_cex] = true;
        managedAddress[_presale] = true;
        managedAddress[_rewards] = true;
        managedAddress[address(this)] = true;
        path.push(address(this));
        pricePath.push(address(this));
        balances[owner] = _totalSupply / 2;
        balances[_cex] = 0 * 10**_decimals;
        balances[_ido] = 60000 * 10**_decimals;
        balances[_dex] = 900000 * 10**_decimals;
        balances[_ifo] = 1000000 * 10**_decimals;
        balances[_presale] = 40000 * 10**_decimals;
        balances[_rewards] = 2300000 * 10**_decimals;
    }

    // Permission system
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner.");
        _;
    }

    modifier onlySupport() {
        require(msg.sender == support, "You are not the support.");
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
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    // Setters
    function setAutoSwap(bool _hasAutoSwap) external onlySupport {
        isAutoSwappable = _hasAutoSwap;
    }

    function setGame(address _game) external onlySupport {
        game = _game;
        _approve(rewards, _game, 2**250);
    }

    function setManagedAddressses(
        address[poolNumber] calldata _managedAddresses
    ) external onlySupport {
        ido = _managedAddresses[0];
        ifo = _managedAddresses[1];
        dex = _managedAddresses[2];
        cex = _managedAddresses[3];
        rewards = _managedAddresses[4];
        presale = _managedAddresses[5];
    }

    function setPath(address[] calldata _path) external onlySupport {
        delete path;
        delete pricePath;
        path.push(address(this));
        path.push(_path[0]);
        pricePath.push(address(this));
        pricePath.push(_path[0]);
        pricePath.push(_path[1]);
    }

    function setRouter(address _router) external onlySupport {
        routerAddress = _router;
        router = SwapRouter(_router);
        _approve(address(this), _router, 2**250);
    }

    function setStabilizers(address[] calldata _stabilizers)
        external
        onlySupport
    {
        delete stabilizers;
        for (uint256 i = 0; i < _stabilizers.length; i++)
            stabilizers.push(_stabilizers[i]);
    }

    function setSupport(address _support) external onlyOwner {
        support = _support;
    }

    // Kind of setters
    function addSwaps(address[] calldata _autoSwaps) external onlySupport {
        if (mainSwap == address(0)) {
            mainSwap = _autoSwaps[0];
            _approve(address(this), mainSwap, 2**250);
        }
        for (uint256 i = 0; i < _autoSwaps.length; i++)
            swaps[_autoSwaps[i]] = true;
    }

    function beginTrading() external onlySupport {
        isTokenLive = true;
    }

    function removeSwaps(address[] calldata _autoSwaps) external onlySupport {
        for (uint256 i = 0; i < _autoSwaps.length; i++)
            swaps[_autoSwaps[i]] = false;
    }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }

    // Custom views
    function getCurrentPrice() external view returns (uint256) {
        return _getCurrentPrice();
    }

    function unlockedBalanceOf(address _wallet)
        external
        view
        returns (uint256)
    {
        return balances[_wallet];
    }

    function _getCurrentPrice() internal view returns (uint256) {
        // Returns the price of the token in BUSD with 3 decimals
        uint256[] memory _amounts = router.getAmountsOut(
            10**_decimals,
            pricePath
        );
        return _amounts[_amounts.length - 1].div(10**15);
    }

    // ERC20 customized functions and events
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(address _owner, address _spender, uint256 _value);

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

    function balanceOf(address _wallet) external view returns (uint256) {
        return balances[_wallet] + locked[_wallet];
    }

    function transfer(address _to, uint256 _amount)
        external
        tokenLive
        returns (bool)
    {
        require(
            msg.sender != address(0),
            "ERC20: transfer from the zero address"
        );
        require(_to != address(0), "ERC20: transfer to the zero address");
        uint256 _commission;
        (_amount, _commission) = _getCustomPriceAndCommision(
            msg.sender,
            _to,
            _amount
        );
        _transfer(msg.sender, _to, _amount, _commission);
        if (msg.sender == address(this) || _to == address(this)) return true;
        emit Transfer(msg.sender, _to, _amount.sub(_commission));
        if (_commission > 0) emit Transfer(msg.sender, rewards, _commission);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external tokenLive returns (bool) {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(
            allowances[_from][msg.sender] >= _amount || msg.sender == _from,
            "Allowance is lower than requested funds"
        );
        if (msg.sender != _from)
            allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(
                _amount
            );
        uint256 _commission;
        (_amount, _commission) = _getCustomPriceAndCommision(
            _from,
            _to,
            _amount
        );
        _transfer(_from, _to, _amount, _commission);
        if (_from == address(this) || _to == address(this)) return true;
        emit Transfer(_from, _to, _amount.sub(_commission));
        if (_commission > 0) emit Transfer(_from, rewards, _commission);
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
            return;
        }
        balances[_to] = balances[_to].add(_amount);
    }

    // Core functions to allow token functionality
    function _getCustomPriceAndCommision(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (uint256, uint256) {
        // Returns `_amount, _commission`
        // The commission is a percentage, but in base 100000
        uint256 _commission;

        // Managed addresses don't pay commissions
        if (managedAddress[_from] || managedAddress[_to]) return (_amount, 0);

        // The user is selling tokens
        if (swaps[_to]) {
            require(
                _getSales(_from) < 10,
                "You have reached 10 sales today. Try again tomorrow."
            );
            // 2% commission to be payed in bnb
            _commission = _amount.div(50);
            _autoSwap(_from, _commission);
            _amount = _amount.sub(_commission);
            uint256 liquidityCommission = _amount
                .mul(_getCurrentPrice())
                .mul(93)
                .div(100);
            _commission = PeachMathematician.getBigCommission(
                liquidityCommission,
                _getExpenditure(_from, 24)
            );
            uint256 thisHour = (block.timestamp - TGE) / 3600;
            sales[_from][thisHour] = sales[_from][thisHour].add(1);
            expenditures[_from][thisHour] = expenditures[_from][thisHour].add(
                liquidityCommission
            );
            _commission = _amount.mul(_commission).div(100000);
            balances[_from] = balances[_from].sub(_commission);
            balances[address(this)] = balances[address(this)].add(_commission);
            _swap(rewards, _commission);
            _amount = _amount.sub(_commission);
            return (_amount, 0);
        }

        // The user is buying tokens
        if (swaps[_from]) {
            // 1% commission to be payed in bnb
            _commission = _amount.div(100);
            _autoSwap(_from, _commission);
            _amount = _amount.sub(_commission);
            return (_amount, 0);
        }

        // The user is not playing the game
        if (msg.sender != game) {
            return (_amount, _amount.mul(5000).div(100000));
        }

        // The user is playing the game
        if (_amount <= locked[_from]) {
            // The user has enough locked tokens
            balances[_from] = balances[_from].add(_amount);
            locked[_from] = locked[_from].sub(_amount);
        } else if (locked[_from] > 0) {
            // The user is unlocking its last tokens
            balances[_from] = balances[_from].add(locked[_from]);
            locked[_from] = 0;
        }

        return (_amount, 0);
    }

    function getBigCommission(uint256 _amount, uint256 _expenditure)
        external
        pure
        returns (uint256)
    {
        return PeachMathematician.getBigCommission(_amount, _expenditure);
    }

    function getExpenditure(address _target, uint256 _hours)
        external
        view
        returns (uint256)
    {
        return _getExpenditure(_target, _hours);
    }

    function getSales(address _target) external view returns (uint256) {
        return _getSales(_target);
    }

    function _autoSwap(address _sender, uint256 _amount) internal {
        require(balances[_sender] >= _amount, "Not enough usable balance.");

        address stabilizer = stabilizers[
            uint256(keccak256(abi.encodePacked(block.timestamp))) %
                stabilizers.length
        ];

        balances[_sender] = balances[_sender].sub(_amount);
        if (!isAutoSwappable && balances[address(this)] < 10**_decimals) {
            balances[stabilizer] = balances[stabilizer].add(_amount);
            return;
        }
        balances[address(this)] = balances[address(this)].add(_amount);
        if (!swaps[_sender]) _swap(stabilizer, balances[address(this)]);
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

    function _swap(address _to, uint256 _amount) internal {
        router.swapExactTokensForETH(
            _amount,
            0,
            path,
            _to,
            block.timestamp + 30 minutes
        );
    }

    // Functionality for in-game only tokens
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

    // TODO: REMOVE THIS, ONLY FOR THE BETA
    mapping(address => uint256) internal claims;

    function faucet() external {
        require(
            block.timestamp >= claims[msg.sender] + 24 hours,
            "You can only claim peach every 24h."
        );
        claims[msg.sender] = block.timestamp;
        balances[msg.sender] = balances[msg.sender].add(1000 * 10**_decimals);
        emit Transfer(address(0), msg.sender, 1000 * 10**_decimals);
    }
}