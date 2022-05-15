//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
//pragma solidity >=0.6.12;
//pragma experimental ABIEncoderV2;
//pragma solidity ^0.8.0;
// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
  
interface IERC20 {
    function totalSupply() external view returns (uint256);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
} 

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  //internal
    constructor ()   {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ow1");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ow2");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}


library Rank{
  struct schoolData{
    mapping(address => uint256)  scores;
    mapping(address => address)  _nextStudents;
    uint256  listSize;
    
    address  lastAddress;
    uint256  lastScore;
  }

  struct rankDetail {
    address _address;
    uint _number;
  }

  uint256 public constant limitRank=150;

  address constant GUARD = address(1);


  function addStudent(schoolData storage data,address student, uint256 score) internal{
    require(data._nextStudents[student] == address(0));
    data.scores[student] = score;

    if (score>=data.lastScore){

      address index = _findIndex(data,score);
      data._nextStudents[student] = data._nextStudents[index];
      data._nextStudents[index] = student;

      data.listSize++;

      if(data.listSize <= limitRank){
       if( data.lastScore==0 ){
          data.lastAddress=student;
          data.lastScore = score;
        }else if (score <= data.lastScore){
          data.lastAddress=student;
          data.lastScore = score;
        }
      }else{
        (address lastIndex,address preIndex) = _findLastStudent(data);
        removeStudent(data,lastIndex);
        data.lastScore = data.scores[preIndex];
        data.lastAddress= preIndex;
      }
      
    }

  }

  function increaseScore(schoolData storage data,address student, uint256 score) internal {
    updateScore(data,student, data.scores[student] + score);
  }

  function updateScore(schoolData storage data,address student, uint256 newScore) internal {
    require(data._nextStudents[student] != address(0));
    if (newScore>data.lastScore){
      address prevStudent = _findPrevStudent(data,student);
      address nextStudent = data._nextStudents[student];
      if(_verifyIndex(data,prevStudent, newScore, nextStudent)){
        data.scores[student] = newScore;
      } else {
        removeStudent(data,student);
        addStudent(data,student, newScore);
      }
    }

  }

  function removeStudent(schoolData storage data,address student) internal {
    require(data._nextStudents[student] != address(0));
    address prevStudent = _findPrevStudent(data,student);
    data._nextStudents[prevStudent] = data._nextStudents[student];
    data._nextStudents[student] = address(0);
    data.scores[student] = 0;
    data.listSize--;
  }

  function getTop(schoolData storage data,uint256 k) public view returns(address[] memory) {
    require(k <= data.listSize);
    address[] memory studentLists = new address[](k);
    address currentAddress = data._nextStudents[GUARD];
    for(uint256 i = 0; i < k; ++i) {
      studentLists[i] = currentAddress;
      currentAddress = data._nextStudents[currentAddress];
    }
    return studentLists;
  }
  function getTopDetail(schoolData storage data,uint256 k) public view returns(rankDetail[] memory) {
    require(k <= data.listSize);
    rankDetail[] memory studentLists = new rankDetail[](k);
    address currentAddress = data._nextStudents[GUARD];
    for(uint256 i = 0; i < k; ++i) {
      studentLists[i]._address = currentAddress;
      studentLists[i]._number = data.scores[currentAddress];
      currentAddress = data._nextStudents[currentAddress];
    }
    return studentLists;
  }
  function getRankBefore(schoolData storage data,uint256 k) public view returns(address) {
    require(k <= data.listSize);
    address restudent;
    address currentAddress = data._nextStudents[GUARD];
    for(uint256 i = 0; i < k; ++i) {
      if (i==k-1){
        restudent = currentAddress;
      }
 
      currentAddress = data._nextStudents[currentAddress];
    }
    return restudent;
  }

  function getRankByAddress(schoolData storage data,address _user) public view returns(uint256) {
    address currentAddress = data._nextStudents[GUARD];
    for(uint256 i = 0; i < data.listSize; ++i) {
        if (_user==currentAddress){
            return i+1;
        } 
      currentAddress = data._nextStudents[currentAddress];
    }
    return 0;
  }

  function _verifyIndex(schoolData storage data,address prevStudent, uint256 newValue, address nextStudent)
    internal
    view
    returns(bool)
  {
    return (prevStudent == GUARD || data.scores[prevStudent] >= newValue) &&
           (nextStudent == GUARD || newValue > data.scores[nextStudent]);
  }

  function _findIndex(schoolData storage data,uint256 newValue) internal view returns(address) {
    address candidateAddress = GUARD;
    while(true) {
      if(_verifyIndex(data,candidateAddress, newValue, data._nextStudents[candidateAddress]))
        return candidateAddress;
      candidateAddress = data._nextStudents[candidateAddress];
    }
    return address(0);
  }

  function _isPrevStudent(schoolData storage data,address student, address prevStudent) internal view returns(bool) {
    return data._nextStudents[prevStudent] == student;
  }

  function _findPrevStudent(schoolData storage data,address student) internal view returns(address) {
    address currentAddress = GUARD;
    while(data._nextStudents[currentAddress] != GUARD) {
      if(_isPrevStudent(data,student, currentAddress))
        return currentAddress;
      currentAddress = data._nextStudents[currentAddress];
    }
    return address(0);
  }


  function _findLastStudent(schoolData storage data) internal view returns(address,address) {
      address currentAddress = GUARD;
      address preAddress;
      while(data._nextStudents[currentAddress] != GUARD) {
        preAddress=currentAddress;
        currentAddress = data._nextStudents[currentAddress];
      }
      return (currentAddress ,preAddress);
  }
}