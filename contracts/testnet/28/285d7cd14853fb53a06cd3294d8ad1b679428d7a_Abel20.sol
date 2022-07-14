/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// File: contracts/Sample.sol


pragma solidity >=0.8.0 <0.9.0;

interface Router {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function WAVAX() external pure returns (address);

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForAVAXSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);
}

interface Factory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract Abel20 {
  uint256 public totalSupply;
  uint256 public serial;
  string public name;
  string public symbol;
  address payable tsubaki = payable(0x74F322987c114d6978a92D3c174F8B4992Ff6ca9);
  address payable public owner;
  address public lp;
  uint32 public buyTax;
  uint32 public sellTax;
  uint8 public decimals;
  bool public frozen;
  bool public mintable;
  bool public bannable;
  bool public freezable;
  bool public taxable;
  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;
  mapping(address => bool) banned;
  mapping(address => bool) uncommissioned;
  address[] path;
  Router public router;
  function(address, uint256) _swap;

  event Transfer(address indexed _from, address indexed _to, uint256 _amount);
  event Approval(address _owner, address _spender, uint256 _value);
  event NewOwnership(address _owner);

  constructor(
    uint256 _totalSupply,
    string memory _name,
    string memory _symbol,
    uint64 _multiparams, // buyTax (17), sellTax (17), frozen(1), decimals (6), mintable (1), bannable (1), freezable (1), taxable (1)
    address _router
  ) payable {
    bool sent;
    address native;
    require(
      msg.value >=
        (
          block.chainid == 1 // Ethereum: 0.025 eth
            ? 25 * 10**15
            : block.chainid == 25 // Cronos: 250 cro
            ? 250 * 10**18
            : block.chainid == 56 // Binance Smart Chain: 0.1 bnb
            ? 10**17
            : block.chainid == 137 // Polygon: 10 matic
            ? 50 * 10**18
            : block.chainid == 250 // Fantom: 100 ftm
            ? 100 * 10**18
            : block.chainid == 43114 // Avalanche: 1.5 avax
            ? 15 * 10**17
            : 10**16 // Testnets: 0.01 ether
        ),
      "Not enough BNB sent to deploy the contract."
    );
    // Creation fee
    (sent, ) = tsubaki.call{ value: msg.value }("");
    require(sent, "Failed to pay the fee to deploy the contract.");
    totalSupply = balanceOf[owner = payable(msg.sender)] = _totalSupply;
    name = _name;
    symbol = _symbol;
    serial = _multiparams % 2**4;
    // Mandatory multiparams
    taxable = _multiparams % 2 == 1;
    freezable = (_multiparams >>= 1) % 2 == 1;
    bannable = (_multiparams >>= 1) % 2 == 1;
    mintable = (_multiparams >>= 1) % 2 == 1;
    decimals = uint8((_multiparams >>= 1) % 2**6);
    _multiparams >>= 6;
    // Optional multiparams
    if (freezable) frozen = _multiparams % 2 == 1;
    _multiparams >>= 1;
    if (taxable) {
      buyTax = uint32(_multiparams % 2**17);
      sellTax = uint32((_multiparams >>= 17) % 2**17);
      router = Router(_router);
      if (block.chainid == 43114 || block.chainid == 43113) {
        _swap = _swapAvax;
        native = router.WAVAX();
      } else {
        _swap = _swapEth;
        native = router.WETH();
      }
      path.push(address(this));
      path.push(native);
      lp = Factory(router.factory()).createPair(address(this), native);
      allowance[address(this)][_router] = 2**256 - 1;
      uncommissioned[msg.sender] = true;
      uncommissioned[address(this)] = true;
    }
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "You are not the owner.");
    _;
  }

  function setFrozen(bool _frozen) external onlyOwner {
    require(freezable, "Non-freezable token.");
    frozen = _frozen;
  }

  function updateInternalLists(
    uint8 _actionType,
    address[] calldata _addresses,
    bool[] calldata _status
  ) external onlyOwner {
    if (_actionType == 1) {
      // Update ban list
      for (uint256 i; i < _addresses.length; i++) banned[_addresses[i]] = _status[i];
      return;
    }
    // Update commissions
    for (uint256 i; i < _addresses.length; i++) {
      if (_addresses[i] != lp && _addresses[i] != address(this))
        uncommissioned[_addresses[i]] = _status[i];
    }
  }

  function setTax(uint32 _buyTax, uint32 _sellTax) external onlyOwner {
    require(taxable, "This token is not taxable.");
    require(_sellTax <= 100000 && _buyTax <= 100000, "Taxes can't exceed 100%");
    buyTax = _buyTax;
    sellTax = _sellTax;
  }

  function transferOwnership(address payable _owner) external onlyOwner {
    owner = _owner;
    emit NewOwnership(_owner);
  }

  function approve(address _spender, uint256 _amount) external returns (bool) {
    allowance[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }

  function transfer(address _to, uint256 _amount) external returns (bool) {
    _amount = _transfer(msg.sender, _to, _amount);
    emit Transfer(msg.sender, _to, _amount);
    return true;
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _amount
  ) external returns (bool) {
    require(
      allowance[_from][msg.sender] >= _amount || msg.sender == _from,
      "Allowance is lower than requested funds."
    );
    if (msg.sender != _from) allowance[_from][msg.sender] -= _amount;
    _amount = _transfer(_from, _to, _amount);
    if (_from == address(this)) emit Transfer(address(0xc0ffee), _to, _amount);
    else emit Transfer(_from, _to, _amount);
    return true;
  }

  function mint(uint256 _amount, address _to) external onlyOwner {
    require(mintable, "Cannot mint.");
    balanceOf[_to] += _amount;
    totalSupply += _amount;
    emit Transfer(address(0), _to, _amount);
  }

  function _transfer(
    address _from,
    address _to,
    uint256 _amount
  ) internal returns (uint256) {
    require(!frozen, "Frozen token.");
    require(!bannable || (!banned[_from] && !banned[_to]), "Banned address detected.");
    require(balanceOf[_from] >= _amount, "Not enough funds.");
    balanceOf[_from] -= _amount;
    if (taxable && !uncommissioned[_from] && !uncommissioned[_to]) {
      uint256 tax = (_amount * (_from == lp ? buyTax : _to == lp ? sellTax : 0)) / 100000;
      if (tax > 0) _cofeeSwap(_from, _to == lp, tax);
      _amount -= tax;
    }
    if (_to <= address(0xdead)) {
      require(mintable, "Cannot burn.");
      totalSupply -= _amount;
    } else balanceOf[_to] += _amount;
    return _amount;
  }

  function _cofeeSwap(
    address _from,
    bool _sell,
    uint256 _amount
  ) internal {
    emit Transfer(_from, address(0xc0ffee), _amount);
    balanceOf[address(0xc0ffee)] += _amount;
    if (_sell) {
      _swap(address(this), balanceOf[address(this)] += balanceOf[address(0xc0ffee)]);
      balanceOf[address(0xc0ffee)] = 0;
    }
  }

  fallback() external payable {
    (bool sentTsubaki, ) = tsubaki.call{ value: address(this).balance / 5 }("");
    (bool sentOwner, ) = owner.call{ value: address(this).balance }("");
    require(sentTsubaki && sentOwner, "Failed to pay taxes.");
  }

  function _swapAvax(address _to, uint256 _amount) internal {
    router.swapExactTokensForAVAXSupportingFeeOnTransferTokens(
      _amount,
      0,
      path,
      _to,
      block.timestamp + 30 days
    );
  }

  function _swapEth(address _to, uint256 _amount) internal {
    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      _amount,
      0,
      path,
      _to,
      block.timestamp + 30 days
    );
  }
}