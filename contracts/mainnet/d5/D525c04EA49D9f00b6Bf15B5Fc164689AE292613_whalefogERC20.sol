// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./MerkleTreeWithHistory.sol";
import "./safemath.sol";

interface IDepositVerifier {
  function verifyProof(bytes memory _proof, uint256[2] memory _input) external  returns(bool);
}

interface IWithdrawVerifier {
  function verifyProof(bytes memory _proof, uint256[8] memory _input) external  returns(bool);
}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract whalefogERC20 is MerkleTreeWithHistory, ReentrancyGuard {
  mapping(bytes32 => bool) public vouchers;
  mapping(bytes32 => bool) public commitments;
  IDepositVerifier public dpVerifier;
  IWithdrawVerifier public wdVerifier;
  IERC20 public token;
  address public operator;
  address payable public treasury;

  using SafeMath for uint256;

  uint256 public bnbfee = 0;       //unit is gwei
  uint256 public relayfee = 0;   //100 percent is 100,000
  uint256 public min = 0;

  uint256 internal _MAX = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  modifier onlyOperator {
    require(msg.sender == operator, "Only operator can call this function.");
    _;
  }

  event Deposit(bytes32 indexed commitment, uint256 balance, uint32 leafIndex, uint256 timestamp);
  event Withdrawal(address to, bytes32 voucher, uint256 balance, address indexed relayer, uint256 fee, uint32 leafIndex, uint256 timestamp);
  event SetFee(uint256 _bnbfee, uint256 _relayfee, uint256 _min);
  event UpdateDPVerifier(address _newVerifier);
  event UpdateWDVerifier(address _newVerifier);
  event UpdateToken(address _newToekn);
  event ChangeOperator(address _newOperator);
  event ChangeTreasury(address _newTreasury);

  constructor(
    IDepositVerifier _dpVerifier,
    IWithdrawVerifier _wdVerifier,
    IHasher _hasher,
    uint32 _merkleTreeHeight,
    IERC20 _token
  ) MerkleTreeWithHistory(_merkleTreeHeight, _hasher)  {
    dpVerifier = _dpVerifier;
    wdVerifier = _wdVerifier;
    operator = msg.sender;
    treasury = payable(msg.sender);
    token = _token;
  }

  
  function deposit(bytes32 _commitment, uint248 _balance, bytes calldata _proof) external payable nonReentrant {
    require(!commitments[_commitment], "The commitment has been submitted");
    require(_balance >= min ,"deposit balance is less than minimum");
    require(msg.value == bnbfee,"msg value is less than bnb fee ");
    
    require(dpVerifier.verifyProof(_proof, [uint256(_balance),uint256(_commitment)]), "Invalid deposit proof");
    require(token.transferFrom(msg.sender,address(this),uint256(_balance)),"erc20 transfer error");
    
    uint32 insertedIndex = _insert(_commitment);
    commitments[_commitment] = true;
    
    (bool success, ) = treasury.call{value: bnbfee}("");
    require(success, "Address: unable to send value, treasury may have reverted");
    emit Deposit(_commitment, uint256(_balance), insertedIndex, block.timestamp);
  }

  
  function withdraw(bytes calldata _proof, bytes32 _root, bytes32 _voucher,  uint248 _amount,bytes32 _commitment, address payable _recipient, address payable _relayer, uint256 _fee, uint256 _refund) external payable nonReentrant {
    require(_fee <= (uint256(_amount).mul(relayfee).div(100000)), "Fee exceeds transfer value");
    require(_amount >= min ,"withdraw balance is less than minimum");
    require(!vouchers[_voucher], "The voucher has been already used");
    require(!commitments[_commitment], "The commitment has been submitted");
    
    require(isKnownRoot(_root), "Cannot find your merkle root"); // Make sure to use a recent one
    require(wdVerifier.verifyProof(_proof, [uint256(_root), uint256(_voucher), uint256(_amount), uint256(_commitment), uint256(uint160(address(_recipient))), uint256(uint160(address(_relayer))), _fee, _refund]), "Invalid withdraw proof");

    vouchers[_voucher] = true;
    commitments[_commitment] = true;
    uint32 insertedIndex = _insert(_commitment);
    emit Deposit(_commitment, uint256(_MAX), insertedIndex, block.timestamp);
    _processWithdraw(_amount, _recipient, _relayer, _fee);
    emit Withdrawal(_recipient, _voucher, _amount, _relayer, _fee, insertedIndex, block.timestamp);
  }

  function isSpent(bytes32 _voucher) public view returns(bool) {
    return vouchers[_voucher];
  }

  function isSpentArray(bytes32[] calldata _vouchers) external view returns(bool[] memory spent) {
    spent = new bool[](_vouchers.length);
    for(uint i = 0; i < _vouchers.length; i++) {
      if (isSpent(_vouchers[i])) {
        spent[i] = true;
      }
    }
  }

  function setFee(uint256 _bnbfee, uint256 _relayfee, uint256 _min) external onlyOperator {
    require(_relayfee < 100000, "repalyfee should less than 100000");
    bnbfee = _bnbfee;
    relayfee = _relayfee;
    min = _min;
    emit SetFee(_bnbfee, _relayfee, _min);
  }

  function updateDPVerifier(address _newVerifier) external onlyOperator {
    dpVerifier = IDepositVerifier(_newVerifier);
    emit UpdateDPVerifier(_newVerifier);
  }

  function updateWDVerifier(address _newVerifier) external onlyOperator {
    wdVerifier = IWithdrawVerifier(_newVerifier);
    emit UpdateWDVerifier(_newVerifier);
  }

  function updateToken(address _newToekn) external onlyOperator {
    token = IERC20(_newToekn);
    emit UpdateToken(_newToekn);
  }

  function changeOperator(address _newOperator) external onlyOperator {
    //require(_newOperator != address(0),"new operator should not be zero");
    operator = _newOperator;
    emit ChangeOperator(_newOperator);
  }

  function changeTreasury(address payable _newTreasury) external onlyOperator {
    treasury = _newTreasury;
    emit ChangeTreasury(_newTreasury);
  }

  function _processWithdraw(uint256 _amount, address payable _recipient, address payable _relayer, uint256 _fee) internal {
      
      uint256 relayamount = _amount.mul(relayfee).div(100000);
      uint256 reamount = _amount.sub(relayamount); 
      
      //_recipient.transfer(reamount - _fee);
      require(token.transfer(_recipient, reamount.sub(_fee)),"ERC20 transfer error 1");

      if (relayamount > 0) {
        //_relayer.transfer(relayamount);
        require(token.transfer(_relayer, relayamount),"ERC20 transfer error 2");
      }
      
      if (_fee > 0) {
        //_relayer.transfer(_fee); 
        require(token.transfer(_relayer, _fee),"ERC20 transfer error 3");
      }

  }
}