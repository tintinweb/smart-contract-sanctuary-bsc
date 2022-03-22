/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract MushakICO is Ownable {
    using SafeMath for uint256;
    using Address for address;
    // IBEP20 public baseToken;
    IBEP20 public presaleToken;
    // mapping(address => uint256) public locked;
    uint256 private totalParticipants;
    mapping(address => uint256) public _balances;
    address private wallet;
    uint256 private unlocked;
    address private ICOadmin;
    uint256 private weiBalance;
    uint256 private weiRaised;
    uint256 public presalerate = 10200000 ;
    bool public phase1 = true;
    bool public paused = false;
    struct participant{
        address _participant;
        uint256 timestamp;
    }
    participant[] public participants;
   

    function endPhase1(bool _phase) external onlyOwner {
        
        phase1 = _phase;
    }
    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return presaleToken.balanceOf(account);
    } 

    function ToatalParticipantsCount() public view returns(uint256){
        return totalParticipants;
    }

    constructor(address _presaleToken,address _wallet) {
        ICOadmin = msg.sender;
        wallet = _wallet;
        // require(_baseToken != address(0) && _baseToken.isContract(), "PresaleSwap: Invalid token contract address");
        require(_presaleToken != address(0) && _presaleToken.isContract(), "PresaleSwap: Invalid token contract address");
        // baseToken = IBEP20(_baseToken);
        presaleToken = IBEP20(_presaleToken);
    }
    function pause() external onlyOwner {
        require(!paused, "PresaleSwap: Presale is paused");
        paused = true;
    }
    function unpause() external onlyOwner {
        require(paused, "PresaleSwap: Presale paused");
        paused = false;
    }
    receive () external payable {
    buyToken(msg.sender);
  }

  fallback () external payable {
      buyToken(_msgSender());
  }
    
    event Transfer(address indexed sender, address indexed recipient, uint256 value);

    function buyToken(address beneficiary) public payable{
        require(beneficiary != address(0));
        require(msg.value != 0);
        require(!paused,"ICO Paused");        
        uint256 weiAmount = msg.value;
        if(phase1==true){
            require(weiAmount<=25550000000000000);
            require(balanceOf(beneficiary)<260000* 10**18,"phase 1 not allowed more token");

        }
        uint256 tokens = weiAmount.mul(presalerate);
        if(balanceOf(beneficiary)<=0){
            totalParticipants+=1;
           participants.push(
               participant(beneficiary,block.timestamp)
           );                 
        }

        _balances[beneficiary] += tokens;
        weiRaised = weiRaised.add(weiAmount);
        weiBalance = weiBalance.add(weiAmount);

        presaleToken.transfer(beneficiary,tokens);
        emit Transfer(address(this), beneficiary, tokens);
    }
    
    function setICORate(uint256 _rate) external onlyOwner() {
        presalerate = _rate;
    }
   
    function withdrawBNB(uint256 _amount) external onlyOwner {
        payable(wallet).transfer(_amount);
        weiBalance -= _amount;
    }

    // function withdrawBNB(address _recipient, uint256 _amount) external onlyOwner {
    //     payable(_recipient).transfer(_amount);
    //     weiBalance -= _amount;
    // }


    function withdrawPresaleToken(address _recipient, uint256 _amount) external onlyOwner {
        require(presaleToken.transfer(_recipient, _amount), "PresaleSwap: Failed to transfer Presale Token");
    }
     
    function BalanceOfBaseToken() public view onlyOwner returns  (uint256){
        return weiBalance;
    }
    function TotalWeiRaised() public view  onlyOwner returns  (uint256){
        return weiRaised;
    }

    function BalanceofPresaleToken() public view returns(uint256){
        return presaleToken.balanceOf(address(this));
    }
    function getAllParticipants()
        public
        view
        returns (participant[] memory)
    {
        return participants;
    }
}