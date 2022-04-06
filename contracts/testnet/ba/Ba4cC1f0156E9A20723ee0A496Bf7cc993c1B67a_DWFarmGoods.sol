/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

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

// File: contracts/FarmGoods.sol


pragma solidity >=0.4.16 <0.9.0;


contract DWFarmGoods {
    using SafeMath for uint256;

    // Token parameters
    string _name = "Darling Waifu Farming Goods";
    string _symbol = "DWFARMED";
    uint8 _decimals = 0;
    uint256 _supply = 0;

    // Important accounts
    address owner = msg.sender;
    address support;
    address game;
    mapping(address => bool) games;

    // Custom members
    mapping(address => uint256) internal confirmations;
    mapping(address => mapping(uint256 => uint256)) internal balances;
    mapping(uint256 => uint256) internal subtotals;
    mapping(uint256 => uint256) internal prices;
    uint256 internal materialCount = 100;

    // Basic events
    event Transfer(address indexed from, address indexed to, uint256 amount);

    // Permission modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner.");
        _;
    }

    modifier onlySupport() {
        require(msg.sender == support, "You are not the support.");
        _;
    }

    modifier onlyGame() {
        require(games[msg.sender], "You are not an game.");
        _;
    }

    // Permission setter
    function setSupport(address _support) external onlyOwner {
        support = _support;
    }

    function setGame(address _game) external onlySupport {
        games[_game] = true;
    }

    function unsetGame(address _game) external onlySupport {
        games[_game] = false;
    }

    function rennounceOwnership() external onlyOwner {
        owner = address(0);
    }

    // Token information functions for Metamask detection
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
        return _supply;
    }

    // Total supply for a certain material
    function specificSupply(uint256 _materialIndex)
        external
        view
        returns (uint256)
    {
        return subtotals[_materialIndex];
    }

    // Add materials to account
    function addMaterial(
        address _destination,
        uint256 _materialIndex,
        uint256 _amount,
        address _confirmation
    ) external onlyGame {
        balances[_destination][_materialIndex] = balances[_destination][
            _materialIndex
        ].add(_amount);
        _supply = _supply.add(_amount);
        subtotals[_materialIndex] = subtotals[_materialIndex].add(_amount);
        confirmations[_confirmation] = _amount + 1;
        emit Transfer(address(0), _destination, _amount);
    }

    // Burn materials
    function burn(
        address _target,
        uint256 _materialIndex,
        uint256 _amount
    ) external onlyGame {
        require(
            balances[_target][_materialIndex] >= _amount,
            "Not enough balance for this material."
        );
        balances[_target][_materialIndex] = balances[_target][_materialIndex]
            .sub(_amount);
        _supply = _supply.sub(_amount);
        subtotals[_materialIndex] = subtotals[_materialIndex].sub(_amount);
        emit Transfer(_target, address(0), _amount);
    }

    // Set a new material count
    function setMaterialCount(uint256 _count) external onlySupport {
        materialCount = _count;
    }

    // Set price for each item
    function setPrice(uint256 _materialId, uint256 _price)
        external
        onlySupport
    {
        prices[_materialId] = _price;
    }

    // Set price for each item
    function getPrice(uint256 _materialId) external view returns (uint256) {
        return prices[_materialId];
    }

    // ERC20~ish functions
    function balanceOf(address _target) external view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < materialCount; i++) {
            total = total.add(balances[_target][i]);
        }
        return total;
    }

    function specificBalanceOf(address _target, uint256 _materialIndex)
        external
        view
        returns (uint256)
    {
        return balances[_target][_materialIndex];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount,
        uint256 _materialIndex
    ) external onlyGame {
        require(
            _amount >= balances[_from][_materialIndex],
            "Not enough balance for this material."
        );
        balances[_from][_materialIndex] = balances[_from][_materialIndex].sub(
            _amount
        );
        balances[_to][_materialIndex] = balances[_to][_materialIndex].add(
            _amount
        );
        emit Transfer(_from, _to, _amount);
    }

    // Get the confirmation for a successful harvest
    // If the result is 0, then no confirmation has been received.
    // Else, the result is the actual harvest + 1
    function getConfirmation(address _confirmation)
        external
        view
        returns (uint256)
    {
        return confirmations[_confirmation];
    }
}