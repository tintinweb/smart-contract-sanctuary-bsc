/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: non

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

interface IERC20 {
 
    function totalSupply() external view returns (uint256);
 
    function balanceOf(address account) external view returns (uint256);
   
    function transfer(address recipient, uint256 amount) external returns (bool);
   
    function allowance(address owner, address spender) external view returns (uint256);
   
    function approve(address spender, uint256 amount) external returns (bool);
   
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
 
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity >=0.6.0 <0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity >=0.6.2 <0.8.0;


library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
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

        // solhint-disable-next-line avoid-low-level-calls
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

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


pragma solidity >=0.6.0 <0.8.0;

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

 
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
  
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { 
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol

pragma solidity >=0.6.0 <0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol

pragma solidity >=0.6.0 <0.8.0;


abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;


        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

pragma solidity >=0.6.0 <0.8.0;

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }


    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }


    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }


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


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
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


    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
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


    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


interface BridgeReward {
  function mint(address _to, uint256 _amount) external;
}


//pragma solidity 0.6.12;

contract JungleBridge {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Dev address
    address payable public devaddr = 0x2096aFDaA68EEaE1EbF95DFdf565eE6d9B1fbA37;
    address payable public operator1 = 0x2096aFDaA68EEaE1EbF95DFdf565eE6d9B1fbA37;
    address payable public operator2 = 0x2096aFDaA68EEaE1EbF95DFdf565eE6d9B1fbA37;

    // BridgeMaster Address    
    address payable public bridgeMaster = 0x63Fb8A264C45Bb5A1272Ad443cD9A17976EfD14b;
    
    // Fee address
    address payable public feeaddr = 0x45472B519de9Ac90A09BF51d9E161B8C6476361D;

    //BridgeReward Token
    address public bridgeRewardToken = 0x2ecB6C7a91bE881ecc55dE75Fe1Cd37F84d97DA1;

    //Fee Token address
    address public bridgeFeeToken = 0x5afFcD905fBDc00Cbee9c8D78BBbD256b0344d3b;    
    
    // minimal Fee Amount in ETH
    uint256 public bridgeFee = 0;

    // Fee to be baid in the BridgeToken
    uint256 public bridgeTokenFee = 0;

    // Reward to be paid for Bridging
    uint256 public bridgeReward = 1e18;

    // switches Reward minting on and off
    uint8 public mintON = 1;    
    
    // TakeFee in Token per 10 000
    uint32 public takeFee = 10; // 10 = 0,1%
    
    // Counts number of Deposits
    uint32 public depositCount = 0;

    // total Deposited Token Amount
    uint256 depositedToken = 0;

    // total amount of FeeToken collected
    uint256 feeTokenCollected = 0;
    
    // Total tokens Sent to Bridge Users
    uint256 bridgedToken = 0;

    // Info of using Bridge
    struct BridgeInfo {
        address userAddr;
        uint32 oppositeChainID;
        uint32 depositID;
        address depositToken;
        uint256 depositAmount;
    }
   
    // Info of recent Deposits
    BridgeInfo[] public bridgeInfo;

    event Deposit(address indexed dst, uint wad);
    
    event Bridge(address indexed user, address depositToken, uint256 depositAmount);
    event Send(address indexed receipient, address receiveToken, uint256 receiveAmount);
    
    event SetDevAddress(address indexed user, address indexed _devaddr);
    event SetFeeAddress(address indexed user, address indexed _feeaddr);
    event SetFeeToken(address indexed user, address  _feeToken);
    event SetBridgeRewardToken(address indexed user, address _BridgeRewardToken);

    event SetDepositIdCounter(address indexed user, uint32 oppositeChainID, uint32 depositID);

    event SetTokenAmountCounter(address indexed user, address tokenAddress, uint256 tokenAmount);

    event SetBridgeMasterAddress(address indexed user, address indexed _bridgeMasteraddr);

    event SetBridgeFee(address indexed user, uint256 _BridgeFee);
    event SetBridgeTokenFee(address indexed user, uint256 _BridgeTokenFee);    

    event SetTakeFee(address indexed user, uint32 _Fee);
    
    // balance of user depositing
    mapping (address => uint256) public balanceOf;

    // Number of user Deposit ID
    mapping (uint32 => uint32) public depositIdCounter;
   
    
    fallback () external payable {
    deposit ();
    }

    receive () external payable {}

    // Receive full balance of any Token from Contract
    function receiveAllAnyToken (address _token) public {   
        require (msg.sender == devaddr, "dev: you are not DEV?");     
        uint256 all = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, all);
    }

    // Receive any Token from Contract
    function receiveAnyToken (address receipient, address _token, uint256 _amount) public {
        require (msg.sender == devaddr || msg.sender == operator1 || msg.sender == operator2, "receiveAnyToken: no permission to receive");
        require (IERC20(_token).balanceOf(address(this)) >= _amount, "receiveAnyToken: not enough balance to send");
        IERC20(_token).safeTransfer(receipient, _amount);
    }

    // Pay out all ETH from Contract to dev
    function receiveETH () public {
        require (msg.sender == devaddr, "dev: you are not DEV?");
        devaddr.transfer(address(this).balance);
    }

    // Pay out ETH from Contract
    function sendEthTo (address payable receipient, uint256 amount) public {
        require (msg.sender == devaddr || msg.sender == operator1 || msg.sender == operator2, "sendEthTo: no permission to send");
        require (address(this).balance >= amount, "sendEthTo: not enough balance to send");
        receipient.transfer(amount);
    }

    // Update dev address by the previous dev.
    function setDevAddress (address payable _devaddr) public {
        require (msg.sender == devaddr, "dev: you are not DEV?");
        devaddr = _devaddr;
        emit SetDevAddress(msg.sender, _devaddr);
    }

    // Update operator address by the  dev.
    function setOperatorAddress (address payable _operator1, address payable _operator2) public {
        require(msg.sender == devaddr, "dev: you are not DEV?");
        operator1 = _operator1;
        operator2 = _operator2;        
    }
    
    // Update Fee address by the dev.
    function setFeeAddress(address payable _feeaddr) public {
        require(msg.sender == devaddr, "dev: you are not DEV?");
        feeaddr = _feeaddr;
        emit SetFeeAddress(msg.sender, _feeaddr);
    }

    // Update Bridge Fee Token.
    function setFeeToken(address _bridgeFeeToken) public {
        require(msg.sender == devaddr, "dev: you are not DEV?");
        bridgeFeeToken = _bridgeFeeToken;
        emit SetFeeToken(msg.sender, _bridgeFeeToken);
    }

    // Update Bridge Reward Token
    function setBridgeRewardToken(address _bridgeRewardToken) public {
        require(msg.sender == devaddr, "dev: you are not DEV?");
        bridgeRewardToken = _bridgeRewardToken;
        emit SetBridgeRewardToken(msg.sender, _bridgeRewardToken);
    }

    // Enable / Disable Reward Minting  1 = on
    function setMintON (uint8 _mintON) public {
        require(msg.sender == devaddr, "dev: you are not DEV?");
        mintON = _mintON;
    }

    // Update Fee address by the dev.
    function setBridgeMaster (address payable _bridgeMaster) public {
        require(msg.sender == devaddr, "dev: you are not DEV?");
        bridgeMaster = _bridgeMaster;
        emit SetBridgeMasterAddress(msg.sender, _bridgeMaster);
    }    

    // update BridgeFee
    function setBridgeFee (uint256 _bridgeFee) public {
        require(msg.sender == devaddr, "dev: you are not DEV?");
        bridgeFee = _bridgeFee;
        emit SetBridgeFee(msg.sender, _bridgeFee);
    }

    // update BridgeFee
    function setBridgeTokenFee (uint256 _bridgeTokenFee) public {
        require(msg.sender == devaddr, "dev: you are not DEV?");
        bridgeTokenFee = _bridgeTokenFee;
        emit SetBridgeTokenFee(msg.sender, _bridgeTokenFee);
    }

    // update Token fee to Take from Deposit
    function setTokenFee (uint32 _takeFee) public {
        require(msg.sender == devaddr, "dev: you are not DEV?");
        takeFee = _takeFee;
        emit SetTakeFee(msg.sender, _takeFee);
    }

    // Function to deposit ETH
    function deposit () public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }


    // Function to set depositIdCounter
    function setDepositIdCounter (uint32 oppositeChainID, uint32 depositID) public {
        require (msg.sender == devaddr || msg.sender == bridgeMaster, "setDepositIdCounter: you are not Allowed");
        depositIdCounter[oppositeChainID] = depositID;
        emit SetDepositIdCounter(msg.sender, oppositeChainID, depositID);
    }

    // See Number of pending deposits
    function bridgeInfoLength () external view returns (uint256) {
        return bridgeInfo.length;
    }

    // See how many token are already reserved to be bridged
    function getTokenAmount (uint32 chainID, address tokenAddr) external view returns (uint256) {
        uint256 tokenAmount = 0;

        for (uint256 i = 0; i < bridgeInfo.length; i++) {
            BridgeInfo memory info = bridgeInfo[i];
            if (info.oppositeChainID == chainID && info.depositToken == tokenAddr) {
                tokenAmount += info.depositAmount;
            }
        }
        return tokenAmount;
    }
    
   

    // Function to Bridge paying ETH
    function bridge (address depositToken, uint32 oppositeChainID, uint256 depositAmount) public payable {

        require (msg.value >= bridgeFee, "bridge: paid Fee to low!");        
        require (depositAmount <= IERC20(depositToken).balanceOf(address(msg.sender)), "bridge: Not enough Token to send!");
      
        uint256 sendAmount;

        if (takeFee > 0){
        uint256 feeAmount = depositAmount.mul(takeFee).div(10000);
        sendAmount = depositAmount.sub(feeAmount);    
        IERC20(depositToken).safeTransferFrom(address(msg.sender), devaddr, feeAmount);
        IERC20(depositToken).safeTransferFrom(address(msg.sender), address(this), sendAmount);
        }

        else {         
        sendAmount = depositAmount;
        IERC20(depositToken).safeTransferFrom(address(msg.sender), address(this), sendAmount);
        }

        depositCount = depositCount + 1;

        bridgeInfo.push(
            BridgeInfo({
                userAddr: msg.sender,
                oppositeChainID: oppositeChainID,
                depositID: depositCount,
                depositToken: depositToken,
                depositAmount: sendAmount
            })
        );

        if (mintON == 1) {
        BridgeReward(bridgeRewardToken).mint(msg.sender, bridgeReward);
        }
        
        depositedToken = depositedToken + sendAmount;

        emit Bridge(msg.sender, depositToken, sendAmount);
    }

    // Function to Bridge paying the Fee Token
    function bridgeWithFuel (address depositToken, uint32 oppositeChainID, uint256 depositAmount, uint256 tokenFeeAmount) public {

        require (tokenFeeAmount >= bridgeTokenFee, "bridgeWithFuel: paid tokenFee to low!");        
        require (depositAmount <= IERC20(depositToken).balanceOf(address(msg.sender)), "bridgeWithFuel: Not enough Token to send!");

        IERC20(bridgeFeeToken).safeTransferFrom(address(msg.sender), address(this), tokenFeeAmount);

        feeTokenCollected = feeTokenCollected + tokenFeeAmount;
      
        uint256 sendAmount;

        if (takeFee > 0){
        uint256 feeAmount = depositAmount.mul(takeFee).div(10000);
        sendAmount = depositAmount.sub(feeAmount);    
        IERC20(depositToken).safeTransferFrom(address(msg.sender), devaddr, feeAmount);
        IERC20(depositToken).safeTransferFrom(address(msg.sender), address(this), sendAmount);
        }

        else {         
        sendAmount = depositAmount;
        IERC20(depositToken).safeTransferFrom(address(msg.sender), address(this), sendAmount);
        }

        depositCount = depositCount + 1;

        bridgeInfo.push(
            BridgeInfo({
                userAddr: msg.sender,
                oppositeChainID: oppositeChainID,
                depositID: depositCount,
                depositToken: depositToken,
                depositAmount: sendAmount
            })
        );

        if (mintON == 1) {
        BridgeReward(bridgeRewardToken).mint(msg.sender, bridgeReward*15/10);
        }

        depositedToken = depositedToken + sendAmount;

        emit Bridge(msg.sender, depositToken, sendAmount);
    }

    // Function to Send the Token to the Bridge User
    function send (address getToken, uint32 oppositeChainID, uint32 depositID, address receipient, uint256 getAmount) public {
        require (msg.sender == devaddr || msg.sender == bridgeMaster, "send: you are not Allowed");
        require (depositID > depositIdCounter[oppositeChainID], "send: depositID to low!");       
        require (getAmount < IERC20(getToken).balanceOf(address(this)), "send: Not enough Token in Bridge");

        IERC20(getToken).safeTransfer(receipient, getAmount);

        depositIdCounter[oppositeChainID] = depositID;

        bridgedToken = bridgedToken + getAmount;

        emit Send(receipient, getToken, getAmount);
    }

    // deletes arry of all pending Deposits
    function deletePending () public {    
        require(msg.sender == devaddr  || msg.sender == bridgeMaster, "deletePending: you are not DEV or bridge master!");
        delete bridgeInfo;    
    }

    // Function to call multiple Sendings in one Transaction
    function batchSend (BridgeInfo[] calldata jobs) public {
        require (msg.sender == devaddr || msg.sender == bridgeMaster, "batchSend: you are not Allowed");
        for (uint256 i = 0; i < jobs.length; i++) {
            BridgeInfo memory job = jobs[i];
            send(job.depositToken,job.oppositeChainID,job.depositID,job.userAddr,job.depositAmount);
        }
    }

}