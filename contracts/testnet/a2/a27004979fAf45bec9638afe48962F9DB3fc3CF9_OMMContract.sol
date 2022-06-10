//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OMMContract is Ownable {
    event Log(string func, address sender, uint value, bytes data);
    event Registration(address who, address parent);
    event CreateProduct(uint reward, uint price, uint count);
    event Buy(address who, uint product, uint cost);

    modifier isRegistred {
      require(referals[msg.sender] != address(0), "You are not registred");
      _;
    }

    uint decimals = 18;

    uint public payers;
    uint private systemReward;
    uint firstReward = 50000 * 10 ** decimals;
    uint divider = 10;
    uint minCost = 5 * 10 ** 16;
    bytes public data;
    bytes public secondData;

    mapping(address => address) public referals;
    mapping(address => address[]) public childs;

    struct Product {
      uint reward;
      uint[5] levels;
      uint price;
    }

    Product[] public products;
    mapping(uint => address[]) productsBuyer;
    mapping(address => mapping(uint => bool)) public activation;

    address public token;
    address payable public fund;

    constructor() {
      uint[5] memory _levels = [uint(30), uint(15), uint(5), uint(0), uint(0)];
      _createProduct(50, _levels, 5 * 10 ** 16);
      _createProduct(50, _levels, 10 * 10 ** 16);
      _createProduct(50, _levels, 100 * 10 ** 16);
      _createProduct(50, _levels, 1000 * 10 ** 16);
      _createProduct(50, _levels, 10000 * 10 ** 16);
      _createProduct(50, _levels, 100000 * 10 ** 16);

      fund = payable(msg.sender);

      payers = 19;

      referals[msg.sender] = msg.sender;
    }

    function registration(address _parent) external payable {
      require(msg.value == minCost, 'Invalide price');
      require(_parent != address(0), 'Parent doesn`t exist');
      require(referals[msg.sender] == address(0), 'You are already registered');
      require(referals[_parent] != address(0), 'Your parent not registered');
      referals[msg.sender] = _parent;
      childs[_parent].push(msg.sender);
      emit Registration(msg.sender, _parent);
      buy(0);
    }

    function _registration(address _child, address _parent) external onlyOwner {
      require(_parent != address(0), 'Parent doesn`t exist');
      require(_child != address(0), 'Child doesn`t exist');
      require(referals[_child] == address(0), 'You are already registered');
      require(referals[_parent] != address(0), 'Your parent not registered');
      referals[_child] = _parent;
      childs[_parent].push(_child);
      emit Registration(_child, _parent);
    }

    function _createProduct(uint _reward, uint[5] memory _levels, uint _price) internal{
      require(_reward <= 100, 'Invalide reward');
      require(_levels[0] + _levels[1] + _levels[2] + _levels[3] + _levels[4] <= 100, 'Invalide levels');
      products.push(Product(_reward, _levels, _price));
      activation[owner()][products.length - 1] = true;
      emit CreateProduct(_reward, _price, products.length - 1);
    }

    function createProduct(uint _reward, uint[5] memory _levels, uint _price) external onlyOwner {
      _createProduct(_reward, _levels, _price);
    }

    function buy(uint _product) public payable {
      uint _price = products[_product].price;
      require(msg.value == _price, 'Invalide price');
      uint _levels;
      uint _reward = products[_product].reward;
      uint _sqr = _getSqr();
      payers++;

      systemReward += msg.value * (100 - _reward) / 100; // Add to pool system reward


      address _referal = referals[msg.sender];
      address _parent = _getParent(msg.sender, _product); // Сlosest active parent

      address payable _to = payable(_parent);
      address payable newReferal = payable(_referal);

      _levels = products[_product].levels[0];


      // First Parent
      if (_parent != _referal) {
        if ((msg.value - minCost) != 0) {
          _to.transfer((msg.value - minCost) * _levels / 100); // Send parent reward
        }
        newReferal.transfer(minCost * _levels / 100); // Send active parent reward
      } else {
        _to.transfer(msg.value * _levels / 100); // Send parent reward
      }

      for(uint i = 1; i < 5; i++) {
        _levels = products[_product].levels[i];
        _parent = _getParent(_parent, _product); // Сlosest active parent
        _to = payable(_parent);
        _to.transfer(msg.value * _levels / 100); // Send parent reward
      }

      //activate
      bool _activate = activation[msg.sender][_product];
      if (!_activate) {
        for(uint i = 0; i <= _product; i++){
          if (!activation[msg.sender][i]){
            activation[msg.sender][i] = true;
          }
        }
      }

      emit Buy(msg.sender, _product, _price);

      productsBuyer[_product].push(msg.sender);
      uint duplicator = _price / minCost;
      uint tokenReward = duplicator * firstReward / 10 ** _sqr;
      tokenReward = tokenReward / 2;
      (bool success, bytes memory _data) = token.call(abi.encodeWithSignature("reward(address,uint256)", msg.sender, tokenReward));
      (bool _success, bytes memory __data) = token.call(abi.encodeWithSignature("reward(address,uint256)", _referal, tokenReward));
      require(success, 'Call failed');
      require(_success, 'Call parent failed');
      data = _data;
      secondData = __data;
    }

    function _getParent(address _child, uint _product) internal view returns(address) {
      address _parent = referals[_child];
      bool _activation = activation[_parent][_product];
      while(_activation == false) {
        _parent = referals[_parent];
        _activation = activation[_parent][_product];
      }
      return _parent;
    }

    function _getSqr() internal view returns(uint){
      uint _sqr = 0;
      while(payers / 10 ** (_sqr + 1) != 0) {
        _sqr++;
      }
      return _sqr;
    }

    function changeToken(address _token) external onlyOwner {
      require(_token != address(0), 'Token doesn`t exist');
      token = _token;
    }

    function changeFund(address payable _fund) external onlyOwner {
      require(_fund != address(0), 'Token doesn`t exist');
      fund = _fund;
    }

    function changeFirstReward(uint _reward) external onlyOwner {
      firstReward = _reward;
    }

    function changeDivider(uint _divider) external onlyOwner {
      divider = _divider;
    }

    function changeMinCost(uint _cost) external onlyOwner {
      minCost = _cost;
    }

    function changeProduct(uint _product, uint _reward, uint[5] memory _levels, uint _price) external onlyOwner {
      require(_reward <= 100, "Reward should be less than 100");
      require(_levels[0] + _levels[1] + _levels[2] + _levels[3] + _levels[4] <= 100, "Levels should be less than 100");
      Product storage cProduct = products[_product];
      cProduct.reward = _reward;
      cProduct.price = _price;
    }

    function getReward(address payable _to, uint _amount) external onlyOwner {
      require(_amount <= systemReward, 'Wou Wou');
      systemReward -= _amount;
      _to.transfer(_amount * 90 / 100);
      fund.transfer(_amount * 10 / 100);
    }

    function getSystemReward() external view onlyOwner returns(uint){
      return systemReward;
    }

    fallback() external payable{
      emit Log('fallback', msg.sender, msg.value, msg.data);
    }


    receive() external payable{
      emit Log('receive', msg.sender, msg.value, '');
    }

    function destroySmartContract(address payable _to) public onlyOwner {
        selfdestruct(_to);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}