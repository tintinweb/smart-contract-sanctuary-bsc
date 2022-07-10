/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
    constructor() {
        _transferOwnership(_msgSender());
    }

  
    function owner() public view virtual returns (address) {
        return _owner;
    }
   
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
   
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
  
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract ReentrancyGuard {
    
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


contract Metastaketimelock is Ownable, ReentrancyGuard {

    struct Locker {
        uint256 amount;
        uint256 depositTime;
        uint256 period;
    }

    mapping(address => Locker[]) public lockerList;
    mapping(address => bool) public allowedToken;
    mapping(address => bool) public isTokenInSwap;

    function lock(address _token, uint256 _amount, uint256 _period) external onlyOwner {
        require(!isTokenInSwap[_token], "lock: token is in swap, please try later.");
        require(allowedToken[_token], "lock: token is not allowed.");
        require(_amount > 0, "lock: amount should be positif.");
        isTokenInSwap[_token] = true;
        uint256 previousBalance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transferFrom(_msgSender(), address(this), _amount);
        uint256 newBalance = IERC20(_token).balanceOf(address(this));
        uint256 realTokenValue = newBalance - previousBalance;
        Locker memory locker = Locker({
            amount: realTokenValue,
            depositTime: block.timestamp,
            period: _period
        });
        lockerList[_token].push(locker);
        isTokenInSwap[_token] = false;
    }

    function unlock(address _token, uint256 _pid) external onlyOwner returns(bool) {
        require(allowedToken[_token], "unlock: token is not allowed.");
        require(_pid < lockerList[_token].length, "unlock: index doesn't exist.");
        isTokenInSwap[_token] = true;
        Locker storage locker = lockerList[_token][_pid];
        require(block.timestamp >= locker.depositTime + locker.period, "unlock: not yet time to withdraw.");
        require(locker.amount > 0, "unlock: nothing to withdraw.");
        IERC20(_token).transfer(_msgSender(), locker.amount);
        locker.amount = 0;
        isTokenInSwap[_token] = false;
        return true;
    }

    function getTotalLockedAmount(address _token) public view returns(uint256){
        uint256 length = listTokenLength(_token);
        uint256 amount;
        for(uint256 i = 0; i < length; i++){
            Locker memory locker = lockerList[_token][i];
            if(locker.amount > 0) amount += locker.amount;
        }
        return amount;
    }

    function setLocker(address _token, uint256 _pid) external onlyOwner returns(bool) {
        require(allowedToken[_token], "unlock: token is not allowed.");
        require(_pid < lockerList[_token].length, "unlock: index doesn't exist.");
        Locker storage locker = lockerList[_token][_pid];
        require(locker.amount > 0, "unlock: nothing to withdraw.");
        locker.amount = 0;
        return true;
    }

    function allowToken(address _token, bool _isAllowed) external onlyOwner {
        allowedToken[_token] = _isAllowed;
    }

    function listTokenLength(address _token) public view returns(uint256)  {
        return lockerList[_token].length;
    }

    function withdraw(uint256 _ethAmount, bool _withdrawAll) external onlyOwner nonReentrant returns(bool) {
        uint256 ethBalance = address(this).balance;
        uint256 ethAmount;
        if(_withdrawAll){
            ethAmount = ethBalance;
        } else {
            ethAmount = _ethAmount;
        }
        require(ethAmount > 0, "withdraw: eth transfer amount should be greater than 0.");
        require(ethAmount <= ethBalance, "withdraw: eth balance must be larger than amount.");
        (bool success,) = payable(_msgSender()).call{value: ethAmount}(new bytes(0));
        require(success, "withdraw: transfer error.");
        return true;
    }

    function ERC20Withdraw( address _tokenAddress, uint256 _tokenAmount, bool _withdrawAll) external onlyOwner nonReentrant returns(bool){
        IERC20 token = IERC20(_tokenAddress);
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 tokenAmount;
        if(_withdrawAll){
            tokenAmount = tokenBalance;
        } else {
            tokenAmount = _tokenAmount;
        }
        uint256 tokenAllowed = tokenAmount > getTotalLockedAmount(_tokenAddress) ? tokenAmount - getTotalLockedAmount(_tokenAddress) : 0;
        require(tokenAllowed > 0, "ERC20withdraw: token balance must be higher than 0.");
        require(tokenAllowed <= tokenBalance, "ERC20withdraw: token balance must be larger than amount.");
        token.transfer(_msgSender(), tokenAllowed);
        return true;
    }

    function checkBalance(IERC20 _tokenAddress) public view returns(uint256) {
        return _tokenAddress.balanceOf(address(this));
    }
    
    receive() external payable {}
}