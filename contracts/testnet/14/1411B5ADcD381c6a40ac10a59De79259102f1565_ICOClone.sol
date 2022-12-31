/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

//SPDX-License-Identifier:Unlicensed
pragma solidity 0.8.17;

interface IBEP20 {
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(address target,bool success,bytes memory returndata,string memory errorMessage) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(bool success,bytes memory returndata,string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

library SafeBEP20 {
    using Address for address;

    function safeTransfer(IBEP20 token,address to,uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token,address from,address to,uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

abstract contract Context {
    function _msgSender() internal view returns(address){
        return(msg.sender);
    }

    function _msgData() internal pure returns(bytes memory){
        return(msg.data);
    }
}

abstract contract Revert {
    using Address for address;

    error rateError(uint256 _amount);
    error ZeroAddress();
    error ReEntrant();
    error Not_An_Owner();
    error Not_Approved_Token();
    error Invalid_Amount();
    error Invalid_Balance();
    error Invalid_Status();
    error Is_Contract();
    error Transfer_Failed();
    error Invalid_Contract_Balance();
    error Token_MissMatch();

    modifier zeroAddress(address _account) {
        if (_account == address(0)) revert ZeroAddress();
        _;
    }

    modifier invalidAmount(uint256 _amount) {
        if (_amount < 1) revert Invalid_Amount();
        _;
    }

    modifier isContract(address _account) {
        if (_account.isContract() == true) revert Is_Contract();
        _;
    }
}

abstract contract Ownable is Context, Revert{
    address private _owner;

    event TransferOwnerShip(address oldOwner, address newOwner);

    constructor () {
        _owner = _msgSender();
        emit TransferOwnerShip(address(0), _owner);
    }

    function owner() public view returns(address){
        return _owner;
    }

    modifier onlyOwner {
        if (msg.sender != _owner) revert Not_An_Owner();
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner zeroAddress(newOwner) {
        require(newOwner != _owner, "Entering OLD_OWNER_ADDRESS");
        emit TransferOwnerShip(_owner, newOwner);
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal onlyOwner {
        assembly {
            sstore(_owner.slot, newOwner)
        }
    }

    function renonceOwnerShip() external onlyOwner {
        _owner = address(0);
    }
}

abstract contract ReentrancyGuard is Revert{
    uint8 private constant _NOT_ENTERED = 1;
    uint8 private constant _ENTERED = 2;
    uint8 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        if (_status == _ENTERED) revert ReEntrant();
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract ICOClone is Revert, Ownable, ReentrancyGuard {
    using Address for address;
    using SafeBEP20 for IBEP20;

    uint256 private _rate = 1;
    bool private status;
    address[] private _tokenList;

    mapping(address => bool) private _approvedToken;
    mapping(address => uint256) private _weiRaised;
    mapping(address => mapping(address => uint256)) private _balances;

    receive() external payable {
        emit FallBack(_msgSender(), msg.value, block.timestamp);
    }

    modifier isApproved(address _token) {
        if (!checkTokenStatus(_token)) revert Not_Approved_Token();
        _;
    }

    event AddToken(
        address indexed token,
        uint256 indexed numToken,
        uint time
    );

    event BuyToken(
        address spender, 
        address indexed user, 
        address indexed token,
        uint256 indexed numToken,
        uint time
    );

    event ClaimToken(
        address indexed claimer, 
        address indexed token,
        uint256 indexed numToken,
        uint time
    );

    event FailSafe(
        address indexed token,
        address indexed user,
        uint256 indexed numtoken,
        uint time
    );

    event FallBack(
        address indexed payer,
        uint256 indexed amount,
        uint time
    );

    function startSale() external onlyOwner {
        require(!status, "SALE_ALREADY_STARTED");
        assembly {
            sstore(status.slot, true)
        }
    }

    function stopSale() external onlyOwner {
        require(status, "SALE_ALREADY_STOPED");
        assembly {
            sstore(status.slot, false)
        }
    }

    function addToken(
        address _token, 
        uint256 _numTokens
    ) external onlyOwner zeroAddress(_token) isApproved(_token) invalidAmount(_numTokens) {
        IBEP20(_token).safeTransferFrom(_msgSender(), address(this), _numTokens);
        emit AddToken(_token, _numTokens, block.timestamp);
    }

    function buyToken(
        address _user, 
        address _token, 
        uint256 _numTokens
    ) external payable isContract(_msgSender()) nonReentrant zeroAddress(_user) zeroAddress(_token) isApproved(_token) invalidAmount(_numTokens) {
        require(status, "SALE_NOT_STARTED");
        if (msg.value != rate(_numTokens)) revert rateError(rate(_numTokens));

        _balances[_user][_token] += _numTokens;
        _weiRaised[_token] += _numTokens;
        _sendValue(owner(), msg.value);
        emit BuyToken(_msgSender(), _user, _token, _numTokens, block.timestamp);
    }

    function claimToken(address _token) external isContract(_msgSender()) nonReentrant zeroAddress(_token) isApproved(_token) {
        require(!status, "SALE_NOT_STOPPED");
        if (_selectorBalanceOf(_token, address(this)) < balanceOfToken(_msgSender(), _token)) revert Invalid_Contract_Balance();
        if (balanceOfToken(_msgSender(), _token) < 1) revert Invalid_Balance();

        uint256 _numTokens = balanceOfToken(_msgSender(),_token);
        unchecked {
            _balances[_msgSender()][_token] -= _numTokens;
        }
        _weiRaised[_token] -= _numTokens;
        IBEP20(_token).safeTransfer(_msgSender(), _numTokens);
        emit ClaimToken(_msgSender(), _token, _numTokens, block.timestamp);
    }

    function approveToken(address _token) external zeroAddress(_token) onlyOwner {
        if (_approvedToken[_token] == true) revert Invalid_Status();
        
        _approvedToken[_token] = true;
        _tokenList.push(_token);
    }

    function unApproveToken(uint256 _index, address _token) external zeroAddress(_token) onlyOwner {
        if (tokenByIndex(_index) != _token) revert Token_MissMatch();
        if (_approvedToken[_token] == false) revert Invalid_Status();

        _approvedToken[_token] = false;
        _removeToken(_index);
    }

    function failSafe(
        address _token, 
        address _user, 
        uint256 _amount
    ) external onlyOwner zeroAddress(_user) invalidAmount(_amount) {
        if (_token == address(0)) {
            _sendValue(_user, _amount);
        } else {
            IBEP20(_token).safeTransfer(_user, _amount);
        }
        emit FailSafe(_token, _user, _amount, block.timestamp);
    }

    function setRate(uint256 _newRate) external onlyOwner invalidAmount(_newRate) {
        assembly {
            sstore(_rate.slot, _newRate)
        }
    }

    function weiRaised(address _token) external zeroAddress(_token) view returns (uint256) {
        return _weiRaised[_token];
    }

    function balanceOfCoin(address _account) external view returns (uint256) {
        return _account.balance;
    }

    function saleStatus() external view returns (bool) {
        return status;
    }

    function checkTokenStatus(address _token) public view returns (bool) {
        return _approvedToken[_token];
    }

    function rate(uint256 _numTokens) public view returns (uint256) {
        return _rate * _numTokens;
    }

    function balanceOfToken(address _account, address _token) public view returns (uint256) {
        return _balances[_account][_token];
    }

    function tokenByIndex(uint256 _index) public view returns (address) {
        return _tokenList[_index];
    }

    function _sendValue(address _receiver, uint256 _amount) private {
        bool success;
        assembly {
            success := call(gas(), _receiver, _amount, 0, 0, 0, 0)
        }
        if (!success) revert Transfer_Failed();
    }

    function _removeToken(uint256 _index) private {
        require(_index < _tokenList.length);
        _tokenList[_index] = _tokenList[_tokenList.length-1];
        _tokenList.pop();
    }

    function _selectorBalanceOf(address _token, address _account) private view returns (uint256) {
        bytes memory data = _token.functionStaticCall(abi.encodeWithSelector(IBEP20(_token).balanceOf.selector,_account));
        return abi.decode(data,(uint256));
    }
}