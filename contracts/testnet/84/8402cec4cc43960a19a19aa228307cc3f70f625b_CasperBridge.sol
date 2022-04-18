/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

// SPDX-License-Identifier: UNLICENSED

// contracts/TokenVesting.sol
// SPDX-License-Identifier: Apache-2.0 (please remove thie line)
pragma solidity 0.8.5;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);


  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  function mint(address to, uint256 amount) external returns(uint256);

  function burn(address from, uint256 amount) external returns(uint256);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

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
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

contract CasperBridge is Context, Ownable {

    struct CasperTx {
        uint256 amount;
        address recipient;
        string sender;
    }

    uint256 public bscTxNumber = 0;

    struct BscTx {
        uint256 amount;
        address sender;
        string recipient;
        string casperTxHash;
    }

    mapping(string => CasperTx) public casperTxInfo;

    mapping(uint256 => BscTx) public bscTxInfo;

    mapping(address => bool) public admins;

    IBEP20 immutable public token;

    event Mint(string _txHash, string _sender, address _recipient, uint256 _amount, uint256 amount);
    event Burn(address _sender, string _recipient, uint256 _amount, uint256 amount);
    event AddAdmin(address _address);
    event RemoveAdmin(address _address);
//    event CompleteTx(uint256 _bscTxNumber, address _sender, string _recipient, uint256 _amount, string _casperTxHash);

    constructor(address _token) {
        require(_token != address(0x0));
        token = IBEP20(_token);
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "Only Admin: sender is not admin");
        _;
    }

    function addAdmin(address _address) external onlyOwner {
        require(_address != address(0x0), "address is invalid");
        require(!admins[_address], "this address is already added as a admin");
        admins[_address] = true;
        emit AddAdmin(_address);
    }

    function removeAdmin(address _address) external onlyOwner {
        require(admins[_address], "this address is not admin");
        admins[_address] = false;
        emit RemoveAdmin(_address);
    }

    function mint(string memory _txHash, string memory _sender, address _recipient, uint256 _amount) external onlyAdmin{
        require(casperTxInfo[_txHash].recipient == address(0x0), "This transaction was already completed");
        uint256 amount = token.mint(_recipient, _amount);
        CasperTx memory casperTx = CasperTx({
            amount: _amount,
            sender: _sender,
            recipient: _recipient
        });
        casperTxInfo[_txHash] = casperTx;

        emit Mint(_txHash, _sender, _recipient, _amount, amount);
    }

    function burn(string memory _recipient, uint256 _amount) external {
        require(_amount <= token.balanceOf(msg.sender), "amount is invalid");
        uint256 amount = token.burn(msg.sender, _amount);
        BscTx memory bscTx = BscTx({
            amount: _amount,
            sender: msg.sender,
            recipient: _recipient,
            casperTxHash: ""
        });
        bscTxNumber += 1;
        bscTxInfo[bscTxNumber] = bscTx;

        emit Burn(msg.sender, _recipient, _amount, amount);
    }

//    function completeTx(uint256 _bscTxNumber, string memory _casperTxHash) external onlyOwner {
//        require(_bscTxNumber != 0, "BSC Tx number is 0");
//        require(_bscTxNumber <= bscTxNumber, "BSC Tx number is invalid");
//        require(keccak256(abi.encodePacked(_casperTxHash)) == keccak256(abi.encodePacked("")), "Casper Tx Hash is invalid");
//        BscTx storage bscTx = bscTxInfo[_bscTxNumber];
//        bscTx.casperTxHash = _casperTxHash;
//
//        emit CompleteTx(_bscTxNumber, bscTx.sender, bscTx.recipient, bscTx.amount, _casperTxHash);
//    }
}